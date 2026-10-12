// ***************************** FILE INFO ***************************** //
// File Name: certifications_state.dart
// Purpose: Defines immutable certification table states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

part of 'certifications_cubit.dart';

/// Base state for certification table data and controls.
sealed class CertificationsState
    extends EmployeeDetailsTableState<CertificationEmployeeRow> {
  const CertificationsState({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that certification data has not loaded yet.
final class CertificationsInitial extends CertificationsState {
  const CertificationsInitial()
      : super(
          rows: const [],
          searchQuery: '',
          filters: const EmployeeFilterModel(),
        );
}

/// Indicates that certification data is loading or refreshing.
final class CertificationsLoading extends CertificationsState {
  const CertificationsLoading({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that certification data is available.
final class CertificationsLoaded extends CertificationsState {
  const CertificationsLoaded({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that supplemental certification data could not load.
final class CertificationsError extends CertificationsState {
  const CertificationsError({
    required this.message,
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });

  final String message;
}
