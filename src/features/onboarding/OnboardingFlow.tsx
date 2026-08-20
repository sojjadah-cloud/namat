'use client';

import * as React from 'react';
import { AnimatePresence, motion } from 'motion/react';
import { useLocale, useTranslations } from 'next-intl';
import type { ActivityLevel, Category, TimePreference } from '@prisma/client';
import { ArrowLeft, MapPin, Sparkles } from 'lucide-react';
import { useRouter, isRtl } from '@/i18n/routing';
import { OptionCard, OptionPill, Switch } from '@/components/ui/option';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { StepProgress } from '@/components/ui/progress';
import { completeOnboarding } from '@/server/actions/profile';
import { CATEGORY_ORDER, CATEGORY_META } from '@/lib/categories';
import { slideStep } from '@/lib/motion';
import { formatNumber } from '@/lib/format';

const GOALS = [
  'lose_weight',
  'eat_better',
  'more_active',
  'improve_fitness',
  'better_habits',
  'wellbeing',
  'maintain',
  'exploring',
] as const;

const ACTIVITY: ActivityLevel[] = ['LOW', 'MODERATE', 'ACTIVE', 'VERY_ACTIVE'];
const TIMES: TimePreference[] = ['MORNING', 'AFTERNOON', 'EVENING', 'ANY'];
const DIETARY = [
  'vegetarian',
  'vegan',
  'high_protein',
  'low_carb',
  'gluten_free',
  'dairy_free',
  'no_preference',
] as const;

const STEPS = ['goals', 'interests', 'activity', 'time', 'location', 'preferences', 'done'] as const;
type Step = (typeof STEPS)[number];

/**
 * Seven screens, one question each.
 *
 * The alternative — one long form — collects the same data and teaches the
 * user nothing. Asked one at a time, each answer visibly changes what NAMAT
 * will do, and the final screen plays that back before anything is saved.
 */
export function OnboardingFlow({
  cities,
}: {
  cities: { slug: string; name: string }[];
}) {
  const locale = useLocale();
  const t = useTranslations('Onboarding');
  const tcat = useTranslations('Categories');
  const tc = useTranslations('Common');
  const router = useRouter();

  const [index, setIndex] = React.useState(0);
  const [pending, startTransition] = React.useTransition();

  const [goals, setGoals] = React.useState<string[]>([]);
  const [interests, setInterests] = React.useState<Category[]>([]);
  const [activityLevel, setActivityLevel] = React.useState<ActivityLevel>('MODERATE');
  const [timePreference, setTimePreference] = React.useState<TimePreference>('ANY');
  const [citySlug, setCitySlug] = React.useState<string | undefined>(cities[0]?.slug);
  const [dietary, setDietary] = React.useState<string[]>([]);
  const [womenOnly, setWomenOnly] = React.useState(false);

  const step: Step = STEPS[index];
  const variants = React.useMemo(() => slideStep(isRtl(locale)), [locale]);

  const toggle = <T extends string>(
    list: T[],
    setList: (next: T[]) => void,
    value: T,
  ) => setList(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);

  const toggleDietary = (d: string) =>
    setDietary((prev) =>
      // "No preference" cannot coexist with a preference.
      d === 'no_preference'
        ? prev.includes(d)
          ? []
          : [d]
        : prev.includes(d)
          ? prev.filter((x) => x !== d)
          : [...prev.filter((x) => x !== 'no_preference'), d],
    );

  const finish = () =>
    startTransition(async () => {
      await completeOnboarding({
        goals,
        interests,
        activityLevel,
        timePreference,
        dietary,
        womenOnly,
        citySlug,
      });
      router.replace('/app');
      router.refresh();
    });

  // Only the two multi-selects can be empty in a way that makes the next
  // screen meaningless; everything else has a sensible default already set.
  const canAdvance =
    step === 'goals' ? goals.length > 0 : step === 'interests' ? interests.length > 0 : true;

  return (
    <div className="flex flex-1 flex-col">
      <header className="flex items-center gap-3 px-5 pt-4 pb-2">
        <button
          type="button"
          onClick={() => setIndex((i) => Math.max(0, i - 1))}
          disabled={index === 0}
          aria-label={tc('back')}
          className="grid size-10 shrink-0 place-items-center rounded-full transition-colors hover:bg-black/[0.04] disabled:opacity-0"
        >
          <ArrowLeft className="rtl-flip size-5 text-ink" aria-hidden />
        </button>
        <span className="flex-1 text-center text-[13px] text-ink-soft">
          {t('progress', {
            current: formatNumber(index + 1, locale),
            total: formatNumber(STEPS.length, locale),
          })}
        </span>
        <span className="size-10 shrink-0" />
      </header>

      <div className="px-5">
        <StepProgress current={index + 1} total={STEPS.length} />
      </div>

      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          key={step}
          variants={variants}
          initial="enter"
          animate="center"
          exit="exit"
          className="flex-1 overflow-y-auto px-5 pt-8 pb-6"
        >
          {step === 'goals' ? (
            <Question title={t('goals.title')} body={t('goals.body')}>
              <div className="space-y-2.5">
                {GOALS.map((g) => (
                  <OptionCard
                    key={g}
                    multi
                    selected={goals.includes(g)}
                    onSelect={() => toggle(goals, setGoals, g)}
                    title={t(`goals.${g}`)}
                  />
                ))}
              </div>
            </Question>
          ) : null}

          {step === 'interests' ? (
            <Question title={t('interests.title')} body={t('interests.body')}>
              <div className="flex flex-wrap gap-2">
                {CATEGORY_ORDER.map((c) => {
                  const Icon = CATEGORY_META[c].icon;
                  return (
                    <OptionPill
                      key={c}
                      selected={interests.includes(c)}
                      onSelect={() => toggle(interests, setInterests, c)}
                      icon={<Icon aria-hidden />}
                    >
                      {tcat(c)}
                    </OptionPill>
                  );
                })}
              </div>
            </Question>
          ) : null}

          {step === 'activity' ? (
            <Question title={t('activity.title')} body={t('activity.body')}>
              <div className="space-y-2.5">
                {ACTIVITY.map((a) => (
                  <OptionCard
                    key={a}
                    selected={activityLevel === a}
                    onSelect={() => setActivityLevel(a)}
                    title={t(`activity.${a}`)}
                    description={t(`activity.${a}_desc`)}
                  />
                ))}
              </div>
            </Question>
          ) : null}

          {step === 'time' ? (
            <Question title={t('time.title')} body={t('time.body')}>
              <div className="space-y-2.5">
                {TIMES.map((time) => (
                  <OptionCard
                    key={time}
                    selected={timePreference === time}
                    onSelect={() => setTimePreference(time)}
                    title={t(`time.${time}`)}
                    description={t(`time.${time}_desc`)}
                  />
                ))}
              </div>
            </Question>
          ) : null}

          {step === 'location' ? (
            <Question title={t('location.title')} body={t('location.body')}>
              <p className="mb-3 text-[13px] font-medium uppercase tracking-[0.14em] text-ink-soft">
                {t('location.chooseCity')}
              </p>
              <div className="space-y-2.5">
                {cities.map((c) => (
                  <OptionCard
                    key={c.slug}
                    selected={citySlug === c.slug}
                    onSelect={() => setCitySlug(c.slug)}
                    title={c.name}
                    icon={<MapPin aria-hidden />}
                  />
                ))}
              </div>
            </Question>
          ) : null}

          {step === 'preferences' ? (
            <Question title={t('preferences.title')} body={t('preferences.body')}>
              <p className="mb-3 text-[13px] font-medium uppercase tracking-[0.14em] text-ink-soft">
                {t('preferences.dietary')}
              </p>
              <div className="flex flex-wrap gap-2">
                {DIETARY.map((d) => (
                  <OptionPill
                    key={d}
                    selected={dietary.includes(d)}
                    onSelect={() => toggleDietary(d)}
                  >
                    {t(`preferences.${d}`)}
                  </OptionPill>
                ))}
              </div>

              <Surface radius="lg" pad="lg" className="mt-6">
                <Switch
                  id="women-only"
                  checked={womenOnly}
                  onCheckedChange={setWomenOnly}
                  label={t('preferences.womenOnly')}
                />
              </Surface>
            </Question>
          ) : null}

          {step === 'done' ? (
            <div className="pt-4 text-center">
              <span className="mx-auto grid size-16 place-items-center rounded-full bg-green-soft text-green">
                <Sparkles className="size-7" aria-hidden />
              </span>
              <h1 className="display mt-6 text-[30px] text-ink text-balance">
                {t('done.title')}
              </h1>
              <p className="mt-3 text-[15px] leading-snug text-ink-soft">{t('done.body')}</p>

              {/* Play back what we heard — the summary is the proof that the
                  seven questions were not busywork. */}
              <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none" className="mt-8 text-start">
                <Summary label={t('done.summaryGoal')}>
                  {goals.map((g) => (
                    <Badge key={g} tone="goal" size="md">
                      {t(`goals.${g}`)}
                    </Badge>
                  ))}
                </Summary>
                <Summary label={t('done.summaryInterests')} className="mt-5">
                  {interests.map((c) => (
                    <Badge key={c} tone="neutral" size="md">
                      {tcat(c)}
                    </Badge>
                  ))}
                </Summary>
                {citySlug ? (
                  <Summary label={t('done.summaryCity')} className="mt-5">
                    <Badge tone="neutral" size="md">
                      {cities.find((c) => c.slug === citySlug)?.name}
                    </Badge>
                  </Summary>
                ) : null}
              </Surface>
            </div>
          ) : null}
        </motion.div>
      </AnimatePresence>

      <div className="safe-bottom border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
        {step === 'done' ? (
          <Button block size="xl" loading={pending} onClick={finish}>
            {t('done.cta')}
          </Button>
        ) : (
          <div className="flex items-center gap-3">
            <Button
              block
              size="xl"
              disabled={!canAdvance}
              onClick={() => setIndex((i) => i + 1)}
            >
              {tc('next')}
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}

function Question({
  title,
  body,
  children,
}: {
  title: string;
  body: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <h1 className="display text-[27px] text-ink text-balance">{title}</h1>
      <p className="mt-2.5 text-[15px] leading-snug text-ink-soft">{body}</p>
      <div className="mt-7">{children}</div>
    </div>
  );
}

function Summary({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={className}>
      <p className="text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
        {label}
      </p>
      <div className="mt-2 flex flex-wrap gap-2">{children}</div>
    </div>
  );
}
