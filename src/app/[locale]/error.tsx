'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import { RotateCcw } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { LogoMark } from '@/components/brand/Logo';

/**
 * Route-level error boundary. It deliberately shows no stack and no message
 * from the thrown error — a visitor cannot act on either, and both can leak
 * query shapes. The digest is enough for us to find it in the logs.
 */
export default function LocaleError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  const t = useTranslations('ErrorPage');

  React.useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div className="bloom grid min-h-dvh place-items-center bg-canvas px-6 py-20">
      <div className="mx-auto max-w-[44ch] text-center">
        <LogoMark className="mx-auto size-14" />
        <h1 className="display mt-10 text-[30px] text-ink text-balance md:text-[42px]">
          {t('title')}
        </h1>
        <p className="mt-5 text-[16px] leading-relaxed text-ink-soft">{t('body')}</p>

        <div className="mt-10 flex flex-wrap justify-center gap-3">
          <Button size="lg" onClick={reset}>
            <RotateCcw />
            {t('retry')}
          </Button>
          <Button asChild variant="secondary" size="lg">
            <Link href="/">{t('home')}</Link>
          </Button>
        </div>

        {error.digest ? (
          <p className="mt-8 text-[12px] text-ink-soft/60">{error.digest}</p>
        ) : null}
      </div>
    </div>
  );
}
