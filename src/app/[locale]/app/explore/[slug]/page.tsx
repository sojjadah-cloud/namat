import { notFound } from 'next/navigation';
import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { Clock, MapPin, Phone, Navigation } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { BackBar } from '@/components/layout/AppHeader';
import { Badge } from '@/components/ui/chip';
import { Rating, Avatar } from '@/components/ui/avatar';
import { Button } from '@/components/ui/button';
import { Surface, SectionHeader } from '@/components/ui/card';
import { EmptyState } from '@/components/ui/feedback';
import { ServiceCard } from '@/components/cards/ServiceCard';
import { getProvider } from '@/server/queries/explore';
import { formatPrice, formatDateShort, formatNumber } from '@/lib/format';
import { pick, pickList } from '@/lib/localized';
import { providerImage } from '@/lib/provider-image';

/**
 * Provider detail is the conversion screen: gallery, who they are, what they
 * offer, and a booking bar that never leaves the viewport. Everything else —
 * reviews, hours, location — sits below the decision, not in front of it.
 */
export default async function ProviderPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const locale = await getLocale();
  const t = await getTranslations('Provider');
  const tc = await getTranslations('Common');
  const tcat = await getTranslations('Categories');

  const provider = await getProvider(slug);
  if (!provider) notFound();

  const name = pick(provider, 'name', locale);
  const tags = pickList(provider, 'tags', locale);
  const cheapest = provider.services.length
    ? Math.min(...provider.services.map((s) => s.price))
    : null;
  const anyIncluded = provider.services.some((s) => s.included);

  return (
    <div className="pb-28">
      {/* ----------------------------------------------------------- Hero --- */}
      <div className="relative">
        <div className="relative h-64 w-full overflow-hidden">
          <Image
            src={providerImage(provider.image, provider.category)}
            alt=""
            fill
            priority
            sizes="(max-width: 768px) 100vw, 430px"
            className="object-cover"
          />
          <div className="absolute inset-x-0 top-0 h-28 bg-gradient-to-b from-ink/35 to-transparent" />
        </div>
        <div className="absolute inset-x-0 top-0">
          <BackBar transparent />
        </div>
      </div>

      {/* ------------------------------------------------------- Identity --- */}
      <div className="relative -mt-6 rounded-t-editorial bg-canvas px-5 pt-6">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <p className="text-[12px] font-medium uppercase tracking-[0.14em] text-ink-soft">
              {tcat(provider.category)}
            </p>
            <h1 className="mt-1.5 text-[26px] font-semibold leading-tight text-ink">
              {name}
            </h1>
          </div>
          {anyIncluded ? (
            <Badge tone="included" size="md" className="mt-1 shrink-0">
              {t('included')}
            </Badge>
          ) : null}
        </div>

        <div className="mt-3 flex flex-wrap items-center gap-x-4 gap-y-2">
          <Rating value={provider.rating} count={provider.reviewCount} locale={locale} />
          <span className="inline-flex items-center gap-1 text-[13px] text-ink-soft">
            <MapPin className="size-4" aria-hidden />
            {pick(provider, 'address', locale)}
          </span>
        </div>

        {tags.length ? (
          <div className="mt-4 flex flex-wrap gap-2">
            {tags.map((tag) => (
              <Badge key={tag} tone="neutral" size="md">
                {tag}
              </Badge>
            ))}
          </div>
        ) : null}

        {/* Gallery is secondary to identity, so it comes after the name. */}
        {provider.gallery.length ? (
          <div className="rail -mx-5 mt-5 gap-3 px-5">
            {provider.gallery.map((src) => (
              <div
                key={src}
                className="relative h-32 w-48 overflow-hidden rounded-md bg-warm"
              >
                <Image src={src} alt="" fill sizes="192px" className="object-cover" />
              </div>
            ))}
          </div>
        ) : null}

        {/* ---------------------------------------------------------- About --- */}
        <section className="mt-8">
          <SectionHeader title={t('about')} className="mb-3" />
          <p className="text-[15px] leading-relaxed text-ink-soft">
            {pick(provider, 'about', locale)}
          </p>
        </section>

        {/* ------------------------------------------------------- Services --- */}
        <section className="mt-8">
          <SectionHeader title={t('services')} className="mb-3" />
          <div className="space-y-2.5">
            {provider.services.map((s) => (
              <Link key={s.id} href={`/app/book/${s.id}`} className="block">
                <ServiceCard
                  locale={locale}
                  service={{
                    id: s.id,
                    name: pick(s, 'name', locale),
                    description: pick(s, 'desc', locale) || null,
                    duration: s.duration,
                    price: s.price,
                    included: s.included,
                  }}
                />
              </Link>
            ))}
          </div>
        </section>

        {/* -------------------------------------------------------- Reviews --- */}
        <section className="mt-8">
          <SectionHeader
            title={t('reviews')}
            action={
              provider.reviewCount > 0 ? (
                <span className="text-[13px] text-ink-soft">
                  {t('reviewCount', { count: formatNumber(provider.reviewCount, locale) })}
                </span>
              ) : null
            }
            className="mb-3"
          />
          {provider.reviews.length ? (
            <div className="space-y-3">
              {provider.reviews.map((r) => (
                <Surface key={r.id} radius="md" pad="md">
                  <div className="flex items-center gap-3">
                    <Avatar name={r.user.name} src={r.user.image} size="sm" />
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-[14px] font-medium text-ink">
                        {r.user.name ?? '—'}
                      </p>
                      <p className="text-[12px] text-ink-soft">
                        {formatDateShort(r.createdAt, locale)}
                      </p>
                    </div>
                    <Rating value={r.rating} locale={locale} size="sm" />
                  </div>
                  {pick(r, 'body', locale) ? (
                    <p className="mt-3 text-[14px] leading-snug text-ink-soft">
                      {pick(r, 'body', locale)}
                    </p>
                  ) : null}
                </Surface>
              ))}
            </div>
          ) : (
            <EmptyState title={t('noReviews')} body={t('noReviewsBody')} />
          )}
        </section>

        {/* ------------------------------------------------------- Location --- */}
        <section className="mt-8">
          <SectionHeader title={t('location')} className="mb-3" />
          <Surface radius="md" pad="md">
            <p className="text-[15px] text-ink">{pick(provider, 'address', locale)}</p>
            <p className="mt-1 text-[13px] text-ink-soft">
              {pick(provider.city, 'name', locale)}
            </p>

            {pick(provider, 'hours', locale) ? (
              <p className="mt-4 flex items-start gap-2 text-[13px] text-ink-soft">
                <Clock className="mt-0.5 size-4 shrink-0" aria-hidden />
                <span>{pick(provider, 'hours', locale)}</span>
              </p>
            ) : null}

            <div className="mt-4 flex flex-wrap gap-2">
              <Button asChild variant="secondary" size="sm">
                <a
                  href={`https://www.google.com/maps/search/?api=1&query=${provider.latitude},${provider.longitude}`}
                  target="_blank"
                  rel="noreferrer"
                >
                  <Navigation className="rtl-flip" />
                  {tc('directions')}
                </a>
              </Button>
              {provider.phone ? (
                <Button asChild variant="secondary" size="sm">
                  <a href={`tel:${provider.phone.replace(/\s/g, '')}`}>
                    <Phone />
                    {t('call')}
                  </a>
                </Button>
              ) : null}
            </div>
          </Surface>
        </section>

        {/* ------------------------------------------------------- Policy --- */}
        <section className="mt-8">
          <Surface tone="warmSoft" radius="md" pad="md" elevation="none">
            <p className="text-[12px] font-medium uppercase tracking-[0.14em] text-ink-soft">
              {t('important')}
            </p>
            <p className="mt-2 text-[14px] leading-snug text-ink-soft">{t('policy')}</p>
          </Surface>
        </section>
      </div>

      {/* -------------------------------------------------- Sticky book bar --- */}
      {provider.services.length ? (
        <div className="fixed inset-x-0 bottom-[calc(72px+env(safe-area-inset-bottom))] z-40 md:absolute">
          <div className="mx-auto flex max-w-[430px] items-center gap-4 border-t border-line/70 bg-canvas/90 px-5 py-3 backdrop-blur-xl">
            <div className="min-w-0 flex-1">
              {anyIncluded ? (
                <p className="text-[14px] font-semibold text-green">{t('included')}</p>
              ) : cheapest != null ? (
                <>
                  <p className="text-[11px] text-ink-soft">{tc('from')}</p>
                  <p className="text-[17px] font-semibold leading-tight text-ink">
                    {formatPrice(cheapest, locale)}
                  </p>
                </>
              ) : null}
            </div>
            <Button asChild size="lg">
              <Link href={`/app/book/${provider.services[0].id}`}>{t('book')}</Link>
            </Button>
          </div>
        </div>
      ) : null}
    </div>
  );
}
