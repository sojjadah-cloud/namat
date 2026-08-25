import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { partnerMonogram, partnerPalette } from './partner-identity';
import { partnerSummary, partnerFulfilment } from './partner-summary';
import { LISTABLE_PARTNERS } from '../../prisma/data/food-partners';
import type { FoodTag, MenuProfile } from '@prisma/client';

/**
 * The point of the monogram is that thirty-eight businesses stop looking like
 * one business repeated, so the property that matters most is distinctness
 * across the actual catalogue — not any single pretty output.
 */

describe('monograms identify the business', () => {
  test('skips generic words that would collide', () => {
    // "The Healthy Kitchen" must not become "TH", and "مطبخ نخل" must not
    // become "م" — both are words that recur across the catalogue.
    assert.equal(partnerMonogram('The Healthy Kitchen'), 'HK');
    assert.equal(partnerMonogram('مطبخ هيلدا كيتو'), 'ه');
  });

  test('single-word names use two letters', () => {
    assert.equal(partnerMonogram('Sprout'), 'SP');
    assert.equal(partnerMonogram('Greeno'), 'GR');
  });

  test('Arabic takes one letter, not two', () => {
    // Arabic letterforms connect; two isolated letters read as a broken word.
    assert.equal([...partnerMonogram('دكتور دايت')].length, 1);
    assert.equal([...partnerMonogram('أساي')].length, 1);
  });

  test('punctuation and apostrophes do not leak in', () => {
    assert.equal(partnerMonogram("Hilda's Keto Kitchen"), 'HK');
    assert.equal(partnerMonogram('Healthy Lab — The Guilt-Free Food Hub'), 'HL');
  });

  test('never returns empty', () => {
    for (const p of LISTABLE_PARTNERS) {
      const m = partnerMonogram(p.nameAr ?? p.nameEn);
      assert.ok(m.length > 0, p.slug);
    }
  });
});

describe('the catalogue looks varied, which is the whole point', () => {
  test('no monogram is shared by more than three partners', () => {
    const counts = new Map<string, number>();
    for (const p of LISTABLE_PARTNERS) {
      const key = partnerMonogram(p.nameEn);
      counts.set(key, (counts.get(key) ?? 0) + 1);
    }
    const worst = [...counts.entries()].sort((a, b) => b[1] - a[1])[0];
    assert.ok(worst[1] <= 3, `"${worst[0]}" repeats ${worst[1]} times`);
  });

  test('at least four distinct colours across the catalogue', () => {
    const palettes = new Set(
      LISTABLE_PARTNERS.map((p) => partnerPalette(p.tags as FoodTag[]).fg),
    );
    assert.ok(palettes.size >= 4, `only ${palettes.size} colours`);
  });

  test('a keto shop and a juice bar do not share a colour', () => {
    const keto = partnerPalette(['KETO'] as FoodTag[]);
    const juice = partnerPalette(['JUICES'] as FoodTag[]);
    assert.notEqual(keto.fg, juice.fg);
  });
});

describe('summaries restate the data, never invent', () => {
  const base = {
    foodTags: ['KETO', 'BAKERY'] as FoodTag[],
    menuProfile: 'DEDICATED' as MenuProfile,
    area: 'الخوير',
    ownDelivery: null,
    platformDelivery: true,
    pickup: true,
    weeklyPlan: null,
    monthlyPlan: null,
  };

  test('names what it makes and where', () => {
    assert.equal(partnerSummary(base, 'ar'), 'كيتو ومخبوزات صحية · الخوير');
  });

  test('flags a mixed menu, because that changes the offer', () => {
    const mixed = { ...base, menuProfile: 'MIXED' as MenuProfile };
    assert.match(partnerSummary(mixed, 'ar'), /ضمن قائمة متنوعة/);
  });

  test('a dedicated menu carries no caveat', () => {
    assert.doesNotMatch(partnerSummary(base, 'ar'), /ضمن قائمة/);
  });

  test('falls back gracefully with no tags and no area', () => {
    const bare = { ...base, foodTags: [] as FoodTag[], area: null };
    assert.equal(partnerSummary(bare, 'ar'), 'شريك أكل صحي');
  });

  test('English reads as English', () => {
    assert.equal(partnerSummary(base, 'en'), 'Keto · Healthy bakery · الخوير');
  });
});

describe('fulfilment shows only what was verified', () => {
  const p = {
    foodTags: [] as FoodTag[],
    menuProfile: null,
    area: null,
    ownDelivery: null,
    platformDelivery: null,
    pickup: null,
    weeklyPlan: null,
    monthlyPlan: null,
  };

  test('unverified capabilities produce nothing at all', () => {
    // Not "no delivery" — null is not a claim either way.
    assert.deepEqual(partnerFulfilment(p, 'ar'), []);
  });

  test('either delivery route counts as delivery once', () => {
    assert.deepEqual(partnerFulfilment({ ...p, platformDelivery: true }, 'ar'), ['توصيل']);
    assert.deepEqual(partnerFulfilment({ ...p, ownDelivery: true }, 'ar'), ['توصيل']);
    assert.deepEqual(
      partnerFulfilment({ ...p, ownDelivery: true, platformDelivery: true }, 'ar'),
      ['توصيل'],
    );
  });

  test('an explicit false is still not shown as a negative', () => {
    assert.deepEqual(partnerFulfilment({ ...p, weeklyPlan: false }, 'ar'), []);
  });

  test('the real Healthy Lab row reads correctly', () => {
    const lab = LISTABLE_PARTNERS.find((x) => x.slug === 'healthy-lab')!;
    const chips = partnerFulfilment(
      { ...p, ...lab, foodTags: lab.tags as FoodTag[], menuProfile: lab.menuProfile as MenuProfile },
      'ar',
    );
    assert.deepEqual(chips, ['توصيل', 'استلام', 'اشتراكات']);
  });
});
