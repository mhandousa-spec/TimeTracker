/// Module: services_management_module
/// Description: State classes for HomePageServicesCubit — the home/services
///              list screen's employee/department loading, filtering and
///              department-count aggregation.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: equatable, ServicesHistoryModel
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Initial version — extracted from
///     home_page_services.dart (fix item 1).
import 'package:equatable/equatable.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

abstract class HomePageServicesState extends Equatable {
  const HomePageServicesState();

  @override
  List<Object?> get props => [];
}

/// Initial state, before the first load has started.
class HomePageServicesInitial extends HomePageServicesState {}

/// Employee/department/services data is loading (first-time load only —
/// subsequent visits keep showing the last loaded data while refreshing).
class HomePageServicesLoading extends HomePageServicesState {}

/// Data loaded (or refreshed) successfully.
class HomePageServicesLoaded extends HomePageServicesState {
  final String userEmail;
  final String userDepartment;
  final List<ServicesHistoryModel> filteredServices;
  final Map<String, int> departmentCounts;
  final int totalServices;

  const HomePageServicesLoaded({
    required this.userEmail,
    required this.userDepartment,
    required this.filteredServices,
    required this.departmentCounts,
    required this.totalServices,
  });

  HomePageServicesLoaded copyWith({
    String? userEmail,
    String? userDepartment,
    List<ServicesHistoryModel>? filteredServices,
    Map<String, int>? departmentCounts,
    int? totalServices,
  }) {
    return HomePageServicesLoaded(
      userEmail: userEmail ?? this.userEmail,
      userDepartment: userDepartment ?? this.userDepartment,
      filteredServices: filteredServices ?? this.filteredServices,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      totalServices: totalServices ?? this.totalServices,
    );
  }

  @override
  List<Object?> get props => [
        userEmail,
        userDepartment,
        filteredServices,
        departmentCounts,
        totalServices,
      ];
}

/// Emitted when the initial load fails.
class HomePageServicesError extends HomePageServicesState {
  final String message;

  const HomePageServicesError(this.message);

  @override
  List<Object?> get props => [message];
}
