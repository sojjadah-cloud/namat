import * as React from 'react';
import { ChevronRight } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { AllowanceMeter, ProgressBar } from '@/components/ui/progress';
import { formatNumber } from '@/lib/format';
import { cn } from '@/lib/utils';

export interface AllowanceUsage {
  category: string;
  label: string;
  used: number;
  total: number;
}

/**
 * The member's command centre summary: what the package gives, what is left,
 * how long the period runs. Deep green because it is the one card on Journey
 * that should feel like a membership, not a listing.
 *
 * Allowances of ten or fewer render as ticks — countable at a glance. Beyond
 * that a bar is honest and a row of ticks is decoration.
 */
export function JourneyCard({
  packageName,
  status,
  daysLeft,
  allowances,
  locale,
  href = '/app/journey/package',
  className,
}: {
  packageName: string;
  status: 'ACTIVE' | 'PAUSED' | 'EXPIRED' | 'CANCELLED';
  daysLeft: number;
  allowances: AllowanceUsage[];
  locale: string;
  href?: string;
  className?: string;
}) {
  const t = useTranslations('Journey.active');
  const tp = useTranslations('Packages');
  const paused = status !== 'ACTIVE';

  return (
    <Link
      href={href}
      className={cn(
        'group block rounded-xl p-5 text-white transition-transform duration-200 active:scale-[0.99]',
        paused ? 'bg-ink' : 'bg-green-deep',
        'shadow-[var(--shadow-md)]',
        className,
      )}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-[12px] font-medium uppercase tracking-[0.14em] text-white/50">
            {t('packageTitle')}
          </p>
          <p className="mt-1.5 truncate text-[20px] font-semibold">{packageName}</p>
        </div>

        {paused ? (
          <Badge tone="light" className="shrink-0">
            {tp(`status.${status}`)}
          </Badge>
        ) : (
          <span className="shrink-0 rounded-full bg-white/12 px-3 py-1 text-[12px] font-medium text-white/85">
            {t('daysLeft', { days: formatNumber(daysLeft, locale) })}
          </span>
        )}
      </div>

      <div className="mt-5 space-y-3.5">
        {allowances.map(({ category, label, used, total }) => (
          <div key={category}>
            <div className="mb-1.5 flex items-baseline justify-between gap-3">
              <span className="truncate text-[13px] text-white/75">{label}</span>
              <span className="shrink-0 text-[13px] font-medium tabular-nums">
                {formatNumber(Math.min(used, total), locale)}
                <span className="text-white/45"> / {formatNumber(total, locale)}</span>
              </span>
            </div>
            {total <= 10 ? (
              <AllowanceMeter used={used} total={total} tone="onDark" />
            ) : (
              <ProgressBar value={used} max={total} tone="onDark" size="sm" />
            )}
          </div>
        ))}
      </div>

      <p className="mt-5 inline-flex items-center gap-1 text-[14px] font-medium text-accent">
        {t('packageCta')}
        <ChevronRight
          className="rtl-flip size-4 transition-transform group-hover:translate-x-0.5"
          aria-hidden
        />
      </p>
    </Link>
  );
}
