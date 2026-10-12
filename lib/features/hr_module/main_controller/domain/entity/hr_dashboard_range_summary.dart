// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_range_summary.dart
// Purpose: Defines minimum, average, and maximum dashboard values.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

/// Represents minimum, average, and maximum values for a dashboard metric.
class HrDashboardRangeSummary {
  const HrDashboardRangeSummary({
    required this.minimum,
    required this.average,
    required this.maximum,
    required this.hasData,
  });

  final int? minimum;
  final int? average;
  final int? maximum;
  final bool hasData;
}
