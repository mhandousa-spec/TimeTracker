/// Module: knowledge_hub / presentation / cubit / dashboard_cubit/dashboard_states.dart
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_states.dart
/// Purpose: Dashboard states — knowledge_hub cubit/state layer.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Example of what your DashboardLoaded state should look like
// Add the monthlyRemoved field to your existing DashboardStates file

abstract class DashboardStates {}

class DashboardInitial extends DashboardStates {}

class DashboardLoading extends DashboardStates {}

class DashboardEmpty extends DashboardStates {}

class DashboardError extends DashboardStates {
  final String error;
  DashboardError(this.error);
}

class DashboardLoaded extends DashboardStates {
  final Map<String, int> statusCounts;
  final Map<String, int> departmentCounts;
  final int totalViews;
  final int totalDownloads;
  final Map<String, int> monthlyUploaded;
  final Map<String, int> monthlyPublished;
  final Map<String, int> monthlyRemoved;    // ✅ ADD THIS LINE
  final Map<String, int> monthlyDownloads;
  final Map<String, int> monthlyViews;
  final Map<String, int> extensionCounts;
  final Map<String, String> departmentNames;
  final int totalRemovedCount;
  final int totalPublishedCount;

  DashboardLoaded({
    required this.statusCounts,
    required this.departmentCounts,
    required this.totalViews,
    required this.totalDownloads,
    required this.monthlyUploaded,
    required this.monthlyPublished,
    required this.monthlyRemoved,    // ✅ ADD THIS LINE
    required this.monthlyDownloads,
    required this.monthlyViews,
    required this.extensionCounts,
    required this.departmentNames,
    required this.totalRemovedCount,
    required this.totalPublishedCount,
  });
}