import type { FoodTag, MenuProfile } from '@prisma/client';

/**
 * A one-line description of a partner, assembled from what the research
 * actually established.
 *
 * Nothing here is written about a business — it is their own recorded facts
 * read back in a sentence: what they make, where they are, how you get it.
 * The moment a partner supplies their own copy, `aboutAr`/`aboutEn` take over
 * and this stops being used for them.
 *
 * Unverified capabilities are simply absent from the sentence. They are never
 * rendered as a negative: "no delivery" is a claim, and null is not a claim.
 */

type Summarisable = {
  foodTags: FoodTag[];
  menuProfile: MenuProfile | null;
  area: string | null;
  ownDelivery: boolean | null;
  platformDelivery: boolean | null;
  pickup: boolean | null;
  weeklyPlan: boolean | null;
  monthlyPlan: boolean | null;
};

const TAG_AR: Record<FoodTag, string> = {
  MEALS: 'وجبات صحية',
  SUBSCRIPTIONS: 'اشتراكات',
  HIGH_PROTEIN: 'عالي البروتين',
  KETO: 'كيتو',
  LOW_CARB: 'قليل الكربوهيدرات',
  VEGETARIAN: 'نباتي',
  SALADS: 'سلطات',
  JUICES: 'عصائر',
  BAKERY: 'مخبوزات صحية',
  GROCERY: 'منتجات صحية',
};

const TAG_EN: Record<FoodTag, string> = {
  MEALS: 'Healthy meals',
  SUBSCRIPTIONS: 'Meal plans',
  HIGH_PROTEIN: 'High protein',
  KETO: 'Keto',
  LOW_CARB: 'Low carb',
  VEGETARIAN: 'Vegetarian',
  SALADS: 'Salads',
  JUICES: 'Juices',
  BAKERY: 'Healthy bakery',
  GROCERY: 'Healthy products',
};

/** Least generic first, so a two-tag summary says something. */
const TAG_ORDER: FoodTag[] = [
  'KETO',
  'HIGH_PROTEIN',
  'LOW_CARB',
  'SUBSCRIPTIONS',
  'VEGETARIAN',
  'SALADS',
  'JUICES',
  'BAKERY',
  'GROCERY',
  'MEALS',
];

/**
 * The headline: what this place makes, and where.
 * e.g. "كيتو ومخبوزات صحية · الخوير"
 */
export function partnerSummary(p: Summarisable, locale: string): string {
  const ar = locale === 'ar';
  const dict = ar ? TAG_AR : TAG_EN;

  const tags = TAG_ORDER.filter((t) => p.foodTags.includes(t)).slice(0, 2);
  const what = tags.map((t) => dict[t]);

  const subject =
    what.length === 0
      ? ar ? 'شريك أكل صحي' : 'Healthy food partner'
      : what.join(ar ? ' و' : ' · ');

  // A menu with a health section is not the same offer as a dedicated one,
  // and a member choosing where to eat is entitled to know which they are
  // looking at before they arrive.
  const caveat =
    p.menuProfile === 'MIXED' ? (ar ? 'ضمن قائمة متنوعة' : 'within a mixed menu') : null;

  const head = caveat ? `${subject} ${caveat}` : subject;
  return p.area ? `${head} · ${p.area}` : head;
}

/**
 * How you actually get the food. Only what was verified appears — an
 * unconfirmed capability is left out rather than shown as unavailable.
 */
export function partnerFulfilment(p: Summarisable, locale: string): string[] {
  const ar = locale === 'ar';
  const out: string[] = [];

  if (p.ownDelivery === true || p.platformDelivery === true) {
    out.push(ar ? 'توصيل' : 'Delivery');
  }
  if (p.pickup === true) out.push(ar ? 'استلام' : 'Pickup');
  if (p.weeklyPlan === true || p.monthlyPlan === true) {
    out.push(ar ? 'اشتراكات' : 'Subscriptions');
  }

  return out;
}
