import { getTranslations } from 'next-intl/server';
import { ArrowRight } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { LogoMark } from '@/components/brand/Logo';

/**
 * A 404 inside the locale segment, so the message and the direction match the
 * language the visitor was already reading in.
 */
export default async function NotFound() {
  const t = await getTranslations('NotFound');

  return (
    <div className="bloom grid min-h-dvh place-items-center bg-canvas px-6 py-20">
      <div className="mx-auto max-w-[44ch] text-center">
        <LogoMark className="mx-auto size-14" />
        <p className="display mt-10 text-[64px] text-sage-light md:text-[88px]">
          {t('code')}
        </p>
        <h1 className="display mt-4 text-[30px] text-ink text-balance md:text-[42px]">
          {t('title')}
        </h1>
        <p className="mt-5 text-[16px] leading-relaxed text-ink-soft">{t('body')}</p>

        <div className="mt-10 flex flex-wrap justify-center gap-3">
          <Button asChild size="lg">
            <Link href="/">
              {t('home')}
              <ArrowRight className="rtl-flip" />
            </Link>
          </Button>
          <Button asChild variant="secondary" size="lg">
            <Link href="/services">{t('explore')}</Link>
          </Button>
        </div>
      </div>
    </div>
  );
}
