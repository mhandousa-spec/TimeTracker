/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_service.dart
/// Purpose: Declares `TransactionService` — submits a new attendance
///          transaction (resolving the direct manager) and cancels a pending
///          one, with the permission checks and System Log entries.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decisions 8, 18, 19 (8/10/2026). Permission gates:
/// `Request_Transaction` to submit, `Cancel_Transaction` to cancel (the
/// cancel UI arrives with the Requests screens in phase 3; the data method is
/// wired now). The rules themselves live in `TransactionRules`.
/// Errors propagate as clean `Exception`s (repositories) or `StateError`
/// (a refused move); the cubit turns them into messages.
/// Updated: 9/10/2026 - phase 4: a submitted transaction notifies its first
/// step's approver(s) ("Pending Approvals", brief §C) when [approvers] +
/// [notifier] are given; the Requests screens cancel through
/// `RequestService.cancelPending` (same gate and rule as [cancel]).
/// Updated: 9/10/2026 - code review: [submit] checks the owner's day rule
/// (check-out the same day, or the next day for an overnight shift; at most
/// 24 h — finding 6) against the employee's schedule ([scheduleOfMe]); a
/// direct manager who cannot act is skipped and one who is the only other
/// HR approver decides alone (finding 7 / owner); [cancel] re-reads the
/// stored transaction and saves with compare-and-set (it acted on the
/// caller's stale copy).

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';

/// Thrown when the signed-in role lacks the switch for the action.
class TimeTrackerPermissionDenied implements Exception {
  const TimeTrackerPermissionDenied();

  @override
  String toString() => 'You do not have permission to do this.';
}

class TransactionService {
  TransactionService({
    required RequestBaseRepository requests,
    required ManagerResolver managers,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    ApproverDirectory? approvers,
    TimeTrackerNotificationService? notifier,
    WorkSetupSourceResolver? resolver,
    DateTime Function() clock = DateTime.now,
  })  : _requests = requests,
        _managers = managers,
        _access = access,
        _log = log,
        _approvers = approvers,
        _notifier = notifier,
        _resolver = resolver,
        _clock = clock;

  final RequestBaseRepository _requests;
  final ManagerResolver _managers;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  final ApproverDirectory? _approvers;
  final TimeTrackerNotificationService? _notifier;
  final WorkSetupSourceResolver? _resolver;
  final DateTime Function() _clock;

  /// Function Name: [scheduleOfMe]
  ///
  /// Purpose: ADDED 9/10/2026 (finding 6) — the signed-in employee's
  /// schedule (null = not assigned / no resolver): an overnight shift may
  /// check out on the next day.
  ///
  /// Return type: [Future<WorkSchedule?>]
  Future<WorkSchedule?> scheduleOfMe() async {
    final WorkSetupSourceResolver? resolver = _resolver;
    if (resolver == null) return null;
    final TimeTrackerIdentity me = _access.identity;
    final EmployeeWorkSetup? setup = await (await resolver.resolve())
        .loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId);
    return setup?.schedule;
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Create the signed-in employee's transaction, routed to their
  /// direct manager (when known) then HR.
  ///
  /// Parameters:
  ///   [DateTime] checkIn / [DateTime] checkOut
  ///   [String] description
  ///   [List<RequestAttachment>] attachments
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> submit({
    required DateTime checkIn,
    required DateTime checkOut,
    required String description,
    List<RequestAttachment> attachments = const <RequestAttachment>[],
  }) async {
    if (!_access.canRequestTransaction) throw const TimeTrackerPermissionDenied();
    final TimeTrackerIdentity me = _access.identity;
    final WorkSchedule? schedule = await scheduleOfMe();
    String manager = await _managers.managerEmailOf(
      employeeEmail: me.email,
      employeeId: me.employeeId,
    );
    final ApproverDirectory? directory = _approvers;
    // Finding 7 (9/10/2026): a manager who cannot act → straight to HR.
    if (manager.isNotEmpty && directory != null && !await directory.mayApprove(manager)) manager = '';
    final bool managerIsSoleOtherHr = manager.isNotEmpty &&
        directory != null &&
        await directory.isSoleOtherHrApprover(email: manager, requesterEmail: me.email);
    final TimeTrackerRequest saved = await _requests.createRequest(
      request: TransactionRules.build(
        requesterEmail: me.email,
        requesterDepartmentId: me.departmentId,
        managerEmail: manager,
        checkIn: checkIn,
        checkOut: checkOut,
        description: description,
        now: _clock(),
        attachments: attachments,
        requesterIsHrApprover: _access.isHrApprover,
        managerIsSoleOtherHr: managerIsSoleOtherHr,
        overnightShift: schedule?.isOvernight ?? false,
      ),
    );
    _log.log(TimeTrackerLogService.actionCreateTransaction);
    final ApproverDirectory? approvers = _approvers;
    final TimeTrackerNotificationService? notifier = _notifier;
    if (approvers != null && notifier != null) {
      final Map<String, int> waiting = await approvers.waitingApprovers(saved);
      if (waiting.isNotEmpty) {
        await notifier.notifyPendingApprovals(
          senderEmail: me.email,
          countByApprover: waiting,
          requestId: saved.id,
          isArabic: false,
        );
      }
    }
    return saved;
  }

  /// Function Name: [cancel]
  ///
  /// Purpose: Cancel the signed-in employee's own PENDING transaction.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///   [String] reason
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> cancel(
    TimeTrackerRequest request, {
    String reason = '',
  }) async {
    // 9/10/2026 (code review): decide on the STORED transaction, not the
    // caller's copy; the save is a compare-and-set on what was read.
    final TimeTrackerRequest? stored = await _requests.fetchRequest(id: request.id);
    if (stored == null) throw Exception('This request no longer exists.');
    if (!_access.canCancelTransaction ||
        !TransactionRules.canCancel(stored, _access.currentUserEmail)) {
      throw const TimeTrackerPermissionDenied();
    }
    final TimeTrackerRequest saved = await _requests.updateRequest(
      request: TransactionRules.cancel(stored, reason: reason),
    );
    _log.log(TimeTrackerLogService.actionCancelTransaction);
    return saved;
  }
}
