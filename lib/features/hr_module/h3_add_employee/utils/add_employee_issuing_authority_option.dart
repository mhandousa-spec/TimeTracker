// ***************************** FILE INFO ***************************** //
// File Name: add_employee_issuing_authority_option.dart
// Purpose: Defines certification issuing-authority options.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum IssuingAuthorityOption {
  university,
  accreditedInstitute,
  professionalBody,
  other;

  String get value => name;

  String get title {
    switch (this) {
      case university:
        return S.current.university;
      case accreditedInstitute:
        return S.current.accreditedInstitute;
      case professionalBody:
        return S.current.professionalBody;
      case other:
        return S.current.other;
    }
  }
}
