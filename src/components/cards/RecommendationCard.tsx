import * as React from 'react';
import Image from 'next/image';
import { ChevronRight } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { cn } from '@/lib/utils';

/** Shown when a provider has not supplied a photograph. Visibly generic on
 *  purpose: a stock kitchen presented as a real shopfront is a false claim. */
const FALLBACK_IMAGE =
  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=70';

/**
 * Every recommendation states its reason. Personalization the user cannot
 * trace is indistinguishable from advertising — the "because you…" line is
 * the card's whole reason to exist, so it is required, not optional.
 */
export function RecommendationCard({
  href,
  title,
  subtitle,
  reason,
  image,
  className,
}: {
  href: string;
  title: string;
  subtitle?: string;
  /** "Because you want to eat better" — already interpolated. */
  reason: string;
  image: string | null;
  className?: string;
}) {
  return (
    <Link
      href={href}
      className={cn(
        'group flex gap-4 rounded-lg bg-white p-3.5 shadow-[var(--shadow-sm)]',
        'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'hover:shadow-[var(--shadow-md)] active:scale-[0.99]',
        className,
      )}
    >
      <div className="relative size-20 shrink-0 overflow-hidden rounded-sm">
        <Image
          src={image ?? FALLBACK_IMAGE}
          alt=""
          fill
          sizes="80px"
          className="object-cover transition-transform duration-500 group-hover:scale-[1.04]"
        />
      </div>

      <div className="min-w-0 flex-1 py-0.5">
        <Badge tone="goal">{reason}</Badge>
        <p className="mt-2 truncate text-[15px] font-semibold text-ink">{title}</p>
        {subtitle ? (
          <p className="mt-0.5 line-clamp-1 text-[13px] text-ink-soft">{subtitle}</p>
        ) : null}
      </div>

      <ChevronRight
        className="rtl-flip mt-7 size-5 shrink-0 self-start text-ink-soft/50 transition-transform group-hover:translate-x-0.5"
        aria-hidden
      />
    </Link>
  );
}
