// ***************************** FILE INFO ***************************** //
// File Name: shift_management_cubit.dart
// Purpose: Loads and manages Shift Management presentation data.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helper/main_helper/current_user_context.dart';
import '../../../main_controller/domain/entity/hr_employee_entity.dart';
import '../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/shift_assignment_model.dart';
import '../../data/models/shift_model.dart';
import '../../data/repository/shift_assignments_repository.dart';
import '../../data/repository/shifts_repository.dart';
import '../../utils/shift_management_local_data.dart';
import '../../utils/shift_employee_table_row.dart';
import '../../utils/shift_validator.dart';
import 'shift_management_state.dart';

/// Coordinates Shift Management data, filters, and presentation state.
class ShiftManagementCubit extends Cubit<ShiftManagementState> {
  ShiftManagementCubit({
    required HrModuleDataCubit hrModuleDataCubit,
    ShiftsRepository? shiftsRepository,
    ShiftAssignmentsRepository? assignmentsRepository,
  })  : _hrModuleDataCubit = hrModuleDataCubit,
        _shiftsRepository = shiftsRepository ?? ShiftsRepository(),
        _assignmentsRepository =
            assignmentsRepository ?? ShiftAssignmentsRepository(),
        super(const ShiftManagementInitial()) {
    _dataSubscription = _hrModuleDataCubit.stream.listen(_handleHrDataState);
  }

  static const String allKey = 'all';

  final HrModuleDataCubit _hrModuleDataCubit;
  final ShiftsRepository _shiftsRepository;
  final ShiftAssignmentsRepository _assignmentsRepository;
  late final StreamSubscription<HrModuleDataState> _dataSubscription;

  /// Method Name: [load]
  ///
  /// Purpose: Loads employee, location, and branch data for the page.
  ///
  /// Returns: Emits a loaded or error state.
  Future<void> load() async {
    emit(_loadingState());
    try {
      await _hrModuleDataCubit.load();
      final locations = ShiftManagementLocalData.getLocations();
      _emitLoaded(
        employees: _employeesFromState(_hrModuleDataCubit.state),
        locations: locations,
        branches: ShiftManagementLocalData.getBranches(),
        shifts: await _loadShiftsOrThrow(),
        assignments: await _loadAssignmentsOrThrow(),
        selectedLocationId: locations.isEmpty ? null : locations.first.id,
      );
    } catch (error) {
      emit(_errorState(error.toString()));
    }
  }

  /// Method Name: [loadShifts]
  ///
  /// Purpose: Refreshes persisted shifts without reloading employee data.
  ///
  /// Returns: Emits updated shift data or an error state.
  Future<void> loadShifts() async {
    try {
      final shifts = await _loadShiftsOrThrow();
      final shiftKeys = shifts.map((shift) => shift.id).toSet();
      _emitLoaded(
        shifts: shifts,
        selectedShiftKey: shiftKeys.contains(state.selectedShiftKey)
            ? state.selectedShiftKey
            : allKey,
      );
    } catch (error) {
      emit(_errorState(error.toString()));
    }
  }

  /// Method Name: [loadAssignments]
  ///
  /// Purpose: Refreshes persisted employee shift assignments for the table.
  ///
  /// Returns: Emits updated assignment data or an error state.
  Future<void> loadAssignments() async {
    try {
      _emitLoaded(assignments: await _loadAssignmentsOrThrow());
    } catch (error) {
      emit(_errorState(error.toString()));
    }
  }

  /// Method Name: [updateEmployeeAssignments]
  ///
  /// Purpose: Appends one new shift revision for every selected employee.
  ///
  /// Parameters:
  /// - [employeeIds]: Existing employee assignment document IDs.
  /// - [shiftId]: Target shift ID.
  ///
  /// Returns: True when the complete update batch is persisted.
  Future<bool> updateEmployeeAssignments({
    required Iterable<String> employeeIds,
    required String shiftId,
  }) async {
    final ids = employeeIds.toSet();
    final assignmentsByEmployee = {
      for (final assignment in state.assignments)
        assignment.employeeId: assignment,
    };
    final editorId = _currentEditorId();
    final targetShift = state.shifts.cast<ShiftModel?>().firstWhere(
          (shift) => shift?.id == shiftId,
          orElse: () => null,
        );
    if (ids.isEmpty || targetShift == null || editorId == null) {
      return false;
    }

    final updates = <ShiftAssignmentModel>[];
    for (final employeeId in ids) {
      final assignment = assignmentsByEmployee[employeeId];
      if (assignment == null) return false;
      updates.add(
        assignment.appendTrackingRevision(
          shiftId: shiftId,
          editorId: editorId,
        ),
      );
    }

    final result = await _assignmentsRepository.updateAssignments(updates);
    return result.fold(
      (failure) {
        emit(_errorState(failure.message));
        return false;
      },
      (_) async {
        await loadAssignments();
        return true;
      },
    );
  }

  /// Method Name: [createShift]
  ///
  /// Purpose: Validates and persists a new shift, then refreshes the list.
  ///
  /// Parameters:
  /// - [shift]: Shift draft to validate and persist.
  ///
  /// Returns: True when the shift is persisted successfully.
  Future<bool> createShift(ShiftModel shift) async {
    final validationError = ShiftValidator.validate(
      shift: shift,
      locationIds: state.locations.map((location) => location.id),
      branches: state.branches,
      existingShifts: state.shifts,
    );
    if (validationError != null) {
      emit(_errorState(validationError.name));
      return false;
    }

    final editorId = _currentEditorId();
    if (editorId == null) {
      emit(_errorState('Current editor could not be resolved'));
      return false;
    }
    final trackedShift = shift.editors.isEmpty
        ? shift.withInitialRevision(editorId: editorId)
        : shift;

    final result = await _shiftsRepository.createShift(trackedShift);
    return result.fold(
      (failure) {
        emit(_errorState(failure.message));
        return false;
      },
      (_) async {
        await loadShifts();
        return true;
      },
    );
  }

  /// Method Name: [updateShiftTimes]
  ///
  /// Purpose: Appends a tracked time-only revision to an existing shift.
  ///
  /// Parameters:
  /// - [shiftId]: Stable ID of the shift to update.
  /// - [startMinutes]: New start time in minutes since midnight.
  /// - [endMinutes]: New end time in minutes since midnight.
  ///
  /// Returns: True when the revision is persisted successfully.
  Future<bool> updateShiftTimes({
    required String shiftId,
    required int startMinutes,
    required int endMinutes,
  }) async {
    final currentShift = state.shifts.cast<ShiftModel?>().firstWhere(
          (shift) => shift?.id == shiftId,
          orElse: () => null,
        );
    if (currentShift == null) {
      emit(_errorState('Shift could not be found'));
      return false;
    }
    final draft = ShiftModel(
      id: currentShift.id,
      locationIds: [currentShift.locationId],
      branchIds: [currentShift.branchId],
      startMinutesHistory: [startMinutes],
      endMinutesHistory: [endMinutes],
      timestamps: const [],
      editors: const [],
    );
    final validationError = ShiftValidator.validate(
      shift: draft,
      locationIds: state.locations.map((location) => location.id),
      branches: state.branches,
      existingShifts: state.shifts,
      excludedShiftId: currentShift.id,
    );
    if (validationError != null) {
      emit(_errorState(validationError.name));
      return false;
    }
    final editorId = _currentEditorId();
    if (editorId == null) {
      emit(_errorState('Current editor could not be resolved'));
      return false;
    }
    final updatedShift = currentShift.appendRevision(
      locationId: currentShift.locationId,
      branchId: currentShift.branchId,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      editorId: editorId,
    );
    final result = await _shiftsRepository.appendShiftRevision(updatedShift);
    return result.fold(
      (failure) {
        emit(_errorState(failure.message));
        return false;
      },
      (_) async {
        await loadShifts();
        return true;
      },
    );
  }

  /// Method Name: [selectLocation]
  ///
  /// Purpose: Selects a location and resets the branch filter.
  ///
  /// Parameters:
  /// - [locationId]: Selected location ID, or null for all locations.
  ///
  /// Returns: Emits the updated filter state.
  void selectLocation(String? locationId) {
    _emitLoaded(
      selectedLocationId: locationId,
      clearLocation: locationId == null,
      clearBranch: true,
      clearShift: true,
    );
  }

  /// Method Name: [selectBranch]
  ///
  /// Purpose: Selects a branch or clears the branch filter.
  ///
  /// Parameters:
  /// - [branchId]: Selected branch ID, or null for all branches.
  ///
  /// Returns: Emits the updated filter state.
  void selectBranch(String? branchId) {
    _emitLoaded(
      selectedBranchId: branchId,
      clearBranch: branchId == null,
      clearShift: true,
    );
  }

  /// Method Name: [selectShift]
  ///
  /// Purpose: Selects a shift time range or clears the shift filter.
  ///
  /// Parameters:
  /// - [shiftKey]: Stable time-range key, or null for all shifts.
  ///
  /// Returns: Emits the updated shift filter state.
  void selectShift(String? shiftKey) {
    _emitLoaded(selectedShiftKey: shiftKey ?? allKey);
  }

  /// Method Name: [updateSearchQuery]
  ///
  /// Purpose: Updates the branch search query.
  ///
  /// Parameters:
  /// - [value]: User-entered search text.
  ///
  /// Returns: Emits the updated search state.
  void updateSearchQuery(String value) {
    final query = value.trim();
    if (query == state.searchQuery) return;
    _emitLoaded(searchQuery: query);
  }

  /// Method Name: [updateSort]
  ///
  /// Purpose: Stores the selected sort option.
  ///
  /// Parameters:
  /// - [value]: Selected sort option.
  ///
  /// Returns: Emits the updated sort state.
  void updateSort(String? value) {
    _emitLoaded(sortValue: value);
  }

  List<BranchModel> visibleBranches() {
    final query = state.searchQuery.toLowerCase();
    return state.branches.where((branch) {
      final matchesLocation = state.selectedLocationId == null ||
          branch.locationId == state.selectedLocationId;
      final matchesSearch =
          query.isEmpty || branch.name.toLowerCase().contains(query);
      return matchesLocation && matchesSearch;
    }).toList();
  }

  /// Method Name: [visibleAssignedEmployees]
  ///
  /// Purpose: Resolves assigned employees that match the active table filters.
  ///
  /// Parameters:
  /// - [departmentId]: Optional department filter from the filter dialog.
  /// - [ignoreBranchFilter]: Whether the branch filter should be ignored.
  ///
  /// Returns: Employee rows with valid branch and shift data.
  List<ShiftEmployeeTableRow> visibleAssignedEmployees({
    String? departmentId,
    bool ignoreBranchFilter = false,
  }) {
    final assignmentsByEmployee = {
      for (final assignment in state.assignments)
        assignment.employeeId: assignment,
    };
    final shiftsById = {for (final shift in state.shifts) shift.id: shift};
    final branchesById = {
      for (final branch in state.branches) branch.id: branch
    };
    final query = state.searchQuery.toLowerCase();

    return state.employees
        .map((employee) {
          final employeeId = employee.id;
          final assignment =
              employeeId == null ? null : assignmentsByEmployee[employeeId];
          final shift =
              assignment == null ? null : shiftsById[assignment.shiftId];
          final branch = shift == null ? null : branchesById[shift.branchId];
          if (employeeId == null ||
              assignment == null ||
              shift == null ||
              branch == null) {
            return null;
          }
          return ShiftEmployeeTableRow(
            employee: employee,
            branch: branch,
            shift: shift,
          );
        })
        .whereType<ShiftEmployeeTableRow>()
        .where((row) {
          final matchesLocation = state.selectedLocationId == null ||
              row.shift.locationId == state.selectedLocationId;
          final matchesBranch = ignoreBranchFilter ||
              state.selectedBranchId == null ||
              row.branch.id == state.selectedBranchId;
          final matchesShift = state.selectedShiftKey == allKey ||
              row.shift.id == state.selectedShiftKey;
          final matchesDepartment =
              departmentId == null || row.employee.departmentId == departmentId;
          final employee = row.employee;
          final searchableText = [
            employee.id,
            employee.getFullName(),
            employee.getFullNameArabic(),
          ].whereType<String>().join(' ').toLowerCase();
          return matchesLocation &&
              matchesBranch &&
              matchesShift &&
              matchesDepartment &&
              (query.isEmpty || searchableText.contains(query));
        })
        .toList();
  }

  @override
  Future<void> close() async {
    await _dataSubscription.cancel();
    return super.close();
  }

  void _handleHrDataState(HrModuleDataState dataState) {
    _emitLoaded(employees: _employeesFromState(dataState));
  }

  List<HrEmployeeEntity> _employeesFromState(HrModuleDataState dataState) {
    return switch (dataState) {
      HrModuleDataLoading(employees: final employees) => employees,
      HrModuleDataLoaded(employees: final employees) => employees,
      HrModuleDataError(employees: final employees) => employees,
      HrModuleDataInitial() => const [],
    };
  }

  ShiftManagementLoading _loadingState() {
    return ShiftManagementLoading(
      employees: state.employees,
      locations: state.locations,
      branches: state.branches,
      shifts: state.shifts,
      assignments: state.assignments,
      selectedLocationId: state.selectedLocationId,
      selectedBranchId: state.selectedBranchId,
      selectedShiftKey: state.selectedShiftKey,
      searchQuery: state.searchQuery,
      sortValue: state.sortValue,
    );
  }

  ShiftManagementError _errorState(String message) {
    return ShiftManagementError(
      message: message,
      employees: state.employees,
      locations: state.locations,
      branches: state.branches,
      shifts: state.shifts,
      assignments: state.assignments,
      selectedLocationId: state.selectedLocationId,
      selectedBranchId: state.selectedBranchId,
      selectedShiftKey: state.selectedShiftKey,
      searchQuery: state.searchQuery,
      sortValue: state.sortValue,
    );
  }

  void _emitLoaded({
    List<HrEmployeeEntity>? employees,
    List<LocationModel>? locations,
    List<BranchModel>? branches,
    List<ShiftModel>? shifts,
    List<ShiftAssignmentModel>? assignments,
    String? selectedLocationId,
    String? selectedBranchId,
    String? selectedShiftKey,
    String? searchQuery,
    String? sortValue,
    bool clearLocation = false,
    bool clearBranch = false,
    bool clearShift = false,
  }) {
    emit(
      ShiftManagementLoaded(
        employees: employees ?? state.employees,
        locations: locations ??
            (state.locations.isEmpty
                ? ShiftManagementLocalData.getLocations()
                : state.locations),
        branches: branches ??
            (state.branches.isEmpty
                ? ShiftManagementLocalData.getBranches()
                : state.branches),
        shifts: shifts ?? state.shifts,
        assignments: assignments ?? state.assignments,
        selectedLocationId: clearLocation
            ? null
            : selectedLocationId ?? state.selectedLocationId,
        selectedBranchId:
            clearBranch ? null : selectedBranchId ?? state.selectedBranchId,
        selectedShiftKey:
            clearShift ? allKey : selectedShiftKey ?? state.selectedShiftKey,
        searchQuery: searchQuery ?? state.searchQuery,
        sortValue: sortValue ?? state.sortValue,
      ),
    );
  }

  Future<List<ShiftModel>> _loadShiftsOrThrow() async {
    final result = await _shiftsRepository.getShifts();
    return result.fold(
        (failure) => throw Exception(failure.message), (value) => value);
  }

  Future<List<ShiftAssignmentModel>> _loadAssignmentsOrThrow() async {
    final result = await _assignmentsRepository.getAssignments();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (value) => value,
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
