/// Module: services_management_module
/// Description: State for EmployeeActionCubit — a thin busy/error signal for
///              the mutating operations on the employee-action request
///              detail screen (ensure-approval-cycle, update-state,
///              fetch-latest-state). The screen keeps owning its own display
///              state (currentState/selectedState) locally since that drives
///              a large widget tree that isn't safe to migrate blind without
///              a compiler; this cubit only reports whether the last I/O
///              call succeeded/failed so the page can react.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/services_management_module/employee_details_services.dart
///                    (audit fix 1b).
library;

import 'package:equatable/equatable.dart';

abstract class EmployeeActionState extends Equatable {
  const EmployeeActionState();

  @override
  List<Object?> get props => [];
}

class EmployeeActionIdle extends EmployeeActionState {
  const EmployeeActionIdle();
}

class EmployeeActionBusy extends EmployeeActionState {
  const EmployeeActionBusy();
}

class EmployeeActionSuccess extends EmployeeActionState {
  const EmployeeActionSuccess();
}

class EmployeeActionError extends EmployeeActionState {
  final String message;

  const EmployeeActionError(this.message);

  @override
  List<Object?> get props => [message];
}
