/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: change_request.dart
/// Purpose: One submitted change request — every field edited in one session,
///          plus who submitted it and where it stands.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N03. A request existed only as a
/// `Map<String, dynamic>` assembled by hand in `preview_changes_page.dart` and
/// re-parsed by hand in `request_page.dart` and `details_request.dart` — three
/// copies of the same 12 string keys, which is how the older single-field shape
/// (`whatChanged` / `oldValue` / `newValue`) and the newer `changes` array came
/// to be read differently in different screens.

import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';

@immutable
class ChangeRequest {
  const ChangeRequest({
    this.id = '',
    this.section = defaultSection,
    this.status = RequestStatus.pending,
    this.requestDate,
    this.requestNote = '',
    this.employeeId = '',
    this.employeeEmail = '',
    this.employeeName = '',
    this.changes = const <FieldChange>[],
  });

  /// What an untagged request is shown as, matching the previous
  /// `data['section'] ?? 'Personal Information'` fallback.
  static const String defaultSection = 'Personal Information';

  final String id;

  /// Which settings section the request came from, e.g. `Personal Information`
  /// or `Health Insurance`. Stored as free text; it is displayed, not switched
  /// on.
  final String section;

  final RequestStatus status;
  final DateTime? requestDate;
  final String requestNote;

  final String employeeId;
  final String employeeEmail;
  final String employeeName;

  final List<FieldChange> changes;

  int get numberOfChanges => changes.length;

  ChangeRequest copyWith({
    String? id,
    String? section,
    RequestStatus? status,
    DateTime? requestDate,
    String? requestNote,
    String? employeeId,
    String? employeeEmail,
    String? employeeName,
    List<FieldChange>? changes,
  }) {
    return ChangeRequest(
      id: id ?? this.id,
      section: section ?? this.section,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      requestNote: requestNote ?? this.requestNote,
      employeeId: employeeId ?? this.employeeId,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeName: employeeName ?? this.employeeName,
      changes: changes ?? this.changes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeRequest &&
          other.id == id &&
          other.section == section &&
          other.status == status &&
          other.requestDate == requestDate &&
          other.requestNote == requestNote &&
          other.employeeId == employeeId &&
          other.employeeEmail == employeeEmail &&
          other.employeeName == employeeName &&
          listEquals(other.changes, changes);

  @override
  int get hashCode => Object.hash(id, section, status, requestDate, requestNote,
      employeeId, employeeEmail, employeeName, Object.hashAll(changes));
}
