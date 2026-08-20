import * as React from 'react';
import Image from 'next/image';
import { Link } from '@/i18n/routing';
import { cn } from '@/lib/utils';

/**
 * Photography-led discovery. No rating, no price, no distance — this card
 * answers "what kind of thing?", nothing else. Everything operational belongs
 * on ProviderCard or ServiceCard.
 */

export function CategoryCard({
  href,
  label,
  description,
  image,
  size = 'md',
  className,
}: {
  href: string;
  label: string;
  description?: string;
  image: string;
  /** `sm` for the Home rail, `md` for the Explore grid, `lg` for the hero tile. */
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={cn(
        'group relative block overflow-hidden rounded-lg',
        'transition-transform duration-300 ease-[cubic-bezier(.22,.61,.36,1)] active:scale-[0.99]',
        size === 'sm' && 'h-36 w-40',
        size === 'md' && 'h-44 w-full',
        size === 'lg' && 'h-60 w-full',
        className,
      )}
    >
      <Image
        src={image}
        alt=""
        fill
        sizes="(max-width: 768px) 50vw, 320px"
        className="object-cover transition-transform duration-500 ease-[cubic-bezier(.22,.61,.36,1)] group-hover:scale-[1.04]"
      />
      {/* Ink scrim, weighted to the bottom so the type stays legible on any photo. */}
      <div className="absolute inset-0 bg-gradient-to-t from-ink/75 via-ink/20 to-transparent" />

      <div className="absolute inset-x-0 bottom-0 p-4">
        <p
          className={cn(
            'font-semibold text-white',
            size === 'sm' ? 'text-[15px]' : 'text-[18px]',
          )}
        >
          {label}
        </p>
        {description && size !== 'sm' ? (
          <p className="mt-1 line-clamp-2 text-[13px] leading-snug text-white/75">
            {description}
          </p>
        ) : null}
      </div>
    </Link>
  );
}
