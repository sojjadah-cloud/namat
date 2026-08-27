import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/cart_notifier.dart';
import '../../membership/domain/membership.dart';
import '../domain/habits.dart';

/// My Journey — the heart of the app.
///
/// The claim NAMAT makes is not that it helps people start. Starting is easy
/// and every app in this category does it. The claim is that it helps people
/// continue, and this is the screen where that claim is either true or it is
/// marketing: today, the week behind it, what is coming, and what the package
/// has actually covered.
///
/// Never locked for a member without a package. A locked tab teaches people
/// the app has rooms they are not allowed in; showing what a package would
/// have covered — computed from their own orders, not from a brochure — is an
/// argument they cannot dismiss as marketing.
class JourneyPage extends ConsumerWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final streak = ref.watch(streakProvider);
    final membership = ref.watch(membershipProvider);

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.xl,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            Row(
              children: [
                Expanded(
                  child: Text(l.journeyTitle, style: text.displayMedium),
                ),
                if (streak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: NamatColors.goldSoft,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      l.streakDays(context.n(streak)),
                      style: text.labelSmall
                          ?.copyWith(color: NamatColors.gold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: NamatSpace.xl),
            const _Today(),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.lastSevenDays, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            const _Week(),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.upcomingTitle, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            const _Upcoming(),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.membershipTitle, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            if (membership == null)
              const _NoMembership()
            else
              _Membership(membership: membership),

            const SizedBox(height: NamatSpace.xxl),
            NamatCard(
              color: NamatColors.pilatesSoft,
              elevated: false,
              padding: const EdgeInsets.all(NamatSpace.lg),
              onTap: () => context.go('/journey/challenges'),
              child: Row(
                children: [
                  const NamatIcon(
                    NamatIcons.challenge,
                    size: 22,
                    color: NamatColors.pilates,
                  ),
                  const SizedBox(width: NamatSpace.md),
                  Expanded(
                    child: Text(l.challengesTitle, style: text.bodyMedium),
                  ),
                  const Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: NamatColors.inkSoft,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Today's habits: one tap each.
class _Today extends ConsumerWidget {
  const _Today();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayProvider);

    return NamatCard(
      organic: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.todayTitle, style: text.titleMedium)),
              Text(
                context.n((today.completion * 100).round()),
                style: text.titleMedium?.copyWith(color: NamatColors.accent),
              ),
              Text('%', style: text.labelSmall),
            ],
          ),
          const SizedBox(height: NamatSpace.xs),
          Text(l.habitsHint, style: text.labelSmall),
          const SizedBox(height: NamatSpace.lg),
          for (final habit in Habit.values)
            Padding(
              padding: const EdgeInsets.only(bottom: NamatSpace.sm),
              child: _HabitRow(habit: habit, day: today),
            ),
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.day});

  final Habit habit;
  final HabitDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final done = day.of(habit);
    final met = day.isMet(habit);

    return Pressable(
      onTap: () => ref.read(habitsProvider.notifier).log(habit),
      child: AnimatedContainer(
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        padding: const EdgeInsets.all(NamatSpace.md),
        decoration: BoxDecoration(
          color: met ? NamatColors.greenSoft : NamatColors.warmSoft,
          borderRadius: BorderRadius.circular(NamatRadius.sm),
        ),
        child: Row(
          children: [
            Icon(
              _icon(habit),
              size: 19,
              color: met ? NamatColors.accent : NamatColors.inkSoft,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(child: Text(_label(habit, l), style: text.bodySmall)),
            if (habit.isCounted)
              Text(
                l.glassesOf(context.n(done), context.n(habit.target)),
                style: text.labelSmall?.copyWith(
                  color: met ? NamatColors.accent : NamatColors.inkSoft,
                ),
              )
            else
              AnimatedScale(
                scale: met ? 1 : 0,
                duration: NamatMotion.fast,
                curve: NamatMotion.enter,
                child: const Icon(
                  Icons.check_circle,
                  size: 19,
                  color: NamatColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _label(Habit h, L l) => switch (h) {
        Habit.water => l.habitWater,
        Habit.steps => l.habitSteps,
        Habit.workout => l.habitWorkout,
        Habit.healthyMeal => l.habitMeal,
        Habit.sleep => l.habitSleep,
      };

  static IconData _icon(Habit h) => switch (h) {
        Habit.water => Icons.water_drop_outlined,
        Habit.steps => Icons.directions_walk,
        Habit.workout => Icons.fitness_center,
        Habit.healthyMeal => Icons.restaurant_outlined,
        Habit.sleep => Icons.bedtime_outlined,
      };
}

/// Seven bars, oldest on the leading edge.
///
/// A shape rather than a number: the useful thing about a week is whether it
/// is holding up, and a percentage cannot show a member that they fall off
/// every Thursday.
class _Week extends ConsumerWidget {
  const _Week();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(weekProvider);

    return SizedBox(
      height: 92,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final day in week)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: day.completion),
                      duration: NamatMotion.slow,
                      curve: NamatMotion.enter,
                      builder: (context, v, _) => Container(
                        height: 8 + v * 60,
                        decoration: BoxDecoration(
                          color: v == 0
                              ? NamatColors.line
                              : Color.lerp(
                                  NamatColors.sageLight,
                                  NamatColors.deep,
                                  v,
                                ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      // The weekday letter, from the locale rather than from a
                      // hand-written list — Arabic weekday names are not a
                      // translation of the English ones.
                      _weekdayLetter(context, day.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _weekdayLetter(BuildContext context, DateTime d) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    const ar = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
    const en = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return (arabic ? ar : en)[d.weekday - 1];
  }
}

/// What is booked, soonest first.
class _Upcoming extends ConsumerWidget {
  const _Upcoming();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final now = DateTime.now();

    final upcoming = ref
        .watch(ordersProvider)
        .where((o) => o.slot != null && o.slot!.isAfter(now))
        .toList()
      ..sort((a, b) => a.slot!.compareTo(b.slot!));

    if (upcoming.isEmpty) {
      return NamatCard(
        padding: const EdgeInsets.all(NamatSpace.lg),
        onTap: () => context.go('/explore'),
        child: Row(
          children: [
            const Icon(
              Icons.event_available,
              size: 20,
              color: NamatColors.inkSoft,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(
              child: Text(l.nothingUpcoming, style: text.bodySmall),
            ),
            const Icon(
              Icons.chevron_left,
              size: 18,
              color: NamatColors.inkSoft,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final o in upcoming.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.sm),
            child: NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              onTap: () => context.go('/bookings'),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.leadTitle, style: text.bodyMedium),
                        const SizedBox(height: 2),
                        Text(
                          context.dateTime(o.slot!),
                          style: text.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: NamatColors.inkSoft,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The package, with counters that come from the member's own orders.
class _Membership extends ConsumerWidget {
  const _Membership({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final pack = membership.package;
    final used = ref.watch(allowanceUsedProvider);

    if (pack == null) return const SizedBox.shrink();

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.xl),
      onTap: () => context.go('/journey/packages'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pack.localisedName(arabic),
                  style: text.titleMedium,
                ),
              ),
              if (membership.paused)
                Text(
                  l.membershipPaused,
                  style: text.labelSmall?.copyWith(color: NamatColors.gold),
                )
              else
                Text(
                  l.renewsIn(context.n(membership.daysRemaining)),
                  style: text.labelSmall,
                ),
            ],
          ),
          const SizedBox(height: NamatSpace.lg),
          // The counters are the product: a member renews because they can see
          // eleven of twelve meals were used, not because a card told them the
          // package was good value.
          for (final entry in pack.grants.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: NamatSpace.md),
              child: _AllowanceBar(
                label: _allowanceLabel(entry.key, l),
                used: used[entry.key] ?? 0,
                total: entry.value,
              ),
            ),
        ],
      ),
    );
  }

  static String _allowanceLabel(Allowance a, L l) => switch (a) {
        Allowance.meals => l.allowanceMeals,
        Allowance.sessions => l.allowanceSessions,
        Allowance.consultations => l.allowanceConsults,
      };
}

class _AllowanceBar extends StatelessWidget {
  const _AllowanceBar({
    required this.label,
    required this.used,
    required this.total,
  });

  final String label;
  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final fraction = total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: text.bodySmall)),
            Text(
              l.usedOf(context.n(used), context.n(total)),
              style: text.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: NamatMotion.base,
            curve: NamatMotion.enter,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: NamatColors.line,
              valueColor: const AlwaysStoppedAnimation(NamatColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// No package: what one would have covered, from the member's own orders.
class _NoMembership extends ConsumerWidget {
  const _NoMembership();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final saving = ref.watch(potentialSavingProvider);

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.xl),
      onTap: () => context.go('/journey/packages'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.noMembership, style: text.titleMedium),
          const SizedBox(height: NamatSpace.xs),
          Text(l.noMembershipBody, style: text.bodySmall),
          if (saving > 0) ...[
            const SizedBox(height: NamatSpace.md),
            // Their own spending, not a brochure figure. It is the one
            // argument for a package a member cannot dismiss as marketing.
            Text(
              l.savedThisMonth(context.money(saving), l.omr),
              style: text.labelMedium?.copyWith(color: NamatColors.accent),
            ),
          ],
          const SizedBox(height: NamatSpace.lg),
          FilledButton(
            onPressed: () => context.go('/journey/packages'),
            child: Text(l.explorePackages),
          ),
        ],
      ),
    );
  }
}
