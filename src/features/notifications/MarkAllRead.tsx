'use client';

import * as React from 'react';
import { useRouter } from '@/i18n/routing';
import { markNotificationsRead } from '@/server/actions/profile';

export function MarkAllRead({ label }: { label: string }) {
  const router = useRouter();
  const [pending, startTransition] = React.useTransition();

  return (
    <button
      type="button"
      disabled={pending}
      onClick={() =>
        startTransition(async () => {
          await markNotificationsRead();
          router.refresh();
        })
      }
      className="text-[13px] font-medium text-green underline-offset-4 hover:underline disabled:opacity-50"
    >
      {label}
    </button>
  );
}
