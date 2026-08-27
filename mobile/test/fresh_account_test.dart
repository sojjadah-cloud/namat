import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/challenges/domain/duel.dart';
import 'package:namat/features/challenges/domain/duels_provider.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/favorites/domain/favorites.dart';
import 'package:namat/features/home/domain/home_feed.dart';
import 'package:namat/features/journey/domain/habits.dart';
import 'package:namat/features/membership/domain/membership.dart';
import 'package:namat/features/rewards/domain/points.dart';
import 'package:namat/features/settings/domain/preferences.dart';
import 'package:namat/main.dart';

/// A brand-new account owns nothing.
///
/// This is the test that keeps the fixtures out. Sample data is harmless on a
/// screen nobody reads and corrosive on the first screen a new member sees:
/// they cannot tell which parts of the app are about them, so none of it is
/// trusted. The app used to open onto five bookings, a duel against a stranger
/// and a week that was 85% done — none of which the member had any part in.

Future<ProviderContainer> _pump(WidgetTester tester, String location) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(routerProvider).go(location);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const NamatApp()),
  );
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pump();
  return container;
}

void main() {
  test('every member-owned list starts empty', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(cartProvider), isEmpty);
    expect(c.read(ordersProvider), isEmpty);
    expect(c.read(duelsProvider), isEmpty);
    expect(c.read(favouritesProvider), isEmpty);
    expect(c.read(pointsProvider), isEmpty);
    expect(c.read(habitsProvider), isEmpty);
    expect(c.read(membershipProvider), isNull);
  });

  test('every member-owned number starts at zero', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(pointsBalanceProvider), 0);
    expect(c.read(cartCountProvider), 0);
    expect(c.read(favouritesCountProvider), 0);
    expect(c.read(streakProvider), 0);
    // The ring used to read 85 for everyone, including someone who had just
    // installed the app.
    expect(c.read(weekProgressProvider), 0);
    expect(c.read(potentialSavingProvider), 0);
  });

  test('the week has seven days and all of them are empty', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final week = c.read(weekProvider);
    expect(week.length, 7);
    for (final day in week) {
      expect(day.completion, 0);
    }
  });

  test('there is no current duel to open', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(currentDuelProvider), isNull);
  });

  testWidgets('bookings opens onto nothing, not onto sample bookings',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await _pump(tester, '/bookings');
    // Five fixture bookings used to live here, including a reformer class the
    // member had never booked.
    expect(find.text('حصة ريفورمر'), findsNothing);
    expect(find.text('استشارة تغذية'), findsNothing);
  });

  testWidgets('challenges opens onto an invitation, not a fixture duel',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await _pump(tester, '/journey/challenges');
    expect(find.text('ما عندك تحديات حالياً'), findsOneWidget);
    // The old fixture opponent.
    expect(find.text('أحمد'), findsNothing);
  });

  group('habits', () {
    test('a tap logs, and a second tap undoes it', () {
      final h = HabitsNotifier()..log(Habit.workout);
      expect(h.dayOf(DateTime.now()).isMet(Habit.workout), isTrue);
      // The commonest correction is "I tapped that by mistake".
      h.log(Habit.workout);
      expect(h.dayOf(DateTime.now()).isMet(Habit.workout), isFalse);
    });

    test('water counts up and wraps at the target', () {
      final h = HabitsNotifier();
      for (var i = 0; i < Habit.water.target; i++) {
        h.log(Habit.water);
      }
      expect(h.dayOf(DateTime.now()).of(Habit.water), Habit.water.target);
      // One more resets rather than overcounting, which is the only way to
      // correct an over-tap without a separate control.
      h.log(Habit.water);
      expect(h.dayOf(DateTime.now()).of(Habit.water), 0);
    });

    test('completion is the average across every habit', () {
      final h = HabitsNotifier()..log(Habit.workout);
      final day = h.dayOf(DateTime.now());
      expect(day.completion, closeTo(1 / Habit.values.length, 0.001));
    });

    test('a day key does not shift near midnight', () {
      // Built from the date parts rather than from a truncated instant, which
      // is where a log quietly moves to the previous day.
      final late = DateTime(2026, 8, 27, 23, 59);
      expect(HabitDay.keyFor(late), '2026-08-27');
      expect(HabitDay.keyFor(DateTime(2026, 8, 27, 0, 1)), '2026-08-27');
    });

    test('a streak counts consecutive days, not perfect ones', () {
      final h = HabitsNotifier();
      final now = DateTime.now();
      // Three days running, none of them complete. A streak that breaks over
      // one missed glass of water punishes people for a bad Tuesday.
      h.log(Habit.water, when: now);
      h.log(Habit.sleep, when: now.subtract(const Duration(days: 1)));
      h.log(Habit.steps, when: now.subtract(const Duration(days: 2)));
      expect(h.streak, 3);
    });

    test('a gap ends the streak', () {
      final h = HabitsNotifier();
      final now = DateTime.now();
      h.log(Habit.water, when: now);
      h.log(Habit.water, when: now.subtract(const Duration(days: 3)));
      expect(h.streak, 1);
    });

    test('not having logged today does not break yesterday-onwards', () {
      final h = HabitsNotifier();
      final now = DateTime.now();
      h.log(Habit.water, when: now.subtract(const Duration(days: 1)));
      h.log(Habit.water, when: now.subtract(const Duration(days: 2)));
      // Still running; simply not extended yet.
      expect(h.streak, 2);
    });
  });

  group('membership', () {
    test('starting one sets the package', () {
      final m = MembershipNotifier()..start('balance');
      expect(m.state!.packageId, 'balance');
      expect(m.state!.package!.grants[Allowance.meals], 12);
    });

    test('a member can move between packages', () {
      final m = MembershipNotifier()..start('active');
      m.start('complete');
      expect(m.state!.packageId, 'complete');
    });

    test('pausing keeps the package; cancelling removes it', () {
      final m = MembershipNotifier()..start('balance');
      m.pause();
      expect(m.state!.paused, isTrue);
      expect(m.state!.packageId, 'balance');

      m.resume();
      expect(m.state!.paused, isFalse);

      // One call, no maze.
      m.cancel();
      expect(m.state, isNull);
    });

    test('allowances left never go negative', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(membershipProvider.notifier).start('active');

      final left = c.read(allowanceLeftProvider);
      for (final entry in left.entries) {
        expect(entry.value, greaterThanOrEqualTo(0), reason: '${entry.key}');
      }
    });

    test('an allowance covers only the kinds it is for', () {
      expect(Allowance.meals.covers(OfferingKind.dish), isTrue);
      expect(Allowance.meals.covers(OfferingKind.session), isFalse);
      expect(Allowance.sessions.covers(OfferingKind.session), isTrue);
      expect(
        Allowance.consultations.covers(OfferingKind.consultation),
        isTrue,
      );
    });

    test('a spent allowance stops covering', () {
      // The check the cart needs: telling a member something is free and then
      // charging for it is the worst outcome in the whole flow.
      expect(
        allowanceCovers({Allowance.meals: 0}, OfferingKind.dish),
        isFalse,
      );
      expect(
        allowanceCovers({Allowance.meals: 1}, OfferingKind.dish),
        isTrue,
      );
    });
  });

  group('preferences', () {
    test('marketing is off by default and everything else is on', () {
      const p = Preferences();
      expect(p.isOn(NotificationChannel.offers), isFalse);
      expect(p.isOn(NotificationChannel.bookings), isTrue);
      expect(p.isOn(NotificationChannel.journey), isTrue);
    });

    test('location is off until it is granted', () {
      // The app works without it, so asking on first launch would be asking
      // for something not yet needed.
      expect(const Preferences().useLocation, isFalse);
    });

    test('a channel can be turned off and back on', () {
      final n = PreferencesNotifier()
        ..setChannel(NotificationChannel.bookings, false);
      expect(n.state.isOn(NotificationChannel.bookings), isFalse);
      n.setChannel(NotificationChannel.bookings, true);
      expect(n.state.isOn(NotificationChannel.bookings), isTrue);
    });

    test('choosing a language sets it, and clearing follows the device', () {
      final n = PreferencesNotifier()..setLocale(const Locale('en'));
      expect(n.state.locale, const Locale('en'));
      n.setLocale(null);
      expect(n.state.locale, isNull);
    });
  });

  test('a sent challenge starts at nil–nil and unaccepted', () {
    final d = DuelsNotifier()
      ..send(
        opponent: 'ahmed',
        metric: DuelMetric.steps,
        target: 10000,
        days: 7,
      );
    final duel = d.state.single;
    // A duel that opens with a score is a duel the member did not take part
    // in, and progress before acceptance scores someone who has not opted in.
    expect(duel.myScore, 0);
    expect(duel.theirScore, 0);
    expect(duel.accepted, isFalse);
  });
}
