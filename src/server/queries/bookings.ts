import { cache } from 'react';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';

/**
 * Bookings split three ways, matching the tabs exactly. "Past" means it
 * happened, not merely that the clock passed it — a confirmed booking whose
 * time has gone is still shown as past rather than silently disappearing.
 */

export const getBookings = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return { upcoming: [], past: [], cancelled: [] };

  const bookings = await prisma.booking.findMany({
    where: { userId: user.id },
    orderBy: { startsAt: 'desc' },
    include: { provider: true, service: true },
  });

  const now = Date.now();

  return {
    upcoming: bookings
      .filter((b) => b.status === 'CONFIRMED' && b.startsAt.getTime() >= now)
      .sort((a, b) => a.startsAt.getTime() - b.startsAt.getTime()),
    past: bookings.filter(
      (b) => b.status === 'COMPLETED' || (b.status === 'CONFIRMED' && b.startsAt.getTime() < now),
    ),
    cancelled: bookings.filter((b) => b.status === 'CANCELLED'),
  };
});

export type BookingWithDetail = Awaited<
  ReturnType<typeof getBookings>
>['upcoming'][number];

export const getBooking = cache(async (id: string) => {
  const user = await getCurrentUser();
  if (!user) return null;

  return prisma.booking.findFirst({
    where: { id, userId: user.id },
    include: { provider: { include: { city: true } }, service: true },
  });
});

export const getNotifications = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return [];

  return prisma.notification.findMany({
    where: { userId: user.id },
    orderBy: { createdAt: 'desc' },
    take: 40,
  });
});

export const getFavorites = cache(async () => {
  const user = await getCurrentUser();
  if (!user) return [];

  const rows = await prisma.favorite.findMany({
    where: { userId: user.id },
    orderBy: { createdAt: 'desc' },
    include: { provider: { include: { city: true } } },
  });

  return rows.map((r) => r.provider);
});
