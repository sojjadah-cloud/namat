'use client';

import * as React from 'react';
import { Check } from 'lucide-react';
import { Switch as BaseSwitch } from '@base-ui/react/switch';
import { cn } from '@/lib/utils';

/**
 * The large selectable card used across onboarding, filters and package
 * personalization. Multi-select shows a check, single-select shows a ring.
 */
export function OptionCard({
  selected,
  onSelect,
  title,
  description,
  icon,
  multi = false,
  className,
  disabled,
}: {
  selected: boolean;
  onSelect: () => void;
  title: React.ReactNode;
  description?: React.ReactNode;
  icon?: React.ReactNode;
  multi?: boolean;
  className?: string;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      role={multi ? 'checkbox' : 'radio'}
      aria-checked={selected}
      onClick={onSelect}
      disabled={disabled}
      className={cn(
        'group flex w-full items-center gap-4 rounded-lg border p-4 text-start',
        'transition-[border-color,background-color,transform] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'active:scale-[0.99] disabled:opacity-45',
        selected
          ? 'border-green bg-green-soft'
          : 'border-line bg-white hover:border-sage',
        className,
      )}
    >
      {icon ? (
        <span
          className={cn(
            'grid size-11 shrink-0 place-items-center rounded-sm transition-colors [&_svg]:size-5',
            selected ? 'bg-green text-white' : 'bg-warm-soft text-green',
          )}
        >
          {icon}
        </span>
      ) : null}

      <span className="min-w-0 flex-1">
        <span className="block text-[15px] font-medium text-ink">{title}</span>
        {description ? (
          <span className="mt-0.5 block text-[13px] text-ink-soft">{description}</span>
        ) : null}
      </span>

      <span
        className={cn(
          'grid size-6 shrink-0 place-items-center border-2 transition-all duration-200',
          multi ? 'rounded-[7px]' : 'rounded-full',
          selected ? 'border-green bg-green text-white' : 'border-[#D3DBD4] bg-white',
        )}
        aria-hidden
      >
        {selected ? (
          multi ? (
            <Check className="size-3.5" strokeWidth={3} />
          ) : (
            <span className="size-2.5 rounded-full bg-white" />
          )
        ) : null}
      </span>
    </button>
  );
}

/** Compact pill variant for dense multi-selects (interests, dietary). */
export function OptionPill({
  selected,
  onSelect,
  children,
  icon,
}: {
  selected: boolean;
  onSelect: () => void;
  children: React.ReactNode;
  icon?: React.ReactNode;
}) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={selected}
      onClick={onSelect}
      className={cn(
        'inline-flex items-center gap-2 rounded-full border px-4 py-2.5 text-[14px] font-medium',
        'transition-colors duration-200 active:scale-[0.98]',
        '[&_svg]:size-4',
        selected
          ? 'border-green bg-green text-white'
          : 'border-line bg-white text-ink hover:border-sage',
      )}
    >
      {icon}
      {children}
    </button>
  );
}

/* -------------------------------------------------------------- Switch --- */

export function Switch({
  checked,
  onCheckedChange,
  label,
  description,
  id,
}: {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  label?: React.ReactNode;
  description?: React.ReactNode;
  id?: string;
}) {
  const control = (
    <BaseSwitch.Root
      id={id}
      checked={checked}
      onCheckedChange={onCheckedChange}
      className={cn(
        'relative h-7 w-12 shrink-0 rounded-full p-0.5 transition-colors duration-200',
        'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
        checked ? 'bg-green' : 'bg-[#D8DFD9]',
      )}
    >
      <BaseSwitch.Thumb
        className={cn(
          'block size-6 rounded-full bg-white shadow-sm transition-transform duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
          // Direction-aware: RTL slides the other way.
          checked ? 'translate-x-5 rtl:-translate-x-5' : 'translate-x-0',
        )}
      />
    </BaseSwitch.Root>
  );

  if (!label) return control;

  return (
    <div className="flex items-center justify-between gap-4">
      <label htmlFor={id} className="min-w-0 cursor-pointer">
        <span className="block text-[15px] font-medium text-ink">{label}</span>
        {description ? (
          <span className="mt-0.5 block text-[13px] text-ink-soft">{description}</span>
        ) : null}
      </label>
      {control}
    </div>
  );
}
