import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/points.dart';

/// Namat Points: the balance, what it buys, and where it came from.
///
/// Rebuilt after the reward cards rendered as blank boxes. The cause was a Row
/// with an unbounded button beside an Expanded column — the button asked for
/// its intrinsic width, the column took the rest, and at 360dp the text had
/// nowhere to go. Every card here now lays out as a column, so nothing
/// competes for width with anything else.
///
/// The order answers the two questions a member actually has, in the order
/// they have them: what is this worth, and what did I do to get it. A balance
/// shown alone answers neither.
class PointsPage extends ConsumerWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final entries = ref.watch(pointsProvider);
    final balance = ref.watch(pointsBalanceProvider);

    // The next thing within reach, so the balance means something. Null once
    // everything is affordable, which is a good problem and needs no prompt.
    final next = namatRewards.where((r) => r.cost > balance).fold<Reward?>(
          null,
          (best, r) => best == null || r.cost < best.cost ? r : best,
        );

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/profile'),
          title: Text(l.pointsTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.lg,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            _Balance(balance: balance, next: next, arabic: arabic),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.rewardsTitle, style: text.titleMedium),
            const SizedBox(height: NamatSpace.md),
            for (final r in namatRewards)
              Padding(
                padding: const EdgeInsets.only(bottom: NamatSpace.md),
                child: _RewardCard(
                  reward: r,
                  balance: balance,
                  arabic: arabic,
                ),
              ),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.pointsHow, style: text.titleMedium),
            const SizedBox(height: NamatSpace.md),
            // Stated as a rate. A programme whose rules are hidden reads as
            // arbitrary, and arbitrary rewards change nobody's behaviour.
            NamatCard(
              padding: const EdgeInsets.all(NamatSpace.lg),
              child: Column(
                children: [
                  for (final reason in const [
                    PointsReason.order,
                    PointsReason.review,
                    PointsReason.challenge,
                    PointsReason.newPartner,
                    PointsReason.streak,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _reasonLabel(reason, l),
                              style: text.bodySmall,
                            ),
                          ),
                          const SizedBox(width: NamatSpace.sm),
                          Text(
                            l.pointsEarned(
                              context.n(pointsFor[reason] ?? 0),
                            ),
                            style: text.labelMedium
                                ?.copyWith(color: NamatColors.accent),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.recentOrders, style: text.titleMedium),
            const SizedBox(height: NamatSpace.md),
            if (entries.isEmpty)
              NamatCard(
                padding: const EdgeInsets.all(NamatSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.pointsEmpty, style: text.bodyMedium),
                    const SizedBox(height: 2),
                    Text(l.pointsEmptyBody, style: text.labelSmall),
                  ],
                ),
              )
            else
              NamatCard(
                padding: const EdgeInsets.all(NamatSpace.lg),
                child: Column(
                  children: [
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: NamatSpace.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _reasonLabel(e.reason, l),
                                    style: text.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.dateTime(e.at),
                                    style: text.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: NamatSpace.sm),
                            Text(
                              // The sign is carried, so a redemption reads as
                              // a subtraction rather than as another award.
                              e.amount >= 0
                                  ? l.pointsEarned(context.n(e.amount))
                                  : '−${context.n(-e.amount)}',
                              style: text.labelMedium?.copyWith(
                                color: e.amount >= 0
                                    ? NamatColors.accent
                                    : NamatColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }

  static String _reasonLabel(PointsReason r, L l) => switch (r) {
        PointsReason.order => l.pointsEarnOrder,
        PointsReason.review => l.pointsEarnReview,
        PointsReason.challenge => l.pointsEarnChallenge,
        PointsReason.streak => l.pointsEarnStreak,
        PointsReason.newPartner => l.pointsEarnNewPartner,
        PointsReason.redeemed => l.pointsRedeemedLabel,
      };
}

/// The balance, and how far it is from the next thing worth having.
class _Balance extends StatelessWidget {
  const _Balance({
    required this.balance,
    required this.next,
    required this.arabic,
  });

  final int balance;
  final Reward? next;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final target = next;
    final progress = target == null ? 1.0 : (balance / target.cost).clamp(0.0, 1.0);

    return NamatCard(
      organic: true,
      color: NamatColors.goldSoft,
      elevated: false,
      padding: const EdgeInsets.all(NamatSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NamatIcon(
                NamatIcons.reward,
                size: 22,
                color: NamatColors.gold,
              ),
              const SizedBox(width: NamatSpace.sm),
              Text(l.pointsBalance, style: text.labelMedium),
            ],
          ),
          const SizedBox(height: NamatSpace.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(context.n(balance), style: text.displayLarge),
              const SizedBox(width: 6),
              Text(l.pointsTitle, style: text.bodySmall),
            ],
          ),
          if (target != null) ...[
            const SizedBox(height: NamatSpace.lg),
            // A bar toward one specific reward, not toward "more points". A
            // balance with nothing to measure it against is a number.
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: NamatMotion.slow,
                curve: NamatMotion.enter,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 7,
                  backgroundColor: Colors.white.withOpacity(0.6),
                  valueColor: const AlwaysStoppedAnimation(NamatColors.gold),
                ),
              ),
            ),
            const SizedBox(height: NamatSpace.sm),
            Text(
              '${target.localisedTitle(arabic)} · '
              '${l.pointsShort(context.n(target.cost - balance))}',
              style: text.labelSmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardCard extends ConsumerWidget {
  const _RewardCard({
    required this.reward,
    required this.balance,
    required this.arabic,
  });

  final Reward reward;
  final int balance;
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final affordable = balance >= reward.cost;
    final short = reward.cost - balance;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.lg),
      // A column, not a row. The old layout put an unbounded button beside an
      // Expanded column, which at 360dp left the text no width at all and drew
      // an empty card.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reward.localisedTitle(arabic),
                  style: text.titleMedium,
                ),
              ),
              const SizedBox(width: NamatSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: affordable
                      ? NamatColors.greenSoft
                      : NamatColors.warmSoft,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  l.pointsCost(context.n(reward.cost)),
                  style: text.labelSmall?.copyWith(
                    color: affordable
                        ? NamatColors.accent
                        : NamatColors.inkSoft,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(reward.localisedDetail(arabic), style: text.bodySmall),
          const SizedBox(height: NamatSpace.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: affordable
                  ? () {
                      final ok = ref
                          .read(pointsProvider.notifier)
                          .redeem(reward.cost, detail: reward.id);
                      if (!ok) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.redeemed),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              child: Text(
                // How far off, rather than a dead button with no explanation.
                // "Redeem" greyed out tells a member with 60 points nothing
                // they can act on.
                affordable ? l.redeem : l.pointsShort(context.n(short)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
