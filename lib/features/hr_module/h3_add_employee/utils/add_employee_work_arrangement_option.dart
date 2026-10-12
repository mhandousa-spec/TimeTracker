// ***************************** FILE INFO ***************************** //
// File Name: add_employee_work_arrangement_option.dart
// Purpose: Defines work-arrangement options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum WorkArrangementOption {
  onsite,
  remote,
  hybrid;

  String get value => name;

  String get title {
    switch (this) {
      case onsite:
        return S.current.onsite;
      case remote:
        return S.current.remote;
      case hybrid:
        return S.current.hybrid;
    }
  }
}
