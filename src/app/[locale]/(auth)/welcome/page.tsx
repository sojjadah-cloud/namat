import { getTranslations } from 'next-intl/server';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';

/**
 * Language before anything else. Asking after signup would mean re-rendering
 * a form the user already filled in, in a direction they did not choose.
 */
export default async function WelcomePage() {
  const t = await getTranslations('Auth.welcome');
  const tb = await getTranslations('Brand');

  return (
    <div className="flex flex-1 flex-col px-6 pt-16 pb-8">
      <div>
        <p className="text-[13px] font-medium uppercase tracking-[0.24em] text-ink-soft">
          {tb('name')}
        </p>
        <h1 className="display mt-4 text-[38px] text-ink text-balance">{t('title')}</h1>
        <p className="mt-3 text-[16px] leading-snug text-ink-soft">{t('body')}</p>
      </div>

      <div className="mt-10 space-y-3">
        <Choice href="/signup" locale="ar" title={t('arabic')} sub={t('arabicSub')} />
        <Choice href="/signup" locale="en" title={t('english')} sub={t('englishSub')} />
      </div>

      <div className="flex-1" />
    </div>
  );
}

function Choice({
  href,
  locale,
  title,
  sub,
}: {
  href: string;
  locale: 'ar' | 'en';
  title: string;
  sub: string;
}) {
  return (
    <Button asChild block variant="secondary" size="xl" className="h-auto justify-start py-4">
      <Link href={href} locale={locale}>
        <span className="block text-start">
          <span className="block text-[17px] font-semibold text-ink">{title}</span>
          <span className="mt-0.5 block text-[13px] font-normal text-ink-soft">{sub}</span>
        </span>
      </Link>
    </Button>
  );
}
