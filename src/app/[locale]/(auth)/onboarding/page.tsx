import { getLocale } from 'next-intl/server';
import { redirect } from '@/i18n/routing';
import { OnboardingFlow } from '@/features/onboarding/OnboardingFlow';
import { getCurrentUser } from '@/server/session';
import { getCities } from '@/server/queries/explore';
import { pick } from '@/lib/localized';

export default async function OnboardingPage() {
  const locale = await getLocale();
  const user = await getCurrentUser();

  if (!user) redirect({ href: '/login', locale });

  const cities = await getCities();

  return (
    <OnboardingFlow
      cities={cities.map((c) => ({ slug: c.slug, name: pick(c, 'name', locale) }))}
    />
  );
}
