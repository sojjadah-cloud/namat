'use client';

import * as React from 'react';
import { OTPField } from '@base-ui/react/otp-field';
import { cn } from '@/lib/utils';

/**
 * Six-digit SMS code. The slots stay LTR under Arabic: a phone code is read
 * left-to-right in both languages, and mirroring it fights the SMS autofill
 * order the OS hands us.
 */

export function OTPInput({
  value,
  onValueChange,
  onComplete,
  length = 6,
  disabled,
  invalid,
  autoFocus,
}: {
  value?: string;
  onValueChange?: (value: string) => void;
  onComplete?: (value: string) => void;
  length?: number;
  disabled?: boolean;
  invalid?: boolean;
  autoFocus?: boolean;
}) {
  return (
    <OTPField.Root
      length={length}
      value={value}
      onValueChange={(next) => onValueChange?.(next)}
      onValueComplete={(next) => onComplete?.(next)}
      disabled={disabled}
      className="flex justify-center gap-2 sm:gap-3"
      dir="ltr"
    >
      {Array.from({ length }, (_, i) => (
        <OTPField.Input
          key={i}
          autoFocus={autoFocus && i === 0}
          aria-invalid={invalid || undefined}
          className={cn(
            'h-14 w-11 rounded-sm border bg-white text-center text-[22px] font-semibold text-ink',
            'transition-[border-color,box-shadow,background-color] duration-200',
            'focus:outline-none focus:border-green focus:ring-4 focus:ring-green/12',
            'data-[filled]:border-green/45',
            'disabled:opacity-45',
            invalid
              ? 'border-danger bg-danger-soft focus:border-danger focus:ring-danger/12'
              : 'border-line',
          )}
        />
      ))}
    </OTPField.Root>
  );
}
