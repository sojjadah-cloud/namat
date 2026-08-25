import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Check, Flame } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Surface } from '@/components/ui/card';
import { ProgressRing } from '@/components/ui/ring';
import { getActiveChallenge, getStreak } from '@/server/queries/challenges';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * The Home and Journey view of whatever challenge is running.
 *
 * One row, one tap, no decision to make — the point is to answer "what am I
 * doing today?" before the member has to go looking. When nothing is running
 * it invites rather than nags, and when today is already done it says so and
 * stops asking.
 */
export async function ActiveChallengeStrip() {
  const [active, streak] = await Promise.all([getActiveChallenge(), getStreak()]);
  const t = await getTranslations('Challenges');
  const locale = await getLocale();

  if (!active) {
    return (
      <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
        <p className="text-[15px] leading-snug text-ink">{t('emptyTitle')}</p>
        <Link
          href="/app/challenges"
          className="mt-3 inline-flex items-center gap-1.5 text-[14px] font-medium text-green"
        >
          {t('emptyCta')}
          <ArrowRight className="size-4 rtl-flip" aria-hidden />
        </Link>
      </Surface>
    );
  }

  const { enrollment, progress } = active;
  const challenge = enrollment.challenge;

  return (
    <Link href={`/app/challenges/${challenge.slug}`} className="block">
      <Surface radius="lg" pad="lg" elevation="sm" className="transition-shadow hover:shadow-[var(--shadow-md)]">
        <div className="flex items-center gap-4">
          <ProgressRing
            value={progress.completedDays}
            max={challenge.durationDays}
            size="md"
            label={t('dayOf', {
              current: formatNumber(progress.day, locale),
              total: formatNumber(challenge.durationDays, locale),
            })}
          >
            {progress.todayDone ? (
              <Check className="size-6 text-green" strokeWidth={2.4} aria-hidden />
            ) : (
              <span className="text-[17px] font-semibold text-ink">
                {formatNumber(progress.day, locale)}
              </span>
            )}
          </ProgressRing>

          <div className="min-w-0 flex-1">
            <p className="truncate text-[16px] font-semibold text-ink">
              {pick(challenge, 'title', locale)}
            </p>

            <p className="mt-0.5 text-[13px] text-ink-soft">
              {progress.todayDone
                ? t('doneToday')
                : progress.task
                  ? t('progressOf', {
                      current: formatNumber(progress.amount, locale),
                      total: formatNumber(progress.target, locale),
                      unit: pick(progress.task, 'unit', locale),
                    })
                  : t('dayOf', {
                      current: formatNumber(progress.day, locale),
                      total: formatNumber(challenge.durationDays, locale),
                    })}
            </p>

            {streak > 0 ? (
              <p className="mt-1.5 inline-flex items-center gap-1 text-[12px] font-medium text-cat-fitness">
                <Flame className="size-3.5" aria-hidden />
                {t('streakDays', { days: formatNumber(streak, locale) })}
              </p>
            ) : null}
          </div>

          <ArrowRight className="size-5 shrink-0 text-ink-soft rtl-flip" aria-hidden />
        </div>
      </Surface>
    </Link>
  );
}
