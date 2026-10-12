/// Module: Control Champion Management
/// Description: Pure "would-be" decisions for the Reassignment Request
///              workflow — mirrors control_status_resolver.dart's shape.
///              Shared by both Champion and Owner cubits (entity-agnostic:
///              operates on raw AssigningControlEntity lists and a
///              GrcRequestType, not on ChampionEntity specifically). No
///              persistence, no side effects: callers (Champion/Owner
///              Cubit) are responsible for acting on what these return.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestEntity, ApprovalStatus, AssigningControlEntity, GrcRequestType
library;

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';

/// function name: [findDueReassignmentRequests]
///
/// purpose: from a module's full request list, find every approved,
///          not-yet-applied Reassign request of [type] whose Start
///          Date has arrived (today >= startDate, compared at day
///          granularity) — these are the requests a caller must apply.
///
/// parameters:
///            [List<GrcRequestEntity>] requests: every request for one module
///            [GrcRequestType] type: which reassignment flow to resolve for
///            (Champion or Owner — defaults to Champion for existing callers)
///
/// return type: [List<GrcRequestEntity>] - requests ready to be applied
List<GrcRequestEntity> findDueReassignmentRequests(
  List<GrcRequestEntity> requests, {
  GrcRequestType type = GrcRequestType.reassignChampion,
}) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return requests.where((r) {
    if (r.type != type) return false;
    if (r.status != ApprovalStatus.approved) return false;
    if (r.appliedAt != null) return false;
    final startDate = r.startDate;
    if (startDate == null) return false;
    final startOfStart = DateTime(startDate.year, startDate.month, startDate.day);
    return !startOfStart.isAfter(startOfToday);
  }).toList();
}

/// function name: [findExpiredControls]
///
/// purpose: from a Champion's or Owner's current assigned controls, find
///          every control whose [AssigningControlEntity.expiresOn] has
///          passed (today >= expiresOn, compared at day granularity) —
///          these must be stripped so the control becomes unassigned.
///
/// parameters:
///            [List<AssigningControlEntity>] assigningControls: the
///            champion's/owner's current controls to check
///
/// return type: [List<AssigningControlEntity>] - controls that have expired
List<AssigningControlEntity> findExpiredControls(
  List<AssigningControlEntity> assigningControls,
) {
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  return assigningControls.where((c) {
    final expiresOn = c.expiresOn;
    if (expiresOn == null) return false;
    final startOfExpiry = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    return !startOfExpiry.isAfter(startOfToday);
  }).toList();
}
