/// Module: core/helper
///
///*************************** FILE INFO ****************************///
/// File Name: country.dart
/// Purpose: The Country value type used by the phone and country pickers.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Split out of the oversized countries.dart.

class Country {
  final String name;
  final Map<String, String> nameTranslations;
  final String flag;
  final String code;
  final String dialCode;
  final String regionCode;
  final int minLength;
  final int maxLength;

  const Country({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
    required this.nameTranslations,
    required this.minLength,
    required this.maxLength,
    this.regionCode = "",
  });

  String get fullCountryCode {
    return dialCode + regionCode;
  }

  String get displayCC {
    if (regionCode != "") {
      return "$dialCode $regionCode";
    }
    return dialCode;
  }

  String localizedName(String languageCode) {
    return nameTranslations[languageCode] ?? name;
  }
}
