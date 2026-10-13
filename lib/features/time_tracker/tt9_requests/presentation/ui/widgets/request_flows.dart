/// Module: time_tracker / tt9_requests / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_flows.dart
/// Purpose: Declares `RequestFlows` — the confirm → (reason) → success
///          dialog flows of every request / approval action, with the
///          failure message afterwards.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Exact texts (inventory §C / §H2, owner copy fixes):
///   * Cancel a pending request: "Request To Cancellation" — "Are You Sure
///     You Want To Cancel This Request ?" → "Request Canceled".
///   * Cancel an approved one: same confirm → "Reason Of Cancellation"
///     (Justifications 0/500, Submit) → "Request Cancellation — You
///     Successfully Requested Cancellation For This Request".
///   * Send Reminder: "Reminder Was Sent On {date}" — "You Can Only Send A
///     Reminder Once Every Two Days…" (also when it is too soon).
///   * Approve: "Approve Request" → "Approved — You Successfully Approved
///     This Request" (never "Service Requested").
///   * Reject: "Reject Request" → "Reason Of Rejection" (required) →
///     "Successful — You Successfully Rejected This Request".
///   * Cancel after approving: "Cancel Request" → "Reason Of Cancellation"
///     → "Request Canceled — You Successfully Canceled This Request".
///   * Under review: Approve / Reject the CANCELLATION (own wording).
/// Animations / haptics (standard): Reject / Cancel / Delete confirms are
/// destructive (ShakeOnce + HIGH on Yes); the others scale in.
/// Updated: 9/10/2026 - code review: a save refused because someone else
/// changed the request first / there is no vacation balance says so.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/widgets/request_text.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestFlows {
  const RequestFlows._();

  static bool _ar(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

  /// Function Name: [cancel]
  ///
  /// Purpose: The requester's Cancel: pending → canceled directly; approved
  /// → asks for the reason and requests the cancellation.
  ///
  /// Return type: [Future<void>]
  static Future<void> cancel(BuildContext context, TimeTrackerRequest request) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final bool ar = _ar(context);
    if (request.status == RequestStatus.pending) {
      await CustomDialogManager.showDialogFlow(
        context: context,
        confirmWidth: 411,
        destructive: true,
        confirmLottie: AppAssets.lottieWarning,
        confirmTitle: s.timeTrackerRequestToCancellation,
        confirmSubtitle: s.timeTrackerCancelRequestConfirm,
        confirmYesText: s.yes,
        confirmNoText: s.no,
        onConfirm: () => actions.cancelPending(request),
        successLottie: AppAssets.successful,
        successTitle: s.timeTrackerRequestCanceledTitle,
        successSubtitle: s.timeTrackerRequestCanceled,
      );
    } else {
      final TextEditingController reason = TextEditingController();
      await CustomDialogManager.showDialogFlow(
        context: context,
        confirmWidth: 411,
        destructive: true,
        confirmLottie: AppAssets.lottieWarning,
        confirmTitle: s.timeTrackerRequestToCancellation,
        confirmSubtitle: s.timeTrackerCancelRequestConfirm,
        confirmYesText: s.yes,
        confirmNoText: s.no,
        comment: true,
        commentRequired: true,
        commentController: reason,
        customReasonTitle: s.timeTrackerReasonOfCancellation,
        customReasonIconAsset: AppAssets.close,
        commentSubmitText: s.submit,
        commentDiscardText: s.discard,
        onConfirm: () => actions.requestCancellation(request, reason: reason.text, isArabic: ar),
        successLottie: AppAssets.successful,
        successTitle: s.timeTrackerRequestCancellationTitle,
        successSubtitle: s.timeTrackerCancellationRequested,
      );
      reason.dispose();
    }
    if (context.mounted) await _afterFlow(context);
  }

  /// Function Name: [sendReminder]
  ///
  /// Purpose: Send Reminder → "Reminder Was Sent On {date}" (the new date,
  /// or the earlier one when it is too soon).
  ///
  /// Return type: [Future<void>]
  static Future<void> sendReminder(BuildContext context, TimeTrackerRequest request) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final bool sent = await actions.sendReminder(request, isArabic: _ar(context));
    if (!context.mounted) return;
    final DateTime? at = actions.state.reminderSentAt;
    if (!sent && !actions.state.reminderTooSoon) {
      await _afterFlow(context);
      return;
    }
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: sent ? AppAssets.successful : AppAssets.lottieWarning,
      title: s.timeTrackerReminderSentOn(TimeTrackerFormat.date(context, at ?? DateTime.now())),
      subtitle: s.timeTrackerReminderRule,
      // Owner rule R3: no OK button, closes itself.
      closeAfter: const Duration(seconds: 3),
    );
  }

  /// Function Name: [approve]
  ///
  /// Purpose: Approve the current step (or accept a cancellation).
  ///
  /// Return type: [Future<void>]
  static Future<void> approve(BuildContext context, TimeTrackerRequest request) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final TimeTrackerTypeName names =
        RequestText.typeNames(context, request, context.read<RequestsCubit>().state);
    final bool ar = _ar(context);
    final bool review = request.status == RequestStatus.underReview;
    // 13/10/2026 (owner): Approve asks for a justification, like Reject asks
    // for a reason (required — the requester and HR read why).
    final TextEditingController justification = TextEditingController();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      // 13/10/2026 (owner I6): a green tick, not the "+" document.
      confirmLottie: AppAssets.lottieApproved,
      confirmTitle: review ? s.timeTrackerApproveCancellation : s.timeTrackerApproveRequest,
      confirmSubtitle: review ? s.timeTrackerApproveCancellationConfirm : s.timeTrackerApproveRequestConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      comment: true,
      commentRequired: true,
      commentController: justification,
      customReasonTitle: s.timeTrackerApprovalJustification,
      customReasonIconAsset: AppAssets.success,
      commentSubmitText: s.submit,
      commentDiscardText: s.discard,
      onConfirm: () => actions.approve(
        request,
        typeName: names,
        isArabic: ar,
        justification: justification.text,
      ),
      successLottie: AppAssets.successful,
      successTitle: review ? s.timeTrackerCancellationApprovedTitle : s.timeTrackerApproved,
      successSubtitle: review ? s.timeTrackerCancellationApproved : s.timeTrackerRequestApproved,
    );
    justification.dispose();
    if (context.mounted) await _afterFlow(context);
  }

  /// Function Name: [reject]
  ///
  /// Purpose: Reject with the required "Reason Of Rejection" (or refuse a
  /// cancellation: the request stays approved).
  ///
  /// Return type: [Future<void>]
  static Future<void> reject(BuildContext context, TimeTrackerRequest request) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final TimeTrackerTypeName names =
        RequestText.typeNames(context, request, context.read<RequestsCubit>().state);
    final bool ar = _ar(context);
    final bool review = request.status == RequestStatus.underReview;
    final TextEditingController reason = TextEditingController();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: review ? s.timeTrackerRejectCancellation : s.timeTrackerRejectRequest,
      confirmSubtitle: review ? s.timeTrackerRejectCancellationConfirm : s.timeTrackerRejectRequestConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      comment: true,
      commentRequired: true,
      commentController: reason,
      customReasonTitle: s.timeTrackerReasonOfRejection,
      customReasonIconAsset: AppAssets.close,
      commentSubmitText: s.submit,
      commentDiscardText: s.discard,
      onConfirm: () => actions.reject(
        request,
        reason: reason.text,
        typeName: names,
        isArabic: ar,
      ),
      successLottie: AppAssets.successful,
      successTitle: review ? s.timeTrackerCancellationRejectedTitle : s.timeTrackerSuccessful,
      successSubtitle: review ? s.timeTrackerCancellationRejected : s.timeTrackerRequestRejected,
    );
    reason.dispose();
    if (context.mounted) await _afterFlow(context);
  }

  /// Function Name: [cancelAfterApproving]
  ///
  /// Purpose: HR's Cancel on an approved request ("Canceled By HR").
  ///
  /// Return type: [Future<void>]
  static Future<void> cancelAfterApproving(BuildContext context, TimeTrackerRequest request) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final TimeTrackerTypeName names =
        RequestText.typeNames(context, request, context.read<RequestsCubit>().state);
    final bool ar = _ar(context);
    final TextEditingController reason = TextEditingController();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerCancelRequest,
      confirmSubtitle: s.timeTrackerCancelRequestConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      comment: true,
      commentRequired: true,
      commentController: reason,
      customReasonTitle: s.timeTrackerReasonOfCancellation,
      customReasonIconAsset: AppAssets.close,
      commentSubmitText: s.submit,
      commentDiscardText: s.discard,
      onConfirm: () => actions.cancelAfterApproving(
        request,
        reason: reason.text,
        typeName: names,
        isArabic: ar,
      ),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerRequestCanceledTitle,
      successSubtitle: s.timeTrackerRequestCanceled,
    );
    reason.dispose();
    if (context.mounted) await _afterFlow(context);
  }

  /// Function Name: [deleteComment]
  ///
  /// Purpose: Delete one's own comment (destructive confirm).
  ///
  /// Return type: [Future<void>]
  static Future<void> deleteComment(
    BuildContext context,
    TimeTrackerRequest request,
    String commentId, {
    required bool asApprover,
  }) async {
    final S s = S.of(context);
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      destructive: true,
      confirmLottie: AppAssets.lottieWarning,
      confirmTitle: s.timeTrackerDeletingComment,
      confirmSubtitle: s.timeTrackerDeleteCommentConfirm,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () => actions.deleteComment(request, commentId, asApprover: asApprover),
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerCommentDeletedTitle,
      successSubtitle: s.timeTrackerCommentDeleted,
    );
    if (context.mounted) await afterAction(context);
  }

  /// Function Name: [afterAction]
  ///
  /// Purpose: After any action: "no permission" / "could not be saved"
  /// when it failed (nothing when it worked).
  ///
  /// Return type: [Future<void>]
  static Future<void> afterAction(BuildContext context) => _afterFlow(context);

  static Future<void> _afterFlow(BuildContext context) async {
    final RequestActionsCubit actions = context.read<RequestActionsCubit>();
    final TimeTrackerActionFailure failure = actions.state.failure;
    if (failure == TimeTrackerActionFailure.none) return;
    final int? year = actions.state.balanceYear;
    final double daysLeft = actions.state.balanceDaysLeft;
    actions.acknowledgeFailure();
    // 9/10/2026 (code review): "changed meanwhile" / "no balance" have
    // their own message; owner round 9 b: a balance refusal names its year.
    await showTimeTrackerFailure(
      context,
      denied: failure == TimeTrackerActionFailure.denied,
      failure: failure,
      message: year == null
          ? null
          : S.of(context).timeTrackerYearBalanceShort(
              LocalizedNumber.digits(context, '$year'),
              LocalizedNumber.digits(context, VacationBalanceList.days(daysLeft)),
            ),
    );
  }
}
