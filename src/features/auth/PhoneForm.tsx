'use client';

import * as React from 'react';
import { signIn } from 'next-auth/react';
import { useLocale, useTranslations } from 'next-intl';
import { useRouter, Link } from '@/i18n/routing';
import { Input, Label, FieldError } from '@/components/ui/field';
import { OTPInput } from '@/components/ui/otp';
import { Button } from '@/components/ui/button';
import { Surface } from '@/components/ui/card';
import { formatNumber, formatPhone } from '@/lib/format';
import { requestCode, setName as saveName } from '@/server/actions/auth';

type Stage = 'phone' | 'code' | 'name';

/**
 * Phone → code → name, as three states of one screen rather than three routes.
 * The number never leaves the top of the view, so "is that the right number?"
 * is answerable without going back, and a wrong digit costs one tap.
 */
export function PhoneForm({ mode }: { mode: 'signup' | 'login' }) {
  const locale = useLocale();
  const t = useTranslations('Auth');
  const tc = useTranslations('Common');
  const router = useRouter();

  const [stage, setStage] = React.useState<Stage>('phone');
  const [phone, setPhone] = React.useState('');
  const [sentTo, setSentTo] = React.useState('');
  const [devCode, setDevCode] = React.useState<string | null>(null);
  const [code, setCode] = React.useState('');
  const [name, setNameValue] = React.useState('');
  const [error, setError] = React.useState<string | null>(null);
  const [pending, startTransition] = React.useTransition();
  const [cooldown, setCooldown] = React.useState(0);

  React.useEffect(() => {
    if (cooldown <= 0) return;
    const id = setTimeout(() => setCooldown((c) => c - 1), 1000);
    return () => clearTimeout(id);
  }, [cooldown]);

  const send = () =>
    startTransition(async () => {
      setError(null);
      const result = await requestCode(phone);
      if (!result.ok) {
        // Each failure needs its own sentence: "invalid number" tells someone
        // who has been rate-limited to edit a number that was fine.
        if (result.error === 'rate-limited') {
          setError(
            t('signup.rateLimited', {
              minutes: formatNumber(Math.ceil(result.retryAfterSeconds / 60), locale),
            }),
          );
        } else if (result.error === 'send-failed') {
          setError(t('signup.sendFailed'));
        } else {
          setError(t('signup.invalidPhone'));
        }
        return;
      }
      setSentTo(result.phone);
      setDevCode(result.devCode ?? null);
      setCode('');
      setCooldown(30);
      setStage('code');
    });

  const verify = (value: string) =>
    startTransition(async () => {
      setError(null);
      const result = await signIn('phone', {
        phone: sentTo,
        code: value,
        redirect: false,
      });

      if (result?.error) {
        setError(t('otp.error'));
        setCode('');
        return;
      }

      // A returning member already has a name; a new number does not.
      const needsName = mode === 'signup';
      if (needsName) {
        setStage('name');
      } else {
        router.replace('/app');
        router.refresh();
      }
    });

  const finish = () =>
    startTransition(async () => {
      const result = await saveName(name);
      if (!result.ok) return;
      router.replace('/onboarding');
      router.refresh();
    });

  /* ------------------------------------------------------------- Phone --- */

  if (stage === 'phone') {
    return (
      <form
        className="flex flex-1 flex-col px-6 pb-8"
        onSubmit={(e) => {
          e.preventDefault();
          send();
        }}
      >
        <h1 className="display text-[32px] text-ink">
          {mode === 'signup' ? t('signup.title') : t('login.title')}
        </h1>
        <p className="mt-3 text-[16px] leading-snug text-ink-soft">
          {mode === 'signup' ? t('signup.body') : t('login.body')}
        </p>

        <div className="mt-8">
          <Label htmlFor="phone">{t('signup.phone')}</Label>
          <div className="mt-2 flex gap-2" dir="ltr">
            <span className="grid h-14 shrink-0 place-items-center rounded-md border border-line bg-warm-soft px-4 text-[15px] font-medium text-ink-soft">
              +968
            </span>
            <Input
              id="phone"
              type="tel"
              inputMode="tel"
              autoComplete="tel"
              autoFocus
              placeholder={t('signup.phonePlaceholder')}
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              className="h-14 flex-1 text-[17px]"
            />
          </div>
          <FieldError>{error}</FieldError>
        </div>

        <div className="flex-1" />

        <Button block size="xl" loading={pending} disabled={phone.trim().length < 6}>
          {t('signup.continue')}
        </Button>

        <p className="mt-5 text-center text-[13px] leading-snug text-ink-soft">
          {t('signup.terms')}
        </p>

        <p className="mt-6 text-center text-[14px] text-ink-soft">
          {mode === 'signup' ? t('signup.haveAccount') : t('login.noAccount')}{' '}
          <Link
            href={mode === 'signup' ? '/login' : '/signup'}
            className="font-medium text-green underline-offset-4 hover:underline"
          >
            {mode === 'signup' ? t('signup.login') : t('login.signup')}
          </Link>
        </p>
      </form>
    );
  }

  /* -------------------------------------------------------------- Code --- */

  if (stage === 'code') {
    return (
      <div className="flex flex-1 flex-col px-6 pb-8">
        <h1 className="display text-[32px] text-ink">{t('otp.title')}</h1>
        <p className="mt-3 text-[16px] leading-snug text-ink-soft">
          {t('otp.body', { phone: formatPhone(sentTo, locale) })}
        </p>

        <button
          type="button"
          onClick={() => {
            setStage('phone');
            setError(null);
          }}
          className="mt-2 self-start text-[14px] font-medium text-green underline-offset-4 hover:underline"
        >
          {t('otp.edit')}
        </button>

        <div className="mt-8">
          <OTPInput
            autoFocus
            value={code}
            onValueChange={setCode}
            onComplete={verify}
            invalid={Boolean(error)}
          />
          {error ? (
            <p role="alert" className="mt-4 text-center text-[13px] text-danger">
              {error}
            </p>
          ) : null}
        </div>

        {/* Stands in for the SMS until a provider is connected. */}
        {devCode ? (
          <Surface tone="warmSoft" radius="md" pad="md" elevation="none" className="mt-6">
            <p className="text-center text-[13px] text-ink-soft">
              {t('otp.hint').split(':')[0]}: <span className="font-semibold tabular-nums text-ink">{devCode}</span>
            </p>
          </Surface>
        ) : null}

        <div className="flex-1" />

        <Button
          block
          size="xl"
          loading={pending}
          disabled={code.length < 6}
          onClick={() => verify(code)}
        >
          {t('otp.verify')}
        </Button>

        <button
          type="button"
          disabled={cooldown > 0 || pending}
          onClick={send}
          className="mt-5 text-center text-[14px] font-medium text-green disabled:text-ink-soft"
        >
          {cooldown > 0
            ? t('otp.resendIn', { seconds: formatNumber(cooldown, locale) })
            : t('otp.resend')}
        </button>
      </div>
    );
  }

  /* -------------------------------------------------------------- Name --- */

  return (
    <form
      className="flex flex-1 flex-col px-6 pb-8"
      onSubmit={(e) => {
        e.preventDefault();
        finish();
      }}
    >
      <h1 className="display text-[32px] text-ink">{t('name.title')}</h1>
      <p className="mt-3 text-[16px] leading-snug text-ink-soft">{t('name.body')}</p>

      <div className="mt-8">
        <Label htmlFor="name">{t('name.first')}</Label>
        <Input
          id="name"
          autoFocus
          autoComplete="given-name"
          value={name}
          onChange={(e) => setNameValue(e.target.value)}
          className="mt-2 h-14 text-[17px]"
          lang={locale}
        />
      </div>

      <div className="flex-1" />

      <Button block size="xl" loading={pending} disabled={!name.trim()}>
        {tc('continue')}
      </Button>
    </form>
  );
}
