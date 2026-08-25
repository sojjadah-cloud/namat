import * as React from 'react';
import Image from 'next/image';
import { CalendarDays, Clock, ChevronRight } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { formatTime, formatDateLong, isSameDay, addDays } from '@/lib/format';
import { cn } from '@/lib/utils';

/** Shown when a provider has not supplied a photograph. Visibly generic on
 *  purpose: a stock kitchen presented as a real shopfront is a false claim. */
const FALLBACK_IMAGE =
  'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=70';

export interface BookingCardData {
  id: string;
  providerName: string;
  serviceName: string;
  image: string | null;
  startsAt: Date;
  status: 'CONFIRMED' | 'COMPLETED' | 'CANCELLED';
  coveredByMembership?: boolean;
}

const STATUS_TONE = {
  CONFIRMED: 'soft',
  COMPLETED: 'neutral',
  CANCELLED: 'danger',
} as const;

/**
 * Operational, not promotional. The date and time carry the weight because
 * that is the only reason anyone opens this screen — "where do I need to be".
 *
 * A cancelled booking stays legible but visually retires: no photo emphasis,
 * muted type.
 */
export function BookingCard({
  booking,
  locale,
  variant = 'list',
  className,
}: {
  booking: BookingCardData;
  locale: string;
  /** `next` is the single highlighted booking on Home. */
  variant?: 'list' | 'next';
  className?: string;
}) {
  const t = useTranslations('Bookings');
  const tb = useTranslations('Booking');
  const tc = useTranslations('Common');
  const { id, providerName, serviceName, image, startsAt, status, coveredByMembership } =
    booking;

  const now = new Date();
  const dayLabel = isSameDay(startsAt, now)
    ? tc('today')
    : isSameDay(startsAt, addDays(now, 1))
      ? tc('tomorrow')
      : formatDateLong(startsAt, locale);

  const cancelled = status === 'CANCELLED';

  if (variant === 'next') {
    return (
      <Link
        href={`/app/bookings/${id}`}
        className={cn(
          'group flex items-center gap-4 rounded-lg bg-green p-4 text-white',
          'shadow-[var(--shadow-md)] transition-transform duration-200 active:scale-[0.99]',
          className,
        )}
      >
        <div className="relative size-16 shrink-0 overflow-hidden rounded-sm ring-1 ring-white/15">
          <Image src={image ?? FALLBACK_IMAGE} alt="" fill sizes="64px" className="object-cover" />
        </div>

        <div className="min-w-0 flex-1">
          <p className="truncate text-[15px] font-semibold">{serviceName}</p>
          <p className="mt-0.5 truncate text-[13px] text-white/70">{providerName}</p>
          <p className="mt-2 flex items-center gap-3 text-[13px] font-medium">
            <span className="inline-flex items-center gap-1.5">
              <CalendarDays className="size-4" aria-hidden />
              {dayLabel}
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Clock className="size-4" aria-hidden />
              {formatTime(startsAt, locale)}
            </span>
          </p>
        </div>

        <ChevronRight
          className="rtl-flip size-5 shrink-0 text-white/50 transition-transform group-hover:translate-x-0.5"
          aria-hidden
        />
      </Link>
    );
  }

  return (
    <Link
      href={`/app/bookings/${id}`}
      className={cn(
        'group flex items-center gap-3.5 rounded-lg bg-white p-3.5 shadow-[var(--shadow-sm)]',
        'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'hover:shadow-[var(--shadow-md)] active:scale-[0.99]',
        cancelled && 'opacity-70',
        className,
      )}
    >
      {/* A date block reads faster than a photo when scanning a list of times. */}
      <div
        className={cn(
          'grid size-16 shrink-0 place-content-center rounded-sm text-center',
          cancelled ? 'bg-warm-soft' : 'bg-green-soft',
        )}
      >
        <span className="text-[11px] font-medium uppercase tracking-wide text-ink-soft">
          {new Intl.DateTimeFormat(locale === 'ar' ? 'ar-OM' : 'en-OM', {
            month: 'short',
          }).format(startsAt)}
        </span>
        <span className="text-[20px] font-semibold leading-tight text-ink">
          {new Intl.DateTimeFormat(locale === 'ar' ? 'ar-OM' : 'en-OM', {
            day: 'numeric',
          }).format(startsAt)}
        </span>
      </div>

      <div className="min-w-0 flex-1">
        <div className="flex items-start justify-between gap-2">
          <p
            className={cn(
              'truncate text-[15px] font-semibold text-ink',
              cancelled && 'line-through decoration-ink-soft/40',
            )}
          >
            {serviceName}
          </p>
          <Badge tone={STATUS_TONE[status]} className="shrink-0">
            {t(`status.${status}`)}
          </Badge>
        </div>
        <p className="mt-0.5 truncate text-[13px] text-ink-soft">{providerName}</p>
        <p className="mt-1.5 flex items-center gap-3 text-[12px] text-ink-soft">
          <span>{dayLabel}</span>
          <span className="inline-flex items-center gap-1">
            <Clock className="size-3.5" aria-hidden />
            {formatTime(startsAt, locale)}
          </span>
          {coveredByMembership && !cancelled ? (
            <span className="font-medium text-green">{tb('packageBenefit')}</span>
          ) : null}
        </p>
      </div>
    </Link>
  );
}
