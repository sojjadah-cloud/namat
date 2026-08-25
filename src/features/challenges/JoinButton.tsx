'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import { useRouter } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { joinChallenge, leaveChallenge } from '@/server/actions/challenges';

/**
 * Join and leave, as one sticky control at the foot of the detail screen.
 *
 * Leaving is a plain text button rather than a second filled one: it is the
 * rarer action and should not compete with the thing the screen is for.
 */
export function JoinButton({ slug, joined }: { slug: string; joined: boolean }) {
  const t = useTranslations('Challenges');
  const router = useRouter();
  const [pending, startTransition] = React.useTransition();

  const run = (action: () => Promise<unknown>) =>
    startTransition(async () => {
      await action();
      router.refresh();
    });

  if (joined) {
    return (
      <button
        type="button"
        disabled={pending}
        onClick={() => run(() => leaveChallenge(slug))}
        className="w-full py-3 text-center text-[14px] font-medium text-ink-soft transition-colors hover:text-danger disabled:opacity-50"
      >
        {t('leave')}
      </button>
    );
  }

  return (
    <Button
      size="xl"
      block
      loading={pending}
      onClick={() => run(() => joinChallenge(slug))}
    >
      {t('join')}
    </Button>
  );
}
