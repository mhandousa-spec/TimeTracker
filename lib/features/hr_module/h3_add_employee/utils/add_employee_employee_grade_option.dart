// ***************************** FILE INFO ***************************** //
// File Name: add_employee_employee_grade_option.dart
// Purpose: Defines employee-grade options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum EmployeeGradeOption {
  intern,
  junior,
  mid,
  senior,
  lead,
  manager,
  executive;

  String get value => name;

  String get title {
    switch (this) {
      case intern:
        return S.current.intern;
      case junior:
        return S.current.junior;
      case mid:
        return S.current.mid;
      case senior:
        return S.current.senior;
      case lead:
        return S.current.lead;
      case manager:
        return S.current.manager;
      case executive:
        return S.current.executive;
    }
  }
}
