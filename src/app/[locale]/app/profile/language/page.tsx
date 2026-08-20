import { getTranslations } from 'next-intl/server';
import { BackBar } from '@/components/layout/AppHeader';
import { LanguagePicker } from '@/features/profile/LanguagePicker';

export default async function LanguagePage() {
  const t = await getTranslations('Profile');

  return (
    <div className="pb-6">
      <BackBar title={t('languageTitle')} />
      <p className="px-5 pt-2 pb-5 text-[15px] text-ink-soft">{t('languageBody')}</p>
      <div className="px-5">
        <LanguagePicker />
      </div>
    </div>
  );
}
