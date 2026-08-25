import { cache } from 'react';
import type { Category, Prisma } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCoveringSlug, getCurrentUser } from '@/server/session';
import { normalizeArabic } from '@/lib/arabic';

/**
 * Discovery queries. Distance is computed in Node rather than PostGIS: the
 * catalogue is a few hundred rows per city, and an equirectangular
 * approximation is accurate to well under a percent at Oman's latitude.
 */

const EARTH_KM = 6371;

export function distanceKm(
  a: { latitude: number | null; longitude: number | null },
  b: { latitude: number | null; longitude: number | null },
): number | null {
  // A researched partner may have no confirmed position yet. Callers rank an
  // unknown distance as mid-range rather than worst — see food-ranking.ts.
  if (a.latitude == null || a.longitude == null) return null;
  if (b.latitude == null || b.longitude == null) return null;

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
    // Matching happens against the `searchKey` generated columns, which hold an
    // Arabic-folded form of the name and address: alef carriers unified,
    // diacritics stripped, digits latinised. Without it a member searching
    // "اطلس" never finds "أطلس", because those are different strings.
    //
    // Raw SQL rather than a Prisma filter because `searchKey` is GENERATED
    // ALWAYS and Prisma has no way to express that — modelling it as an
    // ordinary column would make the next `migrate dev` quietly rewrite it
    // into a plain one and stop it updating.
    const key = normalizeArabic(filters.q);
    if (key) {
      const matches = await prisma.$queryRaw<{ id: string }[]>`
        SELECT DISTINCT p."id"
        FROM "Provider" p
        LEFT JOIN "Service" s
          ON s."providerId" = p."id" AND s."isActive" = true
        WHERE p."searchKey" LIKE ${'%' + key + '%'}
           OR s."searchKey" LIKE ${'%' + key + '%'}
      `;
      where.id = { in: matches.map((m) => m.id) };
    }
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
    // Everything the card needs to describe the partner in its own terms
    // rather than repeating the category name on every row.
    foodTags: p.foodTags,
    menuProfile: p.menuProfile,
    area: p.area,
    ownDelivery: p.ownDelivery,
    platformDelivery: p.platformDelivery,
    pickup: p.pickup,
    weeklyPlan: p.weeklyPlan,
    monthlyPlan: p.monthlyPlan,
    cityNameEn: p.city.nameEn,
    cityNameAr: p.city.nameAr,
    distanceKm: origin ? distanceKm(origin, p) : null,
    fromPrice: p.services.length
      ? Math.min(...p.services.map((s) => s.price))
      : p.fromPrice,
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
