import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'namat_colors.dart';

/// The NAMAT theme.
///
/// Material 3 is the technical foundation and nothing more: every colour,
/// radius and text style below is NAMAT's. What Material is actually used for
/// is the plumbing — ink wells, focus traversal, semantics, safe areas — none
/// of which is worth reimplementing.
///
/// Typography is script-aware. Arabic leads in `PlexArabic` and English in
/// `Poppins`, because a wordmark and a paragraph want different faces and
/// Arabic set in a Latin-first face with a fallback looks like a fallback.
/// Arabic also carries more line height: connected letterforms with ascenders
/// and descenders crowd at the leading that suits Latin.
abstract final class NamatTheme {
  static const _arabic = 'PlexArabic';
  static const _latin = 'Poppins';

  static ThemeData of(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final body = isArabic ? _arabic : _latin;
    // The wordmark and display type stay Poppins in both locales for Latin
    // strings, but Arabic headings must be set in the Arabic face.
    final display = isArabic ? _arabic : _latin;
    final heightScale = isArabic ? 1.45 : 1.25;

    const scheme = ColorScheme.light(
      primary: NamatColors.deep,
      onPrimary: Colors.white,
      primaryContainer: NamatColors.greenSoft,
      onPrimaryContainer: NamatColors.deeper,
      secondary: NamatColors.sage,
      onSecondary: Colors.white,
      surface: NamatColors.surface,
      onSurface: NamatColors.ink,
      surfaceContainerLowest: NamatColors.canvas,
      surfaceContainerLow: NamatColors.warmSoft,
      surfaceContainer: NamatColors.warm,
      outline: NamatColors.line,
      outlineVariant: NamatColors.line,
      error: NamatColors.danger,
      onError: Colors.white,
    );

    TextStyle t(double size, FontWeight weight, {double? height, Color? color}) =>
        TextStyle(
          fontFamily: body,
          fontSize: size,
          fontWeight: weight,
          height: height ?? heightScale,
          color: color ?? NamatColors.ink,
          letterSpacing: isArabic ? 0 : -0.01 * size,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: NamatColors.canvas,
      fontFamily: body,
      splashFactory: InkSparkle.splashFactory,

      textTheme: TextTheme(
        // Display sizes are for headlines only; they use the display face and
        // tighter leading than body copy.
        displayLarge: TextStyle(
          fontFamily: display,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          height: isArabic ? 1.3 : 1.08,
          color: NamatColors.ink,
          letterSpacing: isArabic ? 0 : -0.9,
        ),
        displayMedium: TextStyle(
          fontFamily: display,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: isArabic ? 1.32 : 1.12,
          color: NamatColors.ink,
          letterSpacing: isArabic ? 0 : -0.6,
        ),
        titleLarge: t(21, FontWeight.w600, height: isArabic ? 1.4 : 1.2),
        titleMedium: t(17, FontWeight.w600),
        bodyLarge: t(16, FontWeight.w400),
        bodyMedium: t(15, FontWeight.w400),
        bodySmall: t(13, FontWeight.w400, color: NamatColors.inkSoft),
        labelLarge: t(15, FontWeight.w600),
        labelMedium: t(13, FontWeight.w600),
        labelSmall: t(11, FontWeight.w600, color: NamatColors.inkSoft),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: NamatColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: NamatColors.ink,
        ),
      ),

      // 52 rather than Material's 40: the guidance floor is 44, and a primary
      // action on a wellness app is pressed with a thumb, often mid-walk.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: NamatColors.deep,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NamatRadius.sm),
          ),
          textStyle: TextStyle(
            fontFamily: body,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NamatColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: NamatColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NamatRadius.sm),
          ),
          textStyle: TextStyle(
            fontFamily: body,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NamatColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: t(15, FontWeight.w400, color: NamatColors.inkSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NamatRadius.sm),
          borderSide: const BorderSide(color: NamatColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NamatRadius.sm),
          borderSide: const BorderSide(color: NamatColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NamatRadius.sm),
          borderSide: const BorderSide(color: NamatColors.deep, width: 1.5),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: NamatColors.line,
        thickness: 1,
        space: 1,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
