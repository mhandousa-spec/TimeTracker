/// Module: services_management_module
/// Description: Bottom status row (send-reminder button + state chip) and
///              the requested-date / breached-SLA ribbon overlay for the
///              "my request" details page. Pure presentation — no I/O.
///              Extracted from MyRequestDetails (audit fix #1).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: intl, ServicesNotificationService
/// Revision History: Initial version.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// CHANGED 26/8/2026 — the raw FCM transport (notification_page_config.dart) is
// no longer imported here. UI goes through the module's notification service,
// which writes the in-app record as well as sending the push.
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/services/services_notification_service.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_button_with_image.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyRequestStatusFooter extends StatelessWidget {
  const MyRequestStatusFooter({
    super.key,
    required this.isMobile,
    required this.shouldShowReminder,
    required this.reminderServiceName,
    required this.currentApproverEmail,
    required this.hasApprovalCycle,
    required this.hasRejectionOrCancel,
    required this.borderColor,
    required this.iconAsset,
    required this.stateLabel,
  });

  final bool isMobile;
  final bool shouldShowReminder;
  final String reminderServiceName;
  final String? currentApproverEmail;
  final bool hasApprovalCycle;
  final bool hasRejectionOrCancel;
  final Color borderColor;
  final String iconAsset;
  final String stateLabel;

  /// Function Name: [_sendReminder]
  ///
  /// Purpose: Nudge the approver that this request is still waiting on them.
  ///
  /// ✅ FIX 26/8/2026 — this used to call
  /// `NotificationServiceApp.sendNotification(...)` directly, which is the RAW
  /// FCM transport. Two things followed, and both were reported:
  ///
  ///  1. IT CRASHED. `sendNotification` mints an OAuth token from the FCM
  ///     service account, and `AppKeys.fcmServiceAccountJson()` throws a
  ///     `StateError` when the `--dart-define` values are absent — deliberately,
  ///     so a misconfigured build fails loudly rather than silently dropping
  ///     every notification. Called straight from a tap handler with nothing to
  ///     catch it, that surfaced as an uncaught async error.
  ///  2. IT COULD NOT HAVE REACHED THE NOTIFICATIONS PAGE EVEN IF IT WORKED.
  ///     That page lists Firestore documents written by
  ///     `FirestoreNotificationService`. The raw transport writes none — it
  ///     only posts a push — so the reminder was never going to appear there.
  ///
  /// `app_notification_sender.dart` states the rule: "Modules should NOT call
  /// this directly from UI/cubits. Each module has its own thin service with
  /// intent-named methods." The Services module's method already existed and
  /// already carried the right catalog event; its doc comment reads "Nudge the
  /// approver that a request is still sitting unreviewed", which is precisely
  /// this button. It writes the in-app notification AND sends the push, and it
  /// renders the admin-editable `services_review_reminder_manager` template
  /// instead of the hardcoded English sentence that was here.
  ///
  /// Parameters:
  /// - [context]: for the active locale, and to report the outcome — the button
  ///   previously gave no feedback whether it worked or not.
  Future<void> _sendReminder(BuildContext context) async {
    if (currentApproverEmail == null || currentApproverEmail!.isEmpty) return;

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String senderEmail = AppControllers.isEmployeeRegistered
        ? (AppControllers.employee.employeeEntity?.email ?? '')
        : '';

    final bool sent =
        await ServicesNotificationService.notifyManagerOfPendingReview(
      senderEmail: senderEmail,
      managerEmail: currentApproverEmail!,
      serviceName: reminderServiceName,
      isArabic: isArabic,
    );

    if (!context.mounted) return;

    // ✅ CHANGED: was a ScaffoldMessenger SnackBar. Every other confirmation in
    // this app is a CustomDialogManager dialog, and a SnackBar was easy to miss
    // — it sits at the bottom of a long details page and disappears in two
    // seconds. Success uses showSuccess (auto-closes after ~1.5s); failure uses
    // showMessage, which stays open with an OK button so the user actually
    // reads that the reminder did NOT go out and can retry.
    //
    // NOTE: the success strings are plain, matching the hardcoded 'Breached
    // SLA' already in this file — there is no reminder-sent key in the .arb
    // yet. Worth moving all three into the .arb in the next localisation pass.
    if (sent) {
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
        title: S.of(context).SendReminder,
        subtitle: 'Reminder sent.',
      );
    } else {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
        title: S.of(context).warning,
        subtitle: S.of(context).errorOccuredPleaseTryAgain,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED 10/9/2026 — "My Request Details shows nothing but the title".
    //
    // The status box below asked for `width: double.infinity` in one branch
    // (phone, no reminder button) while sitting as a plain child of this Row.
    // A Row lays a non-flex child out with an UNBOUNDED width, so that became
    //
    //     BoxConstraints forces an infinite width.
    //     The offending constraints were: BoxConstraints(w=Infinity, h=38.6)
    //
    // thrown during `performLayout`. Everything under it then had no size, so
    // the page painted nothing below the frame's title row, and every frame
    // after threw `RenderBox was not laid out` followed by hundreds of
    // `'!semantics.parentDataDirty': is not true` — which is what filled the
    // console and buried this one line.
    //
    // "As wide as the row allows" is `Expanded`, not an infinite width: only a
    // flex child may claim the leftover space. The two SIZED branches (150 on a
    // phone beside the reminder, 200 elsewhere) are unchanged.
    final bool fillsRow = isMobile && !shouldShowReminder;

    final Widget statusBox = Container(
      // Null under `Expanded`: the parent hands down a tight width, and a
      // `width` here would fight it.
      width: fillsRow ? null : (isMobile ? 150.sp : 200.sp),
      height: 36.sp,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hasRejectionOrCancel
              ? Container(
                  width: 22.sp,
                  height: 22.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.red,
                  ),
                  child: Icon(
                    Icons.block_flipped,
                    color: AppColors.chatBackground,
                    size: 18,
                  ),
                )
              : SvgPicture.asset(
                  iconAsset,
                  width: 24.sp,
                  height: 24.sp,
                  fit: BoxFit.scaleDown,
                ),
          SizedBox(width: 8.w),
          Text(
            stateLabel,
            style: StyleText.fontSize16Weight500.copyWith(color: borderColor),
          ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        hasApprovalCycle && shouldShowReminder
            ? customButtonWithImage(
                title: isMobile ? S.of(context).reminder : S.of(context).SendReminder,
                function: () => _sendReminder(context),
                textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                width: isMobile ? 125.sp : 185.sp,
                height: 36.sp,
                space: 8.sp,
                radius: 8.r,
                color: AppColors.primary,
                image: "assets/icons_assets/home_assets/calendar_reminder_bell.svg",
                widthImage: 21.sp,
                heightImage: 21.sp,
                colorBorder: Colors.transparent,
              )
            : SizedBox(),
        if (shouldShowReminder) Spacer(),
        fillsRow ? Expanded(child: statusBox) : statusBox,
      ],
    );
  }
}

class MyRequestDateRibbon extends StatelessWidget {
  const MyRequestDateRibbon({
    super.key,
    required this.isMobile,
    required this.requestedTimestamp,
    required this.showBreachedSlaRibbon,
  });

  final bool isMobile;
  final int? requestedTimestamp;
  final bool showBreachedSlaRibbon;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(12.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "${S.of(context).requestedDate}: ",
                style: isMobile
                    ? StyleText.fontSize10Weight400.copyWith(
                        color: lightMode ? AppColors.secondaryText : AppColors.grey,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: lightMode ? AppColors.secondaryText : AppColors.grey,
                      ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(
                  requestedTimestamp != null
                      ? DateTime.fromMillisecondsSinceEpoch(requestedTimestamp!)
                      : DateTime.now(),
                ),
                style: isMobile
                    ? StyleText.fontSize10Weight400.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      )
                    : StyleText.fontSize12Weight400.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
              ),
            ],
          ),
        ),
        if (showBreachedSlaRibbon)
          Positioned(
            top: 12.h,
            left: -40.w,
            child: Transform.rotate(
              angle: -0.785398,
              child: Container(
                width: 160.w,
                color: AppColors.red,
                child: Row(
                  children: [
                    SizedBox(width: 30.w),
                    Text(
                      'Breached SLA',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
