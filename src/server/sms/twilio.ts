import type { SmsProvider } from './types';

/**
 * Twilio over its REST API rather than the SDK — one authenticated POST is the
 * whole integration, and it keeps a 5MB dependency out of the bundle.
 *
 * `TWILIO_FROM` may be either a purchased number or a Messaging Service SID
 * (`MG…`); the two go in different form fields, which is the only branch here.
 */
export function createTwilioProvider(env: {
  accountSid: string;
  authToken: string;
  from: string;
}): SmsProvider {
  return {
    name: 'twilio',
    async send({ to, body }) {
      const form = new URLSearchParams({ To: to, Body: body });
      if (env.from.startsWith('MG')) form.set('MessagingServiceSid', env.from);
      else form.set('From', env.from);

      try {
        const response = await fetch(
          `https://api.twilio.com/2010-04-01/Accounts/${env.accountSid}/Messages.json`,
          {
            method: 'POST',
            headers: {
              Authorization: `Basic ${Buffer.from(`${env.accountSid}:${env.authToken}`).toString('base64')}`,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: form,
            signal: AbortSignal.timeout(10_000),
          },
        );

        const payload = (await response.json()) as { sid?: string; message?: string };

        if (!response.ok) {
          return {
            ok: false,
            error: payload.message ?? `Twilio responded ${response.status}`,
            // 4xx means the request itself is wrong; retrying sends the same
            // bad request again. 5xx and 429 are worth another attempt.
            retryable: response.status >= 500 || response.status === 429,
          };
        }

        return { ok: true, id: payload.sid ?? 'unknown' };
      } catch (error) {
        return {
          ok: false,
          error: error instanceof Error ? error.message : 'Network error',
          retryable: true,
        };
      }
    },
  };
}
