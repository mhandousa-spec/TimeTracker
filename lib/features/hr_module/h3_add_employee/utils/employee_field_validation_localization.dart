// ***************************** FILE INFO ***************************** //
// File Name: employee_field_validation_localization.dart
// Purpose: Provides language-fixed validation messages for bilingual fields.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';
import '../../../../../../generated/intl/messages_ar.dart' as arabic_messages;
import '../../../../../../generated/intl/messages_en.dart' as english_messages;

/// Supplies validation messages in the language assigned to a form field.
class EmployeeFieldValidationLocalization extends S {
  EmployeeFieldValidationLocalization._(this._locale);

  final String _locale;

  /// Method Name: [englishMessages]
  ///
  /// Purpose: Creates a validator message source fixed to English.
  static S englishMessages() => EmployeeFieldValidationLocalization._('en');

  /// Method Name: [arabicMessages]
  ///
  /// Purpose: Creates a validator message source fixed to Arabic.
  static S arabicMessages() => EmployeeFieldValidationLocalization._('ar');

  String _message(String fallback, String key) {
    final lookup =
        _locale == 'ar' ? arabic_messages.messages : english_messages.messages;
    return lookup.lookupMessage(fallback, _locale, key, const [], null) ??
        fallback;
  }

  @override
  String get fieldRequired => _message(
        'This field is required.',
        'fieldRequired',
      );

  @override
  String get nameMaxLength => _message(
        'Names cannot exceed 20 characters.',
        'nameMaxLength',
      );

  @override
  String get numbersNotAllowed => _message(
        'Numbers are not allowed.',
        'numbersNotAllowed',
      );

  @override
  String get specialCharsNotAllowed => _message(
        'Special characters are not allowed.',
        'specialCharsNotAllowed',
      );

  @override
  String get englishOnly => _message(
        'English letters only',
        'englishOnly',
      );

  @override
  String get arabicOnly => _message(
        'Arabic letters only',
        'arabicOnly',
      );
}
