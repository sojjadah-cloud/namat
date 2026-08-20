/**
 * The verification text, in the language the person is reading the app in.
 *
 * Pure and free of `server-only` so it can be unit-tested directly; the
 * provider plumbing around it is what needs the server guard.
 *
 * The code is wrapped in Unicode isolates so an RTL message renders it as a
 * single left-to-right run: without them the handset can reorder "123456"
 * around the surrounding Arabic. The digits stay Latin because that is what
 * the keypad types.
 */
export function verificationBody(code: string, locale: string) {
  return locale === 'ar'
    ? `رمز تحقق نمط: \u2066${code}\u2069\nصالح لمدة ٥ دقائق. لا تشاركه مع أحد.`
    : `Your NAMAT code is ${code}.\nIt expires in 5 minutes. Do not share it.`;
}
