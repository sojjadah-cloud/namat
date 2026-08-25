'use client';

import { useLocale, useTranslations } from 'next-intl';
import { Languages } from 'lucide-react';
import { usePathname, useRouter } from '@/i18n/routing';

/**
 * Language as a corner control rather than a screen of its own.
 *
 * It used to be the whole welcome page, which spent a full screen on a
 * decision most people make once and never revisit — and spent it before
 * showing them anything worth choosing a language for.
 */
export function LocaleToggle() {
  const t = useTranslations('Nav');
  const locale = useLocale();
  const router = useRouter();
  const pathname = usePathname();

  return (
    <button
      type="button"
      onClick={() => router.replace(pathname, { locale: locale === 'ar' ? 'en' : 'ar' })}
      className="inline-flex items-center gap-1.5 rounded-full border border-line bg-surface/80 px-3 py-1.5 text-[12px] font-medium text-ink-soft backdrop-blur-sm transition-colors hover:text-ink"
    >
      <Languages className="size-3.5" aria-hidden />
      {t('language')}
    </button>
  );
}
