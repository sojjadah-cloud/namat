import type { MetadataRoute } from 'next';
import { SITE_URL } from '@/lib/site';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        // Everything past the welcome screen is personalised and behind a
        // session; the API is not a page.
        disallow: ['/api/', '/en/app/', '/ar/app/', '/en/onboarding', '/ar/onboarding'],
      },
    ],
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
