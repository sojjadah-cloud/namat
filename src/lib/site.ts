/**
 * The canonical origin, in one place. Vercel injects the deployment host at
 * build time; locally we fall back to the dev port so sitemap and metadata
 * URLs stay absolute in every environment.
 */
export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL ??
  (process.env.VERCEL_PROJECT_PRODUCTION_URL
    ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}`
    : 'http://localhost:3000');

/** Public marketing routes, relative to a locale prefix. */
export const PUBLIC_ROUTES = ['', '/services', '/packages', '/partners', '/about'] as const;
