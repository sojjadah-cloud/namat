import * as React from 'react';
import type { FoodTag, MenuProfile } from '@prisma/client';
import { MapPin } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { Rating } from '@/components/ui/avatar';
import { PartnerThumb } from '@/components/cards/PartnerThumb';
import { partnerSummary, partnerFulfilment } from '@/lib/partner-summary';
import { formatDistance } from '@/lib/format';
import { cn } from '@/lib/utils';

export interface ProviderCardData {
  slug: string;
  name: string;
  categoryLabel: string;
  image: string | null;
  rating: number | null;
  reviewCount: number;
  /** Kilometres from the user. Omitted when location is denied. */
  distanceKm?: number | null;
  tags?: string[];
  /** Covered by the member's active package — the strongest signal on the card. */
  included?: boolean;
  /** Drives the monogram colour and the generated one-line summary. */
  foodTags?: FoodTag[];
  menuProfile?: MenuProfile | null;
  area?: string | null;
  ownDelivery?: boolean | null;
  platformDelivery?: boolean | null;
  pickup?: boolean | null;
  weeklyPlan?: boolean | null;
  monthlyPlan?: boolean | null;
}

/**
 * The workhorse of Explore. Two shapes, same information hierarchy:
 * identity → trust → proximity → inclusion.
 *
 * `row`  the default list item — image on the start edge.
 * `tile` for horizontal rails on Home, where photography leads.
 */
export function ProviderCard({
  provider,
  locale,
  variant = 'row',
  className,
}: {
  provider: ProviderCardData;
  locale: string;
  variant?: 'row' | 'tile';
  className?: string;
}) {
  const t = useTranslations('Provider');
  const { slug, name, categoryLabel, image, rating, reviewCount, distanceKm, tags, included } =
    provider;

  // "أكل صحي" on all thirty-four food cards told a member nothing. This says
  // what the place actually makes and where it is, from their own data.
  const summary =
    provider.foodTags && provider.foodTags.length > 0
      ? partnerSummary(
          {
            foodTags: provider.foodTags,
            menuProfile: provider.menuProfile ?? null,
            area: provider.area ?? null,
            ownDelivery: provider.ownDelivery ?? null,
            platformDelivery: provider.platformDelivery ?? null,
            pickup: provider.pickup ?? null,
            weeklyPlan: provider.weeklyPlan ?? null,
            monthlyPlan: provider.monthlyPlan ?? null,
          },
          locale,
        )
      : null;

  const fulfilment = provider.foodTags
    ? partnerFulfilment(
        {
          foodTags: provider.foodTags,
          menuProfile: provider.menuProfile ?? null,
          area: provider.area ?? null,
          ownDelivery: provider.ownDelivery ?? null,
          platformDelivery: provider.platformDelivery ?? null,
          pickup: provider.pickup ?? null,
          weeklyPlan: provider.weeklyPlan ?? null,
          monthlyPlan: provider.monthlyPlan ?? null,
        },
        locale,
      )
    : [];

  const meta = (
    <div className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1">
      {reviewCount > 0 ? (
        <Rating value={rating} count={reviewCount} locale={locale} size="sm" />
      ) : null}
      {typeof distanceKm === 'number' ? (
        <span className="inline-flex items-center gap-1 text-[12px] text-ink-soft">
          <MapPin className="size-3.5" aria-hidden />
          {formatDistance(distanceKm, locale)}
        </span>
      ) : null}
    </div>
  );

  if (variant === 'tile') {
    return (
      <Link
        href={`/app/explore/${slug}`}
        className={cn(
          'group block w-56 overflow-hidden rounded-lg bg-white shadow-[var(--shadow-sm)]',
          'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
          'hover:shadow-[var(--shadow-md)] active:scale-[0.99]',
          className,
        )}
      >
        <div className="relative h-32 w-full overflow-hidden">
          <PartnerThumb
            image={image}
            name={name}
            tags={provider.foodTags ?? []}
            sizes="224px"
            rounded="rounded-none"
            className="absolute inset-0 size-full"
          />
          {included ? (
            <Badge tone="included" className="absolute start-3 top-3">
              {t('included')}
            </Badge>
          ) : null}
        </div>
        <div className="p-3.5">
          <p className="truncate text-[15px] font-semibold text-ink">{name}</p>
          <p className="mt-0.5 line-clamp-2 text-[12px] leading-snug text-ink-soft">
            {summary ?? categoryLabel}
          </p>
          {meta}
        </div>
      </Link>
    );
  }

  return (
    <Link
      href={`/app/explore/${slug}`}
      className={cn(
        'group flex gap-3.5 rounded-lg bg-white p-3 shadow-[var(--shadow-sm)]',
        'transition-[transform,box-shadow] duration-200 ease-[cubic-bezier(.22,.61,.36,1)]',
        'hover:shadow-[var(--shadow-md)] active:scale-[0.99]',
        className,
      )}
    >
      <PartnerThumb
        image={image}
        name={name}
        tags={provider.foodTags ?? []}
        sizes="96px"
        rounded="rounded-sm"
        className="size-24 shrink-0"
      />

      <div className="min-w-0 flex-1 py-0.5">
        <div className="flex items-start justify-between gap-2">
          <p className="truncate text-[15px] font-semibold text-ink">{name}</p>
          {included ? (
            <Badge tone="included" className="shrink-0">
              {t('included')}
            </Badge>
          ) : null}
        </div>
        <p className="mt-0.5 line-clamp-2 text-[12px] leading-snug text-ink-soft">
          {summary ?? categoryLabel}
        </p>
        {meta}
        {fulfilment.length > 0 || tags?.length ? (
          <div className="mt-2 flex flex-wrap gap-1.5">
            {/* Only verified capabilities appear — an unconfirmed one is
                absent rather than shown as unavailable. */}
            {fulfilment.map((f) => (
              <Badge key={f} tone="neutral">
                {f}
              </Badge>
            ))}
            {tags?.slice(0, 2).map((tag) => (
              <Badge key={tag} tone="neutral">
                {tag}
              </Badge>
            ))}
          </div>
        ) : null}
      </div>
    </Link>
  );
}
