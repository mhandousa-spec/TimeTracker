/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_request_model.dart
/// Purpose: Declares `TimeTrackerRequestModel` — Firestore <->
///          `TimeTrackerRequest` mapping for one `Requests/{id}` history
///          document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim (+ `Created_By` / `Modified_By`,
/// playbook §3b; `Creation_Date` is the spec's own field). List fields go
/// through `RequestPartsMapper`. Every write appends the whole request.
/// Updated: 9/10/2026 - code review: `Deducted_Vacation_Days` (finding 4 —
/// null on rows written before it existed), the read [revision] (finding 2)
/// and [hasKnownStatus] (an unknown status no longer reads as pending).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): `Comments` is no longer
/// WRITTEN (one document per comment in `Requests/{id}/Comments`); an old
/// document's list is still read, as `legacyComments` (read-only), until the
/// migration removes the field.
/// Updated: 9/10/2026 - owner round 9 option b: `Deducted_Vacation_Days` is a
/// per-year MAP in each revision ({"2026": 3, "2027": 3} — a map inside the
/// history list, no array-in-array); an old numeric value reads as
/// {start year: n} ([deductedFrom] / [deductedTo]).

import 'package:knowticed_plus/features/time_tracker/data/models/request_parts_mapper.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

typedef _F = TimeTrackerFieldCodec;

class TimeTrackerRequestModel {
  const TimeTrackerRequestModel._();

  static const String fRequestId = 'Request_Id';
  static const String fRequesterEmail = 'Requester_Email';
  static const String fRequesterDepartmentId = 'Requester_Department_Id';
  static const String fRequestTypeId = 'Request_Type_Id';
  static const String fIsTransaction = 'Is_Transaction';
  static const String fDescription = 'Description';
  static const String fStart = 'Start_Date_Time';
  static const String fEnd = 'End_Date_Time';
  static const String fIsAllDay = 'Is_All_Day';
  static const String fTotalMinutes = 'Total_Minutes';
  static const String fAttachments = 'Attachments';
  static const String fStatus = 'Request_Status';
  static const String fApprovalSteps = 'Approval_Steps';
  static const String fCurrentStep = 'Current_Step';
  static const String fCancellationReason = 'Cancellation_Reason';
  static const String fLastReminder = 'Last_Reminder_Date_Time';
  /// READ ONLY since 9/10/2026 (old documents; the migration removes it).
  static const String fLegacyComments = 'Comments';
  static const String fDeductedVacationDays = 'Deducted_Vacation_Days';

  /// Function Name: [hasKnownStatus]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — the stored `Request_Status`
  /// is one the app knows. An odd document is skipped by the repository
  /// instead of showing up as an approvable "pending" request.
  ///
  /// Return type: [bool]
  static bool hasKnownStatus(Map<String, dynamic> map) {
    final String raw = _F.string(TimeTrackerHistoryCodec.lastOf(map, fStatus));
    return RequestStatus.values.any((RequestStatus s) => s.storageKey == raw);
  }

  /// Function Name: [deductedFrom]
  ///
  /// Purpose: One `Deducted_Vacation_Days` entry as days per year: a map
  /// {"2026": 3, …}, or an OLD number n read as {[startYear]: n}; anything
  /// else = never recorded (null).
  ///
  /// Return type: [Map<int, double>?]
  static Map<int, double>? deductedFrom(Object? raw, {required int startYear}) {
    if (raw is num) return Map<int, double>.unmodifiable(<int, double>{startYear: raw.toDouble()});
    if (raw is! Map) return null;
    final Map<int, double> out = <int, double>{};
    for (final MapEntry<dynamic, dynamic> e in raw.entries) {
      final int? year = int.tryParse('${e.key}');
      final Object? days = e.value;
      if (year != null && days is num) out[year] = days.toDouble();
    }
    return Map<int, double>.unmodifiable(out);
  }

  /// Function Name: [deductedTo]
  ///
  /// Purpose: Days per year as stored — {"2026": 3, "2027": 3} (string keys:
  /// Firestore map keys); null stays null (never recorded).
  ///
  /// Return type: [Map<String, Object?>?]
  static Map<String, Object?>? deductedTo(Map<int, double>? byYear) {
    if (byYear == null) return null;
    final List<int> years = byYear.keys.toList()..sort();
    return <String, Object?>{for (final int y in years) '$y': byYear[y]};
  }

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Parameters:
  ///   [String] id: the document id.
  ///   [Map<String, dynamic>] map: the raw document.
  ///
  /// Return type: [TimeTrackerRequest]
  static TimeTrackerRequest fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final DateTime start = _F.date(now(fStart)) ?? DateTime(1970);
    return TimeTrackerRequest(
      id: id.isNotEmpty ? id : _F.string(now(fRequestId)),
      requesterEmail: _F.string(now(fRequesterEmail)),
      requesterDepartmentId: _F.string(now(fRequesterDepartmentId)),
      requestTypeId: _F.string(now(fRequestTypeId)),
      isTransaction: _F.boolean(now(fIsTransaction)),
      description: _F.string(now(fDescription)),
      startAt: start,
      endAt: _F.date(now(fEnd)) ?? start,
      isAllDay: _F.boolean(now(fIsAllDay)),
      totalMinutes: _F.integer(now(fTotalMinutes)),
      attachments: RequestPartsMapper.attachmentsFrom(now(fAttachments)),
      status: RequestStatus.fromStorageKey(_F.string(now(fStatus))),
      approvalSteps: RequestPartsMapper.stepsFrom(now(fApprovalSteps)),
      currentStep: ApprovalStepKind.fromStorageKey(_F.string(now(fCurrentStep))),
      cancellationReason: _F.string(now(fCancellationReason)),
      lastReminderAt: _F.date(now(fLastReminder)),
      legacyComments: RequestPartsMapper.commentsFrom(now(fLegacyComments)),
      audit: _F.auditOf(map),
      revision: TimeTrackerHistoryCodec.rowCount(map),
      deductedDaysByYear: deductedFrom(now(fDeductedVacationDays), startYear: start.year),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///   [String] id: the document id.
  ///   [TimeTrackerAudit] audit
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    TimeTrackerRequest request, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fRequestId: id,
        fRequesterEmail: request.requesterEmail.trim().toLowerCase(),
        fRequesterDepartmentId: request.requesterDepartmentId,
        fRequestTypeId: request.requestTypeId,
        fIsTransaction: request.isTransaction,
        fDescription: request.description.trim(),
        fStart: _F.timestamp(request.startAt),
        fEnd: _F.timestamp(request.endAt),
        fIsAllDay: request.isAllDay,
        fTotalMinutes: request.totalMinutes,
        fAttachments: RequestPartsMapper.attachmentsTo(request.attachments),
        fStatus: request.status.storageKey,
        fApprovalSteps: RequestPartsMapper.stepsTo(request.approvalSteps),
        fCurrentStep: request.currentStep?.storageKey,
        fCancellationReason: request.cancellationReason.trim(),
        fLastReminder: _F.timestamp(request.lastReminderAt),
        fDeductedVacationDays: deductedTo(request.deductedDaysByYear),
        ...audit.fields,
      };
}
