/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_day_model.dart
/// Purpose: Declares `AttendanceDayModel` — Firestore <-> `AttendanceDay`
///          mapping for one `Attendance/{email}_{yyyy-MM-dd}` history document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim (+ the playbook §3b audit trio).
/// `Sessions` stores each history entry as `{Values: [session, …]}`; each
/// session map holds `Check_In_Date_Time`, `Check_Out_Date_Time`,
/// `Work_Location_Id`, `Work_Location_Type`, `Check_In_Latitude`,
/// `Check_In_Longitude` and `Pauses: [{Start, End}]` (an array inside a map,
/// so Firestore accepts it). Every write appends the whole day.
/// Updated: 9/10/2026 - phase 4: [correctionHistory] (the day before an
/// approved transaction's first row — for the revert).
/// Updated: 9/10/2026 - code review: the calendar day is read from the
/// document id `{email}_yyyy-MM-dd` ([dayFromId]) — the stored
/// `Attendance_Date` Timestamp is local midnight of the WRITER's time zone,
/// so a reader in another zone saw the previous / next day. The Timestamp
/// is only a fallback (an id without the date suffix).

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

typedef _F = TimeTrackerFieldCodec;

class AttendanceDayModel {
  const AttendanceDayModel._();

  static const String fAttendanceId = 'Attendance_Id';
  static const String fEmployeeEmail = 'Employee_Email';
  static const String fAttendanceDate = 'Attendance_Date';
  static const String fSessions = 'Sessions';
  static const String fStatus = 'Attendance_Status';
  static const String fLateMinutes = 'Late_Minutes';
  static const String fBreakMinutes = 'Break_Minutes';
  static const String fTotalWorkMinutes = 'Total_Work_Minutes';
  static const String fIsCorrected = 'Is_Corrected_By_Transaction';
  static const String fSourceRequestId = 'Source_Request_Id';

  // Keys inside one session / pause map.
  static const String fCheckIn = 'Check_In_Date_Time';
  static const String fCheckOut = 'Check_Out_Date_Time';
  static const String fWorkLocationId = 'Work_Location_Id';
  static const String fWorkLocationType = 'Work_Location_Type';
  static const String fLatitude = 'Check_In_Latitude';
  static const String fLongitude = 'Check_In_Longitude';
  static const String fPauses = 'Pauses';
  static const String fPauseStart = 'Start';
  static const String fPauseEnd = 'End';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Parameters:
  ///   [String] id: the document id.
  ///   [Map<String, dynamic>] map: the raw document.
  ///
  /// Return type: [AttendanceDay]
  static AttendanceDay fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final DateTime date = dayFromId(id) ??
        dayFromId(_F.string(now(fAttendanceId))) ??
        _F.date(now(fAttendanceDate)) ??
        DateTime(1970);
    return AttendanceDay(
      id: id.isNotEmpty ? id : _F.string(now(fAttendanceId)),
      employeeEmail: _F.string(now(fEmployeeEmail)),
      date: DateTime(date.year, date.month, date.day),
      sessions: List<AttendanceSession>.unmodifiable(
        _F.maps(now(fSessions)).map(_sessionFrom),
      ),
      status: AttendanceStatus.fromStorageKey(_F.string(now(fStatus))),
      lateMinutes: _F.integer(now(fLateMinutes)),
      breakMinutes: _F.integer(now(fBreakMinutes)),
      totalWorkMinutes: _F.integer(now(fTotalWorkMinutes)),
      isCorrectedByTransaction: _F.boolean(now(fIsCorrected)),
      sourceRequestId: _F.string(now(fSourceRequestId)),
      audit: _F.auditOf(map),
    );
  }

  static final RegExp _idDate = RegExp(r'_(\d{4})-(\d{2})-(\d{2})$');

  /// Function Name: [dayFromId]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — the calendar day encoded at
  /// the end of an attendance document id (`{email}_yyyy-MM-dd`), as LOCAL
  /// midnight, whatever zone the day was written in.
  ///
  /// Return type: [DateTime?] — null when the id carries no valid date.
  static DateTime? dayFromId(String id) {
    final RegExpMatch? m = _idDate.firstMatch(id.trim());
    if (m == null) return null;
    final int year = int.parse(m.group(1)!);
    final int month = int.parse(m.group(2)!);
    final int day = int.parse(m.group(3)!);
    final DateTime d = DateTime(year, month, day);
    // 2026-02-31 would roll into March — not a real id.
    return d.year == year && d.month == month && d.day == day ? d : null;
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  ///
  /// Parameters:
  ///   [AttendanceDay] day
  ///   [String] id: the document id.
  ///   [TimeTrackerAudit] audit
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    AttendanceDay day, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fAttendanceId: id,
        fEmployeeEmail: day.employeeEmail.trim().toLowerCase(),
        fAttendanceDate: _F.timestamp(
          DateTime(day.date.year, day.date.month, day.date.day),
        ),
        fSessions: _F.wrap(<Object?>[for (final s in day.sessions) _sessionTo(s)]),
        fStatus: day.status?.storageKey,
        fLateMinutes: day.lateMinutes,
        fBreakMinutes: day.breakMinutes,
        fTotalWorkMinutes: day.totalWorkMinutes,
        fIsCorrected: day.isCorrectedByTransaction,
        fSourceRequestId: day.sourceRequestId,
        ...audit.fields,
      };

  /// Function Name: [correctionHistory]
  ///
  /// Purpose: The day now and just before the FIRST row whose
  /// `Source_Request_Id` is [requestId] (with `Is_Corrected_By_Transaction`).
  ///
  /// Return type: [AttendanceCorrectionHistory?] — null when no row carries
  /// that request.
  static AttendanceCorrectionHistory? correctionHistory(
    String id,
    Map<String, dynamic> map,
    String requestId,
  ) {
    final List<Object?> sources = TimeTrackerHistoryCodec.historyOf(map, fSourceRequestId);
    final List<Object?> flags = TimeTrackerHistoryCodec.historyOf(map, fIsCorrected);
    final int rows = TimeTrackerHistoryCodec.rowCount(map);
    int first = -1;
    for (int i = 0; i < sources.length; i++) {
      final int flagIndex = i - (sources.length - flags.length);
      final bool flagged = flagIndex >= 0 && _F.boolean(flags[flagIndex]);
      if (_F.string(sources[i]) == requestId && flagged) {
        first = i + (rows - sources.length);
        break;
      }
    }
    if (first < 0) return null;
    return AttendanceCorrectionHistory(
      current: fromMap(id, map),
      before: first == 0 ? null : fromMap(id, TimeTrackerHistoryCodec.rowAt(map, first - 1)),
    );
  }

  static AttendanceSession _sessionFrom(Map<String, dynamic> m) =>
      AttendanceSession(
        checkInAt: _F.date(m[fCheckIn]) ?? DateTime(1970),
        checkOutAt: _F.date(m[fCheckOut]),
        workLocationId: _F.string(m[fWorkLocationId]),
        workLocationType: WorkLocationType.fromStorageKey(
          _F.string(m[fWorkLocationType]),
        ),
        latitude: _F.nullableDecimal(m[fLatitude]),
        longitude: _F.nullableDecimal(m[fLongitude]),
        pauses: List<AttendancePause>.unmodifiable(<AttendancePause>[
          for (final Map<String, dynamic> p in _F.maps(m[fPauses]))
            AttendancePause(
              startAt: _F.date(p[fPauseStart]) ?? DateTime(1970),
              endAt: _F.date(p[fPauseEnd]),
            ),
        ]),
      );

  static Map<String, Object?> _sessionTo(AttendanceSession s) =>
      <String, Object?>{
        fCheckIn: _F.timestamp(s.checkInAt),
        fCheckOut: _F.timestamp(s.checkOutAt),
        fWorkLocationId: s.workLocationId,
        fWorkLocationType: s.workLocationType.storageKey,
        fLatitude: s.latitude,
        fLongitude: s.longitude,
        fPauses: <Object?>[
          for (final AttendancePause p in s.pauses)
            <String, Object?>{
              fPauseStart: _F.timestamp(p.startAt),
              fPauseEnd: _F.timestamp(p.endAt),
            },
        ],
      };
}
