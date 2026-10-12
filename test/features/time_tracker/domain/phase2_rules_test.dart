/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: phase2_rules_test.dart
/// Purpose: Unit tests for the phase-2 pure rules: "Late After" grace
///          (decision 22), the absent-day date logic (20), the 1 January
///          vacation roll-over (21), dashboard ranges + stats, the
///          attendance filter / tiles, check-in options and transactions
///          (19).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absent_day_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/personal_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// Mon–Fri, 09:00–17:00.
const WorkSchedule _weekdays = WorkSchedule(
  startMinutes: 9 * 60,
  endMinutes: 17 * 60,
  workingDays: <int>[1, 2, 3, 4, 5],
);

AttendanceDay _day(
  DateTime date, {
  AttendanceStatus? status,
  int late = 0,
  int total = 0,
  List<AttendanceSession> sessions = const <AttendanceSession>[],
}) =>
    AttendanceDay(
      id: 'me@co.com_${date.toIso8601String()}',
      employeeEmail: 'me@co.com',
      date: date,
      status: status,
      lateMinutes: late,
      totalWorkMinutes: total,
      sessions: sessions,
    );

TimeTrackerRequest _request(
  DateTime start, {
  RequestStatus status = RequestStatus.pending,
  bool isTransaction = false,
  String email = 'me@co.com',
}) =>
    TimeTrackerRequest(
      id: 'r',
      requesterEmail: email,
      startAt: start,
      endAt: start,
      isTransaction: isTransaction,
      status: status,
      requestTypeId: 't',
    );

void main() {
  group('Late After grace (decision 22)', () {
    // Wed 7 Oct 2026.
    final DateTime day = DateTime(2026, 10, 7);
    const WorkSchedule grace = WorkSchedule(
      startMinutes: 9 * 60,
      endMinutes: 17 * 60,
      lateAfterMinutes: 10,
    );

    test('a check-in inside the grace is on time', () {
      expect(
        AttendanceCalculator.lateMinutes(
          firstCheckIn: DateTime(2026, 10, 7, 9, 10),
          schedule: grace,
          day: day,
        ),
        0,
      );
    });

    test('after the grace, lateness counts from the shift start', () {
      expect(
        AttendanceCalculator.lateMinutes(
          firstCheckIn: DateTime(2026, 10, 7, 9, 11),
          schedule: grace,
          day: day,
        ),
        11,
      );
    });

    test('grace 0 keeps the phase-1 rule (late after the start)', () {
      expect(
        AttendanceCalculator.lateMinutes(
          firstCheckIn: DateTime(2026, 10, 7, 9, 1),
          schedule: _weekdays,
          day: day,
        ),
        1,
      );
    });

    test('Late_After_Minutes round-trips; old documents read 0', () {
      const WorkLocation location = WorkLocation(
        id: 'loc',
        nameEn: 'HQ',
        lateAfterMinutes: 15,
      );
      final Map<String, dynamic> stored = TimeTrackerHistoryCodec.append(
        old: null,
        values: WorkLocationModel.row(
          location,
          id: 'loc',
          audit: TimeTrackerAudit.next(null, actor: 'a@co.com', now: DateTime(2026)),
        ),
        now: DateTime(2026),
      );
      final WorkLocation back = WorkLocationModel.fromMap('loc', stored);
      expect(back.lateAfterMinutes, 15);
      expect(back.schedule.lateAfterMinutes, 15);
      stored.remove(WorkLocationModel.fLateAfterMinutes);
      expect(WorkLocationModel.fromMap('loc', stored).lateAfterMinutes, 0);
    });
  });

  group('AbsentDayRules (decision 20)', () {
    // Monday 12 Oct 2026, 10:00.
    final DateTime now = DateTime(2026, 10, 12, 10);

    test('past working days since the start date with no record', () {
      final List<DateTime> days = AbsentDayRules.daysToMarkAbsent(
        now: now,
        schedule: _weekdays,
        assignmentStart: DateTime(2026, 10, 5), // Monday
        recordedDays: <DateTime>[DateTime(2026, 10, 6)],
        approvedLeaves: const <DayRange>[],
      );
      // Mon 5, Wed 7, Thu 8, Fri 9 (Tue 6 recorded; Sat/Sun off; today never).
      expect(days, <DateTime>[
        DateTime(2026, 10, 5),
        DateTime(2026, 10, 7),
        DateTime(2026, 10, 8),
        DateTime(2026, 10, 9),
      ]);
    });

    test('approved leave covers its days', () {
      final List<DateTime> days = AbsentDayRules.daysToMarkAbsent(
        now: now,
        schedule: _weekdays,
        assignmentStart: DateTime(2026, 10, 5),
        recordedDays: const <DateTime>[],
        approvedLeaves: <DayRange>[
          DayRange(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 8, 17)),
        ],
      );
      expect(days, <DateTime>[DateTime(2026, 10, 5), DateTime(2026, 10, 9)]);
    });

    test('look-back is capped at 31 days', () {
      final List<DateTime> days = AbsentDayRules.daysToMarkAbsent(
        now: now,
        schedule: const WorkSchedule(startMinutes: 540, endMinutes: 1020),
        assignmentStart: DateTime(2026, 1, 1),
        recordedDays: const <DateTime>[],
        approvedLeaves: const <DayRange>[],
      );
      expect(days, hasLength(31));
      expect(days.first, DateTime(2026, 9, 11));
      expect(days.last, DateTime(2026, 10, 11));
    });

    test('no start date: from the first recorded day; none → nothing', () {
      expect(
        AbsentDayRules.daysToMarkAbsent(
          now: now,
          schedule: _weekdays,
          assignmentStart: null,
          recordedDays: const <DateTime>[],
          approvedLeaves: const <DayRange>[],
        ),
        isEmpty,
      );
      expect(
        AbsentDayRules.daysToMarkAbsent(
          now: now,
          schedule: _weekdays,
          assignmentStart: null,
          recordedDays: <DateTime>[DateTime(2026, 10, 8)],
          approvedLeaves: const <DayRange>[],
        ),
        <DateTime>[DateTime(2026, 10, 9)],
      );
    });

    test('an overnight shift still running is not marked', () {
      const WorkSchedule night = WorkSchedule(startMinutes: 22 * 60, endMinutes: 6 * 60);
      final List<DateTime> days = AbsentDayRules.daysToMarkAbsent(
        now: DateTime(2026, 10, 12, 3), // yesterday's shift ends at 06:00
        schedule: night,
        assignmentStart: DateTime(2026, 10, 10),
        recordedDays: const <DateTime>[],
        approvedLeaves: const <DayRange>[],
      );
      expect(days, <DateTime>[DateTime(2026, 10, 10)]);
    });
  });

  // 9/10/2026 (data model, owner): one balance document per employee per
  // year — decision 21's roll-over is gone; the year is part of the id.
  group('vacation balance per year (replaces decision 21)', () {
    test('a request inside one year costs that year only', () {
      final TimeTrackerRequest r = TimeTrackerRequest(
        id: 'r',
        requesterEmail: 'me@co.com',
        startAt: DateTime(2026, 12, 30),
        endAt: DateTime(2026, 12, 31, 23, 59),
        isAllDay: true,
      );
      expect(VacationBalanceRules.daysByYear(r), <int, double>{2026: 2});
    });

    test('the year never changes on copyWith', () {
      const VacationBalance b = VacationBalance(employeeEmail: 'me@co.com', year: 2025, totalDays: 21, usedDays: 3);
      expect(b.copyWith(usedDays: 0).year, 2025);
    });
  });

  group('DateSpan.of', () {
    final DateTime now = DateTime(2026, 10, 8, 15);

    test('day / week / month / year / custom', () {
      DateSpan s = DateSpan.of(DashboardRange.day, now);
      expect(<DateTime>[s.first, s.last], <DateTime>[DateTime(2026, 10, 8), DateTime(2026, 10, 8)]);
      s = DateSpan.of(DashboardRange.week, now);
      expect(s.first, DateTime(2026, 10, 2));
      s = DateSpan.of(DashboardRange.month, now);
      expect(<DateTime>[s.first, s.last], <DateTime>[DateTime(2026, 10, 1), DateTime(2026, 10, 31)]);
      s = DateSpan.of(DashboardRange.year, now);
      expect(<DateTime>[s.first, s.last], <DateTime>[DateTime(2026), DateTime(2026, 12, 31)]);
      s = DateSpan.of(DashboardRange.custom, now,
          custom: DateSpan(DateTime(2026, 2, 3, 10), DateTime(2026, 3, 4, 23)));
      expect(s.contains(DateTime(2026, 3, 4, 23, 59)), isTrue);
      expect(s.contains(DateTime(2026, 3, 5)), isFalse);
    });
  });

  group('PersonalDashboardStats', () {
    test('tiles, requests and late history by month', () {
      final PersonalDashboardStats stats = PersonalDashboardStats.compute(
        email: 'me@co.com',
        span: DateSpan(DateTime(2026, 9, 1), DateTime(2026, 10, 31)),
        vacationDaysLeft: 12,
        days: <AttendanceDay>[
          _day(DateTime(2026, 9, 1), status: AttendanceStatus.present, sessions: <AttendanceSession>[
            AttendanceSession(checkInAt: DateTime(2026, 9, 1, 9), workLocationId: 'hq'),
          ]),
          _day(DateTime(2026, 9, 2), status: AttendanceStatus.late, late: 20, sessions: <AttendanceSession>[
            AttendanceSession(
              checkInAt: DateTime(2026, 9, 2, 9, 20),
              workLocationType: WorkLocationType.remote,
            ),
          ]),
          _day(DateTime(2026, 10, 5), status: AttendanceStatus.late, late: 5),
          _day(DateTime(2026, 10, 6), status: AttendanceStatus.absent),
          _day(DateTime(2026, 8, 30), status: AttendanceStatus.absent), // out of span
        ],
        requests: <TimeTrackerRequest>[
          _request(DateTime(2026, 9, 3), status: RequestStatus.approved),
          _request(DateTime(2026, 9, 4), status: RequestStatus.underReview),
          _request(DateTime(2026, 9, 5), status: RequestStatus.rejected),
          _request(DateTime(2026, 9, 6), status: RequestStatus.canceledByHr),
          _request(DateTime(2026, 9, 7), isTransaction: true), // not a leave
          _request(DateTime(2026, 9, 7), email: 'other@co.com'),
        ],
      );
      expect(stats.present, 3);
      expect(stats.late, 2);
      expect(stats.absent, 1);
      expect(stats.vacationDaysLeft, 12);
      expect(<int>[stats.approved, stats.pending, stats.rejected, stats.canceled],
          <int>[1, 1, 1, 1]);
      expect(stats.totalRequests, 4);
      expect(stats.lateByMonth.map((MonthLate m) => m.month),
          <DateTime>[DateTime(2026, 9), DateTime(2026, 10)]);
      expect(stats.lateByMonth.first.minutes, 20);
      expect(stats.lateByMonth.last.count, 1);
      expect(stats.sessionsByPlace, <String, int>{'hq': 1, 'remote': 1});
    });
  });

  group('AttendanceTable', () {
    final List<AttendanceDay> days = <AttendanceDay>[
      _day(DateTime(2026, 10, 5), status: AttendanceStatus.present, total: 480),
      _day(DateTime(2026, 10, 6), status: AttendanceStatus.late, total: 300),
      _day(DateTime(2026, 10, 7), status: AttendanceStatus.absent),
      _day(DateTime(2026, 10, 8), status: AttendanceStatus.sickLeave),
      _day(DateTime(2026, 10, 9), status: AttendanceStatus.excused),
      _day(DateTime(2026, 10, 10), status: AttendanceStatus.vacation),
    ];

    test('tiles: present includes late', () {
      final AttendanceTileCounts t = AttendanceTable.tiles(days);
      expect(<int>[t.present, t.absent, t.late, t.vacation, t.sickLeave, t.excused],
          <int>[2, 1, 1, 1, 1, 1]);
    });

    test('rows: newest first, filter + search', () {
      String describe(AttendanceDay d) => d.status?.storageKey ?? '';
      expect(
        AttendanceTable.rows(
          days: days,
          filter: AttendanceFilter.none,
          query: '',
          describe: describe,
        ).first.date,
        DateTime(2026, 10, 10),
      );
      // UI quality pass (9/10/2026): Status · date range · location type.
      expect(
        AttendanceTable.rows(
          days: days,
          filter: AttendanceFilter(from: DateTime(2026, 10, 6), to: DateTime(2026, 10, 7)),
          query: '',
          describe: describe,
        ).map((AttendanceDay d) => d.date),
        <DateTime>[DateTime(2026, 10, 7), DateTime(2026, 10, 6)],
      );
      expect(
        AttendanceTable.rows(
          days: days,
          filter: const AttendanceFilter(status: AttendanceStatus.absent),
          query: '',
          describe: describe,
        ).single.date,
        DateTime(2026, 10, 7),
      );
      expect(
        AttendanceTable.rows(
          days: days,
          filter: AttendanceFilter.day(DateTime(2026, 10, 8)),
          query: '',
          describe: describe,
        ).single.status,
        AttendanceStatus.sickLeave,
      );
      expect(
        AttendanceTable.rows(
          days: days,
          filter: AttendanceFilter.none,
          query: 'SICK',
          describe: describe,
        ).single.status,
        AttendanceStatus.sickLeave,
      );
    });
  });

  group('CheckInOptions', () {
    const WorkLocation hq = WorkLocation(id: 'hq', nameEn: 'HQ');
    const WorkLocation branch = WorkLocation(id: 'br', nameEn: 'Branch');
    const WorkLocation closed =
        WorkLocation(id: 'old', nameEn: 'Old', status: LocationStatus.inactive);
    const EmployeeWorkSetup setup = EmployeeWorkSetup(
      owner: WorkSetupOwner.timeTracker,
      location: hq,
      schedule: _weekdays,
      rules: AttendanceRules(
        isDifferentLocationAllowed: true,
        allowedLocationIds: <String>['br', 'old'],
      ),
    );

    test('only the own location without work-elsewhere', () {
      final List<CheckInOption> options = CheckInOptions.build(
        setup: setup,
        companyLocations: const <WorkLocation>[hq, branch, closed],
        mayWorkElsewhere: false,
      );
      expect(options.map((CheckInOption o) => o.key), <String>['hq']);
    });

    test('allowed active locations + Remote + Client Site otherwise', () {
      final List<CheckInOption> options = CheckInOptions.build(
        setup: setup,
        companyLocations: const <WorkLocation>[hq, branch, closed],
        mayWorkElsewhere: true,
      );
      expect(options.map((CheckInOption o) => o.key),
          <String>['hq', 'br', 'remote', 'client_site']);
    });
  });

  group('TransactionRules (decision 19)', () {
    final DateTime now = DateTime(2026, 10, 8, 12);

    test('validation', () {
      expect(
        TransactionRules.validate(checkIn: null, checkOut: null, description: '', now: now),
        <TransactionError>{TransactionError.checkInRequired, TransactionError.checkOutRequired},
      );
      expect(
        TransactionRules.validate(
          checkIn: DateTime(2026, 10, 7, 17),
          checkOut: DateTime(2026, 10, 7, 9),
          description: '',
          now: now,
        ),
        <TransactionError>{TransactionError.checkOutBeforeCheckIn},
      );
      expect(
        TransactionRules.validate(
          checkIn: DateTime(2026, 10, 8, 9),
          checkOut: DateTime(2026, 10, 8, 18),
          description: 'x' * 501,
          now: now,
        ),
        <TransactionError>{TransactionError.inFuture, TransactionError.descriptionTooLong},
      );
    });

    test('build: manager → HR, pending, minutes', () {
      final TimeTrackerRequest t = TransactionRules.build(
        requesterEmail: 'Me@co.com',
        requesterDepartmentId: 'dep',
        managerEmail: 'boss@co.com',
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17, 30),
        description: '  forgot  ',
        now: now,
      );
      expect(t.isTransaction, isTrue);
      expect(t.requesterEmail, 'me@co.com');
      expect(t.totalMinutes, 510);
      expect(t.description, 'forgot');
      expect(t.status, RequestStatus.pending);
      expect(t.currentStep, ApprovalStepKind.manager);
      expect(t.approvalSteps.map((s) => s.step),
          <ApprovalStepKind>[ApprovalStepKind.manager, ApprovalStepKind.hr]);
    });

    test('build without a manager → HR only', () {
      final TimeTrackerRequest t = TransactionRules.build(
        requesterEmail: 'me@co.com',
        requesterDepartmentId: '',
        managerEmail: '',
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17),
        description: '',
        now: now,
      );
      expect(t.currentStep, ApprovalStepKind.hr);
      expect(t.approvalSteps.single.step, ApprovalStepKind.hr);
    });

    test('cancel: requester only, pending only', () {
      final TimeTrackerRequest t = TransactionRules.build(
        requesterEmail: 'me@co.com',
        requesterDepartmentId: '',
        managerEmail: '',
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17),
        description: '',
        now: now,
      );
      expect(TransactionRules.canCancel(t, 'ME@co.com'), isTrue);
      expect(TransactionRules.canCancel(t, 'other@co.com'), isFalse);
      final TimeTrackerRequest canceled = TransactionRules.cancel(t, reason: ' oops ');
      expect(canceled.status, RequestStatus.canceled);
      expect(canceled.currentStep, isNull);
      expect(canceled.cancellationReason, 'oops');
      expect(TransactionRules.canCancel(canceled, 'me@co.com'), isFalse);
      expect(() => TransactionRules.cancel(canceled), throwsStateError);
    });
  });
}
