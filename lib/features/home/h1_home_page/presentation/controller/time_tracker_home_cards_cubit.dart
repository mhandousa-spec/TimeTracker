/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_cards_cubit.dart
/// Purpose: Declares `TimeTrackerHomeCard` (the seven Time Tracker home
///          cards and the switch each needs), `TimeTrackerHomeCardsCubit` +
///          `TimeTrackerHomeCardsState` — streams the signed-in user's
///          attendance days and the company's requests for those cards.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Time Tracker phase 6 (brief §A), same approach as `TodoHomeCubit`: the
/// module's own cubits live inside `TimeTrackerModuleEntry`, which a home
/// card cannot reach, so this reads the same repositories (get_it) and keeps
/// only what the cards draw; every figure comes from the module's pure
/// `TimeTrackerHomeStatsRules` (the same list rules the Requests / Approvals
/// tabs use). Each card creates its own instance; Firestore shares one
/// listener between identical queries.
///
/// Gates (fail-closed): a card the user may not use shows the standard
/// no-access message ([TimeTrackerHomeCardsStatus.noAccess]); so does every
/// card when the module is not registered (tests, no DI).
/// Updated: 9/10/2026 - Time Tracker code review: an employee without
/// Approvals / HR dashboard rights streams ONLY their own requests (finding
/// 9); the employee's schedule is read so an untrusted absent row is not
/// counted and only whole-day leave counts as Vacations (findings 1, 8);
/// "waits for me" follows the HR rule (All Departments only, never both
/// steps of one round).
/// Updated: 9/10/2026 - QA KP-TT-013: the assignment start is passed too, so
/// Presence / Totals count absences with the HR view's day rule.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/home_widget_stats.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';

/// The seven Time Tracker home cards (Figma "Widgets" column).
enum TimeTrackerHomeCard {
  presence,
  totals,
  trackerStatus,
  myRequest,
  trackerApprover,
  quickRequests,
  quickApprovals;

  /// Function Name: [allows]
  ///
  /// Purpose: Whether the signed-in user may use this card at all.
  ///
  /// Return type: [bool]
  bool allows(TimeTrackerAccess access) {
    switch (this) {
      case TimeTrackerHomeCard.presence:
      case TimeTrackerHomeCard.totals:
        return access.canViewAttendance || access.canViewPersonalDashboard;
      case TimeTrackerHomeCard.trackerStatus:
      case TimeTrackerHomeCard.myRequest:
        return access.canViewRequests;
      case TimeTrackerHomeCard.trackerApprover:
        return access.canViewApprovals;
      case TimeTrackerHomeCard.quickRequests:
        return access.canCheckInAndOut || access.canViewRequests;
      case TimeTrackerHomeCard.quickApprovals:
        return access.canCheckInAndOut || access.canViewApprovals;
    }
  }

  /// The card draws attendance figures.
  bool get needsAttendance => this == TimeTrackerHomeCard.presence || this == TimeTrackerHomeCard.totals;

  /// The card draws request figures (Totals: "Total Requests").
  bool get needsRequests =>
      this == TimeTrackerHomeCard.totals ||
      this == TimeTrackerHomeCard.trackerStatus ||
      this == TimeTrackerHomeCard.myRequest ||
      this == TimeTrackerHomeCard.trackerApprover;
}

enum TimeTrackerHomeCardsStatus { loading, loaded, failure, noAccess }

class TimeTrackerHomeCardsState {
  const TimeTrackerHomeCardsState({
    this.status = TimeTrackerHomeCardsStatus.loading,
    this.stats = TimeTrackerHomeStats.empty,
  });

  final TimeTrackerHomeCardsStatus status;
  final TimeTrackerHomeStats stats;

  bool get isReady => status == TimeTrackerHomeCardsStatus.loaded;

  TimeTrackerHomeCardsState copyWith({
    TimeTrackerHomeCardsStatus? status,
    TimeTrackerHomeStats? stats,
  }) =>
      TimeTrackerHomeCardsState(status: status ?? this.status, stats: stats ?? this.stats);
}

class TimeTrackerHomeCardsCubit extends Cubit<TimeTrackerHomeCardsState> {
  TimeTrackerHomeCardsCubit({
    TimeTrackerAccess? access,
    AttendanceBaseRepository? attendance,
    RequestBaseRepository? requests,
    WorkSetupSourceResolver? resolver,
    DateTime Function()? clock,
  })  : _access = access ?? _find<TimeTrackerAccess>(),
        _attendance = attendance ?? _find<AttendanceBaseRepository>(),
        _requests = requests ?? _find<RequestBaseRepository>(),
        _resolver = resolver ?? _find<WorkSetupSourceResolver>(),
        _clock = clock ?? DateTime.now,
        super(const TimeTrackerHomeCardsState());

  final TimeTrackerAccess? _access;
  final AttendanceBaseRepository? _attendance;
  final RequestBaseRepository? _requests;
  final WorkSetupSourceResolver? _resolver;
  final DateTime Function() _clock;

  /// The employee's schedule (9/10/2026 — which absent rows to trust).
  WorkSchedule? _schedule;

  /// QA KP-TT-013 (9/10/2026): first day of the assignment — absences are
  /// counted from it, like the HR view.
  DateTime? _assignmentStart;

  StreamSubscription<List<AttendanceDay>>? _daysSub;
  StreamSubscription<List<TimeTrackerRequest>>? _requestsSub;
  List<AttendanceDay> _days = const <AttendanceDay>[];
  List<TimeTrackerRequest> _all = const <TimeTrackerRequest>[];
  bool _daysLoaded = false;
  bool _requestsLoaded = false;
  bool _started = false;

  static T? _find<T extends Object>() =>
      GetIt.instance.isRegistered<T>() ? GetIt.instance<T>() : null;

  /// Guard for flutter_bloc 9, which throws on emit after close.
  @override
  void emit(TimeTrackerHomeCardsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Gate [card], then stream what it draws. Idempotent.
  ///
  /// Parameters:
  ///   [TimeTrackerHomeCard] card
  ///
  /// Return type: [void]
  void init(TimeTrackerHomeCard card) {
    if (_started) return;
    _started = true;
    final TimeTrackerAccess? access = _access;
    final AttendanceBaseRepository? attendance = _attendance;
    final RequestBaseRepository? requests = _requests;
    if (access == null || attendance == null || requests == null) {
      emit(state.copyWith(status: TimeTrackerHomeCardsStatus.noAccess));
      return;
    }
    final String email = access.currentUserEmail;
    if (email.isEmpty || !access.canView || !card.allows(access)) {
      emit(state.copyWith(status: TimeTrackerHomeCardsStatus.noAccess));
      return;
    }
    _daysLoaded = !card.needsAttendance;
    _requestsLoaded = !card.needsRequests;
    if (card.needsAttendance) {
      _daysSub = attendance.watchEmployeeAttendance(employeeEmail: email).listen(
        (List<AttendanceDay> days) {
          _days = days;
          _daysLoaded = true;
          _recompute();
        },
        onError: _onError,
      );
    }
    if (card.needsRequests) {
      // Code review finding 9 (9/10/2026): company-wide only for approvers /
      // HR dashboard holders.
      final Stream<List<TimeTrackerRequest>> feed = access.readsCompanyRequests
          ? requests.watchRequests()
          : requests.watchRequestsOf(email: email);
      _requestsSub = feed.listen(
        (List<TimeTrackerRequest> list) {
          _all = list;
          _requestsLoaded = true;
          _recompute();
        },
        onError: _onError,
      );
    }
    if (card.needsAttendance) unawaited(_loadSchedule(access));
    _recompute();
  }

  /// Code review finding 1 (9/10/2026): the schedule tells which stored
  /// absent rows to trust. Unknown → every row counts (old behaviour).
  Future<void> _loadSchedule(TimeTrackerAccess access) async {
    final WorkSetupSourceResolver? resolver = _resolver;
    if (resolver == null) return;
    try {
      final TimeTrackerIdentity me = access.identity;
      final EmployeeWorkSetup? setup = await (await resolver.resolve())
          .loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId);
      _schedule = setup?.schedule;
      _assignmentStart = setup?.startDate;
      _recompute();
    } catch (error) {
      // The cards still work; they just count every stored absent row.
      _scheduleError = error;
    }
  }

  /// Why the schedule could not be read (kept, not swallowed).
  Object? _scheduleError;
  Object? get scheduleError => _scheduleError;

  void _onError(Object error) => emit(state.copyWith(status: TimeTrackerHomeCardsStatus.failure));

  void _recompute() {
    final TimeTrackerAccess? access = _access;
    if (access == null || !_daysLoaded || !_requestsLoaded) return;
    emit(TimeTrackerHomeCardsState(
      status: TimeTrackerHomeCardsStatus.loaded,
      stats: TimeTrackerHomeStatsRules.compute(
        days: _days,
        requests: _all,
        email: access.currentUserEmail,
        now: _clock(),
        approver: access.canViewApprovals ? access.approverView : null,
        waitsForMe: access.canApproveAndReject ? mayDecide : null,
        schedule: _schedule,
        assignmentStart: _assignmentStart,
      ),
    ));
  }

  /// Function Name: [mayDecide]
  ///
  /// Purpose: The current step of [request] waits for the signed-in user
  /// (same test as `ApprovalService.mayDecide`).
  ///
  /// Return type: [bool]
  bool mayDecide(TimeTrackerRequest request) {
    final TimeTrackerAccess? access = _access;
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    return access != null &&
        step != null &&
        access.mayActOnStep(
          step,
          requesterEmail: request.requesterEmail,
          requesterDepartmentId: request.requesterDepartmentId,
          steps: request.approvalSteps,
        );
  }

  @override
  Future<void> close() async {
    await _daysSub?.cancel();
    await _requestsSub?.cancel();
    return super.close();
  }
}
