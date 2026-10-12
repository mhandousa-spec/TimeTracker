// ***************************** FILE INFO ***************************** //
// File Name: shift_assignment_state.dart
// Purpose: Defines immutable Assign Shift presentation states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/shift_model.dart';

/// Immutable state for the employee shift assignment flow.
class ShiftAssignmentState {
  const ShiftAssignmentState({
    required this.employees,
    required this.departments,
    required this.locations,
    required this.branches,
    required this.shifts,
    required this.selectedLocationId,
    required this.selectedBranchId,
    required this.selectedShiftId,
    required this.selectedDepartmentId,
    required this.searchQuery,
    required this.selectedEmployeeIds,
    required this.isLoading,
    required this.isSubmitting,
    required this.errorMessage,
  });

  factory ShiftAssignmentState.initial() => const ShiftAssignmentState(
        employees: [],
        departments: [],
        locations: [],
        branches: [],
        shifts: [],
        selectedLocationId: null,
        selectedBranchId: null,
        selectedShiftId: null,
        selectedDepartmentId: null,
        searchQuery: '',
        selectedEmployeeIds: {},
        isLoading: false,
        isSubmitting: false,
        errorMessage: null,
      );

  final List<HrEmployeeEntity> employees;
  final List<DepartmentModelPro> departments;
  final List<LocationModel> locations;
  final List<BranchModel> branches;
  final List<ShiftModel> shifts;
  final String? selectedLocationId;
  final String? selectedBranchId;
  final String? selectedShiftId;
  final String? selectedDepartmentId;
  final String searchQuery;
  final Set<String> selectedEmployeeIds;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  ShiftAssignmentState copyWith({
    List<HrEmployeeEntity>? employees,
    List<DepartmentModelPro>? departments,
    List<LocationModel>? locations,
    List<BranchModel>? branches,
    List<ShiftModel>? shifts,
    Object? selectedLocationId = _unset,
    Object? selectedBranchId = _unset,
    Object? selectedShiftId = _unset,
    Object? selectedDepartmentId = _unset,
    String? searchQuery,
    Set<String>? selectedEmployeeIds,
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _unset,
  }) {
    return ShiftAssignmentState(
      employees: employees ?? this.employees,
      departments: departments ?? this.departments,
      locations: locations ?? this.locations,
      branches: branches ?? this.branches,
      shifts: shifts ?? this.shifts,
      selectedLocationId: selectedLocationId == _unset
          ? this.selectedLocationId
          : selectedLocationId as String?,
      selectedBranchId: selectedBranchId == _unset
          ? this.selectedBranchId
          : selectedBranchId as String?,
      selectedShiftId: selectedShiftId == _unset
          ? this.selectedShiftId
          : selectedShiftId as String?,
      selectedDepartmentId: selectedDepartmentId == _unset
          ? this.selectedDepartmentId
          : selectedDepartmentId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedEmployeeIds: selectedEmployeeIds ?? this.selectedEmployeeIds,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}

const _unset = Object();
