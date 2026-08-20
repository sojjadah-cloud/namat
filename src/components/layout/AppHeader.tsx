'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import { ArrowLeft, Bell, MapPin } from 'lucide-react';
import { Link, useRouter } from '@/i18n/routing';
import { Avatar } from '@/components/ui/avatar';
import { cn } from '@/lib/utils';

/**
 * Two headers, two jobs.
 *
 * `AppHeader` is the personal one on Home: who you are, where you are, what
 * needs your attention. `BackBar` is the utility one on every pushed screen.
 *
 * The back arrow carries `rtl-flip` so it points the way the language reads.
 */

export function AppHeader({
  greeting,
  name,
  city,
  unread = 0,
  avatarSrc,
}: {
  /** Already interpolated, e.g. "Good morning, Sara" — see Home.greeting*. */
  greeting: string;
  name?: string | null;
  city?: string | null;
  unread?: number;
  avatarSrc?: string | null;
}) {
  const t = useTranslations('Home');

  return (
    <header className="flex items-start justify-between gap-4 px-5 pt-3 pb-4">
      <div className="flex min-w-0 items-center gap-3">
        <Avatar name={name} src={avatarSrc} size="md" />
        <div className="min-w-0">
          <p className="truncate text-[19px] font-semibold leading-tight text-ink">
            {greeting}
          </p>
          {city ? (
            <p className="mt-1 flex items-center gap-1 text-[12px] text-ink-soft">
              <MapPin className="size-3.5 shrink-0" aria-hidden />
              <span className="truncate">{city}</span>
            </p>
          ) : null}
        </div>
      </div>

      <Link
        href="/app/notifications"
        aria-label={t('notifications')}
        className="relative grid size-11 shrink-0 place-items-center rounded-full bg-white shadow-[var(--shadow-sm)] transition-transform active:scale-95"
      >
        <Bell className="size-5 text-ink" strokeWidth={1.9} aria-hidden />
        {unread > 0 ? (
          <span className="absolute end-2.5 top-2.5 size-2 rounded-full bg-danger ring-2 ring-white" />
        ) : null}
      </Link>
    </header>
  );
}

/* ------------------------------------------------------------- BackBar ---
   Sticky, translucent once the page scrolls under it. */

export function BackBar({
  title,
  action,
  transparent = false,
  onBack,
  className,
}: {
  title?: React.ReactNode;
  action?: React.ReactNode;
  /** Sits over a hero image — no surface, no border. */
  transparent?: boolean;
  onBack?: () => void;
  className?: string;
}) {
  const t = useTranslations('Common');
  const router = useRouter();

  return (
    <div
      className={cn(
        'sticky top-0 z-40 flex h-14 items-center gap-2 px-4',
        transparent
          ? 'bg-transparent'
          : 'border-b border-line/70 bg-canvas/85 backdrop-blur-xl',
        className,
      )}
    >
      <button
        type="button"
        onClick={onBack ?? (() => router.back())}
        aria-label={t('back')}
        className={cn(
          'grid size-10 shrink-0 place-items-center rounded-full transition-transform active:scale-95',
          transparent
            ? 'bg-white/90 shadow-[var(--shadow-sm)] backdrop-blur-sm'
            : 'hover:bg-black/[0.04]',
        )}
      >
        <ArrowLeft className="rtl-flip size-5 text-ink" strokeWidth={2} aria-hidden />
      </button>

      {title ? (
        <h1 className="min-w-0 flex-1 truncate text-[17px] font-semibold text-ink">
          {title}
        </h1>
      ) : (
        <span className="flex-1" />
      )}

      {action ? <div className="shrink-0">{action}</div> : null}
    </div>
  );
}
