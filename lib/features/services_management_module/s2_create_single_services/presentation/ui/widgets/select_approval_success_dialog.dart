// ******************* FILE INFO *******************
// File Name: select_approval_success_dialog
// Description: Select approval success dialog.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************

// In: lib/features/services_management_module/s2_create_single_services/presentation/ui/widgets/select_approval_success_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

class SuccessDialogMaster extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  final String? lottiePath;

  const SuccessDialogMaster({
    Key? key,
    required this.title,
    required this.message,
    this.onDismiss,
    this.lottiePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      // ✅ Matches CustomDialogManager (57_custom_dialog_manager.dart): 500.sp
      // wide, 24.r padding, radius 8.r. This dialog sized itself to its own
      // text, so the "Draft Service" success came out visibly narrower than
      // every other confirmation dialog in the flow it belongs to.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
        width: 500.sp,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              lottiePath ?? 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
              width: 80.w,
              height: 80.h,
              repeat: false,
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: StyleText.fontSize20Weight500.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () {
               // Navigator.pop(context);
                onDismiss?.call();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  S.of(context).ok,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}