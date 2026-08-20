'use client';

import * as React from 'react';
import { AnimatePresence, motion } from 'motion/react';
import { useLocale, useTranslations } from 'next-intl';
import { CreditCard, Sparkles } from 'lucide-react';
import { useRouter } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';
import { StepProgress } from '@/components/ui/progress';
import { EmptyState, ErrorState } from '@/components/ui/feedback';
import { createBooking } from '@/server/actions/booking';
import {
  formatPrice,
  formatDuration,
  formatDateLong,
  formatWeekday,
  formatDayNumber,
  formatTime,
  formatNumber,
} from '@/lib/format';
import { slideStep } from '@/lib/motion';
import { isRtl } from '@/i18n/routing';
import { cn } from '@/lib/utils';

/**
 * Date → time → review → confirm.
 *
 * One decision per screen. The steps slide in the reading direction so going
 * forward and going back feel like moving through a place rather than swapping
 * a panel; RTL reverses the axis, which is why `slideStep` takes the direction.
 */

export type FlowDay = {
  date: string;
  times: { id: string; startsAt: string; full: boolean }[];
};

export type FlowService = {
  id: string;
  name: string;
  description: string | null;
  duration: number | null;
  price: number;
  included: boolean;
  providerName: string;
  providerAddress: string;
};

type Step = 'date' | 'time' | 'review';
const STEPS: Step[] = ['date', 'time', 'review'];

export function BookingFlow({
  service,
  days,
  allowanceUsed,
  allowanceTotal,
}: {
  service: FlowService;
  days: FlowDay[];
  allowanceUsed?: number;
  allowanceTotal?: number;
}) {
  const locale = useLocale();
  const t = useTranslations('Booking');
  const tc = useTranslations('Common');
  const tp = useTranslations('Provider');
  const router = useRouter();

  const [step, setStep] = React.useState<Step>('date');
  const [dayIndex, setDayIndex] = React.useState<number | null>(null);
  const [slotId, setSlotId] = React.useState<string | null>(null);
  const [error, setError] = React.useState<string | null>(null);
  const [pending, startTransition] = React.useTransition();

  const variants = React.useMemo(() => slideStep(isRtl(locale)), [locale]);
  const stepNumber = STEPS.indexOf(step) + 1;

  const day = dayIndex != null ? days[dayIndex] : null;
  const slot = day?.times.find((s) => s.id === slotId) ?? null;

  const confirm = () =>
    startTransition(async () => {
      if (!slotId) return;
      setError(null);
      const result = await createBooking(slotId);

      if (!result.ok) {
        setError(result.error === 'taken' ? t('errorTaken') : t('errorGeneric'));
        // The seat is gone — send them back to pick another rather than
        // leaving a dead Confirm button on screen.
        if (result.error === 'taken') {
          setSlotId(null);
          setStep('time');
        }
        return;
      }

      router.replace(`/app/bookings/${result.bookingId}?new=1`);
      router.refresh();
    });

  if (!days.length) {
    return (
      <div className="px-5 pt-6">
        <EmptyState title={t('noTimes')} body={t('noTimesBody')} />
      </div>
    );
  }

  return (
    <div className="pb-32">
      <div className="px-5">
        <StepProgress current={stepNumber} total={STEPS.length} />
        <p className="mt-3 text-[12px] font-medium uppercase tracking-[0.14em] text-ink-soft">
          {t(step === 'date' ? 'stepDate' : step === 'time' ? 'stepTime' : 'stepReview')}
        </p>
      </div>

      <AnimatePresence mode="wait" initial={false}>
        <motion.div
          key={step}
          variants={variants}
          initial="enter"
          animate="center"
          exit="exit"
          className="mt-5"
        >
          {step === 'date' ? (
            <section className="px-5">
              <h2 className="text-[22px] font-semibold text-ink">{t('chooseDate')}</h2>
              <div className="rail -mx-5 mt-5 gap-2.5 px-5">
                {days.map((d, i) => {
                  const date = new Date(d.date);
                  const open = d.times.some((s) => !s.full);
                  const selected = dayIndex === i;
                  return (
                    <button
                      key={d.date}
                      type="button"
                      disabled={!open}
                      onClick={() => {
                        setDayIndex(i);
                        setSlotId(null);
                        setStep('time');
                      }}
                      className={cn(
                        'flex h-20 w-16 flex-col items-center justify-center gap-1 rounded-md border transition-colors',
                        'disabled:opacity-35',
                        selected
                          ? 'border-green bg-green text-white'
                          : 'border-line bg-white text-ink hover:border-sage',
                      )}
                    >
                      <span
                        className={cn(
                          'text-[11px]',
                          selected ? 'text-white/70' : 'text-ink-soft',
                        )}
                      >
                        {formatWeekday(date, locale)}
                      </span>
                      <span className="text-[19px] font-semibold tabular-nums">
                        {formatDayNumber(date, locale)}
                      </span>
                    </button>
                  );
                })}
              </div>
            </section>
          ) : null}

          {step === 'time' && day ? (
            <section className="px-5">
              <h2 className="text-[22px] font-semibold text-ink">{t('chooseTime')}</h2>
              <p className="mt-1.5 text-[14px] text-ink-soft">
                {formatDateLong(new Date(day.date), locale)}
              </p>

              {day.times.some((s) => !s.full) ? (
                <div className="mt-5 grid grid-cols-3 gap-2.5">
                  {day.times.map((s) => (
                    <button
                      key={s.id}
                      type="button"
                      disabled={s.full}
                      onClick={() => setSlotId(s.id)}
                      className={cn(
                        'h-12 rounded-sm border text-[15px] font-medium tabular-nums transition-colors',
                        'disabled:opacity-35 disabled:line-through',
                        slotId === s.id
                          ? 'border-green bg-green text-white'
                          : 'border-line bg-white text-ink hover:border-sage',
                      )}
                    >
                      {formatTime(new Date(s.startsAt), locale)}
                    </button>
                  ))}
                </div>
              ) : (
                <div className="mt-5">
                  <EmptyState title={t('noTimes')} body={t('noTimesBody')} />
                </div>
              )}
            </section>
          ) : null}

          {step === 'review' && slot && day ? (
            <section className="px-5">
              <h2 className="text-[22px] font-semibold text-ink">{t('review')}</h2>

              <Surface radius="lg" pad="lg" className="mt-5">
                <div className="divide-y divide-line">
                  <Row label={t('provider')} value={service.providerName} />
                  <Row label={t('service')} value={service.name} />
                  <Row
                    label={t('date')}
                    value={formatDateLong(new Date(day.date), locale)}
                  />
                  <Row
                    label={t('time')}
                    value={formatTime(new Date(slot.startsAt), locale)}
                  />
                  {service.duration ? (
                    <Row
                      label={t('duration')}
                      value={formatDuration(service.duration, locale)}
                    />
                  ) : null}
                  <Row label={t('location')} value={service.providerAddress} />
                </div>
              </Surface>

              {/* Payment: the membership case is celebrated, not merely applied. */}
              {service.included ? (
                <Surface tone="greenSoft" radius="lg" pad="lg" elevation="none" className="mt-4">
                  <p className="flex items-center gap-2 text-[15px] font-semibold text-green">
                    <Sparkles className="size-4" aria-hidden />
                    {t('paymentPackage')}
                  </p>
                  {allowanceTotal ? (
                    <p className="mt-1.5 text-[13px] text-ink-soft">
                      {t('packageRemaining', {
                        used: formatNumber((allowanceUsed ?? 0) + 1, locale),
                        total: formatNumber(allowanceTotal, locale),
                      })}
                    </p>
                  ) : null}
                </Surface>
              ) : (
                <Surface radius="lg" pad="lg" className="mt-4">
                  <div className="flex items-center justify-between gap-4">
                    <p className="flex items-center gap-2.5 text-[14px] text-ink-soft">
                      <CreditCard className="size-4" aria-hidden />
                      {t('paymentCard')}
                    </p>
                    <p className="text-[19px] font-semibold text-ink">
                      {formatPrice(service.price, locale)}
                    </p>
                  </div>
                </Surface>
              )}

              <Surface tone="warmSoft" radius="md" pad="md" elevation="none" className="mt-4">
                <p className="text-[12px] font-medium uppercase tracking-[0.14em] text-ink-soft">
                  {t('policyTitle')}
                </p>
                <p className="mt-2 text-[13px] leading-snug text-ink-soft">
                  {tp('policy')}
                </p>
              </Surface>

              {error ? (
                <ErrorState className="mt-4" title={error} />
              ) : null}
            </section>
          ) : null}
        </motion.div>
      </AnimatePresence>

      {/* ------------------------------------------------------- Action bar --- */}
      <div className="fixed inset-x-0 bottom-[calc(72px+env(safe-area-inset-bottom))] z-40 md:absolute">
        <div className="mx-auto flex max-w-[430px] items-center gap-3 border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
          {step !== 'date' ? (
            <Button
              variant="secondary"
              size="lg"
              onClick={() => setStep(step === 'review' ? 'time' : 'date')}
            >
              {tc('back')}
            </Button>
          ) : null}

          {step === 'time' ? (
            <Button block size="lg" disabled={!slotId} onClick={() => setStep('review')}>
              {tc('continue')}
            </Button>
          ) : null}

          {step === 'review' ? (
            <Button block size="lg" loading={pending} onClick={confirm}>
              {pending ? t('confirming') : t('confirm')}
            </Button>
          ) : null}

          {step === 'date' ? (
            <div className="flex-1">
              <p className="text-[13px] text-ink-soft">{service.name}</p>
              <p className="text-[15px] font-semibold text-ink">
                {service.included ? (
                  <Badge tone="included" size="md">
                    {t('packageBenefit')}
                  </Badge>
                ) : (
                  formatPrice(service.price, locale)
                )}
              </p>
            </div>
          ) : null}
        </div>
      </div>
    </div>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-baseline justify-between gap-6 py-3">
      <span className="shrink-0 text-[14px] text-ink-soft">{label}</span>
      <span className="text-end text-[14px] font-medium text-ink">{value}</span>
    </div>
  );
}
