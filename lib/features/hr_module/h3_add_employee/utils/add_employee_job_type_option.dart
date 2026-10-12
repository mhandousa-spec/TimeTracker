// ***************************** FILE INFO ***************************** //
// File Name: add_employee_job_type_option.dart
// Purpose: Defines job-type options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum JobTypeOption {
  partTime,
  fullTime,
  contractor;

  String get value => name;

  String get title {
    switch (this) {
      case partTime:
        return S.current.partTime;
      case fullTime:
        return S.current.fullTime;
      case contractor:
        return S.current.contractor;
    }
  }
}
