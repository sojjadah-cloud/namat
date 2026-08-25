import { notFound } from 'next/navigation';
import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { Users, Clock, Sparkles, Check } from 'lucide-react';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface } from '@/components/ui/card';
import { ProgressTrack } from '@/components/ui/ring';
import { DailyTask } from '@/features/challenges/DailyTask';
import { JoinButton } from '@/features/challenges/JoinButton';
import { getChallenge } from '@/server/queries/challenges';
import { CHALLENGE_META } from '@/lib/challenge-meta';
import { formatNumber } from '@/lib/format';
import { pick, pickList } from '@/lib/localized';

/**
 * One challenge.
 *
 * Before joining it argues the case: what it asks, how long, who else is in.
 * After joining that argument is settled, so today's task takes the top of the
 * screen and the rules move below it.
 */
export default async function ChallengeDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const locale = await getLocale();
  const t = await getTranslations('Challenges');

  const challenge = await getChallenge(slug);
  if (!challenge) notFound();

  const meta = CHALLENGE_META[challenge.kind];
  const Icon = meta.icon;
  const { progress } = challenge;
  const joined = Boolean(challenge.enrollment);
  const finished = joined && progress ? progress.completedDays >= challenge.durationDays : false;

  return (
    <div>
      <BackBar />

      {/* ----------------------------------------------------------- hero --- */}
      <div className="relative mx-5 aspect-[16/9] overflow-hidden rounded-xl">
        <Image
          src={challenge.image}
          alt=""
          fill
          priority
          sizes="(max-width: 430px) 100vw, 430px"
          className="object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-ink/70 to-transparent" />
        <span className={`absolute top-3 grid size-10 place-items-center rounded-full bg-white/95 start-3 ${meta.fg}`}>
          <Icon className="size-5" strokeWidth={2} aria-hidden />
        </span>
      </div>

      <div className="px-5">
        <div className="mt-4 flex flex-wrap items-center gap-2 text-[12px] text-ink-soft">
          <span className={`rounded-full px-2.5 py-1 font-medium ${meta.bg} ${meta.fg}`}>
            {t(`kind${challenge.kind}`)}
          </span>
          <span>·</span>
          <span>{t(`level${challenge.level}`)}</span>
        </div>

        <h1 className="display mt-3 text-[28px] text-ink">
          {pick(challenge, 'title', locale)}
        </h1>
        <p className="mt-2.5 text-[15px] leading-relaxed text-ink-soft">
          {pick(challenge, 'summary', locale)}
        </p>

        <div className="mt-5 grid grid-cols-3 gap-3">
          <Fact
            icon={<Clock aria-hidden />}
            value={t('duration', { days: formatNumber(challenge.durationDays, locale) })}
          />
          <Fact
            icon={<Users aria-hidden />}
            value={formatNumber(challenge.participants, locale)}
          />
          <Fact
            icon={<Sparkles aria-hidden />}
            value={t('reward', { points: formatNumber(challenge.rewardPoints, locale) })}
          />
        </div>
      </div>

      {/* --------------------------------------------------- today's task --- */}
      {joined && progress && !finished ? (
        <section className="mt-7 px-5">
          <Surface radius="xl" pad="xl" elevation="sm">
            <p className="text-center text-[13px] font-medium text-ink-soft">
              {t('dayOf', {
                current: formatNumber(progress.day, locale),
                total: formatNumber(challenge.durationDays, locale),
              })}
            </p>
            <div className="mt-1.5">
              <ProgressTrack
                value={progress.completedDays}
                max={challenge.durationDays}
                label={t('dayOf', {
                  current: formatNumber(progress.day, locale),
                  total: formatNumber(challenge.durationDays, locale),
                })}
              />
            </div>

            {progress.task ? (
              <div className="mt-7">
                <DailyTask
                  slug={challenge.slug}
                  kind={progress.task.kind}
                  title={pick(progress.task, 'title', locale)}
                  unit={pick(progress.task, 'unit', locale)}
                  target={progress.target}
                  initialAmount={progress.amount}
                  initialDone={progress.todayDone}
                />
              </div>
            ) : null}
          </Surface>
        </section>
      ) : null}

      {finished ? (
        <section className="mt-7 px-5">
          <Surface radius="xl" pad="xl" elevation="sm" className="text-center">
            <span className="mx-auto grid size-16 place-items-center rounded-full bg-green text-white">
              <Check className="size-8" strokeWidth={2.2} aria-hidden />
            </span>
            <h2 className="mt-5 text-[21px] font-semibold text-ink">{t('allDone')}</h2>
            <p className="mt-2 text-[15px] text-ink-soft">{t('allDoneBody')}</p>
          </Surface>
        </section>
      ) : null}

      {/* ---------------------------------------------------------- rules --- */}
      <section className="mt-8 px-5">
        <h2 className="text-[13px] font-medium tracking-[0.02em] text-ink-soft">
          {t('rules')}
        </h2>
        <ul className="mt-3 space-y-3">
          {pickList(challenge, 'rules', locale).map((rule) => (
            <li key={rule} className="flex gap-3">
              <span
                className="mt-2 size-1.5 shrink-0 rounded-full"
                style={{ backgroundColor: meta.hex }}
                aria-hidden
              />
              <span className="text-[15px] leading-relaxed text-ink">{rule}</span>
            </li>
          ))}
        </ul>
      </section>

      {/* --------------------------------------------------- sticky action ---
          Sticky rather than fixed, and the last thing in the flow, so it
          reserves its own space instead of covering the rules underneath it. */}
      <div className="above-nav sticky z-40 mt-8 border-t border-line bg-canvas/95 px-5 pt-3 pb-3 backdrop-blur-xl">
        <JoinButton slug={challenge.slug} joined={joined} />
      </div>
    </div>
  );
}

function Fact({ icon, value }: { icon: React.ReactNode; value: string }) {
  return (
    <div className="rounded-md bg-warm-soft px-3 py-3 text-center">
      <span className="mx-auto grid size-5 place-items-center text-ink-soft [&_svg]:size-4">
        {icon}
      </span>
      <p className="mt-1.5 text-[13px] font-medium text-ink">{value}</p>
    </div>
  );
}
