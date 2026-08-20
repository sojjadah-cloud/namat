import { createHmac, randomInt, timingSafeEqual } from 'node:crypto';

/**
 * Phone verification without an SMS provider and without an OTP table.
 *
 * The code is never stored server-side. Instead we hand the browser an
 * httpOnly cookie holding `phone.expiry.hmac(phone|code|expiry)` — the code
 * itself is not in it, so the cookie cannot be read to learn the code, and a
 * forged cookie fails the HMAC. Swapping this for a real SMS provider means
 * replacing `sendCode` and nothing else.
 */

const TTL_MS = 5 * 60_000;
const COOKIE = 'namat.otp';

function secret() {
  const value = process.env.AUTH_SECRET ?? process.env.NEXTAUTH_SECRET;
  if (!value) throw new Error('AUTH_SECRET is required to issue verification codes.');
  return value;
}

function sign(phone: string, code: string, expiry: number) {
  return createHmac('sha256', secret()).update(`${phone}|${code}|${expiry}`).digest('hex');
}

export function generateCode() {
  return String(randomInt(0, 1_000_000)).padStart(6, '0');
}

/** Omani mobile numbers are eight digits; the country code is not part of it. */
const NATIONAL_LENGTH = 8;

/**
 * Normalise to E.164 so every way a person writes their own number resolves to
 * one account: "9123 4567", "091234567", "00968 91234567" and "+968 91234567"
 * are the same handset, and each must produce the same string — the phone is
 * the primary key for an account, so a difference here is a duplicate user.
 */
export function normalizePhone(input: string, countryCode = '968') {
  const digits = input.replace(/[^\d]/g, '');
  if (input.trim().startsWith('+')) return `+${digits}`;

  // "00" is the international prefix; what follows is already in full form.
  const international = digits.startsWith('00') ? digits.slice(2) : digits;

  // Only treat a leading "968" as the country code when the total length says
  // it is one. An eight-digit local number may legitimately start with those
  // digits, and stripping them would corrupt it.
  if (
    international.startsWith(countryCode) &&
    international.length === countryCode.length + NATIONAL_LENGTH
  ) {
    return `+${international}`;
  }

  // A leading trunk zero is how the number is written locally but is not part
  // of the international form.
  return `+${countryCode}${international.replace(/^0+/, '')}`;
}

export function issueChallenge(phone: string, code: string) {
  const expiry = Date.now() + TTL_MS;
  return {
    name: COOKIE,
    value: `${phone}.${expiry}.${sign(phone, code, expiry)}`,
    maxAge: Math.floor(TTL_MS / 1000),
  };
}

export function verifyChallenge(cookieValue: string | undefined, phone: string, code: string) {
  if (!cookieValue) return false;

  const [cookiePhone, expiryRaw, mac] = cookieValue.split('.');
  if (!cookiePhone || !expiryRaw || !mac) return false;
  if (cookiePhone !== phone) return false;

  const expiry = Number(expiryRaw);
  if (!Number.isFinite(expiry) || Date.now() > expiry) return false;

  const expected = sign(phone, code, expiry);
  // Both are fixed-length hex from the same HMAC, so lengths always match.
  return timingSafeEqual(Buffer.from(expected, 'hex'), Buffer.from(mac, 'hex'));
}

export const OTP_COOKIE = COOKIE;
