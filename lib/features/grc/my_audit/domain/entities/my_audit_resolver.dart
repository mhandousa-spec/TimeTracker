/// Module: My Audits (Control Owner)
/// Description: Pure join/derivation logic for the Owner's My Audits list —
///              no persistence, no side effects. See
///              docs/superpowers/specs/2026-07-28-my-audits-design.md
///              Section "Building the Owner's list".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'my_audit_entity.dart';
import 'my_audit_item.dart';
import 'my_audit_status.dart';
import 'my_audit_tab.dart';

/// Derives which tab an audit belongs to. `null` (no audit exists yet for
/// this control+champion pair) always means [MyAuditTab.overdue].
MyAuditTab computeMyAuditTab(MyAuditEntity? audit) {
  if (audit == null) return MyAuditTab.overdue;
  switch (audit.status) {
    case MyAuditStatus.pending:
      return MyAuditTab.pending;
    case MyAuditStatus.outstanding:
      return MyAuditTab.outstanding;
    case MyAuditStatus.scored:
      return MyAuditTab.scored;
    case MyAuditStatus.rejected:
      return MyAuditTab.rejected;
  }
}

/// Joins every [audits] entry with its linked [assignmentControls] (keyed by
/// Assignment_Controls doc id, i.e. [MyAuditEntity.submissionId]), keeping
/// only the ones whose Assignment Control's `controlOwner` matches
/// [ownerEmail], then resolves each one's Control/Policy from the
/// already-loaded [policyControls]/[policies] maps. Additionally,
/// synthesizes a read-only, derived Overdue row for every pair in
/// [ownerAssigningControls] (this Owner's own assigned controls, from
/// OwnerModel) that has NO linked Assignment_Controls doc at all and whose
/// Control's `endDate` has passed — meaning the Champion never submitted,
/// so no Approval/My_Audit chain exists for it yet.
List<MyAuditItem> buildMyAuditItems({
  required List<MyAuditEntity> audits,
  required Map<String, AssignmentControlEntity> assignmentControls,
  required List<AssigningControlEntity> ownerAssigningControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, PolicyEntity> policies,
  required String ownerEmail,
}) {
  final items = <MyAuditItem>[];
  final covered = <String>{};

  for (final audit in audits) {
    final assignmentControl = assignmentControls[audit.submissionId];
    if (assignmentControl == null) continue;
    if (assignmentControl.controlOwner != ownerEmail) continue;
    final control = findControlInPolicy(
      policyControls,
      assignmentControl.policyId,
      assignmentControl.controlId,
    );
    if (control == null) continue;
    final policy = policies[assignmentControl.policyId];
    if (policy == null) continue;
    covered.add('${assignmentControl.policyId}_${assignmentControl.controlId}');
    items.add(MyAuditItem(
      audit: audit,
      assignmentControl: assignmentControl,
      control: control,
      policy: policy,
      tab: computeMyAuditTab(audit),
    ));
  }

  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  for (final ac in ownerAssigningControls) {
    final key = '${ac.policyId}_${ac.controlId}';
    if (covered.contains(key)) continue;
    final control = findControlInPolicy(policyControls, ac.policyId, ac.controlId);
    if (control == null) continue;
    final startOfEnd =
        DateTime(control.endDate.year, control.endDate.month, control.endDate.day);
    if (!startOfEnd.isBefore(startOfToday)) continue;
    final policy = policies[ac.policyId];
    if (policy == null) continue;
    items.add(MyAuditItem(
      audit: null,
      assignmentControl: null,
      control: control,
      policy: policy,
      tab: MyAuditTab.overdue,
    ));
  }

  return items;
}
