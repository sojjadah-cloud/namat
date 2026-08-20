import { BackBar } from '@/components/layout/AppHeader';
import { PhoneForm } from '@/features/auth/PhoneForm';

export default function SignupPage() {
  return (
    <>
      <BackBar transparent />
      <PhoneForm mode="signup" />
    </>
  );
}
