/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_stats.dart
/// Purpose: Declares `HrDashboardStats` — every number of the HR dashboard
///          (Overview → HR) for the scoped employees and the chosen range —
///          with its parts `HrDashboardKpi`, `HrMonthAttendance`,
///          `HrMonthCount` and `HrTypeSlice`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Figma HR Dashboard `661:42563` / `661:42895` / `661:43247` (+ the KPI
/// strip and Needs attention card the owner asked for). Rules:
///   * Requests donut — the employees' leave requests (not transactions)
///     whose START falls in the range: Approved · Pending (incl. under
///     review) · Rejected · Canceled (incl. canceled by HR) — the personal
///     dashboard's rule, for many employees.
///   * Request Types donut — the same requests per type (every status),
///     most first; more than [topTypes] + 1 types → the top [topTypes] and
///     "Others".
///   * Attendance History — per calendar month the range touches: Present
///     (attended days, late ones included — same as the Overall tile),
///     Absent, Late, Vacation (leave days) from `HrDayBook`.
///   * Request Types bars — per month, the leave requests of the chosen
///     type (all types when none is chosen), by start.
///   * Request Timeline — per month, every request AND transaction
///     submitted (creation date).
///   * Months: every calendar month the range touches, without the empty
///     months after the current one (attendance never has future days; the
///     Request Types bars keep a future month that holds a leave).
///   * KPI strip (always TODAY, whatever the range): Checked in now · Late
///     today · Absent today · On leave today · Pending approvals (requests +
///     transactions waiting for a decision).
/// Pure Dart — unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_attention.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_days.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_scope.dart';

/// Attendance History bars of one month.
class HrMonthAttendance {
  const HrMonthAttendance({
    required this.month,
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.leave = 0,
  });

  /// First day of the month.
  final DateTime month;
  final int present;
  final int absent;
  final int late;
  final int leave;
}

/// One monthly bar.
class HrMonthCount {
  const HrMonthCount({required this.month, this.count = 0});

  final DateTime month;
  final int count;
}

/// One slice of the Request Types donut ([typeId] '' = "Others").
class HrTypeSlice {
  const HrTypeSlice({required this.typeId, required this.count});

  final String typeId;
  final int count;

  bool get isOthers => typeId.isEmpty;
}

/// The KPI strip (today).
class HrDashboardKpi {
  const HrDashboardKpi({
    this.checkedInNow = 0,
    this.lateToday = 0,
    this.absentToday = 0,
    this.onLeaveToday = 0,
    this.pendingApprovals = 0,
  });

  final int checkedInNow;
  final int lateToday;
  final int absentToday;
  final int onLeaveToday;
  final int pendingApprovals;
}

class HrDashboardStats {
  const HrDashboardStats({
    this.employeeCount = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
    this.canceled = 0,
    this.typeSlices = const <HrTypeSlice>[],
    this.attendanceByMonth = const <HrMonthAttendance>[],
    this.typeByMonth = const <HrMonthCount>[],
    this.timelineByMonth = const <HrMonthCount>[],
    this.kpi = const HrDashboardKpi(),
    this.attention = HrNeedsAttention.empty,
  });

  /// Default number of named slices in the Request Types donut (Figma: 4 +
  /// Others).
  static const int defaultTopTypes = 4;

  final int employeeCount;
  final int approved;
  final int pending;
  final int rejected;
  final int canceled;
  final List<HrTypeSlice> typeSlices;
  final List<HrMonthAttendance> attendanceByMonth;
  final List<HrMonthCount> typeByMonth;
  final List<HrMonthCount> timelineByMonth;
  final HrDashboardKpi kpi;
  final HrNeedsAttention attention;

  int get totalRequests => approved + pending + rejected + canceled;
  int get totalTypeRequests => typeSlices.fold<int>(0, (int s, HrTypeSlice t) => s + t.count);

  static String _norm(String v) => v.trim().toLowerCase();

  /// Function Name: [months]
  ///
  /// Purpose: The first day of every calendar month [span] touches.
  ///
  /// Return type: [List<DateTime>]
  static List<DateTime> months(DateSpan span) => <DateTime>[
        for (DateTime m = DateTime(span.first.year, span.first.month);
            !m.isAfter(span.last);
            m = DateTime(m.year, m.month + 1))
          m,
      ];

  /// Function Name: [compute]
  ///
  /// Purpose: Every number of the HR view (see the file header).
  ///
  /// Parameters:
  ///   [List<TimeTrackerEmployee>] employees: ALREADY scoped and filtered
  ///   (`HrDashboardScope.apply`).
  ///   [Map<String, EmployeePlacement>] placements: keyed by e-mail.
  ///   [List<AttendanceDay>] days: stored days of the range, this month and
  ///   yesterday (any employees — filtered here).
  ///   [List<TimeTrackerRequest>] requests: the company's requests.
  ///   [DateSpan] span: the chosen range.
  ///   [DateTime] now
  ///   [Set<String>] requestTypeIds: the Request Types bars' types (empty =
  ///     all; 13/10/2026 multi-select).
  ///   [int] topTypes: named slices of the Request Types donut.
  ///
  /// Return type: [HrDashboardStats]
  static HrDashboardStats compute({
    required List<TimeTrackerEmployee> employees,
    required Map<String, EmployeePlacement> placements,
    required List<AttendanceDay> days,
    required List<TimeTrackerRequest> requests,
    required DateSpan span,
    required DateTime now,
    Set<String> requestTypeIds = const <String>{},
    int topTypes = defaultTopTypes,
  }) {
    final Set<String> emails = HrDashboardScope.emailsOf(employees);
    final List<TimeTrackerRequest> scoped = <TimeTrackerRequest>[
      for (final TimeTrackerRequest r in requests)
        if (emails.contains(_norm(r.requesterEmail))) r,
    ];
    final HrDayBook book = HrDayBook.build(
      days: <AttendanceDay>[
        for (final AttendanceDay d in days)
          if (emails.contains(_norm(d.employeeEmail))) d,
      ],
      requests: scoped,
      placements: placements,
      now: now,
    );
    int approved = 0, pending = 0, rejected = 0, canceled = 0;
    final Map<String, int> byType = <String, int>{};
    final List<DateTime> monthList = months(span);
    final Map<DateTime, int> typeMonths = <DateTime, int>{for (final DateTime m in monthList) m: 0};
    final Map<DateTime, int> timeline = <DateTime, int>{for (final DateTime m in monthList) m: 0};
    for (final TimeTrackerRequest r in scoped) {
      final DateTime created = r.audit.createdAt ?? r.startAt;
      if (span.contains(created)) {
        final DateTime key = DateTime(created.year, created.month);
        timeline[key] = (timeline[key] ?? 0) + 1;
      }
      if (r.isTransaction || !span.contains(r.startAt)) continue;
      switch (r.status) {
        case RequestStatus.approved:
          approved++;
        case RequestStatus.pending:
        case RequestStatus.underReview:
          pending++;
        case RequestStatus.rejected:
          rejected++;
        case RequestStatus.canceled:
        case RequestStatus.canceledByHr:
          canceled++;
      }
      byType[r.requestTypeId] = (byType[r.requestTypeId] ?? 0) + 1;
      if (requestTypeIds.isEmpty || requestTypeIds.contains(r.requestTypeId)) {
        final DateTime key = DateTime(r.startAt.year, r.startAt.month);
        typeMonths[key] = (typeMonths[key] ?? 0) + 1;
      }
    }
    final DateTime thisMonth = DateTime(now.year, now.month);
    bool future(DateTime m) => m.isAfter(thisMonth);
    return HrDashboardStats(
      employeeCount: emails.length,
      approved: approved,
      pending: pending,
      rejected: rejected,
      canceled: canceled,
      typeSlices: _slices(byType, topTypes),
      attendanceByMonth: _trimTail(
        _attendance(book, emails, span, monthList),
        (HrMonthAttendance m) => future(m.month),
      ),
      typeByMonth: _trimTail(_bars(typeMonths, monthList), (HrMonthCount m) => future(m.month) && m.count == 0),
      timelineByMonth: _trimTail(_bars(timeline, monthList), (HrMonthCount m) => future(m.month) && m.count == 0),
      kpi: _kpi(book, emails, scoped),
      attention: HrNeedsAttention.compute(emails: emails, book: book, requests: scoped),
    );
  }

  /// [list] without its trailing entries that [drop] (empty future months —
  /// a Year range ends on Oct, not on two empty Nov / Dec bars). The first
  /// month always stays.
  static List<T> _trimTail<T>(List<T> list, bool Function(T) drop) {
    int end = list.length;
    while (end > 1 && drop(list[end - 1])) {
      end--;
    }
    return List<T>.unmodifiable(list.take(end));
  }

  static List<HrTypeSlice> _slices(Map<String, int> byType, int top) {
    final List<MapEntry<String, int>> sorted = byType.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        final int byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    if (sorted.length <= top + 1) {
      return List<HrTypeSlice>.unmodifiable(<HrTypeSlice>[
        for (final MapEntry<String, int> e in sorted) HrTypeSlice(typeId: e.key, count: e.value),
      ]);
    }
    final int others = sorted.skip(top).fold<int>(0, (int s, MapEntry<String, int> e) => s + e.value);
    return List<HrTypeSlice>.unmodifiable(<HrTypeSlice>[
      for (final MapEntry<String, int> e in sorted.take(top)) HrTypeSlice(typeId: e.key, count: e.value),
      HrTypeSlice(typeId: '', count: others),
    ]);
  }

  static List<HrMonthAttendance> _attendance(
    HrDayBook book,
    Set<String> emails,
    DateSpan span,
    List<DateTime> monthList,
  ) {
    final List<HrMonthAttendance> out = <HrMonthAttendance>[];
    for (final DateTime m in monthList) {
      final DateTime first = m.isBefore(span.first) ? span.first : m;
      final DateTime monthEnd = DateTime(m.year, m.month + 1, 0);
      final DateSpan part = DateSpan(first, monthEnd.isAfter(span.last) ? span.last : monthEnd);
      int present = 0, absent = 0, late = 0, leave = 0;
      for (final String email in emails) {
        final Map<HrDayKind, int> c = book.countIn(email, part);
        present += c[HrDayKind.present]! + c[HrDayKind.late]!;
        late += c[HrDayKind.late]!;
        absent += c[HrDayKind.absent]!;
        leave += c[HrDayKind.leave]!;
      }
      out.add(HrMonthAttendance(month: m, present: present, absent: absent, late: late, leave: leave));
    }
    return List<HrMonthAttendance>.unmodifiable(out);
  }

  static List<HrMonthCount> _bars(Map<DateTime, int> counts, List<DateTime> monthList) =>
      List<HrMonthCount>.unmodifiable(<HrMonthCount>[
        for (final DateTime m in monthList) HrMonthCount(month: m, count: counts[m] ?? 0),
      ]);

  static HrDashboardKpi _kpi(HrDayBook book, Set<String> emails, List<TimeTrackerRequest> scoped) {
    final DateTime today = book.today;
    final DateTime yesterday = DateTime(today.year, today.month, today.day - 1);
    int checkedIn = 0, late = 0, absent = 0, leave = 0;
    for (final String email in emails) {
      final AttendanceDay? now = book.record(email, today);
      final AttendanceDay? before = book.record(email, yesterday);
      if ((now != null && book.runningNow(now)) || (before != null && book.runningNow(before))) {
        checkedIn++;
      }
      switch (book.kindOf(email, today)) {
        case HrDayKind.late:
          late++;
        case HrDayKind.absent:
          absent++;
        case HrDayKind.leave:
          leave++;
        case HrDayKind.present:
        case null:
          break;
      }
    }
    final int pending = scoped
        .where((TimeTrackerRequest r) =>
            r.status == RequestStatus.pending || r.status == RequestStatus.underReview)
        .length;
    return HrDashboardKpi(
      checkedInNow: checkedIn,
      lateToday: late,
      absentToday: absent,
      onLeaveToday: leave,
      pendingApprovals: pending,
    );
  }
}
