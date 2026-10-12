/// Module: services_app_module/create
///
/// FILE INFO
/// File Name   : country_parse_helper.dart
/// Objective   : Safe country-code parsing with an Egypt fallback. Keeps
///               try/catch out of UI widgets (§11.2) — parsing safety lives
///               in this util where try/catch is allowed (§11.1).
library;

import 'package:country_picker/country_picker.dart';

abstract class CountryParseHelper {
  /// Parses [countryCode] into a [Country], falling back to Egypt (EG)
  /// when the code is null/empty or cannot be parsed.
  static Country parseCountrySafely(String? countryCode) {
    if (countryCode != null && countryCode.isNotEmpty) {
      try {
        return CountryParser.parseCountryCode(countryCode);
      } catch (_) {
        // fall through to the default below
      }
    }

    try {
      return CountryParser.parseCountryCode('EG');
    } catch (_) {
      return Country(
        phoneCode: '20',
        countryCode: 'EG',
        e164Sc: 0,
        geographic: true,
        level: 1,
        name: 'Egypt',
        example: '1001234567',
        displayName: 'Egypt (EG) [+20]',
        displayNameNoCountryCode: 'Egypt (EG)',
        e164Key: '',
      );
    }
  }
}
