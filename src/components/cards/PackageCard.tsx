import * as React from 'react';
import { Check, Sparkles } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { formatPrice, formatNumber } from '@/lib/format';
import { cn } from '@/lib/utils';

export interface PackageCardData {
  slug: string;
  name: string;
  /** One-line positioning: "for people building healthy habits". */
  bestFor: string;
  price: number;
  periodDays: number;
  benefits: string[];
  featured?: boolean;
}

/**
 * Membership is sold on structure, not discount — so the benefits list is the
 * card, and the price sits underneath it rather than in a shouty header.
 *
 * `featured` inverts to deep green. Exactly one package per screen may use it.
 */
export function PackageCard({
  pkg,
  locale,
  current,
  className,
}: {
  pkg: PackageCardData;
  locale: string;
  /** The member's active package — replaces the CTA with a status badge. */
  current?: boolean;
  className?: string;
}) {
  const t = useTranslations('Packages');
  const dark = Boolean(pkg.featured) && !current;

  return (
    <Link
      href={`/app/packages/${pkg.slug}`}
      className={cn(
        'group flex flex-col rounded-xl p-6 transition-[transform,box-shadow] duration-200',
        'ease-[cubic-bezier(.22,.61,.36,1)] active:scale-[0.99]',
        dark
          ? 'bg-green-deep text-white shadow-[var(--shadow-md)]'
          : 'bg-white text-ink shadow-[var(--shadow-sm)] hover:shadow-[var(--shadow-md)]',
        current && 'ring-2 ring-green',
        className,
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <h3 className="text-[22px] font-semibold leading-tight">{pkg.name}</h3>
          <p
            className={cn(
              'mt-1 text-[13px] leading-snug',
              dark ? 'text-white/65' : 'text-ink-soft',
            )}
          >
            {pkg.bestFor}
          </p>
        </div>

        {current ? (
          <Badge tone="included" className="shrink-0">
            {t('current')}
          </Badge>
        ) : pkg.featured ? (
          <Badge tone="goal" className="shrink-0">
            <Sparkles aria-hidden />
            {t('recommended')}
          </Badge>
        ) : null}
      </div>

      <ul className="mt-5 flex-1 space-y-2.5">
        {pkg.benefits.slice(0, 5).map((benefit) => (
          <li key={benefit} className="flex items-start gap-2.5 text-[14px] leading-snug">
            <Check
              className={cn(
                'mt-0.5 size-4 shrink-0',
                dark ? 'text-accent' : 'text-green',
              )}
              strokeWidth={2.4}
              aria-hidden
            />
            <span className={dark ? 'text-white/85' : 'text-ink'}>{benefit}</span>
          </li>
        ))}
      </ul>

      <div
        className={cn(
          'mt-6 flex items-end justify-between border-t pt-4',
          dark ? 'border-white/12' : 'border-line',
        )}
      >
        <div>
          <p className="text-[26px] font-semibold leading-none">
            {formatPrice(pkg.price, locale)}
          </p>
          <p
            className={cn(
              'mt-1.5 text-[12px]',
              dark ? 'text-white/55' : 'text-ink-soft',
            )}
          >
            {pkg.periodDays === 30
              ? t('perMonth')
              : t('checkout.billing', { days: formatNumber(pkg.periodDays, locale) })}
          </p>
        </div>

        {!current ? (
          <span
            className={cn(
              'text-[14px] font-medium underline-offset-4 group-hover:underline',
              dark ? 'text-accent' : 'text-green',
            )}
          >
            {t('start')}
          </span>
        ) : null}
      </div>
    </Link>
  );
}
