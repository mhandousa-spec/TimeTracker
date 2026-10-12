// ***************************** FILE INFO ***************************** //
// File Name: shift_management_state.dart
// Purpose: Defines immutable Shift Management presentation states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/shift_assignment_model.dart';
import '../../data/models/shift_model.dart';

/// Base state for the Shift Management presentation flow.
sealed class ShiftManagementState {
  const ShiftManagementState({
    required this.employees,
    required this.locations,
    required this.branches,
    required this.shifts,
    required this.assignments,
    required this.selectedLocationId,
    required this.selectedBranchId,
    required this.selectedShiftKey,
    required this.searchQuery,
    required this.sortValue,
  });

  final List<HrEmployeeEntity> employees;
  final List<LocationModel> locations;
  final List<BranchModel> branches;
  final List<ShiftModel> shifts;
  final List<ShiftAssignmentModel> assignments;
  final String? selectedLocationId;
  final String? selectedBranchId;
  final String selectedShiftKey;
  final String searchQuery;
  final String? sortValue;
}

/// State before Shift Management data is loaded.
final class ShiftManagementInitial extends ShiftManagementState {
  const ShiftManagementInitial()
      : super(
          employees: const [],
          locations: const [],
          branches: const [],
          shifts: const [],
          assignments: const [],
          selectedLocationId: null,
          selectedBranchId: null,
          selectedShiftKey: 'all',
          searchQuery: '',
          sortValue: null,
        );
}

/// State emitted while Shift Management data is loading.
final class ShiftManagementLoading extends ShiftManagementState {
  const ShiftManagementLoading({
    required super.employees,
    required super.locations,
    required super.branches,
    required super.shifts,
    required super.assignments,
    required super.selectedLocationId,
    required super.selectedBranchId,
    required super.selectedShiftKey,
    required super.searchQuery,
    required super.sortValue,
  });
}

/// State containing loaded Shift Management data and filters.
final class ShiftManagementLoaded extends ShiftManagementState {
  ShiftManagementLoaded({
    required List<HrEmployeeEntity> employees,
    required List<LocationModel> locations,
    required List<BranchModel> branches,
    required List<ShiftModel> shifts,
    required List<ShiftAssignmentModel> assignments,
    required super.selectedLocationId,
    required super.selectedBranchId,
    required super.selectedShiftKey,
    required super.searchQuery,
    required super.sortValue,
  }) : super(
          employees: List.unmodifiable(employees),
          locations: List.unmodifiable(locations),
          branches: List.unmodifiable(branches),
          shifts: List.unmodifiable(shifts),
          assignments: List.unmodifiable(assignments),
        );
}

/// State containing the last available data and a loading error.
final class ShiftManagementError extends ShiftManagementState {
  ShiftManagementError({
    required this.message,
    required List<HrEmployeeEntity> employees,
    required List<LocationModel> locations,
    required List<BranchModel> branches,
    required List<ShiftModel> shifts,
    required List<ShiftAssignmentModel> assignments,
    required super.selectedLocationId,
    required super.selectedBranchId,
    required super.selectedShiftKey,
    required super.searchQuery,
    required super.sortValue,
  }) : super(
          employees: List.unmodifiable(employees),
          locations: List.unmodifiable(locations),
          branches: List.unmodifiable(branches),
          shifts: List.unmodifiable(shifts),
          assignments: List.unmodifiable(assignments),
        );

  final String message;
}
