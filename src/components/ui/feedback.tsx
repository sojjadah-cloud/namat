import * as React from 'react';
import { cn } from '@/lib/utils';
import { Surface } from './card';

/* ------------------------------------------------------------ Skeleton ---
   Never show an empty white screen — every list has a shaped placeholder. */

export function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn('animate-pulse rounded-sm bg-[#E8EDE8]', className)}
      aria-hidden
      {...props}
    />
  );
}

export function SkeletonText({ lines = 2, className }: { lines?: number; className?: string }) {
  return (
    <div className={cn('space-y-2', className)}>
      {Array.from({ length: lines }).map((_, i) => (
        <Skeleton
          key={i}
          className={cn('h-3.5', i === lines - 1 ? 'w-2/3' : 'w-full')}
        />
      ))}
    </div>
  );
}

/** Matches ProviderCard so the swap on load is invisible. */
export function ProviderCardSkeleton() {
  return (
    <Surface pad="sm" radius="lg" className="flex gap-4">
      <Skeleton className="size-24 shrink-0 rounded-sm" />
      <div className="flex flex-1 flex-col justify-center gap-2.5">
        <Skeleton className="h-3 w-24" />
        <Skeleton className="h-4 w-40" />
        <Skeleton className="h-3 w-32" />
      </div>
    </Surface>
  );
}

export function ListSkeleton({ count = 3 }: { count?: number }) {
  return (
    <div className="space-y-4">
      {Array.from({ length: count }).map((_, i) => (
        <ProviderCardSkeleton key={i} />
      ))}
    </div>
  );
}

/* ---------------------------------------------------------- EmptyState ---
   Every empty state carries an action. No dead ends. */

export function EmptyState({
  icon,
  title,
  body,
  action,
  className,
  tone = 'warm',
}: {
  icon?: React.ReactNode;
  title: React.ReactNode;
  body?: React.ReactNode;
  action?: React.ReactNode;
  className?: string;
  tone?: 'warm' | 'plain';
}) {
  return (
    <div
      className={cn(
        'flex flex-col items-center rounded-xl px-6 py-10 text-center',
        tone === 'warm' ? 'bg-warm-soft' : '',
        className,
      )}
    >
      {icon ? (
        <div className="mb-4 grid size-14 place-items-center rounded-full bg-white text-green shadow-[var(--shadow-sm)] [&_svg]:size-6">
          {icon}
        </div>
      ) : null}
      <p className="text-[17px] font-semibold text-ink">{title}</p>
      {body ? <p className="mt-1.5 max-w-[38ch] text-[14px] text-ink-soft">{body}</p> : null}
      {action ? <div className="mt-5">{action}</div> : null}
    </div>
  );
}

/** Same shape as EmptyState but framed as a recoverable failure. */
export function ErrorState({
  title,
  body,
  action,
  className,
}: {
  title: React.ReactNode;
  body?: React.ReactNode;
  action?: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      role="alert"
      className={cn(
        'flex flex-col items-center rounded-xl bg-danger-soft px-6 py-10 text-center',
        className,
      )}
    >
      <p className="text-[17px] font-semibold text-ink">{title}</p>
      {body ? <p className="mt-1.5 max-w-[38ch] text-[14px] text-ink-soft">{body}</p> : null}
      {action ? <div className="mt-5">{action}</div> : null}
    </div>
  );
}
