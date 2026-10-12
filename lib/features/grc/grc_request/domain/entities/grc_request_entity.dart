/// Module: GRC Request Management
/// Description: Flat (non-list, non-history) representation of a GRC
///              approval request — populated for GrcRequestType.
///              reassignChampion (currentChampionEmail/newChampionEmail) and
///              GrcRequestType.reassignOwner (currentOwnerEmail/
///              newOwnerEmail). The reassign-specific fields are nullable
///              because a future controlChanges request would not use them.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: GrcRequestType, ApprovalStatus, AssigningControlEntity
library;

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';

class GrcRequestEntity {
  final String id;
  final String moduleId;
  final GrcRequestType type;
  final ApprovalStatus status;
  final String requestedBy;
  final DateTime requestDate;
  final String note;

  // Decision metadata — null until approved/rejected
  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  // Reassign-specific (null/unused for other request types)
  final String? currentChampionEmail;
  final String? newChampionEmail;
  final String? currentOwnerEmail;
  final String? newOwnerEmail;
  final List<AssigningControlEntity>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  // Set once the recompute-on-read transfer has actually run
  final DateTime? appliedAt;

  const GrcRequestEntity({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.status,
    required this.requestedBy,
    required this.requestDate,
    required this.note,
    this.rejectionReason,
    this.decidedBy,
    this.decisionDate,
    this.currentChampionEmail,
    this.newChampionEmail,
    this.currentOwnerEmail,
    this.newOwnerEmail,
    this.controls,
    this.startDate,
    this.endDate,
    this.appliedAt,
  });
}
