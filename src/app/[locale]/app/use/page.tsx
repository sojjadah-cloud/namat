import Image from 'next/image';
import { getTranslations, getLocale } from 'next-intl/server';
import { ArrowLeft } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { prisma } from '@/lib/prisma';
import { FIELDS, type Field } from '@/lib/fields';
import { formatNumber } from '@/lib/format';

/**
 * "Use NAMAT" — the question before the catalogue.
 *
 * Deliberately no search box, no category chips, no filters. Those all belong
 * one level down, where they have a subject: filtering by "high protein"
 * before choosing between a gym and a dietitian is filtering nothing. This
 * screen asks one question and offers four answers.
 *
 * The cards alternate composition rather than repeating one tile four times —
 * four identical boxes is a menu, and the point is that each of these is a
 * different world inside the product.
 */
export default async function UseNamatPage() {
  const t = await getTranslations('Use');
  const locale = await getLocale();

  // One grouped query rather than four counts.
  const grouped = await prisma.provider.groupBy({
    by: ['category'],
    where: { isActive: true, status: 'PROSPECT' },
    _count: true,
  });
  const perCategory = new Map(grouped.map((g) => [g.category, g._count]));

  const counts = new Map(
    FIELDS.map((f) => [
      f.key,
      f.categories.reduce((sum, c) => sum + (perCategory.get(c) ?? 0), 0),
    ]),
  );

  return (
    <div className="pb-6">
      <header className="px-5 pt-6 pb-1">
        <h1 className="display text-[26px] text-ink text-balance">{t('greeting')}</h1>
        <p className="mt-2 text-[15px] leading-snug text-ink-soft">{t('sub')}</p>
      </header>

      <div className="mt-6 space-y-4 px-5">
        {FIELDS.map((field, i) => (
          <FieldCard
            key={field.key}
            field={field}
            count={counts.get(field.key) ?? 0}
            locale={locale}
            // The first card runs taller, so the column has a lead rather than
            // four equal weights competing.
            tall={i === 0}
          />
        ))}
      </div>
    </div>
  );
}

async function FieldCard({
  field,
  count,
  locale,
  tall,
}: {
  field: Field;
  count: number;
  locale: string;
  tall: boolean;
}) {
  const t = await getTranslations('Use');
  const Icon = field.icon;
  const empty = count === 0;

  return (
    <Link
      href={`/app/use/${field.key}`}
      className="group relative block overflow-hidden rounded-xl shadow-[var(--shadow-sm)] transition-shadow hover:shadow-[var(--shadow-md)]"
    >
      <div className={`relative ${tall ? 'aspect-[5/4]' : 'aspect-[16/9]'}`}>
        <Image
          src={field.image}
          alt=""
          fill
          sizes="(max-width: 430px) 100vw, 400px"
          className="object-cover transition-transform duration-500 group-hover:scale-[1.04]"
        />
        {/* A single wash rather than a border: the type needs contrast, and the
            photograph should still be visible under it. */}
        <div className="absolute inset-0 bg-gradient-to-t from-ink/85 via-ink/40 to-transparent" />

        <span
          className="absolute top-4 grid size-10 place-items-center rounded-full bg-white/95 start-4"
          style={{ color: field.fg }}
        >
          <Icon className="size-5" strokeWidth={2} aria-hidden />
        </span>

        {/* Availability, stated on the card so nobody taps into an empty room
            without warning. */}
        <span
          className={`absolute top-4 end-4 rounded-full px-2.5 py-1 text-[11px] font-medium ${
            empty ? 'bg-ink/60 text-white/80' : 'bg-white/95 text-ink'
          }`}
        >
          {empty ? t('countEmpty') : t('count', { count: formatNumber(count, locale) })}
        </span>

        <div className="absolute inset-x-0 bottom-0 p-5">
          <h2 className="text-[22px] font-semibold text-white">{t(field.key)}</h2>
          <p className="mt-1 max-w-[30ch] text-[13px] leading-snug text-white/75">
            {t(`${field.key}Sub`)}
          </p>
          <span className="mt-3.5 inline-flex items-center gap-1.5 text-[14px] font-medium text-white">
            {t(`${field.key}Cta`)}
            <ArrowLeft
              className="size-4 rtl-flip transition-transform duration-300 group-hover:-translate-x-1 rtl:group-hover:translate-x-1"
              aria-hidden
            />
          </span>
        </div>
      </div>
    </Link>
  );
}
