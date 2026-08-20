import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

/* ---------------------------------------------------------------- Chip ---
   Horizontally scrolling filter pills: Explore categories, quick filters. */

const chip = cva(
  [
    'inline-flex items-center gap-1.5 whitespace-nowrap rounded-full border font-medium',
    'transition-colors duration-200 select-none',
    'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
    '[&_svg]:size-4 [&_svg]:shrink-0',
  ],
  {
    variants: {
      selected: {
        true: 'bg-ink text-white border-ink',
        false: 'bg-white text-ink-soft border-line hover:border-sage hover:text-ink',
      },
      size: {
        sm: 'h-8 px-3 text-[12px]',
        md: 'h-10 px-4 text-[13px]',
      },
    },
    defaultVariants: { selected: false, size: 'md' },
  },
);

export interface ChipProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'size'>,
    VariantProps<typeof chip> {}

export function Chip({ className, selected, size, ...props }: ChipProps) {
  return (
    <button
      type="button"
      aria-pressed={selected ?? false}
      className={cn(chip({ selected, size }), className)}
      {...props}
    />
  );
}

/* --------------------------------------------------------------- Badge ---
   Non-interactive labels on cards: "Included in your package", "Popular". */

const badge = cva(
  'inline-flex items-center gap-1 rounded-full font-medium whitespace-nowrap [&_svg]:size-3.5 [&_svg]:shrink-0',
  {
    variants: {
      tone: {
        // Inclusion is the strongest signal on a card — it beats the price.
        included: 'bg-green text-white',
        goal: 'bg-accent-soft text-[#8A6A38] border border-accent/40',
        neutral: 'bg-warm text-ink-soft',
        soft: 'bg-green-soft text-green',
        light: 'bg-white/90 text-ink backdrop-blur-sm shadow-[var(--shadow-sm)]',
        danger: 'bg-danger-soft text-danger',
      },
      size: {
        sm: 'h-6 px-2 text-[11px]',
        md: 'h-7 px-2.5 text-[12px]',
      },
    },
    defaultVariants: { tone: 'neutral', size: 'sm' },
  },
);

export interface BadgeProps
  extends Omit<React.HTMLAttributes<HTMLSpanElement>, 'color'>,
    VariantProps<typeof badge> {}

export function Badge({ className, tone, size, ...props }: BadgeProps) {
  return <span className={cn(badge({ tone, size }), className)} {...props} />;
}
