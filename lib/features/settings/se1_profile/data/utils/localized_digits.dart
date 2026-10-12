/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: localized_digits.dart
/// Purpose: Render the ASCII digits inside a string using a locale's numerals.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE1-N13. The page carried its own
/// `ArabicDigits(...).toArabicNumbers()` — a ten-entry character substitution
/// applied in three places — which is what `intl` already does, correctly, for
/// every locale rather than just Arabic. `NumberFormat`'s digit symbols are
/// compiled into intl, so unlike `DateFormat` this needs no async
/// initialization.
///
/// FIXED 25/8/2026 — this was silently a NO-OP for Arabic, which is the one
/// language it was written for. In CLDR, the generic `ar` locale's numbering
/// system is `latn`: intl's own `number_symbols_data.dart` gives
/// `"ar": NumberSymbols(... ZERO_DIGIT: '0' ...)`, so `NumberFormat` rendered
/// `2026` as `2026`. Only the regional Arabic locales — `ar_EG` among them —
/// carry `ZERO_DIGIT: '٠'` and produce `٢٠٢٦`.
///
/// So the substitution the class was created to replace really did do
/// something the passthrough did not, and every caller passing `'ar'` had been
/// getting Latin figures back since. [_resolveLocale] closes that gap.

import 'package:intl/intl.dart';

abstract class LocalizedDigits {
  /// Locale used for a language whose CLDR default numbering system is not the
  /// one this app renders in.
  ///
  /// Arabic is the only such case today: the product shows Arabic-Indic
  /// figures (٠١٢٣) throughout — see the manual converters in the roles
  /// module — while CLDR's bare `ar` is Latin-digit. `ar_EG` is the closest
  /// standard locale carrying the digits we want, and it is used here ONLY as
  /// a source of numerals; nothing about it reaches the user as a region.
  static const Map<String, String> _digitLocaleOverrides = <String, String>{
    'ar': 'ar_EG',
  };

  /// Function Name: [apply]
  ///
  /// Purpose: Rewrite every ASCII digit of [value] in [localeName]'s numerals,
  ///          leaving separators, `+` signs and letters untouched.
  ///
  /// Parameters:
  /// - [value]: e.g. `+20`, `2024/07/01`, `01001234567`.
  /// - [localeName]: an intl locale name such as `ar` or `en`. A bare `ar` is
  ///   resolved per [_digitLocaleOverrides]; anything else is used as given, so
  ///   a caller that really wants CLDR's Latin-digit Arabic can ask for
  ///   `ar_XX` explicitly.
  ///
  /// Returns: [String].
  static String apply(String value, String localeName) {
    if (value.isEmpty) return value;

    final NumberFormat digitFormat =
        NumberFormat.decimalPattern(_resolveLocale(localeName))
          ..turnOffGrouping();

    return value.splitMapJoin(
      RegExp(r'\d'),
      onMatch: (Match match) => digitFormat.format(int.parse(match[0]!)),
    );
  }

  /// The locale whose NUMERALS should be used for [localeName].
  static String _resolveLocale(String localeName) =>
      _digitLocaleOverrides[localeName.trim().toLowerCase()] ?? localeName;
}
