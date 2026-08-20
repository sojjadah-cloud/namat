import type { MetadataRoute } from 'next';
import { routing } from '@/i18n/routing';
import { SITE_URL, PUBLIC_ROUTES } from '@/lib/site';

/**
 * Marketing routes only. Everything under /app is behind auth and personalised
 * per member, so it has nothing to offer a crawler.
 *
 * Each entry carries the full alternates map, which is how Google learns that
 * /en/services and /ar/services are the same page in two languages rather than
 * duplicate content.
 */
export default function sitemap(): MetadataRoute.Sitemap {
  return routing.locales.flatMap((locale) =>
    PUBLIC_ROUTES.map((route) => ({
      url: `${SITE_URL}/${locale}${route}`,
      lastModified: new Date(),
      changeFrequency: route === '' ? ('weekly' as const) : ('monthly' as const),
      priority: route === '' ? 1 : 0.7,
      alternates: {
        languages: Object.fromEntries(
          routing.locales.map((l) => [l, `${SITE_URL}/${l}${route}`]),
        ),
      },
    })),
  );
}
