/// Module: GRC Control
/// Description: Shared "would-be" status computation for a Control from its
///              own effective Start Date and whether it currently has any
///              Champion/Owner assigned — the single source of truth for the
///              Unassigned/Scheduled/Active decision, reused by every place
///              a Control's status needs recomputing after an assignment
///              change (Control bulk upload, and the Champion/Owner
///              assignment pages). The single Add/Edit Control page keeps
///              its own richer, private version of this same date logic
///              (it also has to fold in Draft/manual-Inactive handling that
///              doesn't belong in a shared, assignment-only helper).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-22
/// Dependencies: control_status.dart
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';

/// function name: [computeAssigneeBasedControlStatus]
///
/// purpose: decide Unassigned vs Scheduled vs Active for a Control —
///          Unassigned whenever nobody is currently assigned as Champion or
///          Owner, otherwise Scheduled if [effectiveStartDate] hasn't
///          arrived yet (strictly after today) or Active if it has. Callers
///          are responsible for not invoking this over a Control whose
///          current status is Draft, Inactive, or Expired — those are
///          lifecycle states outside an assignment change's authority (see
///          [shouldRecomputeAssigneeBasedStatus]).
///
/// parameters:
///            [DateTime] effectiveStartDate: the control's own Start Date
///            [bool] hasAnyAssignee: whether at least one Champion or Owner is currently assigned
///
/// return type: [ControlStatus] - unassigned, scheduled, or active
ControlStatus computeAssigneeBasedControlStatus({
  required DateTime effectiveStartDate,
  required bool hasAnyAssignee,
}) {
  if (!hasAnyAssignee) return ControlStatus.unassigned;
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return effectiveStartDate.isAfter(startOfToday)
      ? ControlStatus.scheduled
      : ControlStatus.active;
}

/// function name: [shouldRecomputeAssigneeBasedStatus]
///
/// purpose: guard for [computeAssigneeBasedControlStatus] — Draft (not yet
///          published), Inactive (manually deactivated), and Expired (past
///          its End Date) are lifecycle states an assignment change must
///          never override. Only Unassigned/Scheduled/Active are this
///          function's territory.
///
/// parameters:
///            [ControlStatus] currentStatus: the control's status before this assignment change
///
/// return type: [bool] - true if [computeAssigneeBasedControlStatus] may be applied
bool shouldRecomputeAssigneeBasedStatus(ControlStatus currentStatus) {
  return currentStatus != ControlStatus.draft &&
      currentStatus != ControlStatus.inactive &&
      currentStatus != ControlStatus.expired;
}
