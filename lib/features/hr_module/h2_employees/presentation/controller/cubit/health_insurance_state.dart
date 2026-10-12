// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_state.dart
// Purpose: Defines immutable health-insurance table states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

part of 'health_insurance_cubit.dart';

/// Base state for Health Insurance table data and controls.
sealed class HealthInsuranceState
    extends EmployeeDetailsTableState<HealthInsuranceEmployeeRow> {
  const HealthInsuranceState({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

final class HealthInsuranceInitial extends HealthInsuranceState {
  const HealthInsuranceInitial()
      : super(
            rows: const [],
            searchQuery: '',
            filters: const EmployeeFilterModel());
}

final class HealthInsuranceLoading extends HealthInsuranceState {
  const HealthInsuranceLoading(
      {required super.rows,
      required super.searchQuery,
      required super.filters});
}

final class HealthInsuranceLoaded extends HealthInsuranceState {
  const HealthInsuranceLoaded(
      {required super.rows,
      required super.searchQuery,
      required super.filters});
}

final class HealthInsuranceError extends HealthInsuranceState {
  const HealthInsuranceError(
      {required this.message,
      required super.rows,
      required super.searchQuery,
      required super.filters});
  final String message;
}
