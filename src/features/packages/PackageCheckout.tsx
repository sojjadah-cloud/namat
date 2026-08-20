'use client';

import * as React from 'react';
import { useRouter } from '@/i18n/routing';
import { useLocale, useTranslations } from 'next-intl';
import { CreditCard, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { BottomSheet } from '@/components/ui/sheet';
import { useToast } from '@/components/ui/toast';
import { formatNumber } from '@/lib/format';
import { startMembership } from '@/server/actions/membership';

/**
 * Checkout is a review sheet, not a form: there is one price, one method and
 * one decision. Anything that looks like data entry here reads as friction on
 * a screen whose only job is to say yes.
 */
export function PackageCheckout({
  slug,
  packageName,
  priceLabel,
  periodDays,
  startsLabel,
  renewsLabel,
}: {
  slug: string;
  packageName: string;
  priceLabel: string;
  periodDays: number;
  startsLabel: string;
  renewsLabel: string;
}) {
  const locale = useLocale();
  const t = useTranslations('Packages');
  const tc = useTranslations('Common');
  const tb = useTranslations('Booking');
  const router = useRouter();
  const toast = useToast();

  const [open, setOpen] = React.useState(false);
  const [pending, startTransition] = React.useTransition();

  const confirm = () =>
    startTransition(async () => {
      const result = await startMembership(slug);
      if (!result.ok) {
        toast.error(t('checkout.title'), tc('retry'));
        return;
      }
      setOpen(false);
      router.push('/app/journey');
      router.refresh();
    });

  const row = (label: string, value: string) => (
    <div className="flex items-baseline justify-between gap-4 py-2.5">
      <span className="text-[14px] text-ink-soft">{label}</span>
      <span className="text-[14px] font-medium text-ink">{value}</span>
    </div>
  );

  return (
    <>
      <div className="fixed inset-x-0 bottom-[calc(72px+env(safe-area-inset-bottom))] z-40 md:absolute">
        <div className="mx-auto flex max-w-[430px] items-center gap-4 border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
          <div className="min-w-0 flex-1">
            <p className="text-[19px] font-semibold leading-tight text-ink">{priceLabel}</p>
            <p className="text-[12px] text-ink-soft">{t('perMonth')}</p>
          </div>
          <Button size="lg" onClick={() => setOpen(true)}>
            {t('start')}
          </Button>
        </div>
      </div>

      <BottomSheet open={open} onOpenChange={setOpen} title={t('checkout.title')}>
        <div className="pb-6">
          <div className="divide-y divide-line">
            {row(t('checkout.package'), packageName)}
            {row(t('checkout.starts'), startsLabel)}
            {row(t('checkout.renews'), renewsLabel)}
            {row(t('checkout.billing', { days: formatNumber(periodDays, locale) }), priceLabel)}
          </div>

          <Surface tone="warmSoft" radius="md" pad="md" elevation="none" className="mt-4">
            <p className="flex items-center gap-2.5 text-[14px] font-medium text-ink">
              <CreditCard className="size-4 shrink-0 text-ink-soft" aria-hidden />
              {t('checkout.payment')}
            </p>
            <p className="mt-1 ps-[26px] text-[13px] text-ink-soft">
            {tb('paymentCard')}
          </p>
          </Surface>

          <div className="mt-5 flex items-baseline justify-between">
            <span className="text-[15px] text-ink-soft">{t('checkout.total')}</span>
            <span className="text-[22px] font-semibold text-ink">{priceLabel}</span>
          </div>

          <Button block size="lg" className="mt-5" onClick={confirm} loading={pending}>
            {t('checkout.confirm')}
          </Button>

          <p className="mt-4 flex items-start gap-2 text-[12px] leading-snug text-ink-soft">
            <ShieldCheck className="mt-0.5 size-4 shrink-0" aria-hidden />
            <span>
              {t('checkout.noFees')} {t('checkout.policy')}
            </span>
          </p>
        </div>
      </BottomSheet>
    </>
  );
}
