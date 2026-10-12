/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: apply_all_modules_button.dart
/// Purpose: Home card that runs `DemoAccountsSeeder.applyAll` — every
///          notification and every calendar event of every module, for the
///          four demo accounts.
/// Author: Knowticed Plus team
/// Created at: 27/9/2026
///
/// Visible only to the demo accounts themselves (and always in debug builds),
/// so a real tenant never sees it. Confirm → run → success / error dialog
/// through `CustomDialogManager`; no SnackBar.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/demo_accounts_seeder.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ApplyAllModulesButton extends StatefulWidget {
  const ApplyAllModulesButton({super.key, this.onApplied});

  /// Called after a run that wrote anything — Home uses it to reload the
  /// calendar so the new entries show straight away.
  final VoidCallback? onApplied;

  /// Whether the signed-in user should see the button.
  static bool get isVisible {
    if (kDebugMode) return true;
    final String? email =
        Get.find<MainCoreEmployeeController>().employeeEntity?.email;
    return DemoAccountsSeeder.isDemoAccount(email);
  }

  @override
  State<ApplyAllModulesButton> createState() => _ApplyAllModulesButtonState();
}

class _ApplyAllModulesButtonState extends State<ApplyAllModulesButton> {
  bool _running = false;

  static const String _confirmLottie =
      'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json';
  static const String _successLottie =
      'assets/lottie_assets/main_lottie_assets/lottie_approved.json';
  static const String _errorLottie =
      'assets/lottie_assets/main_lottie_assets/lottie_rejected.json';

  Future<void> _onTap() async {
    if (_running) return;
    final bool en = context.isEnglish;

    DemoSeedResult? result;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: _confirmLottie,
      confirmTitle: en ? 'Apply all modules' : 'تطبيق جميع الوحدات',
      confirmSubtitle: en
          ? 'Send every notification and add every calendar event of every '
              'module to the ${DemoAccountsSeeder.accounts.length} demo accounts?'
          : 'إرسال جميع الإشعارات وإضافة جميع أحداث التقويم لكل الوحدات إلى '
              '${DemoAccountsSeeder.accounts.length} حسابات تجريبية؟',
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        setState(() => _running = true);
        try {
          result = await DemoAccountsSeeder.applyAll(
            senderEmail: Get.find<MainCoreEmployeeController>()
                    .employeeEntity
                    ?.email ??
                DemoAccountsSeeder.accounts.last,
            isArabic: !en,
          );
        } catch (e, stackTrace) {
          debugPrint('[demo-seed] threw — $e\n$stackTrace');
        } finally {
          if (mounted) setState(() => _running = false);
        }
        final DemoSeedResult? r = result;
        if (r == null || r.isTotalFailure) {
          if (mounted) {
            await CustomDialogManager.showMessage(
              context: context,
              lottiePath: _errorLottie,
              title: S.of(context).warning,
              subtitle: S.of(context).errorOccuredPleaseTryAgain,
            );
          }
          return false;
        }
        widget.onApplied?.call();
        return true;
      },
      successLottie: _successLottie,
      successTitle: en ? 'Applied' : 'تم التطبيق',
      successSubtitle: en
          ? 'Notifications and calendar events were added to all modules.'
          : 'تمت إضافة الإشعارات وأحداث التقويم لجميع الوحدات.',
    );

    // Partial run: say what did not go through instead of pretending.
    final DemoSeedResult? r = result;
    if (mounted && r != null && !r.isFullSuccess && !r.isTotalFailure) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: _errorLottie,
        title: S.of(context).warning,
        subtitle: en
            ? 'Notifications: ${r.notificationsSent}/${r.notificationsAttempted}\n'
                'Calendar: ${r.calendarEventsWritten}/${r.calendarEventsAttempted}'
            : 'الإشعارات: ${r.notificationsSent}/${r.notificationsAttempted}\n'
                'التقويم: ${r.calendarEventsWritten}/${r.calendarEventsAttempted}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool en = context.isEnglish;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.sp,
              backgroundColor: AppColors.primary,
              child: _running
                  ? SizedBox(
                      width: 22.sp,
                      height: 22.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.textButton,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/icons_assets/main_icons_assets/notification_bell.svg',
                      width: 24.sp,
                      height: 24.sp,
                      colorFilter: ColorFilter.mode(
                          AppColors.textButton, BlendMode.srcIn),
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    en ? 'Apply all modules' : 'تطبيق جميع الوحدات',
                    style: StyleText.fontSize16Weight500,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _running
                        ? (en ? 'Applying…' : 'جارٍ التطبيق…')
                        : (en
                            ? 'All notifications & calendar events for the demo accounts'
                            : 'جميع الإشعارات وأحداث التقويم للحسابات التجريبية'),
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.icon),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
