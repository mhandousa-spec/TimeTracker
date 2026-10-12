import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

/// ******************* FILE INFO *******************
/// File Name: details_switch_state.dart
/// Description: States for Details Switch Cubit
/// Created by: Amr Mesbah
/// Last Update: 01/12/2025


abstract class DetailsSwitchState {}

class DetailsSwitchInitial extends DetailsSwitchState {}

class DetailsSwitchLoading extends DetailsSwitchState {}

class DetailsSwitchLoaded extends DetailsSwitchState {
  final List<EmployeeEntityPro> allEmployees;
  final List<EmployeeEntityPro> filteredEmployees;
  final List<EmployeeEntityPro> selectedEmployees;
  final List<String> selectedDepartments;
  final bool limitAvailability;
  final bool requireApproval;
  final bool isLoading;

  DetailsSwitchLoaded({
    required this.allEmployees,
    required this.filteredEmployees,
    required this.selectedEmployees,
    required this.selectedDepartments,
    required this.limitAvailability,
    required this.requireApproval,
    required this.isLoading,
  });
}

class DetailsSwitchError extends DetailsSwitchState {
  final String message;
  DetailsSwitchError(this.message);
}

class DetailsSwitchValidationError extends DetailsSwitchState {
  final String title;
  final String message;
  final String lottiePath;

  DetailsSwitchValidationError({
    required this.title,
    required this.message,
    required this.lottiePath,
  });
}