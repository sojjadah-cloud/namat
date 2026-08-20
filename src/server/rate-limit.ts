import 'server-only';
import { prisma } from '@/lib/prisma';

/**
 * Rate limiting for the code-request endpoint.
 *
 * Two windows, because they defend against different things. The per-phone
 * limit stops one number being hammered — every send costs money and lands on
 * a real person's handset. The per-IP limit stops one client walking the
 * number space to learn which numbers have accounts, which the "returning"
 * flag in the response would otherwise leak.
 */

const PHONE_WINDOW_MS = 60 * 60_000;
const PHONE_MAX = 5;

const IP_WINDOW_MS = 60 * 60_000;
const IP_MAX = 20;

export type RateLimitVerdict =
  | { allowed: true }
  | { allowed: false; retryAfterSeconds: number };

export async function checkVerificationLimit(
  phone: string,
  ip: string | null,
): Promise<RateLimitVerdict> {
  const now = Date.now();
  const phoneSince = new Date(now - PHONE_WINDOW_MS);
  const ipSince = new Date(now - IP_WINDOW_MS);

  const [phoneCount, ipCount, oldestPhone] = await Promise.all([
    prisma.verificationAttempt.count({
      where: { phone, createdAt: { gte: phoneSince } },
    }),
    ip
      ? prisma.verificationAttempt.count({ where: { ip, createdAt: { gte: ipSince } } })
      : Promise.resolve(0),
    prisma.verificationAttempt.findFirst({
      where: { phone, createdAt: { gte: phoneSince } },
      orderBy: { createdAt: 'asc' },
      select: { createdAt: true },
    }),
  ]);

  if (phoneCount >= PHONE_MAX) {
    // The window is a rolling one, so the caller is free again when the
    // oldest attempt in it ages out — not a fixed hour from now.
    const freeAt = (oldestPhone?.createdAt.getTime() ?? now) + PHONE_WINDOW_MS;
    return {
      allowed: false,
      retryAfterSeconds: Math.max(1, Math.ceil((freeAt - now) / 1000)),
    };
  }

  if (ipCount >= IP_MAX) {
    return { allowed: false, retryAfterSeconds: Math.ceil(IP_WINDOW_MS / 1000) };
  }

  return { allowed: true };
}

export async function recordVerificationAttempt(phone: string, ip: string | null) {
  await prisma.verificationAttempt.create({ data: { phone, ip } });
}

/** Drop rows that can no longer affect any window. Safe to call from a cron. */
export async function pruneVerificationAttempts() {
  const cutoff = new Date(Date.now() - Math.max(PHONE_WINDOW_MS, IP_WINDOW_MS));
  const { count } = await prisma.verificationAttempt.deleteMany({
    where: { createdAt: { lt: cutoff } },
  });
  return count;
}
