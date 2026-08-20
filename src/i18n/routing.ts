import { defineRouting } from 'next-intl/routing';
import { createNavigation } from 'next-intl/navigation';

export const locales = ['ar', 'en'] as const;
export type Locale = (typeof locales)[number];

/** NAMAT is Arabic-first: an unprefixed URL lands in Arabic. */
export const defaultLocale: Locale = 'ar';

export const routing = defineRouting({
  locales,
  defaultLocale,
  // Always prefix so /ar and /en are both real, shareable URLs and the
  // language switch is a plain navigation rather than a cookie side effect.
  localePrefix: 'always',
});

export const { Link, redirect, usePathname, useRouter, getPathname } =
  createNavigation(routing);

export function getDirection(locale: string) {
  return locale === 'ar' ? 'rtl' : 'ltr';
}

export function isRtl(locale: string) {
  return locale === 'ar';
}
