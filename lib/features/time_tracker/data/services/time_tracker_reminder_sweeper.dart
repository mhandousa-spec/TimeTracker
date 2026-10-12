/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_reminder_sweeper.dart
/// Purpose: Declares `TimeTrackerReminderSweeper` — the client-side sweep
///          that raises the three time-driven Time Tracker notifications
///          (missed check-in, forgot to check out, pending approvals) — and
///          `TimeTrackerSweepReport`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// ─── WHY ON THE CLIENT ───────────────────────────────────────────────────
/// The app has no server-side scheduler, so — like `TodoReminderSweeper` and
/// the absent-day sweep (decision 20) — the sweep runs on the signed-in
/// user's device, for that user only: when the Time Tracker module opens and
/// when a Time Tracker home card is shown, at most once every 15 minutes
/// ([sweepIfDue]). A reminder is therefore raised the first time the user
/// opens the app on or after its due time, not at the exact minute. A Cloud
/// Function is the real fix and would replace this file.
///
/// ─── RULES ───────────────────────────────────────────────────────────────
/// `TimeTrackerReminderRules` (pure): missed check-in (needs
/// `Check_In_And_Out` and a work set-up), forgot to check out (30 min after
/// the shift end), pending approvals > 2 days (needs View Approvals +
/// Approve And Reject; once a day, with the count and the oldest request).
///
/// ─── SEND ONCE ───────────────────────────────────────────────────────────
/// Each reminder first claims its marker in `Notification_Log`
/// (`TimeTrackerNotificationLogRepository`); only the claim that created it
/// sends. Every send goes through `TimeTrackerNotificationService.send` →
/// `AppNotificationSender.sendEvent`, so the admin template and the
/// Notification Control on/off switch apply (a disabled event is claimed but
/// not stored — it stays silenced for that due time). The sender is the
/// system address (owner rule 7/10/2026: module reminders are SYSTEM
/// notifications).
///
/// Never throws: failures are counted in the report.
/// Updated: 9/10/2026 - code review: the missed check-in reminder reads only
/// the employee's own requests (finding 9) and only whole-day leave excuses
/// it (finding 8); none on an HR shift's unknown week (finding 1 — in the
/// rules); the overdue-approvals list (approvers only) keeps the company
/// feed; "waits for me" follows the same-person rule of both steps.
/// Updated: 9/10/2026 - QA KP-TT-011: the pending-approvals reminder sends
/// `{{countedRequests}}` in both languages ("1 request" / "طلب واحد").

import 'dart:async';

import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_notification_log_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/absent_day_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/reminder_sweep_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';

/// What one sweep did (returned for callers and tests).
class TimeTrackerSweepReport {
  const TimeTrackerSweepReport({
    this.due = 0,
    this.sent = 0,
    this.alreadySent = 0,
    this.failed = 0,
    this.skipped = false,
  });

  final int due;
  final int sent;
  final int alreadySent;
  final int failed;

  /// Not run: signed out, already running, or ran less than 15 min ago.
  final bool skipped;

  static const TimeTrackerSweepReport notRun = TimeTrackerSweepReport(skipped: true);

  @override
  String toString() => 'TimeTrackerSweepReport(due: $due, sent: $sent, '
      'alreadySent: $alreadySent, failed: $failed, skipped: $skipped)';
}

class TimeTrackerReminderSweeper {
  TimeTrackerReminderSweeper({
    required AttendanceBaseRepository attendance,
    required RequestBaseRepository requests,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    required TimeTrackerNotificationLogRepository log,
    required TimeTrackerNotificationService notifier,
    DateTime Function() clock = DateTime.now,
  })  : _attendance = attendance,
        _requests = requests,
        _resolver = resolver,
        _access = access,
        _log = log,
        _notifier = notifier,
        _clock = clock;

  final AttendanceBaseRepository _attendance;
  final RequestBaseRepository _requests;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final TimeTrackerNotificationLogRepository _log;
  final TimeTrackerNotificationService _notifier;
  final DateTime Function() _clock;

  /// Same sender the To-Do reminders use (system notifications).
  static const String systemSender = 'system@company.com';

  /// Throttle of [sweepIfDue].
  static const Duration minInterval = Duration(minutes: 15);

  bool _running = false;
  DateTime? _lastRunAt;
  String _lastRunFor = '';

  /// Function Name: [runFromUi]
  ///
  /// Purpose: Fire-and-forget [sweepIfDue] of the registered sweeper — called
  /// when the module opens and when a Time Tracker home card is shown. A
  /// no-op when the module's dependencies are not registered (tests).
  ///
  /// Parameters:
  ///   [bool] isArabic: the user's language when the sweep runs.
  ///
  /// Return type: [void]
  static void runFromUi({required bool isArabic}) {
    final GetIt sl = GetIt.instance;
    if (!sl.isRegistered<TimeTrackerReminderSweeper>()) return;
    unawaited(sl<TimeTrackerReminderSweeper>().sweepIfDue(isArabic: isArabic));
  }

  /// Function Name: [sweepIfDue]
  ///
  /// Purpose: Run [sweep] unless it is running or ran for this user less
  /// than [minInterval] ago (module open / home card shown).
  ///
  /// Return type: [Future<TimeTrackerSweepReport>]
  Future<TimeTrackerSweepReport> sweepIfDue({required bool isArabic}) {
    final String me = _access.currentUserEmail;
    final DateTime? last = _lastRunAt;
    if (me.isEmpty || _running) return Future<TimeTrackerSweepReport>.value(TimeTrackerSweepReport.notRun);
    if (last != null && _lastRunFor == me && _clock().difference(last) < minInterval) {
      return Future<TimeTrackerSweepReport>.value(TimeTrackerSweepReport.notRun);
    }
    return sweep(isArabic: isArabic);
  }

  /// Function Name: [sweep]
  ///
  /// Purpose: Work out the due reminders, claim each, send the claimed ones.
  ///
  /// Return type: [Future<TimeTrackerSweepReport>] — never throws.
  Future<TimeTrackerSweepReport> sweep({required bool isArabic}) {
    final String me = _access.currentUserEmail;
    if (me.isEmpty || _running) return Future<TimeTrackerSweepReport>.value(TimeTrackerSweepReport.notRun);
    _running = true;
    // No try here (house rule: try/catch in repositories and cubits): a
    // failed read resolves to null below, the claim and the send never throw.
    return _run(me, isArabic).whenComplete(() => _running = false);
  }

  Future<TimeTrackerSweepReport> _run(String me, bool isArabic) async {
    final List<TimeTrackerDueReminder>? due = await dueReminders().then<List<TimeTrackerDueReminder>?>(
      (List<TimeTrackerDueReminder> list) => list,
      // A read failed (offline, no company): nothing sent, retried next time.
      onError: (Object _) => null,
    );
    if (due == null) return const TimeTrackerSweepReport(failed: 1);
    int sent = 0, already = 0, failed = 0;
    for (final TimeTrackerDueReminder r in due) {
      final TimeTrackerNotificationEvent event = eventOf(r.kind);
      final TimeTrackerClaimResult claim = await _log.claim(
        TimeTrackerNotificationMarker(
          refId: r.refId,
          eventKey: event.key,
          dueAt: r.dueAt,
          receiverEmail: me,
        ),
      );
      switch (claim) {
        case TimeTrackerClaimResult.alreadySent:
          already++;
        case TimeTrackerClaimResult.failed:
          failed++;
        case TimeTrackerClaimResult.claimed:
          if (await _send(r, me, isArabic)) {
            sent++;
          } else {
            failed++;
          }
      }
    }
    _lastRunAt = _clock();
    _lastRunFor = me;
    return TimeTrackerSweepReport(due: due.length, sent: sent, alreadySent: already, failed: failed);
  }

  /// Function Name: [dueReminders]
  ///
  /// Purpose: The reminders due now for the signed-in user (no I/O besides
  /// the reads). Throws when a read fails ([sweep] catches).
  ///
  /// Return type: [Future<List<TimeTrackerDueReminder>>]
  Future<List<TimeTrackerDueReminder>> dueReminders() async {
    final TimeTrackerIdentity me = _access.identity;
    final DateTime now = _clock();
    final List<TimeTrackerDueReminder> out = <TimeTrackerDueReminder>[];
    // 9/10/2026 (code review finding 9): the employee's OWN requests for
    // their leave; the company's only for an approver's overdue list.
    List<TimeTrackerRequest>? mine;
    Future<List<TimeTrackerRequest>> myRequests() async =>
        mine ??= await _requests.watchRequestsOf(email: me.email).first;

    if (_access.canCheckInAndOut) {
      final WorkSetupSource source = await _resolver.resolve();
      final EmployeeWorkSetup? setup =
          await source.loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId);
      if (setup != null) {
        final DateTime today = DateTime(now.year, now.month, now.day);
        final AttendanceDay? todayDay = await _attendance.fetchDay(employeeEmail: me.email, date: today);
        AttendanceDay? open = (todayDay?.isCheckedIn ?? false) ? todayDay : null;
        if (open == null) {
          final AttendanceDay? yesterday = await _attendance.fetchDay(
            employeeEmail: me.email,
            date: DateTime(now.year, now.month, now.day - 1),
          );
          if (yesterday?.isCheckedIn ?? false) open = yesterday;
        }
        final TimeTrackerDueReminder? checkOut = TimeTrackerReminderRules.missedCheckOut(
          email: me.email,
          schedule: setup.schedule,
          openDay: open,
          now: now,
        );
        if (checkOut != null) out.add(checkOut);
        if (open == null) {
          final TimeTrackerDueReminder? checkIn = TimeTrackerReminderRules.missedCheckIn(
            email: me.email,
            schedule: setup.schedule,
            assignmentStart: setup.startDate,
            today: todayDay,
            approvedLeaves: AbsentDaySweeper.approvedLeaveRanges(
              await myRequests(),
              me.email,
              schedule: setup.schedule,
            ),
            now: now,
          );
          if (checkIn != null) out.add(checkIn);
        }
      }
    }

    if (_access.canViewApprovals && _access.canApproveAndReject) {
      final TimeTrackerDueReminder? approvals = TimeTrackerReminderRules.overdueApprovals(
        approverEmail: me.email,
        requests: await _requests.watchRequests().first,
        waitsForMe: mayDecide,
        now: now,
      );
      if (approvals != null) out.add(approvals);
    }
    return out;
  }

  /// Function Name: [mayDecide]
  ///
  /// Purpose: The current step of [request] waits for the signed-in user
  /// (same test as `ApprovalService.mayDecide`).
  ///
  /// Return type: [bool]
  bool mayDecide(TimeTrackerRequest request) {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    return step != null &&
        _access.mayActOnStep(
          step,
          requesterEmail: request.requesterEmail,
          requesterDepartmentId: request.requesterDepartmentId,
          steps: request.approvalSteps,
        );
  }

  /// Function Name: [eventOf]
  ///
  /// Purpose: The catalogue event of each reminder.
  ///
  /// Return type: [TimeTrackerNotificationEvent]
  static TimeTrackerNotificationEvent eventOf(TimeTrackerReminderKind kind) {
    switch (kind) {
      case TimeTrackerReminderKind.missedCheckIn:
        return TimeTrackerNotificationEvent.missedCheckIn;
      case TimeTrackerReminderKind.missedCheckOut:
        return TimeTrackerNotificationEvent.missedCheckOut;
      case TimeTrackerReminderKind.pendingApprovals:
        return TimeTrackerNotificationEvent.pendingApprovalsManager;
    }
  }

  Future<bool> _send(TimeTrackerDueReminder r, String me, bool isArabic) {
    final bool approvals = r.kind == TimeTrackerReminderKind.pendingApprovals;
    return _notifier.send(
      event: eventOf(r.kind),
      page: approvals ? TimeTrackerNotificationPage.approvalDetails : TimeTrackerNotificationPage.mainPage,
      senderEmail: systemSender,
      receiverEmail: me,
      isArabic: isArabic,
      // QA KP-TT-011 (9/10/2026): "1 request" / "طلب واحد" in both languages.
      variables: approvals
          ? TimeTrackerNotificationService.pendingCountVariables(r.count)
          : const <TemplateVariable, String>{},
      variablesAr: approvals
          ? TimeTrackerNotificationService.pendingCountVariables(r.count, arabic: true)
          : const <TemplateVariable, String>{},
      requestId: r.requestId,
    );
  }
}
