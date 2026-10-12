// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_state.dart
// Purpose: Defines immutable HR employee-page search and view state.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import '../../../utils/enums/ui_controllers/hr_employee_view_mode.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

/// Base state for the HR employee search and filtering flow.
sealed class HrEmployeeState {
  const HrEmployeeState({
    required this.employees,
    required this.searchQuery,
    required this.filters,
    required this.viewMode,
  });

  final List<HrEmployeeEntity> employees;
  final String searchQuery;
  final EmployeeFilterModel filters;
  final HrEmployeeViewMode viewMode;
}

/// Initial state before employee source data is available.
final class HrEmployeeInitial extends HrEmployeeState {
  const HrEmployeeInitial({
    super.searchQuery = '',
    super.filters = const EmployeeFilterModel(),
    super.viewMode = HrEmployeeViewMode.table,
  }) : super(
          employees: const [],
        );
}

/// Loading state while the source employee data is being refreshed.
final class HrEmployeeLoading extends HrEmployeeState {
  const HrEmployeeLoading({
    required super.employees,
    required super.searchQuery,
    required super.filters,
    required super.viewMode,
  });
}

/// Loaded state containing the final filtered employee result.
final class HrEmployeeLoaded extends HrEmployeeState {
  const HrEmployeeLoaded({
    required super.employees,
    required super.searchQuery,
    required super.filters,
    required super.viewMode,
  });
}

/// Error state containing the last available filtered employee result.
final class HrEmployeeError extends HrEmployeeState {
  const HrEmployeeError({
    required this.message,
    required super.employees,
    required super.searchQuery,
    required super.filters,
    required super.viewMode,
  });

  final String message;
}
