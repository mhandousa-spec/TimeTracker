// ***************************** FILE INFO ***************************** //
// File Name: add_employee_days_off_option.dart
// Purpose: Defines days-off options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum DaysOffOption {
  fridaySaturday,
  saturdaySunday,
  sundayMonday,
  custom;

  String get value => name;

  String get title {
    switch (this) {
      case fridaySaturday:
        return S.current.fridaySaturday;
      case saturdaySunday:
        return S.current.saturdaySunday;
      case sundayMonday:
        return S.current.sundayMonday;
      case custom:
        return S.current.custom;
    }
  }
}
