/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: employees_health_insurance_state.dart
/// Purpose: States for EmployeesHealthInsuranceCubit.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - Added the standard header (Docs).

// ******************* FILE INFO *******************
// File Name: employees_health_insurance_state.dart
// Description: State for EmployeesHealthInsuranceCubit.
// Module: features / settings / presentation / controller
// *************************************************

import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/entities/request_health_insurance_entity.dart';

enum EmployeesHealthInsuranceStatus { initial, loading, success, failure }

class EmployeesHealthInsuranceState {
  final EmployeesHealthInsuranceStatus status;

  /// The most recently loaded employee's insurance record.
  final HealthInsuranceEntity? insurance;

  /// Employee id the [insurance] belongs to, so callers can tell a stale
  /// record from a fresh one.
  final String? employeeId;

  final String? errorMessage;

  const EmployeesHealthInsuranceState({
    required this.status,
    this.insurance,
    this.employeeId,
    this.errorMessage,
  });

  factory EmployeesHealthInsuranceState.initial() =>
      const EmployeesHealthInsuranceState(
        status: EmployeesHealthInsuranceStatus.initial,
      );

  bool get isLoading => status == EmployeesHealthInsuranceStatus.loading;

  EmployeesHealthInsuranceState copyWith({
    EmployeesHealthInsuranceStatus? status,
    HealthInsuranceEntity? insurance,
    String? employeeId,
    String? errorMessage,
    bool clearInsurance = false,
    bool clearError = false,
  }) {
    return EmployeesHealthInsuranceState(
      status: status ?? this.status,
      insurance: clearInsurance ? null : (insurance ?? this.insurance),
      employeeId: employeeId ?? this.employeeId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
