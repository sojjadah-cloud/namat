/**
 * Enrollment-specific day arithmetic. The calendar itself — and the reason it
 * runs on Oman time rather than the server's — lives in `time.ts`.
 */

import { omanDate, addDays, daysBetween, MS_PER_DAY } from './time';

export { omanDate, addDays, daysBetween, MS_PER_DAY };

/**
 * Which day of the challenge today is, 1-based.
 *
 * Returns a number past `durationDays` when the window has closed — callers
 * decide whether that means "finished" or "expired", because the answer
 * differs for a completed enrollment and an abandoned one.
 */
export function currentDay(startedAt: Date, now: Date = new Date()): number {
  return daysBetween(startedAt, now) + 1;
}

/** The calendar date day N of an enrollment falls on. */
export function dateForDay(startedAt: Date, day: number): Date {
  return addDays(omanDate(startedAt), day - 1);
}

/**
 * Longest run of consecutive completed days ending today or yesterday.
 *
 * Yesterday still counts: a streak should not read as broken at 00:01 just
 * because the day has turned and nothing has been logged yet. It breaks once
 * a full day passes with nothing completed.
 */
export function streakFrom(completedDates: Date[], now: Date = new Date()): number {
  if (completedDates.length === 0) return 0;

  const days = new Set(completedDates.map((d) => omanDate(d).getTime()));
  const today = omanDate(now).getTime();

  // Anchor on today if it is done, otherwise on yesterday. Anything older
  // means the run has already been broken.
  let cursor = days.has(today) ? today : today - MS_PER_DAY;
  if (!days.has(cursor)) return 0;

  let streak = 0;
  while (days.has(cursor)) {
    streak += 1;
    cursor -= MS_PER_DAY;
  }
  return streak;
}
