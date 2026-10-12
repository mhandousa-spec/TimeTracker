// ***************************** FILE INFO ***************************** //
// File Name: employee_details_phone_formatter.dart
// Purpose: Formats employee phone values for read-only display.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

/// Display-only phone formatting helpers for the employee details header.
abstract final class EmployeeDetailsPhoneFormatter {
  /// Method Name: [format]
  ///
  /// Purpose: Removes persisted presentation artifacts and formats the
  /// country code as an international display prefix.
  ///
  /// Parameters:
  /// - [countryCode]: Stored country-code value.
  /// - [number]: Stored national phone number.
  ///
  /// Returns: A normalized phone display value without changing persistence.
  static String format({String? countryCode, String? number}) {
    final code = _clean(countryCode);
    final phone = _clean(number);
    if (code.isEmpty) return phone;
    final internationalCode = '+${code.replaceFirst(RegExp(r'^\++'), '')}';
    return phone.isEmpty ? internationalCode : '$internationalCode $phone';
  }

  static String _clean(String? value) =>
      (value ?? '').replaceAll(RegExp(r'[\[\]\s]'), '').trim();
}
