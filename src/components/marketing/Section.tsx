import * as React from 'react';
import { cn } from '@/lib/utils';

/**
 * Marketing rhythm lives here rather than in every page: one max width, one
 * vertical cadence, one way to write an eyebrow. Pages choose a tone and a
 * heading and stop thinking about spacing.
 */
export function Section({
  children,
  tone = 'canvas',
  className,
  id,
}: {
  children: React.ReactNode;
  tone?: 'canvas' | 'warm' | 'sage' | 'green' | 'bloom';
  className?: string;
  id?: string;
}) {
  return (
    <section
      id={id}
      className={cn(
        'px-5 py-20 md:px-8 md:py-28',
        tone === 'canvas' && 'bg-canvas',
        tone === 'warm' && 'bg-warm-soft',
        tone === 'sage' && 'bg-sage-soft',
        tone === 'green' && 'bloom-dark bg-green-deep text-white',
        tone === 'bloom' && 'bloom bg-canvas',
        className,
      )}
    >
      <div className="mx-auto max-w-[1240px]">{children}</div>
    </section>
  );
}

export function Eyebrow({
  children,
  tone = 'dark',
  className,
}: {
  children: React.ReactNode;
  tone?: 'dark' | 'light';
  className?: string;
}) {
  return (
    <p
      className={cn(
        'inline-flex items-center gap-2.5 text-[11px] font-medium uppercase tracking-[0.18em]',
        tone === 'light' ? 'text-white/55' : 'text-ink-soft',
        className,
      )}
    >
      <span
        className={cn('h-px w-6', tone === 'light' ? 'bg-white/35' : 'bg-sage')}
        aria-hidden
      />
      {children}
    </p>
  );
}

export function SectionTitle({
  children,
  tone = 'dark',
  className,
}: {
  children: React.ReactNode;
  tone?: 'dark' | 'light';
  className?: string;
}) {
  return (
    <h2
      className={cn(
        'display mt-5 text-[32px] text-balance md:text-[48px] lg:text-[56px]',
        tone === 'light' ? 'text-white' : 'text-ink',
        className,
      )}
    >
      {children}
    </h2>
  );
}

export function SectionLead({
  children,
  tone = 'dark',
  className,
}: {
  children: React.ReactNode;
  tone?: 'dark' | 'light';
  className?: string;
}) {
  return (
    <p
      className={cn(
        'mt-5 max-w-[58ch] text-[16px] leading-relaxed md:text-[18px]',
        tone === 'light' ? 'text-white/65' : 'text-ink-soft',
        className,
      )}
    >
      {children}
    </p>
  );
}
