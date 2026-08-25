import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Sparkles } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Surface } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { ProgressRing } from '@/components/ui/ring';
import { formatNumber } from '@/lib/format';

/**
 * The first thing on Home, and the one part that is genuinely a different
 * product for the two kinds of member.
 *
 * Someone without a package opens NAMAT to find something. Someone with one
 * opens it to continue something. Showing both the same feed makes the package
 * look like a discount card rather than a journey — so the lead states which
 * app you are in before anything else on the page loads.
 */
export async function HomeLead({
  membership,
  percent,
}: {
  membership: { packageName: string; daysLeft: number } | null;
  /** Share of this period's allowance already used, 0–100. */
  percent: number;
}) {
  const t = await getTranslations('Home');
  const locale = await getLocale();

  if (!membership) {
    return (
      <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
        <h2 className="text-[19px] font-semibold text-ink">{t('leadGuestTitle')}</h2>
        <p className="mt-1.5 text-[14px] leading-snug text-ink-soft">
          {t('leadGuestBody')}
        </p>
        <Button asChild variant="secondary" size="sm" className="mt-4">
          <Link href="/app/explore">
            {t('leadGuestTitle')}
            <ArrowRight className="rtl-flip" />
          </Link>
        </Button>
      </Surface>
    );
  }

  return (
    <Link href="/app/journey" className="block">
      <Surface
        radius="lg"
        pad="lg"
        elevation="sm"
        className="bg-green-deep text-white transition-shadow hover:shadow-[var(--shadow-md)]"
      >
        <div className="flex items-center gap-4">
          <ProgressRing
            value={percent}
            max={100}
            size="md"
            tone="onDark"
            label={t('leadMemberBody', { percent: formatNumber(percent, locale) })}
          >
            <span className="text-[15px] font-semibold">
              {formatNumber(percent, locale)}
              <span className="text-[10px] text-white/60">٪</span>
            </span>
          </ProgressRing>

          <div className="min-w-0 flex-1">
            <h2 className="text-[19px] font-semibold">{t('leadMemberTitle')}</h2>
            <p className="mt-1 truncate text-[14px] text-white/70">
              {membership.packageName}
            </p>
          </div>

          <ArrowRight className="size-5 shrink-0 text-white/70 rtl-flip" aria-hidden />
        </div>
      </Surface>
    </Link>
  );
}

/**
 * The package suggestion, shown to a member without one who has actually
 * started spending across the ecosystem.
 *
 * Deliberately gated on real behaviour rather than shown to everyone on day
 * one: a package pitched before someone has booked anything is an advert, and
 * the same words after they have booked in three categories are a useful
 * observation about their own spending. With no bookings yet it renders
 * nothing at all, which is the correct behaviour and not a bug.
 */
export async function PackageUpsell({ categoryCount }: { categoryCount: number }) {
  const t = await getTranslations('Home');
  const locale = await getLocale();

  // Two categories is the point where a package starts to be cheaper than
  // paying per service, so it is the earliest the suggestion is honest.
  if (categoryCount < 2) return null;

  return (
    <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
      <span className="inline-flex items-center gap-2 text-[13px] font-medium text-accent">
        <Sparkles className="size-4" aria-hidden />
        {t('upsellTitle')}
      </span>
      <p className="mt-2 text-[14px] leading-snug text-ink-soft">
        {t('upsellBody', { count: formatNumber(categoryCount, locale) })}
      </p>
      <Button asChild variant="secondary" size="sm" className="mt-4">
        <Link href="/app/packages">
          {t('upsellCta')}
          <ArrowRight className="rtl-flip" />
        </Link>
      </Button>
    </Surface>
  );
}
