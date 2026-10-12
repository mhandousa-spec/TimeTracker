// ***************************** FILE INFO ***************************** //
// File Name: add_employee_work_location_option.dart
// Purpose: Defines work-location options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum WorkLocationOption {
  headquarters,
  branchOffice,
  clientSite,
  remote;

  String get value => name;

  String get title {
    switch (this) {
      case headquarters:
        return S.current.headquarters;
      case branchOffice:
        return S.current.branchOffice;
      case clientSite:
        return S.current.clientSite;
      case remote:
        return S.current.remote;
    }
  }
}
