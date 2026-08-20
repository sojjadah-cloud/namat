'use server';

import { cookies, headers } from 'next/headers';
import { getLocale } from 'next-intl/server';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';
import { generateCode, issueChallenge, normalizePhone } from '@/lib/otp';
import { sendVerificationCode } from '@/server/sms';
import { checkVerificationLimit, recordVerificationAttempt } from '@/server/rate-limit';

/** Best-effort client address, for the per-IP half of the rate limit. */
async function clientIp() {
  const h = await headers();
  const forwarded = h.get('x-forwarded-for');
  // The left-most entry is the original client; the rest are proxies.
  return forwarded?.split(',')[0]?.trim() || h.get('x-real-ip') || null;
}

/**
 * Requesting a code is the whole of "sign up". There is no separate account
 * creation step — the account appears the moment the number is proven.
 */
export async function requestCode(rawPhone: string) {
  const phone = normalizePhone(rawPhone);

  // Eight digits after the country code is the Omani mobile shape; anything
  // shorter is a typo rather than a number worth texting.
  if (!/^\+\d{10,15}$/.test(phone)) {
    return { ok: false as const, error: 'invalid-phone' as const };
  }

  const ip = await clientIp();
  const verdict = await checkVerificationLimit(phone, ip);
  if (!verdict.allowed) {
    return {
      ok: false as const,
      error: 'rate-limited' as const,
      retryAfterSeconds: verdict.retryAfterSeconds,
    };
  }

  const code = generateCode();
  const locale = await getLocale();
  const delivery = await sendVerificationCode(phone, code, locale);

  if (!delivery.ok) {
    // Nothing is issued if nothing was sent — otherwise the user waits for a
    // message that will never arrive, with no way to tell why.
    console.error(`SMS delivery failed for ${phone}: ${delivery.error}`);
    return { ok: false as const, error: 'send-failed' as const };
  }

  await recordVerificationAttempt(phone, ip);

  const challenge = issueChallenge(phone, code);
  const jar = await cookies();
  jar.set(challenge.name, challenge.value, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    maxAge: challenge.maxAge,
    path: '/',
  });

  const existing = await prisma.user.findUnique({
    where: { phone },
    select: { id: true, name: true },
  });

  return {
    ok: true as const,
    phone,
    returning: Boolean(existing),
    needsName: !existing?.name,
    // Only ever surfaced outside production, and only when the console
    // backend is in use — a real send means the code is on the handset.
    devCode:
      process.env.NODE_ENV !== 'production' && delivery.id.startsWith('console-')
        ? code
        : undefined,
  };
}

/** The "what should we call you?" step, straight after verification. */
export async function setName(name: string) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const trimmed = name.trim();
  if (!trimmed) return { ok: false as const, error: 'invalid-name' as const };

  await prisma.user.update({ where: { id: user.id }, data: { name: trimmed } });
  return { ok: true as const };
}
