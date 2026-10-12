/// Module: services_management_module
/// Description: State for ServicesDashboardCubit — the monthly
///              canceled-vs-rejected breakdown and the service-name lists
///              (English/Arabic) used to populate the dashboard's service
///              filter dropdown.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from
///                    MonthlyComparisonServicesChart's `_loadData()` (audit
///                    fix item 3: move I/O out of s8 UI).
library;

import 'package:equatable/equatable.dart';

class ServicesDashboardData extends Equatable {
  /// month (1-12) -> {'canceled': count, 'rejected': count}
  final Map<int, Map<String, int>> monthlyData;
  final List<String> allServicesEnglish;
  final List<String> allServicesArabic;

  const ServicesDashboardData({
    this.monthlyData = const {},
    this.allServicesEnglish = const [],
    this.allServicesArabic = const [],
  });

  @override
  List<Object?> get props => [monthlyData, allServicesEnglish, allServicesArabic];
}

abstract class ServicesDashboardState extends Equatable {
  const ServicesDashboardState();

  @override
  List<Object?> get props => [];
}

class ServicesDashboardLoading extends ServicesDashboardState {
  const ServicesDashboardLoading();
}

class ServicesDashboardLoaded extends ServicesDashboardState {
  final ServicesDashboardData data;

  const ServicesDashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}
