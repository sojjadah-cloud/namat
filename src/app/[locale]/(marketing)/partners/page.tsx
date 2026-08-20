import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight, Users, CalendarCheck, Wallet } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { Section, Eyebrow, SectionTitle, SectionLead } from '@/components/marketing/Section';
import { prisma } from '@/lib/prisma';
import { CATEGORY_META, CATEGORY_ORDER } from '@/lib/categories';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

export default async function PartnersPage() {
  const locale = await getLocale();
  const t = await getTranslations('Partners');
  const tcat = await getTranslations('Categories');
  const tl = await getTranslations('Landing');

  const [partners, providerCount] = await Promise.all([
    prisma.partner.findMany(),
    prisma.provider.count({ where: { isActive: true } }),
  ]);

  const benefits = [
    { key: 'b1', icon: Users },
    { key: 'b2', icon: CalendarCheck },
    { key: 'b3', icon: Wallet },
  ] as const;

  return (
    <>
      <section className="bloom px-5 pt-32 pb-20 md:px-8 md:pt-40 md:pb-24">
        <div className="mx-auto grid max-w-[1240px] items-center gap-14 lg:grid-cols-[1fr_0.85fr]">
          <div>
            <Eyebrow>{t('eyebrow')}</Eyebrow>
            <h1 className="display mt-5 text-[42px] text-ink text-balance md:text-[68px]">
              {t('title')}
            </h1>
            <p className="mt-7 max-w-[52ch] text-[17px] leading-relaxed text-ink-soft md:text-[19px]">
              {t('body')}
            </p>
            <Button asChild size="xl" className="mt-9">
              <Link href="/welcome">
                {t('cta')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
          </div>

          <div className="relative aspect-[4/5] overflow-hidden rounded-editorial shadow-[var(--shadow-lg)]">
            <Image
              src="https://images.unsplash.com/photo-1540497077202-7c8a3999166f?auto=format&fit=crop&w=1200&q=75"
              alt=""
              fill
              priority
              sizes="(max-width: 1024px) 100vw, 500px"
              className="object-cover"
            />
          </div>
        </div>
      </section>

      {/* ========================================================= Benefits === */}
      <Section tone="warm">
        <div className="grid gap-5 md:grid-cols-3">
          {benefits.map(({ key, icon: Icon }) => (
            <Surface key={key} radius="xl" pad="xl">
              <span className="grid size-12 place-items-center rounded-md bg-green-soft text-green">
                <Icon className="size-6" strokeWidth={1.8} aria-hidden />
              </span>
              <h2 className="mt-6 text-[21px] font-semibold text-ink">{t(key)}</h2>
              <p className="mt-3 text-[15px] leading-relaxed text-ink-soft">
                {t(`${key}Body`)}
              </p>
            </Surface>
          ))}
        </div>
      </Section>

      {/* ===================================================== Partner wall === */}
      <Section>
        <div className="flex flex-col gap-4 md:flex-row md:items-end md:justify-between">
          <SectionTitle className="mt-0">{t('wall')}</SectionTitle>
          <p className="text-[15px] text-ink-soft">
            {tl('trust.partners')} · {formatNumber(providerCount, locale)}
          </p>
        </div>

        <div className="mt-12 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {partners.map((partner) => {
            const meta = CATEGORY_META[partner.category];
            return (
              <div
                key={partner.id}
                className="flex items-center gap-4 rounded-lg border border-line bg-white px-5 py-4"
              >
                <span
                  className={`grid size-11 shrink-0 place-items-center rounded-md ${meta.bg}`}
                  style={{ color: meta.hex }}
                >
                  <meta.icon className="size-5" strokeWidth={1.9} aria-hidden />
                </span>
                <div className="min-w-0">
                  <p className="truncate text-[15px] font-medium text-ink">
                    {pick(partner, 'name', locale)}
                  </p>
                  <p className="truncate text-[13px] text-ink-soft">
                    {tcat(partner.category)}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </Section>

      {/* ======================================================= Categories === */}
      <Section tone="sage">
        <Eyebrow>{tl('ecosystem.eyebrow')}</Eyebrow>
        <SectionTitle>{tl('ecosystem.title')}</SectionTitle>
        <SectionLead>{tl('ecosystem.body')}</SectionLead>

        <div className="mt-12 flex flex-wrap gap-2.5">
          {CATEGORY_ORDER.map((c) => {
            const meta = CATEGORY_META[c];
            return (
              <span
                key={c}
                className={`inline-flex items-center gap-2 rounded-full px-4 py-2.5 text-[14px] font-medium ${meta.bg} ${meta.fg}`}
              >
                <meta.icon className="size-4" strokeWidth={2} aria-hidden />
                {tcat(c)}
              </span>
            );
          })}
        </div>
      </Section>

      <Section tone="green">
        <div className="mx-auto max-w-[46ch] text-center">
          <SectionTitle tone="light" className="mt-0">
            {t('title')}
          </SectionTitle>
          <SectionLead tone="light" className="mx-auto">
            {t('body')}
          </SectionLead>
          <Button asChild variant="onDark" size="xl" className="mt-9">
            <Link href="/welcome">
              {t('cta')}
              <ArrowRight className="rtl-flip" />
            </Link>
          </Button>
        </div>
      </Section>
    </>
  );
}
