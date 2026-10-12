/// Module: services_management_module
/// Description: State for EmployeeServicesCubit — the cached list of
///              service-history docs assigned to the current provider on
///              the s10 "my assigned services" list screen.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable, ServicesHistoryModel
/// Revision History: Initial version — extracted from
///                    s10_services_provider/ui/services_management_module/employee_services.dart
///                    (audit fix 1b).
library;

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

abstract class EmployeeServicesState extends Equatable {
  const EmployeeServicesState();

  @override
  List<Object?> get props => [];
}

class EmployeeServicesLoading extends EmployeeServicesState {
  const EmployeeServicesLoading();
}

class EmployeeServicesLoaded extends EmployeeServicesState {
  final List<ServicesHistoryModel> services;

  const EmployeeServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class EmployeeServicesError extends EmployeeServicesState {
  final String message;

  const EmployeeServicesError(this.message);

  @override
  List<Object?> get props => [message];
}
