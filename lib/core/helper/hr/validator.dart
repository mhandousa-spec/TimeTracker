// ***************************** FILE INFO ***************************** //
// File Name: validator.dart
// Purpose: Provides centralized localized validation rules for HR features.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';

import '../main_helper/countries.dart';
import '../main_helper/phone_number.dart';

/// Restricts employee-name validation to a specific writing system.
enum HrNameScript { any, english, arabic }

/// Provides reusable validation functions for HR forms.
abstract final class HrValidator {
  /// Method Name: [required]
  ///
  /// Purpose: Rejects blank values after whitespace is removed.
  ///
  /// Parameters:
  /// - [localization]: Source of localized validation messages.
  /// - [required]: Whether an empty value is rejected.
  ///
  /// Returns: A validator for a required text value.
  static String? Function(String?) required(
    S localization, {
    bool required = true,
  }) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return required ? localization.fieldRequired : null;
      }
      return null;
    };
  }

  /// Method Name: [name]
  ///
  /// Purpose: Validates a name using letters, single spaces, and a 20-character cap.
  ///
  /// Parameters:
  /// - [localization]: Source of localized validation messages.
  /// - [required]: Whether an empty name is rejected.
  /// - [script]: Optional writing-system restriction for the name.
  ///
  /// Returns: A validator for required employee or contact names.
  static String? Function(String?) name(
    S localization, {
    bool required = true,
    HrNameScript script = HrNameScript.any,
  }) {
    final lettersAndSingleSpaces =
        RegExp(r'^\p{L}+(?: \p{L}+)*$', unicode: true);
    final englishLettersAndSingleSpaces = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
    final arabicLettersAndSingleSpaces = RegExp(
        r'^[\u0621-\u063A\u0641-\u064A]+(?: [\u0621-\u063A\u0641-\u064A]+)*$');
    final numbers = RegExp(r'\d');
    return (value) {
      final text = value ?? '';
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        return required ? localization.fieldRequired : null;
      }
      if (trimmed.length > 20) return localization.nameMaxLength;
      if (numbers.hasMatch(trimmed)) return localization.numbersNotAllowed;
      if (text != trimmed || !lettersAndSingleSpaces.hasMatch(trimmed)) {
        return localization.specialCharsNotAllowed;
      }
      if (script == HrNameScript.english &&
          !englishLettersAndSingleSpaces.hasMatch(trimmed)) {
        return localization.englishOnly;
      }
      if (script == HrNameScript.arabic &&
          !arabicLettersAndSingleSpaces.hasMatch(trimmed)) {
        return localization.arabicOnly;
      }
      return null;
    };
  }

  /// Method Name: [email]
  ///
  /// Purpose: Validates a required email address.
  ///
  /// Parameters:
  /// - [localization]: Source of localized validation messages.
  ///
  /// Returns: A validator for email inputs.
  static String? Function(String?) email(
    S localization, {
    bool required = true,
  }) {
    final expression = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) {
        return required ? localization.fieldRequired : null;
      }
      return expression.hasMatch(text) ? null : localization.validEmailRequired;
    };
  }

  /// Method Name: [number]
  ///
  /// Purpose: Validates required number-only values up to the requested limit.
  ///
  /// Parameters:
  /// - [localization]: Source of localized validation messages.
  /// - [maxLength]: Maximum number of digits accepted by the value.
  ///
  /// Returns: A validator for number-only fields.
  static String? Function(String?) number(
    S localization, {
    bool required = true,
    int maxLength = 10,
  }) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) {
        return required ? localization.fieldRequired : null;
      }
      if (!RegExp(r'^\d+$').hasMatch(text)) {
        return localization.onlyNumbersAllowed;
      }
      return text.length <= maxLength ? null : localization.numberMaxLength;
    };
  }

  /// Method Name: [requiredSelection]
  ///
  /// Purpose: Validates required dropdown, date, time, and file values.
  ///
  /// Parameters:
  /// - [value]: The selected value to validate.
  /// - [localization]: Source of localized validation messages.
  ///
  /// Returns: A localized error when no value is selected.
  static String? requiredSelection(Object? value, S localization) {
    return value == null || (value is String && value.trim().isEmpty)
        ? localization.fieldRequired
        : null;
  }

  /// Method Name: [employeeId]
  ///
  /// Purpose: Validates an alphanumeric employee identifier used by imports.
  ///
  /// Returns: A localized validation error or null.
  static String? employeeId(String? value, S localization) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return localization.fieldRequired;
    return RegExp(r'^[A-Za-z0-9]{1,20}$').hasMatch(text)
        ? null
        : localization.invalidEmployeeId;
  }

  /// Method Name: [exactDate]
  ///
  /// Purpose: Validates an exact ISO calendar date and optional boundaries.
  ///
  /// Returns: A localized validation error or null.
  static String? exactDate(
    String? value,
    S localization, {
    bool required = true,
    DateTime? minimum,
    DateTime? maximum,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? localization.fieldRequired : null;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
      return localization.invalidDate;
    }
    final parsed = DateTime.tryParse(text);
    if (parsed == null || parsed.toIso8601String().split('T').first != text) {
      return localization.invalidDate;
    }
    if (minimum != null && parsed.isBefore(minimum)) {
      return localization.invalidDate;
    }
    if (maximum != null && parsed.isAfter(maximum)) {
      return localization.invalidDate;
    }
    return null;
  }

  /// Method Name: [nationalId]
  ///
  /// Purpose: Validates the established 9-to-14 digit employee ID range.
  ///
  /// Returns: A localized validation error or null.
  static String? nationalId(String? value, S localization) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return localization.fieldRequired;
    return RegExp(r'^\d{9,14}$').hasMatch(text)
        ? null
        : localization.employeeBulkInvalidNationalId;
  }

  /// Method Name: [passport]
  ///
  /// Purpose: Validates an optional 8-to-11 character passport number.
  ///
  /// Returns: A localized validation error or null.
  static String? passport(String? value, S localization) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return RegExp(r'^[A-Za-z0-9]{8,11}$').hasMatch(text)
        ? null
        : localization.employeeBulkInvalidPassport;
  }

  /// Method Name: [internationalPhone]
  ///
  /// Purpose: Validates an international or Egyptian national phone value.
  ///
  /// Returns: A localized validation error or null.
  static String? internationalPhone(
    String? value,
    S localization, {
    bool required = true,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? localization.fieldRequired : null;
    return parseInternationalPhone(text) == null
        ? localization.invalidPhoneNumber
        : null;
  }

  /// Method Name: [parseInternationalPhone]
  ///
  /// Purpose: Parses an international value or an Egyptian national number.
  ///
  /// Returns: A separated country code and national number, or null.
  static PhoneNumber? parseInternationalPhone(String? value) {
    var compact = value?.replaceAll(RegExp(r'[\s()-]'), '') ?? '';
    if (compact.startsWith('00')) compact = '+${compact.substring(2)}';
    if (!RegExp(r'^\+?\d+$').hasMatch(compact)) return null;

    if (!compact.startsWith('+')) {
      final national = compact.startsWith('0') ? compact.substring(1) : compact;
      final egypt = countries.firstWhere((country) => country.code == 'EG');
      if (national.length < 8 || national.length > egypt.maxLength) {
        return null;
      }
      return PhoneNumber(
        countryISOCode: egypt.code,
        countryCode: '+${egypt.fullCountryCode}',
        number: national,
        countryApp: egypt.code,
      );
    }

    final digits = compact.substring(1);
    final candidates = countries.where((country) {
      final code = country.fullCountryCode;
      if (!digits.startsWith(code)) return false;
      final nationalLength = digits.length - code.length;
      return nationalLength >= country.minLength &&
          nationalLength <= country.maxLength;
    }).toList()
      ..sort((a, b) =>
          b.fullCountryCode.length.compareTo(a.fullCountryCode.length));
    if (candidates.isEmpty) return null;
    final country = candidates.first;
    return PhoneNumber(
      countryISOCode: country.code,
      countryCode: '+${country.fullCountryCode}',
      number: digits.substring(country.fullCountryCode.length),
      countryApp: country.code,
    );
  }
}
