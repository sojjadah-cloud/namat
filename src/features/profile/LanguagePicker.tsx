'use client';

import * as React from 'react';
import { useLocale } from 'next-intl';
import { useRouter, usePathname } from '@/i18n/routing';
import { OptionCard } from '@/components/ui/option';
import { setLocale } from '@/server/actions/profile';
import type { Locale } from '@/i18n/routing';

/**
 * Switching language is a navigation, not a toggle: `/ar/...` and `/en/...`
 * are both real URLs, so the choice survives sharing and reloading. The write
 * to the profile is a side effect for next time they sign in on another device.
 */
export function LanguagePicker() {
  const current = useLocale() as Locale;
  const router = useRouter();
  const pathname = usePathname();
  const [, startTransition] = React.useTransition();

  const choose = (locale: Locale) => {
    if (locale === current) return;
    startTransition(async () => {
      await setLocale(locale);
      router.replace(pathname, { locale });
    });
  };

  return (
    <div className="space-y-2.5">
      <OptionCard
        selected={current === 'ar'}
        onSelect={() => choose('ar')}
        title="العربية"
        description="Arabic · من اليمين إلى اليسار"
      />
      <OptionCard
        selected={current === 'en'}
        onSelect={() => choose('en')}
        title="English"
        description="الإنجليزية · left to right"
      />
    </div>
  );
}
