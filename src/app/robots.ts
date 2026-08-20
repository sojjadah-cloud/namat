import type { MetadataRoute } from 'next';
import { SITE_URL } from '@/lib/site';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        // The member area is personalised and auth-gated; the API is not a page.
        disallow: ['/api/', '/en/app/', '/ar/app/', '/en/onboarding', '/ar/onboarding'],
      },
    ],
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
