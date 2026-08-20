'use client';

import * as React from 'react';
import { Toast } from '@base-ui/react/toast';
import { Check, Info, TriangleAlert, X } from 'lucide-react';
import { cn } from '@/lib/utils';

/**
 * Confirmation that does not interrupt: "Saved", "Booking cancelled",
 * "Added to favourites". Anything the user must acknowledge is a ConfirmSheet,
 * not a toast.
 *
 * Toasts sit above the bottom navigation on mobile and in the bottom-end
 * corner on desktop.
 */

export const ToastProvider = Toast.Provider;

const icons = {
  success: Check,
  error: TriangleAlert,
  info: Info,
} as const;

type ToastTone = keyof typeof icons;

function ToastItem({ toast }: { toast: Toast.Root.ToastObject }) {
  const tone = (toast.type as ToastTone) in icons ? (toast.type as ToastTone) : 'info';
  const Icon = icons[tone];

  return (
    <Toast.Root
      toast={toast}
      className={cn(
        'pointer-events-auto w-full rounded-md bg-ink px-4 py-3.5 text-white shadow-[var(--shadow-lg)]',
        'flex items-start gap-3',
        'transition-[opacity,transform] duration-[260ms] ease-[cubic-bezier(.22,.61,.36,1)]',
        'data-[starting-style]:translate-y-3 data-[starting-style]:opacity-0',
        'data-[ending-style]:translate-y-3 data-[ending-style]:opacity-0',
      )}
    >
      <span
        className={cn(
          'mt-0.5 grid size-5 shrink-0 place-items-center rounded-full',
          tone === 'success' && 'bg-sage text-ink',
          tone === 'error' && 'bg-danger text-white',
          tone === 'info' && 'bg-white/15 text-white',
        )}
      >
        <Icon className="size-3.5" strokeWidth={2.5} aria-hidden />
      </span>

      <div className="min-w-0 flex-1">
        <Toast.Title className="text-sm font-medium leading-snug" />
        <Toast.Description className="mt-0.5 text-[13px] leading-snug text-white/70" />
      </div>

      {toast.actionProps ? (
        <Toast.Action className="shrink-0 text-[13px] font-medium text-accent underline-offset-4 hover:underline" />
      ) : null}

      <Toast.Close
        aria-label="Close"
        className="-me-1 -mt-1 shrink-0 rounded-full p-1.5 text-white/50 transition-colors hover:bg-white/10 hover:text-white"
      >
        <X className="size-4" aria-hidden />
      </Toast.Close>
    </Toast.Root>
  );
}

export function ToastViewport() {
  const { toasts } = Toast.useToastManager();

  return (
    <Toast.Portal>
      <Toast.Viewport
        className={cn(
          'pointer-events-none fixed z-90 flex flex-col gap-2',
          // Clear of the bottom navigation on mobile; corner-anchored on desktop.
          'inset-x-4 bottom-[calc(72px+env(safe-area-inset-bottom)+12px)]',
          'md:inset-x-auto md:bottom-6 md:end-6 md:w-88',
        )}
      >
        {toasts.map((toast) => (
          <ToastItem key={toast.id} toast={toast} />
        ))}
      </Toast.Viewport>
    </Toast.Portal>
  );
}

/**
 * `const toast = useToast(); toast.success(t('saved'))`
 */
export function useToast() {
  const manager = Toast.useToastManager();

  return React.useMemo(
    () => ({
      success: (title: React.ReactNode, description?: React.ReactNode) =>
        manager.add({ title, description, type: 'success' }),
      error: (title: React.ReactNode, description?: React.ReactNode) =>
        manager.add({ title, description, type: 'error', priority: 'high' }),
      info: (title: React.ReactNode, description?: React.ReactNode) =>
        manager.add({ title, description, type: 'info' }),
    }),
    [manager],
  );
}
