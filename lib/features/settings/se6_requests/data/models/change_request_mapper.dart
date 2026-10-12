/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: change_request_mapper.dart
/// Purpose: Translate a request document to and from [ChangeRequest].
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N01 / N03. Parsing lived in three pages; this is the
/// single copy, including the fallback that reads the pre-`changes` documents
/// (one field per document, under `whatChanged` / `oldValue` / `newValue`).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

abstract class ChangeRequestMapper {
  /// Firestore keys on a request document.
  static const String keyChanges = 'changes';
  static const String keySection = 'section';
  static const String keyRequestDate = 'requestDate';
  static const String keyRequestDateFormatted = 'requestDateFormatted';
  static const String keyRequestNote = 'requestNote';
  static const String keyStatus = 'status';

  /// Reviewer's reason for approving / rejecting (added 30/9/2026).
  static const String keyDecisionReason = 'decision_reason';
  static const String keyEmployeeId = 'employeeId';
  static const String keyEmployeeEmail = 'employeeEmail';
  static const String keyEmployeeName = 'employeeName';
  static const String keyCreatedAt = 'createdAt';
  static const String keyUpdatedAt = 'updatedAt';
  static const String keyNumberOfChanges = 'numberOfChanges';

  /// Keys of the legacy single-field document shape.
  static const String legacyKeyWhatChanged = 'whatChanged';
  static const String legacyKeyOldValue = 'oldValue';
  static const String legacyKeyNewValue = 'newValue';

  /// Function Name: [fromDocument]
  ///
  /// Purpose: Read one request document.
  static ChangeRequest fromDocument(String id, Map<String, dynamic> data) {
    return ChangeRequest(
      id: id,
      section: data[keySection]?.toString() ?? ChangeRequest.defaultSection,
      status: RequestStatus.fromWire(data[keyStatus]?.toString()),
      requestDate: _requestDate(data[keyRequestDate]),
      requestNote: data[keyRequestNote]?.toString() ?? '',
      employeeId: data[keyEmployeeId]?.toString() ?? '',
      employeeEmail: data[keyEmployeeEmail]?.toString() ?? '',
      employeeName: data[keyEmployeeName]?.toString() ?? '',
      changes: _changes(data),
    );
  }

  /// Function Name: [_requestDate]
  ///
  /// Purpose: Read `requestDate` whichever way it was stored.
  ///
  /// HARDENED 24/8/2026. This was `data[keyRequestDate] as Timestamp?`, which
  /// throws on a document that stored the date as epoch milliseconds — the
  /// shape `user_management_details_request.dart` has always tolerated
  /// (`if (requestDate is int) … else if (requestDate is Timestamp) …`). That
  /// screen now reads its request through this mapper, so the cast would have
  /// turned an old record into a crash on open. Submissions have written a
  /// server timestamp for a long time, so this only covers the tail.
  ///
  /// Parameters:
  /// - [raw]: the stored value: a [Timestamp], epoch milliseconds, or null.
  ///
  /// Returns: [DateTime] or `null` when the field is absent or unreadable.
  static DateTime? _requestDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is DateTime) return raw;
    return null;
  }

  /// Function Name: [toSubmission]
  ///
  /// Purpose: Build the document body for a new request.
  ///
  /// `requestDate`, `createdAt` and `updatedAt` are server timestamps;
  /// `requestDateFormatted` keeps the human-readable copy the list screens
  /// render.
  static Map<String, dynamic> toSubmission(
    ChangeRequest request, {
    required String formattedDate,
  }) {
    return <String, dynamic>{
      keyChanges:
          request.changes.map((FieldChange c) => c.toMap()).toList(),
      keySection: request.section,
      keyRequestDate: FieldValue.serverTimestamp(),
      keyRequestDateFormatted: formattedDate,
      keyRequestNote: request.requestNote,
      keyStatus: request.status.wireValue,
      keyEmployeeId: request.employeeId,
      keyEmployeeEmail: request.employeeEmail,
      keyEmployeeName: request.employeeName,
      keyCreatedAt: FieldValue.serverTimestamp(),
      keyUpdatedAt: FieldValue.serverTimestamp(),
      keyNumberOfChanges: request.numberOfChanges,
    };
  }

  /// A submission is one document holding every field changed in that session,
  /// under [keyChanges]. Older records used the single-field shape, so fall
  /// back to it rather than showing an empty request.
  static List<FieldChange> _changes(Map<String, dynamic> data) {
    final dynamic raw = data[keyChanges];

    if (raw is List) {
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(FieldChange.fromMap)
          .toList();
    }

    final String? legacyField = data[legacyKeyWhatChanged] as String?;
    if (legacyField != null && legacyField.isNotEmpty) {
      return <FieldChange>[
        FieldChange(
          fieldName: legacyField,
          oldValue: data[legacyKeyOldValue]?.toString() ?? '',
          newValue: data[legacyKeyNewValue]?.toString() ?? '',
        ),
      ];
    }

    return const <FieldChange>[];
  }
}
