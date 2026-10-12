/// Module: GRC / Dashboard Of All Departments
/// Description: Everything the module's Departments tab and its Reporting
///              and Audit page draw, loaded once per module and filtered in
///              memory by department / policy / control.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
/// Dependencies: PolicyEntity, ControlEntity, OwnerEntity, ChampionEntity
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';

/// class name: [DepartmentControlRef]
///
/// purpose: one Control together with the Policy it belongs to and the
///          people assigned to it (owner / champion emails, when known).
class DepartmentControlRef {
  final PolicyEntity policy;
  final ControlEntity control;
  final String? ownerEmail;
  final String? championEmail;

  const DepartmentControlRef({
    required this.policy,
    required this.control,
    this.ownerEmail,
    this.championEmail,
  });

  /// The trimmed, non-empty department names this control is weighted on.
  Set<String> get departments => {
        for (final d in control.departments)
          if (d.department.trim().isNotEmpty) d.department.trim(),
      };
}

/// One month's bar on the Analytics chart.
class DepartmentMonthScore {
  final DateTime month;
  final double value;

  const DepartmentMonthScore({required this.month, required this.value});
}

/// class name: [DepartmentDashboardData]
///
/// purpose: the loaded snapshot plus every derived number the screens need.
///          A null [department] everywhere means "all departments".
class DepartmentDashboardData {
  DepartmentDashboardData({
    required List<PolicyEntity> policies,
    required this.controls,
  }) : policies = policies
            .where((p) => p.status != PolicyStatus.removed)
            .toList(growable: false);

  /// Every non-removed policy of the module.
  final List<PolicyEntity> policies;

  /// Every control of those policies.
  final List<DepartmentControlRef> controls;

  /// Control statuses that count toward a score (same set the score
  /// roll-up uses).
  static const Set<ControlStatus> scoredStatuses = {
    ControlStatus.active,
    ControlStatus.scheduled,
    ControlStatus.unassigned,
  };

  /// All department names found on the module's controls, first-seen order.
  List<String> get departments {
    final out = <String>[];
    for (final ref in controls) {
      for (final d in ref.departments) {
        if (!out.contains(d)) out.add(d);
      }
    }
    return out;
  }

  /// Controls weighted on [department] (all when null), optionally limited
  /// to one policy.
  List<DepartmentControlRef> controlsFor({
    String? department,
    String? policyId,
  }) {
    return controls
        .where((c) =>
            (department == null || c.departments.contains(department)) &&
            (policyId == null || c.policy.id == policyId))
        .toList(growable: false);
  }

  /// Policies that have at least one control in [department] (all
  /// policies when null).
  List<PolicyEntity> policiesFor({String? department}) {
    if (department == null) return policies;
    final ids = {for (final c in controlsFor(department: department)) c.policy.id};
    return policies.where((p) => ids.contains(p.id)).toList(growable: false);
  }

  /// Number of controls under [policyId] inside [department].
  int controlCount(String policyId, {String? department}) =>
      controlsFor(department: department, policyId: policyId).length;

  /// "Compliance Score": the weight-averaged score of the scored controls
  /// in [department], 0–100. Falls back to a plain average when no control
  /// carries a weight.
  double complianceScore({String? department}) {
    final scored = controlsFor(department: department)
        .where((c) => scoredStatuses.contains(c.control.status))
        .toList();
    if (scored.isEmpty) return 0;
    double weight = 0;
    double sum = 0;
    for (final c in scored) {
      weight += c.control.controlsWeight;
      sum += c.control.score * c.control.controlsWeight;
    }
    final double value = weight > 0
        ? sum / weight
        : scored.fold<double>(0, (s, c) => s + c.control.score) / scored.length;
    return value.clamp(0, 100).toDouble();
  }

  /// "Applied Policies": active / scheduled policies in [department].
  int appliedPolicies({String? department}) => policiesFor(department: department)
      .where((p) =>
          p.status == PolicyStatus.active || p.status == PolicyStatus.scheduled)
      .length;

  /// "Applied Controls": scored controls in [department].
  int appliedControls({String? department}) => controlsFor(department: department)
      .where((c) => scoredStatuses.contains(c.control.status))
      .length;

  /// A control's score as it stood at the end of [monthEnd], read from its
  /// score history; null when it had no score yet.
  static int? scoreAt(ControlEntity control, DateTime monthEnd) {
    int? value;
    DateTime? at;
    for (final point in control.scoreHistory) {
      if (point.date.isAfter(monthEnd)) continue;
      if (at == null || !point.date.isBefore(at)) {
        at = point.date;
        value = point.score;
      }
    }
    if (value == null && control.scoreHistory.isEmpty &&
        !control.lastModifiedDate.isAfter(monthEnd)) {
      value = control.score;
    }
    return value;
  }

  /// The last [months] calendar months, oldest first, ending with [now]'s.
  static List<DateTime> lastMonths(DateTime now, {int months = 6}) => [
        for (var i = months - 1; i >= 0; i--) DateTime(now.year, now.month - i),
      ];

  static DateTime _monthEnd(DateTime month) =>
      DateTime(month.year, month.month + 1).subtract(const Duration(milliseconds: 1));

  /// Monthly compliance of one policy inside [department]: the weighted
  /// average of its controls' scores at each month end.
  List<DepartmentMonthScore> policyTimeline(
    String policyId, {
    String? department,
    required DateTime now,
  }) {
    final refs = controlsFor(department: department, policyId: policyId);
    return [
      for (final month in lastMonths(now))
        DepartmentMonthScore(
          month: month,
          value: () {
            final end = _monthEnd(month);
            double weight = 0;
            double sum = 0;
            int plainCount = 0;
            double plainSum = 0;
            for (final r in refs) {
              final s = scoreAt(r.control, end);
              if (s == null) continue;
              weight += r.control.controlsWeight;
              sum += s * r.control.controlsWeight;
              plainCount++;
              plainSum += s;
            }
            if (weight > 0) return sum / weight;
            return plainCount == 0 ? 0.0 : plainSum / plainCount;
          }(),
        ),
    ];
  }

  /// Monthly score of one control.
  List<DepartmentMonthScore> controlTimeline(
    ControlEntity control, {
    required DateTime now,
  }) =>
      [
        for (final month in lastMonths(now))
          DepartmentMonthScore(
            month: month,
            value: (scoreAt(control, _monthEnd(month)) ?? 0).toDouble(),
          ),
      ];
}
