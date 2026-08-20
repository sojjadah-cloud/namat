import Image from 'next/image';
import { getTranslations } from 'next-intl/server';
import { ArrowRight, Heart, ShieldCheck, MapPin } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { Section, Eyebrow, SectionTitle, SectionLead } from '@/components/marketing/Section';
import { CATEGORY_META } from '@/lib/categories';

export default async function AboutPage() {
  const t = await getTranslations('About');
  const tl = await getTranslations('Landing');

  const values = [
    { key: 'v1', icon: MapPin },
    { key: 'v2', icon: Heart },
    { key: 'v3', icon: ShieldCheck },
  ] as const;

  return (
    <>
      <section className="bloom px-5 pt-32 pb-16 md:px-8 md:pt-40 md:pb-20">
        <div className="mx-auto max-w-[1240px]">
          <Eyebrow>{t('eyebrow')}</Eyebrow>
          <h1 className="display mt-5 max-w-[18ch] text-[40px] text-ink text-balance md:text-[64px]">
            {t('title')}
          </h1>
          <p className="mt-8 max-w-[64ch] text-[17px] leading-relaxed text-ink-soft md:text-[19px]">
            {t('lead')}
          </p>
        </div>
      </section>

      {/* A wide plate before the three blocks, so the story has a place. */}
      <div className="px-5 md:px-8">
        <div className="relative mx-auto aspect-[21/9] max-w-[1240px] overflow-hidden rounded-editorial">
          <Image
            src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=2000&q=75"
            alt=""
            fill
            priority
            sizes="1240px"
            className="object-cover"
          />
        </div>
      </div>

      <Section>
        <div className="grid gap-8 md:grid-cols-3">
          {(['b1', 'b2', 'b3'] as const).map((block) => (
            <div key={block}>
              <h2 className="text-[24px] font-semibold text-ink">{t(`${block}Title`)}</h2>
              <p className="mt-3.5 text-[15px] leading-relaxed text-ink-soft">
                {t(`${block}Body`)}
              </p>
            </div>
          ))}
        </div>
      </Section>

      <Section tone="warm">
        <SectionTitle className="mt-0">{t('valuesTitle')}</SectionTitle>

        <div className="mt-14 grid gap-5 md:grid-cols-3">
          {values.map(({ key, icon: Icon }) => (
            <Surface key={key} radius="xl" pad="xl">
              <span className="grid size-12 place-items-center rounded-md bg-green-soft text-green">
                <Icon className="size-6" strokeWidth={1.8} aria-hidden />
              </span>
              <h3 className="mt-6 text-[21px] font-semibold text-ink">{t(key)}</h3>
              <p className="mt-3 text-[15px] leading-relaxed text-ink-soft">
                {t(`${key}Body`)}
              </p>
            </Surface>
          ))}
        </div>
      </Section>

      <Section tone="sage">
        <div className="grid gap-14 lg:grid-cols-[1.1fr_1fr] lg:items-center">
          <div>
            <Eyebrow>{tl('community.eyebrow')}</Eyebrow>
            <SectionTitle>{tl('community.title')}</SectionTitle>
            <SectionLead>{tl('community.body')}</SectionLead>
            <Button asChild size="lg" className="mt-9">
              <Link href="/welcome">
                {tl('cta.primary')}
                <ArrowRight className="rtl-flip" />
              </Link>
            </Button>
          </div>

          <div className="grid grid-cols-2 gap-4">
            {[
              CATEGORY_META.NUTRITION.image,
              CATEGORY_META.GYM.image,
              CATEGORY_META.PILATES.image,
              CATEGORY_META.PRODUCTS.image,
            ].map((src, i) => (
              <div
                key={src}
                className={`relative overflow-hidden rounded-lg ${i % 3 === 0 ? 'aspect-square' : 'aspect-[4/5]'}`}
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
    </>
  );
}
