import { getTranslations, getLocale } from 'next-intl/server';
import { BackBar } from '@/components/layout/AppHeader';
import { PackageCard } from '@/components/cards/PackageCard';
import { Surface } from '@/components/ui/card';
import { getPackages } from '@/server/queries/journey';
import { getMembership } from '@/server/session';
import { pick, pickList } from '@/lib/localized';

export default async function PackagesPage() {
  const locale = await getLocale();
  const t = await getTranslations('Packages');

  const [packages, membership] = await Promise.all([getPackages(), getMembership()]);
  const currentSlug = membership?.package.slug ?? null;

  return (
    <div className="pb-6">
      <BackBar />

      <header className="px-5 pt-4 pb-6">
        <h1 className="display text-[32px] text-ink text-balance">{t('title')}</h1>
        <p className="mt-2 text-[15px] text-ink-soft">{t('subtitle')}</p>
      </header>

      <div className="space-y-4 px-5">
        {packages.map((pkg) => (
          <PackageCard
            key={pkg.slug}
            locale={locale}
            current={pkg.slug === currentSlug}
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

      <div className="mt-6 px-5">
        <Surface tone="warmSoft" radius="md" pad="md" elevation="none">
          <p className="text-[14px] leading-snug text-ink-soft">{t('flexible')}</p>
        </Surface>
      </div>
    </div>
  );
}
