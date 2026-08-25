import type { FoodTag } from '@prisma/client';

/**
 * A visual identity for a partner that has not given us their logo.
 *
 * The alternative already tried — one category photograph on every card —
 * makes a list of thirty-eight businesses look like one business repeated,
 * which is worse than no image at all. Using their real logos is not something
 * we can do off our own bat either: a trademark belongs to its owner and using
 * it to represent them in a product is their decision, not ours.
 *
 * So: a monogram. Distinct per business, obviously a placeholder rather than a
 * forged mark, and coloured by what the business actually does so the list is
 * scannable before it is readable — keto shops read one colour, juice bars
 * another. Replace it the moment a partner supplies their own artwork.
 */

/** Tag → the palette slot it borrows. Ordered by how defining the tag is. */
const TAG_PRIORITY: FoodTag[] = [
  'SUBSCRIPTIONS',
  'HIGH_PROTEIN',
  'KETO',
  'LOW_CARB',
  'SALADS',
  'JUICES',
  'BAKERY',
  'GROCERY',
  'VEGETARIAN',
  'MEALS',
];

type Palette = { bg: string; fg: string };

/**
 * Drawn from the ecosystem hues so the food section stays inside the same
 * colour language as the rest of the app rather than inventing a second one.
 */
const TAG_PALETTE: Record<FoodTag, Palette> = {
  MEALS: { bg: 'var(--namat-green-soft)', fg: 'var(--namat-green-accent)' },
  SUBSCRIPTIONS: { bg: 'var(--namat-accent-soft)', fg: 'var(--namat-accent)' },
  HIGH_PROTEIN: { bg: 'var(--cat-fitness-soft)', fg: 'var(--cat-fitness)' },
  KETO: { bg: 'var(--cat-gym-soft)', fg: 'var(--cat-gym)' },
  LOW_CARB: { bg: 'var(--cat-nutrition-soft)', fg: 'var(--cat-nutrition)' },
  VEGETARIAN: { bg: 'var(--cat-pilates-soft)', fg: 'var(--cat-pilates)' },
  SALADS: { bg: 'var(--cat-wellness-soft)', fg: 'var(--cat-wellness)' },
  JUICES: { bg: 'var(--cat-products-soft)', fg: 'var(--cat-products)' },
  BAKERY: { bg: 'var(--cat-food-soft)', fg: 'var(--cat-food)' },
  GROCERY: { bg: 'var(--namat-warm)', fg: 'var(--namat-ink-soft)' },
};

const DEFAULT_PALETTE: Palette = {
  bg: 'var(--namat-warm-soft)',
  fg: 'var(--namat-ink-soft)',
};

export function partnerPalette(tags: readonly FoodTag[]): Palette {
  const defining = TAG_PRIORITY.find((t) => tags.includes(t));
  return defining ? TAG_PALETTE[defining] : DEFAULT_PALETTE;
}

/** Grammatical filler. Always dropped — it never identifies anything. */
const ARTICLES = new Set([
  'the', 'and', 'of', 'for', 'a', 'an', 'by', 'at', 'in', 'ال',
]);

/**
 * Words describing the kind of business. Dropped only when something
 * distinctive survives: stripping "Kitchen" from "The Healthy Kitchen" leaves
 * "Healthy", which is the single most repeated word in the Muscat catalogue —
 * the filter would be manufacturing the collisions it exists to prevent.
 */
const BUSINESS_TYPES = new Set([
  'restaurant', 'kitchen', 'cafe', 'shop', 'store', 'co', 'foods', 'food',
  'مطعم', 'مطبخ', 'مقهى', 'محل', 'شركة', 'مخزن',
]);

export function partnerMonogram(name: string): string {
  const cleaned = name
    // Apostrophes are removed rather than replaced with a space: turning
    // "Hilda's" into "Hilda s" makes the possessive "s" the second word, and
    // the monogram comes out HS instead of HK.
    .replace(/['’ʼ]/g, '')
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .trim();
  // A stray single Latin letter never identifies a business.
  const all = cleaned
    .split(/\s+/)
    .filter((w) => w.length > 0 && !/^[a-z]$/i.test(w));

  const withoutArticles = all.filter((w) => !ARTICLES.has(w.toLowerCase()));
  const withoutTypes = withoutArticles.filter(
    (w) => !BUSINESS_TYPES.has(w.toLowerCase()),
  );

  // Only drop the business-type words if two identifying words remain.
  const source =
    withoutTypes.length >= 2
      ? withoutTypes
      : withoutArticles.length > 0
        ? withoutArticles
        : all;

  if (source.length === 0) return '؟';

  const isArabic = /\p{Script=Arabic}/u.test(source[0]);
  if (isArabic) {
    const word = source[0];
    // Skip a leading "ال": otherwise every definite name monograms to alef.
    const stem = /^ال\p{Script=Arabic}{2,}/u.test(word) ? word.slice(2) : word;
    return [...stem][0];
  }

  if (source.length === 1) return [...source[0]].slice(0, 2).join('').toUpperCase();
  return ([...source[0]][0] + [...source[1]][0]).toUpperCase();
}
