// ***************************** FILE INFO ***************************** //
// File Name: emergency_contacts_state.dart
// Purpose: Defines immutable emergency-contact table states.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

part of 'emergency_contacts_cubit.dart';

/// Base state for emergency-contact table data and controls.
sealed class EmergencyContactsState
    extends EmployeeDetailsTableState<EmergencyContactEmployeeRow> {
  const EmergencyContactsState({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that emergency-contact data has not loaded yet.
final class EmergencyContactsInitial extends EmergencyContactsState {
  const EmergencyContactsInitial()
      : super(
          rows: const [],
          searchQuery: '',
          filters: const EmployeeFilterModel(),
        );
}

/// Indicates that emergency-contact data is loading or refreshing.
final class EmergencyContactsLoading extends EmergencyContactsState {
  const EmergencyContactsLoading({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that emergency-contact data is available.
final class EmergencyContactsLoaded extends EmergencyContactsState {
  const EmergencyContactsLoaded({
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });
}

/// Indicates that supplemental emergency-contact data could not load.
final class EmergencyContactsError extends EmergencyContactsState {
  const EmergencyContactsError({
    required this.message,
    required super.rows,
    required super.searchQuery,
    required super.filters,
  });

  final String message;
}
