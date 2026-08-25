import type { PrismaClient } from '@prisma/client';
import { FOOD_PARTNERS, type FoodPartner } from './data/food-partners';

/**
 * Seeds the researched Muscat food partners.
 *
 * These are real, named businesses. Three rules follow from that, and they are
 * the reason this file exists instead of a few lines inside seed.ts:
 *
 *   1. Nothing is invented. No ratings, no prices, no photographs, no
 *      descriptions. The research established none of those, and a plausible
 *      4.6 next to a real restaurant is a claim about that restaurant.
 *   2. Unverified is not false. Every operational capability stays null unless
 *      the research settled it, so the delivery and subscription filters never
 *      hide a business on the strength of a gap in our own notes.
 *   3. Nobody is a partner yet. Every row is seeded as PROSPECT — researched,
 *      not signed — and the member-facing queries filter on that.
 */

/** GROCERY-only businesses are shops, not kitchens. */
function categoryFor(partner: FoodPartner): 'FOOD' | 'PRODUCTS' {
  return partner.tags.every((t) => t === 'GROCERY') ? 'PRODUCTS' : 'FOOD';
}

export async function seedFoodPartners(prisma: PrismaClient, cityId: string) {
  for (const p of FOOD_PARTNERS) {
    await prisma.provider.create({
      data: {
        slug: p.slug,
        nameEn: p.nameEn,
        // The schema requires an Arabic name; several businesses trade under a
        // Latin name only, so it falls back rather than being transliterated.
        nameAr: p.nameAr ?? p.nameEn,
        category: categoryFor(p),
        cityId,

        addressEn: p.address ?? p.area,
        addressAr: p.address ?? p.area,
        area: p.area,
        latitude: p.lat,
        longitude: p.lng,
        coordsVerified: p.coordsVerified,

        // Deliberately absent — see rule 1 above.
        aboutEn: null,
        aboutAr: null,
        image: null,
        rating: null,
        reviewCount: 0,
        fromPrice: null,

        phone: p.phone,
        foodTags: p.tags,
        menuProfile: p.menuProfile,
        dataConfidence: p.confidence,
        status: p.status === 'BENCHMARK' ? 'BENCHMARK' : 'PROSPECT',
        grade: p.priority,

        ownDelivery: p.ownDelivery,
        platformDelivery: p.platformDelivery,
        pickup: p.pickup,
        weeklyPlan: p.weeklyPlan,
        monthlyPlan: p.monthlyPlan,
        caloriesLabelled: p.caloriesLabelled,
        proteinLabelled: p.proteinLabelled,
        researchNote: p.notes ?? null,

        // A benchmark must never surface in a member-facing list, and
        // `isActive` is the flag every existing query already respects.
        isActive: p.status !== 'BENCHMARK',
      },
    });
  }

  return FOOD_PARTNERS.length;
}
