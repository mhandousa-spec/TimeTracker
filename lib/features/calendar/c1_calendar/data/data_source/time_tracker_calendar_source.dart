/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_calendar_source.dart
/// Purpose: Declares `TimeTrackerCalendarSource` — the Time Tracker calendar
///          loader ([load], through the module's own repositories) and the
///          pure card builder ([entries]) behind
///          `CalendarDataService.getTimeTrackerCalendarEvents` /
///          `timeTrackerCalendarEntries`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 6 (brief §B). Kept out of the 4,600-line `calendar_data_service.dart`
/// so the shared file only gains two delegating methods.
///
/// What appears (all from `TimeTrackerCalendarEvent`, colour 0xFFFF814A):
///   * MY approved leave — every covered day (approved, or approved and
///     under a cancellation review) — "Approved Leave" (Scheduled);
///   * MY pending leave request — every covered day — "Request Pending
///     Approval" (Pending Approval);
///   * MY transactions — on the corrected day: pending / approved;
///   * MY late and absent days — from Attendance;
///   * for an approver: every requested day of each request whose CURRENT
///     step waits for them — "Awaiting Your Approval" (Pending Approval).
/// Gates: my requests / transactions need View Requests or View Attendance;
/// late / absent need View Attendance; approvals need View Approvals +
/// Approve And Reject. Days limited to 60 back / 180 ahead (like To-Do).
/// `requestId` = the request id (tap opens it — the approver's details for
/// an approval card); late / absent cards carry none and open the
/// Attendance tab on that day (`CalendarEventTap`).
/// Updated: 9/10/2026 - Time Tracker code review: an employee without
/// Approvals / HR dashboard rights reads ONLY their own requests (finding
/// 9); an absent day the app cannot trust (an old sweep row on a
/// non-working day / an HR shift's unknown week — `AbsenceRules`) is not
/// shown (finding 1); "Awaiting Your Approval" follows the HR rule (All
/// Departments only, never both steps of one round).

import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/absence_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';

class TimeTrackerCalendarSource {
  const TimeTrackerCalendarSource({GetIt? locator}) : _locator = locator;

  final GetIt? _locator;

  static const Duration _timeout = Duration(seconds: 15);

  /// Days shown before / after today (same window as To-Do).
  static const int daysBack = 60;
  static const int daysAhead = 180;

  /// Function Name: [load]
  ///
  /// Purpose: The signed-in user's Time Tracker cards, read through the
  /// module's repositories (history documents decoded the same way the
  /// module does). Empty when the module is not registered, no company is
  /// signed in, or the user sees nothing of it. A failed read throws —
  /// `CalendarCubit._collect` records the source as failed.
  ///
  /// Parameters:
  ///   [String] currentUserEmail
  ///   [bool] isArabic
  ///
  /// Return type: [Future<List<CalendarEventModel>>]
  Future<List<CalendarEventModel>> load({
    required String currentUserEmail,
    required bool isArabic,
  }) async {
    final GetIt sl = _locator ?? GetIt.instance;
    final String email = currentUserEmail.trim().toLowerCase();
    if (email.isEmpty || ApiConstants.baseUri.trim().isEmpty) return <CalendarEventModel>[];
    if (!sl.isRegistered<TimeTrackerAccess>() || !sl.isRegistered<RequestBaseRepository>()) {
      return <CalendarEventModel>[];
    }
    final TimeTrackerAccess access = sl<TimeTrackerAccess>();
    final bool showMine = access.canViewRequests || access.canViewAttendance;
    final bool showAttendance = access.canViewAttendance;
    final bool showApprovals = access.canViewApprovals && access.canApproveAndReject;
    if (!showMine && !showAttendance && !showApprovals) return <CalendarEventModel>[];

    // Finding 9: the company's requests only for approvers / HR dashboard.
    final RequestBaseRepository repo = sl<RequestBaseRepository>();
    final List<TimeTrackerRequest> requests = (showMine || showApprovals)
        ? await (access.readsCompanyRequests ? repo.watchRequests() : repo.watchRequestsOf(email: email))
            .first
            .timeout(_timeout)
        : const <TimeTrackerRequest>[];
    final List<AttendanceDay> stored = showAttendance
        ? await sl<AttendanceBaseRepository>().watchEmployeeAttendance(employeeEmail: email).first.timeout(_timeout)
        : const <AttendanceDay>[];
    // Finding 1: hide absent rows the schedule cannot back.
    final List<AttendanceDay> days = stored.isEmpty || !sl.isRegistered<WorkSetupSourceResolver>()
        ? stored
        : AbsenceRules.trusted(stored, await _scheduleOf(sl<WorkSetupSourceResolver>(), access));
    final List<RequestType> types = requests.isEmpty
        ? const <RequestType>[]
        : await sl<RequestTypeBaseRepository>().watchRequestTypes().first.timeout(_timeout);
    bool waits(TimeTrackerRequest r) {
      final RequestApprovalStep? step = RequestCycleRules.actionableStep(r);
      return step != null &&
          access.mayActOnStep(
            step,
            requesterEmail: r.requesterEmail,
            requesterDepartmentId: r.requesterDepartmentId,
            steps: r.approvalSteps,
          );
    }

    final List<TimeTrackerRequest> waiting =
        showApprovals ? requests.where(waits).toList() : const <TimeTrackerRequest>[];
    final List<TimeTrackerEmployee> people = waiting.isEmpty || !sl.isRegistered<EmployeeDirectoryBaseRepository>()
        ? const <TimeTrackerEmployee>[]
        : await sl<EmployeeDirectoryBaseRepository>().fetchEmployees(isArabic: isArabic).timeout(_timeout);

    return entries(
      requests: requests,
      days: days,
      userEmail: email,
      now: DateTime.now(),
      isArabic: isArabic,
      showRequests: showMine,
      showAttendance: showAttendance,
      waitsForMe: showApprovals ? waits : null,
      typeNameOf: (TimeTrackerRequest r) => typeName(r, types, isArabic: isArabic),
      personNameOf: (String who) => personName(who, people, isArabic: isArabic),
    );
  }

  /// The signed-in employee's schedule (null = not assigned).
  static Future<WorkSchedule?> _scheduleOf(WorkSetupSourceResolver resolver, TimeTrackerAccess access) async {
    final TimeTrackerIdentity me = access.identity;
    final EmployeeWorkSetup? setup = await (await resolver.resolve())
        .loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId)
        .timeout(_timeout);
    return setup?.schedule;
  }

  /// Function Name: [entries]
  ///
  /// Purpose: The pure half of [load] — every Time Tracker card for
  /// [userEmail] at [now] (see the file header). Unit-tested.
  ///
  /// Parameters:
  ///   [List<TimeTrackerRequest>] requests: the company's requests.
  ///   [List<AttendanceDay>] days: the user's attendance days.
  ///   [String] userEmail
  ///   [DateTime] now
  ///   [bool] isArabic
  ///   [bool] showRequests / showAttendance: the user's gates.
  ///   [bool Function(TimeTrackerRequest)?] waitsForMe: null = not an
  ///   approver (no approval cards).
  ///   [String Function(TimeTrackerRequest)?] typeNameOf: the card title.
  ///   [String Function(String)?] personNameOf: requester name (approvals).
  ///
  /// Return type: [List<CalendarEventModel>]
  static List<CalendarEventModel> entries({
    required List<TimeTrackerRequest> requests,
    required List<AttendanceDay> days,
    required String userEmail,
    required DateTime now,
    required bool isArabic,
    bool showRequests = true,
    bool showAttendance = true,
    bool Function(TimeTrackerRequest request)? waitsForMe,
    String Function(TimeTrackerRequest request)? typeNameOf,
    String Function(String email)? personNameOf,
  }) {
    final String me = userEmail.trim().toLowerCase();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime first = DateTime(today.year, today.month, today.day - daysBack);
    final DateTime last = DateTime(today.year, today.month, today.day + daysAhead);
    final List<CalendarEventModel> out = <CalendarEventModel>[];
    String timeOf(DateTime d) => DateFormat('hh:mm a', 'en').format(d);
    bool inWindow(DateTime d) {
      final DateTime day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(first) && !day.isAfter(last);
    }

    void add(
      TimeTrackerCalendarEvent type,
      DateTime at, {
      String? name,
      String? requestId,
      Map<TemplateVariable, String> variables = const <TemplateVariable, String>{},
    }) {
      if (!inWindow(at)) return;
      out.add(CalendarEventModel.fromType(
        type,
        sourceDate: at,
        isArabic: isArabic,
        taskName: (name ?? '').trim().isEmpty ? null : name,
        variables: variables,
        time: timeOf(at),
        requestId: requestId,
        userEmail: me,
      ));
    }

    void eachDay(TimeTrackerRequest r, void Function(DateTime at) place) {
      DateTime d = DateTime(r.startAt.year, r.startAt.month, r.startAt.day);
      final DateTime end = DateTime(r.endAt.year, r.endAt.month, r.endAt.day);
      if (d.isBefore(first)) d = first;
      for (int guard = 0; !d.isAfter(end) && !d.isAfter(last) && guard < 400; guard++) {
        // The first day keeps the requested start time (a partial day).
        final bool firstDay = d.year == r.startAt.year && d.month == r.startAt.month && d.day == r.startAt.day;
        place(firstDay ? r.startAt : d);
        d = DateTime(d.year, d.month, d.day + 1);
      }
    }

    String nameOf(TimeTrackerRequest r) => typeNameOf?.call(r) ?? '';

    for (final TimeTrackerRequest r in requests) {
      final bool mine = r.requesterEmail.trim().toLowerCase() == me;
      if (mine && r.isTransaction && (showRequests || showAttendance)) {
        if (r.status == RequestStatus.pending) {
          add(TimeTrackerCalendarEvent.transactionPending, r.startAt, name: nameOf(r), requestId: r.id);
        } else if (r.status == RequestStatus.approved) {
          add(TimeTrackerCalendarEvent.transactionApproved, r.startAt, name: nameOf(r), requestId: r.id);
        }
      } else if (mine && showRequests) {
        final TimeTrackerCalendarEvent? type = switch (r.status) {
          RequestStatus.approved || RequestStatus.underReview => TimeTrackerCalendarEvent.leaveApproved,
          RequestStatus.pending => TimeTrackerCalendarEvent.requestPending,
          _ => null,
        };
        if (type != null) {
          eachDay(r, (DateTime at) => add(type, at, name: nameOf(r), requestId: r.id));
        }
      }
      final bool Function(TimeTrackerRequest)? waits = waitsForMe;
      if (!mine && waits != null && waits(r)) {
        final String who = personNameOf?.call(r.requesterEmail) ?? '';
        final String type = nameOf(r);
        final String title = <String>[who, type].where((String s) => s.trim().isNotEmpty).join(' · ');
        eachDay(r, (DateTime at) => add(TimeTrackerCalendarEvent.approvalPending, at, name: title, requestId: r.id));
      }
    }

    if (showAttendance) {
      for (final AttendanceDay d in days) {
        final DateTime at = d.firstCheckInAt ?? d.date;
        if (d.status == AttendanceStatus.late) {
          add(TimeTrackerCalendarEvent.lateArrival, at,
              variables: <TemplateVariable, String>{TemplateVariable.minutes: '${d.lateMinutes}'});
        } else if (d.status == AttendanceStatus.absent) {
          add(TimeTrackerCalendarEvent.absentDay, d.date);
        }
      }
    }
    return out;
  }

  /// Function Name: [typeName]
  ///
  /// Purpose: The card title of [r]: its request type in the app language
  /// ('' for a transaction or an unknown type — the enum title is used).
  ///
  /// Return type: [String]
  static String typeName(TimeTrackerRequest r, List<RequestType> types, {required bool isArabic}) {
    if (r.isTransaction) return '';
    for (final RequestType t in types) {
      if (t.id == r.requestTypeId) return t.name(isArabic: isArabic);
    }
    return '';
  }

  /// Function Name: [personName]
  ///
  /// Purpose: [email]'s name from [people], else the email.
  ///
  /// Return type: [String]
  static String personName(String email, List<TimeTrackerEmployee> people, {required bool isArabic}) {
    final String key = email.trim().toLowerCase();
    for (final TimeTrackerEmployee p in people) {
      if (p.email == key) {
        final String n = p.name(isArabic: isArabic);
        return n.trim().isEmpty ? key : n;
      }
    }
    return key;
  }
}
