import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/l10n/numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/domain/profile_draft.dart';
import '../../bookings/domain/cart_notifier.dart';

/// Home: what today looks like.
///
/// The daily status leads because it answers the question people open a
/// wellness app with — "am I on track?" — before offering anything to browse.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final evening = DateTime.now().hour >= 16;

    // The name the member gave during setup. Empty for anyone who skipped it
    // or came in through sign-in, so the greeting drops the name rather than
    // addressing them as a blank.
    final name = ref.watch(profileDraftProvider).name;
    final cartCount = ref.watch(cartCountProvider);
    final unrated = ref.watch(unratedOrderProvider);

    return NamatBackground(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            Row(
              children: [
                NamatAvatar(name: name),
                const SizedBox(width: NamatSpace.md),
                Expanded(
                  child: Text(
                    name.isEmpty
                        ? l.useGreeting
                        : evening
                            ? l.greetingEvening(name)
                            : l.greetingMorning(name),
                    style: text.titleMedium,
                    maxLines: 2,
                  ),
                ),
                // Only once there is something in it. A permanently visible
                // empty cart is a button that never does anything.
                if (cartCount > 0)
                  _CartButton(count: cartCount),
                IconButton(
                  onPressed: () => context.go('/home/notifications'),
                  icon: const NamatIcon(NamatIcons.bell, size: 22),
                ),
              ],
            ),
            if (unrated != null) ...[
              const SizedBox(height: NamatSpace.xl),
              // Asked once, about the most recent order only. A backlog of
              // rating prompts is a chore, and chores get dismissed unread.
              NamatCard(
                color: NamatColors.goldSoft,
                elevated: false,
                padding: const EdgeInsets.all(NamatSpace.lg),
                onTap: () => context.go('/rate/${unrated.reference}'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: NamatColors.gold,
                      size: 22,
                    ),
                    const SizedBox(width: NamatSpace.md),
                    Expanded(
                      child: Text(
                        '${l.rateTitle} ${unrated.leadTitle}',
                        style: text.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            ],
            const SizedBox(height: NamatSpace.xl),
            const _DailyStatus(),
            const SizedBox(height: NamatSpace.xxl),
            Text(l.useGreeting, style: text.titleMedium),
            const SizedBox(height: NamatSpace.md),
            const _QuickActions(),
          ]),
        ),
      ),
    );
  }
}

/// The score, with three arcs around it.
///
/// A single number is a verdict; three arcs show which part is carrying it and
/// which part is not, which is the difference between a score you argue with
/// and one you act on.
class _DailyStatus extends StatelessWidget {
  const _DailyStatus();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return NamatCard(
      organic: true,
      child: Column(
        children: [
          NamatProgressRing(
            value: 0.85,
            size: 148,
            stroke: 11,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '٨٥',
                  style: text.displayLarge?.copyWith(fontSize: 40),
                ),
                Text(l.namatPoints, style: text.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: NamatSpace.md),
          Text(
            l.doingGreat,
            style: text.bodySmall?.copyWith(color: NamatColors.accent),
          ),
          const SizedBox(height: NamatSpace.xl),
          Row(
            children: [
              _Arc(label: l.arcNutrition, value: 0.6, color: NamatColors.food),
              _Arc(label: l.arcMovement, value: 0.8, color: NamatColors.fitness),
              _Arc(
                label: l.arcHydration,
                value: 0.75,
                color: NamatColors.nutrition,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Arc extends StatelessWidget {
  const _Arc({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          NamatProgressRing(
            value: value,
            size: 46,
            stroke: 5,
            color: color,
            track: color.withOpacity(0.15),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    final actions = <(NamatIcons, String, Color, Color, String)>[
      (NamatIcons.meals, l.quickBookMeal, NamatColors.food,
          NamatColors.foodSoft, '/use/meals'),
      (NamatIcons.fitness, l.quickFindActivity, NamatColors.fitness,
          NamatColors.fitnessSoft, '/use/fitness'),
      (NamatIcons.consultation, l.quickConsult, NamatColors.nutrition,
          NamatColors.nutritionSoft, '/use/consult'),
      (NamatIcons.challenge, l.quickStartChallenge, NamatColors.pilates,
          NamatColors.pilatesSoft, '/challenges'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: NamatSpace.md,
      crossAxisSpacing: NamatSpace.md,
      childAspectRatio: 1.55,
      children: [
        for (final (icon, label, accent, tint, route) in actions)
          NamatCard(
            color: tint,
            elevated: false,
            padding: const EdgeInsets.all(NamatSpace.lg),
            onTap: () => context.go(route),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NamatIcon(icon, size: 26, color: accent),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A generated avatar: an initial on an organic gradient.
///
/// Nobody is asked for a photograph. Most people never upload one, and a grey
/// silhouette in every row makes an app look abandoned.
class NamatAvatar extends StatelessWidget {
  const NamatAvatar({super.key, required this.name, this.size = 42});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Deterministic from the name, so the same person is the same colour on
    // every screen and between sessions.
    final hue = name.codeUnits.fold<int>(0, (a, b) => a + b) % 4;
    final tint = [
      NamatColors.greenSoft,
      NamatColors.warm,
      NamatColors.nutritionSoft,
      NamatColors.pilatesSoft,
    ][hue];
    final ink = [
      NamatColors.accent,
      NamatColors.gold,
      NamatColors.nutrition,
      NamatColors.pilates,
    ][hue];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, tint.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(size * 0.42),
      ),
      child: Text(
        name.isEmpty ? '؟' : name.substring(0, 1),
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () => context.go('/cart'),
          icon: const NamatIcon(NamatIcons.store, size: 22),
        ),
        Positioned(
          top: 6,
          // Placed by direction rather than by side, so the badge stays on the
          // outer corner of the icon in both layouts.
          right: Directionality.of(context) == TextDirection.rtl ? null : 6,
          left: Directionality.of(context) == TextDirection.rtl ? 6 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: NamatColors.deep,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              context.n(count),
              style: text.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
