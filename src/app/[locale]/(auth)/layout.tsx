/**
 * Auth is app-style, not a form on a marketing page: the same phone-width
 * column as the product, so signing up already feels like being inside NAMAT.
 */
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-dvh justify-center bg-[#EEF1EC] md:py-8">
      <div className="relative flex min-h-dvh w-full flex-col bg-canvas md:min-h-[860px] md:w-[430px] md:overflow-hidden md:rounded-editorial md:shadow-[var(--shadow-lg)]">
        {children}
      </div>
    </div>
  );
}
