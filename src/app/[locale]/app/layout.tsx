import { redirect } from '@/i18n/routing';
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

  // Everything under /app is personal. There is no useful guest state here —
  // discovery for guests lives on the marketing site.
  if (!user) redirect({ href: '/login', locale });

  return (
    <ToastProvider>
      <div className="flex min-h-dvh justify-center bg-[#EEF1EC] md:py-8">
        <div
          className={[
            'relative flex min-h-dvh w-full flex-col bg-canvas',
            'md:min-h-[860px] md:w-[430px] md:overflow-hidden md:rounded-editorial md:shadow-[var(--shadow-lg)]',
          ].join(' ')}
        >
          {/* Space for the fixed bottom navigation plus the home indicator. */}
          <main className="flex-1 pb-[calc(76px+env(safe-area-inset-bottom))]">
            {children}
          </main>
          <BottomNavigation />
        </div>
      </div>
      <ToastViewport />
    </ToastProvider>
  );
}
