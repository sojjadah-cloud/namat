import { getTranslations, getLocale } from 'next-intl/server';
import { CalendarDays } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { BookingCard } from '@/components/cards/BookingCard';
import { BookingTabs } from '@/features/bookings/BookingTabs';
import { EmptyState } from '@/components/ui/feedback';
import { Button } from '@/components/ui/button';
import { getBookings, type BookingWithDetail } from '@/server/queries/bookings';
import { pick } from '@/lib/localized';

export default async function BookingsPage() {
  const locale = await getLocale();
  const t = await getTranslations('Bookings');

  const { upcoming, past, cancelled } = await getBookings();

  const list = (rows: BookingWithDetail[]) =>
    rows.map((b) => (
      <BookingCard
        key={b.id}
        locale={locale}
        booking={{
          id: b.id,
          providerName: pick(b.provider, 'name', locale),
          serviceName: pick(b.service, 'name', locale),
          image: b.provider.image,
          startsAt: b.startsAt,
          // A confirmed booking whose time has passed reads as completed here.
          status: b.status === 'CONFIRMED' && b.startsAt < new Date() ? 'COMPLETED' : b.status,
          coveredByMembership: b.coveredByMembership,
        }}
      />
    ));

  const explore = (
    <Button asChild size="md">
      <Link href="/app/explore">{t('explore')}</Link>
    </Button>
  );

  return (
    <div className="pb-6">
      <header className="px-5 pt-5 pb-4">
        <h1 className="display text-[28px] text-ink">{t('title')}</h1>
      </header>

      <BookingTabs
        counts={{
          upcoming: upcoming.length,
          past: past.length,
          cancelled: cancelled.length,
        }}
        upcoming={
          upcoming.length ? (
            list(upcoming)
          ) : (
            <EmptyState
              icon={<CalendarDays aria-hidden />}
              title={t('emptyUpcoming')}
              body={t('emptyUpcomingBody')}
              action={explore}
            />
          )
        }
        past={
          past.length ? (
            list(past)
          ) : (
            <EmptyState title={t('emptyPast')} body={t('emptyPastBody')} />
          )
        }
        cancelled={
          cancelled.length ? (
            list(cancelled)
          ) : (
            <EmptyState title={t('emptyCancelled')} body={t('emptyCancelledBody')} />
          )
        }
      />
    </div>
  );
}
