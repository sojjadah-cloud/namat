'use client';

import * as React from 'react';
import { Search, X } from 'lucide-react';
import { cn } from '@/lib/utils';

/* --------------------------------------------------------------- Input --- */

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  invalid?: boolean;
  /** Rendered on the leading edge — direction-aware via flex order. */
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(function Input(
  { className, invalid, leading, trailing, ...props },
  ref,
) {
  return (
    <div
      className={cn(
        'flex h-13 items-center gap-2.5 rounded-sm border bg-white px-4',
        'transition-colors duration-200',
        'focus-within:border-green focus-within:ring-4 focus-within:ring-green/10',
        invalid ? 'border-danger' : 'border-line',
        className,
      )}
    >
      {leading ? <span className="shrink-0 text-ink-soft [&_svg]:size-5">{leading}</span> : null}
      <input
        ref={ref}
        aria-invalid={invalid || undefined}
        className={cn(
          'min-w-0 flex-1 bg-transparent text-[15px] text-ink outline-none',
          'placeholder:text-ink-soft/70',
        )}
        {...props}
      />
      {trailing ? <span className="shrink-0 [&_svg]:size-5">{trailing}</span> : null}
    </div>
  );
});

/* --------------------------------------------------------------- Label --- */

export function Label({
  className,
  hint,
  children,
  ...props
}: React.LabelHTMLAttributes<HTMLLabelElement> & { hint?: React.ReactNode }) {
  return (
    <label className={cn('mb-2 flex items-baseline gap-2 text-[13px]', className)} {...props}>
      <span className="font-medium text-ink">{children}</span>
      {hint ? <span className="text-[12px] text-ink-soft">{hint}</span> : null}
    </label>
  );
}

export function FieldError({ children }: { children?: React.ReactNode }) {
  if (!children) return null;
  return (
    <p role="alert" className="mt-2 text-[13px] text-danger">
      {children}
    </p>
  );
}

/* --------------------------------------------------------- SearchField --- */

export interface SearchFieldProps
  extends Omit<React.InputHTMLAttributes<HTMLInputElement>, 'onChange' | 'value' | 'size'> {
  value?: string;
  onValueChange?: (value: string) => void;
  onClear?: () => void;
  size?: 'md' | 'lg';
}

export const SearchField = React.forwardRef<HTMLInputElement, SearchFieldProps>(
  function SearchField({ className, value, onValueChange, onClear, size = 'lg', ...props }, ref) {
    const showClear = Boolean(value && value.length > 0);
    return (
      <div
        className={cn(
          'flex items-center gap-3 rounded-md border border-line bg-white px-4',
          'shadow-[var(--shadow-sm)] transition-colors duration-200',
          'focus-within:border-green focus-within:ring-4 focus-within:ring-green/10',
          size === 'lg' ? 'h-14' : 'h-12',
          className,
        )}
      >
        <Search className="size-5 shrink-0 text-ink-soft" aria-hidden />
        <input
          ref={ref}
          type="search"
          value={value}
          onChange={(e) => onValueChange?.(e.target.value)}
          className={cn(
            'min-w-0 flex-1 bg-transparent text-[15px] text-ink outline-none',
            'placeholder:text-ink-soft/70',
            '[&::-webkit-search-cancel-button]:hidden',
          )}
          {...props}
        />
        {showClear ? (
          <button
            type="button"
            onClick={() => {
              onValueChange?.('');
              onClear?.();
            }}
            className="grid size-7 shrink-0 place-items-center rounded-full bg-warm text-ink-soft transition-colors hover:text-ink"
            aria-label="Clear"
          >
            <X className="size-4" />
          </button>
        ) : null}
      </div>
    );
  },
);
