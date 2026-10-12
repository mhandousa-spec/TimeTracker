/// Module: GRC / Approved Evidence
/// Description: The approved submissions of one GRC module, joined with
///              their Control and Policy, plus the option lists the
///              Approved Evidence filters offer.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';

/// class name: [ApprovedEvidenceItem]
///
/// purpose: one approved piece of evidence — the approval decision, the
///          submission it approved, and the control / policy it belongs to.
class ApprovedEvidenceItem {
  final ApprovalEntity approval;
  final AssignmentControlEntity submission;
  final ControlEntity control;
  final PolicyEntity policy;

  const ApprovedEvidenceItem({
    required this.approval,
    required this.submission,
    required this.control,
    required this.policy,
  });

  /// When the manager approved it.
  DateTime get approvedAt => approval.lastModificationDate;

  Set<String> get departments => {
        for (final d in control.departments)
          if (d.department.trim().isNotEmpty) d.department.trim(),
      };
}

/// class name: [ApprovedEvidenceData]
///
/// purpose: the loaded evidence plus every policy / control of the module
///          (so the pickers list them even before anything is approved).
class ApprovedEvidenceData {
  final List<ApprovedEvidenceItem> items;
  final List<PolicyEntity> policies;
  final Map<String, List<ControlEntity>> controlsByPolicy;

  const ApprovedEvidenceData({
    required this.items,
    required this.policies,
    required this.controlsByPolicy,
  });

  /// Years that have approved evidence, newest first.
  List<int> get years {
    final set = {for (final i in items) i.approvedAt.year}.toList()
      ..sort((a, b) => b.compareTo(a));
    return set;
  }

  /// Every department weighted on any control, first-seen order.
  List<String> get departments {
    final out = <String>[];
    for (final controls in controlsByPolicy.values) {
      for (final c in controls) {
        for (final d in c.departments) {
          final name = d.department.trim();
          if (name.isNotEmpty && !out.contains(name)) out.add(name);
        }
      }
    }
    return out;
  }

  bool _inDepartments(ControlEntity c, Set<String> departments) =>
      departments.isEmpty ||
      c.departments.any((d) => departments.contains(d.department.trim()));

  /// Policies with at least one control in [departments] (all when empty).
  List<PolicyEntity> policiesFor(Set<String> departments) => policies
      .where((p) => (controlsByPolicy[p.id] ?? const <ControlEntity>[])
          .any((c) => _inDepartments(c, departments)))
      .toList(growable: false);

  /// Controls of [policyIds] (all policies when empty) in [departments].
  List<({PolicyEntity policy, ControlEntity control})> controlsFor(
    Set<String> policyIds,
    Set<String> departments,
  ) =>
      [
        for (final p in policies)
          if (policyIds.isEmpty || policyIds.contains(p.id))
            for (final c in controlsByPolicy[p.id] ?? const <ControlEntity>[])
              if (_inDepartments(c, departments)) (policy: p, control: c),
      ];

  /// Control ids are only unique inside their policy, so the Controls
  /// filter works on "policyId/controlId".
  static String controlKey(String policyId, String controlId) =>
      '$policyId/$controlId';

  /// The evidence matching every non-empty filter.
  List<ApprovedEvidenceItem> filter({
    required Set<int> years,
    required Set<String> departments,
    required Set<String> policyIds,
    required Set<String> controlIds,
  }) {
    return items
        .where((i) =>
            (years.isEmpty || years.contains(i.approvedAt.year)) &&
            (departments.isEmpty ||
                i.departments.any(departments.contains)) &&
            (policyIds.isEmpty || policyIds.contains(i.policy.id)) &&
            (controlIds.isEmpty ||
                controlIds.contains(controlKey(i.policy.id, i.control.id))))
        .toList()
      ..sort((a, b) => b.approvedAt.compareTo(a.approvedAt));
  }
}
