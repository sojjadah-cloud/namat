import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;
import '../domain/duel.dart';
import '../domain/duels_provider.dart';

/// The live contest.
///
/// The scoreboard leads, the timeline explains it. Every entry in the timeline
/// is system-generated — this is a record of what happened, not a chat room,
/// and letting people type into it turns a scoreboard into an argument.
/// One duel.
///
/// The opponent's score is not shown until they accept, because there is
/// nowhere to get it from. A scoreboard reading أحمد · 7,950 was a number
/// invented about a real person — the single least defensible kind of
/// placeholder in the app, and the reason a duel could never actually
/// complete or pay out.
class DuelRoomPage extends ConsumerWidget {
  const DuelRoomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final duel = ref.watch(currentDuelProvider);

    if (duel == null) {
      return NamatBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: const NamatBack(fallback: '/journey/challenges'),
          ),
          body: NamatEmptyState(
            title: l.noChallenges,
            action: FilledButton(
              onPressed: () => context.go('/journey/challenges/find'),
              child: Text(l.challengeSomeone),
            ),
          ),
        ),
      );
    }

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/journey/challenges'),
          title: Text(l.challenge),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            0,
            NamatSpace.gutter,
            140,
          ),
          children: revealAll([
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.dayOfDuel(
                    context.n(duel.dayOf),
                    context.n(duel.days),
                  ),
                  style: text.labelSmall,
                ),
                Text(
                  l.days(context.n(duel.endsAt.difference(DateTime.now()).inDays)),
                  style: text.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.xl),
            if (!duel.accepted)
              NamatCard(
                padding: const EdgeInsets.all(NamatSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.duelPending(duel.opponent),
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: NamatSpace.xs),
                    // Said plainly rather than filled in with a number.
                    Text(l.duelPendingBody, style: text.bodySmall),
                    const SizedBox(height: NamatSpace.xl),
                    Text(l.yourProgress, style: text.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${context.n(duel.myScore)} / '
                      '${context.n(duel.target)}',
                      style: text.displayMedium,
                    ),
                  ],
                ),
              )
            else
              _Scoreboard(
                standing: DuelStanding(
                  mine: DuelSide(name: '', score: duel.myScore),
                  theirs: DuelSide(
                    name: duel.opponent,
                    score: duel.theirScore,
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.standing});

  final DuelStanding standing;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final leader = standing.leader;

    return NamatCard(
      organic: true,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Side(side: standing.mine, leading: standing.iAmLeading),
              ),
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
                child: _Side(
                  side: standing.theirs,
                  leading: leader == standing.theirs,
                ),
              ),
            ],
          ),
          const SizedBox(height: NamatSpace.xl),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: standing.share),
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
          // A tie is stated as a tie. Naming a leader when the scores are
          // level is how a "took the lead" line ends up describing nobody.
          Text(
            leader == null
                ? l.drawSoFar
                : standing.iAmLeading
                    ? l.youLeadBy(context.n(standing.margin.abs()))
                    : l.behindBy(context.n(standing.margin.abs())),
            style: text.labelMedium?.copyWith(
              color: leader == null
                  ? NamatColors.inkSoft
                  : standing.iAmLeading
                      ? NamatColors.accent
                      : NamatColors.fitness,
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.side, required this.leading});

  final DuelSide side;
  final bool leading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // A soft ring marks the leader — enough to notice, not enough to
            // gloat about.
            AnimatedContainer(
              duration: NamatMotion.base,
              width: leading ? 66 : 54,
              height: leading ? 66 : 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: leading
                    ? NamatColors.accent.withOpacity(0.14)
                    : Colors.transparent,
              ),
            ),
            NamatAvatar(name: side.name, size: 54),
          ],
        ),
        const SizedBox(height: NamatSpace.sm),
        Text(side.name, style: text.labelMedium),
        const SizedBox(height: 2),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: side.score),
          duration: NamatMotion.reveal,
          curve: NamatMotion.curve,
          builder: (context, v, _) =>
              Text(context.n(v), style: text.titleLarge),
        ),
      ],
    );
  }
}

