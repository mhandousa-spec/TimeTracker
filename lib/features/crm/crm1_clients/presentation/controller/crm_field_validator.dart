// ****************** FILE INFO ******************
// File Name: crm_field_validator.dart
// Purpose: Shared dynamic CRM field validation (required, max length,
//          bilingual language, type regex) used by the client form Cubit and
//          the bulk upload page
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Static validation helpers for dynamic template fields.
///
/// Localized messages receive the locale explicitly through [isArabic];
/// English/Arabic user strings never leak into the domain layer.
class CrmFieldValidator {
  CrmFieldValidator._();

  /// Validates a single dynamic field based on its template metadata.
  ///
  /// Covers required, max characters and validation-type (email/phone/url)
  /// rules. Returns a localized error string or null when the value is valid.
  static String? validate(
    CrmTemplateFieldModel field,
    dynamic value, {
    bool isArabic = false,
  }) {
    final String type = field.fieldTypeId.toLowerCase();
    final String validationType = field.validationType.toLowerCase();

    // 1. Required check.
    if (field.isRequired) {
      final bool isEmpty = _isFieldValueEmpty(field, value);
      if (isEmpty) {
        return requiredFieldMessage(field, isArabic: isArabic);
      }
    }

    // 2. Max characters check.
    if (field.maxCharacters != null) {
      final bool exceedsMaxLength = _textValues(value).any(
        (String text) => text.length > field.maxCharacters!,
      );
      if (exceedsMaxLength) {
        return isArabic
            ? 'تجاوز الحد الأقصى (${field.maxCharacters})'
            : 'Maximum ${field.maxCharacters} characters';
      }
    }

    // 3. Bilingual text language check.
    final String? languageError = _validateBilingualTextLanguage(
      field,
      value,
      isArabic: isArabic,
    );
    if (languageError != null) return languageError;

    // 4. Regex/validation type check.
    for (final String textValue in _textValues(value)) {
      if (textValue.isEmpty) continue;
      if (type == 'email' || validationType == 'email') {
        if (Validator.emailLocalized(textValue) != null) {
          return S.current.invalidEmail;
        }
      } else if (type == 'phone' || validationType == 'phone') {
        if (Validator.number(textValue) != null) {
          return S.current.invalidPhoneNumber;
        }
      } else if (type == 'link' ||
          type == 'website' ||
          validationType == 'url') {
        if (!Validator.isValidLink(textValue)) {
          return S.current.crmInvalidUrl;
        }
      }
    }

    return null;
  }

  /// Validates a field and returns a map of error entries keyed by the field
  /// id (or per-language keys for bilingual fields).
  static Map<String, String> validateErrorEntries(
    CrmTemplateFieldModel field,
    dynamic value, {
    bool isArabic = false,
  }) {
    if (field.showBothLanguages && isBilingualTextField(field)) {
      return _validateBilingualTextFieldEntries(field, value);
    }
    final String? error = validate(field, value, isArabic: isArabic);
    return error == null
        ? const <String, String>{}
        : <String, String>{field.id: error};
  }

  /// True when the field renders two separate English/Arabic text inputs.
  static bool isBilingualTextField(CrmTemplateFieldModel field) {
    final String type = field.fieldTypeId.toLowerCase();
    return type == 'text' || type == 'description' || type.isEmpty;
  }

  /// Localized required-message using the field's custom error text first,
  /// falling back to the app's localized default.
  static String requiredFieldMessage(
    CrmTemplateFieldModel field, {
    required bool isArabic,
  }) {
    final String englishMessage = field.errorMessageEn.trim();
    final String arabicMessage = field.errorMessageAr.trim();
    if (isArabic && arabicMessage.isNotEmpty) return arabicMessage;
    if (!isArabic && englishMessage.isNotEmpty) return englishMessage;
    if (englishMessage.isNotEmpty) return englishMessage;
    if (arabicMessage.isNotEmpty) return arabicMessage;
    return isArabic ? S.current.crmFieldRequiredAr : S.current.crmFieldRequired;
  }

  /// Error key used for the English input of a bilingual field.
  static String englishKey(String fieldId) => '${fieldId}__en';

  /// Error key used for the Arabic input of a bilingual field.
  static String arabicKey(String fieldId) => '${fieldId}__ar';

  /// Returns a localized error when the English input contains Arabic text.
  static String? englishLanguageError(String englishText) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(englishText)
        ? 'Please enter English text in the English field'
        : null;
  }

  /// Returns a localized error when the Arabic input contains English text.
  static String? arabicLanguageError(String arabicText) {
    return RegExp(r'[a-zA-Z]').hasMatch(arabicText)
        ? 'الحقل العربي يجب أن يكون بالعربية'
        : null;
  }

  static Map<String, String> _validateBilingualTextFieldEntries(
    CrmTemplateFieldModel field,
    dynamic value,
  ) {
    final Map<String, String> errors = <String, String>{};
    final Map<String, String> values = _bilingualTextValues(value);
    final String english = values['en'] ?? '';
    final String arabic = values['ar'] ?? '';

    if (field.isRequired) {
      if (english.trim().isEmpty) {
        errors[englishKey(field.id)] =
            requiredFieldMessage(field, isArabic: false);
      }
      if (arabic.trim().isEmpty) {
        errors[arabicKey(field.id)] =
            requiredFieldMessage(field, isArabic: true);
      }
    }

    if (field.maxCharacters != null) {
      if (english.length > field.maxCharacters!) {
        errors[englishKey(field.id)] =
            'Maximum ${field.maxCharacters} characters';
      }
      if (arabic.length > field.maxCharacters!) {
        errors[arabicKey(field.id)] =
            'تجاوز الحد الأقصى (${field.maxCharacters})';
      }
    }

    final String? englishError = englishLanguageError(english);
    if (englishError != null) {
      errors[englishKey(field.id)] = englishError;
    }
    final String? arabicError = arabicLanguageError(arabic);
    if (arabicError != null) {
      errors[arabicKey(field.id)] = arabicError;
    }

    return errors;
  }

  static String? _validateBilingualTextLanguage(
    CrmTemplateFieldModel field,
    dynamic value, {
    required bool isArabic,
  }) {
    if (!field.showBothLanguages ||
        !isBilingualTextField(field) ||
        value is! Map) {
      return null;
    }
    final String english = (value['en'] ?? value['EN'] ?? '').toString().trim();
    final String arabic = (value['ar'] ?? value['AR'] ?? '').toString().trim();
    final bool englishHasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(english);
    final bool arabicHasEnglish = RegExp(r'[a-zA-Z]').hasMatch(arabic);
    if (!englishHasArabic && !arabicHasEnglish) return null;
    if (englishHasArabic && arabicHasEnglish) {
      return isArabic
          ? 'اكتب النص الإنجليزي بالإنجليزية والعربي بالعربية'
          : 'Use English in the English field and Arabic in the Arabic field';
    }
    if (englishHasArabic) {
      return isArabic
          ? 'الحقل الإنجليزي يجب أن يكون بالإنجليزية'
          : 'Please enter English text in the English field';
    }
    return isArabic
        ? 'الحقل العربي يجب أن يكون بالعربية'
        : 'Please enter Arabic text in the Arabic field';
  }

  static bool _isFieldValueEmpty(CrmTemplateFieldModel field, dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) {
      if (field.showBothLanguages && isBilingualTextField(field)) {
        final String english = (value['en'] ?? value['EN'] ?? '').toString();
        final String arabic = (value['ar'] ?? value['AR'] ?? '').toString();
        return english.trim().isEmpty || arabic.trim().isEmpty;
      }
      return value.values
          .every((dynamic item) => item.toString().trim().isEmpty);
    }
    return false;
  }

  static Map<String, String> _bilingualTextValues(dynamic value) {
    if (value is Map) {
      return <String, String>{
        'en': (value['en'] ?? value['EN'] ?? value['Name_En'] ?? '').toString(),
        'ar': (value['ar'] ?? value['AR'] ?? value['Name_Ar'] ?? '').toString(),
      };
    }
    return <String, String>{'en': value?.toString() ?? '', 'ar': ''};
  }

  static List<String> _textValues(dynamic value) {
    if (value is String) return <String>[value];
    if (value is Map) {
      return value.values
          .map((dynamic item) => item?.toString() ?? '')
          .where((String item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }
}
