import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/data/store.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/features/account/domain/session.dart';
import 'package:namat/features/auth/domain/accounts.dart';
import 'package:namat/features/auth/domain/profile_draft.dart';
import 'package:namat/features/auth/presentation/phone_page.dart';
import 'package:namat/features/auth/presentation/setup_page.dart';
import 'package:namat/features/auth/presentation/verify_page.dart';
import 'package:namat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signing up with a number that already has an account, and keeping a name.
///
/// Both faults were about work the member does twice. Signing up again with
/// the number they already used walked them through every setup question to
/// arrive at the account they already had; and the name they typed on the
/// first of those questions was only written down when they advanced past it,
/// so a reload lost it and asked for it again.

const _phone = Size(360, 720);

Future<ProviderContainer> _pump(
  WidgetTester tester,
  String location, {
  SharedPreferences? prefs,
}) async {
  tester.view.physicalSize = _phone * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      if (prefs != null) storeProvider.overrideWithValue(NamatStore(prefs)),
    ],
  );
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
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the account registry', () {
    test('a number is unknown until it completes a sign-up', () {
      final a = AccountsNotifier();
      expect(a.isRegistered('+96891234567'), isFalse);
      a.register('+96891234567');
      expect(a.isRegistered('+96891234567'), isTrue);
    });

    test('every spelling of one number is the same account', () {
      final a = AccountsNotifier()..register(normalisePhone('91234567'));
      // Two spellings becoming two accounts would defeat the check as surely
      // as not having one.
      for (final spelling in ['+968 9123 4567', '096891234567', '91234567']) {
        expect(
          a.isRegistered(normalisePhone(spelling)),
          isTrue,
          reason: spelling,
        );
      }
    });

    test('the number itself is never written down', () async {
      final prefs = await SharedPreferences.getInstance();
      AccountsNotifier(NamatStore(prefs)).register('+96891234567');

      // This store is plain localStorage on the web, readable by any script
      // on the origin. The registry only ever has to answer "have I seen this
      // one", and a digest answers that without holding the number.
      final written = prefs.getString(StorageKey.accounts) ?? '';
      expect(written, isNot(contains('96891234567')));
      expect(written, contains(AccountsNotifier.fingerprint('+96891234567')));
    });

    test('the sign-up draft does not keep the number either', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [storeProvider.overrideWithValue(NamatStore(prefs))],
      );
      addTearDown(container.dispose);

      container.read(profileDraftProvider.notifier)
        ..setPhone('+96891234567')
        ..setName('سارة');

      // It is needed for the few seconds between typing it and confirming the
      // code, and for nothing after that.
      final written = prefs.getString(StorageKey.draft) ?? '';
      expect(written, isNot(contains('96891234567')));
      expect(written, contains('سارة'));
    });

    test('an empty number is not an account', () {
      final a = AccountsNotifier()..register('');
      expect(a.state, isEmpty);
    });

    test('registration survives a relaunch', () async {
      final prefs = await SharedPreferences.getInstance();
      AccountsNotifier(NamatStore(prefs)).register('+96891234567');
      expect(
        AccountsNotifier(NamatStore(prefs)).isRegistered('+96891234567'),
        isTrue,
      );
    });

    test('signing out does not forget that the number has an account',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [storeProvider.overrideWithValue(NamatStore(prefs))],
      );
      addTearDown(container.dispose);

      container.read(accountsProvider.notifier).register('+96891234567');
      container.read(sessionProvider.notifier).signOut();

      // Signing out means "this is not my session", not "this number was
      // never used here" — otherwise signing back in offers the setup
      // questions all over again.
      final next = ProviderContainer(
        overrides: [storeProvider.overrideWithValue(NamatStore(prefs))],
      );
      addTearDown(next.dispose);
      expect(
        next.read(accountsProvider.notifier).isRegistered('+96891234567'),
        isTrue,
      );
    });
  });

  group('the wrong door', () {
    testWidgets('signing up with a registered number offers sign-in instead',
        (tester) async {
      final container = await _pump(tester, '/signup');
      container.read(accountsProvider.notifier).register('+96891234567');

      await tester.enterText(find.byType(TextField), '91234567');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Told inline, beside the field they just filled in, and offered the
      // other door — not silently redirected, because they typed a number
      // rather than an intention to be moved.
      expect(find.text('هذا الرقم مسجّل عندنا'), findsOneWidget);
      expect(find.text('سجّل دخولك'), findsWidgets);
      // And still on the sign-up screen until they choose.
      expect(find.byType(VerifyPage), findsNothing);
    });

    testWidgets('taking the offer lands on the code, not the number again',
        (tester) async {
      final container = await _pump(tester, '/signup');
      container.read(accountsProvider.notifier).register('+96891234567');

      await tester.enterText(find.byType(TextField), '91234567');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.widgetWithText(FilledButton, 'سجّل دخولك'));
      // pumpAndSettle is not an option — the verify screen runs a resend
      // countdown, so it never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // The number is already typed and already stored; asking again would be
      // asking twice for one answer.
      expect(find.byType(VerifyPage), findsOneWidget);
      expect(
        tester.widget<VerifyPage>(find.byType(VerifyPage)).mode,
        'login',
      );
      expect(container.read(profileDraftProvider).phone, '+96891234567');
    });

    testWidgets('signing in with an unknown number offers sign-up',
        (tester) async {
      await _pump(tester, '/login');

      await tester.enterText(find.byType(TextField), '91234567');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // The mirror of the same mistake: a correct code sent to somebody with
      // nothing to sign in to.
      expect(find.text('ما لقينا حساباً بهذا الرقم'), findsOneWidget);
    });

    testWidgets('an unregistered number signs up without interruption',
        (tester) async {
      await _pump(tester, '/signup');

      await tester.enterText(find.byType(TextField), '91234567');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(VerifyPage), findsOneWidget);
      expect(find.byType(PhonePage), findsNothing);
    });
  });

  group('the name', () {
    testWidgets('is kept as it is typed, not when the step is left',
        (tester) async {
      final container = await _pump(tester, '/setup');
      expect(find.byType(SetupPage), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'سارة');
      await tester.pump();

      // Advancing used to be the only thing that saved it, so a name typed
      // and then abandoned was simply gone.
      expect(container.read(profileDraftProvider).name, 'سارة');
    });

    testWidgets('comes back into the field after a relaunch', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      final first = await _pump(tester, '/setup', prefs: prefs);
      await tester.enterText(find.byType(TextField).first, 'خالد');
      await tester.pump();
      expect(first.read(profileDraftProvider).name, 'خالد');

      // A second launch: the field is seeded from what is stored, rather than
      // sitting blank while the next screen greets them by name.
      await _pump(tester, '/setup', prefs: prefs);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'خالد',
      );
    });

    testWidgets('survives to the greeting on Home', (tester) async {
      final container = await _pump(tester, '/setup');
      await tester.enterText(find.byType(TextField).first, 'سارة');
      await tester.pump();

      expect(container.read(greetingNameProvider), 'سارة');
    });
  });
}
