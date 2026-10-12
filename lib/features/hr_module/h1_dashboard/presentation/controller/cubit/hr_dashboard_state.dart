part of 'hr_dashboard_cubit.dart';

// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_state.dart
// Purpose: Defines the state emitted by HrDashboardCubit.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

@immutable
sealed class HrDashboardState {}

final class HrDashboardInitial extends HrDashboardState {}

final class HrDashboardLoading extends HrDashboardState {}

final class HrDashboardLoaded extends HrDashboardState {
  HrDashboardLoaded({
    required this.departments,
    required this.locations,
    required this.selectedDepartmentIds,
    required this.selectedLocations,
    required this.filteredEmployees,
    required this.overallData,
    required this.demographicsData,
    required this.positionAnalytics,
    required this.ageSummary,
    required this.experienceSummary,
    required this.positionDataAvailable,
    required this.employeesPerLocation,
    required this.nationalityDistribution,
    required this.departmentEmployees,
  });

  final List<DepartmentModelPro> departments;
  final List<String> locations;
  final List<String> selectedDepartmentIds;
  final List<String> selectedLocations;
  final List<HrEmployeeEntity> filteredEmployees;
  final HrDashboardOverallData overallData;
  final HrDashboardDemographicsData demographicsData;
  final HrDashboardPositionAnalyticsData positionAnalytics;
  final HrDashboardRangeSummary ageSummary;
  final HrDashboardRangeSummary experienceSummary;
  final bool? positionDataAvailable;
  final List<HrDashboardChartItem> employeesPerLocation;
  final List<HrDashboardChartItem> nationalityDistribution;
  final List<HrDashboardChartItem> departmentEmployees;
}

final class HrDashboardError extends HrDashboardState {
  HrDashboardError(this.message);

  final String message;
}
