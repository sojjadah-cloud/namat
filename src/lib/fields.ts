import type { Category } from '@prisma/client';
import { Salad, Dumbbell, MessageCircle, ShoppingBag, type LucideIcon } from 'lucide-react';

/**
 * The four worlds of "استخدم نمط".
 *
 * A field is not a Category — it is how a member thinks about their day, and
 * one of them covers three database categories. Someone deciding to train does
 * not distinguish a gym from a pilates studio at the moment of choosing; they
 * decide to move, and narrow down inside.
 *
 * Filters deliberately differ per field. Reusing one filter set everywhere is
 * what makes a wellness app feel like a directory: "عالي البروتين" is
 * meaningless for a gym and "نسائي" is meaningless for a supplement shop.
 */

export type FieldKey = 'meals' | 'fitness' | 'experts' | 'stores';

export type Field = {
  key: FieldKey;
  categories: Category[];
  icon: LucideIcon;
  /** Photograph for the card. */
  image: string;
  /** Token pair for the card's wash and its accent. */
  bg: string;
  fg: string;
  /** Filter chips offered inside this field, keyed into Use.filters.*. */
  filters: string[];
};

const photo = (id: string) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=1200&q=72`;

export const FIELDS: Field[] = [
  {
    key: 'meals',
    categories: ['FOOD'],
    icon: Salad,
    image: photo('1512621776951-a57141f2eefd'),
    bg: 'var(--cat-food-soft)',
    fg: 'var(--cat-food)',
    filters: ['nearest', 'topRated', 'subscriptions', 'delivery', 'pickup', 'highProtein', 'keto', 'vegetarian'],
  },
  {
    key: 'fitness',
    // One decision — "I want to move" — spanning three stored categories.
    categories: ['GYM', 'FITNESS', 'PILATES'],
    icon: Dumbbell,
    image: photo('1534438327276-14e5300c3a48'),
    bg: 'var(--cat-fitness-soft)',
    fg: 'var(--cat-fitness)',
    filters: ['nearest', 'topRated', 'gym', 'pilates', 'classes', 'womenOnly', 'personalTrainer'],
  },
  {
    key: 'experts',
    categories: ['NUTRITION'],
    icon: MessageCircle,
    image: photo('1505576399279-565b52d4ac71'),
    bg: 'var(--cat-nutrition-soft)',
    fg: 'var(--cat-nutrition)',
    filters: ['nearest', 'topRated', 'nutrition', 'lifestyle', 'online', 'inPerson'],
  },
  {
    key: 'stores',
    categories: ['PRODUCTS'],
    icon: ShoppingBag,
    image: photo('1550989460-0adf9ea622e2'),
    bg: 'var(--cat-products-soft)',
    fg: 'var(--cat-products)',
    filters: ['nearest', 'topRated', 'supplements', 'organic', 'natural', 'delivery'],
  },
];

export function fieldByKey(key: string): Field | undefined {
  return FIELDS.find((f) => f.key === key);
}
