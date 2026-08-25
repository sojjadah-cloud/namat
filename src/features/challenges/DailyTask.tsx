'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { Check, Minus, Plus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ProgressRing } from '@/components/ui/ring';
import { logProgress, completeToday } from '@/server/actions/challenges';
import { formatNumber } from '@/lib/format';
import { cn } from '@/lib/utils';

/**
 * Today's goal, and the only interactive part of a challenge.
 *
 * The amount is held locally and pushed as an absolute value, so a member can
 * tap the stepper five times quickly without five racing requests each adding
 * one. The server takes the last number it is told, which is also what makes a
 * retried request harmless.
 */
export function DailyTask({
  slug,
  kind,
  title,
  unit,
  target,
  initialAmount,
  initialDone,
}: {
  slug: string;
  kind: 'COUNT' | 'CHECK';
  title: string;
  unit: string;
  target: number;
  initialAmount: number;
  initialDone: boolean;
}) {
  const t = useTranslations('Challenges');
  const locale = useLocale();

  const [amount, setAmount] = React.useState(initialAmount);
  const [done, setDone] = React.useState(initialDone);
  const [pending, startTransition] = React.useTransition();

  // One step is a twentieth of the goal, rounded to something a person would
  // actually say: 500 steps, not 500.0; 1 glass, not 0.4 of one.
  const step = React.useMemo(() => {
    if (target <= 20) return 1;
    const raw = target / 20;
    const magnitude = 10 ** Math.floor(Math.log10(raw));
    return Math.max(1, Math.round(raw / magnitude) * magnitude);
  }, [target]);

  const commit = (next: number) => {
    const clamped = Math.max(0, Math.min(target, next));
    setAmount(clamped);
    startTransition(async () => {
      const result = await logProgress(slug, clamped);
      if (result.ok) setDone(result.data.completed);
    });
  };

  const tick = () => {
    setDone(true);
    startTransition(async () => {
      const result = await completeToday(slug);
      // The server is the authority: if it refused, put the tick back.
      if (!result.ok) setDone(false);
    });
  };

  if (kind === 'CHECK') {
    return (
      <div className="text-center">
        <p className="text-[15px] text-ink-soft">{t('todayGoal')}</p>
        <p className="mt-2 text-[22px] font-semibold text-ink text-balance">{title}</p>

        <button
          type="button"
          onClick={tick}
          disabled={done || pending}
          aria-pressed={done}
          className={cn(
            'mx-auto mt-8 grid size-32 place-items-center rounded-full transition-all duration-300 ease-[var(--ease-namat)]',
            done
              ? 'bg-green text-white shadow-[var(--shadow-md)]'
              : 'bg-green-soft text-green active:scale-95 hover:bg-green/15',
          )}
        >
          <Check className={cn('transition-all', done ? 'size-14' : 'size-12')} strokeWidth={2.2} aria-hidden />
        </button>

        <p className="mt-6 min-h-6 text-[15px] font-medium text-green">
          {done ? t('doneToday') : ''}
        </p>

        {!done ? (
          <Button size="lg" block loading={pending} onClick={tick} className="mt-2">
            {t('markDone')}
          </Button>
        ) : null}
      </div>
    );
  }

  return (
    <div className="text-center">
      <p className="text-[15px] text-ink-soft">{t('todayGoal')}</p>
      <p className="mt-2 text-[22px] font-semibold text-ink text-balance">{title}</p>

      <ProgressRing value={amount} max={target} size="xl" className="mx-auto mt-8">
        <span className="leading-tight">
          <span className="block text-[30px] font-semibold text-ink">
            {formatNumber(amount, locale)}
          </span>
          <span className="block text-[13px] text-ink-soft">
            {formatNumber(target, locale)} {unit}
          </span>
        </span>
      </ProgressRing>

      <div className="mt-8 flex items-center justify-center gap-5">
        <StepButton
          onClick={() => commit(amount - step)}
          disabled={amount <= 0 || pending}
          label={`-${step}`}
        >
          <Minus className="size-5" aria-hidden />
        </StepButton>

        <span className="min-w-24 text-[15px] text-ink-soft">
          {formatNumber(step, locale)} {unit}
        </span>

        <StepButton
          onClick={() => commit(amount + step)}
          disabled={amount >= target || pending}
          label={`+${step}`}
        >
          <Plus className="size-5" aria-hidden />
        </StepButton>
      </div>

      <p className="mt-6 min-h-6 text-[15px] font-medium text-green">
        {done ? t('doneToday') : ''}
      </p>

      {!done ? (
        <Button size="lg" block loading={pending} onClick={() => commit(target)} className="mt-2">
          {t('markDone')}
        </Button>
      ) : null}
    </div>
  );
}

function StepButton({
  children,
  onClick,
  disabled,
  label,
}: {
  children: React.ReactNode;
  onClick: () => void;
  disabled: boolean;
  label: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      aria-label={label}
      className="grid size-12 place-items-center rounded-full border border-line bg-surface text-ink transition-transform active:scale-90 disabled:opacity-35"
    >
      {children}
    </button>
  );
}
