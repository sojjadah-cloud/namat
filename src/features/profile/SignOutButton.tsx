'use client';

import * as React from 'react';
import { signOut } from 'next-auth/react';
import { useLocale } from 'next-intl';

export function SignOutButton({ label, icon }: { label: string; icon?: React.ReactNode }) {
  const locale = useLocale();
  const [pending, startTransition] = React.useTransition();

  return (
    <button
      type="button"
      disabled={pending}
      onClick={() =>
        startTransition(async () => {
          // Land on the marketing site in the language they were using, not on
          // a locale-less URL the proxy then has to guess about.
          await signOut({ callbackUrl: `/${locale}` });
        })
      }
      className={[
        'flex h-13 w-full items-center justify-center gap-2.5 rounded-sm',
        'border border-line bg-white text-[15px] font-medium text-danger',
        'transition-colors hover:bg-danger-soft disabled:opacity-50',
        '[&_svg]:size-[18px]',
      ].join(' ')}
    >
      {icon}
      {label}
    </button>
  );
}
