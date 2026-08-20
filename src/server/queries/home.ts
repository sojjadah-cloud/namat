import { cache } from 'react';
import type { Category } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCoveringSlug, getCurrentUser } from '@/server/session';
import { distanceKm } from './explore';

/**
 * The personalized feed.
 *
 * Ranking is deliberately explainable — interests, then goals, then proximity,
 * then rating — because every recommendation on Home has to be able to say
 * "because you…" out loud. A model we cannot narrate would break that promise.
 */

/** Goals collected in onboarding, mapped onto the categories that serve them. */
const GOAL_CATEGORIES: Record<string, Category[]> = {
  lose_weight: ['NUTRITION', 'FOOD', 'GYM'],
  eat_better: ['FOOD', 'NUTRITION', 'PRODUCTS'],
  more_active: ['GYM', 'FITNESS', 'PILATES'],
  improve_fitness: ['GYM', 'FITNESS'],
  better_habits: ['FOOD', 'GYM', 'WELLNESS'],
  wellbeing: ['WELLNESS', 'PILATES'],
  maintain: ['FOOD', 'FITNESS', 'WELLNESS'],
  exploring: [],
};

export function categoriesForGoals(goals: string[]): Category[] {
  const set = new Set<Category>();
  for (const goal of goals) for (const c of GOAL_CATEGORIES[goal] ?? []) set.add(c);
  return [...set];
}

export const getHomeFeed = cache(async () => {
  const [user, coveringSlug] = await Promise.all([getCurrentUser(), getCoveringSlug()]);
  const profile = user?.profile ?? null;
  const origin = profile?.city ?? null;

  const interests = profile?.interests ?? [];
  const goalCategories = categoriesForGoals(profile?.goals ?? []);
  const relevant = new Set<Category>([...interests, ...goalCategories]);

  const providers = await prisma.provider.findMany({
    where: { isActive: true, ...(origin ? { cityId: origin.id } : {}) },
    include: {
      city: true,
      services: { where: { isActive: true }, select: { price: true, includedIn: true } },
    },
    take: 40,
  });

  const scored = providers.map((p) => {
    const distance = origin ? distanceKm(origin, p) : null;
    // Weights are tuned so an interest match always outranks a rating edge:
    // the feed should feel chosen, not merely popular.
    const score =
      (interests.includes(p.category) ? 40 : 0) +
      (goalCategories.includes(p.category) ? 25 : 0) +
      (profile?.womenOnly && p.womenOnly ? 15 : 0) +
      p.rating * 4 +
      (distance == null ? 0 : Math.max(0, 12 - distance));

    return {
      slug: p.slug,
      nameEn: p.nameEn,
      nameAr: p.nameAr,
      category: p.category,
      image: p.image,
      rating: p.rating,
      reviewCount: p.reviewCount,
      tagsEn: p.tagsEn,
      tagsAr: p.tagsAr,
      cityNameEn: p.city.nameEn,
      cityNameAr: p.city.nameAr,
      distanceKm: distance,
      fromPrice: p.services.length ? Math.min(...p.services.map((s) => s.price)) : null,
      included: Boolean(
        coveringSlug && p.services.some((s) => s.includedIn.includes(coveringSlug)),
      ),
      score,
    };
  });

  const recommended = [...scored].sort((a, b) => b.score - a.score).slice(0, 4);

  const nearYou = origin
    ? [...scored]
        .filter((p) => p.distanceKm != null)
        .sort((a, b) => a.distanceKm! - b.distanceKm!)
        .slice(0, 6)
    : [];

  // Deliberate counterweight to the ranking above: one good thing from a
  // category the user has shown no interest in, so the feed does not close in.
  const tryNew = [...scored]
    .filter((p) => !relevant.has(p.category))
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 4);

  return { recommended, nearYou, tryNew, primaryGoal: profile?.goals?.[0] ?? null };
});

/** The next confirmed booking — the one thing Home promotes above discovery. */
export const getNextBooking = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return null;

  return prisma.booking.findFirst({
    where: { userId: user.id, status: 'CONFIRMED', startsAt: { gte: new Date() } },
    orderBy: { startsAt: 'asc' },
    include: { provider: true, service: true },
  });
});

export const getUnreadCount = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return 0;
  return prisma.notification.count({ where: { userId: user.id, readAt: null } });
});
