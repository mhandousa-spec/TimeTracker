/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: employee_date_formatter.dart
/// Purpose: Parse and format the birthday value stored on an employee.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE1-N12 / N13. `formatDate` used to live on a
/// StatelessWidget in presentation/ui/ with a `try/catch` inside it (forbidden,
/// §11.2) and a `print()` in the catch. `DateFormat.parseStrict` is the only
/// call here that throws, so the exception handling belongs to this layer and
/// the widgets just call [parse] / [format].

import 'package:intl/intl.dart';

import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';

abstract class EmployeeDateFormatter {
  /// The shape the birthday is *written* in. Reads accept the older shapes too,
  /// because existing documents contain all of them.
  static const String storagePattern = 'yyyy/MM/dd';

  /// The shape a date is *shown* in: `23 Aug 2023`. Deliberately different from
  /// [storagePattern] — what is written must stay machine-parsable and stable
  /// across locales, what is read by a person must be unambiguous.
  static const String displayPattern = 'dd MMM yyyy';

  static const List<String> _readPatterns = <String>[
    storagePattern,
    'dd/MM/yyyy',
    'dd MMM yyyy',
    'MMM dd, yyyy',
  ];

  /// Function Name: [parse]
  ///
  /// Purpose: Turn a stored birthday into a [DateTime].
  ///
  /// Parameters:
  /// - [raw]: the value as stored (ISO, `yyyy/MM/dd`, `dd/MM/yyyy`,
  ///   `dd MMM yyyy` or `MMM dd, yyyy`).
  ///
  /// Returns: [DateTime?] — `null` when [raw] is empty or matches no pattern.
  static DateTime? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final String value = raw.trim();

    final DateTime? iso = DateTime.tryParse(value);
    if (iso != null) return iso;

    for (final String pattern in _readPatterns) {
      try {
        // Pinned to 'en'. Stored values always use ASCII digits and English
        // month abbreviations, but `Intl.defaultLocale` is set to 'ar' for
        // Arabic users — so an unpinned DateFormat would try to read them with
        // Arabic-Indic digits and fail on every pattern.
        return DateFormat(pattern, 'en').parseStrict(value);
      } on FormatException {
        // Expected: this is how the pattern list is walked. Only a
        // FormatException is caught, so a real bug still surfaces.
        continue;
      }
    }
    return null;
  }

  /// Function Name: [format]
  ///
  /// Purpose: Render a date for display in the given locale.
  ///
  /// Parameters:
  /// - [date]: the value to render.
  /// - [localeName]: an intl locale name, e.g. `ar` or `en`. Arabic locales get
  ///   Arabic-Indic digits from `intl` itself — the hand-rolled `ArabicDigits`
  ///   string replacement it replaces was flagged as reinventing intl
  ///   (CR-SKEL-SE1-N13).
  ///
  /// Returns: [String].
  ///
  /// CHANGED 8/9/2026 — display is now [displayPattern] ("23 Aug 2023"), not
  /// [storagePattern]. The two were the same string, which is why the personal
  /// information page showed a birthday as `1977/11/12`: an all-numeric date
  /// whose field order a reader has to guess. Storage is unaffected — see
  /// [toStorage] — and [parse] already accepted `dd MMM yyyy` on the way back
  /// in, so nothing that was written before needs migrating.
  ///
  /// The month name follows the locale, so Arabic renders as `٢٣ أغسطس ٢٠٢٣`.
  /// That is safe here: main() runs `AppBarDate.ensureDateFormattingInitialized()`
  /// at start-up, which loads intl date symbols for every supported locale.
  /// Only the language subtag is passed on — a full tag such as `ar-EG` has no
  /// symbol data of its own and would rely on intl's fallback.
  ///
  /// [LocalizedDigits] still runs afterwards; where intl has already produced
  /// Arabic-Indic digits it finds no ASCII digits left and returns the string
  /// unchanged.
  static String format(DateTime date, {String? localeName}) {
    if (localeName == null) {
      return DateFormat(displayPattern, 'en').format(date);
    }

    final String language = localeName.split(RegExp('[-_]')).first;
    final String formatted =
        DateFormat(displayPattern, language == 'ar' ? 'ar' : 'en').format(date);

    return LocalizedDigits.apply(formatted, localeName);
  }

  /// Function Name: [toStorage]
  ///
  /// Purpose: Render a date in the machine-readable storage shape, so a value
  ///          written back is always parseable by [parse] regardless of locale.
  ///
  /// Returns: [String?] — `null` when the date was cleared, which is how the
  ///          controller distinguishes "not edited" from "edited to empty".
  static String? toStorage(DateTime? date) =>
      date == null ? null : DateFormat(storagePattern, 'en').format(date);
}
