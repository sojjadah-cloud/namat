import { notFound } from 'next/navigation';
import { getTranslations, getLocale } from 'next-intl/server';
import { prisma } from '@/lib/prisma';
import { BackBar } from '@/components/layout/AppHeader';
import { BookingFlow } from '@/features/booking/BookingFlow';
import { getAvailability } from '@/server/queries/explore';
import { getCoveringSlug, getMembership } from '@/server/session';
import { pick } from '@/lib/localized';

export default async function BookPage({
  params,
}: {
  params: Promise<{ serviceId: string }>;
}) {
  const { serviceId } = await params;
  const locale = await getLocale();
  const t = await getTranslations('Booking');

  const service = await prisma.service.findUnique({
    where: { id: serviceId },
    include: { provider: true },
  });
  if (!service || !service.isActive) notFound();

  const [days, coveringSlug, membership] = await Promise.all([
    getAvailability(service.id),
    getCoveringSlug(),
    getMembership(),
  ]);

  const included = Boolean(coveringSlug && service.includedIn.includes(coveringSlug));
  const allowance = membership?.package.allowances.find(
    (a) => a.category === service.category,
  );
  const usage = membership?.usage.find((u) => u.category === service.category);

  return (
    <div>
      <BackBar title={t('title')} />
      <BookingFlow
        service={{
          id: service.id,
          name: pick(service, 'name', locale),
          description: pick(service, 'desc', locale) || null,
          duration: service.duration,
          price: service.price,
          included,
          providerName: pick(service.provider, 'name', locale),
          providerAddress: pick(service.provider, 'address', locale),
        }}
        // Dates cross the server/client boundary as ISO strings so the client
        // formats them in the user's locale rather than trusting a serialised
        // Date that has already lost its zone.
        days={days.map((d) => ({
          date: d.date,
          times: d.times.map((s) => ({
            id: s.id,
            startsAt: s.startsAt.toISOString(),
            full: s.full,
          })),
        }))}
        allowanceUsed={included ? (usage?.used ?? 0) : undefined}
        allowanceTotal={included ? allowance?.quantity : undefined}
      />
    </div>
  );
}
