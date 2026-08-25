import { notFound } from 'next/navigation';
import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { CalendarDays, Clock, MapPin, Navigation, Phone, CheckCircle2 } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { Button } from '@/components/ui/button';
import { BookingActions } from '@/features/bookings/BookingActions';
import { getBooking } from '@/server/queries/bookings';
import { getAvailability } from '@/server/queries/explore';
import { formatDateLong, formatTime, formatDuration, formatPrice } from '@/lib/format';
import { pick } from '@/lib/localized';
import { providerImage } from '@/lib/provider-image';

export default async function BookingDetailPage({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<Record<string, string | undefined>>;
}) {
  const { id } = await params;
  const { new: isNew } = await searchParams;
  const locale = await getLocale();
  const t = await getTranslations('Bookings');
  const td = await getTranslations('Bookings.detail');
  const tb = await getTranslations('Booking');
  const tc = await getTranslations('Common');
  const tp = await getTranslations('Provider');

  const booking = await getBooking(id);
  if (!booking) notFound();

  const upcoming = booking.status === 'CONFIRMED' && booking.startsAt > new Date();
  const days = upcoming ? await getAvailability(booking.serviceId) : [];

  return (
    <div className="pb-8">
      <BackBar title={td('title')} />

      {/* Success is a state of this screen, not a separate route — refreshing
          after a booking should not replay a celebration. */}
      {isNew ? (
        <section className="px-5 pt-4">
          <Surface tone="green" radius="lg" pad="lg" elevation="md">
            <CheckCircle2 className="size-6 text-accent" aria-hidden />
            <h2 className="mt-3 text-[22px] font-semibold text-white">
              {tb('successTitle')}
            </h2>
            <p className="mt-1.5 text-[14px] text-white/70">{tb('successBody')}</p>
          </Surface>
        </section>
      ) : null}

      {/* ------------------------------------------------------- Identity --- */}
      <section className="px-5 pt-5">
        <div className="flex gap-4">
          <div className="relative size-20 shrink-0 overflow-hidden rounded-md">
            <Image
              src={providerImage(booking.provider.image, booking.provider.category)}
              alt=""
              fill
              sizes="80px"
              className="object-cover"
            />
          </div>
          <div className="min-w-0 flex-1">
            <Badge
              tone={
                booking.status === 'CANCELLED'
                  ? 'danger'
                  : booking.status === 'COMPLETED'
                    ? 'neutral'
                    : 'soft'
              }
            >
              {t(`status.${booking.status}`)}
            </Badge>
            <h1 className="mt-2 text-[20px] font-semibold leading-tight text-ink">
              {pick(booking.service, 'name', locale)}
            </h1>
            <Link
              href={`/app/explore/${booking.provider.slug}`}
              className="mt-1 block truncate text-[14px] text-ink-soft hover:underline"
            >
              {pick(booking.provider, 'name', locale)}
            </Link>
          </div>
        </div>
      </section>

      {/* ----------------------------------------------------------- When --- */}
      <section className="mt-6 px-5">
        <Surface radius="lg" pad="lg">
          <div className="divide-y divide-line">
            <Row
              icon={<CalendarDays aria-hidden />}
              label={tb('date')}
              value={formatDateLong(booking.startsAt, locale)}
            />
            <Row
              icon={<Clock aria-hidden />}
              label={tb('time')}
              value={
                booking.service.duration
                  ? `${formatTime(booking.startsAt, locale)} · ${formatDuration(booking.service.duration, locale)}`
                  : formatTime(booking.startsAt, locale)
              }
            />
            <Row
              icon={<MapPin aria-hidden />}
              label={tb('location')}
              value={pick(booking.provider, 'address', locale)}
            />
          </div>
        </Surface>
      </section>

      {/* -------------------------------------------------------- Payment --- */}
      <section className="mt-4 px-5">
        <Surface radius="lg" pad="lg">
          <div className="flex items-baseline justify-between gap-4">
            <span className="text-[14px] text-ink-soft">{tb('payment')}</span>
            <span className="text-[15px] font-semibold text-ink">
              {booking.coveredByMembership
                ? tb('paymentPackage')
                : formatPrice(booking.price, locale)}
            </span>
          </div>
          <div className="mt-3 flex items-baseline justify-between gap-4 border-t border-line pt-3">
            <span className="text-[14px] text-ink-soft">{td('reference')}</span>
            <span className="text-[14px] font-medium tabular-nums text-ink">
              {booking.reference}
            </span>
          </div>
        </Surface>
      </section>

      {/* ---------------------------------------------------------- Getting there --- */}
      <section className="mt-4 flex gap-2.5 px-5">
        <Button asChild variant="secondary" size="md" className="flex-1">
          <a
            href={`https://www.google.com/maps/search/?api=1&query=${booking.provider.latitude},${booking.provider.longitude}`}
            target="_blank"
            rel="noreferrer"
          >
            <Navigation className="rtl-flip" />
            {tc('directions')}
          </a>
        </Button>
        {booking.provider.phone ? (
          <Button asChild variant="secondary" size="md" className="flex-1">
            <a href={`tel:${booking.provider.phone.replace(/\s/g, '')}`}>
              <Phone />
              {td('contact')}
            </a>
          </Button>
        ) : null}
      </section>

      {/* -------------------------------------------------------- Actions --- */}
      <section className="mt-6 px-5">
        <BookingActions
          bookingId={booking.id}
          cancellable={upcoming}
          days={days.map((d) => ({
            date: d.date,
            times: d.times.map((s) => ({
              id: s.id,
              startsAt: s.startsAt.toISOString(),
              full: s.full,
            })),
          }))}
        />
      </section>

      {upcoming ? (
        <p className="mt-5 px-5 text-[12px] leading-snug text-ink-soft">{tp('policy')}</p>
      ) : null}
    </div>
  );
}

function Row({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
}) {
  return (
    <div className="flex items-start gap-3 py-3 first:pt-0 last:pb-0">
      <span className="mt-0.5 text-ink-soft [&_svg]:size-4">{icon}</span>
      <span className="min-w-0 flex-1">
        <span className="block text-[12px] text-ink-soft">{label}</span>
        <span className="block text-[15px] font-medium text-ink">{value}</span>
      </span>
    </div>
  );
}
