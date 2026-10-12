// ****************** FILE INFO ******************
// File Name: crm_controls_enums.dart
// Purpose: Enumeration types for CRM Controls dropdowns with dynamic localization support
// Author: Mohand Adel
// Created At: 06/08/2026

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Enum representing CRM Template Category selection (Section or Fields)
enum CrmCategoryEnum {
  section('Section'),
  fields('Fields');

  final String value;

  const CrmCategoryEnum(this.value);

  String get localizedLabel {
    switch (this) {
      case CrmCategoryEnum.section:
        return S.current.crmCategorySection;
      case CrmCategoryEnum.fields:
        return S.current.crmCategoryFields;
    }
  }

  static CrmCategoryEnum? fromValue(String? val) {
    if (val == null) return null;
    return CrmCategoryEnum.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => CrmCategoryEnum.section,
    );
  }

  DropdownItem<String> toDropdownItem() {
    return DropdownItem<String>(value: value, label: localizedLabel);
  }
}

/// Enum representing CRM Template Status selection (Active, Inactive, Deleted)
enum CrmStatusEnum {
  active('Active'),
  inactive('Inactive'),
  deleted('Deleted');

  final String value;

  const CrmStatusEnum(this.value);

  String get localizedLabel {
    switch (this) {
      case CrmStatusEnum.active:
        return S.current.crmStatusActive;
      case CrmStatusEnum.inactive:
        return S.current.crmStatusInactive;
      case CrmStatusEnum.deleted:
        return S.current.crmStatusDeleted;
    }
  }

  static CrmStatusEnum? fromValue(String? val) {
    if (val == null) return null;
    return CrmStatusEnum.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => CrmStatusEnum.active,
    );
  }

  DropdownItem<String> toDropdownItem() {
    return DropdownItem<String>(value: value, label: localizedLabel);
  }
}

/// Enum representing Field Validation Types
enum CrmValidationTypeEnum {
  none('none'),
  numbers('Numbers'),
  symbols('Symbols'),
  letters('Letters'),
  email('Email'),
  phone('Phone');

  final String value;

  const CrmValidationTypeEnum(this.value);

  String get localizedLabel {
    switch (this) {
      case CrmValidationTypeEnum.none:
        return S.current.crmValidationNone;
      case CrmValidationTypeEnum.numbers:
        return S.current.crmValidationNumbers;
      case CrmValidationTypeEnum.symbols:
        return S.current.crmValidationSymbols;
      case CrmValidationTypeEnum.letters:
        return S.current.crmValidationLetters;
      case CrmValidationTypeEnum.email:
        return S.current.crmValidationEmail;
      case CrmValidationTypeEnum.phone:
        return S.current.crmValidationPhone;
    }
  }

  static CrmValidationTypeEnum? fromValue(String? val) {
    if (val == null || val.isEmpty) return null;
    for (final CrmValidationTypeEnum e in CrmValidationTypeEnum.values) {
      if (e.value.toLowerCase() == val.toLowerCase()) return e;
    }
    return null;
  }

  DropdownItem<String> toDropdownItem() {
    return DropdownItem<String>(value: value, label: localizedLabel);
  }
}

/// Enum representing Allowed File Types for file upload fields
enum CrmAllowedFileTypeEnum {
  pdf('PDF'),
  docx('DOCX'),
  txt('TXT'),
  rtf('RTF'),
  png('PNG'),
  jpg('JPG'),
  jpeg('JPEG'),
  svg('SVG');

  final String value;

  const CrmAllowedFileTypeEnum(this.value);

  String get localizedLabel => value;

  static CrmAllowedFileTypeEnum? fromValue(String? val) {
    if (val == null) return null;
    return CrmAllowedFileTypeEnum.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => CrmAllowedFileTypeEnum.pdf,
    );
  }

  MultiSelectDropdownItem<String> toMultiSelectDropdownItem() {
    return MultiSelectDropdownItem<String>(value: value, label: localizedLabel);
  }
}

/// Enum representing Purchasing Validation Types
enum CrmPurchasingValidationEnum {
  numbers('Numbers'),
  symbols('Symbols');

  final String value;

  const CrmPurchasingValidationEnum(this.value);

  String get localizedLabel {
    switch (this) {
      case CrmPurchasingValidationEnum.numbers:
        return S.current.crmValidationNumbers;
      case CrmPurchasingValidationEnum.symbols:
        return S.current.crmValidationSymbols;
    }
  }

  static CrmPurchasingValidationEnum? fromValue(String? val) {
    if (val == null) return null;
    return CrmPurchasingValidationEnum.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => CrmPurchasingValidationEnum.symbols,
    );
  }

  MultiSelectDropdownItem<String> toMultiSelectDropdownItem() {
    return MultiSelectDropdownItem<String>(value: value, label: localizedLabel);
  }
}
