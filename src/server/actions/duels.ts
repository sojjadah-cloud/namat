'use server';

import { revalidatePath } from 'next/cache';
import type { DuelMetric } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';
import {
  duelDay,
  duelEndsAt,
  hasEnded,
  dayMet,
  settle,
  standing,
  pointsFor,
} from '@/lib/duel';
import { omanDate, addDays } from '@/lib/time';

/**
 * Peer challenges: sending, answering, logging and settling.
 *
 * Two rules run through all of it.
 *
 * Nothing counts before both sides agree. A pending duel has no clock and no
 * entries — otherwise a slow reply silently costs the opponent days of a
 * contest they had not yet joined.
 *
 * Privacy is enforced on the server, every time. The UI hides a challenge
 * button when someone is not accepting them, but a hidden button is a
 * suggestion; this is the part that actually holds.
 */

type Result<T = undefined> =
  | ({ ok: true } & (T extends undefined ? object : { data: T }))
  | { ok: false; error: string };

/** Default daily targets, so the sender does not have to invent a number. */
const DEFAULT_TARGET: Record<DuelMetric, number> = {
  STEPS: 10000,
  WORKOUTS: 1,
  WATER: 8,
  STREAK: 1,
  CUSTOM: 1,
};

export async function sendChallenge(input: {
  opponentUsername: string;
  metric: DuelMetric;
  durationDays: number;
  target?: number;
}): Promise<Result<{ duelId: string }>> {
  const me = await getCurrentUser();
  if (!me) return { ok: false, error: 'unauthenticated' };

  if (![1, 3, 7, 14].includes(input.durationDays)) {
    return { ok: false, error: 'invalid-duration' };
  }

  const opponent = await prisma.user.findUnique({
    where: { username: input.opponentUsername },
    select: { id: true, challengePrivacy: true },
  });
  if (!opponent) return { ok: false, error: 'not-found' };
  if (opponent.id === me.id) return { ok: false, error: 'self-challenge' };

  // The privacy check lives here rather than only in the UI: a hidden button
  // stops the polite path, not a crafted request.
  if (opponent.challengePrivacy === 'NOBODY') {
    return { ok: false, error: 'not-accepting' };
  }
  if (opponent.challengePrivacy === 'CONNECTIONS') {
    const connected = await prisma.connection.findFirst({
      where: { followerId: opponent.id, followingId: me.id },
      select: { id: true },
    });
    if (!connected) return { ok: false, error: 'not-connected' };
  }

  // One live contest per pair. Without this, a stack of pending invitations
  // turns into a stack of simultaneous duels the moment they are all accepted.
  const existing = await prisma.duel.findFirst({
    where: {
      status: { in: ['PENDING', 'ACTIVE'] },
      OR: [
        { challengerId: me.id, opponentId: opponent.id },
        { challengerId: opponent.id, opponentId: me.id },
      ],
    },
    select: { id: true, status: true },
  });
  if (existing) return { ok: false, error: `already-${existing.status.toLowerCase()}` };

  const duel = await prisma.duel.create({
    data: {
      challengerId: me.id,
      opponentId: opponent.id,
      metric: input.metric,
      target: input.target ?? DEFAULT_TARGET[input.metric],
      durationDays: input.durationDays,
      status: 'PENDING',
    },
  });

  revalidatePath('/app/challenges');
  return { ok: true, data: { duelId: duel.id } };
}

export async function respondToChallenge(
  duelId: string,
  accept: boolean,
): Promise<Result> {
  const me = await getCurrentUser();
  if (!me) return { ok: false, error: 'unauthenticated' };

  const duel = await prisma.duel.findUnique({
    where: { id: duelId },
    select: { id: true, opponentId: true, status: true, durationDays: true },
  });
  if (!duel) return { ok: false, error: 'not-found' };
  // Only the person challenged may answer — not the sender, not a bystander.
  if (duel.opponentId !== me.id) return { ok: false, error: 'not-yours' };
  if (duel.status !== 'PENDING') return { ok: false, error: 'already-answered' };

  if (!accept) {
    await prisma.duel.update({ where: { id: duelId }, data: { status: 'DECLINED' } });
    revalidatePath('/app/challenges');
    return { ok: true };
  }

  // The clock starts now, at the top of today in Muscat, so both sides get
  // whole days rather than a first day that is however many hours were left.
  const startedAt = omanDate();

  await prisma.$transaction([
    prisma.duel.update({
      where: { id: duelId },
      data: {
        status: 'ACTIVE',
        startedAt,
        endsAt: duelEndsAt(startedAt, duel.durationDays),
      },
    }),
    prisma.duelEvent.create({
      data: { duelId, userId: me.id, kind: 'ACCEPTED' },
    }),
  ]);

  revalidatePath('/app/challenges');
  revalidatePath(`/app/challenges/duel/${duelId}`);
  return { ok: true };
}

/** Withdraw an invitation that has not been answered. */
export async function cancelChallenge(duelId: string): Promise<Result> {
  const me = await getCurrentUser();
  if (!me) return { ok: false, error: 'unauthenticated' };

  const { count } = await prisma.duel.updateMany({
    where: { id: duelId, challengerId: me.id, status: 'PENDING' },
    data: { status: 'CANCELLED' },
  });
  if (count === 0) return { ok: false, error: 'not-found' };

  revalidatePath('/app/challenges');
  return { ok: true };
}

/**
 * Record today's number.
 *
 * Absolute, not a delta, so a double tap or a retried request cannot inflate a
 * score. Every entry is stamped SELF_REPORTED — see the note on the schema
 * about why that matters more here than it does for a solo challenge.
 */
export async function logDuelProgress(
  duelId: string,
  amount: number,
): Promise<Result<{ score: number; leading: boolean }>> {
  const me = await getCurrentUser();
  if (!me) return { ok: false, error: 'unauthenticated' };
  if (!Number.isFinite(amount) || amount < 0) return { ok: false, error: 'invalid-amount' };

  const duel = await prisma.duel.findUnique({
    where: { id: duelId },
    include: { entries: { select: { userId: true, day: true, amount: true } } },
  });
  if (!duel || !duel.startedAt) return { ok: false, error: 'not-found' };
  if (duel.status !== 'ACTIVE') return { ok: false, error: 'not-active' };

  const mine = duel.challengerId === me.id || duel.opponentId === me.id;
  if (!mine) return { ok: false, error: 'not-yours' };

  const shape = {
    metric: duel.metric,
    target: duel.target,
    durationDays: duel.durationDays,
    startedAt: duel.startedAt,
  };
  if (hasEnded(shape)) return { ok: false, error: 'duel-over' };

  const day = duelDay(shape);
  const rounded = Math.round(amount);
  const date = addDays(omanDate(duel.startedAt), day - 1);

  const before = standing(shape, duel.entries, duel.challengerId, duel.opponentId);

  await prisma.duelEntry.upsert({
    where: { duelId_userId_day: { duelId, userId: me.id, day } },
    create: {
      duelId,
      userId: me.id,
      day,
      date,
      amount: rounded,
      metAt: dayMet(rounded, duel.target) ? new Date() : null,
    },
    update: {
      amount: rounded,
      // Meeting the goal is sticky: editing today's number down afterwards
      // does not un-meet a day that was genuinely met.
      metAt: dayMet(rounded, duel.target) ? new Date() : undefined,
    },
  });

  const entries = duel.entries
    .filter((e) => !(e.userId === me.id && e.day === day))
    .concat({ userId: me.id, day, amount: rounded });
  const after = standing(shape, entries, duel.challengerId, duel.opponentId);

  // A lead change is an event worth telling both sides about; a save that
  // leaves the order unchanged is not.
  if (after.leaderId === me.id && before.leaderId !== me.id) {
    await prisma.duelEvent.create({
      data: { duelId, userId: me.id, kind: 'TOOK_LEAD' },
    });
  } else {
    await prisma.duelEvent.create({
      data: { duelId, userId: me.id, kind: 'PROGRESS', amount: rounded },
    });
  }

  revalidatePath(`/app/challenges/duel/${duelId}`);
  return {
    ok: true,
    data: {
      score: me.id === duel.challengerId ? after.challengerScore : after.opponentScore,
      leading: after.leaderId === me.id,
    },
  };
}

/**
 * Close a duel whose time is up and pay both sides.
 *
 * Safe to call repeatedly: the status guard means a second call after the
 * first has settled does nothing, so this can run from a page load, a cron, or
 * both, without paying anyone twice.
 */
export async function settleDuel(duelId: string): Promise<Result> {
  const duel = await prisma.duel.findUnique({
    where: { id: duelId },
    include: { entries: { select: { userId: true, day: true, amount: true } } },
  });
  if (!duel?.startedAt) return { ok: false, error: 'not-found' };
  if (duel.status !== 'ACTIVE') return { ok: false, error: 'not-active' };

  const shape = {
    metric: duel.metric,
    target: duel.target,
    durationDays: duel.durationDays,
    startedAt: duel.startedAt,
  };
  if (!hasEnded(shape)) return { ok: false, error: 'still-running' };

  const result = settle(shape, duel.entries, duel.challengerId, duel.opponentId);

  await prisma.$transaction(async (tx) => {
    const claimed = await tx.duel.updateMany({
      where: { id: duelId, status: 'ACTIVE' },
      data: {
        status: 'COMPLETED',
        settledAt: new Date(),
        winnerId: result.winnerId,
      },
    });
    // Another caller got here first; their transaction pays the points.
    if (claimed.count === 0) return;

    for (const userId of [duel.challengerId, duel.opponentId]) {
      await tx.pointsEntry.create({
        data: {
          userId,
          amount: pointsFor(result, userId),
          reason: 'CHALLENGE_COMPLETED',
          refId: duelId,
        },
      });
    }

    await tx.duelEvent.create({
      data: { duelId, userId: duel.challengerId, kind: 'COMPLETED' },
    });
  });

  revalidatePath(`/app/challenges/duel/${duelId}`);
  revalidatePath('/app/challenges');
  return { ok: true };
}
