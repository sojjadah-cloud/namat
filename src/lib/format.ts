/**
 * Locale-aware formatting. Arabic uses Arabic-Indic digits and Omani rial
 * conventions (3 decimals, but trimmed when the price is whole).
 */

const CURRENCY_BY_COUNTRY: Record<string, string> = {
  OM: 'OMR',
  AE: 'AED',
  SA: 'SAR',
  BH: 'BHD',
  KW: 'KWD',
  QA: 'QAR',
};

export function currencyFor(countryCode = 'OM') {
  return CURRENCY_BY_COUNTRY[countryCode] ?? 'OMR';
}

/** "ar" defaults to Latin digits; "ar-OM" is what gives Arabic-Indic. */
export function intlLocale(locale: string) {
  return locale === 'ar' ? 'ar-OM' : 'en-OM';
}

/** "8 OMR" / "٨ ر.ع" — narrow symbol, no trailing zero noise. */
export function formatPrice(value: number, locale: string, currency = 'OMR') {
  const whole = Number.isInteger(value);
  return new Intl.NumberFormat(intlLocale(locale), {
    style: 'currency',
    currency,
    currencyDisplay: 'narrowSymbol',
    minimumFractionDigits: whole ? 0 : 3,
    maximumFractionDigits: 3,
  }).format(value);
}

export function formatNumber(value: number, locale: string) {
  return new Intl.NumberFormat(intlLocale(locale)).format(value);
}

/** 1.4 km / ١.٤ كم */
export function formatDistance(km: number, locale: string) {
  const n = new Intl.NumberFormat(intlLocale(locale), {
    maximumFractionDigits: 1,
  }).format(km);
  return locale === 'ar' ? `${n} كم` : `${n} km`;
}

export function formatDuration(minutes: number, locale: string) {
  const n = formatNumber(minutes, locale);
  return locale === 'ar' ? `${n} دقيقة` : `${n} min`;
}

/** "6:00 PM" / "٦:٠٠ م" */
export function formatTime(date: Date, locale: string) {
  return new Intl.DateTimeFormat(intlLocale(locale), {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  }).format(date);
}

/** "Thursday 21 August" / "الخميس ٢١ أغسطس" */
export function formatDateLong(date: Date, locale: string) {
  return new Intl.DateTimeFormat(intlLocale(locale), {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }).format(date);
}

export function formatDateShort(date: Date, locale: string) {
  return new Intl.DateTimeFormat(intlLocale(locale), {
    day: 'numeric',
    month: 'short',
  }).format(date);
}

export function formatWeekday(date: Date, locale: string) {
  return new Intl.DateTimeFormat(intlLocale(locale), { weekday: 'short' }).format(date);
}

export function formatDayNumber(date: Date, locale: string) {
  return new Intl.DateTimeFormat(intlLocale(locale), { day: 'numeric' }).format(date);
}

/** "12–18 August" / "١٢–١٨ أغسطس" for the journey week header. */
export function formatDateRange(start: Date, end: Date, locale: string) {
  const fmt = new Intl.DateTimeFormat(intlLocale(locale), {
    day: 'numeric',
    month: 'long',
  });
  if (typeof fmt.formatRange === 'function') return fmt.formatRange(start, end);
  return `${fmt.format(start)} – ${fmt.format(end)}`;
}

/** Which greeting to show, based on the visitor's local hour. */
export function greetingKey(hour: number) {
  if (hour < 12) return 'greetingMorning' as const;
  if (hour < 17) return 'greetingAfternoon' as const;
  return 'greetingEvening' as const;
}

/** Which part of the day a slot falls into, for grouping times. */
export function partOfDay(date: Date): 'MORNING' | 'AFTERNOON' | 'EVENING' {
  const h = date.getHours();
  if (h < 12) return 'MORNING';
  if (h < 17) return 'AFTERNOON';
  return 'EVENING';
}

/**
 * Calendar arithmetic lives in `time.ts`, which does it in Oman time rather
 * than the server's. These re-exports keep the existing call sites working;
 * the previous local copies used the server timezone and so disagreed with the
 * challenge system about where a day ends.
 */
export {
  daysBetween,
  isSameDay,
  isToday,
  addDays,
  startOfWeek,
  omanDate,
  MS_PER_DAY,
} from './time';

/**
 * Phone numbers as a reader sees them, not as a dialler stores them:
 * "+968 9123 4567" in English, "+٩٦٨ ٩١٢٣ ٤٥٦٧" in Arabic.
 *
 * Identifiers that someone has to read back to a human — the booking
 * reference, the code typed into the OTP field — deliberately stay Latin,
 * because they are transcribed rather than read.
 */
export function formatPhone(phone: string, locale: string) {
  const digits = phone.replace(/[^\d]/g, '');
  const grouped =
    digits.length > 3
      ? `+${digits.slice(0, 3)} ${digits.slice(3).replace(/(\d{4})(?=\d)/g, '$1 ')}`
      : `+${digits}`;

  if (locale !== 'ar') return grouped;

  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  return grouped.replace(/\d/g, (d) => arabicIndic[Number(d)]);
}
