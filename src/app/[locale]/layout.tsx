import type { Metadata, Viewport } from 'next';
import { notFound } from 'next/navigation';
import { NextIntlClientProvider } from 'next-intl';
import { setRequestLocale, getTranslations } from 'next-intl/server';
import { Poppins, IBM_Plex_Sans_Arabic } from 'next/font/google';
import { SITE_URL } from '@/lib/site';
import { routing, getDirection } from '@/i18n/routing';
import { cn } from '@/lib/utils';
import '../globals.css';

// Poppins is the brand's Latin face; the board specifies Regular/Medium/SemiBold.
const poppins = Poppins({
  subsets: ['latin'],
  weight: ['400', '500', '600'],
  variable: '--font-poppins',
  display: 'swap',
});

const plexArabic = IBM_Plex_Sans_Arabic({
  subsets: ['arabic', 'latin'],
  weight: ['300', '400', '500', '600', '700'],
  variable: '--font-arabic',
  display: 'swap',
});

/**
 * Metadata is generated per locale so Arabic visitors get an Arabic title and
 * description in search results and link previews — and so every page declares
 * its hreflang pair, which is what stops the two locales competing as
 * duplicate content.
 */
export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'Brand' });
  const description = t('tagline');

  return {
    metadataBase: new URL(SITE_URL),
    title: {
      default: `${t('name')} — ${t('nameLocal')}`,
      template: `%s · ${t('name')}`,
    },
    description,
    applicationName: t('name'),
    appleWebApp: { capable: true, title: t('name'), statusBarStyle: 'default' },
    alternates: {
      canonical: `/${locale}`,
      languages: Object.fromEntries(routing.locales.map((l) => [l, `/${l}`])),
    },
    openGraph: {
      type: 'website',
      siteName: t('name'),
      title: `${t('name')} — ${t('taglineShort')}`,
      description,
      locale: locale === 'ar' ? 'ar_OM' : 'en_OM',
      url: `/${locale}`,
    },
    twitter: {
      card: 'summary_large_image',
      title: `${t('name')} — ${t('taglineShort')}`,
      description,
    },
  };
}

export const viewport: Viewport = {
  themeColor: '#FAF7F2',
  width: 'device-width',
  initialScale: 1,
  viewportFit: 'cover',
};

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

export default async function LocaleLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  if (!routing.locales.includes(locale as (typeof routing.locales)[number])) {
    notFound();
  }

  setRequestLocale(locale);

  return (
    <html
      lang={locale}
      dir={getDirection(locale)}
      className={cn(poppins.variable, plexArabic.variable)}
      suppressHydrationWarning
    >
      <body className="min-h-dvh bg-canvas text-ink antialiased">
        <NextIntlClientProvider>{children}</NextIntlClientProvider>
      </body>
    </html>
  );
}
