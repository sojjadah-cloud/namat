import * as React from 'react';
import Image from 'next/image';
import { Star } from 'lucide-react';
import { cva, type VariantProps } from 'class-variance-authority';
import { intlLocale } from '@/lib/format';
import { cn } from '@/lib/utils';

/* -------------------------------------------------------------- Avatar ---
   Falls back to initials on a warm surface — never a grey silhouette. */

const avatar = cva(
  'relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-warm font-medium text-ink select-none',
  {
    variants: {
      size: {
        sm: 'size-9 text-[13px]',
        md: 'size-11 text-sm',
        lg: 'size-14 text-base',
        xl: 'size-20 text-xl',
      },
    },
    defaultVariants: { size: 'md' },
  },
);

export interface AvatarProps extends VariantProps<typeof avatar> {
  name?: string | null;
  src?: string | null;
  className?: string;
}

/** First letter only — Arabic names rarely read well as two-letter monograms. */
function initial(name?: string | null) {
  return name?.trim().charAt(0).toUpperCase() || '·';
}

export function Avatar({ name, src, size, className }: AvatarProps) {
  return (
    <span className={cn(avatar({ size }), className)} aria-hidden={!name}>
      {src ? (
        <Image src={src} alt={name ?? ''} fill sizes="80px" className="object-cover" />
      ) : (
        initial(name)
      )}
    </span>
  );
}

/* -------------------------------------------------------------- Rating ---
   One filled star plus the number. A five-star row is noise at card size. */

export function Rating({
  value,
  count,
  locale,
  size = 'md',
  className,
}: {
  value: number;
  count?: number;
  locale: string;
  size?: 'sm' | 'md';
  className?: string;
}) {
  const nf = new Intl.NumberFormat(intlLocale(locale), {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  });

  return (
    <span
      className={cn(
        'inline-flex items-center gap-1 font-medium text-ink',
        size === 'sm' ? 'text-[12px]' : 'text-[13px]',
        className,
      )}
    >
      <Star
        className={cn('fill-accent text-accent', size === 'sm' ? 'size-3.5' : 'size-4')}
        aria-hidden
      />
      {nf.format(value)}
      {typeof count === 'number' && count > 0 ? (
        <span className="font-normal text-ink-soft">
          ({new Intl.NumberFormat(intlLocale(locale)).format(count)})
        </span>
      ) : null}
    </span>
  );
}
