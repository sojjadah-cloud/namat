'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import type { ActivityLevel, Category, TimePreference } from '@prisma/client';
import { useRouter } from '@/i18n/routing';
import { OptionCard, OptionPill, Switch } from '@/components/ui/option';
import { Button } from '@/components/ui/button';
import { SectionHeader, Surface } from '@/components/ui/card';
import { useToast } from '@/components/ui/toast';
import { updateProfile } from '@/server/actions/profile';
import { CATEGORY_ORDER, CATEGORY_META } from '@/lib/categories';

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

export type PreferenceState = {
  interests: Category[];
  activityLevel: ActivityLevel;
  timePreference: TimePreference;
  dietary: string[];
  womenOnly: boolean;
  citySlug?: string;
};

/**
 * Everything onboarding asked, in one screen, editable forever. The order
 * matches onboarding so returning here feels like revisiting the same
 * conversation rather than meeting a settings panel.
 */
export function PreferencesEditor({
  initial,
  cities,
}: {
  initial: PreferenceState;
  cities: { slug: string; name: string }[];
}) {
  const t = useTranslations('Onboarding');
  const tcat = useTranslations('Categories');
  const tp = useTranslations('Profile');
  const tc = useTranslations('Common');
  const router = useRouter();
  const toast = useToast();

  const [state, setState] = React.useState<PreferenceState>(initial);
  const [pending, startTransition] = React.useTransition();

  const set = <K extends keyof PreferenceState>(key: K, value: PreferenceState[K]) =>
    setState((prev) => ({ ...prev, [key]: value }));

  const toggleInterest = (c: Category) =>
    set(
      'interests',
      state.interests.includes(c)
        ? state.interests.filter((i) => i !== c)
        : [...state.interests, c],
    );

  const toggleDietary = (d: string) =>
    set(
      'dietary',
      // "No preference" is exclusive — holding it alongside "vegan" is nonsense.
      d === 'no_preference'
        ? state.dietary.includes(d)
          ? []
          : [d]
        : state.dietary.includes(d)
          ? state.dietary.filter((x) => x !== d)
          : [...state.dietary.filter((x) => x !== 'no_preference'), d],
    );

  const save = () =>
    startTransition(async () => {
      await updateProfile(state);
      toast.success(tp('saved'), tp('savedBody'));
      router.refresh();
    });

  return (
    <div className="pb-28">
      {/* ------------------------------------------------------- Interests --- */}
      <section className="px-5">
        <SectionHeader title={tp('interests')} className="mb-3" />
        <div className="flex flex-wrap gap-2">
          {CATEGORY_ORDER.map((c) => {
            const Icon = CATEGORY_META[c].icon;
            return (
              <OptionPill
                key={c}
                selected={state.interests.includes(c)}
                onSelect={() => toggleInterest(c)}
                icon={<Icon aria-hidden />}
              >
                {tcat(c)}
              </OptionPill>
            );
          })}
        </div>
      </section>

      {/* -------------------------------------------------------- Activity --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={tp('activity')} className="mb-3" />
        <div className="space-y-2.5">
          {ACTIVITY.map((level) => (
            <OptionCard
              key={level}
              selected={state.activityLevel === level}
              onSelect={() => set('activityLevel', level)}
              title={t(`activity.${level}`)}
              description={t(`activity.${level}_desc`)}
            />
          ))}
        </div>
      </section>

      {/* ----------------------------------------------------------- Times --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={tp('times')} className="mb-3" />
        <div className="space-y-2.5">
          {TIMES.map((time) => (
            <OptionCard
              key={time}
              selected={state.timePreference === time}
              onSelect={() => set('timePreference', time)}
              title={t(`time.${time}`)}
              description={t(`time.${time}_desc`)}
            />
          ))}
        </div>
      </section>

      {/* ---------------------------------------------------------- Dietary --- */}
      <section className="mt-8 px-5">
        <SectionHeader title={tp('food')} className="mb-3" />
        <div className="flex flex-wrap gap-2">
          {DIETARY.map((d) => (
            <OptionPill
              key={d}
              selected={state.dietary.includes(d)}
              onSelect={() => toggleDietary(d)}
            >
              {t(`preferences.${d}`)}
            </OptionPill>
          ))}
        </div>
      </section>

      {/* ------------------------------------------------------------- City --- */}
      {cities.length ? (
        <section className="mt-8 px-5">
          <SectionHeader title={tp('locations')} className="mb-3" />
          <div className="flex flex-wrap gap-2">
            {cities.map((c) => (
              <OptionPill
                key={c.slug}
                selected={state.citySlug === c.slug}
                onSelect={() => set('citySlug', c.slug)}
              >
                {c.name}
              </OptionPill>
            ))}
          </div>
        </section>
      ) : null}

      {/* -------------------------------------------------------- Women-only --- */}
      <section className="mt-8 px-5">
        <Surface radius="lg" pad="lg">
          <Switch
            id="women-only"
            checked={state.womenOnly}
            onCheckedChange={(v) => set('womenOnly', v)}
            label={t('preferences.womenOnly')}
          />
        </Surface>
      </section>

      <div className="fixed inset-x-0 bottom-[calc(72px+env(safe-area-inset-bottom))] z-40 md:absolute">
        <div className="mx-auto max-w-[430px] border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
          <Button block size="lg" loading={pending} onClick={save}>
            {tc('save')}
          </Button>
        </div>
      </div>
    </div>
  );
}
