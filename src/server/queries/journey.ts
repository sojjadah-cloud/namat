import { cache } from 'react';
import type { Category } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCurrentUser, getMembership } from '@/server/session';
import { startOfWeek, addDays, daysBetween, isSameDay } from '@/lib/format';

/**
 * My Journey has two entirely different jobs depending on membership, so it has
 * two queries rather than one query with holes in it.
 *
 * Non-member: what we know about you, and the two honest ways forward.
 * Member: this week, what the package still covers, what happens next.
 */

export const getJourneyOverview = cache(async () => {
  const [user, membership] = await Promise.all([getCurrentUser(), getMembership()]);
  if (!user) return null;

  const weekStart = startOfWeek(new Date());
  const weekEnd = addDays(weekStart, 7);

  const [weekBookings, upcoming] = await Promise.all([
    prisma.booking.findMany({
      where: {
        userId: user.id,
        startsAt: { gte: weekStart, lt: weekEnd },
        status: { in: ['CONFIRMED', 'COMPLETED'] },
      },
      orderBy: { startsAt: 'asc' },
      include: { provider: true, service: true },
    }),
    prisma.booking.findMany({
      where: { userId: user.id, status: 'CONFIRMED', startsAt: { gte: new Date() } },
      orderBy: { startsAt: 'asc' },
      take: 5,
      include: { provider: true, service: true },
    }),
  ]);

  const now = new Date();
  // `toDateString()` compares in the server's timezone, which on a UTC host
  // rolls over four hours early — a 9pm session in Muscat stopped counting as
  // "today" while the member was still in it.
  const today = weekBookings.filter((b) => isSameDay(b.startsAt, now));

  const completed = weekBookings.filter(
    (b) => b.status === 'COMPLETED' || b.startsAt.getTime() < now.getTime(),
  ).length;

  if (!membership) {
    return {
      member: false as const,
      profile: user.profile,
      weekBookings,
      today,
      upcoming,
      completed,
    };
  }

  // Usage rows are created with the membership, but a category added to the
  // package later would have none — default to zero rather than dropping it.
  const usedByCategory = new Map<Category, number>(
    membership.usage.map((u) => [u.category, u.used]),
  );

  const allowances = membership.package.allowances
    .slice()
    .sort((a, b) => b.quantity - a.quantity)
    .map((a) => ({
      category: a.category,
      total: a.quantity,
      used: usedByCategory.get(a.category) ?? 0,
    }));

  return {
    member: true as const,
    profile: user.profile,
    membership,
    allowances,
    benefitsUsed: allowances.reduce((sum, a) => sum + a.used, 0),
    /**
     * How much of this period's package has been used, 0–100.
     *
     * Weighted by allowance size rather than averaging the per-category
     * percentages: a package of twenty meals and two consultations is mostly
     * meals, and a member who has eaten fifteen of them is well through their
     * month even if they have not called the dietitian yet. Averaging the two
     * ratios would report that as 37%.
     */
    percent: (() => {
      const total = allowances.reduce((sum, a) => sum + a.total, 0);
      if (total === 0) return 0;
      const used = allowances.reduce((sum, a) => sum + Math.min(a.used, a.total), 0);
      return Math.round((used / total) * 100);
    })(),
    daysLeft: Math.max(0, daysBetween(new Date(), membership.endsAt)),
    weekBookings,
    today,
    upcoming,
    completed,
  };
});

export const getPackages = cache(async () =>
  prisma.package.findMany({
    orderBy: { sortOrder: 'asc' },
    include: { allowances: true },
  }),
);

export const getPackage = cache(async (slug: string) =>
  prisma.package.findUnique({ where: { slug }, include: { allowances: true } }),
);
