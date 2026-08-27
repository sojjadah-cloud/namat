import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/numbers.dart';
import '../../../core/theme/namat_colors.dart';
import '../../../core/widgets/namat_icon.dart';
import '../../../core/widgets/namat_motion.dart';
import '../../../core/widgets/namat_nav.dart';
import '../../../core/widgets/namat_scaffold.dart';
import '../../../l10n/app_localizations.dart';
import '../../home/presentation/home_page.dart' show NamatAvatar;
import '../domain/duel.dart';
import '../domain/duels_provider.dart';

/// Composing a challenge: what, and for how long.
///
/// Both choices are on one screen rather than a wizard. There are four metrics
/// and four durations; splitting that across two steps adds a transition and
/// removes the ability to see the whole decision at once.
class CreateDuelPage extends ConsumerStatefulWidget {
  const CreateDuelPage({super.key, required this.username});

  final String username;

  @override
  ConsumerState<CreateDuelPage> createState() => _CreateDuelPageState();
}

class _CreateDuelPageState extends ConsumerState<CreateDuelPage> {
  DuelMetric _metric = DuelMetric.steps;
  int _days = 7;

  /// A duel that runs for a season is a resolution, not a contest. Fourteen
  /// days is the ceiling because that is roughly how long two people will keep
  /// checking a scoreboard.
  static const _durations = [1, 3, 7, 14];

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;
    final name = widget.username;

    return NamatBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const NamatBack(fallback: '/journey/challenges/find'),
          title: Text(l.chooseChallenge),
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
              children: [
                NamatAvatar(name: name, size: 44),
                const SizedBox(width: NamatSpace.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.opponent, style: text.labelSmall),
                    Text(handle(name), style: text.titleMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: NamatSpace.xl),
            for (final m in DuelMetric.values)
              Padding(
                padding: const EdgeInsets.only(bottom: NamatSpace.md),
                child: _MetricCard(
                  metric: m,
                  selected: _metric == m,
                  onTap: () => setState(() => _metric = m),
                ),
              ),
            const SizedBox(height: NamatSpace.lg),
            Text(l.duration, style: text.labelMedium),
            const SizedBox(height: NamatSpace.md),
            Row(
              children: [
                for (final d in _durations) ...[
                  Expanded(
                    child: Pressable(
                      onTap: () => setState(() => _days = d),
                      child: AnimatedContainer(
                        duration: NamatMotion.fast,
                        curve: NamatMotion.enter,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _days == d
                              ? NamatColors.deep
                              : NamatColors.surface,
                          borderRadius:
                              BorderRadius.circular(NamatRadius.xs),
                          border: Border.all(
                            color: _days == d
                                ? NamatColors.deep
                                : NamatColors.line,
                          ),
                        ),
                        child: Text(
                          d == 1 ? l.oneDay : l.days(context.n(d)),
                          textAlign: TextAlign.center,
                          style: text.labelMedium?.copyWith(
                            color: _days == d
                                ? Colors.white
                                : NamatColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (d != _durations.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: NamatSpace.xxl),
            NamatCard(
              color: NamatColors.warmSoft,
              elevated: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.readyToChallenge, style: text.titleMedium),
                  const SizedBox(height: NamatSpace.sm),
                  Text(
                    '${_metric.title(l)} · ${_days == 1 ? l.oneDay : l.days(context.n(_days))}',
                    style: text.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  // Nothing counts until they accept: a slow reply must not
                  // silently eat days off their side of the contest.
                  Text(l.startsAfterAccept(name), style: text.bodySmall),
                ],
              ),
            ),
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
            onPressed: () {
              // The challenge is recorded here, not on the confirmation
              // screen: a member who backs out of that screen would otherwise
              // have sent nothing while being told they had.
              ref.read(duelsProvider.notifier).send(
                    opponent: name,
                    metric: _metric,
                    target: _metric.defaultTarget,
                    days: _days,
                  );
              context.go('/journey/challenges/sent/$name');
            },
            child: Text(l.sendChallenge),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.selected,
    required this.onTap,
  });

  final DuelMetric metric;
  final bool selected;
  final VoidCallback onTap;

  static const _icons = {
    DuelMetric.steps: NamatIcons.fitness,
    DuelMetric.workouts: NamatIcons.challenge,
    DuelMetric.water: NamatIcons.leaf,
    DuelMetric.streak: NamatIcons.journey,
  };

  @override
  Widget build(BuildContext context) {
    final l = L.of(context)!;
    final text = Theme.of(context).textTheme;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: NamatMotion.fast,
        curve: NamatMotion.enter,
        padding: const EdgeInsets.all(NamatSpace.lg),
        decoration: BoxDecoration(
          color: selected ? NamatColors.greenSoft : NamatColors.surface,
          borderRadius: BorderRadius.circular(NamatRadius.lg),
          border: Border.all(
            color: selected ? NamatColors.deep : NamatColors.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            NamatIcon(
              _icons[metric]!,
              size: 26,
              color: selected ? NamatColors.deep : NamatColors.inkSoft,
            ),
            const SizedBox(width: NamatSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metric.title(l), style: text.titleMedium),
                  Text(metric.subtitle(l), style: text.bodySmall),
                ],
              ),
            ),
            AnimatedScale(
              scale: selected ? 1 : 0,
              duration: NamatMotion.fast,
              curve: NamatMotion.enter,
              child: const Icon(
                Icons.check_circle,
                color: NamatColors.deep,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
