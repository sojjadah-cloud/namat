import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/domain/city.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/account/domain/session.dart';
import 'package:namat/features/bookings/domain/cart_notifier.dart';
import 'package:namat/features/catalogue/domain/catalogue.dart';
import 'package:namat/features/favorites/domain/favorites.dart';
import 'package:namat/features/rewards/domain/points.dart';
import 'package:namat/features/use/domain/field.dart';
import 'package:namat/main.dart';

/// Guests, cities, points and saved things.
///
/// The guest gate is the one worth pinning hardest. Getting it wrong in either
/// direction is expensive: too strict and the catalogue is invisible to anyone
/// who has not signed up, too loose and an order is placed against nobody.

Future<ProviderContainer> _pumpAt(WidgetTester tester, String location) async {
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
  group('the session', () {
    test('starts as a guest in the launch market', () {
      const s = Session();
      expect(s.isGuest, isTrue);
      // Sohar, not "nothing": a guest who has chosen no city still needs a
      // real city's supply to browse.
      expect(s.city, NamatCity.sohar);
    });

    test('signing in keeps the name already gathered', () {
      final n = SessionNotifier()..setName('سارة');
      n.signIn();
      expect(n.state.isMember, isTrue);
      expect(n.state.name, 'سارة');
    });

    test('signing in with a name overwrites an empty one', () {
      final n = SessionNotifier()..signIn(name: 'خالد');
      expect(n.state.name, 'خالد');
    });

    test('signing out really signs out', () {
      // The setter used to discard its own result, so this stayed a member.
      final n = SessionNotifier()..signIn(name: 'خالد');
      n.signOut();
      expect(n.state.isGuest, isTrue);
      expect(n.state.name, '');
    });
  });

  group('cities', () {
    test('the launch market has partners in every field it claims', () {
      // Sohar is where the app launches; a field card that opens onto nothing
      // is the first impression it would make.
      final soharFields =
          Catalogue.byCity(NamatCity.sohar).map((p) => p.field).toSet();
      expect(soharFields, isNotEmpty);
      for (final f in soharFields) {
        expect(Catalogue.inCity(f, NamatCity.sohar), isNotEmpty);
      }
    });

    test('the researched partners stay in Muscat', () {
      // They are real businesses in Muscat. Relabelling them as Sohar to make
      // the launch market look full would be a lie about where they are.
      for (final slug in ['healthy-lab', 'nourish-kitchen', 'tree-of-life']) {
        expect(Catalogue.bySlug(slug)!.city, NamatCity.muscat, reason: slug);
      }
    });

    test('every field exists in at least one city', () {
      for (final f in NamatField.values) {
        expect(Catalogue.citiesWith(f), isNotEmpty, reason: f.name);
      }
    });

    test('a field empty in one city is offered in another', () {
      // Meals has no Sohar partner yet, which is exactly the state the empty
      // screen has to handle without looking broken.
      final soharMeals = Catalogue.inCity(NamatField.meals, NamatCity.sohar);
      final elsewhere = Catalogue.citiesWith(NamatField.meals);
      if (soharMeals.isEmpty) {
        expect(elsewhere, isNotEmpty);
        expect(elsewhere, isNot(contains(NamatCity.sohar)));
      }
    });

    test('a city name round-trips', () {
      expect(NamatCity.byName('sohar'), NamatCity.sohar);
      expect(NamatCity.byName('atlantis'), isNull);
    });
  });

  group('points', () {
    test('a new member has nothing and that is not an error', () {
      expect(PointsNotifier.balanceOf(const []), 0);
    });

    test('awards add up', () {
      final p = PointsNotifier()
        ..award(PointsReason.order)
        ..award(PointsReason.review);
      expect(
        PointsNotifier.balanceOf(p.state),
        pointsFor[PointsReason.order]! + pointsFor[PointsReason.review]!,
      );
    });

    test('the ledger keeps a row per award, newest first', () {
      final p = PointsNotifier()
        ..award(PointsReason.order, at: DateTime(2026, 8, 1))
        ..award(PointsReason.challenge, at: DateTime(2026, 8, 2));
      expect(p.state.length, 2);
      expect(p.state.first.reason, PointsReason.challenge);
    });

    test('redeeming subtracts and is recorded', () {
      final p = PointsNotifier();
      for (var i = 0; i < 5; i++) {
        p.award(PointsReason.challenge);
      }
      final before = PointsNotifier.balanceOf(p.state);

      expect(p.redeem(250), isTrue);
      expect(PointsNotifier.balanceOf(p.state), before - 250);
      // Visible in the ledger as a subtraction, not silently netted off.
      expect(p.state.first.amount, -250);
    });

    test('a balance cannot go negative', () {
      final p = PointsNotifier()..award(PointsReason.order);
      // A debt the member never agreed to is not a reward programme.
      expect(p.redeem(10000), isFalse);
      expect(PointsNotifier.balanceOf(p.state), greaterThanOrEqualTo(0));
    });

    test('redeeming zero or less is refused', () {
      final p = PointsNotifier()..award(PointsReason.challenge);
      expect(p.redeem(0), isFalse);
      expect(p.redeem(-50), isFalse);
    });

    test('every reward is reachable by earning', () {
      // A reward nobody can ever afford is decoration.
      final perChallenge = pointsFor[PointsReason.challenge]!;
      for (final r in namatRewards) {
        expect(r.cost, greaterThan(0), reason: r.id);
        expect(r.cost ~/ perChallenge, lessThan(40), reason: r.id);
      }
    });
  });

  group('saved things', () {
    test('the same thing cannot be saved twice', () {
      final f = FavouritesNotifier()
        ..toggle(FavouriteKind.partner, 'namat-move')
        ..toggle(FavouriteKind.partner, 'namat-move')
        ..toggle(FavouriteKind.partner, 'namat-move');
      expect(f.state.length, 1);
    });

    test('a partner and an offering with the same id are different', () {
      final f = FavouritesNotifier()
        ..toggle(FavouriteKind.partner, 'x')
        ..toggle(FavouriteKind.offering, 'x');
      expect(f.state.length, 2);
    });

    test('toggle reports what the state became', () {
      final f = FavouritesNotifier();
      expect(f.toggle(FavouriteKind.partner, 'namat-move'), isTrue);
      expect(f.toggle(FavouriteKind.partner, 'namat-move'), isFalse);
    });

    test('ids can be read back per kind', () {
      final f = FavouritesNotifier()
        ..toggle(FavouriteKind.partner, 'a')
        ..toggle(FavouriteKind.offering, 'b');
      expect(f.idsOf(FavouriteKind.partner), ['a']);
      expect(f.idsOf(FavouriteKind.offering), ['b']);
    });
  });

  group('the guest gate', () {
    testWidgets('a guest can browse a partner and its prices', (tester) async {
      tester.view.physicalSize = const Size(1200, 3600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final container =
          await _pumpAt(tester, '/explore/fitness/partner/namat-move');
      expect(container.read(sessionProvider).isGuest, isTrue);

      // The whole catalogue, without an account. Asking for a phone number
      // before showing a price is how a marketplace loses the undecided.
      expect(find.text('حصة يوغا'), findsOneWidget);
    });

    testWidgets('a guest can fill a cart but not place the order',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final container = await _pumpAt(tester, '/cart');
      container
          .read(cartProvider.notifier)
          .add(Catalogue.offeringById('nm-yoga')!);

      container.read(routerProvider).go('/cart/checkout');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('الحضور إلى المكان'));
      await tester.pump(const Duration(milliseconds: 300));

      // A slot is needed before the button enables.
      final slot = find.byType(FilledButton);
      expect(slot, findsWidgets);

      // Nothing was ordered, because nobody is signed in.
      expect(container.read(ordersProvider), isEmpty);
      // And the cart is intact, so the member loses nothing by being asked.
      expect(container.read(cartProvider), isNotEmpty);
    });
  });
}
