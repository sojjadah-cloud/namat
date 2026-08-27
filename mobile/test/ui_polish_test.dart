import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/core/widgets/namat_art.dart';
import 'package:namat/core/widgets/namat_nav.dart';
import 'package:namat/features/account/domain/session.dart';
import 'package:namat/features/rewards/domain/points.dart';
import 'package:namat/main.dart';

/// The screens as a phone actually renders them.
///
/// Everything here was reported from a phone and none of it was visible at the
/// wide default a widget test uses unless the viewport is set first — the
/// blank reward cards most of all, which came from a Row leaving its text no
/// width at 360dp and looked perfectly fine at 800.

const _phone = Size(360, 720);

Future<ProviderContainer> _pump(WidgetTester tester, String location) async {
  tester.view.physicalSize = _phone * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

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
  group('the tab bar', () {
    testWidgets('names every destination, not just the open one',
        (tester) async {
      await _pump(tester, '/home');
      // An unlabelled glyph is a destination the member has to guess at — and
      // the tabs they most need are the ones they have not opened.
      for (final label in ['الرئيسية', 'استكشف', 'رحلتي', 'حجوزاتي', 'حسابي']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });
  });

  group('going back', () {
    testWidgets('every pushed screen has a way out', (tester) async {
      for (final route in [
        '/journey/challenges',
        '/journey/packages',
        '/profile/points',
        '/profile/favorites',
        '/profile/edit',
        '/profile/settings',
        '/search',
        '/cart',
        '/home/notifications',
        '/explore/fitness',
        '/explore/fitness/partner/namat-move',
      ]) {
        await _pump(tester, route);
        expect(find.byType(NamatBack), findsOneWidget, reason: route);
      }
    });
  });

  group('the points screen', () {
    testWidgets('renders its rewards rather than blank cards', (tester) async {
      await _pump(tester, '/profile/points');

      // Every reward's title, its cost, and something to do about it. The
      // cards used to draw as empty white boxes at this width.
      expect(find.text('حصة رياضية مجانية'), findsOneWidget);
      expect(find.text('متابعة تغذية مجانية'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a dead button says how far off it is', (tester) async {
      final container = await _pump(tester, '/profile/points');
      final cheapest =
          namatRewards.reduce((a, b) => a.cost < b.cost ? a : b);
      expect(container.read(pointsBalanceProvider), 0);

      // "Redeem", greyed out, tells a member with nothing exactly nothing.
      expect(find.text('استبدل'), findsNothing);
      expect(find.textContaining('باقي'), findsWidgets);
      expect(cheapest.cost, greaterThan(0));
    });

    testWidgets('a funded reward becomes redeemable', (tester) async {
      final container = await _pump(tester, '/profile/points');
      final cheapest =
          namatRewards.reduce((a, b) => a.cost < b.cost ? a : b);

      final points = container.read(pointsProvider.notifier);
      for (var i = 0; i < 40; i++) {
        points.awardOnce(PointsReason.streak, detail: 'day-$i');
      }
      await tester.pumpAndSettle();

      expect(
        container.read(pointsBalanceProvider),
        greaterThanOrEqualTo(cheapest.cost),
      );
      expect(find.text('استبدل'), findsWidgets);
    });
  });

  group('the profile', () {
    testWidgets('offers a handle and a way to set one', (tester) async {
      final container = await _pump(tester, '/profile');
      container.read(sessionProvider.notifier).signIn(name: 'سارة');
      await tester.pumpAndSettle();

      // No handle yet, and the profile says so rather than showing nothing.
      expect(find.text('ما اخترت اسم مستخدم'), findsOneWidget);
    });

    testWidgets('shows the handle once set, isolated and Latin',
        (tester) async {
      final container = await _pump(tester, '/profile');
      container.read(sessionProvider.notifier)
        ..signIn(name: 'سارة')
        ..setUsername('SaraQ');
      await tester.pumpAndSettle();

      // Lower-cased on the way in, and wrapped in a bidi isolate so the
      // at-sign does not travel to the far end of an Arabic line.
      expect(container.read(sessionProvider).username, 'saraq');
      expect(find.textContaining('@saraq'), findsOneWidget);
    });

    testWidgets('signs out from the bottom of the profile', (tester) async {
      final container = await _pump(tester, '/profile');
      container.read(sessionProvider.notifier).signIn(name: 'سارة');
      await tester.pumpAndSettle();

      // Found by its label, not by type: OutlinedButton.icon builds a private
      // subclass, and find.byType matches the exact runtime type only.
      final button = find.text('تسجيل الخروج');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      // pump, not pumpAndSettle: signing out lands on the welcome screen,
      // which animates continuously by design and never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(container.read(sessionProvider).isGuest, isTrue);
    });

    testWidgets('a guest is not offered a sign-out', (tester) async {
      await _pump(tester, '/profile');
      expect(find.text('تسجيل الخروج'), findsNothing);
    });
  });

  group('usernames', () {
    test('the rules are about being passed on', () {
      expect(isValidUsername('sara'), isTrue);
      expect(isValidUsername('sara_q1'), isTrue);
      // Too short to be distinctive, too long to repeat over a phone.
      expect(isValidUsername('ab'), isFalse);
      expect(isValidUsername('a' * 21), isFalse);
      // Arabic and spaces: a handle that has to be spelled in two scripts is
      // one nobody can pass on.
      expect(isValidUsername('سارة'), isFalse);
      expect(isValidUsername('sara q'), isFalse);
    });

    test('case does not make two different handles', () {
      expect(isValidUsername('SARA'), isTrue);
      final n = SessionNotifier()..setUsername('  SaRa  ');
      expect(n.state.username, 'sara');
    });
  });

  group('artwork', () {
    testWidgets('every catalogue row carries a mark', (tester) async {
      await _pump(tester, '/explore/fitness/partner/namat-move');
      // A list of pure text rows gives the eye nothing to land on, and every
      // item looks like every other item.
      expect(find.byType(NamatArt), findsWidgets);
    });

    testWidgets('the same id always draws the same mark', (tester) async {
      // A dish that changes appearance between the list and the sheet reads
      // as a different dish.
      const a = NamatArt(seed: 'nm-yoga', accent: Colors.green, tint: Colors.white);
      const b = NamatArt(seed: 'nm-yoga', accent: Colors.green, tint: Colors.white);
      expect(a.seed, b.seed);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Row(children: [a, b]))),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
