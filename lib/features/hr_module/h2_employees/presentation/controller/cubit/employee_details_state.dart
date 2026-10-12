// ***************************** FILE INFO ***************************** //
// File Name: employee_details_state.dart
// Purpose: Defines immutable states for the employee details page.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../domain/entity/employee_details_view_data.dart';

/// Base state for loading one employee's HR details.
sealed class EmployeeDetailsState {
  const EmployeeDetailsState(this.employee);

  final HrEmployeeEntity employee;
}

/// The employee detail request has not started yet.
final class EmployeeDetailsInitial extends EmployeeDetailsState {
  const EmployeeDetailsInitial(super.employee);
}

/// Supplemental employee detail documents are loading.
final class EmployeeDetailsLoading extends EmployeeDetailsState {
  const EmployeeDetailsLoading(super.employee);
}

/// Employee detail data loaded successfully.
final class EmployeeDetailsLoaded extends EmployeeDetailsState {
  EmployeeDetailsLoaded(this.data) : super(data.employee);

  final EmployeeDetailsViewData data;
}

/// Supplemental employee detail documents could not be loaded.
final class EmployeeDetailsError extends EmployeeDetailsState {
  const EmployeeDetailsError({
    required HrEmployeeEntity employee,
    required this.message,
  }) : super(employee);

  final String message;
}
