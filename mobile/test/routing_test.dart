import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/challenges/presentation/challenges_page.dart';
import 'package:namat/features/challenges/presentation/create_duel_page.dart';
import 'package:namat/features/challenges/presentation/duel_room_page.dart';
import 'package:namat/features/challenges/presentation/duel_sent_page.dart';
import 'package:namat/features/challenges/presentation/find_opponent_page.dart';
import 'package:namat/features/notifications/presentation/notifications_page.dart';
import 'package:namat/features/packages/presentation/packages_page.dart';
import 'package:namat/features/partners/presentation/partner_page.dart';
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
    await _pumpAt(tester, '/challenges');
    expect(find.byType(ChallengesPage), findsOneWidget);

    await _pumpAt(tester, '/challenges/find');
    expect(find.byType(FindOpponentPage), findsOneWidget);

    await _pumpAt(tester, '/challenges/new/ahmedfit');
    expect(find.byType(CreateDuelPage), findsOneWidget);

    await _pumpAt(tester, '/challenges/sent/ahmedfit');
    expect(find.byType(DuelSentPage), findsOneWidget);

    await _pumpAt(tester, '/challenges/room');
    expect(find.byType(DuelRoomPage), findsOneWidget);
  });

  testWidgets('packages and the field pages resolve', (tester) async {
    await _pumpAt(tester, '/journey/packages');
    expect(find.byType(PackagesPage), findsOneWidget);

    await _pumpAt(tester, '/use/meals');
    expect(find.byType(FieldPage), findsOneWidget);

    // An unknown field must not crash; it falls through to the error state.
    await _pumpAt(tester, '/use/nonsense');
    expect(find.byType(FieldPage), findsOneWidget);
  });

  testWidgets('a duel carries its opponent through the flow', (tester) async {
    await _pumpAt(tester, '/challenges/new/maryam');
    final page = tester.widget<CreateDuelPage>(find.byType(CreateDuelPage));
    expect(page.username, 'maryam');
  });

  testWidgets('notifications and partner pages resolve', (tester) async {
    await _pumpAt(tester, '/home/notifications');
    expect(find.byType(NotificationsPage), findsOneWidget);

    await _pumpAt(tester, '/use/meals/partner/healthy-lab');
    expect(find.byType(PartnerPage), findsOneWidget);

    // An unknown slug falls back rather than throwing — a stale link should
    // not crash the app.
    await _pumpAt(tester, '/use/meals/partner/does-not-exist');
    expect(find.byType(PartnerPage), findsOneWidget);
  });
}
