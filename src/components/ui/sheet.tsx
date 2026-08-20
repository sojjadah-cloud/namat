'use client';

import * as React from 'react';
import { Drawer } from '@base-ui/react/drawer';
import { cn } from '@/lib/utils';

/**
 * Native-feeling mobile bottom sheet — used for filters, date/time, payment,
 * package options and confirmations. Built on Base UI Drawer so swipe-to-dismiss,
 * focus trapping and scroll locking come for free.
 */

export function BottomSheet({
  open,
  onOpenChange,
  trigger,
  title,
  description,
  children,
  footer,
  /** Sheets that own the full height (filters) vs. hug their content (confirm). */
  size = 'auto',
  className,
}: {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  trigger?: React.ReactNode;
  title?: React.ReactNode;
  description?: React.ReactNode;
  children?: React.ReactNode;
  footer?: React.ReactNode;
  size?: 'auto' | 'tall';
  className?: string;
}) {
  return (
    <Drawer.Root open={open} onOpenChange={onOpenChange} swipeDirection="down">
      {trigger ? <Drawer.Trigger render={trigger as React.ReactElement} /> : null}
      <Drawer.Portal>
        <Drawer.Backdrop
          className={cn(
            'fixed inset-0 z-50 bg-ink/35 backdrop-blur-[2px]',
            'transition-opacity duration-200',
            'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0',
          )}
        />
        <Drawer.Viewport className="fixed inset-0 z-50 flex items-end justify-center">
          <Drawer.Popup
            className={cn(
              'relative w-full max-w-[520px] rounded-t-[28px] bg-canvas',
              'shadow-[0_-10px_40px_rgba(23,32,26,0.12)]',
              'transition-transform duration-[280ms] ease-[cubic-bezier(.22,.61,.36,1)]',
              'data-[starting-style]:translate-y-full data-[ending-style]:translate-y-full',
              size === 'tall' ? 'h-[88dvh]' : 'max-h-[88dvh]',
              'flex flex-col',
              className,
            )}
          >
            <Drawer.SwipeArea className="shrink-0 cursor-grab pt-3 pb-1">
              <span className="mx-auto block h-1 w-10 rounded-full bg-ink/15" aria-hidden />
            </Drawer.SwipeArea>

            {title ? (
              <div className="shrink-0 px-6 pt-2 pb-4">
                <Drawer.Title className="text-[20px] font-semibold text-ink">
                  {title}
                </Drawer.Title>
                {description ? (
                  <Drawer.Description className="mt-1 text-[14px] text-ink-soft">
                    {description}
                  </Drawer.Description>
                ) : null}
              </div>
            ) : null}

            <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-6 pb-2">
              {children}
            </div>

            {footer ? (
              <div className="safe-bottom shrink-0 border-t border-line bg-white/80 px-6 py-4 backdrop-blur">
                {footer}
              </div>
            ) : (
              <div className="safe-bottom h-2 shrink-0" />
            )}
          </Drawer.Popup>
        </Drawer.Viewport>
      </Drawer.Portal>
    </Drawer.Root>
  );
}

export const SheetClose = Drawer.Close;

/**
 * Destructive confirmations (cancel booking, pause package) always go through
 * a sheet so the consequence is stated before the action is possible.
 */
export function ConfirmSheet({
  open,
  onOpenChange,
  title,
  body,
  confirmLabel,
  cancelLabel,
  onConfirm,
  tone = 'danger',
  pending,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: React.ReactNode;
  body?: React.ReactNode;
  confirmLabel: React.ReactNode;
  cancelLabel: React.ReactNode;
  onConfirm: () => void;
  tone?: 'danger' | 'primary';
  pending?: boolean;
}) {
  return (
    <BottomSheet open={open} onOpenChange={onOpenChange} title={title} description={body}>
      <div className="flex flex-col gap-2.5 pt-2 pb-4">
        <button
          type="button"
          onClick={onConfirm}
          disabled={pending}
          className={cn(
            'h-13 rounded-sm text-[15px] font-medium transition-colors active:scale-[0.985] disabled:opacity-50',
            tone === 'danger'
              ? 'bg-danger text-white hover:bg-[#9E3F37]'
              : 'bg-green text-white hover:bg-green-deep',
          )}
        >
          {confirmLabel}
        </button>
        <button
          type="button"
          onClick={() => onOpenChange(false)}
          className="h-13 rounded-sm border border-line bg-white text-[15px] font-medium text-ink transition-colors hover:bg-warm-soft"
        >
          {cancelLabel}
        </button>
      </div>
    </BottomSheet>
  );
}
