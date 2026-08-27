import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../journey/domain/habits.dart';
import '../../rewards/domain/points.dart';

/// Challenges a member can finish on their own.
///
/// These exist because the one-on-one duel cannot be honest without a server.
/// A duel needs the other person's progress, and there is nowhere to get it —
/// so a duel screen showing an opponent on 7,950 steps is inventing a number
/// about a real person. A personal challenge is scored entirely from the
/// member's own habit log, which the app actually has, so it is the one kind
/// that can be true today.
///
/// It is also the kind the product needs most. Competing with a friend is a
/// way to start; finishing seven days in a row is the thing NAMAT claims to
/// help with.

enum PersonalChallenge {
  /// Log a workout on three separate days.
  threeWorkouts,

  /// Log a healthy meal every day for a week.
  weekOfMeals,

  /// Hit the water target on five days.
  fiveDaysHydrated,

  /// Log anything at all, seven days running.
  sevenDayStreak;

  Habit get habit => switch (this) {
        PersonalChallenge.threeWorkouts => Habit.workout,
        PersonalChallenge.weekOfMeals => Habit.healthyMeal,
        PersonalChallenge.fiveDaysHydrated => Habit.water,
        PersonalChallenge.sevenDayStreak => Habit.steps,
      };

  int get target => switch (this) {
        PersonalChallenge.threeWorkouts => 3,
        PersonalChallenge.weekOfMeals => 7,
        PersonalChallenge.fiveDaysHydrated => 5,
        PersonalChallenge.sevenDayStreak => 7,
      };

  /// The streak one counts consecutive days of anything; the rest count days
  /// where one particular habit was met, in any order.
  bool get isStreak => this == PersonalChallenge.sevenDayStreak;
}

/// How far along one challenge is, out of its target.
///
/// Counted over the last fourteen days rather than for all time: a challenge
/// that can be finished by three workouts spread across a year is not a
/// challenge, and one that resets at midnight on a fixed date punishes anyone
/// who joins on a Thursday.
int progressOf(
  PersonalChallenge challenge,
  Map<String, HabitDay> log,
  int streak,
) {
  if (challenge.isStreak) return streak.clamp(0, challenge.target);

  final now = DateTime.now();
  var met = 0;
  for (var i = 0; i < 14; i++) {
    final day = log[HabitDay.keyFor(now.subtract(Duration(days: i)))];
    if (day != null && day.isMet(challenge.habit)) met++;
  }
  return met.clamp(0, challenge.target);
}

final challengeProgressProvider =
    Provider<Map<PersonalChallenge, int>>((ref) {
  final log = ref.watch(habitsProvider);
  final streak = ref.watch(streakProvider);
  return {
    for (final c in PersonalChallenge.values)
      c: progressOf(c, log, streak),
  };
});

/// Which ones are finished but not yet claimed.
final claimableProvider = Provider<List<PersonalChallenge>>((ref) {
  final progress = ref.watch(challengeProgressProvider);
  final claimed = ref.watch(claimedProvider);
  return [
    for (final c in PersonalChallenge.values)
      if (progress[c] == c.target && !claimed.contains(c)) c,
  ];
});

class ClaimedNotifier extends StateNotifier<Set<PersonalChallenge>> {
  ClaimedNotifier(this._points) : super(const {});

  final PointsNotifier _points;

  /// Claiming is a tap, not an automatic award.
  ///
  /// The member should see the points arrive because they did something, and
  /// a balance that changes while they are looking at another screen is a
  /// balance they cannot connect to anything.
  bool claim(PersonalChallenge challenge) {
    if (state.contains(challenge)) return false;
    state = {...state, challenge};
    _points.awardOnce(PointsReason.challenge, detail: challenge.name);
    return true;
  }
}

final claimedProvider =
    StateNotifierProvider<ClaimedNotifier, Set<PersonalChallenge>>(
  (ref) => ClaimedNotifier(ref.read(pointsProvider.notifier)),
);
