import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Sparkles } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { AppHeader } from '@/components/layout/AppHeader';
import { SectionHeader, Surface } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { CategoryCard } from '@/components/cards/CategoryCard';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { BookingCard } from '@/components/cards/BookingCard';
import { JourneyCard } from '@/components/cards/JourneyCard';
import { RecommendationCard } from '@/components/cards/RecommendationCard';
import { HomeSearchLink } from '@/features/home/HomeSearchLink';
import { getHomeFeed, getNextBooking, getUnreadCount } from '@/server/queries/home';
import { getCurrentUser, getMembership } from '@/server/session';
import { getJourneyOverview } from '@/server/queries/journey';
import { CATEGORY_ORDER, CATEGORY_META } from '@/lib/categories';
import { greetingKey } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * Home is a starting point, not a dashboard. It answers three questions in
 * order — what is happening today, what should I do next, what else is there —
 * and every block below the fold is allowed to be absent.
 */
export default async function HomePage() {
  const locale = await getLocale();
  const t = await getTranslations('Home');
  const tc = await getTranslations('Common');
  const tcat = await getTranslations('Categories');

  const [user, feed, nextBooking, unread, membership, journey] = await Promise.all([
    getCurrentUser(),
    getHomeFeed(),
    getNextBooking(),
    getUnreadCount(),
    getMembership(),
    getJourneyOverview(),
  ]);

  if (!user) return null;

  const firstName = user.name?.split(' ')[0] ?? '';
  const greeting = t(greetingKey(new Date().getHours()), { name: firstName });
  const city = user.profile?.city
    ? pick(user.profile.city, 'name', locale)
    : null;

  // The "because you…" line needs the user's own words, not a category name.
  const tgoals = await getTranslations('Onboarding.goals');
  const goalLabel = feed.primaryGoal ? tgoals(feed.primaryGoal) : null;

  return (
    <div className="pb-6">
      <AppHeader
        greeting={greeting}
        name={user.name}
        city={city}
        unread={unread}
        avatarSrc={user.image}
      />

      <div className="px-5">
        <HomeSearchLink placeholder={t('searchPlaceholder')} />
      </div>

      {/* ---------------------------------------------------- NAMAT Today --- */}
      <section className="mt-6 px-5">
        <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
          <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
            {t('todayTitle')}
          </p>

          {journey?.today.length ? (
            <ul className="mt-4 space-y-3">
              {journey.today.map((b) => (
                <li key={b.id} className="flex items-baseline gap-3">
                  <span className="w-14 shrink-0 text-[13px] font-medium tabular-nums text-green">
                    {new Intl.DateTimeFormat(locale === 'ar' ? 'ar-OM' : 'en-OM', {
                      hour: 'numeric',
                      minute: '2-digit',
                    }).format(b.startsAt)}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate text-[15px] font-medium text-ink">
                      {pick(b.service, 'name', locale)}
                    </span>
                    <span className="block truncate text-[13px] text-ink-soft">
                      {pick(b.provider, 'name', locale)}
                    </span>
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <>
              <p className="mt-3 text-[17px] font-semibold leading-snug text-ink">
                {t('todayNothing')}
              </p>
              <p className="mt-1.5 text-[14px] leading-snug text-ink-soft">
                {t('todayNothingBody')}
              </p>
            </>
          )}

          <Button asChild variant="tertiary" size="sm" className="mt-4">
            <Link href="/app/journey">
              {t('todayCta')}
              <ArrowRight className="rtl-flip" />
            </Link>
          </Button>
        </Surface>
      </section>

      {/* ------------------------------------------------ Upcoming booking --- */}
      {nextBooking ? (
        <section className="mt-6 px-5">
          <SectionHeader title={t('upcoming')} className="mb-3" />
          <BookingCard
            variant="next"
            locale={locale}
            booking={{
              id: nextBooking.id,
              providerName: pick(nextBooking.provider, 'name', locale),
              serviceName: pick(nextBooking.service, 'name', locale),
              image: nextBooking.provider.image,
              startsAt: nextBooking.startsAt,
              status: nextBooking.status,
              coveredByMembership: nextBooking.coveredByMembership,
            }}
          />
        </section>
      ) : null}

      {/* ------------------------------------------------------ Categories --- */}
      <section className="mt-8">
        <div className="px-5">
          <SectionHeader
            title={t('categories')}
            action={
              <Button asChild variant="tertiary" size="sm">
                <Link href="/app/explore">{tc('seeAll')}</Link>
              </Button>
            }
          />
        </div>
        <div className="rail mt-3 gap-3 px-5">
          {CATEGORY_ORDER.map((category) => (
            <CategoryCard
              key={category}
              size="sm"
              href={`/app/explore?category=${category}`}
              label={tcat(category)}
              image={CATEGORY_META[category].image}
            />
          ))}
        </div>
      </section>

      {/* ----------------------------------------------------- Recommended --- */}
      {feed.recommended.length ? (
        <section className="mt-8 px-5">
          <SectionHeader title={t('recommended')} className="mb-3" />
          <div className="space-y-3">
            {feed.recommended.map((p) => (
              <RecommendationCard
                key={p.slug}
                href={`/app/explore/${p.slug}`}
                title={pick(p, 'name', locale)}
                subtitle={tcat(p.category)}
                reason={
                  goalLabel ? t('recommendedWhy', { goal: goalLabel }) : tcat(p.category)
                }
                image={p.image}
              />
            ))}
          </div>
        </section>
      ) : null}

      {/* --------------------------------------------------------- Package --- */}
      <section className="mt-8 px-5">
        {membership && journey?.member ? (
          <JourneyCard
            packageName={pick(membership.package, 'name', locale)}
            status={membership.status}
            daysLeft={journey.daysLeft}
            locale={locale}
            allowances={journey.allowances.slice(0, 3).map((a) => ({
              category: a.category,
              label: tcat(a.category),
              used: a.used,
              total: a.total,
            }))}
          />
        ) : (
          <Surface tone="green" radius="xl" pad="lg" elevation="md">
            <Sparkles className="size-5 text-accent" aria-hidden />
            <h2 className="mt-3 text-[20px] font-semibold leading-snug text-white">
              {t('noPackageTitle')}
            </h2>
            <p className="mt-2 text-[14px] leading-snug text-white/70">
              {t('noPackageBody')}
            </p>
            <Button asChild variant="onDark" size="md" className="mt-5">
              <Link href="/app/packages">{t('noPackageCta')}</Link>
            </Button>
          </Surface>
        )}
      </section>

      {/* -------------------------------------------------------- Near you --- */}
      {feed.nearYou.length ? (
        <section className="mt-8">
          <div className="px-5">
            <SectionHeader title={t('nearYou')} />
          </div>
          <div className="rail mt-3 gap-3 px-5">
            {feed.nearYou.map((p) => (
              <ProviderCard
                key={p.slug}
                variant="tile"
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
            ))}
          </div>
        </section>
      ) : null}

      {/* -------------------------------------------------- Try something --- */}
      {feed.tryNew.length ? (
        <section className="mt-8">
          <div className="px-5">
            <SectionHeader title={t('tryNew')} />
          </div>
          <div className="rail mt-3 gap-3 px-5">
            {feed.tryNew.map((p) => (
              <ProviderCard
                key={p.slug}
                variant="tile"
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
            ))}
          </div>
        </section>
      ) : null}
    </div>
  );
}
