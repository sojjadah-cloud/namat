import { Suspense } from 'react';
import { getTranslations, getLocale } from 'next-intl/server';
import type { Category } from '@prisma/client';
import { Link } from '@/i18n/routing';
import { HomeSearchLink } from '@/features/home/HomeSearchLink';
import { CategoryChips, QuickFilters } from '@/features/explore/CategoryChips';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { EmptyState, ListSkeleton } from '@/components/ui/feedback';
import { Button } from '@/components/ui/button';
import { searchProviders } from '@/server/queries/explore';
import { getCoveringSlug } from '@/server/session';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

export default async function ExplorePage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | undefined>>;
}) {
  const params = await searchParams;
  const locale = await getLocale();
  const t = await getTranslations('Explore');
  const ts = await getTranslations('Search');
  const tcat = await getTranslations('Categories');

  const coveringSlug = await getCoveringSlug();

  const results = await searchProviders({
    q: params.q,
    category: (params.category as Category | undefined) ?? 'all',
    womenOnly: params.women === '1',
    includedOnly: params.included === '1',
    sort: (params.sort as 'rating' | 'distance' | undefined) ?? 'recommended',
  });

  return (
    <div className="pb-6">
      <header className="px-5 pt-5 pb-4">
        <h1 className="display text-[28px] text-ink">{t('title')}</h1>
      </header>

      <div className="px-5">
        <HomeSearchLink placeholder={t('searchPlaceholder')} />
      </div>

      <div className="mt-4 space-y-2.5">
        <Suspense fallback={<div className="h-10" />}>
          <CategoryChips />
        </Suspense>
        <Suspense fallback={<div className="h-8" />}>
          <QuickFilters hasPackage={Boolean(coveringSlug)} />
        </Suspense>
      </div>

      <p className="mt-5 px-5 text-[13px] text-ink-soft">
        {t('resultCount', { count: formatNumber(results.length, locale) })}
      </p>

      <div className="mt-3 space-y-3 px-5">
        <Suspense fallback={<ListSkeleton count={4} />}>
          {results.length ? (
            results.map((p) => (
              <ProviderCard
                key={p.slug}
                locale={locale}
                provider={{
                  slug: p.slug,
                  name: pick(p, 'name', locale),
                  categoryLabel: tcat(p.category),
                  image: p.image,
                  rating: p.rating,
                  reviewCount: p.reviewCount,
                  distanceKm: p.distanceKm,
                  tags: locale === 'ar' ? p.tagsAr : p.tagsEn,
                  included: p.included,
                  foodTags: p.foodTags,
                  menuProfile: p.menuProfile,
                  area: p.area,
                  ownDelivery: p.ownDelivery,
                  platformDelivery: p.platformDelivery,
                  pickup: p.pickup,
                  weeklyPlan: p.weeklyPlan,
                  monthlyPlan: p.monthlyPlan,
                }}
              />
            ))
          ) : (
            <EmptyState
              title={ts('noResults')}
              body={ts('noResultsBody')}
              action={
                <Button asChild variant="secondary" size="md">
                  <Link href="/app/explore">{ts('adjust')}</Link>
                </Button>
              }
            />
          )}
        </Suspense>
      </div>
    </div>
  );
}
