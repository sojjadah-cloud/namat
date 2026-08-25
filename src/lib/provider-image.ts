import type { Category } from '@prisma/client';
import { CATEGORY_META } from '@/lib/categories';

/**
 * The image to show for a provider that has not supplied one.
 *
 * Researched partners are seeded without a photograph on purpose: a stock
 * picture of someone else's kitchen presented as a real shopfront is a claim
 * about that business. The category illustration is visibly generic, which is
 * the honest signal that we do not have their photo yet.
 */
export function providerImage(image: string | null, category: Category): string {
  return image ?? CATEGORY_META[category].image;
}
