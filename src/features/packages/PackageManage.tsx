'use client';

import * as React from 'react';
import { useTranslations } from 'next-intl';
import { Pause, Play, Repeat, XCircle } from 'lucide-react';
import { Link, useRouter } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { ConfirmSheet } from '@/components/ui/sheet';
import { useToast } from '@/components/ui/toast';
import {
  pauseMembership,
  resumeMembership,
  cancelRenewal,
} from '@/server/actions/membership';

/**
 * Management actions, ordered by how reversible they are. Pause is first and
 * ordinary; cancelling renewal is last, and both destructive paths state the
 * consequence in a sheet before they can be taken.
 */
export function PackageManage({
  status,
  endsLabel,
}: {
  status: 'ACTIVE' | 'PAUSED' | 'EXPIRED' | 'CANCELLED';
  /** The date the current period runs to, already formatted. */
  endsLabel: string;
}) {
  const t = useTranslations('Packages.detail');
  const tc = useTranslations('Common');
  const router = useRouter();
  const toast = useToast();

  const [pauseOpen, setPauseOpen] = React.useState(false);
  const [cancelOpen, setCancelOpen] = React.useState(false);
  const [pending, startTransition] = React.useTransition();

  const run = (fn: () => Promise<{ ok: boolean }>, message: string, close: () => void) =>
    startTransition(async () => {
      const result = await fn();
      if (!result.ok) {
        toast.error(tc('retry'));
        return;
      }
      close();
      toast.success(message);
      router.refresh();
    });

  return (
    <>
      <div className="space-y-2.5">
        {status === 'PAUSED' ? (
          <Button
            block
            size="lg"
            loading={pending}
            onClick={() => run(resumeMembership, t('resume'), () => {})}
          >
            <Play />
            {t('resume')}
          </Button>
        ) : (
          <Button block variant="secondary" size="lg" onClick={() => setPauseOpen(true)}>
            <Pause />
            {t('pause')}
          </Button>
        )}

        <Button asChild block variant="secondary" size="lg">
          <Link href="/app/packages">
            <Repeat />
            {t('change')}
          </Link>
        </Button>

        <Button block variant="ghost" size="lg" onClick={() => setCancelOpen(true)}>
          <XCircle />
          {t('cancelRenewal')}
        </Button>
      </div>

      <ConfirmSheet
        open={pauseOpen}
        onOpenChange={setPauseOpen}
        title={t('pauseTitle')}
        body={t('pauseBody')}
        confirmLabel={t('pauseConfirm')}
        cancelLabel={tc('cancel')}
        tone="primary"
        pending={pending}
        onConfirm={() => run(pauseMembership, t('pausedTitle'), () => setPauseOpen(false))}
      />

      <ConfirmSheet
        open={cancelOpen}
        onOpenChange={setCancelOpen}
        title={t('cancelTitle')}
        body={t('cancelBody', { date: endsLabel })}
        confirmLabel={t('cancelConfirm')}
        cancelLabel={tc('cancel')}
        pending={pending}
        onConfirm={() => run(cancelRenewal, t('cancelConfirm'), () => setCancelOpen(false))}
      />
    </>
  );
}
