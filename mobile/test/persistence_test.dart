import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/data/store.dart';
import 'package:namat/features/account/domain/session.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/favorites/domain/favorites.dart';
import 'package:namat/features/journey/domain/habits.dart';
import 'package:namat/features/membership/domain/membership.dart';
import 'package:namat/features/rewards/domain/points.dart';
import 'package:namat/features/settings/domain/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State survives a relaunch.
///
/// Everything the member owned lived in memory only, and `shared_preferences`
/// had been a dependency since the first commit without ever being used. On
/// the web that means a page reload wipes the account — and pasting a URL into
/// the address bar is a reload. Choosing a package and then opening the app
/// again showed no package: not a fault in the membership, a fault in it never
/// having been written down.

/// A container backed by a real store, as the app has.
Future<ProviderContainer> _withStore(SharedPreferences prefs) async {
  final container = ProviderContainer(
    overrides: [storeProvider.overrideWithValue(NamatStore(prefs))],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a chosen package is still there next launch', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(membershipProvider.notifier).start('balance');
    expect(first.read(membershipProvider)!.packageId, 'balance');

    // A second container is a second launch: same store, nothing shared in
    // memory.
    final second = await _withStore(prefs);
    expect(second.read(membershipProvider)?.packageId, 'balance');
  });

  test('pausing survives too, and cancelling really removes it', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(membershipProvider.notifier)
      ..start('active')
      ..pause();

    var next = await _withStore(prefs);
    expect(next.read(membershipProvider)!.paused, isTrue);

    next.read(membershipProvider.notifier).cancel();
    next = await _withStore(prefs);
    expect(next.read(membershipProvider), isNull);
  });

  test('points and their ledger survive', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(pointsProvider.notifier)
      ..award(PointsReason.order, detail: 'NM-ABCDE')
      ..award(PointsReason.review, detail: 'NM-ABCDE');
    final balance = first.read(pointsBalanceProvider);

    final second = await _withStore(prefs);
    expect(second.read(pointsBalanceProvider), balance);
    // The ledger, not just the total: a balance without its reasons is a
    // number a member cannot check.
    expect(second.read(pointsProvider).length, 2);
    expect(second.read(pointsProvider).first.detail, 'NM-ABCDE');
  });

  test('an award that already happened is not repeated after a relaunch',
      () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    expect(
      first
          .read(pointsProvider.notifier)
          .awardOnce(PointsReason.streak, detail: '2026-08-27'),
      isTrue,
    );

    // The whole point of persisting the ledger: yesterday cannot be earned
    // twice by closing the app.
    final second = await _withStore(prefs);
    expect(
      second
          .read(pointsProvider.notifier)
          .awardOnce(PointsReason.streak, detail: '2026-08-27'),
      isFalse,
    );
  });

  test('habits survive, and so does the streak they imply', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final first = await _withStore(prefs);
    final habits = first.read(habitsProvider.notifier);
    habits.log(Habit.water, when: now);
    habits.log(Habit.workout, when: now.subtract(const Duration(days: 1)));

    final second = await _withStore(prefs);
    expect(second.read(streakProvider), 2);
    expect(second.read(todayProvider).of(Habit.water), 1);
  });

  test('the cart survives with its prices intact', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first
        .read(cartProvider.notifier)
        .add(Catalogue.offeringById('hl-grilled-quinoa')!, quantity: 2);
    final total = first.read(cartTotalsProvider).subtotal;

    final second = await _withStore(prefs);
    expect(second.read(cartProvider).single.quantity, 2);
    // A line that comes back cheaper than the member agreed to is the worst
    // possible outcome of a serialisation bug.
    expect(second.read(cartTotalsProvider).subtotal, total);
  });

  test('saved things survive', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(favouritesProvider.notifier)
      ..toggle(FavouriteKind.partner, 'namat-move')
      ..toggle(FavouriteKind.offering, 'nm-yoga');

    final second = await _withStore(prefs);
    expect(second.read(favouritesCountProvider), 2);
    expect(
      second.read(favouritesProvider.notifier).contains(
            FavouriteKind.partner,
            'namat-move',
          ),
      isTrue,
    );
  });

  test('the session and the chosen language survive', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(sessionProvider.notifier).signIn(name: 'سارة');
    first.read(preferencesProvider.notifier).setLocale(const Locale('en'));

    final second = await _withStore(prefs);
    expect(second.read(sessionProvider).isMember, isTrue);
    expect(second.read(sessionProvider).name, 'سارة');
    expect(second.read(preferencesProvider).locale, const Locale('en'));
  });

  test('signing out clears everything, not only the session', () async {
    final prefs = await SharedPreferences.getInstance();

    final first = await _withStore(prefs);
    first.read(sessionProvider.notifier).signIn(name: 'سارة');
    first.read(membershipProvider.notifier).start('balance');
    first.read(pointsProvider.notifier).award(PointsReason.order);
    first.read(favouritesProvider.notifier).toggle(
          FavouriteKind.partner,
          'namat-move',
        );

    first.read(sessionProvider.notifier).signOut();

    // Leaving a member's points and habit log behind for whoever opens the
    // app next is the opposite of what signing out means.
    final second = await _withStore(prefs);
    expect(second.read(sessionProvider).isGuest, isTrue);
    expect(second.read(membershipProvider), isNull);
    expect(second.read(pointsBalanceProvider), 0);
    expect(second.read(favouritesCountProvider), 0);
  });

  test('unreadable stored data is dropped, not fatal', () async {
    // A member who cannot open the app at all, and has no way to clear it, is
    // a far worse outcome than one empty list.
    SharedPreferences.setMockInitialValues({
      StorageKey.membership: 'not json at all',
      StorageKey.points: '{"unexpected":"shape"}',
    });
    final prefs = await SharedPreferences.getInstance();

    final container = await _withStore(prefs);
    expect(container.read(membershipProvider), isNull);
    expect(container.read(pointsBalanceProvider), 0);
  });

  test('a container with no store simply does not persist', () {
    // Which is what a unit test wants, and why the store is optional.
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(membershipProvider.notifier).start('balance');
    expect(c.read(membershipProvider)!.packageId, 'balance');
  });
}
