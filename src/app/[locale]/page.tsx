import { redirect } from '@/i18n/routing';
import { getSessionUserId } from '@/server/session';

/**
 * NAMAT is an app, not a site with an app attached. The root is a routing
 * decision, not a page: members go straight to their day, everyone else to the
 * welcome screen.
 *
 * There is deliberately no splash animation here. A splash that exists only to
 * delay the redirect makes the product measurably slower to reach in exchange
 * for a logo the member has already seen; the brand moment belongs in the
 * loading state, which shows only when there is genuinely something to wait for.
 */
export default async function RootPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const userId = await getSessionUserId();

  redirect({ href: userId ? '/app' : '/welcome', locale });
}
