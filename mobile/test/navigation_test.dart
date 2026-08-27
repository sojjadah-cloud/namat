import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/routing/router.dart';
import 'package:namat/core/widgets/namat_nav.dart';
import 'package:namat/main.dart';

/// Direction, and where back goes.
///
/// Both of the faults here were invisible to anyone reading the code in
/// English. Flutter mirrors `arrow_back`, `arrow_forward`, `chevron_left` and
/// `chevron_right` automatically in RTL, so reaching for the opposite-facing
/// icon to "fix" the direction by hand mirrors it twice and lands back where
/// it started — the back arrow pointed left in Arabic, where back is to the
/// right.

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
  group('direction', () {
    test('the icons the app relies on really do mirror', () {
      // The whole approach rests on this. If a future Flutter stopped
      // mirroring them, every back arrow in the Arabic build would silently
      // point the wrong way and nothing else would fail.
      expect(Icons.arrow_back.matchTextDirection, isTrue);
      expect(Icons.chevron_right.matchTextDirection, isTrue);
    });

    test('no screen hand-rolls a reversed arrow', () {
      // `arrow_forward` as a back button and `chevron_left` as "onward" are
      // the two shapes of this mistake. Caught by reading the source, because
      // a widget test cannot see an icon that is correct on one screen and
      // backwards on another.
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('Icons.arrow_forward') ||
            source.contains('Icons.chevron_left')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    testWidgets('the back affordance is an arrow_back', (tester) async {
      await _pump(tester, '/profile/settings');
      expect(find.byType(NamatBack), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsWidgets);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });
  });

  group('where back goes', () {
    testWidgets('settings sub-pages return to settings', (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final container = await _pump(tester, '/profile/settings');
      final router = container.read(routerProvider);

      for (final page in [
        'addresses',
        'city',
        'notifications',
        'language',
        'privacy',
        'support',
      ]) {
        router.go('/profile/settings/$page');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Every one of them opens, which is the part that used to be a row
        // that swallowed the tap.
        expect(find.byType(NamatBack), findsOneWidget, reason: page);

        await tester.tap(find.byType(NamatBack));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // And back retraces one step rather than jumping to a tab root.
        expect(
          find.text('الإعدادات'),
          findsWidgets,
          reason: 'back from $page did not land on settings',
        );
      }
    });

    testWidgets('the profile offers one door to settings, not four',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 3000);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await _pump(tester, '/profile');

      // Privacy, language and support used to be listed here as well as
      // inside Settings, so tapping one and pressing back landed on a screen
      // the member had never opened.
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(find.text('الخصوصية'), findsNothing);
      expect(find.text('اللغة'), findsNothing);
      expect(find.text('المساعدة'), findsNothing);
    });

    testWidgets('a tab root shows no back button at all', (tester) async {
      await _pump(tester, '/profile');
      // Nothing to go back to, so nothing that looks like it would.
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });
  });
}
