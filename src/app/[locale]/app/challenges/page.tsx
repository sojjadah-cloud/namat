import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Flame, Sparkles } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { PageTitle } from '@/components/layout/AppHeader';
import { Surface } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ProgressRing } from '@/components/ui/ring';
import { EmptyState } from '@/components/ui/feedback';
import { ChallengeCard } from '@/components/cards/ChallengeCard';
import { KindFilter } from '@/features/challenges/KindFilter';
import {
  listChallenges,
  getActiveChallenge,
  getStreak,
  getPointsBalance,
} from '@/server/queries/challenges';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * Challenges lead with the one you are already doing, because that is the tap
 * you came for. Discovery sits underneath it — you only browse for a new
 * challenge once today's is dealt with.
 */
export default async function ChallengesPage({
  searchParams,
}: {
  searchParams: Promise<{ kind?: string }>;
}) {
  const { kind } = await searchParams;
  const locale = await getLocale();
  const t = await getTranslations('Challenges');

  const [challenges, active, streak, points] = await Promise.all([
    listChallenges(),
    getActiveChallenge(),
    getStreak(),
    getPointsBalance(),
  ]);

  const filtered =
    kind && kind !== 'all' ? challenges.filter((c) => c.kind === kind) : challenges;

  return (
    <div className="pb-6">
      <PageTitle>{t('title')}</PageTitle>

      {/* ------------------------------------------------- streak + points --- */}
      <div className="mt-1 grid grid-cols-2 gap-3 px-5">
        <Surface tone="warmSoft" radius="md" pad="md" elevation="none">
          <span className="inline-flex items-center gap-1.5 text-[13px] text-ink-soft">
            <Flame className="size-4 text-cat-fitness" aria-hidden />
            {t('streak')}
          </span>
          <p className="mt-1 text-[22px] font-semibold text-ink">
            {t('streakDays', { days: formatNumber(streak, locale) })}
          </p>
        </Surface>

        <Surface tone="warmSoft" radius="md" pad="md" elevation="none">
          <span className="inline-flex items-center gap-1.5 text-[13px] text-ink-soft">
            <Sparkles className="size-4 text-accent" aria-hidden />
            {t('points')}
          </span>
          <p className="mt-1 text-[22px] font-semibold text-ink">
            {formatNumber(points, locale)}
          </p>
        </Surface>
      </div>

      {/* ----------------------------------------------- the active one --- */}
      {active ? (
        <section className="mt-6 px-5">
          <h2 className="text-[13px] font-medium tracking-[0.02em] text-ink-soft">
            {t('active')}
          </h2>

          <Surface
            radius="xl"
            pad="lg"
            elevation="md"
            className="mt-3 bg-green-deep text-white"
          >
            <div className="flex items-center gap-5">
              <ProgressRing
                value={active.progress.completedDays}
                max={active.enrollment.challenge.durationDays}
                size="lg"
                tone="onDark"
                label={t('dayOf', {
                  current: formatNumber(active.progress.day, locale),
                  total: formatNumber(active.enrollment.challenge.durationDays, locale),
                })}
              >
                <span className="text-center leading-tight">
                  <span className="block text-[26px] font-semibold">
                    {formatNumber(active.progress.day, locale)}
                  </span>
                  <span className="block text-[11px] text-white/60">
                    {formatNumber(active.enrollment.challenge.durationDays, locale)}
                  </span>
                </span>
              </ProgressRing>

              <div className="min-w-0 flex-1">
                <h3 className="text-[19px] font-semibold">
                  {pick(active.enrollment.challenge, 'title', locale)}
                </h3>
                {active.progress.task ? (
                  <p className="mt-1.5 text-[14px] leading-snug text-white/70">
                    {t('progressOf', {
                      current: formatNumber(active.progress.amount, locale),
                      total: formatNumber(active.progress.target, locale),
                      unit: pick(active.progress.task, 'unit', locale),
                    })}
                  </p>
                ) : null}
              </div>
            </div>

            <Button asChild variant="onDark" size="lg" block className="mt-5">
              <Link href={`/app/challenges/${active.enrollment.challenge.slug}`}>
                {active.progress.todayDone ? t('continueCta') : t('todayTask')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
          </Surface>
        </section>
      ) : null}

      {/* -------------------------------------------------------- explore --- */}
      <section className="mt-8">
        <h2 className="px-5 text-[13px] font-medium tracking-[0.02em] text-ink-soft">
          {t('explore')}
        </h2>

        <KindFilter active={kind ?? 'all'} />

        <div className="mt-4 space-y-4 px-5">
          {filtered.length === 0 ? (
            <EmptyState title={t('emptyTitle')} />
          ) : (
            filtered.map((c) => (
              <ChallengeCard
                key={c.slug}
                locale={locale}
                challenge={{
                  slug: c.slug,
                  title: pick(c, 'title', locale),
                  summary: pick(c, 'summary', locale),
                  image: c.image,
                  kind: c.kind,
                  level: c.level,
                  durationDays: c.durationDays,
                  rewardPoints: c.rewardPoints,
                  participants: c.participants,
                  joined: c.joined,
                }}
              />
            ))
          )}
        </div>
      </section>
    </div>
  );
}
