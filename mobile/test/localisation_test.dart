import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namat/core/l10n/numbers.dart';
import 'package:namat/features/profile/presentation/profile_page.dart';
import 'package:namat/l10n/app_localizations.dart';

/// Arabic digits and identifier direction.
///
/// Both of these reached the screen once and neither is visible in a code
/// review: a Latin `8420` in an Arabic sentence and a handle rendered
/// back-to-front both compile, pass analysis, and look wrong only to someone
/// reading Arabic. That is what these tests are for.

Widget _wrap(Widget child, {Locale locale = const Locale('ar')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: L.supportedLocales,
    localizationsDelegates: const [
      L.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  group('numbers follow the reader', () {
    testWidgets('Arabic renders Arabic-Indic digits', (tester) async {
      late String formatted;
      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) {
              formatted = context.n(8420);
              return const SizedBox();
            },
          ),
        ),
      );
      // ٨٤٢٠ with the Arabic thousands separator, not "8420".
      expect(formatted, contains('٨'));
      expect(formatted, isNot(contains('8')));
    });

    testWidgets('English keeps Latin digits', (tester) async {
      late String formatted;
      await tester.pumpWidget(
        _wrap(
          locale: const Locale('en'),
          Builder(
            builder: (context) {
              formatted = context.n(8420);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(formatted, contains('8'));
      expect(formatted, isNot(contains('٨')));
    });
  });

  group('identifiers stay left-to-right', () {
    test('a handle is wrapped in a directional isolate', () {
      final h = handle('sara');
      // Without these, bidi moves the at-sign to the far end of an Arabic
      // line and "@sara" renders as "sara@".
      expect(h.codeUnitAt(0), 0x2066, reason: 'missing FIRST STRONG ISOLATE');
      expect(h.codeUnitAt(h.length - 1), 0x2069,
          reason: 'missing POP DIRECTIONAL ISOLATE');
      expect(h, contains('@sara'));
    });

    test('the at-sign leads the handle inside the isolate', () {
      final inner = handle('sara').replaceAll(RegExp(r'[\u2066\u2069]'), '');
      expect(inner, '@sara');
    });
  });

  testWidgets('the profile shows an Arabic level and an intact handle',
      (tester) async {
    await tester.pumpWidget(_wrap(const Scaffold(body: ProfilePage())));
    await tester.pump();

    // The level placeholder is an int; without a format in the ARB it renders
    // as a Latin numeral inside an Arabic sentence.
    expect(find.textContaining('٨'), findsWidgets);
    expect(find.textContaining('مستوى نمط 8'), findsNothing);

    // The handle is present and isolated.
    expect(find.text(handle('sara')), findsOneWidget);
  });
}
