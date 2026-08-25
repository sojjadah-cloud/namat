import type { FoodTag, MenuProfile, Confidence } from '../../prisma/data/food-partners';

/**
 * Ordering the food catalogue against what the member is actually trying to do.
 *
 * The premise: showing forty restaurants in whatever order the database
 * returned them is a directory, and a directory is what every food app already
 * is. Someone whose goal is losing weight and someone building muscle should
 * not see the same first three cards.
 *
 * ── What this is not ──────────────────────────────────────────────────────
 * Not nutritional advice, and not a claim that any partner suits any medical
 * condition. It reorders a list. A high-protein kitchen ranks above a juice
 * bar for someone building muscle because that is the obviously more relevant
 * shop, not because anyone has assessed their diet.
 */

export type Goal =
  | 'lose_weight'
  | 'eat_better'
  | 'more_active'
  | 'improve_fitness'
  | 'better_habits'
  | 'wellbeing'
  | 'maintain'
  | 'exploring';

export type RankablePartner = {
  slug: string;
  tags: FoodTag[];
  menuProfile: MenuProfile;
  confidence: Confidence;
  priority: 'A_PLUS' | 'A' | 'B_PLUS' | 'B' | 'C_PLUS' | 'C';
  /** Kilometres from the member. `null` when the partner has no coordinates. */
  distanceKm: number | null;
  rating: number | null;
};

/**
 * How much each tag matters per goal, on a 0–10 scale.
 *
 * Absent means neutral, not penalised: someone losing weight is not shown a
 * bakery *first*, but a bakery that is nearby and excellent still belongs in
 * the list. Only the ordering changes, never the membership.
 */
const GOAL_WEIGHTS: Record<Goal, Partial<Record<FoodTag, number>>> = {
  lose_weight: {
    LOW_CARB: 10,
    MEALS: 8,
    SALADS: 8,
    KETO: 7,
    SUBSCRIPTIONS: 6,
    HIGH_PROTEIN: 5,
    VEGETARIAN: 3,
    JUICES: 1,
    BAKERY: 0,
    GROCERY: 2,
  },
  improve_fitness: {
    HIGH_PROTEIN: 10,
    MEALS: 8,
    SUBSCRIPTIONS: 7,
    LOW_CARB: 4,
    SALADS: 4,
    KETO: 3,
    GROCERY: 3,
    JUICES: 2,
    VEGETARIAN: 2,
    BAKERY: 1,
  },
  more_active: {
    HIGH_PROTEIN: 9,
    MEALS: 8,
    SUBSCRIPTIONS: 6,
    SALADS: 5,
    JUICES: 4,
    LOW_CARB: 3,
    GROCERY: 3,
    KETO: 2,
    VEGETARIAN: 2,
    BAKERY: 1,
  },
  eat_better: {
    MEALS: 9,
    SALADS: 8,
    GROCERY: 7,
    SUBSCRIPTIONS: 6,
    VEGETARIAN: 5,
    HIGH_PROTEIN: 4,
    JUICES: 4,
    LOW_CARB: 3,
    KETO: 2,
    BAKERY: 2,
  },
  maintain: {
    MEALS: 8,
    SUBSCRIPTIONS: 7,
    SALADS: 6,
    HIGH_PROTEIN: 5,
    GROCERY: 5,
    VEGETARIAN: 4,
    LOW_CARB: 4,
    JUICES: 3,
    KETO: 3,
    BAKERY: 2,
  },
  better_habits: {
    SUBSCRIPTIONS: 10,
    MEALS: 8,
    SALADS: 5,
    GROCERY: 5,
    HIGH_PROTEIN: 4,
    LOW_CARB: 3,
    VEGETARIAN: 3,
    KETO: 2,
    JUICES: 2,
    BAKERY: 1,
  },
  wellbeing: {
    MEALS: 7,
    SALADS: 6,
    JUICES: 6,
    GROCERY: 6,
    VEGETARIAN: 5,
    SUBSCRIPTIONS: 4,
    HIGH_PROTEIN: 3,
    BAKERY: 3,
    LOW_CARB: 2,
    KETO: 2,
  },
  // No stated goal: fall back to quality and proximity alone.
  exploring: {},
};

/** A menu that is entirely on-category is worth more than one with a section. */
const MENU_BONUS: Record<MenuProfile, number> = {
  DEDICATED: 6,
  MOSTLY: 3,
  MIXED: 0,
};

/**
 * Unverified operational data ranks lower, because a card that promises
 * delivery and cannot deliver costs more trust than it wins.
 */
const CONFIDENCE_BONUS: Record<Confidence, number> = {
  CONFIRMED: 6,
  LIKELY: 3,
  UNVERIFIED: 0,
};

const PRIORITY_BONUS: Record<RankablePartner['priority'], number> = {
  A_PLUS: 6,
  A: 4,
  B_PLUS: 3,
  B: 2,
  C_PLUS: 1,
  C: 0,
};

/**
 * Proximity, scored on a curve rather than linearly: the difference between
 * 1km and 3km changes where someone will actually go, while the difference
 * between 18km and 20km does not.
 *
 * A partner with no coordinates scores as if it were mid-range. Ranking it
 * last would bury businesses purely for having incomplete research, which is
 * our gap and not theirs.
 */
function proximityScore(distanceKm: number | null): number {
  if (distanceKm === null) return 4;
  if (distanceKm <= 2) return 10;
  if (distanceKm <= 5) return 8;
  if (distanceKm <= 10) return 5;
  if (distanceKm <= 20) return 2;
  return 0;
}

export type ScoreBreakdown = {
  goalFit: number;
  menu: number;
  confidence: number;
  priority: number;
  proximity: number;
  rating: number;
  total: number;
};

/**
 * Score one partner for one member.
 *
 * Goal fit is the largest single term but deliberately not a majority: a
 * perfect-fit kitchen forty kilometres away in Salalah should still lose to a
 * good one two streets over. The breakdown is returned alongside the total so
 * a surprising order can be explained rather than argued about.
 */
export function scorePartner(
  partner: RankablePartner,
  goals: readonly string[],
): ScoreBreakdown {
  const active = goals.filter((g): g is Goal => g in GOAL_WEIGHTS);

  // With several goals, each tag counts at its strongest — someone who wants
  // to lose weight *and* build fitness should see high-protein meals rank on
  // the fitness weighting rather than being averaged into the middle.
  let goalFit = 0;
  if (active.length > 0 && partner.tags.length > 0) {
    const best = partner.tags.map((tag) =>
      Math.max(...active.map((goal) => GOAL_WEIGHTS[goal][tag] ?? 0)),
    );
    // The strongest matching tag carries it, with the rest contributing a
    // little, so a shop that does one relevant thing well is not beaten by one
    // that does five things vaguely.
    const sorted = [...best].sort((a, b) => b - a);
    goalFit = (sorted[0] ?? 0) * 2 + (sorted[1] ?? 0) * 0.5;
  }

  const menu = MENU_BONUS[partner.menuProfile];
  const confidence = CONFIDENCE_BONUS[partner.confidence];
  const priority = PRIORITY_BONUS[partner.priority];
  const proximity = proximityScore(partner.distanceKm);
  // Ratings below 3 are noise at this catalogue size; treat missing as neutral.
  const rating = partner.rating === null ? 0 : Math.max(0, (partner.rating - 3) * 3);

  return {
    goalFit,
    menu,
    confidence,
    priority,
    proximity,
    rating,
    total: goalFit + menu + confidence + priority + proximity + rating,
  };
}

/**
 * Order the catalogue for a member. Stable: partners scoring equally keep
 * their incoming order, so the list does not reshuffle between renders.
 */
export function rankPartners<T extends RankablePartner>(
  partners: readonly T[],
  goals: readonly string[],
): Array<T & { score: ScoreBreakdown }> {
  // The incoming index rides alongside the partner rather than being spread
  // into it: stripping an added key back off with Omit loses the generic T,
  // and callers would stop seeing their own fields on the result.
  return partners
    .map((partner, index) => ({ partner, score: scorePartner(partner, goals), index }))
    .sort((a, b) => b.score.total - a.score.total || a.index - b.index)
    .map(({ partner, score }) => ({ ...partner, score }));
}
