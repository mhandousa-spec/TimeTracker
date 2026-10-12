// ***************************** FILE INFO ***************************** //
// File Name: add_employee_remote_status_option.dart
// Purpose: Defines remote-status options for the add-employee form.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum RemoteStatusOption {
  fullyRemote,
  partiallyRemote,
  notRemote;

  String get value => name;

  String get title {
    switch (this) {
      case fullyRemote:
        return S.current.fullyRemote;
      case partiallyRemote:
        return S.current.partiallyRemote;
      case notRemote:
        return S.current.notRemote;
    }
  }
}
