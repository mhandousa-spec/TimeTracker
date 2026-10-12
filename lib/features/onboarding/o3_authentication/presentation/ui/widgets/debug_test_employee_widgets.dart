/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: debug_test_employee_widgets.dart
/// Purpose: DEBUG-ONLY entry points of the "Switch to test employee" sign-in:
///          the Sign In screen button, the header avatar menu (tablet /
///          desktop), the More page row (phone), the header badge, and
///          [openDebugTestEmployeeSwitch] which they all call.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 - DEBUG-ONLY (owner-approved option B; see
///            data/utils/debug_test_employee_switch.dart)
///
/// Every call site builds these behind `if (kDebugTestEmployeeSwitchBuild)`
/// — a compile-time constant (`kDebugMode && !kReleaseMode && !kProfileMode`)
/// — so in release / profile they and the picker are tree-shaken. Each widget
/// also checks [isDebugTestEmployeeSwitchEnabled] and renders nothing (or its
/// plain child) when it is false.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/data/utils/debug_test_employee_switch.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/debug_test_employee_switch_screen.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/pages/sign_in_screen.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [openDebugTestEmployeeSwitch]
///
/// Purpose: DEBUG-ONLY 9/10/2026 — open the test-employee picker.
///
/// From the Sign In screen ([signOutFirst] false) the picker is pushed on top.
/// From inside the app ([signOutFirst] true) the user confirms, the session is
/// signed out exactly like the drawer's Log Out (system-log entry, every route
/// removed, back on SignInScreen), and the picker opens over the sign-in
/// screen. The real hand-over (old listeners cancelled, new session loaded)
/// happens when a test employee is tapped — see
/// `LoginController.debugSignInAsTestEmployee`.
///
/// Parameters:
/// - [context]: a mounted context under the app navigator.
/// - [signOutFirst]: sign the current session out before opening.
///
/// Returns: [Future<void>]
Future<void> openDebugTestEmployeeSwitch(BuildContext context,
    {bool signOutFirst = false}) async {
  if (!isDebugTestEmployeeSwitchEnabled()) return;
  HapticController.low();
  final NavigatorState navigator = Navigator.of(context, rootNavigator: true);

  if (!signOutFirst) {
    await navigator.push(MaterialPageRoute<void>(
        builder: (_) => const DebugTestEmployeeSwitchScreen()));
    return;
  }

  final S s = S.of(context);
  await CustomDialogManager.showDialogFlow(
    context: context,
    confirmLottie: 'assets/lottie_assets/home_lottie_assets/newLogOut.json',
    confirmTitle: s.debugSwitchToTestEmployee,
    confirmSubtitle: s.debugTestEmployeeConfirmSwitch,
    confirmYesText: s.yes,
    confirmNoText: s.Cancel,
    onConfirm: () async {
      HapticController.high();
      if (Get.isRegistered<SystemLogsController>()) {
        Get.find<SystemLogsController>().systemLogsAction('logout');
      }
      return true;
    },
    // Same as Log Out: the sign-in screen appearing is the confirmation.
    showSuccessDialog: false,
    successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
    successTitle: s.logout,
    successSubtitle: s.signedOutSuccessfully,
    onSuccessComplete: () {
      if (!navigator.mounted) return;
      DebugTestEmployeeSession.end();
      navigator.pushAndRemoveUntil(
        PageTransition<void>(
          type: PageTransitionType.fade,
          child: const SignInScreen(),
        ),
        (Route<dynamic> route) => false,
      );
      navigator.push(MaterialPageRoute<void>(
          builder: (_) => const DebugTestEmployeeSwitchScreen()));
    },
  );
}

/// DEBUG-ONLY 9/10/2026 — the small "🧪 Test employee" button under Sign In.
class DebugTestEmployeeSignInButton extends StatelessWidget {
  const DebugTestEmployeeSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDebugTestEmployeeSwitchEnabled()) return const SizedBox.shrink();
    return Center(
      child: GestureDetector(
        key: const ValueKey<String>('debugTestEmployeeSignIn'),
        behavior: HitTestBehavior.opaque,
        onTap: () => openDebugTestEmployeeSwitch(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            S.of(context).debugTestEmployeeButton,
            style: StyleText.fontSize12Weight600
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

/// DEBUG-ONLY 9/10/2026 — "DEBUG: test employee" badge for the header, shown
/// only while the session came from the debug switch. [compact] shows the
/// icon alone (narrow title rows); the email is in the tooltip.
class DebugTestEmployeeBadge extends StatelessWidget {
  const DebugTestEmployeeBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!isDebugTestEmployeeSwitchEnabled()) return const SizedBox.shrink();
    return ValueListenableBuilder<String?>(
      valueListenable: DebugTestEmployeeSession.activeEmail,
      builder: (BuildContext context, String? email, _) {
        if (email == null) return const SizedBox.shrink();
        final String label = S.of(context).debugTestEmployeeBadge;
        return Tooltip(
          message: email,
          child: Container(
            key: const ValueKey<String>('debugTestEmployeeBadge'),
            padding: EdgeInsets.symmetric(
                horizontal: compact ? 6.sp : 8.sp, vertical: 4.sp),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: Text(
              compact ? '🧪' : '🧪 $label',
              maxLines: 1,
              style: StyleText.fontSize12Weight600
                  .copyWith(color: AppColors.text),
            ),
          ),
        );
      },
    );
  }
}

/// DEBUG-ONLY 9/10/2026 — turns the header avatar (tablet / desktop) into a
/// menu with one item, "🧪 Switch to test employee".
class DebugTestEmployeeAvatarMenu extends StatelessWidget {
  const DebugTestEmployeeAvatarMenu({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDebugTestEmployeeSwitchEnabled()) return child;
    final String label = S.of(context).debugSwitchToTestEmployee;
    return PopupMenuButton<int>(
      key: const ValueKey<String>('debugTestEmployeeAvatarMenu'),
      tooltip: label,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onOpened: HapticController.low,
      onSelected: (_) =>
          openDebugTestEmployeeSwitch(context, signOutFirst: true),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            label,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
      ],
      child: child,
    );
  }
}

/// DEBUG-ONLY 9/10/2026 — "🧪 Switch to test employee" row for the phone More
/// page, styled like the Sign Out row under it.
class DebugSwitchToTestEmployeeTile extends StatelessWidget {
  const DebugSwitchToTestEmployeeTile({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isDebugTestEmployeeSwitchEnabled()) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.card,
      ),
      child: InkWell(
        key: const ValueKey<String>('debugSwitchToTestEmployeeTile'),
        splashColor: AppColors.transparent,
        onTap: () => openDebugTestEmployeeSwitch(context, signOutFirst: true),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Icon(Icons.science_outlined,
                  size: 20.sp, color: AppColors.primary),
            ),
            SizedBox(width: 16.h),
            Expanded(
              child: Text(
                S.of(context).debugSwitchToTestEmployee,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize020.h,
                  color: AppColors.text,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
