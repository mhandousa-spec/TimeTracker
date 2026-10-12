/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: phase5_rules_test.dart
/// Purpose: Unit tests of the phase-5 pure rules: HR dashboard scope, the
///          day book (stored + unstored absences, leave, due times), every
///          chart's numbers, the KPI strip, Needs attention, and the Vacation
///          Balances list / edit / import rules.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_attention.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_days.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_scope.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';

/// Friday 9 Oct 2026, 10:30.
final DateTime _now = DateTime(2026, 10, 9, 10, 30);

const TimeTrackerEmployee _me = TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1');
const TimeTrackerEmployee _amr = TimeTrackerEmployee(email: 'amr@co.com', nameEn: 'Amr M', departmentId: 'dep-1');
const TimeTrackerEmployee _sara = TimeTrackerEmployee(email: 'sara@co.com', nameEn: 'Sara A', departmentId: 'dep-2');
const List<TimeTrackerEmployee> _all = <TimeTrackerEmployee>[_me, _amr, _sara];

/// 9:00 – 17:00, every day, Late After 10.
const WorkSchedule _day = WorkSchedule(startMinutes: 540, endMinutes: 1020, lateAfterMinutes: 10);

EmployeePlacement _place(String email, {String location = 'hq', WorkSchedule schedule = _day, DateTime? start}) =>
    EmployeePlacement(email: email, locationId: location, schedule: schedule, startDate: start ?? DateTime(2026, 10, 1));

AttendanceDay _rec(String email, DateTime d, {AttendanceStatus? status, List<AttendanceSession>? sessions}) =>
    AttendanceDay(
      id: '${email}_$d',
      employeeEmail: email,
      date: DateTime(d.year, d.month, d.day),
      status: status,
      sessions: sessions ?? const <AttendanceSession>[],
    );

TimeTrackerRequest _req(
  String id,
  String email, {
  RequestStatus status = RequestStatus.pending,
  String type = 'sick',
  DateTime? start,
  DateTime? end,
  DateTime? created,
  bool transaction = false,
  List<RequestApprovalStep> steps = const <RequestApprovalStep>[
    RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com'),
  ],
}) =>
    TimeTrackerRequest(
      id: id,
      requesterEmail: email,
      requestTypeId: transaction ? '' : type,
      isTransaction: transaction,
      startAt: start ?? DateTime(2026, 10, 5),
      endAt: end ?? start ?? DateTime(2026, 10, 5),
      isAllDay: true,
      status: status,
      approvalSteps: steps,
      audit: AuditInfo(createdAt: created ?? DateTime(2026, 10, 1), updatedAt: created ?? DateTime(2026, 10, 1)),
    );

void main() {
  group('HrDashboardScope', () {
    test('without All Departments only the viewer\'s own department; none known → nobody', () {
      expect(HrDashboardScope.permitted(_all, allDepartments: false, ownDepartmentId: 'dep-1'), <TimeTrackerEmployee>[_me, _amr]);
      expect(HrDashboardScope.permitted(_all, allDepartments: false, ownDepartmentId: ''), isEmpty);
      expect(HrDashboardScope.permitted(_all, allDepartments: true, ownDepartmentId: ''), hasLength(3));
    });

    test('Department filter only counts with All Departments; Location by placement; employees only with the switch', () {
      final Map<String, EmployeePlacement> places = <String, EmployeePlacement>{
        'me@co.com': _place('me@co.com'),
        'sara@co.com': _place('sara@co.com', location: 'branch'),
      };
      List<TimeTrackerEmployee> apply(HrDashboardFilters f, {bool all = true, bool byEmployee = true}) =>
          HrDashboardScope.apply(_all, filters: f, placements: places, allDepartments: all, canFilterByEmployee: byEmployee);
      expect(apply(const HrDashboardFilters(departmentId: 'dep-2')), <TimeTrackerEmployee>[_sara]);
      expect(apply(const HrDashboardFilters(departmentId: 'dep-2'), all: false), hasLength(3));
      expect(apply(const HrDashboardFilters(locationId: 'branch')), <TimeTrackerEmployee>[_sara]);
      expect(apply(const HrDashboardFilters(employeeEmails: <String>{'AMR@co.com'})), <TimeTrackerEmployee>[_amr]);
      expect(apply(const HrDashboardFilters(employeeEmails: <String>{'amr@co.com'}), byEmployee: false), hasLength(3));
    });
  });

  group('HrDayBook', () {
    HrDayBook book({
      List<AttendanceDay> days = const <AttendanceDay>[],
      List<TimeTrackerRequest> requests = const <TimeTrackerRequest>[],
      Map<String, EmployeePlacement>? places,
      DateTime? now,
    }) =>
        HrDayBook.build(
          days: days,
          requests: requests,
          placements: places ?? <String, EmployeePlacement>{'me@co.com': _place('me@co.com')},
          now: now ?? _now,
        );

    test('stored statuses: present / late / leave / absent (absent + approved leave = leave)', () {
      final HrDayBook b = book(
        days: <AttendanceDay>[
          _rec('me@co.com', DateTime(2026, 10, 1), status: AttendanceStatus.present),
          _rec('me@co.com', DateTime(2026, 10, 2), status: AttendanceStatus.late),
          _rec('me@co.com', DateTime(2026, 10, 3), status: AttendanceStatus.sickLeave),
          _rec('me@co.com', DateTime(2026, 10, 4), status: AttendanceStatus.absent),
          _rec('me@co.com', DateTime(2026, 10, 5), status: AttendanceStatus.absent),
        ],
        requests: <TimeTrackerRequest>[
          _req('r1', 'me@co.com', status: RequestStatus.approved, start: DateTime(2026, 10, 5)),
        ],
      );
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 1)), HrDayKind.present);
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 2)), HrDayKind.late);
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 3)), HrDayKind.leave);
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 4)), HrDayKind.absent);
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 5)), HrDayKind.leave);
    });

    test('an unstored working day after the start counts as absent once its shift has ended', () {
      final HrDayBook b = book();
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 6)), HrDayKind.absent);
      expect(b.kindOf('me@co.com', DateTime(2026, 9, 30)), isNull, reason: 'before the assignment start');
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 12)), isNull, reason: 'future');
      expect(b.kindOf('amr@co.com', DateTime(2026, 10, 6)), isNull, reason: 'no placement → no unstored absence');
      final HrDayBook old = book(places: <String, EmployeePlacement>{
        'me@co.com': _place('me@co.com', start: DateTime(2026, 1, 1)),
      });
      expect(old.kindOf('me@co.com', DateTime(2026, 9, 20)), HrDayKind.absent, reason: 'within 31 days');
      expect(old.kindOf('me@co.com', DateTime(2026, 8, 1)), isNull, reason: 'older than the sweep ever writes');
    });

    test('today is absent only after start + Late After, and never on approved leave', () {
      expect(book(now: DateTime(2026, 10, 9, 9, 5)).kindOf('me@co.com', DateTime(2026, 10, 9)), isNull);
      expect(book(now: DateTime(2026, 10, 9, 9, 11)).kindOf('me@co.com', DateTime(2026, 10, 9)), HrDayKind.absent);
      final HrDayBook onLeave = book(requests: <TimeTrackerRequest>[
        _req('r', 'me@co.com', status: RequestStatus.approved, start: DateTime(2026, 10, 8), end: DateTime(2026, 10, 10)),
      ]);
      expect(onLeave.kindOf('me@co.com', DateTime(2026, 10, 9)), HrDayKind.leave);
      final HrDayBook pendingLeave = book(requests: <TimeTrackerRequest>[
        _req('r', 'me@co.com', start: DateTime(2026, 10, 9)),
      ]);
      expect(pendingLeave.kindOf('me@co.com', DateTime(2026, 10, 9)), HrDayKind.absent, reason: 'pending does not excuse');
    });

    test('non-working days and the first recorded day when no start date is known', () {
      const WorkSchedule weekdays = WorkSchedule(startMinutes: 540, endMinutes: 1020, workingDays: <int>[1, 2, 3, 4, 5]);
      final HrDayBook b = book(
        places: <String, EmployeePlacement>{
          'me@co.com': const EmployeePlacement(email: 'me@co.com', locationId: 'hq', schedule: weekdays),
        },
        days: <AttendanceDay>[_rec('me@co.com', DateTime(2026, 10, 5), status: AttendanceStatus.present)],
      );
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 3)), isNull, reason: 'Saturday');
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 2)), isNull, reason: 'before the first recorded day');
      expect(b.kindOf('me@co.com', DateTime(2026, 10, 6)), HrDayKind.absent);
      expect(b.countIn('me@co.com', DateSpan(DateTime(2026, 10, 1), DateTime(2026, 10, 31)))[HrDayKind.absent], 4,
          reason: '6, 7, 8 Oct + today (due: 10:30 > 09:00); 10–31 Oct are in the future');
    });

    test('runningNow: today\'s open session yes; yesterday\'s only on an overnight shift not ended yet', () {
      final AttendanceSession open = AttendanceSession(checkInAt: DateTime(2026, 10, 8, 22));
      final AttendanceDay yesterday = _rec('me@co.com', DateTime(2026, 10, 8), sessions: <AttendanceSession>[open]);
      expect(book().runningNow(_rec('me@co.com', DateTime(2026, 10, 9), sessions: <AttendanceSession>[open])), isTrue);
      expect(book().runningNow(yesterday), isFalse, reason: 'day shift — a missing check-out');
      const WorkSchedule night = WorkSchedule(startMinutes: 1320, endMinutes: 360);
      final Map<String, EmployeePlacement> nightShift = <String, EmployeePlacement>{
        'me@co.com': _place('me@co.com', schedule: night),
      };
      expect(book(places: nightShift, now: DateTime(2026, 10, 9, 5)).runningNow(yesterday), isTrue);
      expect(book(places: nightShift, now: DateTime(2026, 10, 9, 7)).runningNow(yesterday), isFalse);
    });
  });

  group('HrDashboardStats', () {
    final Map<String, EmployeePlacement> places = <String, EmployeePlacement>{
      for (final TimeTrackerEmployee e in _all) e.email: _place(e.email),
    };
    final DateSpan year = DateSpan.of(DashboardRange.year, _now);

    test('Requests donut: leave requests of the scoped employees by start, transactions excluded', () {
      final HrDashboardStats s = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me, _amr],
        placements: places,
        days: const <AttendanceDay>[],
        requests: <TimeTrackerRequest>[
          _req('1', 'me@co.com', status: RequestStatus.approved),
          _req('2', 'me@co.com', status: RequestStatus.underReview),
          _req('3', 'amr@co.com', status: RequestStatus.rejected),
          _req('4', 'amr@co.com', status: RequestStatus.canceledByHr),
          _req('5', 'amr@co.com', transaction: true),
          _req('6', 'sara@co.com', status: RequestStatus.approved),
          _req('7', 'me@co.com', start: DateTime(2025, 12, 30)),
        ],
        span: year,
        now: _now,
      );
      expect(<int>[s.approved, s.pending, s.rejected, s.canceled], <int>[1, 1, 1, 1]);
      expect(s.totalRequests, 4);
      expect(s.employeeCount, 2);
    });

    test('Request Types donut: most first, top 4 + Others; Request Types bars follow the chosen type', () {
      final List<TimeTrackerRequest> list = <TimeTrackerRequest>[
        for (int i = 0; i < 5; i++) _req('a$i', 'me@co.com', type: 'annual', start: DateTime(2026, 3, 2)),
        for (int i = 0; i < 4; i++) _req('s$i', 'me@co.com', type: 'sick', start: DateTime(2026, 4, 2)),
        for (int i = 0; i < 3; i++) _req('m$i', 'me@co.com', type: 'mission'),
        for (int i = 0; i < 2; i++) _req('e$i', 'me@co.com', type: 'emergency'),
        _req('x', 'me@co.com', type: 'marriage'),
        _req('y', 'me@co.com', type: 'birth'),
      ];
      final HrDashboardStats s = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me],
        placements: places,
        days: const <AttendanceDay>[],
        requests: list,
        span: year,
        now: _now,
        requestTypeId: 'annual',
      );
      expect(s.typeSlices.map((HrTypeSlice t) => t.typeId).toList(), <String>['annual', 'sick', 'mission', 'emergency', '']);
      expect(s.typeSlices.last.count, 2);
      expect(s.totalTypeRequests, 16);
      expect(s.typeByMonth, hasLength(10), reason: 'Jan – Oct: the empty Nov / Dec are dropped');
      expect(s.attendanceByMonth.last.month, DateTime(2026, 10));
      expect(s.typeByMonth[2].count, 5, reason: 'March');
      expect(s.typeByMonth.fold<int>(0, (int a, HrMonthCount m) => a + m.count), 5);
      final HrDashboardStats five = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me],
        placements: places,
        days: const <AttendanceDay>[],
        requests: list.where((TimeTrackerRequest r) => r.requestTypeId != 'birth').toList(),
        span: year,
        now: _now,
      );
      expect(five.typeSlices.any((HrTypeSlice t) => t.isOthers), isFalse, reason: '5 types fit without Others');
    });

    test('Request Timeline: every request and transaction by creation month', () {
      final HrDashboardStats s = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me],
        placements: places,
        days: const <AttendanceDay>[],
        requests: <TimeTrackerRequest>[
          _req('1', 'me@co.com', created: DateTime(2026, 2, 3)),
          _req('2', 'me@co.com', created: DateTime(2026, 2, 20), transaction: true),
          _req('3', 'me@co.com', created: DateTime(2026, 10, 2)),
        ],
        span: year,
        now: _now,
      );
      expect(s.timelineByMonth[1].count, 2);
      expect(s.timelineByMonth[9].count, 1);
      final HrDashboardStats ahead = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me],
        placements: places,
        days: const <AttendanceDay>[],
        requests: <TimeTrackerRequest>[_req('n', 'me@co.com', start: DateTime(2026, 11, 20))],
        span: year,
        now: _now,
      );
      expect(ahead.typeByMonth.last.month, DateTime(2026, 11), reason: 'a future month with a leave stays');
    });

    test('Attendance History per month: Present incl. late, Absent incl. unstored, Late, Vacation', () {
      final HrDashboardStats s = HrDashboardStats.compute(
        employees: <TimeTrackerEmployee>[_me],
        placements: <String, EmployeePlacement>{'me@co.com': _place('me@co.com', start: DateTime(2026, 10, 1))},
        days: <AttendanceDay>[
          _rec('me@co.com', DateTime(2026, 10, 1), status: AttendanceStatus.present),
          _rec('me@co.com', DateTime(2026, 10, 2), status: AttendanceStatus.late),
          _rec('me@co.com', DateTime(2026, 10, 3), status: AttendanceStatus.vacation),
          _rec('me@co.com', DateTime(2026, 10, 4), status: AttendanceStatus.absent),
        ],
        requests: <TimeTrackerRequest>[
          _req('l', 'me@co.com', status: RequestStatus.approved, start: DateTime(2026, 10, 5), end: DateTime(2026, 10, 6)),
        ],
        span: DateSpan.of(DashboardRange.month, _now),
        now: _now,
      );
      final HrMonthAttendance oct = s.attendanceByMonth.single;
      expect(oct.present, 2);
      expect(oct.late, 1);
      expect(oct.leave, 3, reason: '3 Oct stored + 5–6 Oct approved leave');
      expect(oct.absent, 4, reason: '4 Oct stored + 7, 8, 9 Oct unstored');
    });

    test('KPI strip: checked in now · late · absent · on leave today · pending approvals', () {
      final AttendanceSession open = AttendanceSession(checkInAt: DateTime(2026, 10, 9, 9, 30));
      final HrDashboardStats s = HrDashboardStats.compute(
        employees: _all,
        placements: places,
        days: <AttendanceDay>[
          _rec('me@co.com', DateTime(2026, 10, 9), status: AttendanceStatus.late, sessions: <AttendanceSession>[open]),
        ],
        requests: <TimeTrackerRequest>[
          _req('l', 'amr@co.com', status: RequestStatus.approved, start: DateTime(2026, 10, 9)),
          _req('p1', 'sara@co.com'),
          _req('p2', 'sara@co.com', transaction: true, status: RequestStatus.underReview),
          _req('done', 'sara@co.com', status: RequestStatus.rejected),
        ],
        span: year,
        now: _now,
      );
      expect(s.kpi.checkedInNow, 1);
      expect(s.kpi.lateToday, 1);
      expect(s.kpi.onLeaveToday, 1);
      expect(s.kpi.absentToday, 1, reason: 'Sara: no check-in, past 09:10');
      expect(s.kpi.pendingApprovals, 2);
    });
  });

  group('HrNeedsAttention', () {
    test('overdue approvals (> 2 days, oldest first), 3+ absences, missing check-outs, waiting transactions', () {
      final HrDayBook book = HrDayBook.build(
        days: <AttendanceDay>[
          _rec('me@co.com', DateTime(2026, 10, 8),
              status: AttendanceStatus.present,
              sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 8, 9))]),
          for (int d = 1; d <= 8; d++) _rec('amr@co.com', DateTime(2026, 10, d), status: AttendanceStatus.present),
        ],
        requests: const <TimeTrackerRequest>[],
        placements: <String, EmployeePlacement>{
          'sara@co.com': _place('sara@co.com', start: DateTime(2026, 10, 6)),
          'amr@co.com': _place('amr@co.com'),
        },
        now: _now,
      );
      final HrNeedsAttention a = HrNeedsAttention.compute(
        emails: <String>{'me@co.com', 'amr@co.com', 'sara@co.com'},
        book: book,
        requests: <TimeTrackerRequest>[
          _req('old', 'me@co.com', created: DateTime(2026, 10, 2)),
          _req('older', 'amr@co.com', created: DateTime(2026, 10, 1)),
          _req('fresh', 'amr@co.com', created: DateTime(2026, 10, 8)),
          _req('t', 'sara@co.com', transaction: true, created: DateTime(2026, 10, 8, 12)),
          _req('other', 'x@co.com', created: DateTime(2026, 9, 1)),
        ],
      );
      expect(a.overdueApprovals.map((TimeTrackerRequest r) => r.id).toList(), <String>['older', 'old']);
      expect(a.frequentAbsences.single.email, 'sara@co.com');
      expect(a.frequentAbsences.single.count, 4, reason: '6, 7, 8, 9 Oct');
      expect(a.missingCheckOuts.single.employeeEmail, 'me@co.com');
      expect(a.waitingTransactions.single.id, 't');
      expect(a.isEmpty, isFalse);
    });

    test('a decided HR step waits since that decision; nothing pending → empty', () {
      final TimeTrackerRequest atHr = _req(
        'hr',
        'me@co.com',
        created: DateTime(2026, 9, 1),
        steps: <RequestApprovalStep>[
          RequestApprovalStep(
            step: ApprovalStepKind.manager,
            approverEmail: 'boss@co.com',
            decision: ApprovalDecision.approved,
            decidedAt: DateTime(2026, 10, 8),
          ),
          const RequestApprovalStep(step: ApprovalStepKind.hr),
        ],
      );
      final HrDayBook book = HrDayBook.build(
        days: const <AttendanceDay>[],
        requests: const <TimeTrackerRequest>[],
        placements: const <String, EmployeePlacement>{},
        now: _now,
      );
      expect(HrNeedsAttention.compute(emails: <String>{'me@co.com'}, book: book, requests: <TimeTrackerRequest>[atHr]).isEmpty,
          isTrue);
    });
  });

  group('Vacation Balances rules', () {
    // 9/10/2026 (data model): one document per employee per YEAR — another
    // year's balance is never shown in the selected year (no roll-over).
    test('one row per employee for the selected year; another year is not this year\'s; none stored → 0 days', () {
      final List<VacationBalanceRow> rows = VacationBalanceList.rows(
        employees: _all,
        balances: const <VacationBalance>[
          VacationBalance(employeeEmail: 'me@co.com', year: 2025, totalDays: 21, usedDays: 9),
          VacationBalance(employeeEmail: 'amr@co.com', year: 2026, totalDays: 15, usedDays: 4.5),
        ],
        year: 2026,
      );
      expect(rows.map((VacationBalanceRow r) => r.employee.email).toList(), <String>['amr@co.com', 'me@co.com', 'sara@co.com']);
      expect(rows[1].balance.year, 2026);
      expect(rows[1].isStored, isFalse, reason: 'the 2025 document is not the 2026 balance');
      expect(rows[1].balance.totalDays, 0);
      expect(rows[1].balance.remainingDays, 0);
      expect(rows[0].balance.remainingDays, 10.5);
      expect(VacationBalanceYears.selectable(2026), <int>[2027, 2026, 2025, 2024, 2023]);
      expect(rows[2].isStored, isFalse);
      expect(rows[2].balance.totalDays, 0);
      expect(VacationBalanceList.filter(rows, departmentId: 'dep-2').single.employee, _sara);
      expect(VacationBalanceList.filter(rows, query: 'AMR').single.employee, _amr);
      expect(VacationBalanceList.days(21), '21');
      expect(VacationBalanceList.days(2.5), '2.5');
    });

    test('Total Days: required, 0–366, one decimal, Arabic digits read', () {
      expect(VacationBalanceEditRules.validate(''), VacationTotalError.required);
      expect(VacationBalanceEditRules.validate('abc'), VacationTotalError.invalid);
      expect(VacationBalanceEditRules.validate('-1'), VacationTotalError.invalid);
      expect(VacationBalanceEditRules.validate('2.25'), VacationTotalError.invalid);
      expect(VacationBalanceEditRules.validate('400'), VacationTotalError.tooLarge);
      expect(VacationBalanceEditRules.validate('21.5'), isNull);
      expect(VacationBalanceEditRules.validate('2.3'), isNull, reason: '2.3 × 10 is not exact in binary');
      expect(VacationBalanceEditRules.parseTotal('٢١'), 21);
      expect(VacationBalanceEditRules.parseTotal('2٫5'), 2.5);
    });

    test('apply: keeps used days within the year; another year\'s balance is ignored; creates a new one', () {
      const VacationBalance same = VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 5);
      expect(VacationBalanceEditRules.apply(email: 'me@co.com', stored: same, year: 2026, totalDays: 25).usedDays, 5);
      const VacationBalance old = VacationBalance(employeeEmail: 'me@co.com', year: 2025, totalDays: 21, usedDays: 5);
      final VacationBalance fresh = VacationBalanceEditRules.apply(email: 'me@co.com', stored: old, year: 2026, totalDays: 25);
      expect(<Object>[fresh.year, fresh.usedDays, fresh.totalDays], <Object>[2026, 0.0, 25.0]);
      final VacationBalance created = VacationBalanceEditRules.apply(email: 'New@co.com', stored: null, year: 2026, totalDays: 10);
      expect(<Object>[created.employeeEmail, created.usedDays], <Object>['new@co.com', 0.0]);
    });

    test('import plan: columns, unknown / duplicate e-mails, years, totals, create / update / unchanged', () {
      VacationImportPlan plan(List<List<String>> grid) => VacationBalanceImportRules.plan(
            grid: grid,
            employees: _all,
            stored: const <VacationBalance>[
              VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21),
              VacationBalance(employeeEmail: 'amr@co.com', year: 2026, totalDays: 15),
            ],
            year: 2026,
          );
      expect(plan(const <List<String>>[<String>['Email', 'Year']]).missingColumns, isTrue);
      final VacationImportPlan p = plan(const <List<String>>[
        <String>['email', 'YEAR', 'Total Days', 'Notes'],
        <String>['me@co.com', '2026', '21', ''],
        <String>['AMR@co.com', '', '18', ''],
        <String>['sara@co.com', '2026', '12.5', ''],
        <String>['ghost@co.com', '2026', '10', ''],
        <String>['me@co.com', '2026', '30', ''],
        <String>['', '', '', ''],
      ]);
      expect(p.rows.map((VacationImportRow r) => r.action).toList(), <VacationImportAction>[
        VacationImportAction.unchanged,
        VacationImportAction.update,
        VacationImportAction.create,
        VacationImportAction.skip,
        VacationImportAction.skip,
      ]);
      expect(p.rows[3].issues, <VacationImportIssue>[VacationImportIssue.unknownEmployee]);
      expect(p.rows[4].issues, <VacationImportIssue>[VacationImportIssue.duplicateEmail]);
      expect(p.writable.map((VacationImportRow r) => r.email).toList(), <String>['amr@co.com', 'sara@co.com']);
      expect(p.rows[2].balance!.totalDays, 12.5);
      final VacationImportPlan bad = plan(const <List<String>>[
        <String>['Email', 'Year', 'Total Days'],
        <String>['me@co.com', '2025', '21'],
        <String>['amr@co.com', '2026', ''],
        <String>['sara@co.com', '2026', '999'],
      ]);
      expect(bad.rows.map((VacationImportRow r) => r.issues.single).toList(), <VacationImportIssue>[
        VacationImportIssue.wrongYear,
        VacationImportIssue.totalRequired,
        VacationImportIssue.totalTooLarge,
      ]);
      expect(bad.writable, isEmpty);
    });
  });
}
