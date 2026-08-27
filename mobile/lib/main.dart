import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'core/data/store.dart';
import 'core/routing/router.dart';
import 'core/theme/namat_colors.dart';
import 'core/theme/namat_theme.dart';
import 'features/settings/domain/preferences.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: NamatColors.canvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // Loaded before the first frame rather than hydrated afterwards. The
  // alternative is a visible flash of an empty app followed by the member's
  // own data appearing — which on the screen that says "no package" reads as
  // the subscription having been lost and then found.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        storeProvider.overrideWithValue(NamatStore(prefs)),
      ],
      child: const NamatApp(),
    ),
  );
}

/// The locale the app is running in.
///
/// Arabic is the default rather than a fallback: NAMAT is an Omani product and
/// the Arabic layout is the designed one. English is the translation.
///
/// Derived from the member's own setting so the language screen actually
/// changes the app, rather than recording a preference nothing reads.
final localeProvider = Provider<Locale>(
  (ref) => ref.watch(preferencesProvider).locale ?? const Locale('ar'),
);

class NamatApp extends ConsumerWidget {
  const NamatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'NAMAT',
      debugShowCheckedModeBanner: false,
      theme: NamatTheme.of(locale),
      locale: locale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        // Respect the reader's font-size setting, but stop runaway scaling
        // from breaking the progress rings and the VS layout.
        final scale = MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child!,
        );
      },
    );
  }
}
