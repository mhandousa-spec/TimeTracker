/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_stats.dart
/// Purpose: The data behind the GRC Dashboard (Figma MAGDY, "MAIN PAGE :
///          Main Dashboard" — GRC > Module Name > Dashboard) and the pure
///          functions that turn it into each card's figures:
///            * Policies / Controls donuts (status counts)
///            * Policy Compliance (per policy, 0–100)
///            * Departments (per department, 0–100)
///            * Department Performance (top / least departments)
///            * Compliance Timeline (per month, 0–100, from score history)
/// Author: Amr Mesbah
/// Created: 16/9/2026
/// Updated: 16/9/2026 — rebuilt against the Figma frame.
///
/// Rules (so the dashboard agrees with the rest of GRC):
/// * Status counts use the stored status, like the filter chips.
/// * A policy's compliance is its own grade: score / weight × 100 —
///   policy.score is the weighted share it earned (computePolicyScore).
/// * Department / timeline figures average CONTROL scores (0–100) over the
///   weight-scoped controls only (Active / Scheduled / Unassigned), the same
///   set computePolicyScore counts.
/// * The timeline reads each control's saved score history
///   (ControlEntity.scoreHistory) — the score in force at each month end.
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';

/// * [module] — the Dashboard button inside one module.
/// * [main]   — the Dashboard button on the GRC root page (every module).
enum GrcDashboardScope { module, main }

/// One module's records, fully loaded.
class GrcModuleSnapshot {
  final GRCModuleEntity module;
  final List<PolicyEntity> policies;

  /// Keyed by policy id. A policy whose controls could not be read has no
  /// entry — it contributes nothing rather than a wrong zero.
  final Map<String, List<ControlEntity>> controlsByPolicy;

  const GrcModuleSnapshot({
    required this.module,
    required this.policies,
    required this.controlsByPolicy,
  });
}

/// A control together with the policy it belongs to.
class GrcControlRef {
  final PolicyEntity policy;
  final ControlEntity control;

  const GrcControlRef(this.policy, this.control);

  Set<String> get departments => {
        for (final d in control.departments)
          if (d.department.trim().isNotEmpty) d.department.trim(),
      };
}

/// A bar: a label (already a record name or a raw department key) and a
/// 0–100 value. [id] is the policy id for policy bars, the department for
/// department bars.
class GrcBar {
  final String id;
  final String labelEn;
  final String labelAr;
  final double value;

  const GrcBar({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.value,
  });

  String label({required bool isArabic}) =>
      isArabic && labelAr.trim().isNotEmpty ? labelAr : labelEn;
}

class GrcDashboardData {
  final GrcDashboardScope scope;
  final List<GrcModuleSnapshot> snapshots;

  GrcDashboardData({required this.scope, required this.snapshots})
      : policies = [
          for (final s in snapshots)
            ...s.policies.where((p) => p.status != PolicyStatus.removed),
        ],
        controls = [
          for (final s in snapshots)
            for (final p in s.policies)
              if (p.status != PolicyStatus.removed)
                for (final c in s.controlsByPolicy[p.id] ?? const <ControlEntity>[])
                  GrcControlRef(p, c),
        ];

  final List<PolicyEntity> policies;
  final List<GrcControlRef> controls;

  static const Set<ControlStatus> weightScopedControls = {
    ControlStatus.active,
    ControlStatus.scheduled,
    ControlStatus.unassigned,
  };

  static const Set<PolicyStatus> weightScopedPolicies = {
    PolicyStatus.active,
    PolicyStatus.scheduled,
  };

  /// Every department any control carries, first-seen order.
  List<String> get departments {
    final out = <String>[];
    for (final ref in controls) {
      for (final d in ref.departments) {
        if (!out.contains(d)) out.add(d);
      }
    }
    return out;
  }

  /// Controls of one policy (all when [policyId] is null).
  List<GrcControlRef> controlsOf(String? policyId) => policyId == null
      ? controls
      : controls.where((c) => c.policy.id == policyId).toList();

  Iterable<GrcControlRef> _filtered({
    String? department,
    String? policyId,
    String? controlId,
  }) =>
      controls.where((c) =>
          (policyId == null || c.policy.id == policyId) &&
          (controlId == null || c.control.id == controlId) &&
          (department == null || c.departments.contains(department)));

  // ── Donuts ─────────────────────────────────────────────────────────────

  /// Policies in [department] (any of their controls carries it), by status.
  Map<PolicyStatus, int> policyStatusCounts({String? department}) {
    final ids = department == null
        ? null
        : {for (final c in _filtered(department: department)) c.policy.id};
    final out = <PolicyStatus, int>{};
    for (final p in policies) {
      if (ids != null && !ids.contains(p.id)) continue;
      out[p.status] = (out[p.status] ?? 0) + 1;
    }
    return out;
  }

  Map<ControlStatus, int> controlStatusCounts({String? department}) {
    final out = <ControlStatus, int>{};
    for (final c in _filtered(department: department)) {
      out[c.control.status] = (out[c.control.status] ?? 0) + 1;
    }
    return out;
  }

  // ── Policy Compliance ──────────────────────────────────────────────────

  /// Active / Scheduled policies, each its own 0–100 grade.
  /// [ascending] null keeps load order.
  List<GrcBar> policyCompliance({String? department, bool? ascending}) {
    final ids = department == null
        ? null
        : {for (final c in _filtered(department: department)) c.policy.id};
    final bars = <GrcBar>[
      for (final p in policies)
        if (weightScopedPolicies.contains(p.status) &&
            (ids == null || ids.contains(p.id)))
          GrcBar(
            id: p.id,
            labelEn: p.policyNameEn,
            labelAr: p.policyNameAr,
            value: clampScore(
                p.policyWeight > 0 ? p.score / p.policyWeight * 100 : 0),
          ),
    ];
    return _sort(bars, ascending);
  }

  // ── Departments / Department Performance ───────────────────────────────

  /// Mean weight-scoped control score per department.
  List<GrcBar> departmentScores({
    String? policyId,
    String? controlId,
    bool? ascending,
  }) {
    final sum = <String, double>{};
    final count = <String, int>{};
    for (final c in _filtered(policyId: policyId, controlId: controlId)) {
      if (!weightScopedControls.contains(c.control.status)) continue;
      for (final d in c.departments) {
        sum[d] = (sum[d] ?? 0) + c.control.score;
        count[d] = (count[d] ?? 0) + 1;
      }
    }
    final bars = <GrcBar>[
      for (final d in sum.keys)
        GrcBar(
          id: d,
          labelEn: d,
          labelAr: d,
          value: clampScore(sum[d]! / count[d]!),
        ),
    ];
    return _sort(bars, ascending);
  }

  /// The [limit] best ([top] true) or worst departments.
  List<GrcBar> departmentPerformance({
    String? policyId,
    String? controlId,
    required bool top,
    int limit = 5,
  }) =>
      departmentScores(
        policyId: policyId,
        controlId: controlId,
        ascending: !top,
      ).take(limit).toList();

  // ── Compliance Timeline ────────────────────────────────────────────────

  /// The last [months] calendar months ending with the month of [now]. Each
  /// value is the mean score in force at that month's end, over the
  /// weight-scoped controls that already had a saved score by then.
  List<({DateTime month, double value})> timeline({
    String? policyId,
    String? controlId,
    String? department,
    required DateTime now,
    int months = 6,
  }) {
    final refs = _filtered(
      policyId: policyId,
      controlId: controlId,
      department: department,
    ).where((c) => weightScopedControls.contains(c.control.status)).toList();

    final out = <({DateTime month, double value})>[];
    for (var i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthEnd = DateTime(month.year, month.month + 1);
      var sum = 0.0;
      var n = 0;
      for (final ref in refs) {
        final score = _scoreAt(ref.control, monthEnd);
        if (score == null) continue;
        sum += score;
        n++;
      }
      out.add((month: month, value: n == 0 ? 0 : clampScore(sum / n)));
    }
    return out;
  }

  static int? _scoreAt(ControlEntity control, DateTime before) {
    final history = control.scoreHistory;
    if (history.isEmpty) {
      // Entity not built from a model: only "now" is known.
      return control.lastModifiedDate.isBefore(before) ? control.score : null;
    }
    int? score;
    for (final point in history) {
      if (point.date.isBefore(before)) score = point.score;
    }
    return score;
  }

  // ── helpers ────────────────────────────────────────────────────────────

  static double clampScore(double v) =>
      v.isNaN ? 0 : v.clamp(0, 100).toDouble();

  static List<GrcBar> _sort(List<GrcBar> bars, bool? ascending) {
    if (ascending == null) return bars;
    bars.sort((a, b) =>
        ascending ? a.value.compareTo(b.value) : b.value.compareTo(a.value));
    return bars;
  }
}
