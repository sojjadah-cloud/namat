import { notFound } from 'next/navigation';
import { getTranslations, getLocale } from 'next-intl/server';
import { Check } from 'lucide-react';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface, SectionHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { PackageCheckout } from '@/features/packages/PackageCheckout';
import { getPackage } from '@/server/queries/journey';
import { getMembership } from '@/server/session';
import { formatPrice, formatDateLong, formatNumber, addDays } from '@/lib/format';
import { pick, pickList } from '@/lib/localized';

export default async function PackageDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const locale = await getLocale();
  const t = await getTranslations('Packages');
  const tcat = await getTranslations('Categories');

  const [pkg, membership] = await Promise.all([getPackage(slug), getMembership()]);
  if (!pkg) notFound();

  const isCurrent = membership?.package.slug === pkg.slug;
  const starts = new Date();
  const renews = addDays(starts, pkg.periodDays);

  return (
    <div className="pb-28">
      <BackBar />

      <header className="px-5 pt-4 pb-6">
        {isCurrent ? <Badge tone="included" size="md">{t('current')}</Badge> : null}
        <h1 className="display mt-3 text-[34px] text-ink">{pick(pkg, 'name', locale)}</h1>
        <p className="mt-3 text-[16px] leading-snug text-ink-soft">
          {pick(pkg, 'desc', locale)}
        </p>
      </header>

      <section className="px-5">
        <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
          <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
            {t('bestFor')}
          </p>
          <p className="mt-2 text-[17px] leading-snug text-ink">
            {pick(pkg, 'bestFor', locale)}
          </p>
        </Surface>
      </section>

      {/* ---------------------------------------------------- What is in it --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={t('includes')} className="mb-3" />
        <ul className="space-y-3">
          {pickList(pkg, 'benefits', locale).map((benefit) => (
            <li key={benefit} className="flex items-start gap-3">
              <Check className="mt-0.5 size-4 shrink-0 text-green" strokeWidth={2.4} aria-hidden />
              <span className="text-[15px] leading-snug text-ink">{benefit}</span>
            </li>
          ))}
        </ul>
      </section>

      {/* ------------------------------------------------ Allowance breakdown --- */}
      <section className="mt-8 px-5">
        <Surface radius="lg" pad="lg">
          <div className="divide-y divide-line">
            {pkg.allowances
              .slice()
              .sort((a, b) => b.quantity - a.quantity)
              .map((a) => (
                <div key={a.id} className="flex items-baseline justify-between gap-4 py-3">
                  <span className="text-[15px] text-ink">{tcat(a.category)}</span>
                  <span className="text-[15px] font-semibold tabular-nums text-ink">
                    {formatNumber(a.quantity, locale)}
                  </span>
                </div>
              ))}
          </div>
        </Surface>
      </section>

      <p className="mt-5 px-5 text-[13px] text-ink-soft">{t('flexible')}</p>

      {!isCurrent ? (
        <PackageCheckout
          slug={pkg.slug}
          packageName={pick(pkg, 'name', locale)}
          priceLabel={formatPrice(pkg.price, locale)}
          periodDays={pkg.periodDays}
          startsLabel={formatDateLong(starts, locale)}
          renewsLabel={formatDateLong(renews, locale)}
        />
      ) : null}
    </div>
  );
}
