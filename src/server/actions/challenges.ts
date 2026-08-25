'use server';

import { revalidatePath } from 'next/cache';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';
import { taskForDay } from '@/server/queries/challenges';
import { currentDay, dateForDay, streakFrom } from '@/lib/challenge-day';

/**
 * Writes for the challenge system.
 *
 * Every mutation runs inside a transaction that also awards points, because a
 * completed day whose points went missing is worse than one that never
 * completed — the member sees the tick and the balance disagree, and has no
 * way to reconcile them.
 */

type Result<T = undefined> =
  | ({ ok: true } & (T extends undefined ? object : { data: T }))
  | { ok: false; error: string };

export async function joinChallenge(slug: string): Promise<Result<{ enrollmentId: string }>> {
  const user = await getCurrentUser();
  if (!user) return { ok: false, error: 'unauthenticated' };

  const challenge = await prisma.challenge.findUnique({
    where: { slug },
    select: { id: true, isActive: true },
  });
  if (!challenge?.isActive) return { ok: false, error: 'not-found' };

  // Retaking a challenge later is fine; being on it twice at once is not.
  const existing = await prisma.enrollment.findFirst({
    where: { userId: user.id, challengeId: challenge.id, status: 'ACTIVE' },
    select: { id: true },
  });
  if (existing) return { ok: true, data: { enrollmentId: existing.id } };

  const enrollment = await prisma.$transaction(async (tx) => {
    const created = await tx.enrollment.create({
      data: { userId: user.id, challengeId: challenge.id },
    });

    // "First Challenge" is the one achievement that can only ever fire here.
    const first = await tx.enrollment.count({ where: { userId: user.id } });
    if (first === 1) await grant(tx, user.id, 'first-challenge');

    return created;
  });

  revalidatePath('/app/challenges');
  revalidatePath('/app');
  return { ok: true, data: { enrollmentId: enrollment.id } };
}

export async function leaveChallenge(slug: string): Promise<Result> {
  const user = await getCurrentUser();
  if (!user) return { ok: false, error: 'unauthenticated' };

  const enrollment = await prisma.enrollment.findFirst({
    where: { userId: user.id, challenge: { slug }, status: 'ACTIVE' },
    select: { id: true },
  });
  if (!enrollment) return { ok: false, error: 'not-found' };

  // Abandoned rather than deleted: the days already completed still belong to
  // the member's history, and their streak is built from them.
  await prisma.enrollment.update({
    where: { id: enrollment.id },
    data: { status: 'ABANDONED' },
  });

  revalidatePath('/app/challenges');
  revalidatePath('/app');
  return { ok: true };
}

/**
 * Record progress against today's task.
 *
 * `amount` is absolute, not a delta — the UI sends "8,249 steps so far", and a
 * double-tapped button or a retried request must not add twice.
 */
export async function logProgress(
  slug: string,
  amount: number,
): Promise<Result<{ completed: boolean; day: number; amount: number }>> {
  const user = await getCurrentUser();
  if (!user) return { ok: false, error: 'unauthenticated' };
  if (!Number.isFinite(amount) || amount < 0) return { ok: false, error: 'invalid-amount' };

  const enrollment = await prisma.enrollment.findFirst({
    where: { userId: user.id, challenge: { slug }, status: 'ACTIVE' },
    include: { challenge: { include: { tasks: true } } },
  });
  if (!enrollment) return { ok: false, error: 'not-enrolled' };

  const { challenge } = enrollment;
  const day = currentDay(enrollment.startedAt);
  if (day > challenge.durationDays) return { ok: false, error: 'challenge-over' };

  const task = taskForDay(challenge.tasks, day);
  if (!task) return { ok: false, error: 'no-task' };

  const target = task.kind === 'CHECK' ? 1 : task.target;
  const capped = Math.min(Math.round(amount), target);
  const date = dateForDay(enrollment.startedAt, day);

  const outcome = await prisma.$transaction(async (tx) => {
    const existing = await tx.dayLog.findUnique({
      where: { enrollmentId_day: { enrollmentId: enrollment.id, day } },
    });

    const alreadyDone = Boolean(existing?.completedAt);
    const nowDone = capped >= target;

    const log = await tx.dayLog.upsert({
      where: { enrollmentId_day: { enrollmentId: enrollment.id, day } },
      create: {
        enrollmentId: enrollment.id,
        day,
        date,
        amount: capped,
        completedAt: nowDone ? new Date() : null,
      },
      update: {
        amount: capped,
        // Completion is sticky: dropping today's number below the target does
        // not un-complete a day that was genuinely finished.
        completedAt: existing?.completedAt ?? (nowDone ? new Date() : null),
      },
    });

    // Points are awarded on the transition into completion, never on a
    // re-save of an already-complete day.
    if (nowDone && !alreadyDone) {
      await tx.pointsEntry.create({
        data: {
          userId: user.id,
          amount: challenge.dayPoints,
          reason: 'DAY_COMPLETED',
          refId: enrollment.id,
        },
      });

      const done = await tx.dayLog.count({
        where: { enrollmentId: enrollment.id, completedAt: { not: null } },
      });

      if (done >= challenge.durationDays) {
        await tx.enrollment.update({
          where: { id: enrollment.id },
          data: { status: 'COMPLETED', completedAt: new Date() },
        });
        await tx.pointsEntry.create({
          data: {
            userId: user.id,
            amount: challenge.rewardPoints,
            reason: 'CHALLENGE_COMPLETED',
            refId: enrollment.id,
          },
        });
        await grant(tx, user.id, 'challenge-finisher');
        if (challenge.durationDays >= 30) await grant(tx, user.id, 'thirty-day-journey');
      }

      // Streak milestones are checked here rather than on read, so the
      // achievement lands the moment it is earned.
      const dates = await tx.dayLog.findMany({
        where: { enrollment: { userId: user.id }, completedAt: { not: null } },
        select: { date: true },
        orderBy: { date: 'desc' },
        take: 400,
      });
      if (streakFrom(dates.map((d) => d.date)) >= 7) {
        await grant(tx, user.id, 'seven-day-streak');
      }
    }

    return { completed: Boolean(log.completedAt), day, amount: log.amount };
  });

  revalidatePath('/app/challenges');
  revalidatePath(`/app/challenges/${slug}`);
  revalidatePath('/app');
  revalidatePath('/app/journey');
  return { ok: true, data: outcome };
}

/** Tick a CHECK task — the one-tap path, so the UI never has to know the target. */
export async function completeToday(slug: string) {
  return logProgress(slug, Number.MAX_SAFE_INTEGER);
}

/**
 * Award an achievement and its points, once. The unique constraint on
 * (userId, achievementId) is what makes this safe to call optimistically.
 */
async function grant(
  tx: Parameters<Parameters<typeof prisma.$transaction>[0]>[0],
  userId: string,
  slug: string,
) {
  const achievement = await tx.achievement.findUnique({
    where: { slug },
    select: { id: true, points: true },
  });
  if (!achievement) return;

  const existing = await tx.earnedAchievement.findUnique({
    where: { userId_achievementId: { userId, achievementId: achievement.id } },
    select: { id: true },
  });
  if (existing) return;

  await tx.earnedAchievement.create({
    data: { userId, achievementId: achievement.id },
  });

  if (achievement.points > 0) {
    await tx.pointsEntry.create({
      data: {
        userId,
        amount: achievement.points,
        reason: 'ACHIEVEMENT',
        refId: achievement.id,
      },
    });
  }
}
