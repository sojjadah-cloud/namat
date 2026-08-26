import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/l10n/numbers.dart';
import '../../../l10n/app_localizations.dart';

/// My Journey.
///
/// Never locked for a member without a package. A locked tab teaches people
/// the app has rooms they are not allowed in; showing what a package would
/// have covered this month teaches them what it is for, using their own
/// activity rather than a brochure.
class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key, this.hasPackage = true});

  final bool hasPackage;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter, NamatSpace.xl, NamatSpace.gutter, 120,
          ),
          children: [
            Text(l.journeyTitle, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: NamatSpace.xxl),
            if (hasPackage) const _MemberJourney() else const _GuestJourney(),
          ],
        ),
      ),
    );
  }
}

class _MemberJourney extends StatelessWidget {
  const _MemberJourney();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        NamatCard(
          organic: true,
          child: Column(
            children: [
              NamatProgressRing(
                value: 0.68,
                size: 156,
                stroke: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('٦٨٪', style: text.displayLarge?.copyWith(fontSize: 38)),
                    Text(l.journeyComplete, style: text.labelSmall,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: NamatSpace.xl),
              const _Meter(icon: NamatIcons.meals, used: 20, total: 30,
                  color: NamatColors.food, labelKey: 'meals'),
              const SizedBox(height: NamatSpace.md),
              const _Meter(icon: NamatIcons.fitness, used: 7, total: 10,
                  color: NamatColors.fitness, labelKey: 'workouts'),
              const SizedBox(height: NamatSpace.md),
              const _Meter(icon: NamatIcons.consultation, used: 1, total: 2,
                  color: NamatColors.nutrition, labelKey: 'consults'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({
    required this.icon,
    required this.used,
    required this.total,
    required this.color,
    required this.labelKey,
  });

  final NamatIcons icon;
  final int used;
  final int total;
  final Color color;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final label = switch (labelKey) {
      'meals' => l.mealsUsed,
      'workouts' => l.workoutsUsed,
      _ => l.consultsUsed,
    };

    return Row(
      children: [
        NamatIcon(icon, size: 20, color: color),
        const SizedBox(width: NamatSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: text.labelMedium),
                  Text('${context.n(used)} / ${context.n(total)}',
                      style: text.labelSmall),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: used / total),
                  duration: NamatMotion.reveal,
                  curve: NamatMotion.curve,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GuestJourney extends StatelessWidget {
  const _GuestJourney();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      organic: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NamatIcon(NamatIcons.leaf, size: 34, color: NamatColors.accent),
          const SizedBox(height: NamatSpace.lg),
          Text(l.startYourJourney, style: text.titleLarge),
          const SizedBox(height: NamatSpace.sm),
          Text(l.ifSubscribed, style: text.bodySmall),
          const SizedBox(height: NamatSpace.lg),
          Text('١٢ ${l.mealsUsed}', style: text.bodyMedium),
          Text('٤ ${l.workoutsUsed}', style: text.bodyMedium),
          Text('١ ${l.consultsUsed}', style: text.bodyMedium),
          const SizedBox(height: NamatSpace.lg),
          Text(l.potentialSaving, style: text.labelSmall),
          Text('١٨٫٤ ر.ع',
              style: text.displayMedium?.copyWith(color: NamatColors.accent)),
          const SizedBox(height: NamatSpace.xl),
          FilledButton(
            onPressed: () => context.go('/use'),
            child: Text(l.explorePackages),
          ),
        ],
      ),
    );
  }
}
