/**
 * Payments, expressed in the smallest currency unit.
 *
 * Every amount crossing this boundary is an integer count of baisa
 * (1 OMR = 1000 baisa). Gateways bill in the smallest unit, and a float can
 * not hold 0.001 exactly — an amount that survives a round trip through a
 * double is not the amount anybody agreed to pay.
 */
export type Baisa = number;

export type LineItem = {
  name: string;
  quantity: number;
  unitAmount: Baisa;
};

export type CheckoutRequest = {
  /** Our own id for the thing being paid for, echoed back by the gateway. */
  reference: string;
  items: LineItem[];
  successUrl: string;
  cancelUrl: string;
  /** Surfaced in the gateway dashboard; never include anything sensitive. */
  metadata?: Record<string, string>;
};

export type CheckoutSession = {
  /** The gateway's id, stored so a webhook can be matched to a Payment row. */
  sessionId: string;
  /** Where the browser must be sent to actually pay. */
  redirectUrl: string;
};

export type PaymentState = 'pending' | 'paid' | 'failed' | 'cancelled';

export type CheckoutResult =
  | { ok: true; session: CheckoutSession }
  | { ok: false; error: string };

export interface PaymentProvider {
  readonly name: string;
  createCheckout(request: CheckoutRequest): Promise<CheckoutResult>;
  /** Source of truth after the fact — a redirect back is not proof of payment. */
  getState(sessionId: string): Promise<PaymentState>;
}
