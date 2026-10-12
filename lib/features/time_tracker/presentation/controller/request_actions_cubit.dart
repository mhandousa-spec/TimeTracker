/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_actions_cubit.dart
/// Purpose: Declares `RequestActionsCubit` + `RequestActionsState` — every
///          button of the request / approval details: cancel, request
///          cancellation, send reminder, approve, reject, cancel after
///          approving, and the comment thread.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 4. Each action returns `bool` for
/// `CustomDialogManager.showDialogFlow` (success dialog only on a real
/// success) and keeps why it failed in [RequestActionsState.failure], so the
/// page shows "no permission" / "could not be saved" afterwards (same
/// pattern as the phase-3 set-up cubits). A reminder sent too soon keeps the
/// last date ([RequestActionsState.reminderSentAt]) for the "Reminder Was
/// Sent On …" dialog. The language goes in so notifications render in both
/// (playbook §4: locale passed into the cubit call). Emit-after-close
/// guarded.
/// Updated: 9/10/2026 - code review finding 2: a busy guard — while one
/// action runs, a second tap (double tap, Approve then Reject) is ignored.
/// "Changed by someone else" / "no balance" are their own failures.
/// Updated: 9/10/2026 - owner round 9 b: a balance refusal keeps the year it
/// names ([RequestActionsState.balanceYear] / `balanceDaysLeft`).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): comments are documents of
/// `Requests/{id}/Comments` — [watchComments] feeds the thread
/// (`RequestCommentsCubit`); add / edit / delete keep their signatures.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/approval_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

class RequestActionsState {
  const RequestActionsState({
    this.failure = TimeTrackerActionFailure.none,
    this.reminderSentAt,
    this.reminderTooSoon = false,
    this.balanceYear,
    this.balanceDaysLeft = 0,
  });

  /// ADDED 9/10/2026 (owner round 9 b): the failed state of [error], with
  /// the year a balance refusal names.
  factory RequestActionsState.failedWith(Object error) {
    final (int, double)? year = timeTrackerBalanceYearOf(error);
    return RequestActionsState(
      failure: timeTrackerFailureOf(error),
      balanceYear: year?.$1,
      balanceDaysLeft: year?.$2 ?? 0,
    );
  }

  final TimeTrackerActionFailure failure;

  /// A balance refusal: the year that cannot cover its share, and its days
  /// left ("2027 has only 2 days left"; no balance = 0). Null otherwise.
  final int? balanceYear;
  final double balanceDaysLeft;

  /// When the last reminder went (the new one, or the earlier one when it
  /// was too soon).
  final DateTime? reminderSentAt;
  final bool reminderTooSoon;

  RequestActionsState copyWith({
    TimeTrackerActionFailure? failure,
    DateTime? reminderSentAt,
    bool? reminderTooSoon,
  }) =>
      RequestActionsState(
        failure: failure ?? this.failure,
        reminderSentAt: reminderSentAt ?? this.reminderSentAt,
        reminderTooSoon: reminderTooSoon ?? this.reminderTooSoon,
        balanceYear: balanceYear,
        balanceDaysLeft: balanceDaysLeft,
      );
}

class RequestActionsCubit extends Cubit<RequestActionsState> {
  RequestActionsCubit({
    required RequestService requests,
    required ApprovalService approvals,
  })  : _requests = requests,
        _approvals = approvals,
        super(const RequestActionsState());

  final RequestService _requests;
  final ApprovalService _approvals;

  /// An action is running (finding 2: never two at once).
  bool _busy = false;
  bool get isBusy => _busy;

  @override
  void emit(RequestActionsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── What the signed-in user may do (drives the buttons) ──────────────────

  bool mayDecide(TimeTrackerRequest r) => _approvals.mayDecide(r);
  bool mayCancelAfterApproving(TimeTrackerRequest r) => _approvals.mayCancelAfterApproving(r);
  bool mayComment(TimeTrackerRequest r, {required bool asApprover}) =>
      _requests.mayComment(r, asApprover: asApprover);

  // ── Requester ────────────────────────────────────────────────────────────

  /// Function Name: [cancelPending]
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> cancelPending(TimeTrackerRequest r) => _run(() => _requests.cancelPending(r));

  /// Function Name: [requestCancellation]
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> requestCancellation(TimeTrackerRequest r, {required String reason, required bool isArabic}) =>
      _run(() => _requests.requestCancellation(r, reason: reason, isArabic: isArabic));

  /// Function Name: [sendReminder]
  ///
  /// Purpose: Send a reminder; when it is too soon, [RequestActionsState]
  /// keeps the earlier date and [RequestActionsState.reminderTooSoon].
  ///
  /// Return type: [Future<bool>] — true when sent.
  Future<bool> sendReminder(TimeTrackerRequest r, {required bool isArabic}) async {
    if (_busy) return false;
    _busy = true;
    emit(const RequestActionsState());
    try {
      final TimeTrackerRequest saved = await _requests.sendReminder(r, isArabic: isArabic);
      emit(RequestActionsState(reminderSentAt: saved.lastReminderAt));
      return true;
    } on ReminderTooSoon catch (tooSoon) {
      emit(RequestActionsState(reminderSentAt: tooSoon.lastSentAt, reminderTooSoon: true));
      return false;
    } catch (error) {
      emit(RequestActionsState.failedWith(error));
      return false;
    } finally {
      _busy = false;
    }
  }

  // ── Approver ─────────────────────────────────────────────────────────────

  /// Function Name: [approve] / [reject] / [cancelAfterApproving]
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> approve(TimeTrackerRequest r, {required TimeTrackerTypeName typeName, required bool isArabic}) =>
      _run(() => _approvals.approve(r, typeName: typeName, isArabic: isArabic));

  Future<bool> reject(
    TimeTrackerRequest r, {
    required String reason,
    required TimeTrackerTypeName typeName,
    required bool isArabic,
  }) =>
      _run(() => _approvals.reject(r, reason: reason, typeName: typeName, isArabic: isArabic));

  Future<bool> cancelAfterApproving(
    TimeTrackerRequest r, {
    required String reason,
    required TimeTrackerTypeName typeName,
    required bool isArabic,
  }) =>
      _run(() => _approvals.cancelAfterApproving(r, reason: reason, typeName: typeName, isArabic: isArabic));

  // ── Comments ─────────────────────────────────────────────────────────────

  /// Function Name: [watchComments]
  ///
  /// Purpose: ADDED 9/10/2026 — the live comments of [requestId] (the
  /// `Comments` sub-collection), for `RequestCommentsCubit`.
  ///
  /// Return type: [Stream<List<RequestComment>>]
  Stream<List<RequestComment>> watchComments(String requestId) => _requests.watchComments(requestId);

  /// Function Name: [addComment] / [editComment] / [deleteComment]
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> addComment(TimeTrackerRequest r, String text, {required bool asApprover}) =>
      _run(() => _requests.addComment(r, text: text, asApprover: asApprover));

  Future<bool> editComment(TimeTrackerRequest r, String commentId, String text, {required bool asApprover}) =>
      _run(() => _requests.editComment(r, commentId: commentId, text: text, asApprover: asApprover));

  Future<bool> deleteComment(TimeTrackerRequest r, String commentId, {required bool asApprover}) =>
      _run(() => _requests.deleteComment(r, commentId: commentId, asApprover: asApprover));

  void acknowledgeFailure() => emit(state.copyWith(failure: TimeTrackerActionFailure.none));

  Future<bool> _run(Future<Object?> Function() action) async {
    // A second tap while the first save runs is ignored (finding 2).
    if (_busy) return false;
    _busy = true;
    emit(const RequestActionsState());
    try {
      await action();
      return true;
    } catch (error) {
      emit(RequestActionsState.failedWith(error));
      return false;
    } finally {
      _busy = false;
    }
  }
}
