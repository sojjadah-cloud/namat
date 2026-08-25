import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/main.dart';

void main() {
  testWidgets('boots in Arabic and lays out right-to-left', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NamatApp()));
    await tester.pump();

    // The context has to come from *below* MaterialApp: the Localizations and
    // Directionality widgets are built by it, so its own element sits above
    // them and cannot see either.
    final context = tester.element(find.byType(Scaffold).first);

    // Arabic is the default rather than a fallback, and the entire layout
    // depends on the direction being derived from it.
    expect(Localizations.localeOf(context).languageCode, 'ar');
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('the splash finishes and hands over to onboarding',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: NamatApp()));

    // The mark draws itself over ~2.4s; anything longer than that and a cold
    // start is being padded rather than covered.
    await tester.pump(const Duration(milliseconds: 2500));
    // Not pumpAndSettle: the onboarding illustration orbits continuously by
    // design, so nothing on that screen ever settles and the helper would
    // time out waiting for an animation that is supposed to keep running.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PageView), findsOneWidget);
  });
}
