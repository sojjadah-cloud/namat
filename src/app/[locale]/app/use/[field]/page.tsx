import { notFound } from 'next/navigation';
import { getTranslations, getLocale } from 'next-intl/server';
import { PackageOpen, ArrowLeft } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { FieldSearch } from '@/features/use/FieldSearch';
import { fieldByKey } from '@/lib/fields';
import { searchProviders } from '@/server/queries/explore';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * One field: search and filters scoped to it.
 *
 * The search here is contextual by construction — it only ever queries this
 * field's categories, so typing "بروتين" inside meals finds kitchens and the
 * same word inside stores finds supplements. There is no way for an unrelated
 * result to appear, because the unrelated rows are never in the query.
 */
export default async function FieldPage({
  params,
  searchParams,
}: {
  params: Promise<{ field: string }>;
  searchParams: Promise<{ q?: string; f?: string }>;
}) {
  const { field: key } = await params;
  const { q, f } = await searchParams;

  const field = fieldByKey(key);
  if (!field) notFound();

  const t = await getTranslations('Use');
  const locale = await getLocale();
  const tcat = await getTranslations('Categories');

  const active = f ? f.split(',').filter(Boolean) : [];

  const all = await searchProviders({ q });
  // The field owns its slice of the catalogue; nothing else can surface here.
  let results = all.filter((p) => field.categories.includes(p.category));

  // Filters that map onto data we actually hold. The rest are declared in the
  // field definition and rendered, but cannot narrow anything until the
  // catalogue carries the facts behind them — a filter that silently does
  // nothing is worse than one that is visibly unavailable, so unsupported
  // chips are disabled rather than shown as working.
  if (active.includes('delivery')) {
    results = results.filter((p) => p.ownDelivery === true || p.platformDelivery === true);
  }
  if (active.includes('pickup')) results = results.filter((p) => p.pickup === true);
  if (active.includes('subscriptions')) {
    results = results.filter((p) => p.weeklyPlan === true || p.monthlyPlan === true);
  }
  if (active.includes('highProtein')) results = results.filter((p) => p.foodTags.includes('HIGH_PROTEIN'));
  if (active.includes('keto')) results = results.filter((p) => p.foodTags.includes('KETO'));
  if (active.includes('vegetarian')) results = results.filter((p) => p.foodTags.includes('VEGETARIAN'));
  if (active.includes('supplements') || active.includes('natural') || active.includes('organic')) {
    results = results.filter((p) => p.foodTags.includes('GROCERY'));
  }
  if (active.includes('womenOnly')) results = results.filter((p) => p.womenOnly);

  if (active.includes('nearest')) {
    results = [...results].sort((a, b) => (a.distanceKm ?? Infinity) - (b.distanceKm ?? Infinity));
  }
  if (active.includes('topRated')) {
    results = [...results].sort((a, b) => (b.rating ?? 0) - (a.rating ?? 0));
  }

  // Two different kinds of nothing, and conflating them is a bad experience:
  // "we have no partners here" is about NAMAT, "your search found none" is
  // about the query, and only one of them is fixed by clearing a filter.
  const fieldIsEmpty = all.filter((p) => field.categories.includes(p.category)).length === 0;

  return (
    <div className="pb-6">
      <BackBar />

      <header className="px-5 pt-2 pb-4">
        <h1 className="display text-[26px] text-ink">{t(key)}</h1>
        <p className="mt-1.5 text-[14px] text-ink-soft">{t('searchTitle')}</p>
      </header>

      {!fieldIsEmpty ? (
        <FieldSearch
          fieldKey={key}
          placeholder={t(
            `search${key.charAt(0).toUpperCase()}${key.slice(1)}` as
              | 'searchMeals'
              | 'searchFitness'
              | 'searchExperts'
              | 'searchStores',
          )}
          filters={field.filters}
          active={active}
          initialQuery={q ?? ''}
        />
      ) : null}

      <div className="mt-5 px-5">
        {fieldIsEmpty ? (
          <EmptyField />
        ) : results.length === 0 ? (
          <Surface tone="warmSoft" radius="lg" pad="xl" elevation="none" className="text-center">
            <p className="text-[16px] font-semibold text-ink">{t('noMatch')}</p>
            <p className="mt-1.5 text-[14px] text-ink-soft">{t('noMatchBody')}</p>
            <Button asChild variant="secondary" size="sm" className="mt-4">
              <Link href={`/app/use/${key}`}>{t('clearFilters')}</Link>
            </Button>
          </Surface>
        ) : (
          <>
            <p className="mb-3 text-[13px] text-ink-soft">
              {t('resultCount', { count: formatNumber(results.length, locale) })}
            </p>
            <div className="space-y-3">
              {results.map((p) => (
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
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
}

/**
 * Shown when NAMAT has no partners in this field at all.
 *
 * It says so plainly instead of dressing it up: pretending a field is
 * "coming soon" is a promise nobody has made, and an empty search box above an
 * empty list just looks broken.
 */
async function EmptyField() {
  const t = await getTranslations('Use');

  return (
    <Surface tone="warmSoft" radius="lg" pad="xl" elevation="none" className="text-center">
      <span className="mx-auto grid size-14 place-items-center rounded-full bg-white text-ink-soft">
        <PackageOpen className="size-6" strokeWidth={1.6} aria-hidden />
      </span>
      <p className="mt-5 text-[17px] font-semibold text-ink">{t('emptyTitle')}</p>
      <p className="mx-auto mt-2 max-w-[34ch] text-[14px] leading-relaxed text-ink-soft">
        {t('emptyBody')}
      </p>
      <Button asChild variant="secondary" size="sm" className="mt-5">
        <Link href="/app/use">
          {t('emptyCta')}
          <ArrowLeft className="size-4 rtl-flip" aria-hidden />
        </Link>
      </Button>
    </Surface>
  );
}
