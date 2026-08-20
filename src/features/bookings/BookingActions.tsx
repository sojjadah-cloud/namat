'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { CalendarClock, X } from 'lucide-react';
import { useRouter } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { BottomSheet, ConfirmSheet } from '@/components/ui/sheet';
import { useToast } from '@/components/ui/toast';
import { cancelBooking, rescheduleBooking } from '@/server/actions/booking';
import { formatDateLong, formatTime, formatWeekday, formatDayNumber } from '@/lib/format';
import { cn } from '@/lib/utils';
import type { FlowDay } from '@/features/booking/BookingFlow';

/**
 * Reschedule and cancel sit together because they are the same question asked
 * two ways — "not this time". Reschedule is offered first and styled as the
 * ordinary path; cancelling is available but never the obvious button.
 */
export function BookingActions({
  bookingId,
  days,
  cancellable,
}: {
  bookingId: string;
  days: FlowDay[];
  /** Past and already-cancelled bookings show nothing at all. */
  cancellable: boolean;
}) {
  const locale = useLocale();
  const t = useTranslations('Bookings.detail');
  const tb = useTranslations('Booking');
  const tc = useTranslations('Common');
  const router = useRouter();
  const toast = useToast();

  const [rescheduleOpen, setRescheduleOpen] = React.useState(false);
  const [cancelOpen, setCancelOpen] = React.useState(false);
  const [dayIndex, setDayIndex] = React.useState(0);
  const [slotId, setSlotId] = React.useState<string | null>(null);
  const [pending, startTransition] = React.useTransition();

  if (!cancellable) return null;

  const day = days[dayIndex];

  const doReschedule = () =>
    startTransition(async () => {
      if (!slotId) return;
      const result = await rescheduleBooking(bookingId, slotId);
      if (!result.ok) {
        toast.error(result.error === 'taken' ? tb('errorTaken') : tb('errorGeneric'));
        return;
      }
      setRescheduleOpen(false);
      toast.success(t('rescheduled'));
      router.refresh();
    });

  const doCancel = () =>
    startTransition(async () => {
      const result = await cancelBooking(bookingId);
      if (!result.ok) {
        toast.error(tb('errorGeneric'));
        return;
      }
      setCancelOpen(false);
      toast.success(t('cancelled'));
      router.refresh();
    });

  return (
    <>
      <div className="space-y-2.5">
        <Button
          block
          variant="secondary"
          size="lg"
          onClick={() => setRescheduleOpen(true)}
          disabled={!days.length}
        >
          <CalendarClock />
          {t('reschedule')}
        </Button>
        <Button block variant="danger" size="lg" onClick={() => setCancelOpen(true)}>
          <X />
          {t('cancel')}
        </Button>
      </div>

      <BottomSheet
        open={rescheduleOpen}
        onOpenChange={setRescheduleOpen}
        title={t('rescheduleTitle')}
        size="tall"
        footer={
          <Button block size="lg" disabled={!slotId} loading={pending} onClick={doReschedule}>
            {tc('confirm')}
          </Button>
        }
      >
        <div className="rail -mx-6 gap-2.5 px-6 pb-1">
          {days.map((d, i) => {
            const date = new Date(d.date);
            const open = d.times.some((s) => !s.full);
            return (
              <button
                key={d.date}
                type="button"
                disabled={!open}
                onClick={() => {
                  setDayIndex(i);
                  setSlotId(null);
                }}
                className={cn(
                  'flex h-20 w-16 flex-col items-center justify-center gap-1 rounded-md border transition-colors',
                  'disabled:opacity-35',
                  dayIndex === i
                    ? 'border-green bg-green text-white'
                    : 'border-line bg-white text-ink hover:border-sage',
                )}
              >
                <span
                  className={cn(
                    'text-[11px]',
                    dayIndex === i ? 'text-white/70' : 'text-ink-soft',
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

        {day ? (
          <>
            <p className="mt-5 text-[14px] text-ink-soft">
              {formatDateLong(new Date(day.date), locale)}
            </p>
            <div className="mt-3 grid grid-cols-3 gap-2.5 pb-4">
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
          </>
        ) : null}
      </BottomSheet>

      <ConfirmSheet
        open={cancelOpen}
        onOpenChange={setCancelOpen}
        title={t('cancelTitle')}
        body={t('cancelBody')}
        confirmLabel={t('cancelConfirm')}
        cancelLabel={t('cancelKeep')}
        onConfirm={doCancel}
        pending={pending}
      />
    </>
  );
}
