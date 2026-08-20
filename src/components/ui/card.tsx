import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

/**
 * Surface is the only place raw card styling lives. Every card family
 * (Provider, Service, Booking, Package, Journey…) composes it.
 */
const surface = cva('relative', {
  variants: {
    tone: {
      white: 'bg-white',
      warm: 'bg-warm',
      warmSoft: 'bg-warm-soft',
      green: 'bg-green text-white',
      greenDeep: 'bg-green-deep text-white',
      greenSoft: 'bg-green-soft',
      canvas: 'bg-canvas',
      none: '',
    },
    radius: {
      sm: 'rounded-sm',
      md: 'rounded-md',
      lg: 'rounded-lg',
      xl: 'rounded-xl',
      '2xl': 'rounded-2xl',
      editorial: 'rounded-editorial',
    },
    border: {
      true: 'border border-line',
      false: '',
    },
    elevation: {
      none: '',
      sm: 'shadow-[var(--shadow-sm)]',
      md: 'shadow-[var(--shadow-md)]',
      lg: 'shadow-[var(--shadow-lg)]',
    },
    pad: {
      none: '',
      sm: 'p-4',
      md: 'p-5',
      lg: 'p-6',
      xl: 'p-7',
    },
  },
  defaultVariants: {
    tone: 'white',
    radius: 'lg',
    border: false,
    elevation: 'sm',
    pad: 'none',
  },
});

export interface SurfaceProps
  extends React.HTMLAttributes<HTMLElement>,
    VariantProps<typeof surface> {
  as?: 'div' | 'article' | 'section' | 'li';
}

export function Surface({
  className,
  tone,
  radius,
  border,
  elevation,
  pad,
  as: Comp = 'div',
  ...props
}: SurfaceProps) {
  return (
    <Comp
      className={cn(surface({ tone, radius, border, elevation, pad }), className)}
      {...props}
    />
  );
}

/** A surface that is also a pressable target. */
export function PressableSurface({ className, ...props }: SurfaceProps) {
  return (
    <Surface
      className={cn(
        'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'active:scale-[0.99] hover:shadow-[var(--shadow-md)]',
        className,
      )}
      {...props}
    />
  );
}

/* ------------------------------------------------------- Section header ---
   Title on the start edge, optional action on the end edge. */

export function SectionHeader({
  title,
  action,
  eyebrow,
  className,
}: {
  title: React.ReactNode;
  action?: React.ReactNode;
  eyebrow?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('flex items-end justify-between gap-4', className)}>
      <div className="min-w-0">
        {eyebrow ? (
          <p className="mb-1 text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
            {eyebrow}
          </p>
        ) : null}
        <h2 className="truncate text-[19px] font-semibold text-ink">{title}</h2>
      </div>
      {action ? <div className="shrink-0">{action}</div> : null}
    </div>
  );
}
