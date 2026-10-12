// ***************************** FILE INFO ***************************** //
// File Name: shift_assignment_cubit.dart
// Purpose: Coordinates employee shift assignment selection and persistence.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helper/main_helper/current_user_context.dart';
import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/shift_assignment_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/repository/shift_assignments_repository.dart';
import '../../data/repository/shifts_repository.dart';
import '../../utils/shift_management_local_data.dart';
import 'shift_assignment_state.dart';

/// Manages the Assign Shift form and its employee assignment batch.
class ShiftAssignmentCubit extends Cubit<ShiftAssignmentState> {
  ShiftAssignmentCubit({
    required HrModuleDataCubit hrModuleDataCubit,
    ShiftsRepository? shiftsRepository,
    ShiftAssignmentsRepository? assignmentsRepository,
  })  : _hrModuleDataCubit = hrModuleDataCubit,
        _shiftsRepository = shiftsRepository ?? ShiftsRepository(),
        _assignmentsRepository =
            assignmentsRepository ?? ShiftAssignmentsRepository(),
        super(ShiftAssignmentState.initial()) {
    _dataSubscription = _hrModuleDataCubit.stream.listen(_handleHrDataState);
  }

  final HrModuleDataCubit _hrModuleDataCubit;
  final ShiftsRepository _shiftsRepository;
  final ShiftAssignmentsRepository _assignmentsRepository;
  late final StreamSubscription<HrModuleDataState> _dataSubscription;

  /// Method Name: [load]
  ///
  /// Purpose: Loads shared employees, departments, local filters, and shifts.
  ///
  /// Returns: Emits the loaded assignment state or an error state.
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _hrModuleDataCubit.load();
      final shifts = await _loadShifts();
      emit(state.copyWith(
        employees: _employees(_hrModuleDataCubit.state),
        departments: _departments(_hrModuleDataCubit.state),
        locations: ShiftManagementLocalData.getLocations(),
        branches: ShiftManagementLocalData.getBranches(),
        shifts: shifts,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  /// Method Name: [selectLocation]
  ///
  /// Purpose: Selects a location and clears dependent selections.
  ///
  /// Parameters:
  /// - [locationId]: Selected location ID.
  void selectLocation(String? locationId) {
    emit(state.copyWith(
      selectedLocationId: locationId,
      selectedBranchId: null,
      selectedShiftId: null,
    ));
  }

  /// Method Name: [selectBranch]
  ///
  /// Purpose: Selects a branch and clears the dependent shift selection.
  ///
  /// Parameters:
  /// - [branchId]: Selected branch ID.
  void selectBranch(String? branchId) {
    emit(state.copyWith(selectedBranchId: branchId, selectedShiftId: null));
  }

  /// Method Name: [selectShift]
  ///
  /// Purpose: Selects a shift to assign.
  ///
  /// Parameters:
  /// - [shiftId]: Selected shift ID.
  void selectShift(String? shiftId) {
    emit(state.copyWith(selectedShiftId: shiftId));
  }

  /// Method Name: [selectDepartment]
  ///
  /// Purpose: Filters employees by department.
  ///
  /// Parameters:
  /// - [departmentId]: Selected department ID.
  void selectDepartment(String? departmentId) {
    emit(state.copyWith(selectedDepartmentId: departmentId));
  }

  /// Method Name: [updateSearchQuery]
  ///
  /// Purpose: Updates employee search filtering.
  ///
  /// Parameters:
  /// - [query]: User-entered search text.
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query.trim()));
  }

  /// Method Name: [toggleEmployee]
  ///
  /// Purpose: Toggles one employee in the assignment selection.
  ///
  /// Parameters:
  /// - [employeeId]: Employee ID to toggle.
  void toggleEmployee(String employeeId) {
    final selected = {...state.selectedEmployeeIds};
    selected.contains(employeeId)
        ? selected.remove(employeeId)
        : selected.add(employeeId);
    emit(state.copyWith(selectedEmployeeIds: selected));
  }

  /// Method Name: [selectAllVisibleEmployees]
  ///
  /// Purpose: Selects every currently visible employee.
  void selectAllVisibleEmployees() {
    emit(state.copyWith(
      selectedEmployeeIds: {
        ...state.selectedEmployeeIds,
        ...visibleEmployees()
            .map((employee) => employee.id)
            .whereType<String>(),
      },
    ));
  }

  /// Method Name: [clearVisibleEmployees]
  ///
  /// Purpose: Removes currently visible employees from the selection.
  void clearVisibleEmployees() {
    final visibleIds = visibleEmployees().map((employee) => employee.id);
    final selected = {...state.selectedEmployeeIds}..removeAll(visibleIds);
    emit(state.copyWith(selectedEmployeeIds: selected));
  }

  /// Method Name: [visibleBranches]
  ///
  /// Purpose: Returns branches belonging to the selected location.
  ///
  /// Returns: Filtered branch records.
  List<BranchModel> visibleBranches() => state.branches
      .where((branch) => branch.locationId == state.selectedLocationId)
      .toList();

  /// Method Name: [visibleShifts]
  ///
  /// Purpose: Returns shifts belonging to the selected location and branch.
  ///
  /// Returns: Filtered shift records.
  List<ShiftModel> visibleShifts() => state.shifts
      .where((shift) =>
          shift.locationId == state.selectedLocationId &&
          shift.branchId == state.selectedBranchId)
      .toList();

  /// Method Name: [visibleEmployees]
  ///
  /// Purpose: Applies department and search filters to employees.
  ///
  /// Returns: Employees currently visible in the selection grid.
  List<HrEmployeeEntity> visibleEmployees() {
    final query = state.searchQuery.toLowerCase();
    return state.employees.where((employee) {
      final departmentMatches = state.selectedDepartmentId == null ||
          employee.departmentId == state.selectedDepartmentId;
      final name = employee.getFullName().toLowerCase();
      final arabicName = employee.getFullNameArabic().toLowerCase();
      return departmentMatches &&
          (query.isEmpty || name.contains(query) || arabicName.contains(query));
    }).toList();
  }

  /// Method Name: [submitAssignments]
  ///
  /// Purpose: Creates one tracked assignment for every selected employee.
  ///
  /// Returns: True when the assignment batch is persisted.
  Future<bool> submitAssignments() async {
    final shift = state.shifts.cast<ShiftModel?>().firstWhere(
          (item) => item?.id == state.selectedShiftId,
          orElse: () => null,
        );
    final editorId = _currentEditorId();
    if (shift == null ||
        state.selectedLocationId == null ||
        state.selectedBranchId == null ||
        state.selectedEmployeeIds.isEmpty ||
        editorId == null) {
      emit(state.copyWith(errorMessage: 'Complete assignment details'));
      return false;
    }
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final assignments = state.selectedEmployeeIds
        .map(
          (employeeId) => ShiftAssignmentModel.withInitialAssignment(
            employeeId: employeeId,
            shiftId: shift.id,
            editorId: editorId,
          ),
        )
        .toList();
    final result = await _assignmentsRepository.createAssignments(assignments);
    return result.fold(
      (failure) {
        emit(
            state.copyWith(isSubmitting: false, errorMessage: failure.message));
        return false;
      },
      (_) {
        emit(state.copyWith(isSubmitting: false, selectedEmployeeIds: {}));
        return true;
      },
    );
  }

  @override
  Future<void> close() async {
    await _dataSubscription.cancel();
    return super.close();
  }

  void _handleHrDataState(HrModuleDataState dataState) {
    emit(state.copyWith(
      employees: _employees(dataState),
      departments: _departments(dataState),
    ));
  }

  List<HrEmployeeEntity> _employees(HrModuleDataState dataState) =>
      switch (dataState) {
        HrModuleDataLoading(employees: final employees) => employees,
        HrModuleDataLoaded(employees: final employees) => employees,
        HrModuleDataError(employees: final employees) => employees,
        HrModuleDataInitial() => const [],
      };

  List<DepartmentModelPro> _departments(HrModuleDataState dataState) =>
      switch (dataState) {
        HrModuleDataLoading(departments: final departments) => departments,
        HrModuleDataLoaded(departments: final departments) => departments,
        HrModuleDataError(departments: final departments) => departments,
        HrModuleDataInitial() => const [],
      };

  Future<List<ShiftModel>> _loadShifts() async {
    final result = await _shiftsRepository.getShifts();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (shifts) => shifts,
    );
  }

  String? _currentEditorId() {
    final email = CurrentUserContext.email?.trim().toLowerCase();
    if (email == null || email.isEmpty) return null;
    for (final employee in state.employees) {
      if (employee.email?.trim().toLowerCase() == email &&
          employee.id?.trim().isNotEmpty == true) {
        return employee.id;
      }
    }
    return null;
  }
}
