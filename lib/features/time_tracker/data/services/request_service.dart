/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: request_service.dart
/// Purpose: Declares `RequestService` — everything the EMPLOYEE does with
///          their requests: load the form (types, balance, schedule),
///          submit, cancel a pending one, ask to cancel an approved one,
///          send a reminder, and the comment thread — and `RequestFormSetup`
///          + `ReminderTooSoon`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase-4 brief §A. Gates (FINAL SPEC §1 section 4 / 3 / 5):
///   * submit `Create_Time_Tracker_Request`; cancel `Cancel_Time_Tracker_
///     Request` (a transaction: `Cancel_Transaction`); reminder
///     `Send_Request_Reminder`; comments `Comment_On_Requests` (requester) or
///     `Comment_On_Approvals` (an approver of the request).
///   * The form offers ACTIVE types available to the employee's location
///     AND department; the direct manager is resolved at submit
///     (`ManagerResolver`, decision 18).
/// Every state change appends a history row (who = `Modified_By`, time =
/// `timestamps`, status / steps / reason) and writes the System Log; the
/// current step's approver(s) are notified. A type with no approval step is
/// approved on submit and deducts at once. Rules live in the domain
/// (`RequestFormRules`, `RequestCycleRules`, `RequestCommentRules`); no try
/// here — repositories throw clean `Exception`s, a refused move is a
/// `StateError`, a missing switch `TimeTrackerPermissionDenied`.
/// Updated: 9/10/2026 - code review:
///   * finding 2: every update is a compare-and-set on the request as just
///     re-read (comments were retried on a `TimeTrackerRecordChanged` —
///     no longer needed since they left the request, see below);
///   * finding 3: a request approved on submit (no approval step) is
///     created TOGETHER with its deduction (one transaction) — no approved
///     request without its deduction, no duplicate after a failed write;
///   * finding 7: a direct manager who cannot act (no `Approve_And_Reject`
///     / not active) is skipped at submit (the request goes to HR); a
///     manager who is the only other HR approver decides alone;
///   * finding 10: a deducting type with no balance = 0 days remaining;
///   * submit re-reads the request TYPE (a stale form snapshot of a type
///     made inactive / changed is refused) and refuses an overlap with the
///     employee's own live leave requests;
///   * [loadFormSetup] counts vacation days on the deduction schedule
///     (finding 1) and reads only the employee's own requests (finding 9);
///     the 1 January roll-over is no longer written by this read.
/// Updated: 9/10/2026 - data model (owner, 9 Oct):
///   * balances are one document per employee per YEAR — the form loads
///     every stored year ([RequestFormSetup.balances]); owner round 9
///     option b: a deducting request may span two years and EACH year must
///     cover its share — else `TimeTrackerNoVacationBalance(year)` /
///     `TimeTrackerYearBalanceShort` naming that year;
///   * comments are documents of `Requests/{id}/Comments`
///     (`RequestCommentBaseRepository`): adding / editing / deleting one no
///     longer rewrites the request, so the compare-and-set retry loop for
///     comments is gone. The gates are unchanged (`Comment_On_Requests` for
///     the requester, `Comment_On_Approvals` for an involved approver,
///     checked on a FRESH read of the request); edit / delete only one's
///     own comment (checked by the repository inside its transaction).

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_effects.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_comment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/vacation_balance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_side_effects.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_reminder_rule.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// What the request form needs: the types the employee may pick, their
/// balances (9/10/2026: one per YEAR — every stored year), the schedule
/// vacation days are counted on, and (9/10/2026) their own requests
/// (overlap check).
class RequestFormSetup {
  const RequestFormSetup({
    this.types = const <RequestType>[],
    this.balances = const <VacationBalance>[],
    this.year = 0,
    this.schedule,
    this.ownRequests = const <TimeTrackerRequest>[],
  });

  final List<RequestType> types;

  /// The employee's stored balances, one per year (9/10/2026).
  final List<VacationBalance> balances;

  /// The current year when the setup was loaded.
  final int year;

  /// Function Name: [balanceFor]
  ///
  /// Purpose: The balance of [year] (null = none stored → 0 days for a
  /// deducting type).
  ///
  /// Return type: [VacationBalance?]
  VacationBalance? balanceFor(int year) {
    for (final VacationBalance b in balances) {
      if (b.year == year) return b;
    }
    return null;
  }

  /// The current year's balance.
  VacationBalance? get balance => balanceFor(year);

  /// Function Name: [balanceForDraft]
  ///
  /// Purpose: The balance a draft is checked against — the year it STARTS
  /// in (the current year until a start date is picked).
  ///
  /// Return type: [VacationBalance?]
  VacationBalance? balanceForDraft(RequestDraft draft) => balanceFor(draft.startDate?.year ?? year);

  /// The schedule vacation days are counted on (9/10/2026: the deduction
  /// schedule — an unknown HR week falls back to the company's week).
  final WorkSchedule? schedule;
  final List<TimeTrackerRequest> ownRequests;
}

/// "You Can Only Send A Reminder Once Every Two Days" — [lastSentAt] is the
/// date the dialog shows.
class ReminderTooSoon implements Exception {
  const ReminderTooSoon(this.lastSentAt);

  final DateTime lastSentAt;

  @override
  String toString() => 'A reminder was already sent on $lastSentAt.';
}

class RequestService {
  RequestService({
    required RequestBaseRepository requests,
    required RequestCommentBaseRepository comments,
    required RequestTypeBaseRepository types,
    required VacationBalanceBaseRepository balances,
    required WorkSetupSourceResolver resolver,
    required ManagerResolver managers,
    required ApproverDirectory approvers,
    required RequestEffects effects,
    required TimeTrackerNotificationService notifier,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    DateTime Function() clock = DateTime.now,
  })  : _requests = requests,
        _comments = comments,
        _types = types,
        _balances = balances,
        _resolver = resolver,
        _managers = managers,
        _approvers = approvers,
        _effects = effects,
        _notifier = notifier,
        _access = access,
        _log = log,
        _clock = clock;

  final RequestBaseRepository _requests;
  final RequestCommentBaseRepository _comments;
  final RequestTypeBaseRepository _types;
  final VacationBalanceBaseRepository _balances;
  final WorkSetupSourceResolver _resolver;
  final ManagerResolver _managers;
  final ApproverDirectory _approvers;
  final RequestEffects _effects;
  final TimeTrackerNotificationService _notifier;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  final DateTime Function() _clock;

  /// Function Name: [loadFormSetup]
  ///
  /// Purpose: The types the signed-in employee may pick (ACTIVE, available
  /// to their location AND department), their balances (every stored year,
  /// read only — 9/10/2026), the schedule vacation days are counted on and
  /// their own requests.
  ///
  /// Return type: [Future<RequestFormSetup>]
  Future<RequestFormSetup> loadFormSetup() async {
    final TimeTrackerIdentity me = _access.identity;
    final EmployeeWorkSetup? setup = await (await _resolver.resolve())
        .loadWorkSetup(employeeEmail: me.email, employeeId: me.employeeId);
    final List<RequestType> all = await _types.watchRequestTypes().first;
    return RequestFormSetup(
      types: RequestFormRules.availableTypes(
        all,
        locationId: setup?.location.id ?? '',
        departmentId: me.departmentId,
      ),
      balances: await _balances.fetchBalancesOf(employeeEmail: me.email),
      year: _clock().year,
      schedule: await _effects.deductionScheduleOf(me.email, employeeId: me.employeeId),
      ownRequests: await _requests.watchRequestsOf(email: me.email).first,
    );
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Create the signed-in employee's request (after the confirm
  /// dialog) and notify whoever its first step waits for. Everything the
  /// form validated against is READ AGAIN here (type, balance, own
  /// requests — 9/10/2026), so a stale form cannot slip through.
  ///
  /// Parameters:
  ///   [RequestDraft] draft · [RequestFormSetup] setup (what the form showed;
  ///   not trusted — everything is re-read) · [bool] isArabic
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> submit(
    RequestDraft draft, {
    required RequestFormSetup setup,
    required bool isArabic,
  }) async {
    if (!_access.canCreateRequest) throw const TimeTrackerPermissionDenied();
    final RequestFormSetup current = await loadFormSetup();
    final RequestType? picked = draft.type;
    RequestType? fresh;
    for (final RequestType t in current.types) {
      if (picked != null && t.id == picked.id) fresh = t;
    }
    // The type was made inactive / removed / moved out of reach meanwhile.
    if (picked != null && fresh == null) {
      throw StateError('This request type is no longer available.');
    }
    final RequestDraft checked = fresh == null ? draft : draft.copyWith(type: fresh);
    final Set<RequestFormError> errors = RequestFormRules.validate(
      checked,
      // 9/10/2026: the balance of the year the request starts in.
      balance: current.balanceForDraft(checked),
      balances: current.balances,
      schedule: current.schedule,
      ownRequests: current.ownRequests,
    );
    if (errors.contains(RequestFormError.noBalance) || errors.contains(RequestFormError.exceedsBalance)) {
      // Round 9 b: name the first year that cannot cover its share.
      final VacationShortfall? short = RequestFormRules.shortfall(
        checked,
        schedule: current.schedule,
        balance: current.balanceForDraft(checked),
        balances: current.balances,
      );
      if (short == null || short.isMissing) throw TimeTrackerNoVacationBalance(year: short?.year);
      throw TimeTrackerYearBalanceShort(year: short.year, daysLeft: short.daysLeft);
    }
    if (errors.isNotEmpty) {
      throw StateError('The request is not valid: ${errors.map((RequestFormError e) => e.name).join(', ')}');
    }
    final TimeTrackerIdentity me = _access.identity;
    final String manager = await _actionableManager(me);
    final TimeTrackerRequest built = RequestFormRules.build(
      checked,
      requesterEmail: me.email,
      requesterDepartmentId: me.departmentId,
      managerEmail: manager,
      // HR's own request → their manager decides alone (9/10/2026).
      requesterIsHrApprover: _access.isHrApprover,
      managerIsSoleOtherHr: manager.isNotEmpty &&
          await _approvers.isSoleOtherHrApprover(email: manager, requesterEmail: me.email),
    );
    // No approval step at all: approved on submit → created WITH its
    // deduction in one transaction (finding 3).
    final PlannedRequestChange planned = await _effects.plan(
      from: RequestStatus.pending,
      after: built,
      type: checked.type,
    );
    final TimeTrackerRequest saved = (await _requests.commitRequest(
      request: planned.request,
      effects: planned.effects,
      now: _clock(),
    ))
        .request;
    _log.log(TimeTrackerLogService.actionCreateRequest);
    await _notifyWaiting(saved, isArabic: isArabic);
    return saved;
  }

  /// The direct manager when they can act on the manager step, else ''
  /// (the request then goes to HR — finding 7, decision 18).
  Future<String> _actionableManager(TimeTrackerIdentity me) async {
    final String manager = await _managers.managerEmailOf(
      employeeEmail: me.email,
      employeeId: me.employeeId,
    );
    if (manager.trim().isEmpty) return '';
    return await _approvers.mayApprove(manager) ? manager : '';
  }

  /// Function Name: [cancelPending]
  ///
  /// Purpose: The requester withdraws a PENDING request or transaction.
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> cancelPending(TimeTrackerRequest request) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    final bool allowed =
        fresh.isTransaction ? _access.canCancelTransaction : _access.canCancelRequest;
    if (!allowed || !RequestCycleRules.canCancelPending(fresh, _access.currentUserEmail)) {
      throw const TimeTrackerPermissionDenied();
    }
    final TimeTrackerRequest saved =
        await _requests.updateRequest(request: RequestCycleRules.cancelPending(fresh));
    _log.log(fresh.isTransaction
        ? TimeTrackerLogService.actionCancelTransaction
        : TimeTrackerLogService.actionCancelRequest);
    return saved;
  }

  /// Function Name: [requestCancellation]
  ///
  /// Purpose: "Request To Cancellation" on an APPROVED leave request (with
  /// the reason) → under review, back through the approval cycle.
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored.
  Future<TimeTrackerRequest> requestCancellation(
    TimeTrackerRequest request, {
    required String reason,
    required bool isArabic,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    if (!_access.canCancelRequest ||
        !RequestCycleRules.canRequestCancellation(fresh, _access.currentUserEmail)) {
      throw const TimeTrackerPermissionDenied();
    }
    final TimeTrackerRequest next = RequestCycleRules.requestCancellation(fresh, reason: reason);
    // The type needed no approval → canceled at once, the stored deduction
    // given back in the SAME transaction (findings 3 + 4).
    final RequestType? type = RequestEffects.needsType(fresh.status, next)
        ? await _types.fetchRequestType(id: fresh.requestTypeId)
        : null;
    final PlannedRequestChange planned = await _effects.plan(from: fresh.status, after: next, type: type);
    final RequestCommit commit = await _requests.commitRequest(
      request: planned.request,
      effects: planned.effects,
      now: _clock(),
    );
    final TimeTrackerRequest saved = commit.request;
    _log.log(TimeTrackerLogService.actionRequestCancellation);
    await _notifyWaiting(saved, isArabic: isArabic);
    return saved;
  }

  /// Function Name: [sendReminder]
  ///
  /// Purpose: "Send Reminder" on a PENDING request (once every two days):
  /// notify the current step's approver(s).
  ///
  /// Return type: [Future<TimeTrackerRequest>] — as stored; throws
  /// [ReminderTooSoon] inside the two days.
  Future<TimeTrackerRequest> sendReminder(
    TimeTrackerRequest request, {
    required bool isArabic,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    if (!_access.canSendRequestReminder ||
        !RequestCycleRules.isRequester(fresh, _access.currentUserEmail) ||
        fresh.status != RequestStatus.pending) {
      throw const TimeTrackerPermissionDenied();
    }
    final DateTime now = _clock();
    final DateTime? last = fresh.lastReminderAt;
    if (last != null && !RequestCycleRules.canRemind(fresh, _access.currentUserEmail, now)) {
      throw ReminderTooSoon(last);
    }
    final TimeTrackerRequest saved =
        await _requests.updateRequest(request: RequestCycleRules.remind(fresh, now: now));
    _log.log(TimeTrackerLogService.actionSendReminder);
    await _notifyWaiting(saved, isArabic: isArabic);
    return saved;
  }

  /// Function Name: [nextReminderAt]
  ///
  /// Return type: [DateTime?] — when the next reminder may go (null = now).
  DateTime? nextReminderAt(TimeTrackerRequest request) =>
      RequestReminderRule.nextAllowedAt(request.lastReminderAt);

  /// Function Name: [watchComments]
  ///
  /// Purpose: ADDED 9/10/2026 (data model) — the live comments of
  /// [requestId] (`Requests/{id}/Comments`; deleted ones included —
  /// `RequestCommentRules.thread` hides them). The details page that shows
  /// them already checked the viewer may see the request.
  ///
  /// Return type: [Stream<List<RequestComment>>]
  Stream<List<RequestComment>> watchComments(String requestId) =>
      _comments.watchComments(requestId: requestId);

  /// Function Name: [addComment] / [editComment] / [deleteComment]
  ///
  /// Purpose: The "Inquiries And Comments" thread ([asApprover] = from the
  /// Approvals tab → `Comment_On_Approvals`, else `Comment_On_Requests` on
  /// one's own request — checked on a FRESH read of the request). Edit /
  /// delete only one's own comment. Since 9/10/2026 each comment is its own
  /// document: the request itself is not written.
  ///
  /// Return type: [Future<RequestComment>] — as stored.
  Future<RequestComment> addComment(
    TimeTrackerRequest request, {
    required String text,
    required bool asApprover,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    _requireComment(fresh, asApprover: asApprover);
    return _comments.addComment(
      requestId: fresh.id,
      comment: RequestCommentRules.create(authorEmail: _access.currentUserEmail, text: text, now: _clock()),
    );
  }

  Future<RequestComment> editComment(
    TimeTrackerRequest request, {
    required String commentId,
    required String text,
    required bool asApprover,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    _requireComment(fresh, asApprover: asApprover);
    return _comments.editComment(
      requestId: fresh.id,
      commentId: commentId,
      editorEmail: _access.currentUserEmail,
      text: text,
      now: _clock(),
    );
  }

  Future<RequestComment> deleteComment(
    TimeTrackerRequest request, {
    required String commentId,
    required bool asApprover,
  }) async {
    final TimeTrackerRequest fresh = await _fresh(request);
    _requireComment(fresh, asApprover: asApprover);
    return _comments.deleteComment(
      requestId: fresh.id,
      commentId: commentId,
      editorEmail: _access.currentUserEmail,
    );
  }

  /// Function Name: [mayComment]
  ///
  /// Return type: [bool] — the signed-in user may write in [request]'s
  /// thread from that tab.
  bool mayComment(TimeTrackerRequest request, {required bool asApprover}) => asApprover
      ? _access.canCommentOnApprovals && ApprovalInbox.involves(request, _access.approverView)
      : _access.canCommentOnRequests && RequestCycleRules.isRequester(request, _access.currentUserEmail);

  void _requireComment(TimeTrackerRequest request, {required bool asApprover}) {
    if (!mayComment(request, asApprover: asApprover)) throw const TimeTrackerPermissionDenied();
  }

  Future<TimeTrackerRequest> _fresh(TimeTrackerRequest request) async {
    final TimeTrackerRequest? stored = await _requests.fetchRequest(id: request.id);
    if (stored == null) throw Exception('This request no longer exists.');
    return stored;
  }

  Future<void> _notifyWaiting(TimeTrackerRequest request, {required bool isArabic}) async {
    final Map<String, int> waiting = await _approvers.waitingApprovers(request);
    if (waiting.isEmpty) return;
    await _notifier.notifyPendingApprovals(
      senderEmail: _access.currentUserEmail,
      countByApprover: waiting,
      requestId: request.id,
      isArabic: isArabic,
    );
  }
}
