import { getTranslations, getLocale } from 'next-intl/server';
import { Footprints, Salad, Droplets, Leaf } from 'lucide-react';
import { ProgressRing } from '@/components/ui/ring';
import { formatNumber } from '@/lib/format';

/**
 * The phone on the welcome screen.
 *
 * Built from the real design tokens rather than dropped in as a flat image:
 * a screenshot goes stale the first time the palette or the type scale moves,
 * and this cannot. It renders at any size and in either direction.
 *
 * The numbers here are illustrative — this is a picture of the product, shown
 * to someone who has no account and therefore no data of their own. Nothing on
 * this screen is presented as theirs.
 */
export async function AppPreview() {
  const t = await getTranslations('Auth.welcome');
  const locale = await getLocale();
  const n = (v: number) => formatNumber(v, locale);

  return (
    <div className="relative mx-auto w-[248px]">
      {/* Device shell */}
      <div className="relative overflow-hidden rounded-[34px] border-[6px] border-ink/85 bg-canvas shadow-[var(--shadow-lg)]">
        {/* Notch */}
        <div className="absolute inset-x-0 top-0 z-10 flex justify-center">
          <span className="mt-1.5 h-4 w-16 rounded-full bg-ink/85" />
        </div>

        <div className="px-3.5 pt-7 pb-3">
          <p className="text-center text-[11px] font-semibold text-ink">
            {t('previewGreeting')}
          </p>
          <p className="mt-0.5 text-center text-[8px] text-ink-soft">{t('previewSub')}</p>

          {/* Score */}
          <div className="mt-3 grid place-items-center">
            <ProgressRing value={85} max={100} size="lg">
              <span className="leading-tight">
                <span className="block text-[26px] font-semibold text-ink">{n(85)}</span>
                <span className="block text-[8px] text-ink-soft">{t('previewScore')}</span>
              </span>
            </ProgressRing>
            <p className="mt-1.5 text-[8px] text-green">{t('previewScoreNote')}</p>
          </div>

          {/* Weekly tiles */}
          <p className="mt-3 text-center text-[8px] font-medium text-ink-soft">
            {t('previewWeek')}
          </p>
          <div className="mt-1.5 grid grid-cols-3 gap-1.5">
            <Tile
              icon={<Footprints aria-hidden />}
              label={t('previewFitness')}
              value={t('previewSessions', { done: n(4), total: n(5) })}
              tone="text-cat-fitness"
            />
            <Tile
              icon={<Salad aria-hidden />}
              label={t('previewNutrition')}
              value={t('previewDays', { done: n(3), total: n(5) })}
              tone="text-cat-food"
            />
            <Tile
              icon={<Droplets aria-hidden />}
              label={t('previewWater')}
              value={t('previewGlasses', { done: n(6), total: n(8) })}
              tone="text-cat-nutrition"
            />
          </div>

          {/* Tip */}
          <div className="mt-2.5 rounded-md bg-green-soft px-2.5 py-2">
            <p className="flex items-center gap-1 text-[8px] font-semibold text-green">
              <Leaf className="size-2.5" aria-hidden />
              {t('previewTipTitle')}
            </p>
            <p className="mt-0.5 text-[7px] leading-relaxed text-ink-soft">
              {t('previewTipBody')}
            </p>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="flex items-center justify-around border-t border-line bg-canvas/90 px-2 py-1.5">
          {[0, 1, 2, 3].map((i) => (
            <span
              key={i}
              className={`size-1.5 rounded-full ${i === 0 ? 'bg-green' : 'bg-line'}`}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

function Tile({
  icon,
  label,
  value,
  tone,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  tone: string;
}) {
  return (
    <div className="rounded-sm bg-warm-soft px-1 py-1.5 text-center">
      <span className={`mx-auto grid place-items-center ${tone} [&_svg]:size-2.5`}>
        {icon}
      </span>
      <p className="mt-0.5 text-[7px] font-medium text-ink">{label}</p>
      <p className="text-[7px] text-ink-soft">{value}</p>
    </div>
  );
}
