import { getTranslations, getLocale } from 'next-intl/server';
import { BackBar } from '@/components/layout/AppHeader';
import { PreferencesEditor } from '@/features/profile/PreferencesEditor';
import { getCurrentUser } from '@/server/session';
import { getCities } from '@/server/queries/explore';
import { pick } from '@/lib/localized';

export default async function PreferencesPage() {
  const locale = await getLocale();
  const t = await getTranslations('Profile');

  const [user, cities] = await Promise.all([getCurrentUser(), getCities()]);
  if (!user) return null;

  const profile = user.profile;
  const currentCity = cities.find((c) => c.id === profile?.cityId);

  return (
    <div>
      <BackBar title={t('prefsTitle')} />
      <div className="pt-4">
        <PreferencesEditor
          cities={cities.map((c) => ({ slug: c.slug, name: pick(c, 'name', locale) }))}
          initial={{
            interests: profile?.interests ?? [],
            activityLevel: profile?.activityLevel ?? 'MODERATE',
            timePreference: profile?.timePreference ?? 'ANY',
            dietary: profile?.dietary ?? [],
            womenOnly: profile?.womenOnly ?? false,
            citySlug: currentCity?.slug,
          }}
        />
      </div>
    </div>
  );
}
