'use client';

import * as React from 'react';
import { Tabs as BaseTabs } from '@base-ui/react/tabs';
import { cn } from '@/lib/utils';

/**
 * Two distinct switchers, deliberately not the same component:
 *
 * `Tabs`             underline indicator — top-level content switching
 *                    (Bookings: Upcoming / Past / Cancelled).
 * `SegmentedControl` filled pill — a local choice inside a section
 *                    (Journey: This week / This month).
 *
 * Both animate the indicator via Base UI's `--active-tab-*` vars, so RTL is
 * handled by the library rather than by mirrored maths here.
 */

export const TabsRoot = BaseTabs.Root;
export const TabsPanel = BaseTabs.Panel;

export function TabsList({
  className,
  children,
  ...props
}: React.ComponentProps<typeof BaseTabs.List>) {
  return (
    <BaseTabs.List
      className={cn(
        'relative flex items-center gap-1 border-b border-line',
        className,
      )}
      {...props}
    >
      {children}
      <BaseTabs.Indicator
        renderBeforeHydration
        className={cn(
          'absolute bottom-0 left-0 z-10 h-0.5 rounded-full bg-green',
          'w-[var(--active-tab-width)] translate-x-[var(--active-tab-left)]',
          'transition-[translate,width] duration-[260ms] ease-[cubic-bezier(.22,.61,.36,1)]',
        )}
      />
    </BaseTabs.List>
  );
}

export function TabsTab({
  className,
  ...props
}: React.ComponentProps<typeof BaseTabs.Tab>) {
  return (
    <BaseTabs.Tab
      className={cn(
        'relative -mb-px h-11 select-none px-4 text-sm font-medium text-ink-soft',
        'transition-colors duration-200 hover:text-ink',
        'data-[selected]:text-ink',
        'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
        className,
      )}
      {...props}
    />
  );
}

/* --------------------------------------------------- Segmented control ---
   Filled track, sliding white thumb. Never used for page-level navigation. */

export function SegmentedControl({
  className,
  children,
  ...props
}: React.ComponentProps<typeof BaseTabs.Root>) {
  return (
    <BaseTabs.Root {...props}>
      <BaseTabs.List
        className={cn(
          'relative inline-flex w-full items-center rounded-full bg-warm p-1',
          className,
        )}
      >
        <BaseTabs.Indicator
          renderBeforeHydration
          className={cn(
            'absolute top-1 left-0 z-0 h-[calc(100%-8px)] rounded-full bg-white shadow-[var(--shadow-sm)]',
            'w-[var(--active-tab-width)] translate-x-[var(--active-tab-left)]',
            'transition-[translate,width] duration-[260ms] ease-[cubic-bezier(.22,.61,.36,1)]',
          )}
        />
        {children}
      </BaseTabs.List>
    </BaseTabs.Root>
  );
}

export function SegmentedItem({
  className,
  ...props
}: React.ComponentProps<typeof BaseTabs.Tab>) {
  return (
    <BaseTabs.Tab
      className={cn(
        'relative z-10 h-9 flex-1 select-none rounded-full text-[13px] font-medium text-ink-soft',
        'transition-colors duration-200 data-[selected]:text-ink',
        'focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-green',
        className,
      )}
      {...props}
    />
  );
}
