import * as React from 'react';
import Image from 'next/image';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { formatPrice } from '@/lib/format';
import { cn } from '@/lib/utils';

/**
 * Healthy products: the one commerce-shaped card in the system. Kept on a
 * warm surface with the photo on a light ground so it never reads as a
 * bookable experience.
 */
export function ProductCard({
  href,
  name,
  brand,
  image,
  price,
  locale,
  tag,
  className,
}: {
  href: string;
  name: string;
  brand?: string;
  image: string;
  price: number;
  locale: string;
  /** "Local", "Organic" — one word, one claim. */
  tag?: string;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={cn(
        'group block w-44 overflow-hidden rounded-lg bg-white shadow-[var(--shadow-sm)]',
        'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'hover:shadow-[var(--shadow-md)] active:scale-[0.99]',
        className,
      )}
    >
      <div className="relative h-40 w-full overflow-hidden bg-warm-soft">
        <Image
          src={image}
          alt=""
          fill
          sizes="176px"
          className="object-contain p-4 transition-transform duration-500 group-hover:scale-[1.05]"
        />
        {tag ? (
          <Badge tone="soft" className="absolute start-2.5 top-2.5">
            {tag}
          </Badge>
        ) : null}
      </div>

      <div className="p-3.5">
        {brand ? (
          <p className="truncate text-[11px] font-medium uppercase tracking-[0.1em] text-ink-soft">
            {brand}
          </p>
        ) : null}
        <p className="mt-1 line-clamp-2 text-[14px] font-medium leading-snug text-ink">
          {name}
        </p>
        <p className="mt-2 text-[15px] font-semibold text-ink">
          {formatPrice(price, locale)}
        </p>
      </div>
    </Link>
  );
}
