'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import { useRouter } from '@/i18n/routing';
import { OptionCard } from '@/components/ui/option';
import { Button } from '@/components/ui/button';
import { useToast } from '@/components/ui/toast';
import { updateProfile } from '@/server/actions/profile';

export const GOAL_KEYS = [
  'lose_weight',
  'eat_better',
  'more_active',
  'improve_fitness',
  'better_habits',
  'wellbeing',
  'maintain',
  'exploring',
] as const;

/**
 * Editing goals re-ranks Home, so the save confirmation says so — otherwise
 * the change looks like it did nothing until the user happens to scroll the
 * feed later.
 */
export function GoalsEditor({ initial }: { initial: string[] }) {
  const t = useTranslations('Onboarding.goals');
  const tp = useTranslations('Profile');
  const tc = useTranslations('Common');
  const router = useRouter();
  const toast = useToast();

  const [goals, setGoals] = React.useState<string[]>(initial);
  const [pending, startTransition] = React.useTransition();

  const toggle = (key: string) =>
    setGoals((prev) =>
      prev.includes(key) ? prev.filter((g) => g !== key) : [...prev, key],
    );

  const save = () =>
    startTransition(async () => {
      await updateProfile({ goals });
      toast.success(tp('saved'), tp('savedBody'));
      router.refresh();
    });

  const dirty =
    goals.length !== initial.length || goals.some((g) => !initial.includes(g));

  return (
    <div className="pb-28">
      <div className="space-y-2.5 px-5">
        {GOAL_KEYS.map((key) => (
          <OptionCard
            key={key}
            multi
            selected={goals.includes(key)}
            onSelect={() => toggle(key)}
            title={t(key)}
          />
        ))}
      </div>

      <div className="fixed inset-x-0 bottom-[calc(72px+env(safe-area-inset-bottom))] z-40 md:absolute">
        <div className="mx-auto max-w-[430px] border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
          <Button block size="lg" loading={pending} disabled={!dirty} onClick={save}>
            {tc('save')}
          </Button>
        </div>
      </div>
    </div>
  );
}
