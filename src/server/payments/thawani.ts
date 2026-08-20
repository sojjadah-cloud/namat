import type { PaymentProvider, PaymentState } from './types';

/**
 * Thawani Pay — the gateway most Omani merchants settle through.
 *
 * Two credentials with different jobs: the secret key authenticates our API
 * calls and must never leave the server, while the publishable key is a query
 * parameter on the hosted checkout URL the customer opens. Mixing them up is
 * the usual first bug, so they are named for where they are allowed to go.
 *
 * Amounts are already baisa by the time they reach here, which is what
 * Thawani's `unit_amount` expects — no conversion, no rounding.
 */
const HOSTS = {
  test: { api: 'https://uatcheckout.thawani.om/api/v1', pay: 'https://uatcheckout.thawani.om' },
  live: { api: 'https://checkout.thawani.om/api/v1', pay: 'https://checkout.thawani.om' },
};

export function createThawaniProvider(env: {
  secretKey: string;
  publishableKey: string;
  mode: 'test' | 'live';
}): PaymentProvider {
  const host = HOSTS[env.mode];

  const call = async (path: string, init?: RequestInit) =>
    fetch(`${host.api}${path}`, {
      ...init,
      headers: {
        'thawani-api-key': env.secretKey,
        'Content-Type': 'application/json',
        ...init?.headers,
      },
      signal: AbortSignal.timeout(15_000),
    });

  return {
    name: 'thawani',

    async createCheckout({ reference, items, successUrl, cancelUrl, metadata }) {
      try {
        const response = await call('/checkout/session', {
          method: 'POST',
          body: JSON.stringify({
            client_reference_id: reference,
            mode: 'payment',
            products: items.map((item) => ({
              name: item.name,
              quantity: item.quantity,
              unit_amount: item.unitAmount,
            })),
            success_url: successUrl,
            cancel_url: cancelUrl,
            metadata,
          }),
        });

        const payload = (await response.json()) as {
          success?: boolean;
          description?: string;
          data?: { session_id?: string };
        };

        const sessionId = payload.data?.session_id;
        if (!response.ok || !sessionId) {
          return {
            ok: false,
            error: payload.description ?? `Thawani responded ${response.status}`,
          };
        }

        return {
          ok: true,
          session: {
            sessionId,
            redirectUrl: `${host.pay}/pay/${sessionId}?key=${env.publishableKey}`,
          },
        };
      } catch (error) {
        return { ok: false, error: error instanceof Error ? error.message : 'Network error' };
      }
    },

    async getState(sessionId) {
      const response = await call(`/checkout/session/${sessionId}`);
      if (!response.ok) return 'pending';

      const payload = (await response.json()) as {
        data?: { payment_status?: string };
      };

      return toState(payload.data?.payment_status);
    },
  };
}

/** Thawani's vocabulary, narrowed to the four states we act on. */
function toState(status: string | undefined): PaymentState {
  switch (status) {
    case 'paid':
      return 'paid';
    case 'cancelled':
      return 'cancelled';
    case 'failed':
    case 'expired':
      return 'failed';
    default:
      // "unpaid" and anything we do not recognise stay pending: treating an
      // unknown status as failed would cancel a booking somebody has paid for.
      return 'pending';
  }
}
