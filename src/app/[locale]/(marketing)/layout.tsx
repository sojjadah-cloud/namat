import { PublicNav } from '@/components/layout/PublicNav';
import { Footer } from '@/components/layout/Footer';

/**
 * The marketing site is the one place NAMAT gets to be wide. The app column
 * lives at 430px; here the grid runs to 1240 and the photography can breathe.
 */
export default function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-dvh bg-canvas">
      <PublicNav />
      <main>{children}</main>
      <Footer />
    </div>
  );
}
