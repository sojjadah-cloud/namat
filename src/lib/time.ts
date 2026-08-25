/**
 * Calendar arithmetic for NAMAT, in one place.
 *
 * Every "day" in this product is an Oman day. That matters because the server
 * is not in Oman: on Vercel it runs in UTC, so between 8pm and midnight Muscat
 * time the server's calendar is already on yesterday. Left to the platform,
 * a member finishing a walk at 10pm would see it land on the wrong day, their
 * streak would break at a boundary they never crossed, and Journey would show
 * a different "today" than Challenges — the same product disagreeing with
 * itself twice a night.
 *
 * The offset is a fixed +4: Oman has never observed daylight saving, so a
 * timezone-database lookup would buy nothing and cost a dependency. Expanding
 * to a market that does observe DST is the one reason to change this file, and
 * the change belongs here rather than at each call site.
 */

const OMAN_OFFSET_MS = 4 * 60 * 60_000;

export const MS_PER_DAY = 24 * 60 * 60_000;

/**
 * The calendar date in Oman, as a UTC-midnight Date.
 *
 * Postgres `@db.Date` columns carry no time, so representing a day as UTC
 * midnight keeps what is written equal to what is read back.
 */
export function omanDate(instant: Date = new Date()): Date {
  const shifted = new Date(instant.getTime() + OMAN_OFFSET_MS);
  return new Date(
    Date.UTC(shifted.getUTCFullYear(), shifted.getUTCMonth(), shifted.getUTCDate()),
  );
}

/** Whole calendar days from `from` to `to`. Negative when `to` is earlier. */
export function daysBetween(from: Date, to: Date): number {
  return Math.round((omanDate(to).getTime() - omanDate(from).getTime()) / MS_PER_DAY);
}

export function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * MS_PER_DAY);
}

/** Whether two instants fall on the same Oman calendar day. */
export function isSameDay(a: Date, b: Date): boolean {
  return omanDate(a).getTime() === omanDate(b).getTime();
}

export function isToday(date: Date, now: Date = new Date()): boolean {
  return isSameDay(date, now);
}

/**
 * The Saturday-start week containing `date`, as an Oman calendar date.
 * The Omani working week runs Sunday to Thursday, so a week that begins on
 * Saturday puts the weekend at the end where a reader expects it.
 */
export function startOfWeek(date: Date = new Date()): Date {
  const day = omanDate(date);
  // getUTCDay on a UTC-midnight date gives the Oman weekday: 0 Sun … 6 Sat.
  const offset = (day.getUTCDay() + 1) % 7;
  return addDays(day, -offset);
}
