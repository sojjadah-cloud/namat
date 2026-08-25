import 'package:flutter/material.dart';

import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;

/// Challenges.
///
/// The VS card leads because a live contest is the only thing on this screen
/// with a deadline. Browsing for a new challenge is what you do once today's
/// is dealt with, so it sits underneath.
class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

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
          children: [
            Text(l.challengesTitle, style: text.displayMedium),
            const SizedBox(height: 4),
            Text(
              l.challengesHero,
              style: text.bodySmall?.copyWith(color: NamatColors.accent),
            ),
            const SizedBox(height: NamatSpace.xl),
            FilledButton.icon(
              onPressed: () {},
              icon: const NamatIcon(
                NamatIcons.challenge,
                size: 20,
                color: Colors.white,
              ),
              label: Text(l.challengeSomeone),
            ),
            const SizedBox(height: NamatSpace.xxl),
            const _VersusCard(),
          ],
        ),
      ),
    );
  }
}

class _VersusCard extends StatelessWidget {
  const _VersusCard();

  static const _mine = 8420;
  static const _theirs = 7950;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    const total = _mine + _theirs;

    return NamatCard(
      organic: true,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _Side(name: 'خالد', score: _mine)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: NamatColors.deep,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  l.vs,
                  style: text.labelMedium?.copyWith(color: Colors.white),
                ),
              ),
              const Expanded(child: _Side(name: 'أحمد', score: _theirs)),
            ],
          ),
          const SizedBox(height: NamatSpace.xl),
          // One bar split between the two, so the lead reads as a proportion
          // rather than two numbers the reader has to subtract.
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: _mine / total),
              duration: NamatMotion.reveal,
              curve: NamatMotion.curve,
              builder: (context, v, _) => Row(
                children: [
                  Expanded(
                    flex: (v * 1000).round(),
                    child: Container(height: 8, color: NamatColors.accent),
                  ),
                  Expanded(
                    flex: ((1 - v) * 1000).round(),
                    child: Container(height: 8, color: NamatColors.sageLight),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NamatSpace.md),
          Text(
            l.youLeadBy('٤٧٠'),
            style: text.labelMedium?.copyWith(color: NamatColors.accent),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.name, required this.score});

  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        NamatAvatar(name: name, size: 54),
        const SizedBox(height: NamatSpace.sm),
        Text(name, style: text.labelMedium),
        const SizedBox(height: 2),
        // Counting up on entry makes the score feel live rather than printed.
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: NamatMotion.reveal,
          curve: NamatMotion.curve,
          builder: (context, v, _) => Text('$v', style: text.titleLarge),
        ),
      ],
    );
  }
}
