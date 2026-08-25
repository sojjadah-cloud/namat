import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { currentDay, dateForDay, streakFrom } from './challenge-day';
import { omanDate, addDays } from './time';

/**
 * The streak is the mechanic members care most about and the one that is
 * hardest to get right: it depends on day boundaries, on gaps, and on the
 * decision that yesterday still counts. Each of those is pinned here.
 */

const iso = (d: Date) => d.toISOString().slice(0, 10);
/** A completion logged mid-morning Muscat on the given date. */
const done = (date: string) => new Date(`${date}T06:00:00Z`);

describe('currentDay', () => {
  const start = new Date('2026-03-15T06:00:00Z'); // 10:00 Muscat, 15 March

  test('the day you join is day 1', () => {
    assert.equal(currentDay(start, new Date('2026-03-15T18:00:00Z')), 1);
  });

  test('midnight in Muscat moves to day 2, not midnight UTC', () => {
    // 20:00 UTC is 00:00 Muscat on the 16th. Getting this wrong shifts every
    // subsequent day of the challenge by one.
    assert.equal(currentDay(start, new Date('2026-03-15T19:59:00Z')), 1);
    assert.equal(currentDay(start, new Date('2026-03-15T20:00:00Z')), 2);
  });

  test('counts on past the end of the challenge', () => {
    // Callers clamp this themselves; the function reports the truth.
    assert.equal(currentDay(start, new Date('2026-03-25T06:00:00Z')), 11);
  });
});

describe('dateForDay', () => {
  const start = new Date('2026-03-15T06:00:00Z');

  test('day 1 is the join date', () => {
    assert.equal(iso(dateForDay(start, 1)), '2026-03-15');
  });

  test('round-trips with currentDay for every day of a 30-day challenge', () => {
    for (let day = 1; day <= 30; day++) {
      assert.equal(currentDay(start, dateForDay(start, day)), day, `day ${day}`);
    }
  });

  test('spans a month boundary', () => {
    assert.equal(iso(dateForDay(start, 20)), '2026-04-03');
  });
});

describe('streakFrom', () => {
  const now = new Date('2026-03-20T10:00:00Z'); // 14:00 Muscat, Friday 20 March

  test('no completions is no streak', () => {
    assert.equal(streakFrom([], now), 0);
  });

  test('today alone is a streak of one', () => {
    assert.equal(streakFrom([done('2026-03-20')], now), 1);
  });

  test('counts a consecutive run ending today', () => {
    assert.equal(
      streakFrom([done('2026-03-18'), done('2026-03-19'), done('2026-03-20')], now),
      3,
    );
  });

  test('a run ending yesterday still counts', () => {
    // Deliberate: at 00:01 a member has not logged today yet, and showing
    // their streak as broken would be both wrong and demoralising.
    assert.equal(streakFrom([done('2026-03-18'), done('2026-03-19')], now), 2);
  });

  test('a gap of one full day breaks it', () => {
    // Nothing on the 19th or 20th, so the run is already over.
    assert.equal(streakFrom([done('2026-03-16'), done('2026-03-17')], now), 0);
  });

  test('only the run touching today counts, not the longest ever', () => {
    assert.equal(
      streakFrom(
        [done('2026-03-01'), done('2026-03-02'), done('2026-03-03'), done('2026-03-19'), done('2026-03-20')],
        now,
      ),
      2,
    );
  });

  test('two completions on one day do not inflate it', () => {
    // Two enrollments finished on the same date is one day of streak.
    assert.equal(
      streakFrom([done('2026-03-20'), done('2026-03-20'), done('2026-03-19')], now),
      2,
    );
  });

  test('order of the input does not matter', () => {
    assert.equal(
      streakFrom([done('2026-03-20'), done('2026-03-18'), done('2026-03-19')], now),
      3,
    );
  });

  test('a completion logged at 11pm Muscat counts for that day', () => {
    // 19:30 UTC on the 19th is 23:30 Muscat the same day. If this were read in
    // UTC it would still be the 19th — but the equivalent 20:30 UTC is the
    // 20th in Muscat, and that is the case that used to break.
    const late = new Date('2026-03-19T20:30:00Z'); // 00:30 Muscat on the 20th
    assert.equal(streakFrom([done('2026-03-19'), late], now), 2);
  });

  test('a long unbroken run counts fully', () => {
    const days = Array.from({ length: 30 }, (_, i) =>
      addDays(omanDate(now), -i),
    );
    assert.equal(streakFrom(days, now), 30);
  });
});
