import Image from 'next/image';
import type { FoodTag } from '@prisma/client';
import { partnerMonogram, partnerPalette } from '@/lib/partner-identity';
import { cn } from '@/lib/utils';

/**
 * A partner's picture, or a stand-in that is honestly a stand-in.
 *
 * When a partner has supplied artwork it is shown. When they have not, this
 * renders their monogram on a colour drawn from what they sell — never a stock
 * photograph of someone else's kitchen, and never a scraped logo. The previous
 * approach put one category photo on all thirty-eight cards, which made the
 * catalogue look like a single business listed thirty-eight times.
 */
export function PartnerThumb({
  image,
  name,
  tags,
  className,
  sizes = '96px',
  rounded = 'rounded-md',
}: {
  image: string | null;
  name: string;
  tags: readonly FoodTag[];
  className?: string;
  sizes?: string;
  rounded?: string;
}) {
  if (image) {
    return (
      <div className={cn('relative overflow-hidden', rounded, className)}>
        <Image src={image} alt="" fill sizes={sizes} className="object-cover" />
      </div>
    );
  }

  const { bg, fg } = partnerPalette(tags);
  const monogram = partnerMonogram(name);

  return (
    <div
      className={cn('grid place-items-center overflow-hidden', rounded, className)}
      style={{ backgroundColor: bg }}
      aria-hidden
    >
      <span
        className="text-[22px] leading-none font-semibold tracking-tight"
        style={{ color: fg }}
      >
        {monogram}
      </span>
    </div>
  );
}
