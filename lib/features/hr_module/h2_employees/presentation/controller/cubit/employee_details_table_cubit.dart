// ***************************** FILE INFO ***************************** //
// File Name: employee_details_table_cubit.dart
// Purpose: Centralizes shared employee detail table state and filtering behavior.
// Author: Mohamed Elrashidy
// Created At: 2026-08-14
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

import '../../../../../../core/helper/main_helper/flexible_date_parser.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../domain/entity/employee_details_row.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'employee_details_table_state.dart';

/// Base Cubit for searchable and filterable supplemental employee tables.
abstract class EmployeeDetailsTableCubit<R extends EmployeeDetailsRow,
    S extends EmployeeDetailsTableState<R>> extends Cubit<S> {
  EmployeeDetailsTableCubit({
    required Cubit<HrModuleDataState> dataCubit,
    required S initialState,
  })  : _dataCubit = dataCubit,
        super(initialState);

  final Cubit<HrModuleDataState> _dataCubit;
  StreamSubscription<HrModuleDataState>? _dataSubscription;
  List<R> _sourceRows = const [];
  List<HrEmployeeEntity> _employees = const [];

  /// Method Name: [initializeEmployeeDetailsTable]
  ///
  /// Purpose: Starts shared employee synchronization after child initialization.
  ///
  /// Returns: Subscribes once and processes the current shared data state.
  @protected
  void initializeEmployeeDetailsTable() {
    if (_dataSubscription != null) return;
    _dataSubscription = _dataCubit.stream.listen(_handleDataState);
    _handleDataState(_dataCubit.state);
  }

  /// Method Name: [updateSearchQuery]
  ///
  /// Purpose: Applies a normalized query to every searchable row value.
  ///
  /// Parameters:
  /// - [value]: Current shared-toolbar search text.
  void updateSearchQuery(String value) =>
      publishLoaded(searchQuery: value.trim());

  /// Method Name: [applyFilters]
  ///
  /// Purpose: Applies shared employee filters to the current source rows.
  ///
  /// Parameters:
  /// - [filters]: Department, job-title, and start-date selections.
  void applyFilters(EmployeeFilterModel filters) =>
      publishLoaded(filters: filters);

  /// Method Name: [resetFilters]
  ///
  /// Purpose: Clears filters while preserving the active search query.
  void resetFilters() => publishLoaded(filters: const EmployeeFilterModel());

  /// Method Name: [departmentOptions]
  ///
  /// Purpose: Builds localized department filter options from source employees.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether department labels use English.
  ///
  /// Returns: Unique employee department IDs and their localized labels.
  List<EmployeeFilterOption> departmentOptions(bool isEnglish) => _employees
      .map((employee) => employee.departmentId?.trim() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet()
      .map((id) => EmployeeFilterOption(
            value: id,
            label: Get.find<MainCoreDepartmentCubit>()
                .getDepartmentName(id, isEnglish),
          ))
      .toList();

  /// Method Name: [jobTitleOptions]
  ///
  /// Purpose: Builds unique job-title filter options from source employees.
  ///
  /// Returns: Stable lowercase values and their visible title labels.
  List<EmployeeFilterOption> jobTitleOptions() => _employees
      .map((employee) => employee.title?.trim() ?? '')
      .where((title) => title.isNotEmpty)
      .toSet()
      .map((title) =>
          EmployeeFilterOption(value: title.toLowerCase(), label: title))
      .toList();

  /// Method Name: [rebuildRows]
  ///
  /// Purpose: Rejoins current employees with child-owned supplemental data.
  ///
  /// Parameters:
  /// - [employees]: Optional employee snapshot replacing the current source.
  @protected
  void rebuildRows([List<HrEmployeeEntity>? employees]) {
    final values = employees ?? _employees;
    _sourceRows = values.map(buildRow).toList();
  }

  /// Method Name: [publishLoaded]
  ///
  /// Purpose: Publishes filtered rows through the feature's loaded state type.
  ///
  /// Parameters:
  /// - [searchQuery]: Optional replacement search query.
  /// - [filters]: Optional replacement filters.
  @protected
  void publishLoaded({
    String? searchQuery,
    EmployeeFilterModel? filters,
  }) {
    final nextQuery = searchQuery ?? state.searchQuery;
    final nextFilters = filters ?? state.filters;
    emit(createLoadedState(
      rows: _filterRows(searchQuery: nextQuery, filters: nextFilters),
      searchQuery: nextQuery,
      filters: nextFilters,
    ));
  }

  /// Method Name: [publishError]
  ///
  /// Purpose: Publishes a feature error without discarding available rows.
  ///
  /// Parameters:
  /// - [message]: User-displayable failure message.
  @protected
  void publishError(String message) {
    emit(createErrorState(
      message: message,
      rows: _filterRows(),
      searchQuery: state.searchQuery,
      filters: state.filters,
    ));
  }

  /// Creates one feature row for the supplied employee.
  @protected
  R buildRow(HrEmployeeEntity employee);

  /// Creates the feature-specific initial state.
  @protected
  S createInitialState();

  /// Creates the feature-specific loading state.
  @protected
  S createLoadingState({
    required List<R> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  });

  /// Creates the feature-specific loaded state.
  @protected
  S createLoadedState({
    required List<R> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  });

  /// Creates the feature-specific error state.
  @protected
  S createErrorState({
    required String message,
    required List<R> rows,
    required String searchQuery,
    required EmployeeFilterModel filters,
  });

  @override
  Future<void> close() async {
    await _dataSubscription?.cancel();
    return super.close();
  }

  /// Method Name: [_handleDataState]
  ///
  /// Purpose: Mirrors shared HR employee states into the feature table.
  ///
  /// Parameters:
  /// - [dataState]: Current shared employee and department state.
  void _handleDataState(HrModuleDataState dataState) {
    switch (dataState) {
      case HrModuleDataInitial():
        emit(createInitialState());
      case HrModuleDataLoading():
        _employees = dataState.employees;
        rebuildRows(dataState.employees);
        emit(createLoadingState(
          rows: _filterRows(),
          searchQuery: state.searchQuery,
          filters: state.filters,
        ));
      case HrModuleDataLoaded():
        _employees = dataState.employees;
        rebuildRows(dataState.employees);
        publishLoaded();
      case HrModuleDataError():
        _employees = dataState.employees;
        rebuildRows(dataState.employees);
        publishError(dataState.message);
    }
  }

  /// Method Name: [_filterRows]
  ///
  /// Purpose: Applies search and shared employee criteria to source rows.
  ///
  /// Parameters:
  /// - [searchQuery]: Optional query override.
  /// - [filters]: Optional filter override.
  ///
  /// Returns: Rows matching every active criterion.
  List<R> _filterRows({
    String? searchQuery,
    EmployeeFilterModel? filters,
  }) {
    final query = (searchQuery ?? state.searchQuery).toLowerCase();
    final activeFilters = filters ?? state.filters;
    return _sourceRows.where((row) {
      final employee = row.employee;
      final matchesSearch = query.isEmpty ||
          row.searchValues.any((value) => value.toLowerCase().contains(query));
      return matchesSearch &&
          (activeFilters.departmentId == null ||
              employee.departmentId == activeFilters.departmentId) &&
          (activeFilters.jobTitle == null ||
              employee.title?.toLowerCase() == activeFilters.jobTitle) &&
          _matchesStartDate(employee.firstLogin, activeFilters.startDate);
    }).toList();
  }

  /// Method Name: [_matchesStartDate]
  ///
  /// Purpose: Applies the inclusive employee start-date lower bound.
  ///
  /// Parameters:
  /// - [rawDate]: Persisted employee first-login value.
  /// - [selectedDate]: Optional selected lower-bound date.
  ///
  /// Returns: Whether the employee meets the selected date criterion.
  bool _matchesStartDate(String? rawDate, DateTime? selectedDate) {
    if (selectedDate == null) return true;
    final employeeDate = parseFlexibleDate(rawDate);
    if (employeeDate == null) return false;
    final dateOnly =
        DateTime(employeeDate.year, employeeDate.month, employeeDate.day);
    final selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return !dateOnly.isBefore(selectedDateOnly);
  }
}
