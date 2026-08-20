import { getTranslations } from 'next-intl/server';
import { CreditCard, ShieldCheck } from 'lucide-react';
import { BackBar } from '@/components/layout/AppHeader';
import { Surface } from '@/components/ui/card';
import { Badge } from '@/components/ui/chip';

/**
 * Payment is presentational until a PSP is wired in. The screen is real so
 * checkout has somewhere to point, but nothing here collects card details —
 * that will belong to the processor's own hosted form, never to this app.
 */
export default async function PaymentPage() {
  const t = await getTranslations('Profile');
  const tp = await getTranslations('Packages');

  return (
    <div className="pb-6">
      <BackBar title={t('payment')} />

      <div className="mt-4 px-5">
        <Surface radius="lg" pad="lg">
          <div className="flex items-center gap-4">
            <span className="grid size-11 shrink-0 place-items-center rounded-sm bg-warm-soft text-ink">
              <CreditCard className="size-5" aria-hidden />
            </span>
            <div className="min-w-0 flex-1">
              <p className="text-[15px] font-medium text-ink">{t('cardNumber')}</p>
              <p className="mt-0.5 text-[13px] text-ink-soft">{t('cardMeta')}</p>
            </div>
            <Badge tone="soft">{tp('status.ACTIVE')}</Badge>
          </div>
        </Surface>

        <p className="mt-5 flex items-start gap-2 text-[13px] leading-snug text-ink-soft">
          <ShieldCheck className="mt-0.5 size-4 shrink-0" aria-hidden />
          <span>{tp('checkout.noFees')}</span>
        </p>
      </div>
    </div>
  );
}
