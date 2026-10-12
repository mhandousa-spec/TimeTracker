/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_calculator_test.dart
/// Purpose: Unit tests for `AttendanceCalculator` (late / break / total
///          minutes and status) and `AttendanceSessionRules` (check in /
///          pause / resume / check out).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_session_rules.dart';

void main() {
  // Wednesday 7 Oct 2026; shift 09:00–17:00, Sunday–Thursday.
  final DateTime day = DateTime(2026, 10, 7);
  DateTime at(int h, [int m = 0]) => DateTime(2026, 10, 7, h, m);
  const WorkSchedule schedule = WorkSchedule(
    startMinutes: 9 * 60,
    endMinutes: 17 * 60,
    workingDays: <int>[7, 1, 2, 3, 4],
  );

  AttendanceSession session(
    DateTime checkIn, {
    DateTime? checkOut,
    List<AttendancePause> pauses = const <AttendancePause>[],
  }) =>
      AttendanceSession(checkInAt: checkIn, checkOutAt: checkOut, pauses: pauses);

  group('totals', () {
    test('total work = span minus pauses; break = pauses', () {
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: day,
        sessions: <AttendanceSession>[
          session(at(9), checkOut: at(17), pauses: <AttendancePause>[
            AttendancePause(startAt: at(12), endAt: at(12, 30)),
            AttendancePause(startAt: at(15), endAt: at(15, 15)),
          ]),
        ],
        schedule: schedule,
        now: at(18),
      );
      expect(s.totalWorkMinutes, 8 * 60 - 45);
      expect(s.breakMinutes, 45);
      expect(s.lateMinutes, 0);
      expect(s.status, AttendanceStatus.present);
    });

    test('several sessions add up; an open session and pause run to now', () {
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: day,
        sessions: <AttendanceSession>[
          session(at(9), checkOut: at(11)),
          session(at(13), pauses: <AttendancePause>[
            AttendancePause(startAt: at(14)),
          ]),
        ],
        schedule: schedule,
        now: at(14, 30),
      );
      expect(s.totalWorkMinutes, 120 + 60);
      expect(s.breakMinutes, 30);
    });

    test('a pause still open at check-out ends at the check-out', () {
      expect(
        AttendanceCalculator.pauseMinutes(
          session(at(9), checkOut: at(10), pauses: <AttendancePause>[
            AttendancePause(startAt: at(9, 40)),
          ]),
          at(23),
        ),
        20,
      );
    });
  });

  group('late / status', () {
    test('first check-in after the shift start is late', () {
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: day,
        sessions: <AttendanceSession>[session(at(9, 25), checkOut: at(17))],
        schedule: schedule,
        now: at(18),
      );
      expect(s.lateMinutes, 25);
      expect(s.status, AttendanceStatus.late);
    });

    test('no schedule or a day off never counts as late', () {
      expect(
        AttendanceCalculator.lateMinutes(
          firstCheckIn: at(11),
          schedule: null,
          day: day,
        ),
        0,
      );
      final DateTime friday = DateTime(2026, 10, 9);
      expect(
        AttendanceCalculator.lateMinutes(
          firstCheckIn: DateTime(2026, 10, 9, 11),
          schedule: schedule,
          day: friday,
        ),
        0,
      );
    });

    test('no sessions: undecided before the shift ends, absent after', () {
      AttendanceStatus? statusAt(DateTime now) => AttendanceCalculator.summarize(
            day: day,
            sessions: const <AttendanceSession>[],
            schedule: schedule,
            now: now,
          ).status;
      expect(statusAt(at(16, 59)), isNull);
      expect(statusAt(at(17)), AttendanceStatus.absent);
    });

    test('no sessions on a day off is never absent', () {
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: DateTime(2026, 10, 9),
        sessions: const <AttendanceSession>[],
        schedule: schedule,
        now: DateTime(2026, 10, 10),
      );
      expect(s.status, isNull);
    });

    test('an approved leave wins over absent and late', () {
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: day,
        sessions: const <AttendanceSession>[],
        schedule: schedule,
        now: at(23),
        leaveStatus: AttendanceStatus.sickLeave,
      );
      expect(s.status, AttendanceStatus.sickLeave);
    });

    test('an overnight shift ends the next day', () {
      const WorkSchedule night =
          WorkSchedule(startMinutes: 22 * 60, endMinutes: 6 * 60);
      expect(night.isOvernight, isTrue);
      expect(night.endOn(day), DateTime(2026, 10, 8, 6));
      expect(night.shiftMinutes, 8 * 60);
      final AttendanceSummary s = AttendanceCalculator.summarize(
        day: day,
        sessions: const <AttendanceSession>[],
        schedule: night,
        now: DateTime(2026, 10, 8, 5),
      );
      expect(s.status, isNull);
    });

    test('apply writes the derived fields onto the day', () {
      final AttendanceDay d = AttendanceCalculator.apply(
        AttendanceDay(
          id: 'x',
          employeeEmail: 'me@co.com',
          date: day,
          sessions: <AttendanceSession>[session(at(9, 10), checkOut: at(10))],
        ),
        schedule: schedule,
        now: at(12),
      );
      expect(d.lateMinutes, 10);
      expect(d.totalWorkMinutes, 50);
      expect(d.status, AttendanceStatus.late);
    });
  });

  group('AttendanceSessionRules', () {
    final AttendanceDay empty =
        AttendanceDay(id: 'x', employeeEmail: 'me@co.com', date: day);

    test('check in → pause → resume → check out', () {
      AttendanceDay d = AttendanceSessionRules.checkIn(
        empty,
        at: at(9),
        locationId: 'loc',
        type: WorkLocationType.office,
      );
      expect(d.isCheckedIn, isTrue);
      d = AttendanceSessionRules.pause(d, at: at(12), isPauseAllowed: true);
      expect(d.isPaused, isTrue);
      d = AttendanceSessionRules.resume(d, at: at(12, 30));
      expect(d.isPaused, isFalse);
      d = AttendanceSessionRules.checkOut(d, at: at(17));
      expect(d.isCheckedIn, isFalse);
      expect(d.lastCheckOutAt, at(17));
      expect(d.sessions.single.pauses.single.endAt, at(12, 30));
    });

    test('several check-ins a day open several sessions', () {
      AttendanceDay d = AttendanceSessionRules.checkIn(empty,
          at: at(9), locationId: 'a', type: WorkLocationType.office);
      d = AttendanceSessionRules.checkOut(d, at: at(11));
      d = AttendanceSessionRules.checkIn(d,
          at: at(13), locationId: '', type: WorkLocationType.remote);
      expect(d.sessions, hasLength(2));
      expect(d.firstCheckInAt, at(9));
    });

    test('checking out while paused closes the pause too', () {
      AttendanceDay d = AttendanceSessionRules.checkIn(empty,
          at: at(9), locationId: 'a', type: WorkLocationType.office);
      d = AttendanceSessionRules.pause(d, at: at(10), isPauseAllowed: true);
      d = AttendanceSessionRules.checkOut(d, at: at(10, 20));
      expect(d.sessions.single.pauses.single.endAt, at(10, 20));
    });

    test('invalid moves throw', () {
      final AttendanceDay inDay = AttendanceSessionRules.checkIn(empty,
          at: at(9), locationId: 'a', type: WorkLocationType.office);
      expect(
        () => AttendanceSessionRules.checkIn(inDay,
            at: at(10), locationId: 'a', type: WorkLocationType.office),
        throwsStateError,
      );
      expect(
        () => AttendanceSessionRules.pause(inDay, at: at(10), isPauseAllowed: false),
        throwsStateError,
      );
      expect(() => AttendanceSessionRules.resume(inDay, at: at(10)), throwsStateError);
      expect(() => AttendanceSessionRules.checkOut(empty, at: at(10)), throwsStateError);
    });
  });
}
