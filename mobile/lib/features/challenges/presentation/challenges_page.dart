import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../core/widgets/namat_states.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/duels_provider.dart';
import '../domain/personal_challenges.dart';
import '../../rewards/domain/points.dart';
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // A bare back bar: the page's own display heading names it, so an
        // AppBar title would say it twice. Every screen a member navigates
        // into now has one — a page you can enter and not leave is the fault
        // people report as the app being stuck.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const NamatBack(fallback: '/journey'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.xl,
            NamatSpace.gutter,
            120,
          ),
          children: revealAll([
            Text(l.challengesTitle, style: text.displayMedium),
            const SizedBox(height: 4),
            Text(
              l.challengesHero,
              style: text.bodySmall?.copyWith(color: NamatColors.accent),
            ),
            const SizedBox(height: NamatSpace.xl),
            FilledButton.icon(
              onPressed: () => context.go('/journey/challenges/find'),
              icon: const NamatIcon(
                NamatIcons.challenge,
                size: 20,
                color: Colors.white,
              ),
              label: Text(l.challengeSomeone),
            ),
            const SizedBox(height: NamatSpace.xxl),
            // Personal challenges first. They are the only kind that can be
            // scored honestly without a server, and they are the kind the
            // product is actually about — competing with a friend is a way to
            // start, finishing seven days running is the thing NAMAT claims
            // to help with.
            Text(l.personalChallenges, style: text.labelMedium),
            const SizedBox(height: 2),
            Text(l.personalChallengesSub, style: text.labelSmall),
            const SizedBox(height: NamatSpace.md),
            const _PersonalChallenges(),
            const SizedBox(height: NamatSpace.section),
            Text(l.yourChallenges, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            const _CurrentDuel(),
            const SizedBox(height: NamatSpace.section),
            Text(l.officialChallenges, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            const _OfficialChallenges(),
          ]),
        ),
      ),
    );
  }
}

/// The duel the member is actually in, or an invitation to start one.
///
/// A fixture duel used to live here — خالد on 8,420 against أحمد on 7,950 —
/// so a brand-new account opened onto a competition it had never entered. On
/// the first screen a member sees, sample data does not read as a placeholder;
/// it reads as the app being wrong about them.
class _CurrentDuel extends ConsumerWidget {
  const _CurrentDuel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final duel = ref.watch(currentDuelProvider);

    if (duel == null) {
      return NamatCard(
        padding: const EdgeInsets.all(NamatSpace.xl),
        onTap: () => context.go('/journey/challenges/find'),
        child: Row(
          children: [
            const NamatIcon(
              NamatIcons.challenge,
              size: 22,
              color: NamatColors.inkSoft,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(child: Text(l.noChallenges, style: text.bodySmall)),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: NamatColors.inkSoft,
            ),
          ],
        ),
      );
    }

    final total = duel.myScore + duel.theirScore;
    final share = total == 0 ? 0.5 : duel.myScore / total;
    final lead = duel.myScore - duel.theirScore;

    return NamatCard(
      organic: true,
      onTap: () => context.go('/journey/challenges/room'),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Side(name: '', score: duel.myScore)),
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
              Expanded(
                child: _Side(name: duel.opponent, score: duel.theirScore),
              ),
            ],
          ),
          const SizedBox(height: NamatSpace.xl),
          // One bar split between the two, so the lead reads as a proportion
          // rather than two numbers the reader has to subtract.
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: share),
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
            // All three states, because "you lead by 0" is not a sentence and
            // a member who is behind should be told so plainly.
            lead == 0
                ? l.drawSoFar
                : lead > 0
                    ? l.youLeadBy(context.n(lead))
                    : l.behindBy(context.n(-lead)),
            style: text.labelMedium?.copyWith(
              color: lead >= 0 ? NamatColors.accent : NamatColors.inkSoft,
            ),
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
          builder: (context, v, _) =>
              Text(context.n(v), style: text.titleLarge),
        ),
      ],
    );
  }
}

/// Challenges NAMAT runs itself, alongside the peer duels.
///
/// These are open to everyone, subscriber or not. Putting basic competition
/// behind a package would make the social half of the product a paid feature,
/// which is the opposite of why it exists.
class _OfficialChallenges extends StatelessWidget {
  const _OfficialChallenges();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;

    const items = [
      (
        title: 'تحدي نمط الأسبوعي',
        detail: 'امشِ ٥٠٬٠٠٠ خطوة هذا الأسبوع',
        people: 1248,
        points: 250,
        icon: NamatIcons.fitness,
        accent: NamatColors.fitness,
        tint: NamatColors.fitnessSoft,
      ),
      (
        title: 'ثمانية أكواب',
        detail: 'اشرب ٨ أكواب يومياً لمدة أسبوع',
        people: 2130,
        points: 150,
        icon: NamatIcons.leaf,
        accent: NamatColors.nutrition,
        tint: NamatColors.nutritionSoft,
      ),
      (
        title: 'شهر بلا انقطاع',
        detail: 'نشاط واحد كل يوم لمدة ٣٠ يوم',
        people: 310,
        points: 900,
        icon: NamatIcons.journey,
        accent: NamatColors.products,
        tint: NamatColors.productsSoft,
      ),
    ];

    return Column(
      children: [
        for (final c in items)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.md),
            child: NamatCard(
              color: c.tint,
              elevated: false,
              onTap: () => namatNotConnected(context),
              child: Row(
                children: [
                  NamatIcon(c.icon, size: 30, color: c.accent),
                  const SizedBox(width: NamatSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.detail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              l.participants(context.n(c.people)),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l.rewardPoints(context.n(c.points)),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: c.accent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Challenges scored from the member's own habit log.
class _PersonalChallenges extends ConsumerWidget {
  const _PersonalChallenges();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final progress = ref.watch(challengeProgressProvider);
    final claimed = ref.watch(claimedProvider);

    return Column(
      children: [
        for (final c in PersonalChallenge.values)
          Padding(
            padding: const EdgeInsets.only(bottom: NamatSpace.sm),
            child: _ChallengeRow(
              challenge: c,
              done: progress[c] ?? 0,
              claimed: claimed.contains(c),
              onClaim: () {
                ref.read(claimedProvider.notifier).claim(c);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l.pointsEarned(
                        context.n(pointsFor[PointsReason.challenge] ?? 0),
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.challenge,
    required this.done,
    required this.claimed,
    required this.onClaim,
  });

  final PersonalChallenge challenge;
  final int done;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final complete = done >= challenge.target;
    final fraction = done / challenge.target;

    return NamatCard(
      padding: const EdgeInsets.all(NamatSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(_label(challenge, l), style: text.bodyMedium)),
              Text(
                l.challengeProgress(
                  context.n(done),
                  context.n(challenge.target),
                ),
                style: text.labelSmall?.copyWith(
                  color: complete ? NamatColors.accent : NamatColors.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: NamatSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
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
          // The claim is a tap, not an automatic award: a balance that changes
          // while the member is looking at another screen is a balance they
          // cannot connect to anything they did.
          if (complete) ...[
            const SizedBox(height: NamatSpace.md),
            if (claimed)
              Text(
                l.claimed,
                style: text.labelSmall?.copyWith(color: NamatColors.accent),
              )
            else
              FilledButton(
                onPressed: onClaim,
                child: Text(
                  l.claimReward(
                    context.n(pointsFor[PointsReason.challenge] ?? 0),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _label(PersonalChallenge c, L l) => switch (c) {
        PersonalChallenge.threeWorkouts => l.pcThreeWorkouts,
        PersonalChallenge.weekOfMeals => l.pcWeekOfMeals,
        PersonalChallenge.fiveDaysHydrated => l.pcFiveDaysHydrated,
        PersonalChallenge.sevenDayStreak => l.pcSevenDayStreak,
      };
}
