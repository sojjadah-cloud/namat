import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { Slot } from './slot';
import { Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';

const button = cva(
  [
    'inline-flex items-center justify-center gap-2 font-medium whitespace-nowrap',
    'transition-[background-color,color,transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
    'active:scale-[0.985] disabled:pointer-events-none disabled:opacity-45',
    'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
    '[&_svg]:shrink-0',
  ],
  {
    variants: {
      variant: {
        // Green carries importance — used sparingly, never decoratively.
        primary: 'bg-green text-white hover:bg-green-deep shadow-[var(--shadow-sm)]',
        secondary: 'bg-white text-ink border border-line hover:bg-warm-soft',
        warm: 'bg-warm text-ink hover:bg-[#E0DACB]',
        ghost: 'text-ink hover:bg-black/[0.04]',
        // Text + directional arrow.
        tertiary: 'text-green hover:text-green-deep underline-offset-4 hover:underline px-0',
        danger: 'bg-danger-soft text-danger hover:bg-[#F6E3E1]',
        onDark: 'bg-white text-ink hover:bg-white/90',
      },
      size: {
        sm: 'h-9 px-4 text-[13px] rounded-xs [&_svg]:size-4',
        md: 'h-11 px-5 text-sm rounded-sm [&_svg]:size-[18px]',
        lg: 'h-13 px-6 text-[15px] rounded-md [&_svg]:size-5',
        xl: 'h-14 px-8 text-base rounded-md [&_svg]:size-5',
        icon: 'size-11 rounded-full [&_svg]:size-5',
        iconSm: 'size-9 rounded-full [&_svg]:size-[18px]',
      },
      block: { true: 'w-full' },
    },
    compoundVariants: [
      { variant: 'tertiary', size: 'md', class: 'h-auto px-0' },
      { variant: 'tertiary', size: 'sm', class: 'h-auto px-0' },
    ],
    defaultVariants: { variant: 'primary', size: 'md' },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof button> {
  asChild?: boolean;
  loading?: boolean;
}

export function Button({
  className,
  variant,
  size,
  block,
  asChild,
  loading,
  disabled,
  children,
  ...props
}: ButtonProps) {
  const Comp = asChild ? Slot : 'button';
  return (
    <Comp
      className={cn(button({ variant, size, block }), className)}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? (
        <>
          <Loader2 className="animate-spin" aria-hidden />
          {children}
        </>
      ) : (
        children
      )}
    </Comp>
  );
}

export { button as buttonVariants };
