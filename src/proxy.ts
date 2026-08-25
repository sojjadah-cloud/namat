import createMiddleware from 'next-intl/middleware';
import type { NextRequest } from 'next/server';
import { routing } from './i18n/routing';

const intl = createMiddleware(routing);

/**
 * next-intl's middleware, plus the requested path forwarded as a header.
 *
 * Layouts cannot see which child route is rendering, and next-intl rewrites
 * the locale prefix away before the request reaches one. The app layout needs
 * that path to decide whether a visitor without an account is allowed through
 * — Explore is open to them, the rest of the app is not — so the original
 * pathname is passed along explicitly.
 */
export default function middleware(request: NextRequest) {
  const response = intl(request);
  response.headers.set('x-pathname', request.nextUrl.pathname);
  return response;
}

export const config = {
  matcher: ['/', '/(ar|en)/:path*', '/((?!api|_next|_vercel|.*\\..*).*)'],
};
