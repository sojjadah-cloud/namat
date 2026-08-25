import { cache } from 'react';
import type { Challenge, ChallengeTask, DayLog } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';
import { currentDay, streakFrom, omanDate } from '@/lib/challenge-day';

/**
 * Reads for the challenge system.
 *
 * Progress is always derived from DayLog rows rather than from a counter on
 * the enrollment: a stored "days completed" number drifts the first time a row
 * is edited or a job runs twice, and there is no way to notice that it has.
 */

/** The task governing a given day — the per-day row if there is one, else the daily default. */
export function taskForDay(tasks: ChallengeTask[], day: number) {
  return tasks.find((t) => t.day === day) ?? tasks.find((t) => t.day === null) ?? null;
}

export const listChallenges = cache(async () => {
  const [challenges, user] = await Promise.all([
    prisma.challenge.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
      include: {
        tasks: true,
        _count: { select: { enrollments: true } },
      },
    }),
    getCurrentUser(),
  ]);

  const enrollments = user
    ? await prisma.enrollment.findMany({
        where: { userId: user.id, status: 'ACTIVE' },
        select: { challengeId: true },
      })
    : [];

  const joined = new Set(enrollments.map((e) => e.challengeId));

  return challenges.map((c) => ({
    ...c,
    // Seeded head start plus real sign-ups, so a new challenge does not read
    // as abandoned on launch day.
    participants: c.baseParticipants + c._count.enrollments,
    joined: joined.has(c.id),
  }));
});

export type ChallengeListItem = Awaited<ReturnType<typeof listChallenges>>[number];

export const getChallenge = cache(async (slug: string) => {
  const challenge = await prisma.challenge.findUnique({
    where: { slug },
    include: { tasks: true, _count: { select: { enrollments: true } } },
  });
  if (!challenge) return null;

  const user = await getCurrentUser();
  const enrollment = user
    ? await prisma.enrollment.findFirst({
        where: { userId: user.id, challengeId: challenge.id, status: 'ACTIVE' },
        include: { days: { orderBy: { day: 'asc' } } },
      })
    : null;

  return {
    ...challenge,
    participants: challenge.baseParticipants + challenge._count.enrollments,
    enrollment,
    progress: enrollment ? summarise(challenge, enrollment.days, enrollment.startedAt) : null,
  };
});

/** Where an enrollment stands: today's task, today's amount, days done. */
function summarise(
  challenge: Challenge & { tasks: ChallengeTask[] },
  days: DayLog[],
  startedAt: Date,
) {
  const day = Math.min(currentDay(startedAt), challenge.durationDays);
  const task = taskForDay(challenge.tasks, day);
  const todayLog = days.find((d) => d.day === day);
  const completedDays = days.filter((d) => d.completedAt).length;

  return {
    day,
    task,
    amount: todayLog?.amount ?? 0,
    target: task?.target ?? 1,
    todayDone: Boolean(todayLog?.completedAt),
    completedDays,
    // Percentage of the whole challenge, not of today.
    percent: Math.round((completedDays / challenge.durationDays) * 100),
    daysLeft: Math.max(0, challenge.durationDays - day + (todayLog?.completedAt ? 0 : 1)),
  };
}

/**
 * The single challenge Home leads with — the one most likely to be acted on
 * now, which is the one furthest along rather than the newest.
 */
export const getActiveChallenge = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return null;

  const enrollments = await prisma.enrollment.findMany({
    where: { userId: user.id, status: 'ACTIVE' },
    include: {
      challenge: { include: { tasks: true } },
      days: { orderBy: { day: 'asc' } },
    },
  });
  if (enrollments.length === 0) return null;

  const scored = enrollments.map((e) => ({
    enrollment: e,
    progress: summarise(e.challenge, e.days, e.startedAt),
  }));

  // Prefer something still open today; among those, the nearest to finishing.
  scored.sort((a, b) => {
    if (a.progress.todayDone !== b.progress.todayDone) return a.progress.todayDone ? 1 : -1;
    return b.progress.percent - a.progress.percent;
  });

  return scored[0];
});

/**
 * Consecutive days with at least one completed challenge day, across every
 * enrollment. Switching challenges mid-run should not cost the streak.
 */
export const getStreak = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return 0;

  const days = await prisma.dayLog.findMany({
    where: { enrollment: { userId: user.id }, completedAt: { not: null } },
    select: { date: true },
    orderBy: { date: 'desc' },
    take: 400,
  });

  return streakFrom(days.map((d) => d.date));
});

export const getPointsBalance = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return 0;

  const { _sum } = await prisma.pointsEntry.aggregate({
    where: { userId: user.id },
    _sum: { amount: true },
  });
  return _sum.amount ?? 0;
});

export const getAchievements = cache(async () => {
  const user = await getCurrentUser();

  const [all, earned] = await Promise.all([
    prisma.achievement.findMany({ orderBy: { sortOrder: 'asc' } }),
    user
      ? prisma.earnedAchievement.findMany({
          where: { userId: user.id },
          select: { achievementId: true, earnedAt: true },
        })
      : Promise.resolve([]),
  ]);

  const earnedMap = new Map(earned.map((e) => [e.achievementId, e.earnedAt]));
  return all.map((a) => ({ ...a, earnedAt: earnedMap.get(a.id) ?? null }));
});

/**
 * The NAMAT Score: a motivational lifestyle indicator, explicitly not a health
 * measurement. Four weighted parts, each capped, so no single behaviour can
 * carry the whole number and no part can push it over 100.
 *
 * The parts are returned alongside the total because a score you cannot break
 * down is a number people learn to ignore.
 */
export const getNamatScore = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return null;

  const since = new Date(Date.now() - 28 * 24 * 60 * 60_000);
  const today = omanDate();

  const [completedDays, activeCount, bookingCount, streak] = await Promise.all([
    prisma.dayLog.count({
      where: {
        enrollment: { userId: user.id },
        completedAt: { not: null },
        date: { gte: omanDate(since) },
      },
    }),
    prisma.enrollment.count({ where: { userId: user.id, status: 'ACTIVE' } }),
    prisma.booking.count({
      where: { userId: user.id, status: 'COMPLETED', createdAt: { gte: since } },
    }),
    getStreak(),
  ]);

  // Each part is scaled against what a genuinely engaged month looks like,
  // then clamped so the total cannot exceed 100.
  const consistency = Math.min(35, Math.round((completedDays / 20) * 35));
  const momentum = Math.min(25, Math.round((streak / 14) * 25));
  const activity = Math.min(25, Math.round((bookingCount / 8) * 25));
  const engagement = Math.min(15, activeCount * 8);

  return {
    total: consistency + momentum + activity + engagement,
    parts: { consistency, momentum, activity, engagement },
    asOf: today,
  };
});
