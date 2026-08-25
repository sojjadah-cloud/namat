import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import {
  omanDate,
  daysBetween,
  addDays,
  isSameDay,
  startOfWeek,
} from './time';

/**
 * These tests exist because every one of them is a boundary the server gets
 * wrong on its own. Oman runs four hours ahead of UTC, so the last four hours
 * of every Muscat day are the previous day to a UTC host — which is exactly
 * when people log an evening walk or finish a 9pm class.
 *
 * Dates are written as UTC instants with the Muscat wall-clock time in the
 * comment, because that is the pairing under test.
 */

const iso = (d: Date) => d.toISOString().slice(0, 10);

describe('omanDate', () => {
  test('afternoon UTC is the same Oman day', () => {
    // 12:00 UTC = 16:00 Muscat, 15 March.
    assert.equal(iso(omanDate(new Date('2026-03-15T12:00:00Z'))), '2026-03-15');
  });

  test('19:59 UTC is still the same Oman day', () => {
    // 23:59 Muscat, 15 March — the last minute of the day.
    assert.equal(iso(omanDate(new Date('2026-03-15T19:59:00Z'))), '2026-03-15');
  });

  test('20:00 UTC has already rolled over in Oman', () => {
    // 00:00 Muscat, 16 March. A server comparing in UTC would say the 15th.
    assert.equal(iso(omanDate(new Date('2026-03-15T20:00:00Z'))), '2026-03-16');
  });

  test('midnight UTC is still the previous evening nowhere — Oman is ahead', () => {
    // 04:00 Muscat, 16 March.
    assert.equal(iso(omanDate(new Date('2026-03-16T00:00:00Z'))), '2026-03-16');
  });

  test('returns UTC midnight so it round-trips through a date column', () => {
    const d = omanDate(new Date('2026-03-15T19:30:00Z'));
    assert.equal(d.getUTCHours(), 0);
    assert.equal(d.getUTCMinutes(), 0);
    assert.equal(d.getUTCSeconds(), 0);
    assert.equal(d.getUTCMilliseconds(), 0);
  });

  test('handles a month boundary', () => {
    // 00:30 Muscat, 1 April.
    assert.equal(iso(omanDate(new Date('2026-03-31T20:30:00Z'))), '2026-04-01');
  });

  test('handles a year boundary', () => {
    // 00:30 Muscat, 1 January 2027.
    assert.equal(iso(omanDate(new Date('2026-12-31T20:30:00Z'))), '2027-01-01');
  });
});

describe('daysBetween', () => {
  test('same Oman day is zero even across a UTC date change', () => {
    // Both are 15 March in Muscat: 10:00 and 23:00.
    const a = new Date('2026-03-15T06:00:00Z');
    const b = new Date('2026-03-15T19:00:00Z');
    assert.equal(daysBetween(a, b), 0);
  });

  test('counts the rollover as one day', () => {
    // 23:00 Muscat 15th → 00:30 Muscat 16th, ninety minutes apart.
    const a = new Date('2026-03-15T19:00:00Z');
    const b = new Date('2026-03-15T20:30:00Z');
    assert.equal(daysBetween(a, b), 1);
  });

  test('is negative when the target is earlier', () => {
    assert.equal(
      daysBetween(new Date('2026-03-20T06:00:00Z'), new Date('2026-03-18T06:00:00Z')),
      -2,
    );
  });

  test('spans months', () => {
    assert.equal(
      daysBetween(new Date('2026-03-30T06:00:00Z'), new Date('2026-04-02T06:00:00Z')),
      3,
    );
  });
});

describe('isSameDay', () => {
  test('true across a UTC boundary within one Oman day', () => {
    assert.ok(
      isSameDay(new Date('2026-03-15T06:00:00Z'), new Date('2026-03-15T19:30:00Z')),
    );
  });

  test('false once Muscat has rolled over', () => {
    // The bug this replaced: these are the same UTC date but different Oman days.
    assert.equal(
      isSameDay(new Date('2026-03-15T06:00:00Z'), new Date('2026-03-15T20:30:00Z')),
      false,
    );
  });
});

describe('startOfWeek', () => {
  test('a Saturday is its own week start', () => {
    // 14 March 2026 is a Saturday. 08:00 Muscat.
    assert.equal(iso(startOfWeek(new Date('2026-03-14T04:00:00Z'))), '2026-03-14');
  });

  test('a Sunday belongs to the Saturday before it', () => {
    assert.equal(iso(startOfWeek(new Date('2026-03-15T04:00:00Z'))), '2026-03-14');
  });

  test('a Friday belongs to the Saturday six days earlier', () => {
    // 20 March 2026 is a Friday, the last day of that week.
    assert.equal(iso(startOfWeek(new Date('2026-03-20T04:00:00Z'))), '2026-03-14');
  });

  test('late Friday evening in Muscat starts a new week', () => {
    // 21:00 UTC Friday = 01:00 Saturday in Muscat, so the week has turned.
    assert.equal(iso(startOfWeek(new Date('2026-03-20T21:00:00Z'))), '2026-03-21');
  });

  test('every day of a week resolves to the same Saturday', () => {
    const starts = new Set<string>();
    for (let i = 0; i < 7; i++) {
      starts.add(iso(startOfWeek(addDays(new Date('2026-03-14T04:00:00Z'), i))));
    }
    assert.deepEqual([...starts], ['2026-03-14']);
  });
});

describe('addDays', () => {
  test('adds and subtracts whole days', () => {
    const base = omanDate(new Date('2026-03-15T06:00:00Z'));
    assert.equal(iso(addDays(base, 5)), '2026-03-20');
    assert.equal(iso(addDays(base, -5)), '2026-03-10');
    assert.equal(iso(addDays(base, 0)), '2026-03-15');
  });

  test('crosses a month end', () => {
    const base = omanDate(new Date('2026-03-30T06:00:00Z'));
    assert.equal(iso(addDays(base, 3)), '2026-04-02');
  });
});
