// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_cubit.dart
// Purpose: Applies HR employee search and filters and publishes final results.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../../../core/helper/main_helper/flexible_date_parser.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import '../../../utils/enums/ui_controllers/hr_employee_view_mode.dart';
import 'hr_employee_state.dart';

/// Cubit for HR employee search, filtering, and presentation state.
class HrEmployeeCubit extends Cubit<HrEmployeeState> {
  HrEmployeeCubit({
    required HrModuleDataCubit dataCubit,
    required MainCoreDepartmentCubit departmentCubit,
  })  : _dataCubit = dataCubit,
        _departmentCubit = departmentCubit,
        super(const HrEmployeeInitial()) {
    _dataSubscription = _dataCubit.stream.listen(_handleDataState);
    _handleDataState(_dataCubit.state);
  }

  final HrModuleDataCubit _dataCubit;
  final MainCoreDepartmentCubit _departmentCubit;
  late final StreamSubscription<HrModuleDataState> _dataSubscription;

  List<HrEmployeeEntity> _sourceEmployees = const [];
  List<EmployeeFilterOption> _departmentOptions = const [];

  /// Method Name: [updateSearchQuery]
  ///
  /// Purpose: Applies a trimmed, case-insensitive employee search query.
  ///
  /// Parameters:
  /// - [value]: Current search field text.
  ///
  /// Returns: Emits the final employee result after search and filters.
  void updateSearchQuery(String value) {
    final query = value.trim();
    if (query == state.searchQuery) return;
    _emitLoadedResult(searchQuery: query);
  }

  /// Method Name: [updateViewMode]
  ///
  /// Purpose: Publishes the selected employee table or grid presentation.
  ///
  /// Parameters:
  /// - [value]: New employee presentation mode.
  ///
  /// Returns: Emits the current result with the selected view mode.
  void updateViewMode(HrEmployeeViewMode value) {
    if (value == state.viewMode) return;
    emit(_loadedState(viewMode: value));
  }

  /// Method Name: [applyFilters]
  ///
  /// Purpose: Applies department, job-title, and first-login date filters.
  ///
  /// Parameters:
  /// - [filters]: Filter values submitted by the employee filter dialog.
  ///
  /// Returns: Emits the final employee result after all active criteria.
  void applyFilters(EmployeeFilterModel filters) {
    emit(_loadedState(filters: filters));
  }

  /// Method Name: [resetFilters]
  ///
  /// Purpose: Clears all filters while preserving the active search query.
  ///
  /// Returns: Emits the search-matched employee result without filters.
  void resetFilters() {
    emit(_loadedState(filters: const EmployeeFilterModel()));
  }

  /// Method Name: [departmentOptions]
  ///
  /// Purpose: Provides stable department IDs with localized display labels.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether labels should use English department names.
  ///
  /// Returns: Available department filter options.
  List<EmployeeFilterOption> departmentOptions(bool isEnglish) {
    return _departmentOptions
        .map(
          (option) => EmployeeFilterOption(
            value: option.value,
            label: _departmentCubit.getDepartmentName(option.value, isEnglish),
          ),
        )
        .where((option) => option.label.trim().isNotEmpty)
        .toList();
  }

  /// Method Name: [jobTitleOptions]
  ///
  /// Purpose: Creates unique job-title filter options from source employees.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether labels should use English titles.
  ///
  /// Returns: Available canonical job-title values with localized labels.
  List<EmployeeFilterOption> jobTitleOptions(bool isEnglish) {
    final options = <String, String>{};
    for (final employee in _sourceEmployees) {
      final value = employee.title?.trim() ?? '';
      if (value.isEmpty) continue;
      final label = (isEnglish ? employee.title : employee.titleInArabic)
                  ?.trim()
                  .isNotEmpty ==
              true
          ? (isEnglish ? employee.title : employee.titleInArabic)!.trim()
          : value;
      options[value.toLowerCase()] = label;
    }
    return options.entries
        .map((entry) =>
            EmployeeFilterOption(value: entry.key, label: entry.value))
        .toList();
  }

  @override
  Future<void> close() async {
    await _dataSubscription.cancel();
    return super.close();
  }

  void _handleDataState(HrModuleDataState dataState) {
    switch (dataState) {
      case HrModuleDataInitial():
        emit(_initialState());
      case HrModuleDataLoading():
        _sourceEmployees = dataState.employees;
        _updateDepartmentOptions(dataState.departments);
        emit(_loadingState());
      case HrModuleDataLoaded():
        _sourceEmployees = dataState.employees;
        _updateDepartmentOptions(dataState.departments);
        _emitLoadedResult();
      case HrModuleDataError():
        _sourceEmployees = dataState.employees;
        _updateDepartmentOptions(dataState.departments);
        emit(
          HrEmployeeError(
            message: dataState.message,
            employees: _filterEmployees(),
            searchQuery: state.searchQuery,
            filters: state.filters,
            viewMode: state.viewMode,
          ),
        );
    }
  }

  void _updateDepartmentOptions(List<dynamic> departments) {
    _departmentOptions = departments
        .map((department) {
          final id = department.departmentID?.toString().trim() ?? '';
          return id.isEmpty ? null : EmployeeFilterOption(value: id, label: '');
        })
        .whereType<EmployeeFilterOption>()
        .toList();
  }

  HrEmployeeInitial _initialState() {
    return HrEmployeeInitial(
      searchQuery: state.searchQuery,
      filters: state.filters,
      viewMode: state.viewMode,
    );
  }

  HrEmployeeLoading _loadingState() {
    return HrEmployeeLoading(
      employees: const [],
      searchQuery: state.searchQuery,
      filters: state.filters,
      viewMode: state.viewMode,
    );
  }

  HrEmployeeLoaded _loadedState({
    String? searchQuery,
    EmployeeFilterModel? filters,
    HrEmployeeViewMode? viewMode,
  }) {
    return HrEmployeeLoaded(
      employees: _filterEmployees(
        searchQuery: searchQuery ?? state.searchQuery,
        filters: filters ?? state.filters,
      ),
      searchQuery: searchQuery ?? state.searchQuery,
      filters: filters ?? state.filters,
      viewMode: viewMode ?? state.viewMode,
    );
  }

  void _emitLoadedResult({String? searchQuery}) {
    emit(_loadedState(searchQuery: searchQuery));
  }

  List<HrEmployeeEntity> _filterEmployees({
    String? searchQuery,
    EmployeeFilterModel? filters,
  }) {
    final query = (searchQuery ?? state.searchQuery).trim().toLowerCase();
    final activeFilters = filters ?? state.filters;

    return _sourceEmployees.where((employee) {
      final matchesSearch = query.isEmpty || _matchesSearch(employee, query);
      final matchesDepartment = activeFilters.departmentId == null ||
          employee.departmentId == activeFilters.departmentId;
      final matchesJobTitle = activeFilters.jobTitle == null ||
          employee.title?.trim().toLowerCase() == activeFilters.jobTitle;
      final matchesStartDate = _matchesStartDate(
        employee.firstLogin,
        activeFilters.startDate,
      );
      return matchesSearch &&
          matchesDepartment &&
          matchesJobTitle &&
          matchesStartDate;
    }).toList();
  }

  bool _matchesSearch(HrEmployeeEntity employee, String query) {
    final values = [
      employee.firstName,
      employee.middleName,
      employee.lastName,
      employee.firstNameInArabic,
      employee.middleNameInArabic,
      employee.lastNameInArabic,
      employee.id,
    ];
    return values.any(
      (value) => value?.trim().toLowerCase().contains(query) ?? false,
    );
  }

  bool _matchesStartDate(String? rawDate, DateTime? selectedDate) {
    if (selectedDate == null) return true;
    final employeeDate = parseFlexibleDate(rawDate);
    if (employeeDate == null) return false;
    final dateOnly = DateTime(
      employeeDate.year,
      employeeDate.month,
      employeeDate.day,
    );
    final selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return !dateOnly.isBefore(selectedDateOnly);
  }
}
