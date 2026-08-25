import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import { rankPartners, scorePartner, type RankablePartner } from './food-ranking';
import { LISTABLE_PARTNERS, FOOD_PARTNERS } from '../../prisma/data/food-partners';

/**
 * The claim being tested is the product one: a member losing weight and a
 * member building muscle must not see the same first card. Everything else
 * here guards the ways that claim could be true on average and wrong in the
 * cases people actually hit.
 */

const partner = (over: Partial<RankablePartner> = {}): RankablePartner => ({
  slug: 'x',
  tags: ['MEALS'],
  menuProfile: 'DEDICATED',
  confidence: 'CONFIRMED',
  priority: 'A',
  distanceKm: 3,
  rating: 4.5,
  ...over,
});

/** The catalogue as the app would rank it, with a plausible distance spread. */
const catalogue = (): RankablePartner[] =>
  LISTABLE_PARTNERS.map((p, i) => ({
    slug: p.slug,
    tags: p.tags,
    menuProfile: p.menuProfile,
    confidence: p.confidence,
    priority: p.priority,
    distanceKm: p.lat === null ? null : 2 + (i % 9),
    rating: 4 + ((i % 10) / 10),
  }));

describe('goals change the order', () => {
  test('weight loss and fitness do not lead with the same partner', () => {
    const losing = rankPartners(catalogue(), ['lose_weight']);
    const building = rankPartners(catalogue(), ['improve_fitness']);
    assert.notEqual(
      losing[0].slug,
      building[0].slug,
      'the whole feature is that these differ',
    );
  });

  test('a high-protein kitchen outranks a juice bar for fitness', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'juice', tags: ['JUICES'] }),
        partner({ slug: 'protein', tags: ['HIGH_PROTEIN', 'MEALS'] }),
      ],
      ['improve_fitness'],
    );
    assert.equal(ranked[0].slug, 'protein');
  });

  test('a low-carb kitchen outranks a bakery for weight loss', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'bakery', tags: ['BAKERY'] }),
        partner({ slug: 'lowcarb', tags: ['LOW_CARB'] }),
      ],
      ['lose_weight'],
    );
    assert.equal(ranked[0].slug, 'lowcarb');
  });

  test('subscriptions lead for someone building habits', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'oneoff', tags: ['SALADS'] }),
        partner({ slug: 'plan', tags: ['SUBSCRIPTIONS'] }),
      ],
      ['better_habits'],
    );
    assert.equal(ranked[0].slug, 'plan');
  });
});

describe('nothing is filtered out, only reordered', () => {
  test('every listable partner survives ranking under every goal', () => {
    const goals = [
      'lose_weight',
      'improve_fitness',
      'eat_better',
      'maintain',
      'better_habits',
      'wellbeing',
      'more_active',
      'exploring',
    ];
    for (const goal of goals) {
      const ranked = rankPartners(catalogue(), [goal]);
      assert.equal(ranked.length, LISTABLE_PARTNERS.length, goal);
    }
  });

  test('a bakery still appears for someone losing weight', () => {
    const ranked = rankPartners(catalogue(), ['lose_weight']);
    assert.ok(ranked.some((p) => p.tags.includes('BAKERY')));
  });
});

describe('proximity is weighed against fit, not ignored', () => {
  test('a perfect fit far away loses to a good fit nearby', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'far', tags: ['LOW_CARB'], distanceKm: 40 }),
        partner({ slug: 'near', tags: ['SALADS'], distanceKm: 1 }),
      ],
      ['lose_weight'],
    );
    assert.equal(ranked[0].slug, 'near');
  });

  test('but fit still beats proximity at comparable distances', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'wrong', tags: ['BAKERY'], distanceKm: 2 }),
        partner({ slug: 'right', tags: ['LOW_CARB'], distanceKm: 4 }),
      ],
      ['lose_weight'],
    );
    assert.equal(ranked[0].slug, 'right');
  });

  test('a partner with no coordinates is not buried', () => {
    // Missing coordinates are a gap in our research, not a fault of theirs.
    const ranked = rankPartners(
      [
        partner({ slug: 'faraway', tags: ['LOW_CARB'], distanceKm: 30 }),
        partner({ slug: 'unknown', tags: ['LOW_CARB'], distanceKm: null }),
      ],
      ['lose_weight'],
    );
    assert.equal(ranked[0].slug, 'unknown');
  });
});

describe('data quality shows up in the order', () => {
  test('confirmed research outranks unverified, all else equal', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'unsure', confidence: 'UNVERIFIED' }),
        partner({ slug: 'sure', confidence: 'CONFIRMED' }),
      ],
      ['eat_better'],
    );
    assert.equal(ranked[0].slug, 'sure');
  });

  test('a dedicated menu outranks a health section in a mixed one', () => {
    const ranked = rankPartners(
      [
        partner({ slug: 'mixed', menuProfile: 'MIXED' }),
        partner({ slug: 'dedicated', menuProfile: 'DEDICATED' }),
      ],
      ['eat_better'],
    );
    assert.equal(ranked[0].slug, 'dedicated');
  });
});

describe('edge cases', () => {
  test('no goals still produces a sensible order', () => {
    const ranked = rankPartners(catalogue(), []);
    assert.equal(ranked.length, LISTABLE_PARTNERS.length);
    // Falls back to quality and proximity, so the top card is still credible.
    assert.ok(ranked[0].score.total > 0);
  });

  test('an unrecognised goal is ignored rather than throwing', () => {
    const ranked = rankPartners(catalogue(), ['train_for_a_marathon']);
    assert.equal(ranked.length, LISTABLE_PARTNERS.length);
  });

  test('a partner with no tags does not crash the scorer', () => {
    const score = scorePartner(partner({ tags: [] }), ['lose_weight']);
    assert.equal(score.goalFit, 0);
    assert.ok(Number.isFinite(score.total));
  });

  test('ranking is stable for equal scores', () => {
    const same = [partner({ slug: 'a' }), partner({ slug: 'b' }), partner({ slug: 'c' })];
    const ranked = rankPartners(same, ['eat_better']);
    assert.deepEqual(ranked.map((p) => p.slug), ['a', 'b', 'c']);
  });

  test('multiple goals take the strongest weighting, not the average', () => {
    // High protein is weak for weight loss and strongest for fitness. Someone
    // pursuing both should see it rank on the fitness weighting.
    const both = scorePartner(
      partner({ tags: ['HIGH_PROTEIN'] }),
      ['lose_weight', 'improve_fitness'],
    );
    const losingOnly = scorePartner(partner({ tags: ['HIGH_PROTEIN'] }), ['lose_weight']);
    assert.ok(both.goalFit > losingOnly.goalFit);
  });
});

describe('the dataset itself', () => {
  test('the benchmark entry is never listable', () => {
    assert.ok(FOOD_PARTNERS.some((p) => p.slug === 'calo'));
    assert.ok(!LISTABLE_PARTNERS.some((p) => p.slug === 'calo'));
  });

  test('slugs are unique — the source research listed Healthy Lab twice', () => {
    const slugs = FOOD_PARTNERS.map((p) => p.slug);
    assert.equal(new Set(slugs).size, slugs.length);
  });

  test('there are 38 listable partners, not the 40 rows of research', () => {
    // 40 rows minus one duplicate (Healthy Lab) minus one benchmark (Calo).
    assert.equal(LISTABLE_PARTNERS.length, 38);
  });

  test('every partner carries at least one tag', () => {
    for (const p of FOOD_PARTNERS) {
      assert.ok(p.tags.length > 0, p.slug);
    }
  });

  test('unverified capabilities are null, never false', () => {
    // A `false` here would mean "confirmed not to deliver". Only businesses
    // the research actually settled should carry one.
    const healthyLab = FOOD_PARTNERS.find((p) => p.slug === 'healthy-lab')!;
    assert.equal(healthyLab.ownDelivery, null);
    assert.equal(healthyLab.platformDelivery, true);
  });

  test('phone numbers are E.164', () => {
    for (const p of FOOD_PARTNERS) {
      if (p.phone !== null) {
        assert.match(p.phone, /^\+968\d{7,8}$/, `${p.slug}: ${p.phone}`);
      }
    }
  });

  test('coordinates are inside Oman when present', () => {
    for (const p of FOOD_PARTNERS) {
      if (p.lat !== null && p.lng !== null) {
        assert.ok(p.lat > 16 && p.lat < 27, `${p.slug} latitude`);
        assert.ok(p.lng > 51 && p.lng < 60, `${p.slug} longitude`);
      }
    }
  });
});
