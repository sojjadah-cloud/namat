'use server';

import { revalidatePath } from 'next/cache';
import type { ActivityLevel, Category, TimePreference } from '@prisma/client';
import { prisma } from '@/lib/prisma';
import { getCurrentUser } from '@/server/session';

/**
 * Personalization writes. Every one of these re-ranks Home, so they all
 * revalidate `/app` — a preference change the feed ignores would read as the
 * setting not working.
 */

export type OnboardingAnswers = {
  goals: string[];
  interests: Category[];
  activityLevel: ActivityLevel;
  timePreference: TimePreference;
  dietary: string[];
  womenOnly: boolean;
  citySlug?: string;
};

export async function completeOnboarding(answers: OnboardingAnswers) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const city = answers.citySlug
    ? await prisma.city.findUnique({ where: { slug: answers.citySlug } })
    : null;

  const data = {
    goals: answers.goals,
    interests: answers.interests,
    activityLevel: answers.activityLevel,
    timePreference: answers.timePreference,
    dietary: answers.dietary,
    womenOnly: answers.womenOnly,
    cityId: city?.id ?? null,
    onboardedAt: new Date(),
  };

  await prisma.profile.upsert({
    where: { userId: user.id },
    create: { userId: user.id, ...data },
    update: data,
  });

  revalidatePath('/app');
  revalidatePath('/app/journey');
  return { ok: true as const };
}

export async function updateProfile(patch: Partial<OnboardingAnswers> & { name?: string }) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const { name, citySlug, ...profilePatch } = patch;

  if (name) {
    await prisma.user.update({ where: { id: user.id }, data: { name } });
  }

  const city = citySlug
    ? await prisma.city.findUnique({ where: { slug: citySlug } })
    : undefined;

  await prisma.profile.upsert({
    where: { userId: user.id },
    create: {
      userId: user.id,
      goals: [],
      interests: [],
      ...profilePatch,
      ...(city ? { cityId: city.id } : {}),
    },
    update: { ...profilePatch, ...(city ? { cityId: city.id } : {}) },
  });

  revalidatePath('/app');
  revalidatePath('/app/profile');
  revalidatePath('/app/journey');
  return { ok: true as const };
}

export async function setLocale(locale: 'ar' | 'en') {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const };
  await prisma.user.update({ where: { id: user.id }, data: { locale } });
  return { ok: true as const };
}

/** Toggle rather than add/remove: the heart is one control, not two. */
export async function toggleFavorite(providerId: string) {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const, error: 'unauthenticated' as const };

  const existing = await prisma.favorite.findUnique({
    where: { userId_providerId: { userId: user.id, providerId } },
  });

  if (existing) {
    await prisma.favorite.delete({ where: { id: existing.id } });
  } else {
    await prisma.favorite.create({ data: { userId: user.id, providerId } });
  }

  revalidatePath('/app/profile/favorites');
  return { ok: true as const, favorited: !existing };
}

export async function markNotificationsRead() {
  const user = await getCurrentUser();
  if (!user) return { ok: false as const };

  await prisma.notification.updateMany({
    where: { userId: user.id, readAt: null },
    data: { readAt: new Date() },
  });

  revalidatePath('/app/notifications');
  revalidatePath('/app');
  return { ok: true as const };
}
