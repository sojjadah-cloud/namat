'use client';

import { useLocale, useTranslations } from 'next-intl';
import { usePathname, useRouter } from '@/i18n/routing';
import { CHALLENGE_KINDS, CHALLENGE_META } from '@/lib/challenge-meta';
import { cn } from '@/lib/utils';

/**
 * The kind chips, as a horizontal rail that bleeds to the screen edge.
 *
 * Filtering goes through the URL rather than component state so a filtered
 * view is shareable, survives a back navigation, and keeps the list itself on
 * the server where the data already is.
 */
export function KindFilter({ active }: { active: string }) {
  const t = useTranslations('Challenges');
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  const select = (kind: string) => {
    router.replace(kind === 'all' ? pathname : `${pathname}?kind=${kind}`, { locale });
  };

  return (
    <div className="rail mt-3 gap-2 px-5">
      {(['all', ...CHALLENGE_KINDS] as const).map((kind) => {
        const selected = active === kind;
        const meta = kind === 'all' ? null : CHALLENGE_META[kind];
        const Icon = meta?.icon;

        return (
          <button
            key={kind}
            type="button"
            onClick={() => select(kind)}
            aria-pressed={selected}
            className={cn(
              'inline-flex shrink-0 items-center gap-1.5 rounded-full px-4 py-2 text-[14px] font-medium transition-colors',
              selected
                ? 'bg-green text-white'
                : 'bg-warm-soft text-ink-soft hover:text-ink',
            )}
          >
            {Icon ? <Icon className="size-4" strokeWidth={2} aria-hidden /> : null}
            {kind === 'all' ? t('kindAll') : t(`kind${kind}`)}
          </button>
        );
      })}
    </div>
  );
}
