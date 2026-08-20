'use client';

import * as React from 'react';
import { useSearchParams } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useRouter, usePathname } from '@/i18n/routing';
import { Chip } from '@/components/ui/chip';
import { CATEGORY_ORDER } from '@/lib/categories';

/**
 * Filter state lives in the URL, not in component state: a filtered Explore
 * view is a thing people send each other, and the back button should undo a
 * filter rather than leave the screen.
 */
export function CategoryChips() {
  const t = useTranslations('Categories');
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();
  const active = params.get('category') ?? 'all';

  const select = (category: string) => {
    const next = new URLSearchParams(params.toString());
    if (category === 'all') next.delete('category');
    else next.set('category', category);
    router.replace(`${pathname}?${next.toString()}`, { scroll: false });
  };

  return (
    <div className="rail gap-2 px-5">
      <Chip selected={active === 'all'} onClick={() => select('all')}>
        {t('all')}
      </Chip>
      {CATEGORY_ORDER.map((category) => (
        <Chip
          key={category}
          selected={active === category}
          onClick={() => select(category)}
        >
          {t(category)}
        </Chip>
      ))}
    </div>
  );
}

/** Quick filters: the four intents that actually change what people book. */
export function QuickFilters({ hasPackage }: { hasPackage: boolean }) {
  const t = useTranslations('Explore');
  const router = useRouter();
  const pathname = usePathname();
  const params = useSearchParams();

  const toggle = (key: string, value: string) => {
    const next = new URLSearchParams(params.toString());
    if (next.get(key) === value) next.delete(key);
    else next.set(key, value);
    router.replace(`${pathname}?${next.toString()}`, { scroll: false });
  };

  const on = (key: string, value: string) => params.get(key) === value;

  return (
    <div className="rail gap-2 px-5">
      <Chip
        size="sm"
        selected={on('sort', 'distance')}
        onClick={() => toggle('sort', 'distance')}
      >
        {t('quickNear')}
      </Chip>
      <Chip
        size="sm"
        selected={on('sort', 'rating')}
        onClick={() => toggle('sort', 'rating')}
      >
        {t('quickRated')}
      </Chip>
      <Chip size="sm" selected={on('women', '1')} onClick={() => toggle('women', '1')}>
        {t('filters.womenOnly')}
      </Chip>
      {hasPackage ? (
        <Chip
          size="sm"
          selected={on('included', '1')}
          onClick={() => toggle('included', '1')}
        >
          {t('quickIncluded')}
        </Chip>
      ) : null}
    </div>
  );
}
