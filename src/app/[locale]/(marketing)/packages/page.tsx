import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Check, Minus } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { Section, Eyebrow, SectionTitle, SectionLead } from '@/components/marketing/Section';
import { PackageCard } from '@/components/cards/PackageCard';
import { getPackages } from '@/server/queries/journey';
import { CATEGORY_ORDER, CATEGORY_META } from '@/lib/categories';
import { formatPrice, formatNumber } from '@/lib/format';
import { pick, pickList } from '@/lib/localized';

/**
 * The public membership preview: the same three cards as in-app, plus the
 * side-by-side table. Pre-auth, so every CTA points at signup rather than
 * checkout — nobody should reach a payment sheet before they have an account.
 */
export default async function PublicPackagesPage() {
  const locale = await getLocale();
  const t = await getTranslations('Packages');
  const tcat = await getTranslations('Categories');
  const tl = await getTranslations('Landing');

  const packages = await getPackages();

  return (
    <>
      <section className="bloom px-5 pt-32 pb-16 md:px-8 md:pt-40 md:pb-20">
        <div className="mx-auto max-w-[1240px] text-center">
          <Eyebrow className="justify-center">{tl('membership.eyebrow')}</Eyebrow>
          <h1 className="display mx-auto mt-5 max-w-[16ch] text-[42px] text-ink text-balance md:text-[64px]">
            {t('title')}
          </h1>
          <p className="mx-auto mt-6 max-w-[48ch] text-[17px] leading-relaxed text-ink-soft md:text-[19px]">
            {t('subtitle')}
          </p>
        </div>
      </section>

      {/* ========================================================== Cards === */}
      <Section className="pt-0 md:pt-0">
        <div className="grid gap-5 lg:grid-cols-3">
          {packages.map((pkg) => (
            <PackageCard
              key={pkg.slug}
              locale={locale}
              pkg={{
                slug: pkg.slug,
                name: pick(pkg, 'name', locale),
                bestFor: pick(pkg, 'bestFor', locale),
                price: pkg.price,
                periodDays: pkg.periodDays,
                benefits: pickList(pkg, 'benefits', locale),
                featured: pkg.featured,
              }}
            />
          ))}
        </div>

        <p className="mt-8 text-center text-[14px] text-ink-soft">{t('flexible')}</p>
      </Section>

      {/* ======================================================= Compare === */}
      <Section tone="warm">
        <SectionTitle className="mt-0">{t('compareTitle')}</SectionTitle>
        <SectionLead>{tl('membership.body')}</SectionLead>

        <Surface radius="xl" pad="none" className="mt-12 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full min-w-[560px] border-collapse text-start">
              <thead>
                <tr className="border-b border-line">
                  <th className="p-5 text-start text-[13px] font-medium text-ink-soft">
                    {t('includes')}
                  </th>
                  {packages.map((pkg) => (
                    <th key={pkg.slug} className="p-5 text-start">
                      <span className="block text-[17px] font-semibold text-ink">
                        {pick(pkg, 'name', locale)}
                      </span>
                      <span className="mt-1 block text-[13px] font-normal text-ink-soft">
                        {formatPrice(pkg.price, locale)} · {t('perMonth')}
                      </span>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {CATEGORY_ORDER.map((category) => {
                  const meta = CATEGORY_META[category];
                  // Hide rows no package covers — an all-dashes row teaches
                  // the reader nothing except that the table is padded.
                  const anyone = packages.some((p) =>
                    p.allowances.some((a) => a.category === category),
                  );
                  if (!anyone) return null;

                  return (
                    <tr key={category} className="border-b border-line last:border-0">
                      <td className="p-5">
                        <span className="inline-flex items-center gap-2.5">
                          <span
                            className={`grid size-8 shrink-0 place-items-center rounded-full ${meta.bg}`}
                            style={{ color: meta.hex }}
                          >
                            <meta.icon className="size-4" strokeWidth={2} aria-hidden />
                          </span>
                          <span className="text-[15px] text-ink">{tcat(category)}</span>
                        </span>
                      </td>
                      {packages.map((pkg) => {
                        const allowance = pkg.allowances.find(
                          (a) => a.category === category,
                        );
                        return (
                          <td key={pkg.slug} className="p-5">
                            {allowance ? (
                              <span className="inline-flex items-center gap-2 text-[15px] font-medium text-ink">
                                <Check
                                  className="size-4 text-green"
                                  strokeWidth={2.5}
                                  aria-hidden
                                />
                                {formatNumber(allowance.quantity, locale)}
                              </span>
                            ) : (
                              <Minus className="size-4 text-ink-soft/40" aria-hidden />
                            )}
                          </td>
                        );
                      })}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Surface>
      </Section>

      {/* =========================================================== CTA === */}
      <Section tone="green">
        <div className="mx-auto max-w-[46ch] text-center">
          <SectionTitle tone="light" className="mt-0">
            {tl('membership.title')}
          </SectionTitle>
          <SectionLead tone="light" className="mx-auto">
            {tl('membership.singleBody')}
          </SectionLead>
          <div className="mt-10 flex flex-wrap justify-center gap-3">
            <Button asChild variant="onDark" size="xl">
              <Link href="/welcome">
                {tl('cta.primary')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
            <Button
              asChild
              size="xl"
              className="border border-white/25 bg-transparent text-white hover:bg-white/10"
            >
              <Link href="/services">{tl('hero.secondary')}</Link>
            </Button>
          </div>
        </div>
      </Section>
    </>
  );
}
