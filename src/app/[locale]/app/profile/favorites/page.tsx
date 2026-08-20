import { getTranslations, getLocale } from 'next-intl/server';
import { Heart } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { EmptyState } from '@/components/ui/feedback';
import { Button } from '@/components/ui/button';
import { getFavorites } from '@/server/queries/bookings';
import { pick } from '@/lib/localized';

export default async function FavoritesPage() {
  const locale = await getLocale();
  const t = await getTranslations('Profile');
  const tb = await getTranslations('Bookings');
  const tcat = await getTranslations('Categories');

  const favorites = await getFavorites();

  return (
    <div className="pb-6">
      <BackBar title={t('favorites')} />

      <div className="mt-4 space-y-3 px-5">
        {favorites.length ? (
          favorites.map((p) => (
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
                tags: locale === 'ar' ? p.tagsAr : p.tagsEn,
              }}
            />
          ))
        ) : (
          <EmptyState
            icon={<Heart aria-hidden />}
            title={t('favoritesEmpty')}
            body={t('favoritesEmptyBody')}
            action={
              <Button asChild size="md">
                <Link href="/app/explore">{tb('explore')}</Link>
              </Button>
            }
          />
        )}
      </div>
    </div>
  );
}
