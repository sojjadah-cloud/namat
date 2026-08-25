/**
 * Arabic text normalisation for search.
 *
 * Arabic is written with several characters that readers treat as the same
 * letter and typists produce inconsistently. Someone hunting for "أطلس" will
 * type "اطلس", because the plain alef is one key and the hamza forms are
 * three. A raw substring match returns nothing, and the member concludes the
 * gym is not on NAMAT.
 *
 * The transformations are all lossy on purpose — this output is only ever a
 * search key, never something displayed. Display always uses the original.
 *
 * Deliberately NOT handled: the definite article. "طاولة" already matches
 * "الطاولة الخضراء" under substring search, so stripping "ال" would only
 * create false positives on words that legitimately begin with those letters.
 */

/** Combining marks: fathatan…sukun, superscript alef, and the tatweel filler. */
const DIACRITICS = /[ً-ْٰـ]/g;

/** Arabic-Indic and extended Arabic-Indic digits, in value order. */
const ARABIC_DIGITS = '٠١٢٣٤٥٦٧٨٩';
const EXTENDED_DIGITS = '۰۱۲۳۴۵۶۷۸۹';

const LETTER_FOLDS: Array<[RegExp, string]> = [
  // Every alef carrier folds to the bare alef.
  [/[أإآٱ]/g, 'ا'], // أ إ آ ٱ → ا
  // Teh marbuta and heh are interchangeable word-finally in practice.
  [/ة/g, 'ه'], // ة → ه
  // Alef maksura is written for final yeh as often as not.
  [/ى/g, 'ي'], // ى → ي
  // Hamza carriers fold to their base letter.
  [/ؤ/g, 'و'], // ؤ → و
  [/ئ/g, 'ي'], // ئ → ي
];

/**
 * Fold a string to its search key: case-flattened, diacritic-free, with
 * interchangeable letter forms unified, digits in Latin, and whitespace
 * collapsed. Safe on Latin text, which passes through lowercased.
 */
export function normalizeArabic(input: string): string {
  let out = input.normalize('NFKC').toLowerCase();

  out = out.replace(DIACRITICS, '');

  for (const [pattern, replacement] of LETTER_FOLDS) {
    out = out.replace(pattern, replacement);
  }

  // A search for "٤" and a search for "4" should reach the same rows.
  out = out.replace(/[٠-٩]/g, (d) => String(ARABIC_DIGITS.indexOf(d)));
  out = out.replace(/[۰-۹]/g, (d) => String(EXTENDED_DIGITS.indexOf(d)));

  // Arabic keyboards produce a mix of spaces, and pasted text carries more.
  return out.replace(/\s+/g, ' ').trim();
}

/**
 * The SQL that must produce the same key inside Postgres, used by the
 * generated columns the search index is built on.
 *
 * It has to stay in step with `normalizeArabic`: if the two disagree, a query
 * normalised in TypeScript will not match a column normalised in SQL, and the
 * failure is silent — searches simply return less than they should. The test
 * suite compares the two implementations over the seed corpus for that reason.
 *
 * `translate` deletes any source character with no positional counterpart in
 * the destination string, which is how the diacritics are dropped.
 */
export const NORMALIZE_SQL = (column: string) => `
  regexp_replace(
    translate(
      lower(${column}),
      'أإآٱةىؤئ٠١٢٣٤٥٦٧٨٩ًٌٍَُِّْٰـ',
      'ااااهيوي0123456789'
    ),
    '\\s+', ' ', 'g'
  )
`;
