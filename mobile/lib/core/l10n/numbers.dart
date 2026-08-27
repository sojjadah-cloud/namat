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
  bool get _isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// Format for display: grouped, and in the locale's own digits.
  String n(num value) {
    // Grouping and decimal placement come from intl; only the glyphs are ours.
    final latin = NumberFormat.decimalPattern('en').format(value);
    return _isArabic ? _toArabicIndic(latin) : latin;
  }

  /// Money, at the precision the currency actually has.
  ///
  /// The rial divides into 1000 baisa, so prices here carry three decimals and
  /// not the two that most currency formatting assumes. `3.2` rendered as
  /// "3.20" is not a rounding nicety — it is a different price, and a member
  /// comparing it against a partner's own menu would find it wrong.
  ///
  /// The currency word is not appended here: it comes from the ARB, so that
  /// this returns a bare number the caller places on whichever side of it the
  /// layout wants.
  String money(num value) {
    final fixed = value.toStringAsFixed(3);
    final dot = fixed.indexOf('.');
    // Grouped on the whole part only; three decimals never take a separator.
    final whole = NumberFormat.decimalPattern('en')
        .format(int.parse(fixed.substring(0, dot)));
    final latin = '$whole.${fixed.substring(dot + 1)}';
    return _isArabic ? _toArabicIndic(latin) : latin;
  }

  /// A phone number as a reader sees it: "+٩٦٨ ٩١٢٣ ٤٥٦٧".
  ///
  /// Grouped and converted, unlike the number in the entry field — that one is
  /// typed on a keypad and sent to a network, this one is read back so the
  /// member can confirm it is theirs.
  String phone(String e164) {
    final digits = e164.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return e164;
    final country = digits.substring(0, 3);
    final rest = digits.substring(3);
    final grouped = rest.replaceAllMapped(
      RegExp(r'(\d{4})(?=\d)'),
      (m) => '${m[1]} ',
    );
    final latin = '+$country $grouped';
    return _isArabic ? _toArabicIndic(latin) : latin;
  }

  /// A moment, as a member would say it: "اليوم ٦:٠٠ م", "الخميس ٤:٠٠ م".
  ///
  /// Relative for the next week because that is the horizon a booking lives
  /// in — "الخميس" is instantly placeable where "٣٠ أغسطس" needs a calendar.
  /// Beyond that it falls back to a date, since "الخميس" three weeks out is
  /// ambiguous rather than helpful.
  String dateTime(DateTime when) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(when.year, when.month, when.day);
    final days = that.difference(today).inDays;

    final locale = _isArabic ? 'ar' : 'en';
    final time = DateFormat.jm(locale).format(when);

    final day = switch (days) {
      0 => _isArabic ? 'اليوم' : 'Today',
      1 => _isArabic ? 'بكرة' : 'Tomorrow',
      -1 => _isArabic ? 'أمس' : 'Yesterday',
      > 1 && < 7 => DateFormat.EEEE(locale).format(when),
      _ => DateFormat.MMMd(locale).format(when),
    };

    // intl renders the date in Latin digits even for 'ar', for the same reason
    // NumberFormat does — so the glyph swap applies here too.
    final joined = '$day $time';
    return _isArabic ? _toArabicIndic(joined) : joined;
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
