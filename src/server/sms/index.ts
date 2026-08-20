import 'server-only';
import type { SmsProvider } from './types';
import { consoleProvider } from './console';
import { createTwilioProvider } from './twilio';
import { verificationBody } from './message';

export type { SmsProvider, SmsResult } from './types';
export { verificationBody } from './message';

/**
 * Resolves the configured backend once per process.
 *
 * Selection is explicit via `SMS_PROVIDER` rather than inferred from whichever
 * credentials happen to be present — a half-populated env should fail with a
 * clear message, not quietly fall back to logging codes to a console nobody
 * is reading.
 */
let cached: SmsProvider | undefined;

function resolve(): SmsProvider {
  const choice = process.env.SMS_PROVIDER?.trim().toLowerCase() || 'console';

  if (choice === 'console') return consoleProvider;

  if (choice === 'twilio') {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    const from = process.env.TWILIO_FROM;

    if (!accountSid || !authToken || !from) {
      throw new Error(
        'SMS_PROVIDER=twilio requires TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM.',
      );
    }
    return createTwilioProvider({ accountSid, authToken, from });
  }

  throw new Error(`Unknown SMS_PROVIDER "${choice}". Expected "console" or "twilio".`);
}

export function smsProvider(): SmsProvider {
  cached ??= resolve();
  return cached;
}

export async function sendVerificationCode(phone: string, code: string, locale: string) {
  return smsProvider().send({ to: phone, body: verificationBody(code, locale) });
}
