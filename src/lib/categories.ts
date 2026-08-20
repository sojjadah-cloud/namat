import type { Category } from '@prisma/client';
import {
  Salad,
  Stethoscope,
  Dumbbell,
  Footprints,
  Sparkles,
  Leaf,
  ShoppingBasket,
} from 'lucide-react';

/**
 * Category presentation lives in one place so Home, Explore, Journey and the
 * marketing ecosystem section can never drift apart on wording, imagery or
 * colour. Labels come from the `Categories` message namespace, keyed by enum.
 *
 * Each category owns an earthy hue. Seven shades of the brand green would read
 * as one undifferentiated list; these give the ecosystem seven recognisable
 * identities while staying inside the palette's temperature. The hue is only
 * ever a tint or an icon colour — actions stay green everywhere.
 */

const photo = (id: string) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=800&q=70`;

export const CATEGORY_ORDER: Category[] = [
  'FOOD',
  'NUTRITION',
  'GYM',
  'FITNESS',
  'PILATES',
  'WELLNESS',
  'PRODUCTS',
];

export type CategoryMeta = {
  image: string;
  icon: typeof Salad;
  /** Tailwind text colour token for the icon. */
  fg: string;
  /** Tailwind background token for the tint behind it. */
  bg: string;
  /** Raw value, for inline SVG fills and gradients. */
  hex: string;
};

export const CATEGORY_META: Record<Category, CategoryMeta> = {
  FOOD: {
    image: photo('1512621776951-a57141f2eefd'),
    icon: Salad,
    fg: 'text-cat-food',
    bg: 'bg-cat-food-soft',
    hex: 'var(--cat-food)',
  },
  NUTRITION: {
    image: photo('1505576399279-565b52d4ac71'),
    icon: Stethoscope,
    fg: 'text-cat-nutrition',
    bg: 'bg-cat-nutrition-soft',
    hex: 'var(--cat-nutrition)',
  },
  GYM: {
    image: photo('1534438327276-14e5300c3a48'),
    icon: Dumbbell,
    fg: 'text-cat-gym',
    bg: 'bg-cat-gym-soft',
    hex: 'var(--cat-gym)',
  },
  FITNESS: {
    image: photo('1552674605-db6ffd4facb5'),
    icon: Footprints,
    fg: 'text-cat-fitness',
    bg: 'bg-cat-fitness-soft',
    hex: 'var(--cat-fitness)',
  },
  PILATES: {
    image: photo('1518611012118-696072aa579a'),
    icon: Sparkles,
    fg: 'text-cat-pilates',
    bg: 'bg-cat-pilates-soft',
    hex: 'var(--cat-pilates)',
  },
  WELLNESS: {
    image: photo('1540555700478-4be289fbecef'),
    icon: Leaf,
    fg: 'text-cat-wellness',
    bg: 'bg-cat-wellness-soft',
    hex: 'var(--cat-wellness)',
  },
  PRODUCTS: {
    image: photo('1550989460-0adf9ea622e2'),
    icon: ShoppingBasket,
    fg: 'text-cat-products',
    bg: 'bg-cat-products-soft',
    hex: 'var(--cat-products)',
  },
};

/**
 * The three brand pillars from the identity board. They group the seven
 * categories into something a newcomer can hold in their head.
 */
export const PILLARS = [
  { key: 'nourish', icon: Leaf, categories: ['FOOD', 'NUTRITION', 'PRODUCTS'] },
  { key: 'move', icon: Dumbbell, categories: ['GYM', 'FITNESS', 'PILATES'] },
  { key: 'thrive', icon: Sparkles, categories: ['WELLNESS'] },
] as const satisfies ReadonlyArray<{
  key: string;
  icon: typeof Leaf;
  categories: readonly Category[];
}>;
