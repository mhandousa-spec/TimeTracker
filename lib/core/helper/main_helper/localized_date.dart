/// Module: core/helper/main_helper
///
///*************************** FILE INFO ****************************///
/// File Name: localized_date.dart
/// Purpose: Render a date using the active locale's month names AND numerals.
/// Author: Knowticed Plus team
/// Created at: 29/8/2026
///
/// Added because `DateFormat('dd MMM yyyy', 'ar').format(...)` gives Arabic
/// month names but Latin digits — "29 أغسطس 2026" — so every date on an Arabic
/// screen mixed the two numbering systems while the counts beside it, which go
/// through [LocalizedNumber], were already Arabic-Indic.
///
/// Why the digits are mapped here rather than left to intl: which numbering
/// system CLDR hands a bare `ar` has moved between intl releases, and an
/// unrecognised locale tag silently falls back to `en` instead of throwing —
/// the same reasoning [LocalizedNumber.forLocale] documents for numbers. The
/// map is a no-op on a build that already emits Arabic-Indic digits, since
/// there is then nothing Latin left to replace.
///
/// ⚠️ Display only. Never parse or store the result — Arabic-Indic digits do
/// not round-trip through `DateTime.parse` or a Firestore query.

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';

abstract final class LocalizedDate {
  const LocalizedDate._();

  /// Function Name: [of]
  ///
  /// Purpose: [date] formatted with [pattern] in the locale currently in the
  ///          tree — "29 Aug 2026" in English, "٢٩ أغسطس ٢٠٢٦" in Arabic.
  ///
  /// Parameters:
  /// - [context]: Supplies the active locale.
  /// - [date]: The date to render.
  /// - [pattern]: An intl date pattern; defaults to `dd MMM yyyy`.
  static String of(
    BuildContext context,
    DateTime date, {
    String pattern = 'dd MMM yyyy',
  }) =>
      forLocale(
        date,
        Localizations.localeOf(context).languageCode,
        pattern: pattern,
      );

  /// Function Name: [forLocale]
  ///
  /// Purpose: As [of], for callers that already know the locale name and have
  ///          no BuildContext to hand.
  static String forLocale(
    DateTime date,
    String localeName, {
    String pattern = 'dd MMM yyyy',
  }) {
    final bool isArabic = localeName.toLowerCase().startsWith('ar');
    final String formatted =
        DateFormat(pattern, isArabic ? 'ar' : 'en').format(date);

    return isArabic ? formatted.toArabicNumbers() : formatted;
  }

  /// Function Name: [ofStored]
  ///
  /// Purpose: Render one of the date STRINGS this app persists (access grant /
  ///          revoke dates and the like) in the active locale.
  ///
  /// Why a parser is needed at all: those fields are stored as text, not as a
  /// Timestamp, and the canonical shape is
  /// `Constants.userAccessDateFormat` — "MMM dd, yyyy" in English. Rows written
  /// by older builds carry ISO-8601, `dd/MM/yyyy`, or a named month in either
  /// language, which is why the repository ships its own `parseAccessDate`.
  /// [parseStored] accepts the same set.
  ///
  /// Returns [fallback] (default `-`) for null, empty or unparseable input, so
  /// a screen never paints a raw storage string at the user.
  static String ofStored(
    BuildContext context,
    String? stored, {
    String pattern = 'dd MMM yyyy',
    String fallback = '-',
  }) {
    final DateTime? parsed = parseStored(stored);
    if (parsed == null) return fallback;

    return of(context, parsed, pattern: pattern);
  }

  /// Function Name: [parseStored]
  ///
  /// Purpose: Read a persisted date string in any shape this app has written
  ///          one, newest convention first. Null when nothing matches — the
  ///          caller decides what to show instead.
  ///
  /// ⚠️ Parsing only. Write dates back with the canonical
  /// `DateFormat(Constants.userAccessDateFormat, 'en')`, never with a localized
  /// formatter: the stored value is on-disk vocabulary, not display text.
  static DateTime? parseStored(String? stored) {
    if (stored == null) return null;

    final String value = stored.trim();
    if (value.isEmpty || value == '-') return null;

    // Arabic-Indic digits are normalised away first: a value that was DISPLAYED
    // in Arabic and saved back ("٢٥ فبراير ٢٠٢٧") is the same date as its
    // Latin-digit twin, and intl parses digits by the locale's own symbols.
    final String latinDigits = _toLatinDigits(value);

    // ISO-8601 first: unambiguous, and what `DateTime.toString()` writes.
    final DateTime? iso = DateTime.tryParse(latinDigits);
    if (iso != null) return iso;

    const List<String> patterns = <String>[
      'MMM dd, yyyy', // Constants.userAccessDateFormat — the canonical one
      'MMM d, yyyy',
      'dd MMM yyyy',
      'd MMM yyyy',
      'MMMM dd, yyyy',
      'dd MMMM yyyy',
      'dd/MM/yyyy',
      'd/M/yyyy',
    ];

    // English on the normalised digits — that is what the writers use.
    final DateTime? english = _tryPatterns(latinDigits, 'en', patterns);
    if (english != null) return english;

    // Arabic on the ORIGINAL, for a row saved whole in Arabic: intl's `ar`
    // expects that locale's own digits, so it must not see the normalised copy.
    final DateTime? arabic = _tryPatterns(value, 'ar', patterns);
    if (arabic != null) return arabic;

    // Last: an Arabic MONTH beside Latin digits ("فبراير 25, 2027") — neither
    // locale parses that mix, and it is exactly what an older build wrote when
    // it localized a value on its way to storage. Swap the month name for its
    // English abbreviation and try once more.
    final String monthTranslated = _arabicMonthsToEnglish(latinDigits);
    if (monthTranslated != latinDigits) {
      return _tryPatterns(monthTranslated, 'en', patterns);
    }

    return null;
  }

  static DateTime? _tryPatterns(
    String value,
    String locale,
    List<String> patterns,
  ) {
    for (final String pattern in patterns) {
      try {
        return DateFormat(pattern, locale).parseStrict(value);
      } on FormatException {
        // Not this shape; try the next.
      }
    }
    return null;
  }

  static String _toLatinDigits(String value) {
    const int arabicIndicZero = 0x0660;
    const int asciiZero = 0x30;

    return String.fromCharCodes(
      value.runes.map((int rune) =>
          (rune >= arabicIndicZero && rune <= arabicIndicZero + 9)
              ? asciiZero + (rune - arabicIndicZero)
              : rune),
    );
  }

  /// Arabic month names → the English abbreviations intl parses. Both the
  /// hamza'd and bare spellings appear in stored data, hence the pairs.
  static const Map<String, String> _arabicMonths = <String, String>{
    'يناير': 'Jan',
    'فبراير': 'Feb',
    'مارس': 'Mar',
    'أبريل': 'Apr',
    'ابريل': 'Apr',
    'مايو': 'May',
    'يونيو': 'Jun',
    'يونية': 'Jun',
    'يوليو': 'Jul',
    'يولية': 'Jul',
    'أغسطس': 'Aug',
    'اغسطس': 'Aug',
    'سبتمبر': 'Sep',
    'أكتوبر': 'Oct',
    'اكتوبر': 'Oct',
    'نوفمبر': 'Nov',
    'ديسمبر': 'Dec',
  };

  static String _arabicMonthsToEnglish(String value) {
    String result = value;
    _arabicMonths.forEach((String arabic, String english) {
      result = result.replaceAll(arabic, english);
    });
    return result;
  }
}
