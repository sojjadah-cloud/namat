import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/features/challenges/domain/personal_challenges.dart';
import 'package:namat/features/journey/domain/habits.dart';
import 'package:namat/features/rewards/domain/points.dart';

/// Earning, and being able to spend what you earned.
///
/// The redeem buttons were permanently grey, and it was not one bug. Three of
/// the five ways to earn never fired at all — the screen listed them, and
/// nothing in the app called them — and the two that did paid 30 for a full
/// order-and-rate cycle against a 250-point reward. Nine complete cycles
/// before a single button lit up, which is indistinguishable from broken.

void main() {
  group('the earning rules are reachable', () {
    test('every reason the screen advertises is worth something', () {
      // A rule listed on the page and worth nothing is a lie on the page.
      for (final r in PointsReason.values) {
        if (r == PointsReason.redeemed) continue;
        expect(pointsFor[r], isNotNull, reason: r.name);
        expect(pointsFor[r], greaterThan(0), reason: r.name);
      }
    });

    test('the cheapest reward is within a fortnight of ordinary use', () {
      final cheapest =
          namatRewards.map((r) => r.cost).reduce((a, b) => a < b ? a : b);
      // Two weeks of logging a habit each day, and nothing else.
      final fromHabitsAlone = 14 * pointsFor[PointsReason.streak]!;
      expect(cheapest, lessThanOrEqualTo(fromHabitsAlone));
    });

    test('a week of habits plus two orders clears the first reward', () {
      final earned = 7 * pointsFor[PointsReason.streak]! +
          2 * pointsFor[PointsReason.order]! +
          2 * pointsFor[PointsReason.review]! +
          pointsFor[PointsReason.newPartner]!;
      final cheapest =
          namatRewards.map((r) => r.cost).reduce((a, b) => a < b ? a : b);
      expect(earned, greaterThanOrEqualTo(cheapest));
    });
  });

  group('awarding once', () {
    test('the same day cannot be earned twice', () {
      final p = PointsNotifier();
      expect(p.awardOnce(PointsReason.streak, detail: '2026-08-27'), isTrue);
      // Logging five habits on Tuesday is one Tuesday.
      expect(p.awardOnce(PointsReason.streak, detail: '2026-08-27'), isFalse);
      expect(PointsNotifier.balanceOf(p.state), pointsFor[PointsReason.streak]);
    });

    test('a different day is a different award', () {
      final p = PointsNotifier()
        ..awardOnce(PointsReason.streak, detail: '2026-08-27')
        ..awardOnce(PointsReason.streak, detail: '2026-08-28');
      expect(
        PointsNotifier.balanceOf(p.state),
        2 * pointsFor[PointsReason.streak]!,
      );
    });

    test('the same partner is only new once', () {
      final p = PointsNotifier();
      expect(
        p.awardOnce(PointsReason.newPartner, detail: 'Nourish Kitchen'),
        isTrue,
      );
      expect(
        p.awardOnce(PointsReason.newPartner, detail: 'Nourish Kitchen'),
        isFalse,
      );
    });
  });

  group('logging a habit earns the day', () {
    test('the first log of a day awards, the rest do not', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(habitsProvider.notifier).log(Habit.water);
      final afterFirst = c.read(pointsBalanceProvider);
      expect(afterFirst, pointsFor[PointsReason.streak]);

      c.read(habitsProvider.notifier).log(Habit.workout);
      c.read(habitsProvider.notifier).log(Habit.sleep);
      // Still one day.
      expect(c.read(pointsBalanceProvider), afterFirst);
    });

    test('undoing the only log does not award a second time on redo', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final habits = c.read(habitsProvider.notifier);

      habits.log(Habit.workout);
      habits.log(Habit.workout); // undo
      habits.log(Habit.workout); // redo

      // The day was already earned; re-opening it is not a new day.
      expect(c.read(pointsBalanceProvider), pointsFor[PointsReason.streak]);
    });
  });

  group('personal challenges', () {
    test('progress counts days a habit was met', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final habits = c.read(habitsProvider.notifier);
      final now = DateTime.now();

      for (var i = 0; i < 3; i++) {
        habits.log(Habit.workout, when: now.subtract(Duration(days: i)));
      }

      expect(
        c.read(challengeProgressProvider)[PersonalChallenge.threeWorkouts],
        3,
      );
    });

    test('a finished challenge becomes claimable', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final habits = c.read(habitsProvider.notifier);
      final now = DateTime.now();

      for (var i = 0; i < 3; i++) {
        habits.log(Habit.workout, when: now.subtract(Duration(days: i)));
      }

      expect(
        c.read(claimableProvider),
        contains(PersonalChallenge.threeWorkouts),
      );
    });

    test('claiming pays out once and stops being claimable', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final habits = c.read(habitsProvider.notifier);
      final now = DateTime.now();

      for (var i = 0; i < 3; i++) {
        habits.log(Habit.workout, when: now.subtract(Duration(days: i)));
      }
      final before = c.read(pointsBalanceProvider);

      expect(
        c.read(claimedProvider.notifier).claim(PersonalChallenge.threeWorkouts),
        isTrue,
      );
      expect(
        c.read(pointsBalanceProvider),
        before + pointsFor[PointsReason.challenge]!,
      );

      // A second tap pays nothing.
      expect(
        c.read(claimedProvider.notifier).claim(PersonalChallenge.threeWorkouts),
        isFalse,
      );
      expect(
        c.read(claimableProvider),
        isNot(contains(PersonalChallenge.threeWorkouts)),
      );
    });

    test('an unfinished challenge is not claimable', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(habitsProvider.notifier).log(Habit.workout);
      expect(
        c.read(claimableProvider),
        isNot(contains(PersonalChallenge.threeWorkouts)),
      );
    });
  });

  group('redeeming', () {
    test('works the moment the balance covers a reward', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final points = c.read(pointsProvider.notifier);
      final cheapest = namatRewards.reduce((a, b) => a.cost < b.cost ? a : b);

      // Earn past it the way a member would: fortnight of habits.
      final now = DateTime.now();
      for (var i = 0; i < 14; i++) {
        points.awardOnce(
          PointsReason.streak,
          detail: HabitDay.keyFor(now.subtract(Duration(days: i))),
        );
      }
      expect(c.read(pointsBalanceProvider), greaterThanOrEqualTo(cheapest.cost));

      expect(points.redeem(cheapest.cost, detail: cheapest.id), isTrue);
      expect(
        c.read(pointsBalanceProvider),
        14 * pointsFor[PointsReason.streak]! - cheapest.cost,
      );
    });

    test('a second redemption beyond the balance is refused', () {
      final p = PointsNotifier()..award(PointsReason.challenge);
      final cheapest = namatRewards.reduce((a, b) => a.cost < b.cost ? a : b);
      expect(p.redeem(cheapest.cost), isFalse);
      expect(PointsNotifier.balanceOf(p.state), greaterThanOrEqualTo(0));
    });
  });
}
