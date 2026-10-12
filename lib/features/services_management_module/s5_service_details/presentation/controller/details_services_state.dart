// ******************* FILE INFO *******************
// File Name: details_services_state
// Description: Details services state.
// Module: services_management_module / presentation/s5_service_details/controller
// *************************************************

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

import 'package:knowticed_plus/features/services_management_module/s5_service_details/data/service_stats_model.dart';

abstract class DetailsServicesState {}

class DetailsServicesInitial extends DetailsServicesState {}

class DetailsServicesLoading extends DetailsServicesState {}

class DetailsServicesLoaded extends DetailsServicesState {
  final List<Map<String, dynamic>> filteredItems;
  final List<Map<String, dynamic>> displayedItems;
  final List<EmployeeEntityModell> allEmployees;
  final List<Map<String, dynamic>> displayedStats;
  final   ServiceStatsModel stats;

  DetailsServicesLoaded({
    required this.filteredItems,
    required this.displayedItems,
    required this.allEmployees,
    required this.displayedStats,
    required this.stats,
  });
}

class DetailsServicesError extends DetailsServicesState {
  final String message;

  DetailsServicesError(this.message);
}

class DetailsServicesFilterApplied extends DetailsServicesState {
  final List<Map<String, dynamic>> displayedItems;

  DetailsServicesFilterApplied(this.displayedItems);
}

class DetailsServicesSearchApplied extends DetailsServicesState {}

class DetailsServicesTabChanged extends DetailsServicesState {
  final bool isEmployeesTab;

  DetailsServicesTabChanged(this.isEmployeesTab);
}
