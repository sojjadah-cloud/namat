import { Search } from 'lucide-react';
import { Link } from '@/i18n/routing';

/**
 * Home shows a search *affordance*, not a search field. Tapping navigates to
 * the search screen where recent queries and suggestions live — an inline input
 * here would strand the user on a screen with nowhere to put results.
 */
export function HomeSearchLink({ placeholder }: { placeholder: string }) {
  return (
    <Link
      href="/app/search"
      className={[
        'flex h-14 items-center gap-3 rounded-md border border-line bg-white px-4',
        'shadow-[var(--shadow-sm)] transition-colors duration-200',
        'hover:border-sage active:scale-[0.995]',
      ].join(' ')}
    >
      <Search className="size-5 shrink-0 text-ink-soft" strokeWidth={1.9} aria-hidden />
      <span className="truncate text-[15px] text-ink-soft">{placeholder}</span>
    </Link>
  );
}
