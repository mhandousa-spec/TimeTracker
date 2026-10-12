/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: phone_country_lookup.dart
/// Purpose: Resolve an employee's stored phone country code into a flag and a
///          dial code for display.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE1-N12. `_getCountryFlag` / `_getDialCode` lived on the
/// ContactInformation State with a `try/catch` each (forbidden in
/// presentation/ui/, §11.2). The try/catch existed only because the nested
/// `firstWhere(... orElse: () => countries.firstWhere(...))` could itself throw
/// when the fallback was missing; a null-returning lookup removes the need for
/// it entirely.
///
/// Note the original matched the *stored country code* against `Country.dialCode`
/// — comparing "EG" to "20" — so it always fell through to the Egyptian
/// default. This matches on `Country.code` first (what is actually stored) and
/// still accepts a dial code, so records that stored one keep working.

import 'package:knowticed_plus/core/helper/main_helper/countries.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';

abstract class PhoneCountryLookup {
  /// Function Name: [find]
  ///
  /// Purpose: Look a country up by ISO code (e.g. `EG`) or dial code (`20`).
  ///
  /// Returns: [Country?] — `null` when nothing matches.
  static Country? find(String codeOrDialCode) {
    final String needle = codeOrDialCode.trim().replaceFirst('+', '');
    if (needle.isEmpty) return null;

    for (final Country country in countries) {
      if (country.code.toUpperCase() == needle.toUpperCase()) return country;
    }
    for (final Country country in countries) {
      if (country.dialCode == needle) return country;
    }
    return null;
  }

  /// Function Name: [flagOf]
  ///
  /// Purpose: Flag emoji for a stored country code, falling back to the app
  ///          default country.
  static String flagOf(String codeOrDialCode) =>
      (find(codeOrDialCode) ?? _fallback)?.flag ?? '';

  /// Function Name: [dialCodeOf]
  ///
  /// Purpose: `+`-prefixed dial code for a stored country code.
  static String dialCodeOf(String codeOrDialCode) {
    final Country? country = find(codeOrDialCode) ?? _fallback;
    return country == null ? '' : '+${country.dialCode}';
  }

  static Country? get _fallback => find(PersonalProfile.defaultCountryCode);
}
