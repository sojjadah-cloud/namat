import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Check, Heart } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Surface, SectionHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { Button } from '@/components/ui/button';
import { EmptyState } from '@/components/ui/feedback';
import { JourneyCard } from '@/components/cards/JourneyCard';
import { BookingCard } from '@/components/cards/BookingCard';
import { ProviderCard } from '@/components/cards/ProviderCard';
import { getJourneyOverview } from '@/server/queries/journey';
import { getHomeFeed } from '@/server/queries/home';
import { getFavorites } from '@/server/queries/bookings';
import { formatTime, formatNumber, startOfWeek, addDays, isSameDay } from '@/lib/format';
import { pick } from '@/lib/localized';

type Overview = NonNullable<Awaited<ReturnType<typeof getJourneyOverview>>>;
type MemberOverview = Extract<Overview, { member: true }>;
type NonMemberOverview = Extract<Overview, { member: false }>;

/**
 * My Journey answers "am I actually doing this?" — and the honest answer
 * differs enormously depending on whether a package is running, so the screen
 * is two designs rather than one design with sections greyed out.
 */
export default async function JourneyPage() {
  const locale = await getLocale();
  const journey = await getJourneyOverview();
  if (!journey) return null;

  return journey.member ? (
    <MemberJourney journey={journey} locale={locale} />
  ) : (
    <NonMemberJourney journey={journey} locale={locale} />
  );
}

function PageTitle({ children }: { children: React.ReactNode }) {
  return (
    <header className="px-5 pt-5 pb-4">
      <h1 className="display text-[28px] text-ink">{children}</h1>
    </header>
  );
}

/* --------------------------------------------------------------- Member --- */

async function MemberJourney({
  journey,
  locale,
}: {
  journey: MemberOverview;
  locale: string;
}) {
  const t = await getTranslations('Journey');
  const ta = await getTranslations('Journey.active');
  const tcat = await getTranslations('Categories');
  const weekStart = startOfWeek(new Date());

  return (
    <div className="pb-6">
      <PageTitle>{t('title')}</PageTitle>

      {/* --------------------------------------------------------- The week --- */}
      <section className="px-5">
        <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
          <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
            {ta('week')}
          </p>

          {/* Seven dots, one per day. Filled means something happened. */}
          <div className="mt-4 flex justify-between gap-1">
            {Array.from({ length: 7 }, (_, i) => {
              const day = addDays(weekStart, i);
              const has = journey.weekBookings.some((b) => isSameDay(b.startsAt, day));
              const today = isSameDay(day, new Date());
              return (
                <div key={i} className="flex flex-1 flex-col items-center gap-2">
                  <span className="text-[11px] text-ink-soft">
                    {new Intl.DateTimeFormat(locale === 'ar' ? 'ar-OM' : 'en-OM', {
                      weekday: 'narrow',
                    }).format(day)}
                  </span>
                  <span
                    className={[
                      'grid size-8 place-items-center rounded-full transition-colors',
                      has ? 'bg-green text-white' : 'bg-white text-ink-soft',
                      today && !has ? 'ring-2 ring-green/35' : '',
                    ].join(' ')}
                  >
                    {has ? <Check className="size-4" strokeWidth={2.6} aria-hidden /> : null}
                  </span>
                </div>
              );
            })}
          </div>

          <p className="mt-5 flex flex-wrap gap-x-4 gap-y-1 text-[13px] text-ink-soft">
            <span>{ta('completed', { count: formatNumber(journey.completed, locale) })}</span>
            <span>
              {ta('upcomingCount', {
                count: formatNumber(journey.upcoming.length, locale),
              })}
            </span>
            <span>
              {ta('benefitsUsed', { count: formatNumber(journey.benefitsUsed, locale) })}
            </span>
          </p>
        </Surface>
      </section>

      {/* ------------------------------------------------------------ Today --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={ta('today')} className="mb-3" />
        {journey.today.length ? (
          <Surface radius="lg" pad="md">
            <ul className="space-y-4">
              {journey.today.map((b) => (
                <li key={b.id} className="flex items-baseline gap-4">
                  <span className="w-16 shrink-0 text-[13px] font-medium tabular-nums text-green">
                    {formatTime(b.startsAt, locale)}
                  </span>
                  <span className="min-w-0 flex-1">
                    <Link
                      href={`/app/bookings/${b.id}`}
                      className="block truncate text-[15px] font-medium text-ink hover:underline"
                    >
                      {pick(b.service, 'name', locale)}
                    </Link>
                    <span className="block truncate text-[13px] text-ink-soft">
                      {pick(b.provider, 'name', locale)}
                    </span>
                  </span>
                </li>
              ))}
            </ul>
          </Surface>
        ) : (
          <EmptyState title={ta('todayEmpty')} body={ta('todayEmptyBody')} />
        )}
      </section>

      {/* ---------------------------------------------------------- Package --- */}
      <section className="mt-8 px-5">
        <JourneyCard
          packageName={pick(journey.membership.package, 'name', locale)}
          status={journey.membership.status}
          daysLeft={journey.daysLeft}
          locale={locale}
          allowances={journey.allowances.map((a) => ({
            category: a.category,
            label: tcat(a.category),
            used: a.used,
            total: a.total,
          }))}
        />
      </section>

      {/* --------------------------------------------------------- Upcoming --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={ta('upcoming')} className="mb-3" />
        {journey.upcoming.length ? (
          <div className="space-y-3">
            {journey.upcoming.map((b) => (
              <BookingCard
                key={b.id}
                locale={locale}
                booking={{
                  id: b.id,
                  providerName: pick(b.provider, 'name', locale),
                  serviceName: pick(b.service, 'name', locale),
                  image: b.provider.image,
                  startsAt: b.startsAt,
                  status: b.status,
                  coveredByMembership: b.coveredByMembership,
                }}
              />
            ))}
          </div>
        ) : (
          <EmptyState
            title={ta('noUpcoming')}
            body={ta('noUpcomingBody')}
            action={
              <Button asChild size="md">
                <Link href="/app/explore">{ta('nextStepCta')}</Link>
              </Button>
            }
          />
        )}
      </section>
    </div>
  );
}

/* ----------------------------------------------------------- Non-member --- */

async function NonMemberJourney({
  journey,
  locale,
}: {
  journey: NonMemberOverview;
  locale: string;
}) {
  const t = await getTranslations('Journey');
  const te = await getTranslations('Journey.empty');
  const tcat = await getTranslations('Categories');
  const tgoals = await getTranslations('Onboarding.goals');

  const [feed, favorites] = await Promise.all([getHomeFeed(), getFavorites()]);
  const profile = journey.profile;

  return (
    <div className="pb-6">
      <PageTitle>{t('title')}</PageTitle>

      <section className="px-5">
        <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
          <h2 className="display text-[24px] text-ink">{te('title')}</h2>
          <p className="mt-3 text-[15px] leading-snug text-ink-soft">{te('body')}</p>

          {profile?.goals.length ? (
            <div className="mt-6">
              <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
                {te('goal')}
              </p>
              <div className="mt-2 flex flex-wrap gap-2">
                {profile.goals.map((goal) => (
                  <Badge key={goal} tone="goal" size="md">
                    {tgoals(goal)}
                  </Badge>
                ))}
              </div>
            </div>
          ) : null}

          {profile?.interests.length ? (
            <div className="mt-5">
              <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
                {te('interests')}
              </p>
              <div className="mt-2 flex flex-wrap gap-2">
                {profile.interests.map((c) => (
                  <Badge key={c} tone="neutral" size="md">
                    {tcat(c)}
                  </Badge>
                ))}
              </div>
            </div>
          ) : null}
        </Surface>
      </section>

      {/* -------------------------------------------------------- Two paths --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={te('pathTitle')} className="mb-3" />
        <div className="space-y-3">
          <Surface radius="lg" pad="lg">
            <h3 className="text-[18px] font-semibold text-ink">{te('path1')}</h3>
            <p className="mt-2 text-[14px] leading-snug text-ink-soft">{te('path1Body')}</p>
            <Button asChild variant="secondary" size="md" className="mt-4">
              <Link href="/app/explore">
                {te('path1Cta')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
          </Surface>

          <Surface tone="green" radius="lg" pad="lg" elevation="md">
            <h3 className="text-[18px] font-semibold text-white">{te('path2')}</h3>
            <p className="mt-2 text-[14px] leading-snug text-white/70">{te('path2Body')}</p>
            <Button asChild variant="onDark" size="md" className="mt-4">
              <Link href="/app/packages">
                {te('path2Cta')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
          </Surface>
        </div>
      </section>

      {/* ---------------------------------------------------- Where to start --- */}
      {feed.recommended.length ? (
        <section className="mt-8 px-5">
          <SectionHeader title={te('recommended')} className="mb-3" />
          <div className="space-y-3">
            {feed.recommended.slice(0, 3).map((p) => (
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
                }}
              />
            ))}
          </div>
        </section>
      ) : null}

      {/* ------------------------------------------------------------ Saved --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={te('saved')} className="mb-3" />
        {favorites.length ? (
          <div className="space-y-3">
            {favorites.map((p) => (
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
                }}
              />
            ))}
          </div>
        ) : (
          <EmptyState icon={<Heart aria-hidden />} title={te('noSaved')} />
        )}
      </section>
    </div>
  );
}
