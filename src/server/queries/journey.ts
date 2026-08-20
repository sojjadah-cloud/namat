import { cache } from 'react';
import type { Category } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCurrentUser, getMembership } from '@/server/session';
import { startOfWeek, addDays, daysBetween } from '@/lib/format';

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
  const today = weekBookings.filter(
    (b) => b.startsAt.toDateString() === now.toDateString(),
  );

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
