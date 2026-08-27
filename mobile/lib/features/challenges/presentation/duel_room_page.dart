import 'package:flutter/material.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;
import '../domain/duel.dart';

/// The live contest.
///
/// The scoreboard leads, the timeline explains it. Every entry in the timeline
/// is system-generated — this is a record of what happened, not a chat room,
/// and letting people type into it turns a scoreboard into an argument.
class DuelRoomPage extends StatefulWidget {
  const DuelRoomPage({super.key});

  @override
  State<DuelRoomPage> createState() => _DuelRoomPageState();
}

class _DuelRoomPageState extends State<DuelRoomPage> {
  int _mine = 8420;
  static const _theirs = 7950;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    final standing = DuelStanding(
      mine: DuelSide(name: 'خالد', score: _mine),
      theirs: const DuelSide(name: 'أحمد', score: _theirs),
    );

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/journey/challenges'),
          title: Text(l.metricSteps),
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
                  l.dayOfDuel(context.n(4), context.n(7)),
                  style: text.labelSmall,
                ),
                Text(l.timeLeft('٥ أيام'), style: text.labelSmall),
              ],
            ),
            const SizedBox(height: NamatSpace.md),
            _Scoreboard(standing: standing),
            const SizedBox(height: NamatSpace.xxl),
            Text(l.latestActivity, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            _Timeline(standing: standing),
          ]),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.fromLTRB(
            NamatSpace.gutter,
            NamatSpace.md,
            NamatSpace.gutter,
            NamatSpace.xxl,
          ),
          child: FilledButton(
            // Absolute, not a delta: a double tap or a retried request must
            // not inflate a score that has points riding on it.
            onPressed: () => setState(() => _mine += 500),
            child: Text(l.logToday),
          ),
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.standing});

  final DuelStanding standing;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    final events = <(String, Color)>[
      (l.eventProgress(standing.mine.name, context.n(3240)),
          NamatColors.inkSoft),
      (l.eventGoalMet(standing.theirs.name), NamatColors.accent),
      (l.eventTookLead(standing.mine.name), NamatColors.fitness),
      (l.eventAccepted(standing.theirs.name), NamatColors.inkSoft),
    ];

    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: events[i].$2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < events.length - 1)
                    Container(
                      width: 1.5,
                      height: 30,
                      color: NamatColors.line,
                    ),
                ],
              ),
              const SizedBox(width: NamatSpace.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: NamatSpace.lg),
                  child: Text(events[i].$1, style: text.bodySmall),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
