import '../../../l10n/app_localizations.dart';

/// What a duel measures.
///
/// Volume metrics total everything logged, because beating the daily target is
/// the point of competing. STREAK counts whole days only — going twice as far
/// on Tuesday does not buy Wednesday off, and not breaking is the whole skill
/// being tested.
enum DuelMetric {
  steps(defaultTarget: 10000),
  workouts(defaultTarget: 1),
  water(defaultTarget: 8),
  streak(defaultTarget: 1);

  const DuelMetric({required this.defaultTarget});

  final int defaultTarget;

  bool get countsWholeDaysOnly => this == DuelMetric.streak;

  String title(L l) => switch (this) {
        DuelMetric.steps => l.metricSteps,
        DuelMetric.workouts => l.metricWorkouts,
        DuelMetric.water => l.metricWater,
        DuelMetric.streak => l.metricStreak,
      };

  String subtitle(L l) => switch (this) {
        DuelMetric.steps => l.metricStepsSub,
        DuelMetric.workouts => l.metricWorkoutsSub,
        DuelMetric.water => l.metricWaterSub,
        DuelMetric.streak => l.metricStreakSub,
      };
}

/// A person you can compete with.
///
/// Only what is public. A challenge profile never carries a phone number, an
/// email, a location or anything about health — those exist on the account and
/// have no business on a screen another member can open.
class Opponent {
  const Opponent({
    required this.name,
    required this.username,
    required this.level,
    required this.wins,
    required this.streak,
    this.acceptsChallenges = true,
  });

  final String name;
  final String username;
  final int level;
  final int wins;
  final int streak;

  /// False when they have closed the door. The button is hidden, and a real
  /// server would refuse the request too — a hidden button stops only the
  /// polite path.
  final bool acceptsChallenges;
}

/// One side's running total.
class DuelSide {
  const DuelSide({required this.name, required this.score});
  final String name;
  final int score;
}

/// Where a duel stands.
class DuelStanding {
  const DuelStanding({required this.mine, required this.theirs});

  final DuelSide mine;
  final DuelSide theirs;

  int get margin => mine.score - theirs.score;

  /// Null while level. A tie has no leader, and inventing one is how a
  /// "took the lead" notification ends up firing at nobody.
  DuelSide? get leader => switch (margin) {
        0 => null,
        > 0 => mine,
        _ => theirs,
      };

  bool get iAmLeading => leader == mine;

  /// Share of the combined total, for the split bar. Falls back to level when
  /// neither side has logged anything, rather than dividing by zero.
  double get share {
    final total = mine.score + theirs.score;
    return total == 0 ? 0.5 : mine.score / total;
  }
}
