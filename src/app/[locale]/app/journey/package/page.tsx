import { getTranslations, getLocale } from 'next-intl/server';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface, SectionHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { Button } from '@/components/ui/button';
import { AllowanceMeter, ProgressBar } from '@/components/ui/progress';
import { EmptyState } from '@/components/ui/feedback';
import { PackageManage } from '@/features/packages/PackageManage';
import { getJourneyOverview } from '@/server/queries/journey';
import { formatDateLong, formatPrice, formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

export default async function PackageDetailPage() {
  const locale = await getLocale();
  const t = await getTranslations('Packages');
  const td = await getTranslations('Packages.detail');
  const tcat = await getTranslations('Categories');
  const ta = await getTranslations('Journey.active');

  const journey = await getJourneyOverview();

  if (!journey?.member) {
    return (
      <div>
        <BackBar title={t('title')} />
        <div className="px-5 pt-6">
          <EmptyState
            title={t('title')}
            body={t('subtitle')}
            action={
              <Button asChild size="md">
                <Link href="/app/packages">{t('start')}</Link>
              </Button>
            }
          />
        </div>
      </div>
    );
  }

  const { membership, allowances, daysLeft } = journey;
  const paused = membership.status === 'PAUSED';

  return (
    <div className="pb-8">
      <BackBar title={pick(membership.package, 'name', locale)} />

      {/* Paused is a first-class state, explained on arrival rather than
          discovered when a benefit silently fails to apply. */}
      {paused ? (
        <section className="px-5 pt-4">
          <Surface tone="warm" radius="lg" pad="lg" elevation="none">
            <h2 className="text-[19px] font-semibold text-ink">{td('pausedTitle')}</h2>
            <p className="mt-2 text-[14px] leading-snug text-ink-soft">{td('pausedNote')}</p>
            {membership.pausedAt ? (
              <p className="mt-3 text-[13px] text-ink-soft">
                {td('pausedFrom')} · {formatDateLong(membership.pausedAt, locale)}
              </p>
            ) : null}
          </Surface>
        </section>
      ) : null}

      {/* --------------------------------------------------------- Summary --- */}
      <section className="px-5 pt-5">
        <Surface radius="lg" pad="lg">
          <div className="divide-y divide-line">
            <Row label={td('status')} value={t(`status.${membership.status}`)} />
            <Row label={td('started')} value={formatDateLong(membership.startedAt, locale)} />
            <Row label={td('ends')} value={formatDateLong(membership.endsAt, locale)} />
            {membership.renewsAt ? (
              <Row label={td('renews')} value={formatDateLong(membership.renewsAt, locale)} />
            ) : null}
            <Row label={td('price')} value={formatPrice(membership.package.price, locale)} />
          </div>
        </Surface>
      </section>

      {/* ----------------------------------------------------------- Usage --- */}
      <section className="mt-8 px-5">
        <SectionHeader
          title={td('usage')}
          action={
            <Badge tone="neutral">
              {ta('daysLeft', { days: formatNumber(daysLeft, locale) })}
            </Badge>
          }
          className="mb-3"
        />
        <Surface radius="lg" pad="lg">
          <div className="space-y-5">
            {allowances.map((a) => (
              <div key={a.category}>
                <div className="mb-2 flex items-baseline justify-between gap-3">
                  <span className="text-[14px] text-ink">{tcat(a.category)}</span>
                  <span className="text-[14px] font-medium tabular-nums text-ink-soft">
                    {formatNumber(Math.min(a.used, a.total), locale)} /{' '}
                    {formatNumber(a.total, locale)}
                  </span>
                </div>
                {a.total <= 10 ? (
                  <AllowanceMeter used={a.used} total={a.total} />
                ) : (
                  <ProgressBar value={a.used} max={a.total} size="sm" />
                )}
              </div>
            ))}
          </div>
        </Surface>
      </section>

      {/* ---------------------------------------------------------- Manage --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={td('manage')} className="mb-3" />
        <PackageManage
          status={membership.status}
          endsLabel={formatDateLong(membership.endsAt, locale)}
        />
      </section>
    </div>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-baseline justify-between gap-4 py-3 first:pt-0 last:pb-0">
      <span className="text-[14px] text-ink-soft">{label}</span>
      <span className="text-[14px] font-medium text-ink">{value}</span>
    </div>
  );
}
