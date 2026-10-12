/// Module: settings/main_controller
//
///*************************** FILE INFO ****************************///
/// File Name: employee_state.dart
/// Purpose: States for EmployeeController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026

part of './employee_controller.dart';

sealed class EmployeeControllerState {
  const EmployeeControllerState();
}

final class EmployeeInitial extends EmployeeControllerState {
  const EmployeeInitial();
}

final class EmployeeLoading extends EmployeeControllerState {
  const EmployeeLoading();
}

/// Emitted whenever the cached employee data changes. Not value-equal on
/// purpose, so every emit rebuilds — this replaces GetX `update()`.
final class EmployeeLoaded extends EmployeeControllerState {
  const EmployeeLoaded();
}

/// Emitted when a load or write fails.
///
/// The GetX version had no error channel at all: `getAllEmployees` swallowed
/// its exception in an empty catch, and `getEmployee` returned `null` for both
/// "not found" and "the request threw".
final class EmployeeError extends EmployeeControllerState {
  const EmployeeError(this.message);

  final String message;
}
