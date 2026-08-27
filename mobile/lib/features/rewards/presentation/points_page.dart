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

/// Namat Points: the balance, what it can buy, and where it came from.
///
/// The ledger is the point of the screen. A member who cannot see why their
/// balance moved does not trust it — and a balance shown alone answers a
/// question nobody asked, while the two they do ask are "what is this worth"
/// and "what did I do to get it".
class PointsPage extends ConsumerWidget {
  const PointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final entries = ref.watch(pointsProvider);
    final balance = ref.watch(pointsBalanceProvider);

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
            NamatCard(
              color: NamatColors.goldSoft,
              elevated: false,
              padding: const EdgeInsets.all(NamatSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.pointsBalance, style: text.labelSmall),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(context.n(balance), style: text.displayMedium),
                      const SizedBox(width: 6),
                      Text(l.pointsTitle, style: text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: NamatSpace.xxl),

            Text(l.rewardsTitle, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            for (final r in namatRewards)
              Padding(
                padding: const EdgeInsets.only(bottom: NamatSpace.sm),
                child: _RewardCard(reward: r, balance: balance, arabic: arabic),
              ),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.pointsHow, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            // Stated as a rate, not as a mystery. A programme whose rules are
            // hidden reads as arbitrary, and arbitrary rewards do not change
            // behaviour.
            for (final reason in [
              PointsReason.order,
              PointsReason.review,
              PointsReason.challenge,
              PointsReason.newPartner,
              PointsReason.streak,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_reasonLabel(reason, l), style: text.bodySmall),
                    ),
                    Text(
                      l.pointsEarned(context.n(pointsFor[reason] ?? 0)),
                      style: text.labelSmall
                          ?.copyWith(color: NamatColors.accent),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: NamatSpace.xxl),
            Text(l.myOrders, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: NamatSpace.lg),
                child: NamatEmptyState(
                  illustration: const NamatIcon(
                    NamatIcons.reward,
                    size: 44,
                    color: NamatColors.inkSoft,
                  ),
                  title: l.pointsEmpty,
                  body: l.pointsEmptyBody,
                ),
              )
            else
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: NamatSpace.sm),
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
                      Text(
                        // The sign is carried, so a redemption reads as a
                        // subtraction rather than as another award.
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.localisedTitle(arabic), style: text.bodyMedium),
                const SizedBox(height: 2),
                Text(reward.localisedDetail(arabic), style: text.labelSmall),
                const SizedBox(height: 6),
                Text(
                  // How far off, rather than a bare price. "400 points" tells
                  // a member with 260 nothing they can act on.
                  affordable
                      ? l.pointsCost(context.n(reward.cost))
                      : l.pointsShort(context.n(short)),
                  style: text.labelSmall?.copyWith(
                    color:
                        affordable ? NamatColors.accent : NamatColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: NamatSpace.sm),
          FilledButton(
            onPressed: affordable
                ? () {
                    final ok = ref.read(pointsProvider.notifier).redeem(
                          reward.cost,
                          detail: reward.id,
                        );
                    if (!ok) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.redeemed),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : null,
            child: Text(l.redeem),
          ),
        ],
      ),
    );
  }
}
