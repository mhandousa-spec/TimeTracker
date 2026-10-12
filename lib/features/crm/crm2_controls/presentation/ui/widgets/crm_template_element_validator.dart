// ****************** FILE INFO ******************
// File Name: crm_template_element_validator.dart
// Purpose: Validation rules and helper functions for CRM template element forms
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_edit_model.dart';

abstract class CrmTemplateElementValidator {
  /// Validates section English and Arabic names.
  static ({String? enError, String? arError}) validateSectionNames({
    required String nameEn,
    required String nameAr,
  }) {
    final String enText = nameEn.trim();
    final String arText = nameAr.trim();

    String? enErr;
    if (enText.isEmpty) {
      enErr = 'Field Required';
    } else {
      final dynamic res = Validator.isEnglish(enText);
      if (res is String) enErr = res;
    }

    final String? arErr = Validator.isArabic(
      arText,
      'الحقل مطلوب',
      'يرجى إدخال النص باللغة العربية',
    );

    return (enError: enErr, arError: arErr);
  }

  /// Validates field edit model names and optional/required error messages.
  static bool validateFieldEdit(CrmTemplateFieldEditModel edit) {
    bool hasError = false;
    final String enText = edit.nameEnController.text.trim();
    final String arText = edit.nameArController.text.trim();

    String? enErr;
    if (enText.isEmpty) {
      enErr = 'Field Required';
    } else {
      final dynamic res = Validator.isEnglish(enText);
      if (res is String) enErr = res;
    }

    final String? arErr = Validator.isArabic(
      arText,
      'الحقل مطلوب',
      'يرجى إدخال النص باللغة العربية',
    );

    if (enErr != null || arErr != null) {
      edit.nameEnError = enErr;
      edit.nameArError = arErr;
      hasError = true;
    } else {
      edit.nameEnError = null;
      edit.nameArError = null;
    }

    if (edit.field.isRequired) {
      final String errEn = edit.errorEnController.text.trim();
      final String errAr = edit.errorArController.text.trim();

      String? errEnMsg;
      if (errEn.isEmpty) {
        errEnMsg = 'Field Required';
      } else {
        final dynamic res = Validator.isEnglish(errEn);
        if (res is String) errEnMsg = res;
      }

      final String? errArMsg = Validator.isArabic(
        errAr,
        'الحقل مطلوب',
        'يرجى إدخال النص باللغة العربية',
      );

      if (errEnMsg != null || errArMsg != null) {
        edit.errorEnError = errEnMsg;
        edit.errorArError = errArMsg;
        hasError = true;
      } else {
        edit.errorEnError = null;
        edit.errorArError = null;
      }
    } else {
      edit.errorEnError = null;
      edit.errorArError = null;
    }

    return hasError;
  }

  /// Checks whether the form currently satisfies all validity criteria for Save/Add.
  static bool isFormValid({
    required String selectedCategory,
    required bool isExistingSectionMode,
    required bool isExistingFieldMode,
    required String sectionNameEn,
    required String sectionNameAr,
    required List<CrmTemplateFieldEditModel> fieldEdits,
  }) {
    if (selectedCategory.isEmpty) return false;

    if (selectedCategory == 'Section' || isExistingSectionMode) {
      final String enText = sectionNameEn.trim();
      final String arText = sectionNameAr.trim();

      if (enText.isEmpty || arText.isEmpty) return false;
      if (Validator.isEnglish(enText) is String) return false;
      if (Validator.isArabic(
            arText,
            'الحقل مطلوب',
            'يرجى إدخال النص باللغة العربية',
          ) !=
          null) {
        return false;
      }
    }

    if (fieldEdits.isEmpty) return false;

    for (final CrmTemplateFieldEditModel edit in fieldEdits) {
      if (edit.field.fieldTypeId.trim().isEmpty) return false;
      final String enText = edit.nameEnController.text.trim();
      final String arText = edit.nameArController.text.trim();

      if (enText.isEmpty || arText.isEmpty) return false;
      if (Validator.isEnglish(enText) is String) return false;
      if (Validator.isArabic(
            arText,
            'الحقل مطلوب',
            'يرجى إدخال النص باللغة العربية',
          ) !=
          null) {
        return false;
      }

      if (edit.field.isRequired) {
        final String errEn = edit.errorEnController.text.trim();
        final String errAr = edit.errorArController.text.trim();
        if (errEn.isEmpty || Validator.isEnglish(errEn) is String) {
          return false;
        }
        if (errAr.isEmpty ||
            Validator.isArabic(
                  errAr,
                  'الحقل مطلوب',
                  'يرجى إدخال النص باللغة العربية',
                ) !=
                null) {
          return false;
        }
      }
    }

    return true;
  }

  /// Validates inputs live as the user types (only showing errors when field has text and format is invalid).
  static void validateLiveInputs({
    required String sectionNameEn,
    required String sectionNameAr,
    required void Function(String? enErr, String? arErr) onSectionErrorChanged,
    required List<CrmTemplateFieldEditModel> fieldEdits,
  }) {
    final String secEn = sectionNameEn.trim();
    final String secAr = sectionNameAr.trim();

    String? secEnErr;
    if (secEn.isNotEmpty) {
      final dynamic res = Validator.isEnglish(secEn);
      if (res is String) secEnErr = res;
    }

    String? secArErr;
    if (secAr.isNotEmpty) {
      secArErr = Validator.isArabic(
        secAr,
        'الحقل مطلوب',
        'يرجى إدخال النص باللغة العربية',
      );
    }

    onSectionErrorChanged(secEnErr, secArErr);

    for (final CrmTemplateFieldEditModel edit in fieldEdits) {
      final String enText = edit.nameEnController.text.trim();
      final String arText = edit.nameArController.text.trim();

      if (enText.isNotEmpty) {
        final dynamic res = Validator.isEnglish(enText);
        edit.nameEnError = res is String ? res : null;
      } else {
        edit.nameEnError = null;
      }

      if (arText.isNotEmpty) {
        edit.nameArError = Validator.isArabic(
          arText,
          'الحقل مطلوب',
          'يرجى إدخال النص باللغة العربية',
        );
      } else {
        edit.nameArError = null;
      }

      if (edit.field.isRequired) {
        final String errEn = edit.errorEnController.text.trim();
        final String errAr = edit.errorArController.text.trim();

        if (errEn.isNotEmpty) {
          final dynamic res = Validator.isEnglish(errEn);
          edit.errorEnError = res is String ? res : null;
        } else {
          edit.errorEnError = null;
        }

        if (errAr.isNotEmpty) {
          edit.errorArError = Validator.isArabic(
            errAr,
            'الحقل مطلوب',
            'يرجى إدخال النص باللغة العربية',
          );
        } else {
          edit.errorArError = null;
        }
      } else {
        edit.errorEnError = null;
        edit.errorArError = null;
      }
    }
  }
}
