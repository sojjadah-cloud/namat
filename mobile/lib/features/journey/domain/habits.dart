import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rewards/domain/points.dart';

/// Lightweight habit tracking.
///
/// Deliberately small. NAMAT is not trying to become a medical tracker, and a
/// screen that asks for macros, sleep stages and resting heart rate every day
/// gets abandoned in a week — which takes the rest of the journey with it.
/// Five habits, one tap each, and the day's row is complete.
///
/// Nothing here is a health claim. The water target is a convention, not a
/// prescription, and the app never tells anyone what their body needs.

enum Habit {
  water,
  steps,
  workout,
  healthyMeal,
  sleep;

  /// What a full day looks like.
  ///
  /// A count for water, a yes/no for the rest. Steps come from a phone's
  /// pedometer eventually; until that is wired the member logs the day rather
  /// than a number, because a step count typed by hand is a number nobody
  /// trusts and everybody rounds up.
  int get target => switch (this) {
        Habit.water => 8,
        _ => 1,
      };

  bool get isCounted => this == Habit.water;
}

/// One day's habits, keyed by the day rather than by a timestamp.
///
/// Oman is UTC+4 with no daylight saving, so a local calendar day is
/// unambiguous — but the key is still built from the date parts rather than
/// from a truncated instant, because a truncation is the kind of thing that
/// quietly moves a log to the previous day for anyone logging near midnight.
class HabitDay {
  const HabitDay({required this.date, this.counts = const {}});

  final DateTime date;
  final Map<Habit, int> counts;

  int of(Habit h) => counts[h] ?? 0;

  bool isMet(Habit h) => of(h) >= h.target;

  /// How much of the day is done, as a fraction.
  double get completion {
    var done = 0.0;
    for (final h in Habit.values) {
      done += (of(h) / h.target).clamp(0.0, 1.0);
    }
    return done / Habit.values.length;
  }

  static String keyFor(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String get key => keyFor(date);
}

class HabitsNotifier extends StateNotifier<Map<String, HabitDay>> {
  HabitsNotifier([this._onDayOpened]) : super(const {});

  /// Called the first time anything is logged on a given day, with that day's
  /// key. The points rule lives with the points; the habits only report that
  /// a day has started, which is the fact they own.
  final void Function(String dayKey)? _onDayOpened;

  HabitDay dayOf(DateTime when) =>
      state[HabitDay.keyFor(when)] ?? HabitDay(date: when);

  /// Adds one to a counted habit, or toggles a yes/no one.
  ///
  /// Toggling rather than only incrementing matters: the commonest correction
  /// is "I tapped that by mistake", and a tracker with no way to undo is a
  /// tracker people stop trusting.
  void log(Habit habit, {DateTime? when}) {
    final day = when ?? DateTime.now();
    final key = HabitDay.keyFor(day);
    final existing = state[key] ?? HabitDay(date: day);
    final current = existing.of(habit);

    final next = habit.isCounted
        ? (current >= habit.target ? 0 : current + 1)
        : (current > 0 ? 0 : 1);

    // Was this day blank before the tap? Undoing a log does not re-open the
    // day, and a second habit on the same day is not a second day.
    final opening =
        next > 0 && existing.counts.values.every((v) => v == 0);

    state = {
      ...state,
      key: HabitDay(
        date: existing.date,
        counts: {...existing.counts, habit: next},
      ),
    };

    if (opening) _onDayOpened?.call(key);
  }

  /// Consecutive days ending today with anything logged at all.
  ///
  /// "Anything" rather than "everything" on purpose. A streak that breaks the
  /// first time someone misses one glass of water is a streak that punishes
  /// people for a bad Tuesday, and the behaviour worth rewarding is turning up
  /// at all.
  int get streak {
    var days = 0;
    var cursor = DateTime.now();
    while (true) {
      final day = state[HabitDay.keyFor(cursor)];
      final logged = day != null && day.counts.values.any((v) => v > 0);
      if (!logged) {
        // Today not yet logged does not break a streak that is still running;
        // it just has not been extended.
        if (days == 0 && _isToday(cursor)) {
          cursor = cursor.subtract(const Duration(days: 1));
          continue;
        }
        return days;
      }
      days++;
      cursor = cursor.subtract(const Duration(days: 1));
      if (days > 400) return days;
    }
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, Map<String, HabitDay>>(
  (ref) => HabitsNotifier(
    // Once per day, keyed on the day, so logging five habits on Tuesday earns
    // Tuesday once.
    (dayKey) => ref
        .read(pointsProvider.notifier)
        .awardOnce(PointsReason.streak, detail: dayKey),
  ),
);

final todayProvider = Provider<HabitDay>((ref) {
  ref.watch(habitsProvider);
  return ref.read(habitsProvider.notifier).dayOf(DateTime.now());
});

final streakProvider = Provider<int>((ref) {
  ref.watch(habitsProvider);
  return ref.read(habitsProvider.notifier).streak;
});

/// The last seven days, oldest first, for the timeline.
final weekProvider = Provider<List<HabitDay>>((ref) {
  ref.watch(habitsProvider);
  final notifier = ref.read(habitsProvider.notifier);
  final now = DateTime.now();
  return [
    for (var i = 6; i >= 0; i--)
      notifier.dayOf(now.subtract(Duration(days: i))),
  ];
});
