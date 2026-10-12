// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_cubit.dart
// Purpose: Maintains HR dashboard filters and derived analytics.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

import '../../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_chart_item.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_demographics_data.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_overall_data.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_position_analytics_data.dart';
import '../../../../main_controller/domain/entity/hr_dashboard_range_summary.dart';
import '../../../utils/hr_dashboard_calculator.dart';

part 'hr_dashboard_state.dart';

class HrDashboardCubit extends Cubit<HrDashboardState> {
  HrDashboardCubit({required HrModuleDataCubit hrModuleDataCubit})
      : _hrModuleDataCubit = hrModuleDataCubit,
        super(HrDashboardInitial()) {
    _dataSubscription = _hrModuleDataCubit.stream.listen(_handleDataState);
    _handleDataState(_hrModuleDataCubit.state);
  }

  final HrModuleDataCubit _hrModuleDataCubit;
  late final StreamSubscription<HrModuleDataState> _dataSubscription;

  List<HrEmployeeEntity> _employees = [];
  List<DepartmentModelPro> _departments = [];
  List<String> _locations = [];
  List<String> _selectedDepartmentIds = [];
  List<String> _selectedLocations = [];

  List<HrEmployeeEntity> get employees => _employees;
  List<DepartmentModelPro> get departments => _departments;
  List<String> get locations => _locations;
  List<String> get selectedDepartmentIds => _selectedDepartmentIds;
  List<String> get selectedLocations => _selectedLocations;

  /// Method Name: [filteredEmployees]
  ///
  /// Purpose: Returns source employees matching the active dashboard filters.
  ///
  /// Returns: The filtered employee list used by dashboard calculations.
  List<HrEmployeeEntity> get filteredEmployees =>
      HrDashboardCalculator.filterEmployees(
        employees: _employees,
        selectedDepartmentIds: _selectedDepartmentIds,
        selectedLocations: _selectedLocations,
      );

  /// Method Name: [updateDepartmentSelection]
  ///
  /// Purpose: Rebuilds dashboard analytics for selected department IDs.
  ///
  /// Parameters:
  /// - [values]: Stable department IDs selected in the dashboard filter.
  ///
  /// Returns: Emits an updated dashboard state.
  void updateDepartmentSelection(List<String> values) {
    _selectedDepartmentIds = List<String>.from(values);
    _emitLoadedState();
  }

  /// Method Name: [updateLocationSelection]
  ///
  /// Purpose: Rebuilds dashboard analytics for selected work locations.
  ///
  /// Parameters:
  /// - [values]: Work locations selected in the dashboard filter.
  ///
  /// Returns: Emits an updated dashboard state.
  void updateLocationSelection(List<String> values) {
    _selectedLocations = List<String>.from(values);
    _emitLoadedState();
  }

  /// Method Name: [_handleDataState]
  ///
  /// Purpose: Synchronizes dashboard source data with the shared HR state.
  ///
  /// Parameters:
  /// - [state]: The latest employee and department source state.
  ///
  /// Returns: Emits loading, error, or recalculated dashboard state.
  void _handleDataState(HrModuleDataState state) {
    if (state is HrModuleDataLoading) {
      _updateSourceData(
        employees: state.employees,
        departments: state.departments,
      );
      if (_employees.isEmpty && _departments.isEmpty) {
        emit(HrDashboardLoading());
      } else {
        _emitLoadedState();
      }
      return;
    }
    if (state is HrModuleDataError) {
      _updateSourceData(
        employees: state.employees,
        departments: state.departments,
      );
      if (_employees.isEmpty && _departments.isEmpty) {
        emit(HrDashboardError(state.message));
      } else {
        _emitLoadedState();
      }
      return;
    }
    if (state is! HrModuleDataLoaded) return;

    _updateSourceData(
      employees: state.employees,
      departments: state.departments,
    );
    _emitLoadedState();
  }

  /// Method Name: [_updateSourceData]
  ///
  /// Purpose: Copies shared source lists and rebuilds available locations.
  ///
  /// Parameters:
  /// - [employees]: Latest HR employee source data.
  /// - [departments]: Latest HR department source data.
  ///
  /// Returns: Updates the cubit's internal source data.
  void _updateSourceData({
    required List<HrEmployeeEntity> employees,
    required List<DepartmentModelPro> departments,
  }) {
    _employees = List<HrEmployeeEntity>.from(employees);
    _departments = List<DepartmentModelPro>.from(departments);
    _locations = _buildLocations();
  }

  /// Method Name: [_buildLocations]
  ///
  /// Purpose: Produces sorted, unique non-empty employee work locations.
  ///
  /// Returns: Filter values available for the location dropdown.
  List<String> _buildLocations() {
    final locations = _employees
        .map((employee) => employee.workLocation?.trim() ?? '')
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();
    locations.sort();
    return locations;
  }

  /// Method Name: [_emitLoadedState]
  ///
  /// Purpose: Emits dashboard data derived from current source data and filters.
  ///
  /// Returns: Emits [HrDashboardLoaded].
  void _emitLoadedState() {
    emit(_loadedState());
  }

  /// Method Name: [_loadedState]
  ///
  /// Purpose: Calculates the complete dashboard presentation state.
  ///
  /// Returns: Immutable dashboard data for widgets and charts.
  HrDashboardLoaded _loadedState() {
    final filtered = filteredEmployees;
    return HrDashboardLoaded(
      departments: List.unmodifiable(_departments),
      locations: List.unmodifiable(_locations),
      selectedDepartmentIds: List.unmodifiable(_selectedDepartmentIds),
      selectedLocations: List.unmodifiable(_selectedLocations),
      filteredEmployees: List.unmodifiable(filtered),
      overallData: HrDashboardCalculator.calculateOverall(
        filteredEmployees: filtered,
        hasSourceData: _employees.isNotEmpty || _departments.isNotEmpty,
      ),
      demographicsData: HrDashboardCalculator.calculateDemographics(
        filteredEmployees: filtered,
      ),
      positionAnalytics: HrDashboardCalculator.calculatePositionAnalytics(
        filteredEmployees: filtered,
      ),
      ageSummary: HrDashboardCalculator.calculateAgeSummary(
        filteredEmployees: filtered,
      ),
      experienceSummary: HrDashboardCalculator.calculateExperienceSummary(
        filteredEmployees: filtered,
      ),
      positionDataAvailable: HrDashboardCalculator.hasPositionData(filtered),
      employeesPerLocation: List.unmodifiable(
        HrDashboardCalculator.calculateEmployeesPerLocation(
          filteredEmployees: filtered,
        ),
      ),
      nationalityDistribution: List.unmodifiable(
        HrDashboardCalculator.calculateNationalities(
          filteredEmployees: filtered,
        ),
      ),
      departmentEmployees: List.unmodifiable(
        HrDashboardCalculator.calculateDepartmentEmployees(
          filteredEmployees: filtered,
        ),
      ),
    );
  }

  @override

  /// Method Name: [close]
  ///
  /// Purpose: Cancels the shared HR data subscription before disposal.
  ///
  /// Returns: Completes after subscription cleanup.
  Future<void> close() async {
    await _dataSubscription.cancel();
    return super.close();
  }
}
