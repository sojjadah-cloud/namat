'use server';

import { revalidatePath } from 'next/cache';
import { prisma } from '@/lib/prisma';
import { getCurrentUser, getMembership } from '@/server/session';

/**
 * Membership lifecycle: start, pause, resume, change, stop renewing.
 *
 * Pausing moves the end date out by the days paused rather than freezing a
 * counter — the member paid for thirty usable days and should get thirty
 * usable days back.
 */

const DAY = 86_400_000;

export async function startMembership(packageSlug: string) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const pkg = await prisma.package.findUnique({
    where: { slug: packageSlug },
    include: { allowances: true },
  });
  if (!pkg) return { ok: false as const, error: 'not-found' as const };

  const membership = await prisma.$transaction(async (tx) => {
    // Changing package ends the old one at the moment the new one starts;
    // two active memberships would make "included" ambiguous.
    await tx.membership.updateMany({
      where: { userId: user.id, status: { in: ['ACTIVE', 'PAUSED'] } },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    });

    const endsAt = new Date(Date.now() + pkg.periodDays * DAY);
    const created = await tx.membership.create({
      data: {
        userId: user.id,
        packageId: pkg.id,
        status: 'ACTIVE',
        endsAt,
        renewsAt: endsAt,
      },
    });

    await tx.usage.createMany({
      data: pkg.allowances.map((a) => ({
        membershipId: created.id,
        category: a.category,
        used: 0,
      })),
    });

    return created;
  });

  revalidatePath('/app');
  revalidatePath('/app/journey');
  revalidatePath('/app/packages');
  return { ok: true as const, membershipId: membership.id };
}

export async function pauseMembership() {
  const membership = await getMembership();
  if (!membership || membership.status !== 'ACTIVE') {
    return { ok: false as const, error: 'not-found' as const };
  }

  await prisma.membership.update({
    where: { id: membership.id },
    data: { status: 'PAUSED', pausedAt: new Date() },
  });

  revalidatePath('/app/journey');
  revalidatePath('/app');
  return { ok: true as const };
}

export async function resumeMembership() {
  const membership = await getMembership();
  if (!membership || membership.status !== 'PAUSED' || !membership.pausedAt) {
    return { ok: false as const, error: 'not-found' as const };
  }

  const pausedDays = Math.ceil((Date.now() - membership.pausedAt.getTime()) / DAY);
  const endsAt = new Date(membership.endsAt.getTime() + pausedDays * DAY);

  await prisma.membership.update({
    where: { id: membership.id },
    data: {
      status: 'ACTIVE',
      pausedAt: null,
      resumesAt: new Date(),
      endsAt,
      renewsAt: endsAt,
    },
  });

  revalidatePath('/app/journey');
  revalidatePath('/app');
  return { ok: true as const };
}

/** Stops the renewal but leaves the current period fully usable. */
export async function cancelRenewal() {
  const membership = await getMembership();
  if (!membership) return { ok: false as const, error: 'not-found' as const };

  await prisma.membership.update({
    where: { id: membership.id },
    data: { renewsAt: null, cancelledAt: new Date() },
  });

  revalidatePath('/app/journey');
  return { ok: true as const, endsAt: membership.endsAt };
}
