/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_attendance.dart
/// Purpose: Declares `TtDemoAttendance` — the DEBUG-ONLY demo attendance:
///          30 days of history per employee (present / late with minutes /
///          absent / on leave / corrected by a transaction / breaks and
///          pauses / one automatic check-out / alerts) and today's live
///          check-ins of a few colleagues.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data)
///
/// Pure Dart. Totals, late minutes and statuses come from the module's own
/// `AttendanceCalculator`, so every figure matches what the app computes.
/// Leave days follow the approved / under-review all-day requests of the
/// plan; a transaction's day is open (pending) or corrected (approved, with
/// the uncorrected first row kept in the history). Sessions are spread over
/// the office, remote work and client sites (Work Locations donut). The
/// signed-in user's TODAY is never written (their real check-in state stays).

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';

class TtDemoAttendance {
  TtDemoAttendance(this.input, this.setup, this.requests);

  final TtDemoInput input;
  final TtDemoSetup setup;
  final List<TtDemoRequest> requests;

  /// Days of history before today.
  static const int historyDays = 30;

  DateTime get _today => TtDemoCalendar.dayOf(input.now);

  /// Function Name: [build]
  ///
  /// Purpose: Every demo attendance day of every employee.
  ///
  /// Return type: [List<TtDemoDay>]
  List<TtDemoDay> build() {
    final List<TtDemoDay> out = <TtDemoDay>[];
    final List<TimeTrackerEmployee> all = input.everyone;
    for (int k = 0; k < all.length; k++) {
      out.addAll(_employee(k, all[k]));
    }
    return List<TtDemoDay>.unmodifiable(out);
  }

  List<TtDemoDay> _employee(int k, TimeTrackerEmployee e) {
    final WorkLocation loc = setup.locationOf(e);
    final WorkSchedule s = loc.schedule;
    final TtDemoCalendar cal = TtDemoCalendar(s);
    final List<TimeTrackerRequest> mine = <TimeTrackerRequest>[
      for (final TtDemoRequest r in requests)
        if (r.request.requesterEmail == e.email) r.request,
    ];
    // Three absences this month for ONE colleague (Needs Attention).
    final Set<DateTime> absent = <DateTime>{};
    if (k == 2) {
      for (DateTime d = DateTime(_today.year, _today.month); d.isBefore(_today); d = TtDemoCalendar.addDays(d, 1)) {
        if (s.isWorkingDay(d) && _leaveOn(mine, d) == null && _transactionOn(mine, d) == null) absent.add(d);
        if (absent.length == 3) break;
      }
    }
    final DateTime autoDay = cal.back(_today, 11 + k % 3);
    final DateTime longBreakDay = cal.back(_today, 13 + k % 2);
    final List<TtDemoDay> out = <TtDemoDay>[];
    for (int back = historyDays; back >= 1; back--) {
      final DateTime d = TtDemoCalendar.addDays(_today, -back);
      if (!s.isWorkingDay(d)) continue;
      final AttendanceStatus? leave = _leaveOn(mine, d);
      final TimeTrackerRequest? tx = _transactionOn(mine, d);
      final String id = _id(e, d);
      if (leave != null) {
        out.add(TtDemoDay(day: AttendanceDay(id: id, employeeEmail: e.email, date: d, status: leave)));
      } else if (tx != null) {
        out.add(_transactionDay(e, d, tx, s, loc));
      } else if (absent.contains(d) || TtDemoDice.roll('${e.email}_absent_${d.month}_${d.day}', 100) < 3) {
        out.add(TtDemoDay(day: AttendanceDay(id: id, employeeEmail: e.email, date: d, status: AttendanceStatus.absent)));
      } else {
        out.add(_workDay(e, d, s, loc, auto: _same(d, autoDay), longBreak: _same(d, longBreakDay)));
      }
    }
    // Today: a few colleagues are checked in right now (one of them late).
    final int other = k - 1;
    if (other >= 0 && other < 4 && _leaveOn(mine, _today) == null && _transactionOn(mine, _today) == null) {
      out.add(_liveToday(e, s, loc, late: other == 3));
    }
    return out;
  }

  String _id(TimeTrackerEmployee e, DateTime d) => TimeTrackerFirestorePaths.attendanceDocId(e.email, d);

  static bool _same(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// The leave status of [d] from an approved / under-review ALL-DAY request.
  AttendanceStatus? _leaveOn(List<TimeTrackerRequest> mine, DateTime d) {
    for (final TimeTrackerRequest r in mine) {
      if (r.isTransaction || !r.isAllDay) continue;
      if (r.status != RequestStatus.approved && r.status != RequestStatus.underReview) continue;
      final DateTime from = TtDemoCalendar.dayOf(r.startAt);
      final DateTime to = TtDemoCalendar.dayOf(r.endAt);
      if (d.isBefore(from) || d.isAfter(to)) continue;
      if (r.requestTypeId == TtDemoIds.sick) return AttendanceStatus.sickLeave;
      if (r.requestTypeId == TtDemoIds.workshop) return AttendanceStatus.excused;
      return AttendanceStatus.vacation;
    }
    return null;
  }

  TimeTrackerRequest? _transactionOn(List<TimeTrackerRequest> mine, DateTime d) {
    for (final TimeTrackerRequest r in mine) {
      if (!r.isTransaction) continue;
      if (r.status != RequestStatus.approved && r.status != RequestStatus.pending) continue;
      if (_same(TtDemoCalendar.dayOf(r.startAt), d)) return r;
    }
    return null;
  }

  /// Where the session was checked in (office most days).
  (WorkLocationType, String) _where(TimeTrackerEmployee e, DateTime d, WorkLocation loc) {
    // Every employee has at least one remote day and one client-site day in
    // the month (Work Locations donut, owner 14:17 #6).
    final int day = d.day % 14;
    if (day == 3) return (WorkLocationType.remote, '');
    if (day == 10) return (WorkLocationType.clientSite, '');
    final int roll = TtDemoDice.roll('${e.email}_where_${d.month}_${d.day}', 100);
    if (roll < 12) return (WorkLocationType.remote, '');
    if (roll < 20) return (WorkLocationType.clientSite, '');
    return (WorkLocationType.office, loc.id);
  }

  TtDemoDay _workDay(
    TimeTrackerEmployee e,
    DateTime d,
    WorkSchedule s,
    WorkLocation loc, {
    required bool auto,
    required bool longBreak,
  }) {
    final String key = '${e.email}_${d.month}_${d.day}';
    final bool late = TtDemoDice.roll('${key}_late', 100) < 13;
    final int inOffset = late
        ? s.lateAfterMinutes + 6 + TtDemoDice.roll('${key}_lm', 50)
        : -14 + TtDemoDice.roll('${key}_in', 14 + (s.lateAfterMinutes > 0 ? s.lateAfterMinutes : 1));
    final DateTime checkIn = DateTime(d.year, d.month, d.day, 0, s.startMinutes + inOffset);
    final DateTime checkOut = auto
        ? DateTime(d.year, d.month, d.day, 0, s.endMinutes)
        : DateTime(d.year, d.month, d.day, 0, s.endMinutes + TtDemoDice.roll('${key}_out', 40));
    final List<AttendancePause> pauses = <AttendancePause>[];
    final List<TtDemoAlert> alerts = <TtDemoAlert>[];
    if (loc.isBreakAllowed && (longBreak || TtDemoDice.roll('${key}_break', 100) < 70)) {
      final int allowed = loc.breakMinutes > 0 ? loc.breakMinutes : 30;
      final int length = longBreak ? allowed + 22 : allowed - TtDemoDice.roll('${key}_bl', 8);
      final DateTime start = DateTime(d.year, d.month, d.day, 12, 30 + TtDemoDice.roll('${key}_bs', 15));
      pauses.add(AttendancePause(startAt: start, endAt: start.add(Duration(minutes: length))));
      if (longBreak) {
        alerts.add(TtDemoAlert(
          type: 'break_exceeded',
          at: start.add(Duration(minutes: allowed)),
          minutesOver: length - allowed,
        ));
      }
    }
    if (loc.isPauseAllowed && TtDemoDice.roll('${key}_pause', 100) < 30) {
      final DateTime start = DateTime(d.year, d.month, d.day, 10, 20 + TtDemoDice.roll('${key}_ps', 25));
      pauses.insert(0, AttendancePause(startAt: start, endAt: start.add(Duration(minutes: 8 + TtDemoDice.roll('${key}_pl', 8)))));
    }
    final (WorkLocationType type, String locationId) = _where(e, d, loc);
    final AttendanceSession session = AttendanceSession(
      checkInAt: checkIn,
      checkOutAt: checkOut,
      workLocationId: locationId,
      workLocationType: type,
      latitude: type == WorkLocationType.office ? loc.latitude : null,
      longitude: type == WorkLocationType.office ? loc.longitude : null,
      pauses: pauses,
    );
    final AttendanceDay day = AttendanceCalculator.apply(
      AttendanceDay(id: _id(e, d), employeeEmail: e.email, date: d, sessions: <AttendanceSession>[session]),
      schedule: s,
      now: input.now,
    );
    if (day.lateMinutes > 0) {
      alerts.insert(0, TtDemoAlert(type: 'late_arrival', at: checkIn, minutesOver: day.lateMinutes));
    }
    if (auto) {
      alerts.add(TtDemoAlert(type: 'auto_check_out', at: checkOut.add(const Duration(minutes: 120))));
    }
    return TtDemoDay(day: day, alerts: alerts, isAutoCheckOut: auto);
  }

  /// A transaction's day: still open (pending) or corrected (approved).
  TtDemoDay _transactionDay(TimeTrackerEmployee e, DateTime d, TimeTrackerRequest tx, WorkSchedule s, WorkLocation loc) {
    final AttendanceSession open = AttendanceSession(
      checkInAt: tx.startAt,
      workLocationId: loc.id,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
    final AttendanceDay openDay = AttendanceCalculator.apply(
      AttendanceDay(id: _id(e, d), employeeEmail: e.email, date: d, sessions: <AttendanceSession>[open]),
      schedule: s,
      // 13/10/2026: no check-out → no total yet (it used to count to the
      // schedule's end, so the row showed "Leaving –" next to "8:04 Hrs").
      now: tx.startAt,
    );
    final List<TtDemoAlert> missed = <TtDemoAlert>[
      TtDemoAlert(type: 'missed_check_out', at: s.endOn(d).add(const Duration(minutes: 30))),
    ];
    if (tx.status != RequestStatus.approved) return TtDemoDay(day: openDay, alerts: missed);
    final AttendanceDay corrected = AttendanceCalculator.apply(
      openDay.copyWith(
        sessions: <AttendanceSession>[open.copyWith(checkOutAt: tx.endAt)],
        isCorrectedByTransaction: true,
        sourceRequestId: tx.id,
      ),
      schedule: s,
      now: input.now,
    );
    return TtDemoDay(day: corrected, alerts: missed, before: openDay);
  }

  /// Checked in this morning and still working.
  TtDemoDay _liveToday(TimeTrackerEmployee e, WorkSchedule s, WorkLocation loc, {required bool late}) {
    final DateTime d = _today;
    final int offset = late ? s.lateAfterMinutes + 55 : -9 + TtDemoDice.roll('${e.email}_today', 12);
    DateTime checkIn = DateTime(d.year, d.month, d.day, 0, s.startMinutes + offset);
    if (checkIn.isAfter(input.now)) checkIn = input.now.subtract(const Duration(minutes: 35));
    final AttendanceSession session = AttendanceSession(
      checkInAt: checkIn,
      workLocationId: loc.id,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
    final AttendanceDay day = AttendanceCalculator.apply(
      AttendanceDay(id: _id(e, d), employeeEmail: e.email, date: d, sessions: <AttendanceSession>[session]),
      schedule: s,
      now: input.now,
    );
    return TtDemoDay(
      day: day,
      alerts: <TtDemoAlert>[
        if (day.lateMinutes > 0) TtDemoAlert(type: 'late_arrival', at: checkIn, minutesOver: day.lateMinutes),
      ],
    );
  }
}
