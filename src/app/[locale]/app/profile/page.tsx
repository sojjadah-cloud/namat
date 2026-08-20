import { getTranslations, getLocale } from 'next-intl/server';
import {
  ChevronRight,
  Target,
  SlidersHorizontal,
  Heart,
  Languages,
  CreditCard,
  Bell,
  LogOut,
  Sparkles,
} from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Avatar } from '@/components/ui/avatar';
import { Surface } from '@/components/ui/card';
import { SignOutButton } from '@/features/profile/SignOutButton';
import { getCurrentUser, getMembership } from '@/server/session';
import { formatPhone } from '@/lib/format';
import { pick } from '@/lib/localized';

/**
 * Profile is a hub, not a settings dump. Personalization comes first because
 * it is the only group that changes what the app does; account plumbing sits
 * below it, and logging out is last and quiet.
 */
export default async function ProfilePage() {
  const locale = await getLocale();
  const t = await getTranslations('Profile');
  const tp = await getTranslations('Packages');

  const [user, membership] = await Promise.all([getCurrentUser(), getMembership()]);
  if (!user) return null;

  return (
    <div className="pb-6">
      <header className="px-5 pt-5 pb-4">
        <h1 className="display text-[28px] text-ink">{t('title')}</h1>
      </header>

      {/* -------------------------------------------------------- Identity --- */}
      <section className="px-5">
        <Surface radius="lg" pad="lg">
          <div className="flex items-center gap-4">
            <Avatar name={user.name} src={user.image} size="xl" />
            <div className="min-w-0 flex-1">
              <p className="truncate text-[19px] font-semibold text-ink">
                {user.name ?? '—'}
              </p>
              <p className="mt-0.5 truncate text-[13px] text-ink-soft">
                {user.phone ? formatPhone(user.phone, locale) : (user.email ?? '')}
              </p>
              {user.profile?.city ? (
                <p className="mt-0.5 truncate text-[13px] text-ink-soft">
                  {pick(user.profile.city, 'name', locale)}
                </p>
              ) : null}
            </div>
          </div>
        </Surface>
      </section>

      {/* --------------------------------------------------------- Package --- */}
      <section className="mt-4 px-5">
        {membership ? (
          <Link href="/app/journey/package" className="block">
            <Surface tone="greenSoft" radius="lg" pad="lg" elevation="none">
              <div className="flex items-center gap-3">
                <Sparkles className="size-5 shrink-0 text-green" aria-hidden />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-[15px] font-semibold text-ink">
                    {pick(membership.package, 'name', locale)}
                  </p>
                  <p className="mt-0.5 text-[13px] text-ink-soft">
                    {tp(`status.${membership.status}`)}
                  </p>
                </div>
                <ChevronRight className="rtl-flip size-5 shrink-0 text-ink-soft" aria-hidden />
              </div>
            </Surface>
          </Link>
        ) : (
          <Link href="/app/packages" className="block">
            <Surface tone="warmSoft" radius="lg" pad="lg" elevation="none">
              <div className="flex items-center gap-3">
                <Sparkles className="size-5 shrink-0 text-ink-soft" aria-hidden />
                <p className="min-w-0 flex-1 text-[15px] font-medium text-ink">
                  {tp('title')}
                </p>
                <ChevronRight className="rtl-flip size-5 shrink-0 text-ink-soft" aria-hidden />
              </div>
            </Surface>
          </Link>
        )}
      </section>

      {/* ------------------------------------------------- Personalization --- */}
      <Group title={t('personalization')}>
        <Row href="/app/profile/goals" icon={<Target aria-hidden />} label={t('goals')} />
        <Row
          href="/app/profile/preferences"
          icon={<SlidersHorizontal aria-hidden />}
          label={t('prefsTitle')}
        />
        <Row
          href="/app/profile/favorites"
          icon={<Heart aria-hidden />}
          label={t('favorites')}
        />
      </Group>

      {/* ---------------------------------------------------------- Account --- */}
      <Group title={t('account')}>
        <Row
          href="/app/profile/language"
          icon={<Languages aria-hidden />}
          label={t('language')}
          value={locale === 'ar' ? 'العربية' : 'English'}
        />
        <Row
          href="/app/profile/payment"
          icon={<CreditCard aria-hidden />}
          label={t('payment')}
        />
        <Row
          href="/app/notifications"
          icon={<Bell aria-hidden />}
          label={t('notifications')}
        />
      </Group>

      <section className="mt-8 px-5">
        <SignOutButton label={t('logout')} icon={<LogOut aria-hidden />} />
      </section>
    </div>
  );
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mt-8 px-5">
      <p className="mb-2.5 px-1 text-[11px] font-medium uppercase tracking-[0.14em] text-ink-soft">
        {title}
      </p>
      <Surface radius="lg" pad="none" className="overflow-hidden">
        <div className="divide-y divide-line">{children}</div>
      </Surface>
    </section>
  );
}

function Row({
  href,
  icon,
  label,
  value,
}: {
  href: string;
  icon: React.ReactNode;
  label: string;
  value?: string;
}) {
  return (
    <Link
      href={href}
      className="flex items-center gap-3.5 px-4 py-3.5 transition-colors hover:bg-black/[0.02]"
    >
      <span className="shrink-0 text-ink-soft [&_svg]:size-[18px]">{icon}</span>
      <span className="min-w-0 flex-1 truncate text-[15px] text-ink">{label}</span>
      {value ? <span className="shrink-0 text-[13px] text-ink-soft">{value}</span> : null}
      <ChevronRight className="rtl-flip size-4 shrink-0 text-ink-soft/60" aria-hidden />
    </Link>
  );
}
