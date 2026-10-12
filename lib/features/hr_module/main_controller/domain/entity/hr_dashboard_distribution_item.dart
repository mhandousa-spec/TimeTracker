// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_distribution_item.dart
// Purpose: Defines one categorized HR dashboard distribution item.
// Author: Mohamed Elrashidy
// Created At: 2026-08-21
// ********************************************************************* //

/// Represents one category and its dashboard count.
class HrDashboardDistributionItem {
  final String category;
  final int count;

  const HrDashboardDistributionItem({
    required this.category,
    required this.count,
  });
}
