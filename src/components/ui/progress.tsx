import * as React from 'react';
import { cn } from '@/lib/utils';

/**
 * Restrained progress. Journey and package usage read as information,
 * not as a game. No oversized charts, no confetti.
 */
export function ProgressBar({
  value,
  max = 100,
  className,
  tone = 'green',
  size = 'md',
  label,
}: {
  value: number;
  max?: number;
  className?: string;
  tone?: 'green' | 'accent' | 'sage' | 'onDark';
  size?: 'sm' | 'md';
  label?: string;
}) {
  const pct = max > 0 ? Math.min(100, Math.max(0, (value / max) * 100)) : 0;
  const fill = {
    green: 'bg-green',
    accent: 'bg-accent',
    sage: 'bg-sage',
    onDark: 'bg-white',
  }[tone];

  return (
    <div
      role="progressbar"
      aria-valuenow={Math.round(pct)}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label={label}
      className={cn(
        'w-full overflow-hidden rounded-full',
        tone === 'onDark' ? 'bg-white/25' : 'bg-[#E4EAE4]',
        size === 'sm' ? 'h-1.5' : 'h-2',
        className,
      )}
    >
      <div
        className={cn('h-full rounded-full transition-[width] duration-500 ease-out', fill)}
        style={{ inlineSize: `${pct}%` }}
      />
    </div>
  );
}

/** Segmented allowance meter: 8 of 10 sessions, shown as ticks not a bar. */
export function AllowanceMeter({
  used,
  total,
  className,
  tone = 'green',
}: {
  used: number;
  total: number;
  className?: string;
  tone?: 'green' | 'onDark';
}) {
  const capped = Math.min(used, total);
  return (
    <div className={cn('flex gap-1', className)} aria-hidden>
      {Array.from({ length: total }).map((_, i) => (
        <span
          key={i}
          className={cn(
            'h-1.5 flex-1 rounded-full transition-colors',
            i < capped
              ? tone === 'onDark'
                ? 'bg-white'
                : 'bg-green'
              : tone === 'onDark'
                ? 'bg-white/25'
                : 'bg-[#E4EAE4]',
          )}
        />
      ))}
    </div>
  );
}

/** Thin step indicator for onboarding and booking. */
export function StepProgress({
  current,
  total,
  className,
}: {
  current: number;
  total: number;
  className?: string;
}) {
  return (
    <div className={cn('flex gap-1.5', className)} aria-hidden>
      {Array.from({ length: total }).map((_, i) => (
        <span
          key={i}
          className={cn(
            'h-1 flex-1 rounded-full transition-colors duration-300',
            i < current ? 'bg-green' : 'bg-[#E1E7E1]',
          )}
        />
      ))}
    </div>
  );
}
