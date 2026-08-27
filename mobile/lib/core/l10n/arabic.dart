/// Arabic text folding for search.
///
/// Someone typing `اطلس` expects to find `أطلس`, and someone typing `مسؤول`
/// expects to find it whether or not they reached for the hamza. Without
/// folding, search appears broken to exactly the members who type fastest.
///
/// The mapping is written as an explicit map rather than as two parallel
/// strings fed to a translate-style call. That is deliberate: the parallel
/// form was used once here and one missing replacement shifted every mapping
/// after it, silently, so `ة` folded to `ي`. A map cannot go out of step with
/// itself.
library;

const Map<String, String> _folds = {
  // Every alef form is one letter as far as a searcher is concerned.
  'أ': 'ا',
  'إ': 'ا',
  'آ': 'ا',
  'ٱ': 'ا',
  // Alef maqsura and ya are interchanged constantly in typing.
  'ى': 'ي',
  // Ta marbuta reads as ha at the end of a word.
  'ة': 'ه',
  // Hamza carriers fold to the letter carrying them.
  'ؤ': 'و',
  'ئ': 'ي',
  'ء': '',
};

/// Harakat, sukun, shadda, superscript alef, and tatweel.
///
/// Stripped rather than folded: they are pronunciation marks, and nobody types
/// them into a search box even when the catalogue carries them.
final _marks = RegExp('[ً-ْٰـ]');

/// Reduces a string to the form both a query and a catalogue entry share.
String foldArabic(String input) {
  final stripped = input.replaceAll(_marks, '');
  final out = StringBuffer();
  for (final ch in stripped.characters) {
    out.write(_folds[ch] ?? ch);
  }
  return out.toString().toLowerCase().trim();
}

/// Does [haystack] contain [needle], ignoring the differences above?
///
/// Substring rather than prefix: a member searching `طاولة` should find
/// `الطاولة الخضراء`, and the definite article makes prefix matching miss
/// most of an Arabic catalogue.
bool matchesArabic(String haystack, String needle) {
  final n = foldArabic(needle);
  if (n.isEmpty) return true;
  return foldArabic(haystack).contains(n);
}

extension on String {
  /// Iterating code units would split a surrogate pair; Arabic does not use
  /// any, but the catalogue carries Latin names too and a partner could yet
  /// arrive with an emoji in theirs.
  Iterable<String> get characters sync* {
    for (final rune in runes) {
      yield String.fromCharCode(rune);
    }
  }
}
