/// Module: time_tracker / tt12_hr_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_cubit.dart
/// Purpose: Declares `HrDashboardCubit` — loads what the HR view of the
///          Overview tab needs (employees, departments, locations,
///          placements, the company's requests and request types, the
///          attendance of the range), keeps its filters / range / chart
///          choices and the My Dashboard | HR toggle, and recomputes
///          `HrDashboardStats` whenever an input changes.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Gated by `HR_Dashboard` (nothing is read without it). Scope (FINAL SPEC
/// §1): every department with `HR_Dashboard_All_Departments`, else only the
/// viewer's own. Reads stay bounded: attendance is read for the PERMITTED
/// employees only, for (a) the chosen range up to today and (b) this month
/// + yesterday (the KPI strip and Needs attention), each cached per range
/// for [cacheFor] — changing a filter never reads again, changing the range
/// reads only an uncached range. Requests / request types stream (the same
/// company-wide feed as the Requests tab — history fields cannot be queried
/// on their current value, FINAL SPEC §2). Names / locations / placements
/// that fail to load degrade to empty instead of failing the view.
///
/// Async work in [init]; streams cancelled in [close]; emit-after-close
/// guarded (playbook §3).
/// Updated: 9/10/2026 - code review: no stream is opened after [close] ran
/// during [init]'s awaits; non-fatal read failures are kept in
/// `errorMessage` (they were swallowed). The company-wide request feed stays
/// (HR dashboard holders may read it — finding 9).

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/hr_dashboard_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_scope.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/hr_dashboard_stats.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_state.dart';

class HrDashboardCubit extends Cubit<HrDashboardState> {
  HrDashboardCubit({
    required HrDashboardBaseRepository dashboard,
    required RequestBaseRepository requests,
    required RequestTypeBaseRepository types,
    required EmployeeDirectoryBaseRepository directory,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    DateTime Function() clock = DateTime.now,
    this.cacheFor = const Duration(minutes: 2),
  })  : _dashboard = dashboard,
        _requests = requests,
        _types = types,
        _directory = directory,
        _resolver = resolver,
        _access = access,
        _clock = clock,
        super(HrDashboardState());

  final HrDashboardBaseRepository _dashboard;
  final RequestBaseRepository _requests;
  final RequestTypeBaseRepository _types;
  final EmployeeDirectoryBaseRepository _directory;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final DateTime Function() _clock;

  /// How long a read range stays fresh.
  final Duration cacheFor;

  /// Range key → (read at, days).
  final Map<String, (DateTime, List<AttendanceDay>)> _cache = <String, (DateTime, List<AttendanceDay>)>{};
  StreamSubscription<List<TimeTrackerRequest>>? _requestSub;
  StreamSubscription<List<RequestType>>? _typeSub;
  bool _requestsLoaded = false;
  bool _attendanceLoaded = false;

  /// Number of attendance range reads made (diagnostics / tests).
  int attendanceReads = 0;

  @override
  void emit(HrDashboardState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Load names, locations and placements, start the request
  /// streams, then read the attendance of the range.
  ///
  /// Return type: [Future<void>]
  Future<void> init({bool isArabic = false}) async {
    if (!_access.canViewHrDashboard) return;
    emit(state.copyWith(
      status: HrDashboardStatus.loading,
      allDepartments: _access.hrDashboardAllDepartments,
      canFilterByEmployee: _access.canFilterHrDashboardByEmployee,
      ownDepartmentId: _access.identity.departmentId,
      now: _clock(),
      errorMessage: '',
    ));
    List<TimeTrackerEmployee> people = const <TimeTrackerEmployee>[];
    Map<String, String> departments = const <String, String>{};
    try {
      people = await _directory.fetchEmployees(isArabic: isArabic);
      departments = await _directory.fetchDepartments(isArabic: isArabic);
    } catch (error) {
      // Names only — e-mails still identify people; the reason is kept.
      emit(state.copyWith(errorMessage: error.toString()));
    }
    List<WorkLocation> locations = const <WorkLocation>[];
    try {
      locations = await (await _resolver.resolve()).loadLocations();
    } catch (error) {
      // The Location filter stays empty; nothing else depends on it.
      emit(state.copyWith(errorMessage: error.toString()));
    }
    emit(state.copyWith(employees: people, departments: departments, locations: locations));
    Map<String, EmployeePlacement> placements = const <String, EmployeePlacement>{};
    try {
      placements = await _dashboard.fetchPlacements(employees: state.permitted);
    } catch (error) {
      // No schedules → no unstored absences / Location filter matches.
      emit(state.copyWith(errorMessage: error.toString()));
    }
    _set(state.copyWith(placements: placements));
    await _requestSub?.cancel();
    await _typeSub?.cancel();
    // 9/10/2026 (code review): closed during the awaits → open nothing.
    if (isClosed) return;
    _requestsLoaded = false;
    _typeSub = _types.watchRequestTypes().listen(
      (List<RequestType> list) => emit(state.copyWith(types: list)),
      // Type names only — keep why.
      onError: (Object error) => emit(state.copyWith(errorMessage: error.toString())),
    );
    _requestSub = _requests.watchRequests().listen(
      (List<TimeTrackerRequest> list) {
        _requestsLoaded = true;
        _set(state.copyWith(requests: list, now: _clock()));
      },
      onError: _fail,
    );
    await loadAttendance();
  }

  /// Function Name: [loadAttendance]
  ///
  /// Purpose: Read (or take from the cache) the attendance of the range up
  /// to today and of this month + yesterday. [force] ignores the cache.
  ///
  /// Return type: [Future<void>]
  Future<void> loadAttendance({bool force = false}) async {
    if (!_access.canViewHrDashboard) return;
    final DateTime now = _clock();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateSpan span = DateSpan.of(state.range, now, custom: state.customSpan);
    final DateTime monthStart = DateTime(now.year, now.month);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    final List<DateSpan> wanted = <DateSpan>[
      if (!span.first.isAfter(today)) DateSpan(span.first, span.last.isAfter(today) ? today : span.last),
      DateSpan(yesterday.isBefore(monthStart) ? yesterday : monthStart, today),
    ];
    emit(state.copyWith(attendanceLoading: true, now: now));
    try {
      final Set<String> emails = HrDashboardScope.emailsOf(state.permitted);
      final Map<String, AttendanceDay> byId = <String, AttendanceDay>{};
      for (final DateSpan s in wanted) {
        for (final AttendanceDay d in await _read(s, emails, now, force: force)) {
          byId[d.id] = d;
        }
      }
      _attendanceLoaded = true;
      _set(state.copyWith(
        // A successful read clears an earlier failure.
        status: HrDashboardStatus.loading,
        days: List<AttendanceDay>.unmodifiable(byId.values),
        attendanceLoading: false,
        now: now,
      ));
    } catch (error) {
      emit(state.copyWith(attendanceLoading: false));
      _fail(error);
    }
  }

  Future<List<AttendanceDay>> _read(DateSpan s, Set<String> emails, DateTime now, {required bool force}) async {
    final String key = '${TimeTrackerFirestorePaths.dateKey(s.first)}_${TimeTrackerFirestorePaths.dateKey(s.last)}';
    final (DateTime, List<AttendanceDay>)? hit = _cache[key];
    if (!force && hit != null && now.difference(hit.$1) < cacheFor) return hit.$2;
    attendanceReads++;
    final List<AttendanceDay> days = await _dashboard.fetchAttendance(employeeEmails: emails, span: s);
    _cache[key] = (now, days);
    return days;
  }

  /// Function Name: [refreshIfStale]
  ///
  /// Purpose: Re-read ranges older than [cacheFor] (the tab was reopened).
  ///
  /// Return type: [Future<void>]
  Future<void> refreshIfStale() async {
    if (state.status != HrDashboardStatus.loaded) return;
    await loadAttendance();
  }

  /// Function Name: [selectRange] / [applyCustom]
  ///
  /// Purpose: The "Time" menu (Day / Week / Month / Year, or the Custom
  /// Date Selector's span — reversed ends are swapped).
  ///
  /// Return type: [Future<void>]
  Future<void> selectRange(DashboardRange range) async {
    if (range == DashboardRange.custom || range == state.range) return;
    _set(state.copyWith(range: range, now: _clock()));
    await loadAttendance();
  }

  Future<void> applyCustom(DateTime first, DateTime last) async {
    final bool reversed = last.isBefore(first);
    _set(state.copyWith(
      range: DashboardRange.custom,
      customSpan: DateSpan(reversed ? last : first, reversed ? first : last),
      now: _clock(),
    ));
    await loadAttendance();
  }

  /// Function Name: [setDepartment] / [setLocation] / [setEmployees] /
  /// [setSeries] / [setRequestType] / [setShowHr]
  ///
  /// Purpose: The filters ('' = all), the picked employees (empty = all),
  /// the Attendance History status, the Request Types bars' type, and the
  /// Overview toggle. None of them reads Firestore.
  ///
  /// Return type: [void]
  void setDepartment(String departmentId) =>
      _set(state.copyWith(filters: state.filters.copyWith(departmentId: departmentId)));

  void setLocation(String locationId) =>
      _set(state.copyWith(filters: state.filters.copyWith(locationId: locationId)));

  void setEmployees(Set<String> emails) => _set(state.copyWith(
        filters: state.filters.copyWith(
          employeeEmails: Set<String>.unmodifiable(<String>{for (final String e in emails) e.trim().toLowerCase()}),
        ),
      ));

  void setSeries(HrAttendanceSeries series) => emit(state.copyWith(series: series));

  void setRequestType(String typeId) => _set(state.copyWith(requestTypeId: typeId));

  void setShowHr(bool showHr) => emit(state.copyWith(showHr: showHr));

  /// Recompute the stats for [next] and publish it.
  void _set(HrDashboardState next) {
    final bool ready = _requestsLoaded && _attendanceLoaded;
    final HrDashboardState withStatus = next.copyWith(
      status: next.status == HrDashboardStatus.failure
          ? HrDashboardStatus.failure
          : (ready ? HrDashboardStatus.loaded : HrDashboardStatus.loading),
    );
    emit(withStatus.copyWith(
      stats: HrDashboardStats.compute(
        employees: withStatus.scoped,
        placements: withStatus.placements,
        days: withStatus.days,
        requests: withStatus.requests,
        span: withStatus.span,
        now: withStatus.now,
        requestTypeId: withStatus.requestTypeId,
      ),
    ));
  }

  void _fail(Object error) =>
      emit(state.copyWith(status: HrDashboardStatus.failure, errorMessage: error.toString()));

  @override
  Future<void> close() async {
    await _requestSub?.cancel();
    await _typeSub?.cancel();
    return super.close();
  }
}
