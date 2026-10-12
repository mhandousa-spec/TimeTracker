/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_state.dart
/// Purpose: States emitted by [GrcDashboardCubit], and [GrcDashboardFilters] —
///          every dropdown / toggle on the dashboard.
/// Author: Amr Mesbah
/// Created: 16/9/2026
library;

import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_color_coding.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';

/// Sentinel so copyWith can set a nullable field back to null.
const Object _keep = Object();

class GrcDashboardFilters {
  /// Top-right Department dropdown: filters the two donuts and Policy
  /// Compliance.
  final String? department;

  /// Policy Compliance Sort. null = unsorted, true = ASC, false = DES.
  final bool? complianceAscending;

  /// Departments card.
  final String? departmentsPolicyId;
  final String? departmentsControlId;
  final bool? departmentsAscending;

  /// Department Performance card.
  final String? performancePolicyId;
  final String? performanceControlId;
  final bool performanceTop;

  /// Compliance Timeline card.
  final bool timelineBaseline;
  final String? timelinePolicyId;
  final String? timelineControlId;
  final String? timelineDepartment;

  const GrcDashboardFilters({
    this.department,
    this.complianceAscending,
    this.departmentsPolicyId,
    this.departmentsControlId,
    this.departmentsAscending,
    this.performancePolicyId,
    this.performanceControlId,
    this.performanceTop = true,
    this.timelineBaseline = false,
    this.timelinePolicyId,
    this.timelineControlId,
    this.timelineDepartment,
  });

  GrcDashboardFilters copyWith({
    Object? department = _keep,
    Object? complianceAscending = _keep,
    Object? departmentsPolicyId = _keep,
    Object? departmentsControlId = _keep,
    Object? departmentsAscending = _keep,
    Object? performancePolicyId = _keep,
    Object? performanceControlId = _keep,
    bool? performanceTop,
    bool? timelineBaseline,
    Object? timelinePolicyId = _keep,
    Object? timelineControlId = _keep,
    Object? timelineDepartment = _keep,
  }) {
    T pick<T>(Object? v, T current) => identical(v, _keep) ? current : v as T;
    return GrcDashboardFilters(
      department: pick<String?>(department, this.department),
      complianceAscending:
          pick<bool?>(complianceAscending, this.complianceAscending),
      departmentsPolicyId:
          pick<String?>(departmentsPolicyId, this.departmentsPolicyId),
      departmentsControlId:
          pick<String?>(departmentsControlId, this.departmentsControlId),
      departmentsAscending:
          pick<bool?>(departmentsAscending, this.departmentsAscending),
      performancePolicyId:
          pick<String?>(performancePolicyId, this.performancePolicyId),
      performanceControlId:
          pick<String?>(performanceControlId, this.performanceControlId),
      performanceTop: performanceTop ?? this.performanceTop,
      timelineBaseline: timelineBaseline ?? this.timelineBaseline,
      timelinePolicyId: pick<String?>(timelinePolicyId, this.timelinePolicyId),
      timelineControlId:
          pick<String?>(timelineControlId, this.timelineControlId),
      timelineDepartment:
          pick<String?>(timelineDepartment, this.timelineDepartment),
    );
  }
}

sealed class GrcDashboardState {
  const GrcDashboardState();
}

final class GrcDashboardInitial extends GrcDashboardState {
  const GrcDashboardInitial();
}

final class GrcDashboardLoading extends GrcDashboardState {
  const GrcDashboardLoading();
}

final class GrcDashboardLoaded extends GrcDashboardState {
  final GrcDashboardData data;
  final GrcDashboardFilters filters;

  /// Per category; policy starts with the design's red / orange / green.
  final Map<GrcColorCategory, GrcColorRule> colorRules;

  const GrcDashboardLoaded({
    required this.data,
    this.filters = const GrcDashboardFilters(),
    this.colorRules = const {
      GrcColorCategory.policy: kDefaultPolicyColorRule,
    },
  });

  GrcDashboardLoaded copyWith({
    GrcDashboardFilters? filters,
    Map<GrcColorCategory, GrcColorRule>? colorRules,
  }) =>
      GrcDashboardLoaded(
        data: data,
        filters: filters ?? this.filters,
        colorRules: colorRules ?? this.colorRules,
      );
}

final class GrcDashboardFailure extends GrcDashboardState {
  final String message;

  const GrcDashboardFailure(this.message);
}
