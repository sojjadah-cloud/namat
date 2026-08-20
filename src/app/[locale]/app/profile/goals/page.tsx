import { getTranslations } from 'next-intl/server';
import { BackBar } from '@/components/layout/AppHeader';
import { GoalsEditor } from '@/features/profile/GoalsEditor';
import { getCurrentUser } from '@/server/session';

export default async function GoalsPage() {
  const t = await getTranslations('Profile');
  const tg = await getTranslations('Onboarding.goals');

  const user = await getCurrentUser();
  if (!user) return null;

  return (
    <div>
      <BackBar title={t('goals')} />
      <p className="px-5 pt-2 pb-5 text-[15px] text-ink-soft">{tg('body')}</p>
      <GoalsEditor initial={user.profile?.goals ?? []} />
    </div>
  );
}
