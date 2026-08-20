import { cache } from 'react';
import type { Category, Prisma } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCoveringSlug, getCurrentUser } from '@/server/session';

/**
 * Discovery queries. Distance is computed in Node rather than PostGIS: the
 * catalogue is a few hundred rows per city, and an equirectangular
 * approximation is accurate to well under a percent at Oman's latitude.
 */

const EARTH_KM = 6371;

export function distanceKm(
  a: { latitude: number; longitude: number },
  b: { latitude: number; longitude: number },
) {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const x = toRad(b.longitude - a.longitude) * Math.cos(toRad((a.latitude + b.latitude) / 2));
  const y = toRad(b.latitude - a.latitude);
  return Math.round(Math.sqrt(x * x + y * y) * EARTH_KM * 10) / 10;
}

export type ExploreFilters = {
  q?: string;
  category?: Category | 'all';
  citySlug?: string;
  maxPrice?: number;
  minRating?: number;
  womenOnly?: boolean;
  /** Only what the member's package already covers. */
  includedOnly?: boolean;
  sort?: 'recommended' | 'rating' | 'distance';
};

export async function searchProviders(filters: ExploreFilters = {}) {
  const [user, coveringSlug] = await Promise.all([getCurrentUser(), getCoveringSlug()]);

  const where: Prisma.ProviderWhereInput = { isActive: true };

  if (filters.category && filters.category !== 'all') where.category = filters.category;
  if (filters.citySlug) where.city = { slug: filters.citySlug };
  if (filters.womenOnly) where.womenOnly = true;
  if (filters.minRating) where.rating = { gte: filters.minRating };

  if (filters.q) {
    const q = filters.q.trim();
    where.OR = [
      { nameEn: { contains: q, mode: 'insensitive' } },
      { nameAr: { contains: q } },
      { addressEn: { contains: q, mode: 'insensitive' } },
      { addressAr: { contains: q } },
      { services: { some: { nameEn: { contains: q, mode: 'insensitive' } } } },
      { services: { some: { nameAr: { contains: q } } } },
    ];
  }

  // Price and inclusion are properties of the services, not the provider.
  const serviceFilter: Prisma.ServiceWhereInput = { isActive: true };
  if (filters.maxPrice != null) serviceFilter.price = { lte: filters.maxPrice };
  if (filters.includedOnly && coveringSlug) serviceFilter.includedIn = { has: coveringSlug };
  if (filters.maxPrice != null || (filters.includedOnly && coveringSlug)) {
    where.services = { some: serviceFilter };
  }

  const providers = await prisma.provider.findMany({
    where,
    include: {
      city: true,
      services: { where: { isActive: true }, select: { price: true, includedIn: true } },
    },
    orderBy: filters.sort === 'rating' ? { rating: 'desc' } : { reviewCount: 'desc' },
    take: 60,
  });

  const origin = user?.profile?.city ?? null;

  const rows = providers.map((p) => ({
    slug: p.slug,
    nameEn: p.nameEn,
    nameAr: p.nameAr,
    category: p.category,
    image: p.image,
    rating: p.rating,
    reviewCount: p.reviewCount,
    tagsEn: p.tagsEn,
    tagsAr: p.tagsAr,
    womenOnly: p.womenOnly,
    cityNameEn: p.city.nameEn,
    cityNameAr: p.city.nameAr,
    distanceKm: origin ? distanceKm(origin, p) : null,
    fromPrice: p.services.length ? Math.min(...p.services.map((s) => s.price)) : null,
    included: Boolean(
      coveringSlug && p.services.some((s) => s.includedIn.includes(coveringSlug)),
    ),
  }));

  if (filters.sort === 'distance' && origin) {
    rows.sort((a, b) => (a.distanceKm ?? Infinity) - (b.distanceKm ?? Infinity));
  }

  return rows;
}

export type ProviderListItem = Awaited<ReturnType<typeof searchProviders>>[number];

/** Provider detail, with services marked against the member's package. */
export const getProvider = cache(async (slug: string) => {
  const coveringSlug = await getCoveringSlug();

  const provider = await prisma.provider.findUnique({
    where: { slug },
    include: {
      city: true,
      services: { where: { isActive: true }, orderBy: { price: 'asc' } },
      reviews: {
        orderBy: { createdAt: 'desc' },
        take: 5,
        include: { user: { select: { name: true, image: true } } },
      },
    },
  });

  if (!provider || !provider.isActive) return null;

  return {
    ...provider,
    services: provider.services.map((s) => ({
      ...s,
      included: Boolean(coveringSlug && s.includedIn.includes(coveringSlug)),
    })),
  };
});

/** The next two weeks of open slots for one service, grouped by day. */
export async function getAvailability(serviceId: string) {
  const slots = await prisma.slot.findMany({
    where: { serviceId, startsAt: { gte: new Date() } },
    orderBy: { startsAt: 'asc' },
  });

  const byDay = new Map<string, { startsAt: Date; id: string; full: boolean }[]>();
  for (const slot of slots) {
    const key = slot.startsAt.toISOString().slice(0, 10);
    if (!byDay.has(key)) byDay.set(key, []);
    byDay.get(key)!.push({
      id: slot.id,
      startsAt: slot.startsAt,
      full: slot.booked >= slot.capacity,
    });
  }

  return [...byDay.entries()].map(([date, times]) => ({ date, times }));
}

export const getCities = cache(async () =>
  prisma.city.findMany({
    where: { country: { isLive: true } },
    orderBy: { nameEn: 'asc' },
  }),
);
