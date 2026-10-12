// ***************************** FILE INFO ***************************** //
// File Name: add_employee_degree_option.dart
// Purpose: Defines degree options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum DegreeOption {
  highSchool,
  diploma,
  bachelor,
  master,
  doctorate,
  professionalCertification;

  String get value => name;

  String get title {
    switch (this) {
      case highSchool:
        return S.current.highSchool;
      case diploma:
        return S.current.diploma;
      case bachelor:
        return S.current.bachelor;
      case master:
        return S.current.master;
      case doctorate:
        return S.current.phdDegree;
      case professionalCertification:
        return S.current.professionalCertification;
    }
  }
}
