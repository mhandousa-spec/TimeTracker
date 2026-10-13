/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_notification_service.dart
/// Purpose: Declares `TimeTrackerNotificationService` — every notification
///          the Requests / Approvals flows send, as intent-named methods.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same pattern as `TodoNotificationService`: the event comes from
/// `TimeTrackerNotificationEvent`, the landing page from
/// `TimeTrackerNotificationPage`, the placeholder from `TemplateVariable`;
/// everything goes through `AppNotificationSender.sendEvent` (admin-edited
/// template, enabled switch, both languages, FCM push). Every send carries
/// the request id (`Request_Id`) so View opens THAT request — the
/// requester's details or the approver's details (page key).
///
/// Events (brief §C, existing catalogue wording):
///   * new request / transaction, moved to HR, reminder, cancellation asked
///     → `pending_approvals_manager` ("{count} requests pending your review")
///     to the current step's approver(s), count per approver;
///   * approved → `request_approved_attendance_leave` (leave) /
///     `attendance_correction_approved` (transaction) → requester;
///   * rejected → `request_rejected` / `attendance_correction_rejected`;
///   * canceled after approval → `request_canceled` (new, 9/10/2026);
///   * balance used up by an approval → `vacation_entitlement_exhausted`.
/// The sender is the person who acted (so the inbox shows them and its
/// Message button reaches them). `sendEvent` resolves to false on failure
/// instead of throwing; [send] is the one dispatch point (tests override it).
/// Updated: 9/10/2026 - QA KP-TT-011: pending approvals carry
/// `{{countedRequests}}` in both languages ([pendingCountVariables]) — no
/// more "1 requests" / "1 طلبات".

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/count_wording.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';

/// A request type name in both languages (the `{{requestType}}` value).
class TimeTrackerTypeName {
  const TimeTrackerTypeName({this.en = '', this.ar = ''});

  final String en;
  final String ar;
}

class TimeTrackerNotificationService {
  const TimeTrackerNotificationService();

  /// Function Name: [notifyPendingApprovals]
  ///
  /// Purpose: "Pending Approvals" to each approver, with how many requests
  /// wait for them ([countByApprover]: email → count, ≥ 1).
  ///
  /// Return type: [Future<int>] — how many were stored.
  Future<int> notifyPendingApprovals({
    required String senderEmail,
    required Map<String, int> countByApprover,
    required String requestId,
    required bool isArabic,
  }) async {
    int sent = 0;
    for (final MapEntry<String, int> e in countByApprover.entries) {
      final int count = e.value < 1 ? 1 : e.value;
      final bool ok = await send(
        event: TimeTrackerNotificationEvent.pendingApprovalsManager,
        page: TimeTrackerNotificationPage.approvalDetails,
        senderEmail: senderEmail,
        receiverEmail: e.key,
        isArabic: isArabic,
        variables: pendingCountVariables(count),
        variablesAr: pendingCountVariables(count, arabic: true),
        requestId: requestId,
      );
      if (ok) sent++;
    }
    return sent;
  }

  /// Function Name: [pendingCountVariables]
  ///
  /// Purpose: ADDED 9/10/2026 (QA KP-TT-011) — the placeholders of the
  /// pending-approvals texts: `{{count}}` (the number) and
  /// `{{countedRequests}}` (the number with its noun in correct grammar:
  /// "1 request" / "3 requests", "طلب واحد" / "طلبان" / "3 طلبات").
  ///
  /// Return type: [Map<TemplateVariable, String>] — English, or the Arabic
  /// override with [arabic].
  static Map<TemplateVariable, String> pendingCountVariables(int count, {bool arabic = false}) =>
      <TemplateVariable, String>{
        TemplateVariable.count: '$count',
        TemplateVariable.countedRequests: TimeTrackerCountWording.requests(count, arabic: arabic),
      };

  /// Function Name: [notifyApproved] / [notifyRejected] / [notifyCanceled]
  ///
  /// Purpose: The decision, to the requester (transactions use the
  /// attendance-correction events; canceling a transaction uses
  /// `request_canceled` with the "Transaction" name).
  ///
  /// Return type: [Future<bool>]
  Future<bool> notifyApproved({
    required String senderEmail,
    required String requesterEmail,
    required bool isTransaction,
    required TimeTrackerTypeName typeName,
    required String requestId,
    required bool isArabic,
  }) =>
      _toRequester(
        event: isTransaction
            ? TimeTrackerNotificationEvent.attendanceCorrectionApproved
            : TimeTrackerNotificationEvent.requestApprovedAttendanceLeave,
        senderEmail: senderEmail,
        requesterEmail: requesterEmail,
        typeName: isTransaction ? null : typeName,
        requestId: requestId,
        isArabic: isArabic,
      );

  Future<bool> notifyRejected({
    required String senderEmail,
    required String requesterEmail,
    required bool isTransaction,
    required TimeTrackerTypeName typeName,
    required String requestId,
    required bool isArabic,
  }) =>
      _toRequester(
        event: isTransaction
            ? TimeTrackerNotificationEvent.attendanceCorrectionRejected
            : TimeTrackerNotificationEvent.requestRejected,
        senderEmail: senderEmail,
        requesterEmail: requesterEmail,
        typeName: isTransaction ? null : typeName,
        requestId: requestId,
        isArabic: isArabic,
      );

  Future<bool> notifyCanceled({
    required String senderEmail,
    required String requesterEmail,
    required TimeTrackerTypeName typeName,
    required String requestId,
    required bool isArabic,
  }) =>
      _toRequester(
        event: TimeTrackerNotificationEvent.requestCanceled,
        senderEmail: senderEmail,
        requesterEmail: requesterEmail,
        typeName: typeName,
        requestId: requestId,
        isArabic: isArabic,
      );

  /// Function Name: [notifyVacationExhausted]
  ///
  /// Purpose: "Vacation Limit Reached" — an approval used the last days.
  ///
  /// Return type: [Future<bool>]
  Future<bool> notifyVacationExhausted({
    required String senderEmail,
    required String requesterEmail,
    required String requestId,
    required bool isArabic,
  }) =>
      _toRequester(
        event: TimeTrackerNotificationEvent.vacationEntitlementExhausted,
        senderEmail: senderEmail,
        requesterEmail: requesterEmail,
        typeName: null,
        requestId: requestId,
        isArabic: isArabic,
      );

  /// Function Name: [notifyWorkLocationUpdated] / [notifyShiftUpdated]
  ///
  /// Purpose: ADDED 13/10/2026 (decision 34): HR assigned / reassigned the
  /// employee — "Assigned Work Location Updated" when the place(s) changed,
  /// "Shift Schedule Updated" when the working rules changed. Opens the
  /// module's main page.
  ///
  /// Return type: [Future<bool>]
  Future<bool> notifyWorkLocationUpdated({
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
  }) =>
      send(
        event: TimeTrackerNotificationEvent.workLocationUpdatedSelf,
        page: TimeTrackerNotificationPage.mainPage,
        senderEmail: senderEmail,
        receiverEmail: employeeEmail,
        isArabic: isArabic,
      );

  Future<bool> notifyShiftUpdated({
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
  }) =>
      send(
        event: TimeTrackerNotificationEvent.shiftUpdated,
        page: TimeTrackerNotificationPage.mainPage,
        senderEmail: senderEmail,
        receiverEmail: employeeEmail,
        isArabic: isArabic,
      );

  Future<bool> _toRequester({
    required TimeTrackerNotificationEvent event,
    required String senderEmail,
    required String requesterEmail,
    required TimeTrackerTypeName? typeName,
    required String requestId,
    required bool isArabic,
  }) {
    final TimeTrackerTypeName? name = typeName;
    return send(
      event: event,
      page: TimeTrackerNotificationPage.requestDetails,
      senderEmail: senderEmail,
      receiverEmail: requesterEmail,
      isArabic: isArabic,
      variables: name == null
          ? const <TemplateVariable, String>{}
          : <TemplateVariable, String>{TemplateVariable.requestType: name.en.trim()},
      variablesAr: name == null
          ? const <TemplateVariable, String>{}
          : <TemplateVariable, String>{
              TemplateVariable.requestType: name.ar.trim().isNotEmpty ? name.ar.trim() : name.en.trim(),
            },
      requestId: requestId,
    );
  }

  /// Function Name: [send]
  ///
  /// Purpose: The one place a Time Tracker event is dispatched.
  ///
  /// Parameters:
  ///   [TimeTrackerNotificationEvent] event
  ///   [TimeTrackerNotificationPage] page: which details View opens.
  ///   [String] senderEmail / [String] receiverEmail
  ///   [bool] isArabic
  ///   [Map<TemplateVariable, String>] variables / variablesAr
  ///   [String] requestId: stored as `Request_Id`.
  ///
  /// Return type: [Future<bool>] — false for an empty receiver or a failed
  /// send (never throws).
  Future<bool> send({
    required TimeTrackerNotificationEvent event,
    required TimeTrackerNotificationPage page,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const <TemplateVariable, String>{},
    Map<TemplateVariable, String> variablesAr = const <TemplateVariable, String>{},
    String requestId = '',
  }) async {
    final String receiver = receiverEmail.trim().toLowerCase();
    if (receiver.isEmpty) return false;
    return AppNotificationSender.sendEvent(
      event: event,
      pageKey: page.key,
      senderEmail: senderEmail.trim().toLowerCase(),
      receiverEmail: receiver,
      isArabic: isArabic,
      variables: variables,
      variablesAr: variablesAr,
      requestId: requestId.trim(),
    );
  }
}
