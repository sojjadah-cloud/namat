import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { ImageResponse } from 'next/og';
import { getTranslations } from 'next-intl/server';
import { routing, getDirection } from '@/i18n/routing';

export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';
export const alt = 'NAMAT';

export function generateStaticParams() {
  return routing.locales.map((locale) => ({ locale }));
}

const fontFile = (name: string) =>
  readFile(join(process.cwd(), 'src', 'assets', 'fonts', name));

/**
 * The link preview card, drawn from the same palette as the site.
 *
 * Two things about this file are not like the rest of the app. Satori supports
 * only a subset of CSS — no custom properties, no external stylesheets — so
 * the brand colours are repeated as literals rather than read from the token
 * layer. And it needs real font binaries: the renderer ships with a Latin face
 * only, which is why an Arabic card used to throw `substFormat: 3`. The TTFs
 * under `src/assets/fonts` are read here and passed in directly.
 *
 * The wordmark stays Latin and Poppins in both locales — a logo is not
 * translated — while everything around it follows the locale.
 */
export default async function OpenGraphImage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: 'Brand' });
  const rtl = getDirection(locale) === 'rtl';

  const [poppins, arabic, arabicBold] = await Promise.all([
    fontFile('Poppins-SemiBold.ttf'),
    fontFile('IBMPlexSansArabic-Regular.ttf'),
    fontFile('IBMPlexSansArabic-SemiBold.ttf'),
  ]);

  const body = rtl ? 'Plex Arabic' : 'Poppins';

  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: rtl ? 'flex-end' : 'flex-start',
          textAlign: rtl ? 'right' : 'left',
          padding: '90px',
          background:
            'radial-gradient(60% 55% at 12% 10%, #3C6157 0%, transparent 70%), radial-gradient(50% 50% at 92% 88%, #4A6A5C 0%, transparent 70%), #233C38',
          fontFamily: body,
        }}
      >
        <svg width="104" height="104" viewBox="0 0 64 64" fill="none">
          <path
            d="M17 55V17.5L45 47"
            stroke="#FFFFFF"
            strokeWidth={10}
            strokeLinecap="round"
            strokeLinejoin="round"
          />
          <path
            d="M52 8c2.3 10.4-.6 19-8.7 25.8-5.6-9.8-2.7-18.4 8.7-25.8Z"
            fill="#A8C699"
          />
        </svg>

        <div
          style={{
            display: 'flex',
            fontFamily: 'Poppins',
            fontSize: 86,
            fontWeight: 600,
            color: '#FFFFFF',
            letterSpacing: '-0.03em',
            marginTop: 40,
          }}
        >
          namat
        </div>

        <div style={{ display: 'flex', alignItems: 'center', marginTop: 20 }}>
          <div style={{ display: 'flex', width: 44, height: 2, background: '#7DA27D' }} />
          <div
            style={{
              display: 'flex',
              fontSize: 32,
              fontWeight: 600,
              color: '#A8C699',
              margin: '0 18px',
            }}
          >
            {t('taglineShort')}
          </div>
          <div style={{ display: 'flex', width: 44, height: 2, background: '#7DA27D' }} />
        </div>

        <div
          style={{
            display: 'flex',
            fontSize: 29,
            color: 'rgba(255,255,255,0.6)',
            marginTop: 36,
            maxWidth: 860,
            lineHeight: 1.45,
          }}
        >
          {t('tagline')}
        </div>
      </div>
    ),
    {
      ...size,
      fonts: [
        { name: 'Poppins', data: poppins, weight: 600, style: 'normal' },
        { name: 'Plex Arabic', data: arabic, weight: 400, style: 'normal' },
        { name: 'Plex Arabic', data: arabicBold, weight: 600, style: 'normal' },
      ],
    },
  );
}
