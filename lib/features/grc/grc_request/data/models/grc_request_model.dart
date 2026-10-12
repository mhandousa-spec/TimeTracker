/// Module: GRC Request Management
/// Description: Firestore model for a GRC approval request. Unlike
///              ChampionModel/PolicyModel, this is NOT a history list — a
///              request is a single decided event (create, then optionally
///              approve/reject once), so its status/decision fields are
///              plain mutable values, not append-only revision lists.
///              Firestore path: GRC Modules/{Module_ID}/Champion Requests/{Request_ID}.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-25
/// Dependencies: AssigningControlModel, GrcRequestEntity, GrcRequestType, ApprovalStatus, intl

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/control/data/models/assigning_control_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';


final DateFormat _requestDateFormat = DateFormat('d MMM yyyy', 'en');

class GrcRequestModel {
  static const String _keyRequestId = 'Request_ID';
  static const String _keyType = 'Type';
  static const String _keyStatus = 'Status';
  static const String _keyRequestedBy = 'Requested_By';
  static const String _keyRequestDate = 'Request_Date';
  static const String _keyNote = 'Note';
  static const String _keyRejectionReason = 'Rejection_Reason';
  static const String _keyDecidedBy = 'Decided_By';
  static const String _keyDecisionDate = 'Decision_Date';
  static const String _keyCurrentChampionEmail = 'Current_Champion_Email';
  static const String _keyNewChampionEmail = 'New_Champion_Email';
  static const String _keyCurrentOwnerEmail = 'Current_Owner_Email';
  static const String _keyNewOwnerEmail = 'New_Owner_Email';
  static const String _keyControls = 'Controls';
  static const String _keyStartDate = 'Start_Date';
  static const String _keyEndDate = 'End_Date';
  static const String _keyAppliedAt = 'Applied_At';

  final String id;
  final String moduleId;
  final String type; // GrcRequestType.value
  final String status; // 'pending' | 'approved' | 'rejected'
  final String requestedBy;
  final DateTime requestDate;
  final String note;

  final String? rejectionReason;
  final String? decidedBy;
  final DateTime? decisionDate;

  final String? currentChampionEmail;
  final String? newChampionEmail;
  final String? currentOwnerEmail;
  final String? newOwnerEmail;
  final List<AssigningControlModel>? controls;
  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? appliedAt;

  const GrcRequestModel({
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

  /// Only the fields the request-decision flow ever changes are
  /// parameterized — every other field always passes through unchanged.
  /// Extracted because the repository previously re-typed all 17 fields
  /// by hand in 4 near-identical methods to change just 1-2 of them.
  GrcRequestModel copyWith({
    String? status,
    String? rejectionReason,
    String? decidedBy,
    DateTime? decisionDate,
    DateTime? appliedAt,
  }) {
    return GrcRequestModel(
      id: id,
      moduleId: moduleId,
      type: type,
      status: status ?? this.status,
      requestedBy: requestedBy,
      requestDate: requestDate,
      note: note,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      decidedBy: decidedBy ?? this.decidedBy,
      decisionDate: decisionDate ?? this.decisionDate,
      currentChampionEmail: currentChampionEmail,
      newChampionEmail: newChampionEmail,
      currentOwnerEmail: currentOwnerEmail,
      newOwnerEmail: newOwnerEmail,
      controls: controls,
      startDate: startDate,
      endDate: endDate,
      appliedAt: appliedAt ?? this.appliedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyRequestId: id,
      GrcFirestoreKeys.moduleId: moduleId,
      _keyType: type,
      _keyStatus: status,
      _keyRequestedBy: requestedBy,
      _keyRequestDate: _requestDateFormat.format(requestDate),
      _keyNote: note,
      _keyRejectionReason: rejectionReason,
      _keyDecidedBy: decidedBy,
      _keyDecisionDate:
          decisionDate != null ? _requestDateFormat.format(decisionDate!) : null,
      _keyCurrentChampionEmail: currentChampionEmail,
      _keyNewChampionEmail: newChampionEmail,
      _keyCurrentOwnerEmail: currentOwnerEmail,
      _keyNewOwnerEmail: newOwnerEmail,
      _keyControls: controls?.map((c) => c.toJson()).toList(),
      _keyStartDate: startDate != null ? _requestDateFormat.format(startDate!) : null,
      _keyEndDate: endDate != null ? _requestDateFormat.format(endDate!) : null,
      _keyAppliedAt: appliedAt != null ? _requestDateFormat.format(appliedAt!) : null,
    };
  }

  factory GrcRequestModel.fromJson(Map<String, dynamic> json) {
    final decisionDateRaw = json[_keyDecisionDate] as String?;
    final startDateRaw = json[_keyStartDate] as String?;
    final endDateRaw = json[_keyEndDate] as String?;
    final appliedAtRaw = json[_keyAppliedAt] as String?;
    return GrcRequestModel(
      id: json[_keyRequestId] as String,
      moduleId: json[GrcFirestoreKeys.moduleId] as String,
      type: json[_keyType] as String,
      status: json[_keyStatus] as String,
      requestedBy: json[_keyRequestedBy] as String,
      requestDate: _requestDateFormat.parse(json[_keyRequestDate] as String),
      note: json[_keyNote] as String? ?? '',
      rejectionReason: json[_keyRejectionReason] as String?,
      decidedBy: json[_keyDecidedBy] as String?,
      decisionDate:
          decisionDateRaw != null ? _requestDateFormat.parse(decisionDateRaw) : null,
      currentChampionEmail: json[_keyCurrentChampionEmail] as String?,
      newChampionEmail: json[_keyNewChampionEmail] as String?,
      currentOwnerEmail: json[_keyCurrentOwnerEmail] as String?,
      newOwnerEmail: json[_keyNewOwnerEmail] as String?,
      controls: (json[_keyControls] as List?)
          ?.map((c) => AssigningControlModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      startDate: startDateRaw != null ? _requestDateFormat.parse(startDateRaw) : null,
      endDate: endDateRaw != null ? _requestDateFormat.parse(endDateRaw) : null,
      appliedAt: appliedAtRaw != null ? _requestDateFormat.parse(appliedAtRaw) : null,
    );
  }

  GrcRequestEntity toEntity() {
    return GrcRequestEntity(
      id: id,
      moduleId: moduleId,
      type: GrcRequestType.fromString(type),
      status: ApprovalStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => ApprovalStatus.pending,
      ),
      requestedBy: requestedBy,
      requestDate: requestDate,
      note: note,
      rejectionReason: rejectionReason,
      decidedBy: decidedBy,
      decisionDate: decisionDate,
      currentChampionEmail: currentChampionEmail,
      newChampionEmail: newChampionEmail,
      currentOwnerEmail: currentOwnerEmail,
      newOwnerEmail: newOwnerEmail,
      controls: controls?.map((c) => c.toEntity()).toList(),
      startDate: startDate,
      endDate: endDate,
      appliedAt: appliedAt,
    );
  }
}
