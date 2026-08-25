import { daysBetween, omanDate, addDays } from './time';

/**
 * Scoring for a head-to-head challenge.
 *
 * Pure and free of Prisma so the rules can be tested directly — the ways a
 * duel goes wrong are all arithmetic (a tie misreported as a win, a day
 * counted twice, a lead change fired on every save) and none of them need a
 * database to reproduce.
 *
 * Two metrics score differently and the difference matters:
 *
 *   - Volume metrics (steps, workouts, water) total everything logged. Beating
 *     the daily target is worth something, so 12,000 steps counts as 12,000.
 *   - STREAK is about not breaking. Only whole days that met the target count,
 *     and going twice as far on Tuesday does not buy Wednesday off.
 */

export type DuelMetric = 'STEPS' | 'WORKOUTS' | 'WATER' | 'STREAK' | 'CUSTOM';

export type Entry = { userId: string; day: number; amount: number };

export type DuelShape = {
  metric: DuelMetric;
  /** Daily goal. For STREAK this is what a day must reach to count. */
  target: number;
  durationDays: number;
  startedAt: Date;
};

/** Whether a day's logged amount satisfies that day's goal. */
export function dayMet(amount: number, target: number): boolean {
  return target > 0 && amount >= target;
}

/**
 * One side's score.
 *
 * Amounts are clamped to the target for STREAK only. For volume metrics the
 * excess is the whole point of competing.
 */
export function scoreFor(
  duel: DuelShape,
  entries: readonly Entry[],
  userId: string,
): number {
  const mine = entries.filter((e) => e.userId === userId && e.day >= 1 && e.day <= duel.durationDays);

  if (duel.metric === 'STREAK') {
    return mine.filter((e) => dayMet(e.amount, duel.target)).length;
  }

  return mine.reduce((sum, e) => sum + Math.max(0, e.amount), 0);
}

/** Which day of the duel it is, 1-based, clamped to the duel's length. */
export function duelDay(duel: DuelShape, now: Date = new Date()): number {
  const raw = daysBetween(duel.startedAt, now) + 1;
  return Math.min(Math.max(1, raw), duel.durationDays);
}

/**
 * The instant the duel closes: Oman midnight at the end of its final day.
 *
 * `omanDate` returns a UTC-midnight marker for a calendar day, which is four
 * hours *later* than the Muscat midnight it stands for. Returning it unadjusted
 * kept a finished duel accepting entries until 4am the next morning — long
 * enough for someone to log a winning number after the contest had ended.
 */
export function duelEndsAt(startedAt: Date, durationDays: number): Date {
  const dayAfterLast = addDays(omanDate(startedAt), durationDays);
  return new Date(dayAfterLast.getTime() - OMAN_OFFSET_MS);
}

const OMAN_OFFSET_MS = 4 * 60 * 60_000;

/**
 * Whether the duel is over.
 *
 * Compared by day number rather than by instant: both sides are already
 * bucketed into Oman calendar days, and mixing the two representations is
 * exactly what produced the four-hour overrun above.
 */
export function hasEnded(duel: DuelShape, now: Date = new Date()): boolean {
  return daysBetween(duel.startedAt, now) + 1 > duel.durationDays;
}

export type Standing = {
  challengerScore: number;
  opponentScore: number;
  /** Positive when the challenger leads, negative when the opponent does. */
  margin: number;
  /** Null while level — a tie has no leader, and pretending otherwise is how
   *  "took the lead" notifications end up firing at nobody. */
  leaderId: string | null;
};

export function standing(
  duel: DuelShape,
  entries: readonly Entry[],
  challengerId: string,
  opponentId: string,
): Standing {
  const challengerScore = scoreFor(duel, entries, challengerId);
  const opponentScore = scoreFor(duel, entries, opponentId);
  const margin = challengerScore - opponentScore;

  return {
    challengerScore,
    opponentScore,
    margin,
    leaderId: margin === 0 ? null : margin > 0 ? challengerId : opponentId,
  };
}

export type Result =
  | { outcome: 'DRAW'; winnerId: null }
  | { outcome: 'WIN'; winnerId: string };

/**
 * The final result. A level score is a draw, explicitly — never resolved by
 * who logged first or who was challenged, both of which are arbitrary and
 * would feel rigged to the person who lost on them.
 */
export function settle(
  duel: DuelShape,
  entries: readonly Entry[],
  challengerId: string,
  opponentId: string,
): Result {
  const { leaderId } = standing(duel, entries, challengerId, opponentId);
  return leaderId === null
    ? { outcome: 'DRAW', winnerId: null }
    : { outcome: 'WIN', winnerId: leaderId };
}

/** Points awarded when a duel settles. */
export const DUEL_POINTS = {
  /** Both sides get this for finishing, win or lose. */
  COMPLETION: 75,
  /** The winner's additional share. A draw pays neither side the bonus. */
  WIN_BONUS: 75,
} as const;

export function pointsFor(result: Result, userId: string): number {
  const won = result.outcome === 'WIN' && result.winnerId === userId;
  return DUEL_POINTS.COMPLETION + (won ? DUEL_POINTS.WIN_BONUS : 0);
}
