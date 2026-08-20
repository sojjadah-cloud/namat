import { BackBar } from '@/components/layout/AppHeader';
import { PhoneForm } from '@/features/auth/PhoneForm';

export default function LoginPage() {
  return (
    <>
      <BackBar transparent />
      <PhoneForm mode="login" />
    </>
  );
}
