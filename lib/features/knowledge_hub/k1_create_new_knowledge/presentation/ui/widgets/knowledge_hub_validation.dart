/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/knowledge_hub_validation.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_validation.dart
/// Purpose: Form-validation helpers for the create-knowledge flow.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';



class KnowledgeHubValidation {
  final BuildContext context;
  final GlobalKey<FormState> documentNameFormKey;
  final GlobalKey<FormState> documentDescriptionKey;
  final String dropDownMenuText;
  final bool hasDocument;
  final bool limitDepartmentAvailability;
  final List<String> selectedDepartments;
  final bool schedulePublishing;
  final DateTime? startDate;

  KnowledgeHubValidation({
    required this.context,
    required this.documentNameFormKey,
    required this.documentDescriptionKey,
    required this.dropDownMenuText,
    required this.hasDocument,
    required this.limitDepartmentAvailability,
    required this.selectedDepartments,
    required this.schedulePublishing,
    required this.startDate,
  });

  ValidationResult validate() {
    if (!_validateFormFields()) {
      return ValidationResult(
        isValid: false,
        message: S.of(context)!.pleaseFillAllRequiredFieldsCorrectly,
      );
    }

    if (!_validateDocumentType()) {
      return ValidationResult(
        isValid: false,
        message: S.of(context).please_select_doc_type,
      );
    }

    if (!_validateDocumentAttachment()) {
      return ValidationResult(
        isValid: false,
        message: S.of(context)!.pleaseAttachDocument,
      );
    }

    if (!_validateDepartmentSelection()) {
      return ValidationResult(
        isValid: false,
        message: S.of(context)!.addDepartmentsOrSwitchOffLimitAvailability,
      );
    }

    if (!_validateSchedulePublishing()) {
      return ValidationResult(
        isValid: false,
        message: S.of(context)!.addStartDateOrSwitchOffSchedulePublishing,
      );
    }

    return ValidationResult(isValid: true);
  }

  bool _validateFormFields() {
    return documentNameFormKey.currentState!.validate() &&
        documentDescriptionKey.currentState!.validate();
  }

  bool _validateDocumentType() {
    return dropDownMenuText != 'Choose Type';
  }

  bool _validateDocumentAttachment() {
    return hasDocument;
  }

  bool _validateDepartmentSelection() {
    return !limitDepartmentAvailability || selectedDepartments.isNotEmpty;
  }

  bool _validateSchedulePublishing() {
    return !schedulePublishing || startDate != null;
  }
}

class ValidationResult {
  final bool isValid;
  final String? message;

  ValidationResult({required this.isValid, this.message});
}