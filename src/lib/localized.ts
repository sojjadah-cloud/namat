/**
 * Content rows carry both languages side by side (`nameEn` / `nameAr`) rather
 * than a translations table — the catalogue is curated, not user-generated, and
 * both languages ship together or not at all.
 */

type Bilingual<K extends string> = {
  [P in `${K}En` | `${K}Ar`]: string | null;
};

/** `pick(provider, 'name', locale)` → the right column, English as fallback. */
export function pick<K extends string>(
  row: Bilingual<K>,
  key: K,
  locale: string,
): string {
  const ar = (row as Record<string, string | null>)[`${key}Ar`];
  const en = (row as Record<string, string | null>)[`${key}En`];
  return (locale === 'ar' ? ar || en : en || ar) ?? '';
}

/** Same, for the `String[]` columns: tags, benefits. */
export function pickList<K extends string>(
  row: { [P in `${K}En` | `${K}Ar`]: string[] },
  key: K,
  locale: string,
): string[] {
  const ar = (row as Record<string, string[]>)[`${key}Ar`];
  const en = (row as Record<string, string[]>)[`${key}En`];
  return (locale === 'ar' ? (ar?.length ? ar : en) : en?.length ? en : ar) ?? [];
}
