'use client';

import * as React from 'react';
import { Clock, Check } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Badge } from '@/components/ui/chip';
import { formatPrice, formatDuration } from '@/lib/format';
import { cn } from '@/lib/utils';

export interface ServiceCardData {
  id: string;
  name: string;
  description?: string | null;
  /** Null for products and other untimed items. */
  duration?: number | null;
  price: number;
  included?: boolean;
}

/**
 * One bookable thing. The price slot is where membership pays off: when the
 * package covers it, the number is replaced by "Included" rather than struck
 * through — a member should not have to do arithmetic to feel the benefit.
 *
 * Renders as a radio when `onSelect` is passed (the booking flow's step 1),
 * otherwise as a plain row on the provider page.
 */
export function ServiceCard({
  service,
  locale,
  selected,
  onSelect,
  className,
}: {
  service: ServiceCardData;
  locale: string;
  selected?: boolean;
  onSelect?: (id: string) => void;
  className?: string;
}) {
  const t = useTranslations('Provider');
  const { id, name, description, duration, price, included } = service;

  const selectable = typeof onSelect === 'function';

  const body = (
    <>
      <div className="min-w-0 flex-1">
        <p className="text-[15px] font-medium leading-snug text-ink">{name}</p>
        {description ? (
          <p className="mt-1 line-clamp-2 text-[13px] leading-snug text-ink-soft">
            {description}
          </p>
        ) : null}
        {typeof duration === 'number' ? (
          <p className="mt-2 inline-flex items-center gap-1.5 text-[12px] text-ink-soft">
            <Clock className="size-3.5" aria-hidden />
            {formatDuration(duration, locale)}
          </p>
        ) : null}
      </div>

      <div className="flex shrink-0 flex-col items-end gap-1.5">
        {included ? (
          <Badge tone="included" size="md">
            <Check aria-hidden />
            {t('included')}
          </Badge>
        ) : (
          <span className="text-[15px] font-semibold text-ink">
            {formatPrice(price, locale)}
          </span>
        )}
      </div>
    </>
  );

  if (!selectable) {
    return (
      <div
        className={cn(
          'flex items-start gap-4 rounded-md bg-white p-4 shadow-[var(--shadow-sm)]',
          className,
        )}
      >
        {body}
      </div>
    );
  }

  return (
    <button
      type="button"
      role="radio"
      aria-checked={selected ?? false}
      onClick={() => onSelect(id)}
      className={cn(
        'flex w-full items-start gap-4 rounded-md border bg-white p-4 text-start',
        'transition-[border-color,box-shadow,background-color] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'active:scale-[0.99]',
        'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
        selected
          ? 'border-green bg-green-soft/60 shadow-[var(--shadow-sm)]'
          : 'border-line hover:border-sage',
        className,
      )}
    >
      {body}
    </button>
  );
}
