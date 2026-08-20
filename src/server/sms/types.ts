/** What every SMS backend must be able to do. Kept deliberately tiny. */
export type SmsMessage = {
  /** E.164 destination, e.g. "+96891234567". */
  to: string;
  body: string;
};

export type SmsResult =
  | { ok: true; id: string }
  | { ok: false; error: string; retryable: boolean };

export interface SmsProvider {
  readonly name: string;
  send(message: SmsMessage): Promise<SmsResult>;
}
