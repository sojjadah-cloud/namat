import * as React from 'react';
import { cn } from '@/lib/utils';

/**
 * A circular progress indicator.
 *
 * Drawn with `pathLength="1"` so the dash maths is a plain 0–1 fraction and
 * does not change when the radius does — the alternative recomputes
 * `2πr` at three sizes and silently breaks when someone adds a fourth.
 *
 * Rotation is applied to the SVG rather than the circle so the sweep starts at
 * twelve o'clock in both directions. Under RTL the whole ring mirrors, which
 * is what an Arabic reader expects: progress grows anticlockwise.
 */
export function ProgressRing({
  value,
  max = 100,
  size = 'md',
  tone = 'green',
  children,
  className,
  label,
}: {
  value: number;
  max?: number;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  tone?: 'green' | 'onDark' | 'accent';
  children?: React.ReactNode;
  className?: string;
  /** Screen-reader text; the visual centre is decorative. */
  label?: string;
}) {
  const fraction = max > 0 ? Math.min(1, Math.max(0, value / max)) : 0;

  const box = { sm: 'size-14', md: 'size-20', lg: 'size-28', xl: 'size-40' }[size];
  const stroke = { sm: 0.1, md: 0.09, lg: 0.08, xl: 0.07 }[size];

  const track =
    tone === 'onDark' ? 'stroke-white/20' : tone === 'accent' ? 'stroke-accent/25' : 'stroke-green/15';
  const bar =
    tone === 'onDark' ? 'stroke-white' : tone === 'accent' ? 'stroke-accent' : 'stroke-green';

  return (
    <div
      className={cn('relative grid place-items-center', box, className)}
      role="img"
      aria-label={label}
    >
      <svg viewBox="0 0 100 100" className="size-full -rotate-90 rtl:rotate-90" aria-hidden>
        <circle
          cx="50"
          cy="50"
          r="42"
          fill="none"
          pathLength={1}
          strokeWidth={stroke * 100}
          className={track}
        />
        <circle
          cx="50"
          cy="50"
          r="42"
          fill="none"
          pathLength={1}
          strokeWidth={stroke * 100}
          strokeLinecap="round"
          strokeDasharray={1}
          strokeDashoffset={1 - fraction}
          className={cn(bar, 'transition-[stroke-dashoffset] duration-500 ease-[var(--ease-namat)]')}
        />
      </svg>

      {children ? (
        <span className="absolute inset-0 grid place-items-center text-center">{children}</span>
      ) : null}
    </div>
  );
}

/**
 * A horizontal bar for the same data, used where a ring would be too heavy —
 * inside list rows and dense dashboards.
 */
export function ProgressTrack({
  value,
  max = 100,
  tone = 'green',
  className,
  label,
}: {
  value: number;
  max?: number;
  tone?: 'green' | 'onDark' | 'accent';
  className?: string;
  label?: string;
}) {
  const percent = max > 0 ? Math.min(100, Math.max(0, (value / max) * 100)) : 0;

  return (
    <div
      className={cn(
        'h-1.5 w-full overflow-hidden rounded-full',
        tone === 'onDark' ? 'bg-white/20' : 'bg-green/12',
        className,
      )}
      role="progressbar"
      aria-valuenow={Math.round(percent)}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label={label}
    >
      <div
        className={cn(
          'h-full rounded-full transition-[width] duration-500 ease-[var(--ease-namat)]',
          tone === 'onDark' ? 'bg-white' : tone === 'accent' ? 'bg-accent' : 'bg-green',
        )}
        style={{ width: `${percent}%` }}
      />
    </div>
  );
}
