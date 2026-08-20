'use server';

import { revalidatePath } from 'next/cache';
import { prisma } from '@/lib/prisma';
import { getCurrentUser, getMembership } from '@/server/session';

/**
 * Booking mutations.
 *
 * Capacity is enforced inside a transaction with a conditional update rather
 * than a read-then-write: two people tapping the same 6pm reformer slot at the
 * same moment is the normal case, not the edge case.
 */

export type BookingResult =
  | { ok: true; bookingId: string; reference: string }
  | { ok: false; error: 'unauthenticated' | 'taken' | 'not-found' | 'generic' };

function reference() {
  return `NMT-${Math.floor(100000 + Math.random() * 900000)}`;
}

export async function createBooking(slotId: string): Promise<BookingResult> {
  const user = await getCurrentUser();
  if (!user) return { ok: false, error: 'unauthenticated' };

  const membership = await getMembership();
  const coveringSlug = membership?.status === 'ACTIVE' ? membership.package.slug : null;

  try {
    return await prisma.$transaction(async (tx) => {
      const slot = await tx.slot.findUnique({
        where: { id: slotId },
        include: { service: { include: { provider: true } } },
      });

      if (!slot || slot.startsAt.getTime() < Date.now()) {
        return { ok: false as const, error: 'not-found' as const };
      }

      // Only claims the seat if it is still there.
      const claimed = await tx.slot.updateMany({
        where: { id: slotId, booked: { lt: slot.capacity } },
        data: { booked: { increment: 1 } },
      });
      if (claimed.count === 0) return { ok: false as const, error: 'taken' as const };

      const category = slot.service.category;
      const allowance = membership?.package.allowances.find((a) => a.category === category);
      const usage = membership?.usage.find((u) => u.category === category);
      const covered =
        Boolean(coveringSlug && slot.service.includedIn.includes(coveringSlug)) &&
        Boolean(allowance) &&
        (usage?.used ?? 0) < (allowance?.quantity ?? 0);

      if (covered && membership) {
        await tx.usage.upsert({
          where: { membershipId_category: { membershipId: membership.id, category } },
          create: { membershipId: membership.id, category, used: 1 },
          update: { used: { increment: 1 } },
        });
      }

      const booking = await tx.booking.create({
        data: {
          reference: reference(),
          userId: user.id,
          serviceId: slot.serviceId,
          providerId: slot.service.providerId,
          slotId: slot.id,
          startsAt: slot.startsAt,
          price: covered ? 0 : slot.service.price,
          coveredByMembership: covered,
          paymentMethod: covered ? null : 'card',
        },
      });

      return { ok: true as const, bookingId: booking.id, reference: booking.reference };
    });
  } catch {
    return { ok: false, error: 'generic' };
  } finally {
    revalidatePath('/app');
    revalidatePath('/app/bookings');
    revalidatePath('/app/journey');
  }
}

/**
 * Cancelling returns the seat and, inside the free window, the allowance.
 * Outside it the session is counted — the policy the provider page states.
 */
const FREE_CANCEL_HOURS = 6;

export async function cancelBooking(bookingId: string) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const booking = await prisma.booking.findFirst({
    where: { id: bookingId, userId: user.id, status: 'CONFIRMED' },
    include: { service: true },
  });
  if (!booking) return { ok: false as const, error: 'not-found' as const };

  const hoursOut = (booking.startsAt.getTime() - Date.now()) / 3_600_000;
  const refundAllowance = hoursOut >= FREE_CANCEL_HOURS;

  await prisma.$transaction(async (tx) => {
    await tx.booking.update({
      where: { id: bookingId },
      data: { status: 'CANCELLED', cancelledAt: new Date() },
    });

    if (booking.slotId) {
      await tx.slot.updateMany({
        where: { id: booking.slotId, booked: { gt: 0 } },
        data: { booked: { decrement: 1 } },
      });
    }

    if (booking.coveredByMembership && refundAllowance) {
      const membership = await tx.membership.findFirst({
        where: { userId: user.id, status: 'ACTIVE' },
      });
      if (membership) {
        await tx.usage.updateMany({
          where: {
            membershipId: membership.id,
            category: booking.service.category,
            used: { gt: 0 },
          },
          data: { used: { decrement: 1 } },
        });
      }
    }
  });

  revalidatePath('/app/bookings');
  revalidatePath('/app/journey');
  revalidatePath('/app');
  return { ok: true as const, refunded: refundAllowance };
}

/** Reschedule is a seat swap, not a cancel-and-rebook: the allowance is untouched. */
export async function rescheduleBooking(bookingId: string, newSlotId: string) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  try {
    return await prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findFirst({
        where: { id: bookingId, userId: user.id, status: 'CONFIRMED' },
      });
      if (!booking) return { ok: false as const, error: 'not-found' as const };

      const slot = await tx.slot.findUnique({ where: { id: newSlotId } });
      if (!slot || slot.serviceId !== booking.serviceId) {
        return { ok: false as const, error: 'not-found' as const };
      }

      const claimed = await tx.slot.updateMany({
        where: { id: newSlotId, booked: { lt: slot.capacity } },
        data: { booked: { increment: 1 } },
      });
      if (claimed.count === 0) return { ok: false as const, error: 'taken' as const };

      if (booking.slotId) {
        await tx.slot.updateMany({
          where: { id: booking.slotId, booked: { gt: 0 } },
          data: { booked: { decrement: 1 } },
        });
      }

      await tx.booking.update({
        where: { id: bookingId },
        data: { slotId: newSlotId, startsAt: slot.startsAt },
      });

      return { ok: true as const };
    });
  } catch {
    return { ok: false as const, error: 'generic' as const };
  } finally {
    revalidatePath('/app/bookings');
  }
}
