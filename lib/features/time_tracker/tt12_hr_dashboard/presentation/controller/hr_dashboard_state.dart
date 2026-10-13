/// Module: time_tracker / tt12_hr_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_state.dart
/// Purpose: Declares `HrDashboardState` (+ `HrDashboardStatus`,
///          `HrAttendanceSeries`) — the inputs of the Overview tab's HR view
///          (employees, placements, requests, attendance of the range), its
///          filters / range / chart choices, the My Dashboard | HR toggle, and
///          the derived `HrDashboardStats`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). [stats] is computed by the cubit whenever an input
/// changes (`HrDashboardStats.compute`), so a rebuild never recomputes it.

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_scope.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';

enum HrDashboardStatus { initial, loading, loaded, failure }

/// The Attendance History "Status" dropdown (all = the four grouped bars).
enum HrAttendanceSeries { all, present, absent, late, vacation }

class HrDashboardState {
  HrDashboardState({
    this.status = HrDashboardStatus.initial,
    this.showHr = false,
    this.allDepartments = false,
    this.canFilterByEmployee = false,
    this.ownDepartmentId = '',
    this.employees = const <TimeTrackerEmployee>[],
    this.departments = const <String, String>{},
    this.locations = const <WorkLocation>[],
    this.placements = const <String, EmployeePlacement>{},
    this.requests = const <TimeTrackerRequest>[],
    this.types = const <RequestType>[],
    this.days = const <AttendanceDay>[],
    this.range = DashboardRange.year,
    this.customSpan,
    this.filters = HrDashboardFilters.none,
    this.series = HrAttendanceSeries.all,
    this.requestTypeIds = const <String>{},
    this.attendanceLoading = false,
    this.stats = const HrDashboardStats(),
    DateTime? now,
    this.errorMessage = '',
  }) : now = now ?? DateTime.now();

  final HrDashboardStatus status;

  /// The Overview toggle: HR view (true) or My Dashboard (false — the first
  /// segment, so the tab opens on the user's own dashboard; decision to
  /// confirm). Ignored without `Personal_Dashboard` (HR view only).
  final bool showHr;

  /// `HR_Dashboard_All_Departments` (Department filter shown).
  final bool allDepartments;

  /// `HR_Dashboard_Filter_By_Employee` (Employee picker shown).
  final bool canFilterByEmployee;
  final String ownDepartmentId;

  /// Every company employee (names, picker).
  final List<TimeTrackerEmployee> employees;

  /// Department id → name.
  final Map<String, String> departments;
  final List<WorkLocation> locations;

  /// E-mail → location + schedule.
  final Map<String, EmployeePlacement> placements;

  /// The company's requests (scoped by the stats).
  final List<TimeTrackerRequest> requests;
  final List<RequestType> types;

  /// Stored days of the range + this month + yesterday.
  final List<AttendanceDay> days;
  final DashboardRange range;
  final DateSpan? customSpan;
  final HrDashboardFilters filters;
  final HrAttendanceSeries series;

  /// The Request Types bars' type ('' = all).
  final Set<String> requestTypeIds;

  /// A range change is being read.
  final bool attendanceLoading;
  final HrDashboardStats stats;
  final DateTime now;
  final String errorMessage;

  bool get isLoading => status == HrDashboardStatus.initial || status == HrDashboardStatus.loading;

  /// The days the chosen range covers.
  DateSpan get span => DateSpan.of(range, now, custom: customSpan);

  /// The employees this viewer may see.
  List<TimeTrackerEmployee> get permitted => HrDashboardScope.permitted(
        employees,
        allDepartments: allDepartments,
        ownDepartmentId: ownDepartmentId,
      );

  /// [permitted] narrowed by the filters.
  List<TimeTrackerEmployee> get scoped => HrDashboardScope.apply(
        permitted,
        filters: filters,
        placements: placements,
        allDepartments: allDepartments,
        canFilterByEmployee: canFilterByEmployee,
      );

  /// The picked employees (Employee picker), in name order.
  List<TimeTrackerEmployee> get pickedEmployees => <TimeTrackerEmployee>[
        for (final TimeTrackerEmployee e in permitted)
          if (filters.employeeEmails.contains(e.email.trim().toLowerCase())) e,
      ];

  TimeTrackerEmployee? employeeByEmail(String email) {
    final String key = email.trim().toLowerCase();
    for (final TimeTrackerEmployee e in employees) {
      if (e.email.trim().toLowerCase() == key) return e;
    }
    return null;
  }

  RequestType? typeById(String id) {
    for (final RequestType t in types) {
      if (t.id == id) return t;
    }
    return null;
  }

  WorkLocation? locationById(String id) {
    for (final WorkLocation l in locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [HrDashboardState]
  HrDashboardState copyWith({
    HrDashboardStatus? status,
    bool? showHr,
    bool? allDepartments,
    bool? canFilterByEmployee,
    String? ownDepartmentId,
    List<TimeTrackerEmployee>? employees,
    Map<String, String>? departments,
    List<WorkLocation>? locations,
    Map<String, EmployeePlacement>? placements,
    List<TimeTrackerRequest>? requests,
    List<RequestType>? types,
    List<AttendanceDay>? days,
    DashboardRange? range,
    DateSpan? customSpan,
    HrDashboardFilters? filters,
    HrAttendanceSeries? series,
    Set<String>? requestTypeIds,
    bool? attendanceLoading,
    HrDashboardStats? stats,
    DateTime? now,
    String? errorMessage,
  }) =>
      HrDashboardState(
        status: status ?? this.status,
        showHr: showHr ?? this.showHr,
        allDepartments: allDepartments ?? this.allDepartments,
        canFilterByEmployee: canFilterByEmployee ?? this.canFilterByEmployee,
        ownDepartmentId: ownDepartmentId ?? this.ownDepartmentId,
        employees: employees ?? this.employees,
        departments: departments ?? this.departments,
        locations: locations ?? this.locations,
        placements: placements ?? this.placements,
        requests: requests ?? this.requests,
        types: types ?? this.types,
        days: days ?? this.days,
        range: range ?? this.range,
        customSpan: customSpan ?? this.customSpan,
        filters: filters ?? this.filters,
        series: series ?? this.series,
        requestTypeIds: requestTypeIds ?? this.requestTypeIds,
        attendanceLoading: attendanceLoading ?? this.attendanceLoading,
        stats: stats ?? this.stats,
        now: now ?? this.now,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
