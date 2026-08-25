import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import {
  scoreFor,
  standing,
  settle,
  pointsFor,
  duelDay,
  hasEnded,
  dayMet,
  type DuelShape,
  type Entry,
} from './duel';

/**
 * A duel has points and a public result attached, so the ways it can be wrong
 * are the ways a member feels cheated: a tie called as a loss, a lead that
 * flips on a rounding error, a day counted twice. Each of those is pinned here.
 */

const KHALID = 'khalid';
const AHMED = 'ahmed';

const steps = (over: Partial<DuelShape> = {}): DuelShape => ({
  metric: 'STEPS',
  target: 10000,
  durationDays: 7,
  startedAt: new Date('2026-03-15T06:00:00Z'),
  ...over,
});

const e = (userId: string, day: number, amount: number): Entry => ({ userId, day, amount });

describe('volume metrics total everything logged', () => {
  test('exceeding the daily target counts in full', () => {
    // Walking 12,000 on a 10,000 day is worth 12,000 — the extra is the point
    // of competing rather than just completing.
    const entries = [e(KHALID, 1, 12000), e(KHALID, 2, 8000)];
    assert.equal(scoreFor(steps(), entries, KHALID), 20000);
  });

  test('only the challenger’s own entries count', () => {
    const entries = [e(KHALID, 1, 5000), e(AHMED, 1, 9000)];
    assert.equal(scoreFor(steps(), entries, KHALID), 5000);
    assert.equal(scoreFor(steps(), entries, AHMED), 9000);
  });

  test('entries outside the duel window are ignored', () => {
    // Day 0 and day 8 of a seven-day duel are not part of it.
    const entries = [e(KHALID, 0, 9999), e(KHALID, 1, 100), e(KHALID, 8, 9999)];
    assert.equal(scoreFor(steps(), entries, KHALID), 100);
  });

  test('negative amounts cannot subtract from a score', () => {
    const entries = [e(KHALID, 1, 5000), e(KHALID, 2, -4000)];
    assert.equal(scoreFor(steps(), entries, KHALID), 5000);
  });

  test('no entries is zero, not an error', () => {
    assert.equal(scoreFor(steps(), [], KHALID), 0);
  });
});

describe('STREAK counts whole days, not volume', () => {
  const streak = steps({ metric: 'STREAK', target: 1 });

  test('a day that met the target counts once', () => {
    const entries = [e(KHALID, 1, 1), e(KHALID, 2, 1)];
    assert.equal(scoreFor(streak, entries, KHALID), 2);
  });

  test('doing extra on one day does not buy another day', () => {
    // The whole mechanic is not breaking, so 5 on Monday is still one day.
    const entries = [e(KHALID, 1, 5)];
    assert.equal(scoreFor(streak, entries, KHALID), 1);
  });

  test('a day short of the target counts for nothing', () => {
    const water = steps({ metric: 'STREAK', target: 8 });
    const entries = [e(KHALID, 1, 7), e(KHALID, 2, 8)];
    assert.equal(scoreFor(water, entries, KHALID), 1);
  });
});

describe('dayMet', () => {
  test('meeting exactly counts', () => {
    assert.equal(dayMet(10000, 10000), true);
  });
  test('one short does not', () => {
    assert.equal(dayMet(9999, 10000), false);
  });
  test('a zero target never counts, rather than always counting', () => {
    // Guards a misconfigured duel from marking every day complete.
    assert.equal(dayMet(0, 0), false);
  });
});

describe('who is leading', () => {
  test('the higher score leads', () => {
    const entries = [e(KHALID, 1, 8420), e(AHMED, 1, 7950)];
    const s = standing(steps(), entries, KHALID, AHMED);
    assert.equal(s.leaderId, KHALID);
    assert.equal(s.margin, 470);
  });

  test('a level score has no leader at all', () => {
    // Not "the challenger by default" — a phantom leader is what makes a
    // "took the lead" notification fire at nobody.
    const entries = [e(KHALID, 1, 5000), e(AHMED, 1, 5000)];
    const s = standing(steps(), entries, KHALID, AHMED);
    assert.equal(s.leaderId, null);
    assert.equal(s.margin, 0);
  });

  test('margin is signed from the challenger’s side', () => {
    const entries = [e(AHMED, 1, 9000)];
    assert.equal(standing(steps(), entries, KHALID, AHMED).margin, -9000);
  });
});

describe('settling', () => {
  test('the leader wins', () => {
    const entries = [e(KHALID, 1, 68420), e(AHMED, 1, 64820)];
    assert.deepEqual(settle(steps(), entries, KHALID, AHMED), {
      outcome: 'WIN',
      winnerId: KHALID,
    });
  });

  test('a level score is a draw, not a win for whoever was challenged', () => {
    const entries = [e(KHALID, 1, 5000), e(AHMED, 1, 5000)];
    assert.deepEqual(settle(steps(), entries, KHALID, AHMED), {
      outcome: 'DRAW',
      winnerId: null,
    });
  });

  test('a duel nobody logged is a draw', () => {
    assert.deepEqual(settle(steps(), [], KHALID, AHMED), {
      outcome: 'DRAW',
      winnerId: null,
    });
  });
});

describe('points', () => {
  test('the winner takes completion plus the bonus', () => {
    const result = settle(steps(), [e(KHALID, 1, 100)], KHALID, AHMED);
    assert.equal(pointsFor(result, KHALID), 150);
  });

  test('finishing and losing still pays', () => {
    // Turning up for seven days is worth something even without winning.
    const result = settle(steps(), [e(KHALID, 1, 100)], KHALID, AHMED);
    assert.equal(pointsFor(result, AHMED), 75);
  });

  test('a draw pays both sides the completion award and no bonus', () => {
    const result = settle(steps(), [], KHALID, AHMED);
    assert.equal(pointsFor(result, KHALID), 75);
    assert.equal(pointsFor(result, AHMED), 75);
  });
});

describe('the clock', () => {
  const duel = steps(); // starts 10:00 Muscat on 15 March, runs 7 days

  test('the day it starts is day 1', () => {
    assert.equal(duelDay(duel, new Date('2026-03-15T18:00:00Z')), 1);
  });

  test('day numbers follow Oman midnight, not UTC', () => {
    // 20:00 UTC is already the 16th in Muscat.
    assert.equal(duelDay(duel, new Date('2026-03-15T19:59:00Z')), 1);
    assert.equal(duelDay(duel, new Date('2026-03-15T20:00:00Z')), 2);
  });

  test('never reports past the final day', () => {
    assert.equal(duelDay(duel, new Date('2026-04-01T06:00:00Z')), 7);
  });

  test('is still running on its last day', () => {
    // Day 7 is 21 March; the duel closes at the end of it.
    assert.equal(hasEnded(duel, new Date('2026-03-21T12:00:00Z')), false);
  });

  test('has ended once the final day is over', () => {
    // 20:00 UTC on the 21st is midnight starting the 22nd in Muscat.
    assert.equal(hasEnded(duel, new Date('2026-03-21T20:00:00Z')), true);
  });
});
