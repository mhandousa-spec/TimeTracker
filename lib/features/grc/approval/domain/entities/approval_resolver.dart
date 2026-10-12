/// Module: Approvals (Department Manager)
/// Description: Pure join/derivation logic for the manager's Approvals
///              list, and the Chief-title Department Manager resolution
///              used at Champion submit time — no persistence, no side
///              effects. See docs/superpowers/specs/2026-07-28-approvals-design.md.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'approval_entity.dart';
import 'approval_item.dart';
import 'approval_status.dart';

/// Visual identity (color + icon) for one [ApprovalStatus], shared by the
/// status pill on the Approvals card, tab bar, and details page.
class ApprovalStatusStyle {
  final Color color;
  final IconData icon;

  const ApprovalStatusStyle({required this.color, required this.icon});

  static ApprovalStatusStyle of(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return ApprovalStatusStyle(color: AppColors.warning, icon: Icons.schedule);
      case ApprovalStatus.approved:
        return const ApprovalStatusStyle(color: Colors.green, icon: Icons.check_circle);
      case ApprovalStatus.rejected:
        return const ApprovalStatusStyle(color: Colors.red, icon: Icons.block);
    }
  }
}

/// Finds the Department Manager for [championEmail]: another employee
/// sharing the champion's `departmentId` whose `title` starts with "Chief"
/// (case-insensitive). Returns null if the champion isn't found, has no
/// department, or no such peer exists — a valid, expected outcome (the
/// submission still succeeds with `Department_Manager` left null).
String? findDepartmentManagerEmail(
  List<EmployeeEntityPro> employees, {
  required String championEmail,
}) {
  String norm(String? v) => (v ?? '').trim().toLowerCase();
  final String champ = norm(championEmail);

  EmployeeEntityPro? champion;
  for (final e in employees) {
    if (norm(e.email) == champ) {
      champion = e;
      break;
    }
  }
  if (champion == null) return null;

  // FIXED 28/9/2026 (GRC bug report p7 — evidence never reached the
  // supervisor). The reviewer is the champion's own SUPERVISOR from the org
  // chart (Employees_Info.Supervisor, an email). This used to pick whoever in
  // the champion's department had a title starting with "Chief" — so a
  // Marketing champion's evidence went to the CMO, not to the Marketing
  // Manager they actually report to, and never showed in that manager's
  // Approvals. The old rule stays only as a fallback for employees with no
  // supervisor set.
  final String supervisor = norm(champion.supervisor);
  if (supervisor.isNotEmpty && supervisor != champ) return supervisor;

  final departmentId = champion.departmentId;
  if (departmentId == null) return null;

  for (final e in employees) {
    if (norm(e.email) == champ) continue;
    if (e.departmentId != departmentId) continue;
    if (e.title?.trim().toLowerCase().startsWith('chief') ?? false) {
      return norm(e.email);
    }
  }
  return null;
}

/// Joins every [approvals] entry (any status — All/Approved/Pending/Rejected
/// are all shown to the manager, filtered client-side by the list page) with
/// its linked [assignmentControls] (keyed by Assignment_Controls doc id,
/// i.e. [ApprovalEntity.submissionId]), keeping only the ones whose
/// Assignment Control's `departmentManager` matches [managerEmail], then
/// resolves each one's Control/Policy from the already-loaded
/// [policyControls]/[policies] maps. A pair whose Assignment Control,
/// Control, or Policy can't be found is silently skipped.
List<ApprovalItem> buildApprovalItems({
  required List<ApprovalEntity> approvals,
  required Map<String, AssignmentControlEntity> assignmentControls,
  required Map<String, List<ControlEntity>> policyControls,
  required Map<String, PolicyEntity> policies,
  required String managerEmail,
  /// true for a Module Owner (GRC bug report p3): every approval in the
  /// module, not only the ones [managerEmail] supervises.
  bool includeAll = false,
}) {
  final items = <ApprovalItem>[];
  for (final approval in approvals) {
    final assignmentControl = assignmentControls[approval.submissionId];
    if (assignmentControl == null) continue;
    // Case/space-insensitive: emails reach here from several screens.
    if (!includeAll &&
        (assignmentControl.departmentManager ?? '').trim().toLowerCase() !=
            managerEmail.trim().toLowerCase()) {
      continue;
    }
    final control = findControlInPolicy(
      policyControls,
      assignmentControl.policyId,
      assignmentControl.controlId,
    );
    if (control == null) continue;
    final policy = policies[assignmentControl.policyId];
    if (policy == null) continue;
    items.add(ApprovalItem(
      approval: approval,
      assignmentControl: assignmentControl,
      control: control,
      policy: policy,
    ));
  }
  return items;
}
