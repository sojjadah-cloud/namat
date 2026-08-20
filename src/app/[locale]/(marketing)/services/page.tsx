import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowRight } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Section, Eyebrow, SectionTitle } from '@/components/marketing/Section';
import { prisma } from '@/lib/prisma';
import { CATEGORY_ORDER, CATEGORY_META, PILLARS } from '@/lib/categories';
import { formatNumber } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * The ecosystem, one deep-dive band per category. Each band carries its own
 * hue so a visitor scrolling fast can tell food from fitness without reading.
 */
export default async function ServicesPage() {
  const locale = await getLocale();
  const t = await getTranslations('Services');
  const tcat = await getTranslations('Categories');
  const tl = await getTranslations('Landing');

  const providers = await prisma.provider.findMany({
    where: { isActive: true },
    orderBy: { rating: 'desc' },
    include: { _count: { select: { services: true } } },
  });

  const byCategory = new Map<string, typeof providers>();
  for (const p of providers) {
    if (!byCategory.has(p.category)) byCategory.set(p.category, []);
    byCategory.get(p.category)!.push(p);
  }

  return (
    <>
      <section className="bloom px-5 pt-32 pb-16 md:px-8 md:pt-40 md:pb-20">
        <div className="mx-auto max-w-[1240px]">
          <Eyebrow>{t('eyebrow')}</Eyebrow>
          <h1 className="display mt-5 max-w-[16ch] text-[40px] text-ink text-balance md:text-[64px]">
            {t('title')}
          </h1>
          <p className="mt-8 max-w-[58ch] text-[17px] leading-relaxed text-ink-soft md:text-[19px]">
            {t('body')}
          </p>

          {/* Jump links — seven bands is a long page without them. */}
          <div className="mt-10 flex flex-wrap gap-2">
            {CATEGORY_ORDER.map((c) => {
              const meta = CATEGORY_META[c];
              return (
                <a
                  key={c}
                  href={`#${c.toLowerCase()}`}
                  className={`rounded-full px-4 py-2 text-[14px] font-medium transition-opacity hover:opacity-80 ${meta.bg} ${meta.fg}`}
                >
                  {tcat(c)}
                </a>
              );
            })}
          </div>
        </div>
      </section>

      {/* ========================================================== Pillars === */}
      <Section tone="warm">
        <div className="grid gap-8 md:grid-cols-3">
          {PILLARS.map(({ key, icon: Icon }) => (
            <div key={key} className="flex gap-4">
              <span className="grid size-11 shrink-0 place-items-center rounded-md bg-white text-green shadow-[var(--shadow-sm)]">
                <Icon className="size-5" strokeWidth={1.8} aria-hidden />
              </span>
              <div>
                <h2 className="text-[20px] font-semibold text-ink">
                  {tl(`pillars.${key}`)}
                </h2>
                <p className="mt-2 text-[15px] leading-relaxed text-ink-soft">
                  {tl(`pillars.${key}Body`)}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Section>

      {/* ========================================================== Bands === */}
      {CATEGORY_ORDER.map((category, index) => {
        const meta = CATEGORY_META[category];
        const list = byCategory.get(category) ?? [];
        const flipped = index % 2 === 1;

        return (
          <section
            key={category}
            id={category.toLowerCase()}
            className={`scroll-mt-24 px-5 py-16 md:px-8 md:py-24 ${index % 2 === 0 ? 'bg-canvas' : 'bg-sage-soft'}`}
          >
            <div className="mx-auto max-w-[1240px]">
              <div
                className={`grid items-center gap-12 lg:grid-cols-2 ${flipped ? 'lg:[direction:rtl]' : ''}`}
              >
                <div className={flipped ? 'lg:[direction:inherit]' : ''}>
                  <span
                    className={`inline-flex size-12 items-center justify-center rounded-md ${meta.bg}`}
                    style={{ color: meta.hex }}
                  >
                    <meta.icon className="size-6" strokeWidth={1.8} aria-hidden />
                  </span>

                  <h2 className="display mt-6 text-[32px] text-ink md:text-[42px]">
                    {tcat(category)}
                  </h2>
                  <p className="mt-4 max-w-[52ch] text-[16px] leading-relaxed text-ink-soft md:text-[17px]">
                    {tcat(`desc.${category}`)}
                  </p>

                  {list.length ? (
                    <ul className="mt-8 space-y-3">
                      {list.slice(0, 4).map((p) => (
                        <li key={p.id} className="flex items-baseline gap-3">
                          <span
                            className="mt-1.5 size-1.5 shrink-0 rounded-full"
                            style={{ backgroundColor: meta.hex }}
                            aria-hidden
                          />
                          <span className="text-[15px] text-ink">
                            {pick(p, 'name', locale)}
                          </span>
                          <span className="text-[13px] text-ink-soft">
                            {formatNumber(p._count.services, locale)}
                          </span>
                        </li>
                      ))}
                    </ul>
                  ) : null}

                  <Button asChild variant="secondary" size="lg" className="mt-9">
                    <Link href="/welcome">
                      {t('explore')}
                      <ArrowRight className="rtl-flip" />
                    </Link>
                  </Button>
                </div>

                <div
                  className={`relative aspect-[5/4] overflow-hidden rounded-editorial ${flipped ? 'lg:[direction:inherit]' : ''}`}
                >
                  <Image
                    src={meta.image}
                    alt=""
                    fill
                    sizes="(max-width: 1024px) 100vw, 580px"
                    className="object-cover"
                  />
                </div>
              </div>
            </div>
          </section>
        );
      })}

      <Section tone="green">
        <div className="mx-auto max-w-[46ch] text-center">
          <SectionTitle tone="light" className="mt-0">
            {tl('cta.titleB')}
          </SectionTitle>
          <Button asChild variant="onDark" size="xl" className="mt-9">
            <Link href="/welcome">
              {tl('cta.primary')}
              <ArrowRight className="rtl-flip" />
            </Link>
          </Button>
        </div>
      </Section>
    </>
  );
}
