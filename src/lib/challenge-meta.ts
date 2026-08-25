import type { ChallengeKind } from '@prisma/client';
import {
  Footprints,
  Salad,
  Droplets,
  Moon,
  Brain,
  CalendarCheck,
  Users,
  Flag,
  Flame,
  Trophy,
  Mountain,
  Compass,
  Sparkles,
  type LucideIcon,
} from 'lucide-react';

/**
 * Presentation for challenge kinds, in one place so the chips, cards, detail
 * header and Home widget cannot drift apart.
 *
 * Kinds borrow the ecosystem hues rather than inventing a second colour
 * language — movement reads as fitness, nutrition as food — so a member who
 * has learnt the Explore palette already knows this one.
 */
export const CHALLENGE_KINDS: ChallengeKind[] = [
  'MOVEMENT',
  'NUTRITION',
  'HYDRATION',
  'SLEEP',
  'MIND',
  'CONSISTENCY',
  'COMMUNITY',
];

type KindMeta = { icon: LucideIcon; fg: string; bg: string; hex: string };

export const CHALLENGE_META: Record<ChallengeKind, KindMeta> = {
  MOVEMENT: {
    icon: Footprints,
    fg: 'text-cat-fitness',
    bg: 'bg-cat-fitness-soft',
    hex: 'var(--cat-fitness)',
  },
  NUTRITION: {
    icon: Salad,
    fg: 'text-cat-food',
    bg: 'bg-cat-food-soft',
    hex: 'var(--cat-food)',
  },
  HYDRATION: {
    icon: Droplets,
    fg: 'text-cat-nutrition',
    bg: 'bg-cat-nutrition-soft',
    hex: 'var(--cat-nutrition)',
  },
  SLEEP: {
    icon: Moon,
    fg: 'text-cat-gym',
    bg: 'bg-cat-gym-soft',
    hex: 'var(--cat-gym)',
  },
  MIND: {
    icon: Brain,
    fg: 'text-cat-pilates',
    bg: 'bg-cat-pilates-soft',
    hex: 'var(--cat-pilates)',
  },
  CONSISTENCY: {
    icon: CalendarCheck,
    fg: 'text-cat-wellness',
    bg: 'bg-cat-wellness-soft',
    hex: 'var(--cat-wellness)',
  },
  COMMUNITY: {
    icon: Users,
    fg: 'text-cat-products',
    bg: 'bg-cat-products-soft',
    hex: 'var(--cat-products)',
  },
};

/** Achievement icons are stored as names in the database; this resolves them. */
const ACHIEVEMENT_ICONS: Record<string, LucideIcon> = {
  Flag,
  Flame,
  Trophy,
  Mountain,
  Compass,
  Sparkles,
};

export function achievementIcon(name: string): LucideIcon {
  return ACHIEVEMENT_ICONS[name] ?? Sparkles;
}
