import type { MetadataRoute } from 'next';
import { routing } from '@/i18n/routing';
import { SITE_URL } from '@/lib/site';

/**
 * NAMAT is an app behind a sign-in, so there is almost nothing for a crawler
 * to index: every real screen is personalised and auth-gated. Only the entry
 * point is listed, once per locale, with the hreflang pair that tells Google
 * the two are one page in two languages rather than duplicate content.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  return routing.locales.map((locale) => ({
    url: `${SITE_URL}/${locale}`,
    lastModified: new Date(),
    changeFrequency: 'monthly' as const,
    priority: 1,
    alternates: {
      languages: Object.fromEntries(
        routing.locales.map((l) => [l, `${SITE_URL}/${l}`]),
      ),
    },
  }));
}
