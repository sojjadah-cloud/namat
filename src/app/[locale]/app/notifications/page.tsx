import { getTranslations, getLocale } from 'next-intl/server';
import { Bell, CalendarDays, Compass, Route, Sparkles, Tag } from 'lucide-react';
import type { NotificationKind } from '@prisma/client';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { EmptyState } from '@/components/ui/feedback';
import { MarkAllRead } from '@/features/notifications/MarkAllRead';
import { getNotifications } from '@/server/queries/bookings';
import { formatDateShort } from '@/lib/format';
import { pick } from '@/lib/localized';
import { cn } from '@/lib/utils';

const ICONS: Record<NotificationKind, typeof Bell> = {
  BOOKING: CalendarDays,
  JOURNEY: Route,
  PACKAGE: Sparkles,
  RECOMMENDATION: Compass,
  OFFER: Tag,
  SYSTEM: Bell,
};

export default async function NotificationsPage() {
  const locale = await getLocale();
  const t = await getTranslations('Notifications');

  const notifications = await getNotifications();
  const hasUnread = notifications.some((n) => !n.readAt);

  return (
    <div className="pb-6">
      <BackBar
        title={t('title')}
        action={hasUnread ? <MarkAllRead label={t('markAll')} /> : undefined}
      />

      {notifications.length ? (
        <ul className="mt-2 divide-y divide-line px-5">
          {notifications.map((n) => {
            const Icon = ICONS[n.kind];
            const unread = !n.readAt;
            const body = (
              <div className="flex gap-3.5 py-4">
                <span
                  className={cn(
                    'mt-0.5 grid size-9 shrink-0 place-items-center rounded-full',
                    unread ? 'bg-green-soft text-green' : 'bg-warm text-ink-soft',
                  )}
                >
                  <Icon className="size-[18px]" strokeWidth={1.9} aria-hidden />
                </span>

                <div className="min-w-0 flex-1">
                  <p
                    className={cn(
                      'text-[15px] leading-snug',
                      unread ? 'font-semibold text-ink' : 'font-medium text-ink-soft',
                    )}
                  >
                    {pick(n, 'title', locale)}
                  </p>
                  <p className="mt-1 text-[13px] leading-snug text-ink-soft">
                    {pick(n, 'body', locale)}
                  </p>
                  <p className="mt-1.5 text-[12px] text-ink-soft/70">
                    {formatDateShort(n.createdAt, locale)}
                  </p>
                </div>

                {unread ? (
                  <span
                    className="mt-2 size-2 shrink-0 rounded-full bg-green"
                    aria-label={t('title')}
                  />
                ) : null}
              </div>
            );

            return (
              <li key={n.id}>
                {n.href ? (
                  <Link href={n.href} className="block hover:bg-black/[0.02]">
                    {body}
                  </Link>
                ) : (
                  body
                )}
              </li>
            );
          })}
        </ul>
      ) : (
        <div className="px-5 pt-6">
          <EmptyState icon={<Bell aria-hidden />} title={t('empty')} body={t('emptyBody')} />
        </div>
      )}
    </div>
  );
}
