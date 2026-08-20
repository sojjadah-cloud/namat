import { cache } from 'react';
import { auth } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

/**
 * One session read and one user read per request, shared by every server
 * component on the page. Without `cache` the Home screen alone would hit the
 * database five times for the same row.
 */

export const getSessionUserId = cache(async () => {
  const session = await auth();
  return session?.user?.id ?? null;
});

export const getCurrentUser = cache(async () => {
  const userId = await getSessionUserId();
  if (!userId) return null;

  return prisma.user.findUnique({
    where: { id: userId },
    include: { profile: { include: { city: true } } },
  });
});

export type CurrentUser = NonNullable<Awaited<ReturnType<typeof getCurrentUser>>>;

/**
 * The active membership drives half the app: which services read as included,
 * whether Journey shows the member command centre, what Home surfaces.
 * Paused and expired memberships are returned too — the UI has designed states
 * for both, and hiding them would strand the user with no way back.
 */
export const getMembership = cache(async () => {
  const userId = await getSessionUserId();
  if (!userId) return null;

  return prisma.membership.findFirst({
    where: { userId, status: { in: ['ACTIVE', 'PAUSED'] } },
    orderBy: { startedAt: 'desc' },
    include: {
      package: { include: { allowances: true } },
      usage: true,
    },
  });
});

export type ActiveMembership = NonNullable<Awaited<ReturnType<typeof getMembership>>>;

/** The package slug a service must list in `includedIn` to count as covered. */
export const getCoveringSlug = cache(async () => {
  const membership = await getMembership();
  return membership?.status === 'ACTIVE' ? membership.package.slug : null;
});
