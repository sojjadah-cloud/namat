import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Check, CalendarCheck, Sparkles, Quote } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/chip';
import { Surface } from '@/components/ui/card';
import { Section, Eyebrow, SectionTitle, SectionLead } from '@/components/marketing/Section';
import { PackageCard } from '@/components/cards/PackageCard';
import { LogoMark } from '@/components/brand/Logo';
import { prisma } from '@/lib/prisma';
import { getPackages } from '@/server/queries/journey';
import { CATEGORY_ORDER, CATEGORY_META, PILLARS } from '@/lib/categories';
import { formatNumber } from '@/lib/format';
import { pick, pickList } from '@/lib/localized';

/**
 * The landing page sells the idea, not the feature list: what a healthier week
 * looks like when the pieces already exist and someone finally connected them.
 *
 * Sections alternate canvas / warm / sage / deep green so a long scroll reads
 * as chapters rather than one endless page.
 */
export default async function LandingPage() {
  const locale = await getLocale();
  const t = await getTranslations('Landing');
  const tcat = await getTranslations('Categories');
  const tb = await getTranslations('Brand');

  const [packages, partners, counts] = await Promise.all([
    getPackages(),
    prisma.partner.findMany({ take: 12 }),
    Promise.all([
      prisma.provider.count({ where: { isActive: true } }),
      prisma.service.count({ where: { isActive: true } }),
    ]),
  ]);

  const [providerCount, serviceCount] = counts;

  return (
    <>
      {/* ============================================================ Hero === */}
      <section className="bloom relative overflow-hidden px-5 pt-32 pb-20 md:px-8 md:pt-40 md:pb-28">
        <div className="mx-auto grid max-w-[1240px] items-center gap-14 lg:grid-cols-[1.05fr_1fr]">
          <div>
            <Badge tone="soft" size="md">
              <Sparkles aria-hidden />
              {tb('taglineShort')}
            </Badge>

            <h1 className="display mt-6 text-[42px] text-ink text-balance md:text-[68px] lg:text-[76px]">
              {t('hero.titleA')}
              <br />
              <span className="text-green-accent">{t('hero.titleB')}</span>
              <br />
              {t('hero.titleC')}
            </h1>

            <p className="mt-7 max-w-[52ch] text-[17px] leading-relaxed text-ink-soft md:text-[19px]">
              {t('hero.body')}
            </p>

            <div className="mt-9 flex flex-wrap gap-3">
              <Button asChild size="xl">
                <Link href="/welcome">
                  {t('hero.primary')}
                  <ArrowRight className="rtl-flip" />
                </Link>
              </Button>
              <Button asChild variant="secondary" size="xl">
                <Link href="/services">{t('hero.secondary')}</Link>
              </Button>
            </div>
          </div>

          {/* A collage rather than a phone frame: the product is the week it
              produces, not the chrome around it. */}
          <div className="relative">
            <div className="relative aspect-[4/5] w-full overflow-hidden rounded-editorial shadow-[var(--shadow-lg)]">
              <Image
                src="https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=1200&q=75"
                alt=""
                fill
                priority
                sizes="(max-width: 1024px) 100vw, 560px"
                className="object-cover"
              />
            </div>

            <FloatingChip
              className="-start-4 top-10 md:-start-10"
              icon={<CalendarCheck aria-hidden />}
              label={t('hero.chipBooking')}
            />
            <FloatingChip
              className="-end-3 top-1/3 md:-end-8"
              icon={<Sparkles aria-hidden />}
              label={t('hero.chipRecommendation')}
              tone="green"
            />
            <FloatingChip
              className="-start-3 bottom-24 md:-start-8"
              icon={<Check aria-hidden />}
              label={t('hero.chipProgress')}
            />
            <FloatingChip
              className="-end-4 bottom-10 md:-end-10"
              icon={<LogoMark className="size-4" />}
              label={t('hero.chipPackage')}
            />
          </div>
        </div>
      </section>

      {/* =========================================================== Trust === */}
      <Section tone="warm">
        <div className="grid gap-10 md:grid-cols-[1fr_1.2fr] md:items-end">
          <SectionTitle className="mt-0">{t('trust.title')}</SectionTitle>
          <div className="grid grid-cols-3 gap-6">
            <Stat value={formatNumber(providerCount, locale)} label={t('trust.partners')} />
            <Stat value={formatNumber(serviceCount, locale)} label={t('trust.services')} />
            <Stat value={formatNumber(CATEGORY_ORDER.length, locale)} label={t('trust.experts')} />
          </div>
        </div>
        <p className="mt-10 text-[14px] text-ink-soft">{t('trust.note')}</p>
      </Section>

      {/* ========================================================= Pillars === */}
      <Section>
        <Eyebrow>{t('pillars.eyebrow')}</Eyebrow>
        <SectionTitle>{t('pillars.title')}</SectionTitle>
        <SectionLead>{t('pillars.body')}</SectionLead>

        <div className="mt-14 grid gap-5 md:grid-cols-3">
          {PILLARS.map(({ key, icon: Icon, categories }) => (
            <Surface key={key} radius="xl" pad="xl" className="flex flex-col">
              <span className="grid size-12 place-items-center rounded-md bg-green-soft text-green">
                <Icon className="size-6" strokeWidth={1.8} aria-hidden />
              </span>
              <h3 className="mt-6 text-[24px] font-semibold text-ink">
                {t(`pillars.${key}`)}
              </h3>
              <p className="mt-3 flex-1 text-[15px] leading-relaxed text-ink-soft">
                {t(`pillars.${key}Body`)}
              </p>
              <div className="mt-6 flex flex-wrap gap-2">
                {categories.map((c) => (
                  <span
                    key={c}
                    className={`rounded-full px-3 py-1.5 text-[12px] font-medium ${CATEGORY_META[c].bg} ${CATEGORY_META[c].fg}`}
                  >
                    {tcat(c)}
                  </span>
                ))}
              </div>
            </Surface>
          ))}
        </div>
      </Section>

      {/* ======================================================= Ecosystem === */}
      <Section tone="bloom">
        <Eyebrow>{t('ecosystem.eyebrow')}</Eyebrow>
        <SectionTitle>{t('ecosystem.title')}</SectionTitle>
        <SectionLead>{t('ecosystem.body')}</SectionLead>

        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {CATEGORY_ORDER.map((category, i) => {
            const meta = CATEGORY_META[category];
            const Icon = meta.icon;
            // The first tile runs tall so the grid reads as editorial rather
            // than as a uniform sheet of cards.
            const tall = i === 0;
            return (
              <Link
                key={category}
                href="/services"
                className={`group relative overflow-hidden rounded-xl ${tall ? 'lg:row-span-2 lg:aspect-auto' : ''} aspect-[4/3]`}
              >
                <Image
                  src={meta.image}
                  alt=""
                  fill
                  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 300px"
                  className="object-cover transition-transform duration-500 group-hover:scale-[1.05]"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-ink/80 via-ink/25 to-transparent" />
                <div className="absolute inset-x-0 bottom-0 p-5">
                  <span
                    className="mb-3 grid size-9 place-items-center rounded-full bg-white/90"
                    style={{ color: meta.hex }}
                  >
                    <Icon className="size-[18px]" strokeWidth={2} aria-hidden />
                  </span>
                  <p className="text-[17px] font-semibold text-white">{tcat(category)}</p>
                  <p className="mt-1 line-clamp-2 text-[13px] leading-snug text-white/70">
                    {tcat(`desc.${category}`)}
                  </p>
                </div>
              </Link>
            );
          })}
        </div>
      </Section>

      {/* ==================================================== How it works === */}
      <Section tone="sage">
        <Eyebrow>{t('how.eyebrow')}</Eyebrow>
        <SectionTitle>{t('how.title')}</SectionTitle>

        <ol className="mt-14 grid gap-8 md:grid-cols-3">
          {(['s1', 's2', 's3'] as const).map((step, i) => (
            <li key={step}>
              <span className="display text-[56px] text-green-accent">
                {formatNumber(i + 1, locale)}
              </span>
              <h3 className="mt-3 text-[21px] font-semibold text-ink">
                {t(`how.${step}Title`)}
              </h3>
              <p className="mt-2.5 text-[15px] leading-relaxed text-ink-soft">
                {t(`how.${step}Body`)}
              </p>
            </li>
          ))}
        </ol>
      </Section>

      {/* ================================================ Personalization === */}
      <Section tone="green">
        <div className="grid gap-14 lg:grid-cols-[1fr_0.9fr] lg:items-center">
          <div>
            <Eyebrow tone="light">{t('personalization.eyebrow')}</Eyebrow>
            <SectionTitle tone="light">{t('personalization.title')}</SectionTitle>
            <SectionLead tone="light">{t('personalization.body')}</SectionLead>

            <div className="mt-10 flex flex-wrap gap-2.5">
              {(['f1', 'f2', 'f3', 'f4', 'f5', 'f6'] as const).map((f) => (
                <span
                  key={f}
                  className="rounded-full border border-white/15 bg-white/[0.07] px-4 py-2 text-[14px] text-white/85"
                >
                  {t(`personalization.${f}`)}
                </span>
              ))}
            </div>
          </div>

          <Surface radius="xl" pad="lg" elevation="lg" className="bg-white">
            <Badge tone="goal" size="md">
              {t('personalization.previewTitle')}
            </Badge>
            <div className="mt-5 flex gap-4">
              <div className="relative size-20 shrink-0 overflow-hidden rounded-md">
                <Image
                  src={CATEGORY_META.PILATES.image}
                  alt=""
                  fill
                  sizes="80px"
                  className="object-cover"
                />
              </div>
              <div className="min-w-0">
                <p className="text-[16px] font-semibold text-ink">
                  {t('showcase.explore')}
                </p>
                <p className="mt-1 text-[14px] text-ink-soft">
                  {t('personalization.previewBody')}
                </p>
              </div>
            </div>
          </Surface>
        </div>
      </Section>

      {/* ====================================================== Membership === */}
      <Section>
        <Eyebrow>{t('membership.eyebrow')}</Eyebrow>
        <SectionTitle>{t('membership.title')}</SectionTitle>
        <SectionLead>{t('membership.body')}</SectionLead>

        <div className="mt-14 grid gap-5 lg:grid-cols-3">
          {packages.map((pkg) => (
            <PackageCard
              key={pkg.slug}
              locale={locale}
              pkg={{
                slug: pkg.slug,
                name: pick(pkg, 'name', locale),
                bestFor: pick(pkg, 'bestFor', locale),
                price: pkg.price,
                periodDays: pkg.periodDays,
                benefits: pickList(pkg, 'benefits', locale),
                featured: pkg.featured,
              }}
            />
          ))}
        </div>

        <Surface tone="warmSoft" radius="xl" pad="xl" elevation="none" className="mt-5">
          <div className="flex flex-col gap-5 md:flex-row md:items-center md:justify-between">
            <div>
              <h3 className="text-[21px] font-semibold text-ink">
                {t('membership.singleTitle')}
              </h3>
              <p className="mt-2 max-w-[52ch] text-[15px] text-ink-soft">
                {t('membership.singleBody')}
              </p>
            </div>
            <Button asChild variant="secondary" size="lg" className="shrink-0">
              <Link href="/services">{t('hero.secondary')}</Link>
            </Button>
          </div>
        </Surface>
      </Section>

      {/* ======================================================= Community === */}
      <Section tone="warm">
        <div className="grid gap-14 lg:grid-cols-[1fr_1.1fr] lg:items-center">
          <div>
            <Eyebrow>{t('community.eyebrow')}</Eyebrow>
            <SectionTitle>{t('community.title')}</SectionTitle>
            <SectionLead>{t('community.body')}</SectionLead>
          </div>
          <div className="grid grid-cols-2 gap-4">
            {[
              CATEGORY_META.FOOD.image,
              CATEGORY_META.WELLNESS.image,
              CATEGORY_META.PRODUCTS.image,
              CATEGORY_META.FITNESS.image,
            ].map((src, i) => (
              <div
                key={src}
                className={`relative overflow-hidden rounded-lg ${i % 3 === 0 ? 'aspect-[4/5]' : 'aspect-square'}`}
              >
                <Image
                  src={src}
                  alt=""
                  fill
                  sizes="(max-width: 1024px) 50vw, 280px"
                  className="object-cover"
                />
              </div>
            ))}
          </div>
        </div>
      </Section>

      {/* ==================================================== Testimonials === */}
      <Section>
        <Eyebrow>{t('testimonials.eyebrow')}</Eyebrow>
        <SectionTitle>{t('testimonials.title')}</SectionTitle>

        <div className="mt-14 grid gap-5 md:grid-cols-3">
          {[
            { quote: t('community.body'), name: 'سارة', meta: tcat('PILATES') },
            { quote: t('membership.singleBody'), name: 'خالد', meta: tcat('GYM') },
            { quote: t('how.s3Body'), name: 'مريم', meta: tcat('FOOD') },
          ].map((item, i) => (
            <Surface
              key={item.name}
              radius="xl"
              pad="xl"
              tone={i === 1 ? 'warmSoft' : 'white'}
              elevation={i === 1 ? 'none' : 'sm'}
            >
              <Quote className="size-6 text-sage" aria-hidden />
              <p className="mt-5 text-[16px] leading-relaxed text-ink">{item.quote}</p>
              <p className="mt-6 text-[14px] font-medium text-ink">{item.name}</p>
              <p className="text-[13px] text-ink-soft">{item.meta}</p>
            </Surface>
          ))}
        </div>
      </Section>

      {/* ======================================================== Partners === */}
      <Section tone="sage">
        <div className="flex flex-col gap-6 md:flex-row md:items-end md:justify-between">
          <div>
            <Eyebrow>{t('partners.eyebrow')}</Eyebrow>
            <SectionTitle>{t('partners.title')}</SectionTitle>
          </div>
          <Button asChild variant="secondary" size="lg" className="shrink-0">
            <Link href="/partners">
              {t('partners.cta')}
              <ArrowRight className="rtl-flip" />
            </Link>
          </Button>
        </div>

        <div className="mt-12 grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
          {partners.map((partner) => {
            const meta = CATEGORY_META[partner.category];
            return (
              <div
                key={partner.id}
                className="flex items-center gap-3 rounded-lg bg-white/70 px-4 py-4"
              >
                <span
                  className={`grid size-9 shrink-0 place-items-center rounded-full ${meta.bg}`}
                  style={{ color: meta.hex }}
                >
                  <meta.icon className="size-4" strokeWidth={2} aria-hidden />
                </span>
                <span className="min-w-0 truncate text-[14px] font-medium text-ink">
                  {pick(partner, 'name', locale)}
                </span>
              </div>
            );
          })}
        </div>
      </Section>

      {/* ============================================================= CTA === */}
      <Section tone="green">
        <div className="mx-auto max-w-[46ch] text-center">
          <LogoMark tone="mono" className="mx-auto size-12 text-white" />
          <h2 className="display mt-8 text-[34px] text-white text-balance md:text-[52px]">
            {t('cta.titleA')}
            <br />
            <span className="text-accent">{t('cta.titleB')}</span>
            <br />
            {t('cta.titleC')}
          </h2>
          <div className="mt-10 flex flex-wrap justify-center gap-3">
            <Button asChild variant="onDark" size="xl">
              <Link href="/welcome">
                {t('cta.primary')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
            <Button
              asChild
              size="xl"
              className="border border-white/25 bg-transparent text-white hover:bg-white/10"
            >
              <Link href="/about">{t('cta.secondary')}</Link>
            </Button>
          </div>
        </div>
      </Section>
    </>
  );
}

/* ------------------------------------------------------------- helpers --- */

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <p className="display text-[40px] text-green md:text-[52px]">{value}</p>
      <p className="mt-2 text-[13px] text-ink-soft">{label}</p>
    </div>
  );
}

function FloatingChip({
  icon,
  label,
  className,
  tone = 'white',
}: {
  icon: React.ReactNode;
  label: string;
  className?: string;
  tone?: 'white' | 'green';
}) {
  return (
    <span
      className={`absolute hidden items-center gap-2.5 rounded-full px-4 py-2.5 text-[13px] font-medium shadow-[var(--shadow-md)] backdrop-blur-sm sm:inline-flex [&_svg]:size-4 ${
        tone === 'green' ? 'bg-green text-white' : 'bg-white/95 text-ink'
      } ${className ?? ''}`}
    >
      {icon}
      {label}
    </span>
  );
}
