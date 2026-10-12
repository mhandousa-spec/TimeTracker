/// Module: Approvals (Department Manager)
/// Description: Firestore model for one Department Manager approval
///              decision on a Champion's Assignment Control submission,
///              following the same history-list pattern as
///              AssignmentControlModel: every mutable field is a `List<T>`,
///              index i is one revision. One document per control+champion
///              pair, reused across resubmission cycles (the linked
///              Assignment_Controls document already preserves the full
///              submission history, so this document only needs to track
///              the decision state, reset to Pending on each resubmit).
///              Firestore path:
///              GRC Modules/{Module_ID}/Approvals/{Approval_ID}
///              where Approval_ID = "{controlId}_{championEmail}".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
/// Dependencies: ApprovalEntity, ApprovalStatus, GrcFirestoreKeys
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:knowticed_plus/features/grc/approval/domain/entities/approval_status.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class ApprovalModel {
  static const String _keyRequestId = 'Request_ID';
  static const String _keySubmissionId = 'Submission_ID';
  static const String _keyStatus = 'Status';
  static const String _keyReasonsOfRejection = 'Reasons_of_Rejection';
  static const String _keyApprovalComments = 'Approval_Comments';
  // Deliberately NOT reusing the shared GrcFirestoreKeys.modifiers
  // ('Modifiers') — the schema given for this feature explicitly names
  // this field "Modifier" (singular), same convention as AssignmentControlModel.
  static const String _keyModifier = 'Modifier';

  final String requestId;
  final String submissionId;

  final List<String> status; // ApprovalStatus.value strings
  final List<String?> reasonsOfRejection;
  final List<String?> approvalComments;
  final List<String> modifier;
  final List<DateTime> modificationDate;

  ApprovalModel({
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.reasonsOfRejection,
    required this.approvalComments,
    required this.modifier,
    required this.modificationDate,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All ApprovalModel Lists must have the same number of elements (same index count)',
      );
    }
  }

  bool _allSameLength() {
    final lengths = <int>{
      status.length,
      reasonsOfRejection.length,
      approvalComments.length,
      modifier.length,
      modificationDate.length,
    };
    return lengths.length == 1;
  }

  /// Builds the first revision — always Status "Pending".
  factory ApprovalModel.create({
    required String requestId,
    required String submissionId,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return ApprovalModel(
      requestId: requestId,
      submissionId: submissionId,
      status: [ApprovalStatus.pending.value],
      reasonsOfRejection: const [null],
      approvalComments: const [null],
      modifier: [editorEmail],
      modificationDate: [now],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for anything not passed. [requestId]/[submissionId] are fixed
  /// fields, always carried over unchanged.
  ApprovalModel copyWithUpdate({
    String? status,
    String? reasonOfRejection,
    String? approvalComment,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return ApprovalModel(
      requestId: requestId,
      submissionId: submissionId,
      status: [...this.status, status ?? this.status.last],
      reasonsOfRejection: [
        ...reasonsOfRejection,
        reasonOfRejection ?? reasonsOfRejection.last,
      ],
      approvalComments: [
        ...approvalComments,
        approvalComment ?? approvalComments.last,
      ],
      modifier: [...modifier, editorEmail],
      modificationDate: [...modificationDate, now],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyRequestId: requestId,
      _keySubmissionId: submissionId,
      _keyStatus: status,
      _keyReasonsOfRejection: reasonsOfRejection,
      _keyApprovalComments: approvalComments,
      _keyModifier: modifier,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
    };
  }

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      requestId: json[_keyRequestId] as String,
      submissionId: json[_keySubmissionId] as String,
      status: List<String>.from(json[_keyStatus] ?? []),
      reasonsOfRejection: List<String?>.from(json[_keyReasonsOfRejection] ?? []),
      approvalComments: List<String?>.from(json[_keyApprovalComments] ?? []),
      modifier: List<String>.from(json[_keyModifier] ?? []),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
    );
  }

  ApprovalEntity toEntity() {
    return ApprovalEntity(
      requestId: requestId,
      submissionId: submissionId,
      status: ApprovalStatus.fromString(status.last),
      reasonOfRejection: reasonsOfRejection.last,
      approvalComment: approvalComments.last,
      lastModifier: modifier.last,
      lastModificationDate: modificationDate.last,
    );
  }
}
