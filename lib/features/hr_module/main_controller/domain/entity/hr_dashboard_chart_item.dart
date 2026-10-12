// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_chart_item.dart
// Purpose: Defines one HR dashboard chart item.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

/// Represents one chart category and its count.
class HrDashboardChartItem {
  final String category;
  final int count;

  const HrDashboardChartItem({
    required this.category,
    required this.count,
  });
}
