import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Numbers, in the reader's own digits.
///
/// Arabic in Oman is written with Arabic-Indic digits, so a Latin `8420` in an
/// otherwise Arabic sentence reads as a foreign insert. Flutter will not do
/// this on its own: a Dart `int` interpolated into a string is always Latin,
/// which is exactly how "مستوى نمط 8" reached the screen.
///
/// The digits are mapped here by hand rather than left to `intl`. That is not
/// belt-and-braces — `NumberFormat.decimalPattern('ar').format(8420)` returns
/// `"8,420"`. Dart's locale data does not switch numbering system the way a
/// browser's `Intl` does, so trusting it yields Latin digits that look correct
/// in review and wrong on the screen.
///
/// Every user-visible number goes through [n] rather than string
/// interpolation. There is one deliberate exception, below.

const _arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// U+066C ARABIC THOUSANDS SEPARATOR and U+066B ARABIC DECIMAL SEPARATOR.
const _arabicGroup = '٬';
const _arabicDecimal = '٫';

String _toArabicIndic(String latin) {
  final out = StringBuffer();
  for (final unit in latin.codeUnits) {
    if (unit >= 0x30 && unit <= 0x39) {
      out.write(_arabicIndic[unit - 0x30]);
    } else if (unit == 0x2C) {
      out.write(_arabicGroup);
    } else if (unit == 0x2E) {
      out.write(_arabicDecimal);
    } else {
      out.writeCharCode(unit);
    }
  }
  return out.toString();
}

extension NamatNumbers on BuildContext {
  /// Format for display: grouped, and in the locale's own digits.
  String n(num value) {
    // Grouping and decimal placement come from intl; only the glyphs are ours.
    final latin = NumberFormat.decimalPattern('en').format(value);
    return Localizations.localeOf(this).languageCode == 'ar'
        ? _toArabicIndic(latin)
        : latin;
  }
}

/// FIRST STRONG ISOLATE and POP DIRECTIONAL ISOLATE.
///
/// Written as escapes rather than pasted in: they are invisible, and a literal
/// bidi control in source makes the code read differently from how it
/// compiles — which is a trap for the next person editing this line.
const _isolateStart = '\u2066';
const _isolateEnd = '\u2069';

/// Pins a run of text as left-to-right without affecting the text around it.
///
/// Identifiers stay Latin in both languages: a username, a booking reference
/// or a verification code is transcribed rather than read — someone says it
/// aloud to a receptionist or types it into a keypad — and converting its
/// digits makes it unusable.
///
/// The isolate matters as much as the digits do. Bidi reordering moves a
/// leading at-sign to the far end of an Arabic line, so a handle renders
/// back-to-front without it.
String ltrIsolate(String identifier) =>
    '$_isolateStart$identifier$_isolateEnd';

/// A handle as it should appear anywhere in the app.
String handle(String username) => ltrIsolate('@$username');
