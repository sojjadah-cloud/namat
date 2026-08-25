import { getTranslations } from 'next-intl/server';
import { Salad, Dumbbell, MessageCircle, ShoppingBag, ArrowLeft } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Button } from '@/components/ui/button';
import { LogoMark } from '@/components/brand/Logo';
import { AppPreview } from '@/features/auth/AppPreview';
import { LocaleToggle } from '@/features/auth/LocaleToggle';

/**
 * The first screen anyone sees.
 *
 * It argues the case before asking for anything: what NAMAT covers, what the
 * app looks like, and only then the two account buttons. The language choice
 * that used to occupy this whole screen is now a toggle in the corner —
 * picking a language is not a reason to see a screen.
 *
 * The floating labels are positioned against the phone rather than laid out in
 * a grid, which is what makes it read as a product shot instead of a menu.
 */
export default async function WelcomePage() {
  const t = await getTranslations('Auth.welcome');

  const features = [
    { icon: Salad, label: t('fMeals'), sub: t('fMealsSub'), tone: 'text-cat-food' },
    { icon: Dumbbell, label: t('fFitness'), sub: t('fFitnessSub'), tone: 'text-cat-fitness' },
    { icon: MessageCircle, label: t('fExperts'), sub: t('fExpertsSub'), tone: 'text-cat-nutrition' },
    { icon: ShoppingBag, label: t('fStores'), sub: t('fStoresSub'), tone: 'text-cat-products' },
  ];

  return (
    <div className="bloom relative flex flex-1 flex-col overflow-y-auto">
      <div className="absolute end-4 top-4 z-20">
        <LocaleToggle />
      </div>

      {/* ---------------------------------------------------------- Hero --- */}
      <header className="px-6 pt-14 text-center">
        <LogoMark className="mx-auto size-14" />
        <p
          className="display mt-3 text-[38px] tracking-[0.08em] text-green-deep"
          style={{ fontFamily: 'var(--font-arabic), sans-serif' }}
        >
          نمط
        </p>

        <h1 className="display mt-6 text-[30px] text-ink text-balance">
          {t('heroA')}
          <br />
          <span className="text-green-accent">{t('heroB')}</span>
        </h1>

        <p className="mx-auto mt-4 max-w-[34ch] text-[15px] leading-relaxed text-ink-soft">
          {t('heroBody')}
        </p>

        {/* A quiet progress rule, echoing the leaf gradient. */}
        <span className="mx-auto mt-6 flex h-1 w-24 overflow-hidden rounded-full bg-line">
          <span className="h-full w-1/2 rounded-full bg-green" />
          <span className="h-full w-1/4 rounded-full bg-sage-light" />
        </span>
      </header>

      {/* ------------------------------------------------- Product shot --- */}
      <div className="relative mt-8 px-6">
        <AppPreview />

        <FloatLabel
          className="-start-1 top-6"
          icon={<Salad aria-hidden />}
          tone="text-cat-food"
          title={t('fMeals')}
          sub={t('fMealsSub')}
        />
        <FloatLabel
          className="-end-1 top-24"
          icon={<MessageCircle aria-hidden />}
          tone="text-cat-nutrition"
          title={t('fExperts')}
          sub={t('fExpertsSub')}
        />
        <FloatLabel
          className="-start-1 bottom-28"
          icon={<Dumbbell aria-hidden />}
          tone="text-cat-fitness"
          title={t('fFitness')}
          sub={t('fFitnessSub')}
        />
        <FloatLabel
          className="-end-1 bottom-10"
          icon={<ShoppingBag aria-hidden />}
          tone="text-cat-products"
          title={t('fStores')}
          sub={t('fStoresSub')}
        />
      </div>

      {/* ------------------------------------------------------ Pillars --- */}
      <div className="mt-10 px-6">
        <div className="grid grid-cols-4 divide-x divide-line rounded-lg border border-line bg-surface/70 py-4 rtl:divide-x-reverse">
          {features.map(({ icon: Icon, label, tone }) => (
            <div key={label} className="px-1 text-center">
              <Icon className={`mx-auto size-5 ${tone}`} strokeWidth={1.8} aria-hidden />
              <p className="mt-1.5 text-[11px] font-medium text-ink">{label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* --------------------------------------------------------- CTAs --- */}
      <div className="mt-8 space-y-3 px-6 pb-10">
        <Button asChild size="xl" block>
          <Link href="/signup">
            <span className="grid size-7 place-items-center rounded-full bg-white/15">
              <ArrowLeft className="size-4 rtl-flip" aria-hidden />
            </span>
            {t('signup')}
          </Link>
        </Button>

        <Button asChild size="xl" block variant="secondary">
          <Link href="/login">
            <ArrowLeft className="size-4 rtl-flip" aria-hidden />
            {t('login')}
          </Link>
        </Button>

        <Link
          href="/app/explore"
          className="mx-auto mt-2 flex w-fit items-center gap-1.5 border-b border-dashed border-line pb-1 text-[13px] font-medium text-green"
        >
          <LogoMark className="size-3.5" />
          {t('guest')}
        </Link>
      </div>
    </div>
  );
}

/**
 * A caption pinned beside the phone. Absolutely positioned against the shot,
 * and hidden on very narrow screens where it would land on top of the device
 * rather than beside it.
 */
function FloatLabel({
  icon,
  title,
  sub,
  tone,
  className,
}: {
  icon: React.ReactNode;
  title: string;
  sub: string;
  tone: string;
  className?: string;
}) {
  return (
    <span
      className={`absolute hidden max-w-[124px] flex-col gap-1 rounded-md bg-surface/95 px-2.5 py-2 shadow-[var(--shadow-md)] backdrop-blur-sm xs:flex ${className ?? ''}`}
    >
      <span className={`grid size-6 place-items-center rounded-full bg-warm-soft ${tone} [&_svg]:size-3.5`}>
        {icon}
      </span>
      <span className="text-[11px] leading-tight font-semibold text-ink">{title}</span>
      <span className="text-[9px] leading-tight text-ink-soft">{sub}</span>
    </span>
  );
}
