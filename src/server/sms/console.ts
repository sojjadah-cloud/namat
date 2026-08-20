import type { SmsProvider } from './types';

/**
 * The development backend: prints the message to the server log instead of
 * spending money. It is the default when no provider is configured, and it
 * refuses to be used in production so a missing env var fails loudly at the
 * first send rather than silently swallowing every verification code.
 */
export const consoleProvider: SmsProvider = {
  name: 'console',
  async send({ to, body }) {
    if (process.env.NODE_ENV === 'production') {
      return {
        ok: false,
        error: 'No SMS provider is configured. Set SMS_PROVIDER and its credentials.',
        retryable: false,
      };
    }

    console.info(`\n  ┌─ SMS → ${to}\n  │  ${body}\n  └─\n`);
    return { ok: true, id: `console-${Date.now()}` };
  },
};
