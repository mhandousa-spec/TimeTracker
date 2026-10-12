// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_demographics_data.dart
// Purpose: Defines HR dashboard demographic distributions.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

import 'hr_dashboard_distribution_item.dart';

/// Contains gender, marital-status, and employee-total dashboard data.
class HrDashboardDemographicsData {
  final List<HrDashboardDistributionItem> genderDistribution;
  final List<HrDashboardDistributionItem> maritalStatusDistribution;
  final int filteredEmployeeTotal;

  const HrDashboardDemographicsData({
    required this.genderDistribution,
    required this.maritalStatusDistribution,
    required this.filteredEmployeeTotal,
  });
}
