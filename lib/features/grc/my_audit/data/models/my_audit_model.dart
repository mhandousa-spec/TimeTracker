/// Module: My Audits (Control Owner)
/// Description: Firestore model for one Control Owner's review/score
///              decision on a Champion's Assignment Control submission,
///              following the same history-list pattern as
///              ApprovalModel/AssignmentControlModel. One document per
///              control+champion pair, reused across cycles. Firestore path:
///              GRC Modules/{Module_ID}/My Audit/{My_Audit_ID}
///              where My_Audit_ID = "{controlId}_{championEmail}".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-28
/// Dependencies: MyAuditEntity, MyAuditStatus, GrcFirestoreKeys
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:knowticed_plus/features/grc/my_audit/domain/entities/my_audit_status.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class MyAuditModel {
  static const String _keyAuditId = 'Audit_ID';
  static const String _keyRequestId = 'Request_ID';
  static const String _keySubmissionId = 'Submission_ID';
  static const String _keyStatus = 'Status';
  static const String _keyControlScore = 'Control_Score';
  static const String _keyControlOwnerJustifications = 'Control_Owner_Justifications';
  static const String _keyControlOwnerReasonsOfRejection =
      'Control_Owner_Reasons_of_Rejection';
  static const String _keyModifier = 'Modifier';

  final String auditId;
  final String requestId;
  final String submissionId;

  final List<String> status; // MyAuditStatus.value strings
  final List<double?> controlScore;
  final List<String?> controlOwnerJustifications;
  final List<String?> controlOwnerReasonsOfRejection;
  final List<String> modifier;
  final List<DateTime> modificationDate;

  MyAuditModel({
    required this.auditId,
    required this.requestId,
    required this.submissionId,
    required this.status,
    required this.controlScore,
    required this.controlOwnerJustifications,
    required this.controlOwnerReasonsOfRejection,
    required this.modifier,
    required this.modificationDate,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All MyAuditModel Lists must have the same number of elements (same index count)',
      );
    }
  }

  bool _allSameLength() {
    final lengths = <int>{
      status.length,
      controlScore.length,
      controlOwnerJustifications.length,
      controlOwnerReasonsOfRejection.length,
      modifier.length,
      modificationDate.length,
    };
    return lengths.length == 1;
  }

  /// Builds the first revision — always Status "Pending" (created when a
  /// manager approves the linked Approval — see ApprovalCubit.approve).
  factory MyAuditModel.create({
    required String auditId,
    required String requestId,
    required String submissionId,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return MyAuditModel(
      auditId: auditId,
      requestId: requestId,
      submissionId: submissionId,
      status: [MyAuditStatus.pending.value],
      controlScore: const [null],
      controlOwnerJustifications: const [null],
      controlOwnerReasonsOfRejection: const [null],
      modifier: [editorEmail],
      modificationDate: [now],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for anything not passed. [auditId]/[requestId]/[submissionId]
  /// are fixed fields, always carried over unchanged.
  MyAuditModel copyWithUpdate({
    String? status,
    double? controlScore,
    String? controlOwnerJustification,
    String? controlOwnerReasonOfRejection,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return MyAuditModel(
      auditId: auditId,
      requestId: requestId,
      submissionId: submissionId,
      status: [...this.status, status ?? this.status.last],
      controlScore: [...this.controlScore, controlScore ?? this.controlScore.last],
      controlOwnerJustifications: [
        ...controlOwnerJustifications,
        controlOwnerJustification ?? controlOwnerJustifications.last,
      ],
      controlOwnerReasonsOfRejection: [
        ...controlOwnerReasonsOfRejection,
        controlOwnerReasonOfRejection ?? controlOwnerReasonsOfRejection.last,
      ],
      modifier: [...modifier, editorEmail],
      modificationDate: [...modificationDate, now],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keyAuditId: auditId,
      _keyRequestId: requestId,
      _keySubmissionId: submissionId,
      _keyStatus: status,
      _keyControlScore: controlScore,
      _keyControlOwnerJustifications: controlOwnerJustifications,
      _keyControlOwnerReasonsOfRejection: controlOwnerReasonsOfRejection,
      _keyModifier: modifier,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
    };
  }

  factory MyAuditModel.fromJson(Map<String, dynamic> json) {
    return MyAuditModel(
      auditId: json[_keyAuditId] as String,
      requestId: json[_keyRequestId] as String,
      submissionId: json[_keySubmissionId] as String,
      status: List<String>.from(json[_keyStatus] ?? []),
      controlScore: (json[_keyControlScore] as List? ?? [])
          .map((e) => e == null ? null : (e as num).toDouble())
          .toList(),
      controlOwnerJustifications:
          List<String?>.from(json[_keyControlOwnerJustifications] ?? []),
      controlOwnerReasonsOfRejection:
          List<String?>.from(json[_keyControlOwnerReasonsOfRejection] ?? []),
      modifier: List<String>.from(json[_keyModifier] ?? []),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
    );
  }

  MyAuditEntity toEntity() {
    return MyAuditEntity(
      auditId: auditId,
      requestId: requestId,
      submissionId: submissionId,
      status: MyAuditStatus.fromString(status.last),
      controlScore: controlScore.last,
      controlOwnerJustification: controlOwnerJustifications.last,
      controlOwnerReasonOfRejection: controlOwnerReasonsOfRejection.last,
      lastModifier: modifier.last,
      lastModificationDate: modificationDate.last,
    );
  }
}
