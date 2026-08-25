import { redirect } from '@/i18n/routing';
import { headers } from 'next/headers';
import { getLocale } from 'next-intl/server';
import { BottomNavigation } from '@/components/layout/BottomNavigation';
import { ToastProvider, ToastViewport } from '@/components/ui/toast';
import { getCurrentUser } from '@/server/session';

/**
 * The product shell. On desktop this is not a stretched phone but a phone-width
 * column on a calm ground — the marketing site owns the wide layouts, and the
 * app keeps one reading measure at every breakpoint.
 */
export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const locale = await getLocale();
  const user = await getCurrentUser();
  // next-intl rewrites the locale prefix away, so the middleware header is the
  // only place the originally requested path survives into the layout.
  const requested = (await headers()).get('x-pathname') ?? '';
  const pathname = requested;

  // Most of /app is personal and worth nothing without an account. Discovery
  // is the exception: the welcome screen offers to show the catalogue before
  // signing up, and that promise has to be keepable. Explore and the partner
  // pages it links to therefore render for visitors; everything else — the
  // journey, bookings, the profile — still requires a session.
  const guestViewable =
    pathname.includes('/app/explore') || pathname.includes('/app/search');
  if (!user && !guestViewable) redirect({ href: '/login', locale });

  return (
    <ToastProvider>
      <div className="flex min-h-dvh justify-center bg-[#EEF1EC] md:items-center md:py-8">
        <div
          className={[
            'relative flex min-h-dvh w-full flex-col bg-canvas',
            'md:h-[860px] md:max-h-[calc(100dvh-4rem)] md:min-h-0 md:w-[430px]',
            'md:overflow-hidden md:rounded-editorial md:shadow-[var(--shadow-lg)]',
          ].join(' ')}
        >
          {/* Space for the fixed bottom navigation plus the home indicator. */}
          <main className="pb-nav flex-1 md:overflow-y-auto md:overscroll-contain">
            {children}
          </main>
          <BottomNavigation />
        </div>
      </div>
      <ToastViewport />
    </ToastProvider>
  );
}
