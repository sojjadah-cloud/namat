import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/auth/presentation/phone_page.dart';
import 'package:namat/features/auth/presentation/setup_page.dart';
import 'package:namat/features/auth/presentation/verify_page.dart';
import 'package:namat/features/bookings/presentation/bookings_page.dart';
import 'package:namat/features/bookings/presentation/cart_page.dart';
import 'package:namat/features/bookings/presentation/checkout_page.dart';
import 'package:namat/features/bookings/presentation/order_done_page.dart';
import 'package:namat/features/challenges/presentation/challenges_page.dart';
import 'package:namat/features/challenges/presentation/create_duel_page.dart';
import 'package:namat/features/challenges/presentation/duel_room_page.dart';
import 'package:namat/features/challenges/presentation/duel_sent_page.dart';
import 'package:namat/features/challenges/presentation/find_opponent_page.dart';
import 'package:namat/features/notifications/presentation/notifications_page.dart';
import 'package:namat/features/packages/presentation/packages_page.dart';
import 'package:namat/features/partners/presentation/partner_page.dart';
import 'package:namat/features/reviews/presentation/rate_page.dart';
import 'package:namat/features/use/presentation/field_page.dart';
import 'package:namat/main.dart';

/// Routes resolve.
///
/// A mistyped path in GoRouter is not a compile error — it is a blank screen
/// the first time someone taps the button, which is exactly the kind of fault
/// that survives a demo and reaches a user.

Future<void> _pumpAt(WidgetTester tester, String location) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(routerProvider).go(location);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const NamatApp(),
    ),
  );
  // Long enough for the splash to hand over, but not pumpAndSettle: several
  // screens animate continuously and would never settle.
  await tester.pump(const Duration(milliseconds: 2600));
  await tester.pump();
}

void main() {
  testWidgets('the challenge flow resolves end to end', (tester) async {
    await _pumpAt(tester, '/journey/challenges');
    expect(find.byType(ChallengesPage), findsOneWidget);

    await _pumpAt(tester, '/journey/challenges/find');
    expect(find.byType(FindOpponentPage), findsOneWidget);

    await _pumpAt(tester, '/journey/challenges/new/ahmedfit');
    expect(find.byType(CreateDuelPage), findsOneWidget);

    await _pumpAt(tester, '/journey/challenges/sent/ahmedfit');
    expect(find.byType(DuelSentPage), findsOneWidget);

    await _pumpAt(tester, '/journey/challenges/room');
    expect(find.byType(DuelRoomPage), findsOneWidget);
  });

  testWidgets('packages and the field pages resolve', (tester) async {
    await _pumpAt(tester, '/journey/packages');
    expect(find.byType(PackagesPage), findsOneWidget);

    await _pumpAt(tester, '/explore/meals');
    expect(find.byType(FieldPage), findsOneWidget);

    // An unknown field must not crash; it falls through to the error state.
    await _pumpAt(tester, '/explore/nonsense');
    expect(find.byType(FieldPage), findsOneWidget);
  });

  testWidgets('a duel carries its opponent through the flow', (tester) async {
    await _pumpAt(tester, '/journey/challenges/new/maryam');
    final page = tester.widget<CreateDuelPage>(find.byType(CreateDuelPage));
    expect(page.username, 'maryam');
  });

  testWidgets('notifications and partner pages resolve', (tester) async {
    await _pumpAt(tester, '/home/notifications');
    expect(find.byType(NotificationsPage), findsOneWidget);

    await _pumpAt(tester, '/explore/meals/partner/healthy-lab');
    expect(find.byType(PartnerPage), findsOneWidget);

    // An unknown slug falls back rather than throwing — a stale link should
    // not crash the app.
    await _pumpAt(tester, '/explore/meals/partner/does-not-exist');
    expect(find.byType(PartnerPage), findsOneWidget);
  });

  testWidgets('the order flow resolves', (tester) async {
    await _pumpAt(tester, '/bookings');
    expect(find.byType(BookingsPage), findsOneWidget);

    await _pumpAt(tester, '/cart');
    expect(find.byType(CartPage), findsOneWidget);

    await _pumpAt(tester, '/cart/checkout');
    expect(find.byType(CheckoutPage), findsOneWidget);

    // The reference is part of the path now: the confirmation screen shows
    // the order it names rather than whatever was bought most recently.
    await _pumpAt(tester, '/cart/done/NM-4K7Q2');
    expect(find.byType(OrderDonePage), findsOneWidget);
    expect(
      tester.widget<OrderDonePage>(find.byType(OrderDonePage)).reference,
      'NM-4K7Q2',
    );

    await _pumpAt(tester, '/rate/NM-4K7Q2');
    expect(find.byType(RatePage), findsOneWidget);
  });

  testWidgets('the sign-up flow resolves end to end', (tester) async {
    await _pumpAt(tester, '/signup');
    expect(find.byType(PhonePage), findsOneWidget);
    expect(
      tester.widget<PhonePage>(find.byType(PhonePage)).mode,
      'signup',
    );

    await _pumpAt(tester, '/signup/verify');
    expect(find.byType(VerifyPage), findsOneWidget);

    await _pumpAt(tester, '/setup');
    expect(find.byType(SetupPage), findsOneWidget);
  });

  testWidgets('login reuses the same screen in the other mode', (tester) async {
    await _pumpAt(tester, '/login');
    expect(tester.widget<PhonePage>(find.byType(PhonePage)).mode, 'login');

    await _pumpAt(tester, '/login/verify');
    expect(tester.widget<VerifyPage>(find.byType(VerifyPage)).mode, 'login');
  });
}
