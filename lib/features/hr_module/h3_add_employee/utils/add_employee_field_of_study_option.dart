// ***************************** FILE INFO ***************************** //
// File Name: add_employee_field_of_study_option.dart
// Purpose: Defines field-of-study options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum FieldOfStudyOption {
  business,
  humanResources,
  finance,
  informationTechnology,
  engineering,
  other;

  String get value => name;

  String get title {
    switch (this) {
      case business:
        return S.current.business;
      case humanResources:
        return S.current.humanResources;
      case finance:
        return S.current.finance;
      case informationTechnology:
        return S.current.informationTechnology;
      case engineering:
        return S.current.engineering;
      case other:
        return S.current.other;
    }
  }
}
