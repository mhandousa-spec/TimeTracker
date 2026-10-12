/// Module: Assignment Controls (Control Champion)
/// Description: Firestore model for one Control Champion's submission
///              cycle on a Control, following the same history-list
///              pattern as ControlModel/ChampionModel/GRCModuleModel:
///              every mutable field is a `List<T>`, index i is one revision
///              (Submit/Reject/Resubmit/Approve). Firestore path:
///              GRC Modules/{Module_ID}/Assignment Controls/{Assignment_Controls_ID}
///              where Assignment_Controls_ID = "{controlId}_{championEmail}".
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-27
/// Dependencies: AssignmentControlEntity, AssignmentControlStatus, GrcFirestoreKeys
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/assignment_control_status.dart';
import 'package:knowticed_plus/features/grc/assignment_control/domain/entities/submission_history_entry.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firestore_keys.dart';

final DateFormat _storageDateFormat = DateFormat('d MMM yyyy', 'en');

class AssignmentControlModel {
  static const String _keySubmissionId = 'Submission_ID';
  static const String _keyControlChampionEmail = 'Control_Champion_Email';
  static const String _keyControlId = 'Control_ID';
  static const String _keyControlOwner = 'Control_Owner';
  static const String _keyDepartmentManager = 'Department_Manager';
  static const String _keySubmissionDocument = 'Submission_Document';
  static const String _keySubmissionNote = 'Submission_Note';
  static const String _keyStatus = 'Status';
  static const String _keyDepartmentManagerRejectionReasons =
      'Department_Manager_Reasons_Of_Rejection';
  static const String _keyControlScore = 'Control_Score';
  static const String _keyControlOwnerJustifications =
      'Control_Owner_Justifications';
  static const String _keyControlOwnerRejectionReasons =
      'Control_Owner_Reasons_Of_Rejection';
  // Deliberately NOT reusing the shared GrcFirestoreKeys.modifiers ('Modifiers')
  // — the schema given for this feature explicitly names this field
  // "Modifier" (singular).
  static const String _keyModifier = 'Modifier';

  final String submissionId;
  final String controlChampionEmail;
  final String policyId;
  final String controlId;
  final String? controlOwner;
  final String? departmentManager;

  final List<String> submissionDocument;
  final List<String> submissionNote;
  final List<String> status; // AssignmentControlStatus.value strings
  final List<String> modifier;
  final List<DateTime> modificationDate;
  final List<String?> departmentManagerRejectionReasons;
  final List<double?> controlScore;
  final List<String?> controlOwnerJustifications;
  final List<String?> controlOwnerRejectionReasons;

  AssignmentControlModel({
    required this.submissionId,
    required this.controlChampionEmail,
    required this.policyId,
    required this.controlId,
    required this.controlOwner,
    required this.departmentManager,
    required this.submissionDocument,
    required this.submissionNote,
    required this.status,
    required this.modifier,
    required this.modificationDate,
    required this.departmentManagerRejectionReasons,
    required this.controlScore,
    required this.controlOwnerJustifications,
    required this.controlOwnerRejectionReasons,
  }) {
    if (!_allSameLength()) {
      throw ArgumentError(
        'All AssignmentControlModel Lists must have the same number of elements (same index count)',
      );
    }
  }

  bool _allSameLength() {
    final lengths = <int>{
      submissionDocument.length,
      submissionNote.length,
      status.length,
      modifier.length,
      modificationDate.length,
      departmentManagerRejectionReasons.length,
      controlScore.length,
      controlOwnerJustifications.length,
      controlOwnerRejectionReasons.length,
    };
    return lengths.length == 1;
  }

  /// Builds the first revision of a submission cycle — always Status
  /// "Submitted" (there is no stored "Pending" revision; see design spec).
  factory AssignmentControlModel.create({
    required String submissionId,
    required String controlChampionEmail,
    required String policyId,
    required String controlId,
    required String? controlOwner,
    required String? departmentManager,
    required String submissionDocument,
    required String submissionNote,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return AssignmentControlModel(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner,
      departmentManager: departmentManager,
      submissionDocument: [submissionDocument],
      submissionNote: [submissionNote],
      status: [AssignmentControlStatus.submitted.value],
      modifier: [editorEmail],
      modificationDate: [now],
      departmentManagerRejectionReasons: const [null],
      controlScore: const [null],
      controlOwnerJustifications: const [null],
      controlOwnerRejectionReasons: const [null],
    );
  }

  /// Appends a new revision to every history List, reusing the previous
  /// value for anything not passed. The fixed fields (submissionId,
  /// controlChampionEmail, policyId, controlId, controlOwner,
  /// departmentManager) are always carried over unchanged — this feature
  /// never mutates them after creation.
  AssignmentControlModel copyWithUpdate({
    String? submissionDocument,
    String? submissionNote,
    String? status,
    String? departmentManagerRejectionReason,
    double? controlScore,
    String? controlOwnerJustification,
    String? controlOwnerRejectionReason,
    // ADDED 28/9/2026: a resubmission re-resolves who reviews it. Null keeps
    // the stored value (every existing caller passes neither).
    String? controlOwner,
    String? departmentManager,
    required String editorEmail,
  }) {
    final now = DateTime.now();
    return AssignmentControlModel(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner ?? this.controlOwner,
      departmentManager: departmentManager ?? this.departmentManager,
      submissionDocument: [
        ...this.submissionDocument,
        submissionDocument ?? this.submissionDocument.last,
      ],
      submissionNote: [
        ...this.submissionNote,
        submissionNote ?? this.submissionNote.last,
      ],
      status: [...this.status, status ?? this.status.last],
      modifier: [...modifier, editorEmail],
      modificationDate: [...modificationDate, now],
      departmentManagerRejectionReasons: [
        ...departmentManagerRejectionReasons,
        departmentManagerRejectionReason ??
            departmentManagerRejectionReasons.last,
      ],
      controlScore: [
        ...this.controlScore,
        controlScore ?? this.controlScore.last,
      ],
      controlOwnerJustifications: [
        ...controlOwnerJustifications,
        controlOwnerJustification ?? controlOwnerJustifications.last,
      ],
      controlOwnerRejectionReasons: [
        ...controlOwnerRejectionReasons,
        controlOwnerRejectionReason ?? controlOwnerRejectionReasons.last,
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      _keySubmissionId: submissionId,
      _keyControlChampionEmail: controlChampionEmail,
      GrcFirestoreKeys.policyId: policyId,
      _keyControlId: controlId,
      _keyControlOwner: controlOwner,
      _keyDepartmentManager: departmentManager,
      _keySubmissionDocument: submissionDocument,
      _keySubmissionNote: submissionNote,
      _keyStatus: status,
      _keyModifier: modifier,
      GrcFirestoreKeys.modificationDate:
          modificationDate.map((d) => _storageDateFormat.format(d)).toList(),
      _keyDepartmentManagerRejectionReasons: departmentManagerRejectionReasons,
      _keyControlScore: controlScore,
      _keyControlOwnerJustifications: controlOwnerJustifications,
      _keyControlOwnerRejectionReasons: controlOwnerRejectionReasons,
    };
  }

  factory AssignmentControlModel.fromJson(Map<String, dynamic> json) {
    return AssignmentControlModel(
      submissionId: json[_keySubmissionId] as String,
      controlChampionEmail: json[_keyControlChampionEmail] as String,
      policyId: json[GrcFirestoreKeys.policyId] as String,
      controlId: json[_keyControlId] as String,
      controlOwner: json[_keyControlOwner] as String?,
      departmentManager: json[_keyDepartmentManager] as String?,
      submissionDocument: List<String>.from(json[_keySubmissionDocument] ?? []),
      submissionNote: List<String>.from(json[_keySubmissionNote] ?? []),
      status: List<String>.from(json[_keyStatus] ?? []),
      modifier: List<String>.from(json[_keyModifier] ?? []),
      modificationDate: (json[GrcFirestoreKeys.modificationDate] as List? ?? [])
          .map((d) => _storageDateFormat.parse(d as String))
          .toList(),
      departmentManagerRejectionReasons: List<String?>.from(
          json[_keyDepartmentManagerRejectionReasons] ?? []),
      controlScore: (json[_keyControlScore] as List? ?? [])
          .map((e) => e == null ? null : (e as num).toDouble())
          .toList(),
      controlOwnerJustifications:
          List<String?>.from(json[_keyControlOwnerJustifications] ?? []),
      controlOwnerRejectionReasons:
          List<String?>.from(json[_keyControlOwnerRejectionReasons] ?? []),
    );
  }

  AssignmentControlEntity toEntity() {
    return AssignmentControlEntity(
      submissionId: submissionId,
      controlChampionEmail: controlChampionEmail,
      policyId: policyId,
      controlId: controlId,
      controlOwner: controlOwner,
      departmentManager: departmentManager,
      submissionDocument: submissionDocument.last,
      submissionNote: submissionNote.last,
      status: AssignmentControlStatus.fromString(status.last),
      departmentManagerRejectionReason: departmentManagerRejectionReasons.last,
      controlScore: controlScore.last,
      controlOwnerJustification: controlOwnerJustifications.last,
      controlOwnerRejectionReason: controlOwnerRejectionReasons.last,
      lastModifier: modifier.last,
      lastModificationDate: modificationDate.last,
    );
  }

  /// Groups consecutive revisions that share the same [submissionDocument]
  /// value into one [SubmissionHistoryEntry] per distinct file, newest file
  /// first. A Reject (or Approve) never changes [submissionDocument] — it
  /// appends a revision carrying the same document forward (see
  /// [copyWithUpdate]) — so grouping by document value collapses those into
  /// one card, using the *last* revision of each run for status/rejection
  /// reason. [rejectionReason] is only ever non-null when that run's final
  /// status is Rejected, even if a stale value is still sitting in
  /// [departmentManagerRejectionReasons] from an earlier rejection.
  List<SubmissionHistoryEntry> toSubmissionHistory() {
    final entries = <SubmissionHistoryEntry>[];
    var runStart = 0;
    for (var i = 1; i <= submissionDocument.length; i++) {
      final runEnds = i == submissionDocument.length ||
          submissionDocument[i] != submissionDocument[runStart];
      if (!runEnds) continue;
      final end = i - 1;
      final parsedStatus = AssignmentControlStatus.fromString(status[end]);
      entries.add(SubmissionHistoryEntry(
        document: submissionDocument[runStart],
        note: submissionNote[runStart],
        submittedDate: modificationDate[runStart],
        status: parsedStatus,
        rejectionReason: parsedStatus == AssignmentControlStatus.rejected
            ? departmentManagerRejectionReasons[end]
            : null,
      ));
      runStart = i;
    }
    return entries.reversed.toList();
  }
}
