// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_position_analytics_data.dart
// Purpose: Defines HR dashboard position analytics distributions.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

import 'hr_dashboard_distribution_item.dart';

/// Contains workforce and position distributions for the HR dashboard.
class HrDashboardPositionAnalyticsData {
  static const employeeCategoryKey = 'employee';

  final List<HrDashboardDistributionItem> workforceDistribution;
  final List<HrDashboardDistributionItem> jobTypeDistribution;
  final List<HrDashboardDistributionItem> workArrangementDistribution;
  final List<HrDashboardDistributionItem> jobGradeDistribution;
  final bool hasData;

  const HrDashboardPositionAnalyticsData({
    required this.workforceDistribution,
    required this.jobTypeDistribution,
    required this.workArrangementDistribution,
    required this.jobGradeDistribution,
    required this.hasData,
  });
}
