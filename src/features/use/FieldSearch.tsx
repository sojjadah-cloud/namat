'use client';

import * as React from 'react';
import { useLocale, useTranslations } from 'next-intl';
import { useRouter } from '@/i18n/routing';
import { SearchField } from '@/components/ui/field';
import { cn } from '@/lib/utils';

/**
 * Search and filters for one field.
 *
 * State lives in the URL rather than in the component: a filtered view is then
 * shareable, survives a back navigation, and the list itself stays on the
 * server next to the data. The cost is a round trip per change, which at this
 * catalogue size is imperceptible and buys a lot of simplicity.
 *
 * Filters this catalogue cannot yet answer are rendered disabled rather than
 * hidden. Hiding them would quietly shrink the promise; showing them as
 * working would return wrong results. Disabled says what is true — the filter
 * exists, the data behind it does not yet.
 */

/** Filters backed by columns we actually populate today. */
const SUPPORTED = new Set([
  'nearest',
  'topRated',
  'delivery',
  'pickup',
  'subscriptions',
  'highProtein',
  'keto',
  'vegetarian',
  'supplements',
  'organic',
  'natural',
  'womenOnly',
]);

export function FieldSearch({
  fieldKey,
  placeholder,
  filters,
  active,
  initialQuery,
}: {
  fieldKey: string;
  placeholder: string;
  filters: string[];
  active: string[];
  initialQuery: string;
}) {
  const t = useTranslations('Use');
  const locale = useLocale();
  const router = useRouter();

  const [value, setValue] = React.useState(initialQuery);
  const [pending, startTransition] = React.useTransition();

  const push = (next: { q?: string; f?: string[] }) => {
    const params = new URLSearchParams();
    const q = next.q ?? value;
    const f = next.f ?? active;
    if (q.trim()) params.set('q', q.trim());
    if (f.length) params.set('f', f.join(','));

    const query = params.toString();
    startTransition(() => {
      router.replace(`/app/use/${fieldKey}${query ? `?${query}` : ''}`, { locale });
    });
  };

  const toggle = (key: string) => {
    const next = active.includes(key)
      ? active.filter((k) => k !== key)
      : [...active, key];
    push({ f: next });
  };

  return (
    <div>
      <div className="px-5">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            push({ q: value });
          }}
        >
          <SearchField
            value={value}
            placeholder={placeholder}
            onValueChange={setValue}
            onClear={() => {
              setValue('');
              push({ q: '' });
            }}
          />
        </form>
      </div>

      <div className="rail mt-3 gap-2 px-5">
        {filters.map((key) => {
          const on = active.includes(key);
          const supported = SUPPORTED.has(key);

          return (
            <button
              key={key}
              type="button"
              disabled={!supported || pending}
              onClick={() => toggle(key)}
              aria-pressed={on}
              title={supported ? undefined : t('countEmpty')}
              className={cn(
                'shrink-0 rounded-full px-3.5 py-2 text-[13px] font-medium transition-colors',
                on
                  ? 'bg-green text-white'
                  : 'bg-warm-soft text-ink-soft hover:text-ink',
                !supported && 'cursor-not-allowed opacity-40 hover:text-ink-soft',
              )}
            >
              {t(`filters.${key}`)}
            </button>
          );
        })}
      </div>
    </div>
  );
}
