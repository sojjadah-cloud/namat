'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { TabsRoot, TabsList, TabsTab, TabsPanel } from '@/components/ui/tabs';
import { formatNumber } from '@/lib/format';

/**
 * The three lists are rendered on the server and passed in as panels — the tab
 * strip is the only part that needs to be interactive, so it is the only part
 * that ships to the browser.
 */
export function BookingTabs({
  upcoming,
  past,
  cancelled,
  counts,
}: {
  upcoming: React.ReactNode;
  past: React.ReactNode;
  cancelled: React.ReactNode;
  counts: { upcoming: number; past: number; cancelled: number };
}) {
  const locale = useLocale();
  const t = useTranslations('Bookings');

  return (
    <TabsRoot defaultValue="upcoming">
      <div className="px-5">
        <TabsList>
          <TabsTab value="upcoming">
            {t('upcoming')}
            {counts.upcoming > 0 ? (
              <span className="ms-1.5 text-[12px] text-ink-soft">
                {formatNumber(counts.upcoming, locale)}
              </span>
            ) : null}
          </TabsTab>
          <TabsTab value="past">{t('past')}</TabsTab>
          <TabsTab value="cancelled">{t('cancelled')}</TabsTab>
        </TabsList>
      </div>

      <TabsPanel value="upcoming" className="mt-5 space-y-3 px-5">
        {upcoming}
      </TabsPanel>
      <TabsPanel value="past" className="mt-5 space-y-3 px-5">
        {past}
      </TabsPanel>
      <TabsPanel value="cancelled" className="mt-5 space-y-3 px-5">
        {cancelled}
      </TabsPanel>
    </TabsRoot>
  );
}
