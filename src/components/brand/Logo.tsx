import * as React from 'react';
import { cn } from '@/lib/utils';

/**
 * The NAMAT mark: a stem that reads as the left stroke of an "N", and a leaf
 * that completes it — letter, nature and person in one shape.
 *
 * Drawn rather than imported so it inherits colour from its surface: the same
 * component works on canvas, on sage and on deep green. Replace the paths if
 * the studio ships a final SVG; the API here should not need to change.
 */
export function LogoMark({
  className,
  tone = 'brand',
}: {
  className?: string;
  /** `mono` on coloured surfaces, where both shapes go white. */
  tone?: 'brand' | 'mono';
}) {
  const stem = tone === 'mono' ? 'currentColor' : 'var(--namat-green)';
  const leaf = tone === 'mono' ? 'currentColor' : 'var(--namat-sage-light)';

  return (
    <svg
      viewBox="0 0 64 64"
      fill="none"
      aria-hidden
      className={cn('shrink-0', className)}
    >
      {/* The N's left leg and diagonal, drawn as one stroke so the joint
          stays a single rounded corner at any size. */}
      <path
        d="M17 55V17.5L45 47"
        stroke={stem}
        strokeWidth={10}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      {/* The leaf stands where the N's right leg would be — the letter and the
          growth read as one shape rather than a logo with a decoration. */}
      <path
        d="M52 8c2.3 10.4-.6 19-8.7 25.8-5.6-9.8-2.7-18.4 8.7-25.8Z"
        fill={leaf}
        opacity={tone === 'mono' ? 0.7 : 1}
      />
    </svg>
  );
}

/**
 * Mark plus wordmark plus rule-flanked tagline, as laid out on the brand board.
 * `size` controls the whole lockup; the tagline drops below `md` because a
 * five-word line under a 20px wordmark is unreadable, not small.
 */
export function Logo({
  size = 'md',
  tone = 'brand',
  tagline,
  className,
}: {
  size?: 'sm' | 'md' | 'lg';
  tone?: 'brand' | 'mono';
  tagline?: string;
  className?: string;
}) {
  const mark = { sm: 'size-7', md: 'size-9', lg: 'size-14' }[size];
  const word = { sm: 'text-[20px]', md: 'text-[26px]', lg: 'text-[44px]' }[size];

  return (
    <span className={cn('inline-flex items-center gap-2.5', className)}>
      <LogoMark tone={tone} className={mark} />
      <span className="inline-flex flex-col">
        <span
          className={cn(
            'font-medium lowercase leading-none tracking-[-0.02em]',
            word,
            tone === 'mono' ? 'text-current' : 'text-ink',
          )}
          // The wordmark is Latin in both locales — a logo is not translated.
          style={{ fontFamily: 'var(--font-poppins), sans-serif' }}
        >
          namat
        </span>
        {tagline && size !== 'sm' ? (
          <span
            className={cn(
              'mt-1.5 inline-flex items-center gap-2 text-[10px] tracking-[0.02em] whitespace-nowrap',
              tone === 'mono' ? 'text-current/70' : 'text-ink-soft',
            )}
          >
            <Rule tone={tone} />
            {tagline}
            <Rule tone={tone} />
          </span>
        ) : null}
      </span>
    </span>
  );
}

function Rule({ tone }: { tone: 'brand' | 'mono' }) {
  return (
    <span
      className={cn(
        'h-px w-4 shrink-0',
        tone === 'mono' ? 'bg-current/40' : 'bg-sage',
      )}
    />
  );
}
