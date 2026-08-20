'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { TrendingUp, X } from 'lucide-react';
import { Link, useRouter } from '@/i18n/routing';
import { SearchField } from '@/components/ui/field';
import { Chip } from '@/components/ui/chip';
import { SectionHeader } from '@/components/ui/card';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { EmptyState, ListSkeleton } from '@/components/ui/feedback';
import { Button } from '@/components/ui/button';
import { CATEGORY_ORDER } from '@/lib/categories';
import type { ProviderListItem } from '@/server/queries/explore';
import { pick } from '@/lib/localized';
import * as recentSearches from '@/lib/recent-searches';

/**
 * Search is a screen, not a field. Before you type it shows the two things
 * that actually get tapped — what you searched before, and where everyone
 * else is going — because an empty search screen is a dead end.
 */
export function SearchScreen({
  results,
  query,
  trending,
}: {
  results: ProviderListItem[];
  query: string;
  trending: ProviderListItem[];
}) {
  const locale = useLocale();
  const t = useTranslations('Search');
  const tcat = useTranslations('Categories');
  const router = useRouter();

  const [value, setValue] = React.useState(query);
  const [pending, startTransition] = React.useTransition();

  const recent = React.useSyncExternalStore(
    recentSearches.subscribe,
    recentSearches.getSnapshot,
    recentSearches.getServerSnapshot,
  );

  const submit = (q: string) => {
    const trimmed = q.trim();
    setValue(trimmed);
    if (trimmed) recentSearches.remember(trimmed);
    startTransition(() => {
      router.replace(trimmed ? `/app/search?q=${encodeURIComponent(trimmed)}` : '/app/search');
    });
  };


  const card = (p: ProviderListItem) => (
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
      }}
    />
  );

  return (
    <div className="pb-6">
      <div className="sticky top-0 z-40 bg-canvas/90 px-5 pt-4 pb-3 backdrop-blur-xl">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            submit(value);
          }}
        >
          <SearchField
            autoFocus
            value={value}
            placeholder={t('placeholder')}
            onValueChange={setValue}
            onClear={() => submit('')}
          />
        </form>
      </div>

      {query ? (
        <div className="mt-2 space-y-3 px-5">
          {pending ? (
            <ListSkeleton count={3} />
          ) : results.length ? (
            <>
              <SectionHeader title={t('resultsPlaces')} className="mb-1" />
              {results.map(card)}
            </>
          ) : (
            <EmptyState
              title={t('noResults')}
              body={t('noResultsBody')}
              action={
                <Button asChild variant="secondary" size="md">
                  <Link href="/app/explore">{t('adjust')}</Link>
                </Button>
              }
            />
          )}
        </div>
      ) : (
        <div className="mt-4 space-y-8">
          {recent.length ? (
            <section className="px-5">
              <SectionHeader
                title={t('recent')}
                action={
                  <button
                    type="button"
                    onClick={recentSearches.clearRecent}
                    className="text-[13px] font-medium text-ink-soft hover:text-ink"
                  >
                    {t('clearRecent')}
                  </button>
                }
                className="mb-3"
              />
              <ul className="space-y-1">
                {recent.map((q) => (
                  <li key={q}>
                    <button
                      type="button"
                      onClick={() => submit(q)}
                      className="flex w-full items-center gap-3 rounded-sm py-2.5 text-start text-[15px] text-ink hover:bg-black/[0.03]"
                    >
                      <X className="size-4 shrink-0 rotate-45 text-ink-soft" aria-hidden />
                      <span className="truncate">{q}</span>
                    </button>
                  </li>
                ))}
              </ul>
            </section>
          ) : null}

          <section>
            <div className="px-5">
              <SectionHeader title={t('suggested')} className="mb-3" />
            </div>
            <div className="rail gap-2 px-5">
              {CATEGORY_ORDER.map((c) => (
                <Chip key={c} onClick={() => router.push(`/app/explore?category=${c}`)}>
                  {tcat(c)}
                </Chip>
              ))}
            </div>
          </section>

          {trending.length ? (
            <section className="px-5">
              <SectionHeader
                title={t('trending')}
                eyebrow={<TrendingUp className="size-3.5" aria-hidden />}
                className="mb-3"
              />
              <div className="space-y-3">{trending.map(card)}</div>
            </section>
          ) : null}
        </div>
      )}
    </div>
  );
}
