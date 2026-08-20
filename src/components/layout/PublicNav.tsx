'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { Menu, X } from 'lucide-react';
import { Link, usePathname, useRouter } from '@/i18n/routing';
import { Logo } from '@/components/brand/Logo';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

const LINKS = [
  { href: '/services', key: 'services' },
  { href: '/packages', key: 'memberships' },
  { href: '/partners', key: 'partners' },
  { href: '/about', key: 'about' },
] as const;

/**
 * Transparent over the hero, translucent once the page scrolls under it —
 * so the first thing a visitor sees is the photograph, not a bar.
 */
export function PublicNav() {
  const t = useTranslations('Nav');
  const locale = useLocale();
  const pathname = usePathname();
  const router = useRouter();

  const [open, setOpen] = React.useState(false);

  // Scroll offset is external state. Subscribing beats mirroring it into
  // component state, and the `false` server snapshot keeps the first paint
  // transparent — matching what a visitor at the top of the page sees.
  const scrolled = React.useSyncExternalStore(
    (onChange) => {
      window.addEventListener('scroll', onChange, { passive: true });
      return () => window.removeEventListener('scroll', onChange);
    },
    () => window.scrollY > 12,
    () => false,
  );

  // Close the sheet on navigation — a menu that survives a route change traps
  // the user behind their own tap. Adjusted during render rather than in an
  // effect so the sheet is already closed on the frame the new route paints,
  // and so a back-button navigation closes it too, not just a link tap.
  const [sheetPath, setSheetPath] = React.useState(pathname);
  if (sheetPath !== pathname) {
    setSheetPath(pathname);
    setOpen(false);
  }

  const toggleLocale = () => {
    router.replace(pathname, { locale: locale === 'ar' ? 'en' : 'ar' });
  };

  return (
    <header
      className={cn(
        'fixed inset-x-0 top-0 z-50 transition-[background-color,box-shadow,backdrop-filter] duration-300',
        scrolled
          ? 'bg-canvas/85 shadow-[var(--shadow-sm)] backdrop-blur-xl'
          : 'bg-transparent',
      )}
    >
      <div className="mx-auto flex h-18 max-w-[1240px] items-center gap-6 px-5 md:px-8">
        <Link href="/" aria-label="NAMAT">
          <Logo size="sm" />
        </Link>

        <nav className="hidden flex-1 items-center gap-1 lg:flex">
          {LINKS.map(({ href, key }) => (
            <Link
              key={href}
              href={href}
              className={cn(
                'rounded-full px-4 py-2 text-[14px] font-medium transition-colors',
                pathname === href
                  ? 'bg-green-soft text-green'
                  : 'text-ink-soft hover:bg-black/[0.03] hover:text-ink',
              )}
            >
              {t(key)}
            </Link>
          ))}
        </nav>

        <div className="ms-auto flex items-center gap-2 lg:ms-0">
          <button
            type="button"
            onClick={toggleLocale}
            className="hidden rounded-full px-3 py-2 text-[13px] font-medium text-ink-soft transition-colors hover:text-ink sm:block"
          >
            {t('language')}
          </button>

          <Button asChild variant="ghost" size="sm" className="hidden sm:inline-flex">
            <Link href="/login">{t('login')}</Link>
          </Button>

          <Button asChild size="sm" className="hidden sm:inline-flex">
            <Link href="/welcome">{t('start')}</Link>
          </Button>

          <button
            type="button"
            aria-label={t('menu')}
            aria-expanded={open}
            onClick={() => setOpen((v) => !v)}
            className="grid size-10 place-items-center rounded-full text-ink transition-colors hover:bg-black/[0.04] lg:hidden"
          >
            {open ? <X className="size-5" /> : <Menu className="size-5" />}
          </button>
        </div>
      </div>

      {/* Mobile sheet */}
      <div
        className={cn(
          'overflow-hidden border-t border-line bg-canvas/95 backdrop-blur-xl transition-[max-height] duration-300 ease-[cubic-bezier(.22,.61,.36,1)] lg:hidden',
          open ? 'max-h-96' : 'max-h-0 border-t-0',
        )}
      >
        <nav className="flex flex-col px-5 py-4">
          {LINKS.map(({ href, key }) => (
            <Link
              key={href}
              href={href}
              className="border-b border-line py-3.5 text-[16px] font-medium text-ink last:border-0"
            >
              {t(key)}
            </Link>
          ))}
          <div className="mt-4 flex flex-col gap-2.5 pb-2">
            <Button asChild size="lg" block>
              <Link href="/welcome">{t('start')}</Link>
            </Button>
            <Button asChild variant="secondary" size="lg" block>
              <Link href="/login">{t('login')}</Link>
            </Button>
            <button
              type="button"
              onClick={toggleLocale}
              className="py-2 text-[14px] font-medium text-ink-soft"
            >
              {t('language')}
            </button>
          </div>
        </nav>
      </div>
    </header>
  );
}
