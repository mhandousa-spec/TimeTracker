// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_overall_data.dart
// Purpose: Defines overall HR dashboard statistics.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

/// Contains the overall summary values displayed by the HR dashboard.
class HrDashboardOverallData {
  final int totalEmployees;
  final int totalDepartments;
  final int onboardingEmployees;
  final int scheduledLeave;
  final int attendanceCompliance;
  final bool hasData;

  const HrDashboardOverallData({
    required this.totalEmployees,
    required this.totalDepartments,
    required this.onboardingEmployees,
    required this.scheduledLeave,
    required this.attendanceCompliance,
    required this.hasData,
  });
}
