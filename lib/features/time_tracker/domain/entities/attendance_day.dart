/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_day.dart
/// Purpose: Declares `AttendanceDay` (one employee's attendance for one
///          calendar day) and its parts `AttendanceSession` (check-in →
///          check-out) and `AttendancePause` (pause → resume).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 5 (8/10/2026): several check-ins a day are allowed, so a
/// day holds a list of sessions; Pause = Break and is NOT counted in the total
/// work time. Stored at `Modules/time_tracker/Attendance/{email}_{yyyy-MM-dd}`
/// (FINAL SPEC §2). Derived numbers (late / break / total minutes, status) are
/// calculated by `AttendanceCalculator` and written with each change.
///
/// Plain immutable Dart: no Firestore, no Flutter.
/// Updated: 9/10/2026 - phase 4: `AttendanceCorrectionHistory` (the day now
/// and just before an approved transaction rewrote it — for the revert).

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

/// One Pause → Resume interval inside a session. [endAt] is null while paused.
class AttendancePause {
  const AttendancePause({required this.startAt, this.endAt});

  final DateTime startAt;
  final DateTime? endAt;

  bool get isOpen => endAt == null;
}

/// One Check In → Check Out interval. [checkOutAt] is null while checked in.
class AttendanceSession {
  const AttendanceSession({
    required this.checkInAt,
    this.checkOutAt,
    this.workLocationId = '',
    this.workLocationType = WorkLocationType.office,
    this.latitude,
    this.longitude,
    this.pauses = const <AttendancePause>[],
  });

  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String workLocationId;
  final WorkLocationType workLocationType;

  /// Device position at check-in (null when not captured).
  final double? latitude;
  final double? longitude;
  final List<AttendancePause> pauses;

  bool get isOpen => checkOutAt == null;

  /// Checked in and currently on a pause.
  bool get isPaused => isOpen && pauses.isNotEmpty && pauses.last.isOpen;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [AttendanceSession]
  AttendanceSession copyWith({
    DateTime? checkOutAt,
    List<AttendancePause>? pauses,
  }) =>
      AttendanceSession(
        checkInAt: checkInAt,
        checkOutAt: checkOutAt ?? this.checkOutAt,
        workLocationId: workLocationId,
        workLocationType: workLocationType,
        latitude: latitude,
        longitude: longitude,
        pauses: pauses ?? this.pauses,
      );
}

class AttendanceDay {
  const AttendanceDay({
    required this.id,
    required this.employeeEmail,
    required this.date,
    this.sessions = const <AttendanceSession>[],
    this.status,
    this.lateMinutes = 0,
    this.breakMinutes = 0,
    this.totalWorkMinutes = 0,
    this.isCorrectedByTransaction = false,
    this.sourceRequestId = '',
    this.audit = AuditInfo.none,
  });

  /// `{email}_{yyyy-MM-dd}` (see `TimeTrackerFirestorePaths.attendanceDocId`).
  final String id;
  final String employeeEmail;

  /// The calendar day (local midnight).
  final DateTime date;
  final List<AttendanceSession> sessions;

  /// Null while the day has no decided status (e.g. today, not checked in).
  final AttendanceStatus? status;
  final int lateMinutes;
  final int breakMinutes;
  final int totalWorkMinutes;

  /// The day was rewritten by an approved transaction request (owner
  /// decision 8: HR never edits attendance directly).
  final bool isCorrectedByTransaction;
  final String sourceRequestId;
  final AuditInfo audit;

  /// The running session, if the employee is checked in now.
  AttendanceSession? get openSession =>
      sessions.isNotEmpty && sessions.last.isOpen ? sessions.last : null;

  bool get isCheckedIn => openSession != null;
  bool get isPaused => openSession?.isPaused ?? false;

  /// First check-in of the day (the one lateness is measured from).
  DateTime? get firstCheckInAt =>
      sessions.isEmpty ? null : sessions.first.checkInAt;

  /// Last check-out of the day, null while checked in or before any session.
  DateTime? get lastCheckOutAt =>
      sessions.isEmpty ? null : sessions.last.checkOutAt;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearStatus] resets the status to null.
  ///
  /// Return type: [AttendanceDay]
  AttendanceDay copyWith({
    List<AttendanceSession>? sessions,
    AttendanceStatus? status,
    bool clearStatus = false,
    int? lateMinutes,
    int? breakMinutes,
    int? totalWorkMinutes,
    bool? isCorrectedByTransaction,
    String? sourceRequestId,
  }) =>
      AttendanceDay(
        id: id,
        employeeEmail: employeeEmail,
        date: date,
        sessions: sessions ?? this.sessions,
        status: clearStatus ? null : (status ?? this.status),
        lateMinutes: lateMinutes ?? this.lateMinutes,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        totalWorkMinutes: totalWorkMinutes ?? this.totalWorkMinutes,
        isCorrectedByTransaction:
            isCorrectedByTransaction ?? this.isCorrectedByTransaction,
        sourceRequestId: sourceRequestId ?? this.sourceRequestId,
        audit: audit,
      );
}

/// A corrected day as stored now, and as it was just before the FIRST row
/// written by the transaction ([before] null = the day had no record yet).
/// Phase 4 (9/10/2026): "Cancel Request After Approving" on a transaction.
class AttendanceCorrectionHistory {
  const AttendanceCorrectionHistory({required this.current, this.before});

  final AttendanceDay current;
  final AttendanceDay? before;
}
