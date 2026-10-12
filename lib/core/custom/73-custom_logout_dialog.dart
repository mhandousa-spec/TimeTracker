// ignore_for_file: deprecated_member_use
/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_logout_dialog.dart
/// Purpose: Declares `CustomLogOutDialogBox`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/core/custom/5-custom_button.dart';

import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
class CustomLogOutDialogBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color backgroundColor;
  final bool showButtons;

  /// Label for the confirm button.
  ///
  /// FIXED 22/8/2026: this was a non-null `String` defaulting to the literal
  /// `'Delete'`, and the one call site (custom_drawer.dart) passed the literal
  /// `'Yes'`. Neither went through `S.of(context)`, so in the Arabic UI the
  /// confirm button read "Yes" next to an Arabic "إلغاء". It is nullable now
  /// and falls back to the localized `yes` string, which is resolved in
  /// [build] where a BuildContext exists.
  final String? buttonText;
  final Color buttonFontColor;
  final Color buttoncolor;
  final VoidCallback? onConfirm;

  const CustomLogOutDialogBox({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.backgroundColor,
    required this.showButtons,
    this.buttonText,
    this.buttoncolor = Colors.black,
    this.buttonFontColor = Colors.white,
    this.onConfirm,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        width: isTablet? (isPortrait? 0.7.w : 0.45.w) : null, 
        padding:   EdgeInsets.all(isTablet?20 : 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              imagePath,
              width: isPortrait? .09.h : 0.15.h,
              height: isPortrait? .09.h : 0.15.h,
            ),
           
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S.of(context).logout,
                     textAlign: TextAlign.center,
                      style: StyleText.fontSize20Weight500.copyWith(
                          color: AppColors.text
                      )
                  ),
                  SizedBox(height: .02.h),
                  Text(
                    S.of(context).confirmLogout,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight500.copyWith(
                      color: AppColors.secondaryText
                    )
                  ),
                ],
              ),
            ),
            if (showButtons)
              Padding(
                padding: EdgeInsets.only(top:isTablet? (isPortrait? 0.025.h : 0.03.h) : 0.01.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: customButton(
                        title: S.of(context).Cancel,
                        function: () {
                          hapticController.triggerHapticFeedback(
                            vibration: VibrateType.lightImpact,
                            hapticFeedback: HapticFeedback.lightImpact,
                          );
                          Navigator.pop(context, false);
                        },
                        // Was a raw `Colors.black`, which disappears against
                        // the grey fill in dark mode (§12 — no raw Colors.*).
                        textStyle: StyleText.fontSize18Weight500.copyWith(
                            color: AppColors.onSecondaryAction
                        ),
                        color: AppColors.secondaryAction,
                        height: 38.sp, // Match the original height
                      ),
                    ),
                    SizedBox(
                      width: 0.04.w,
                    ),
                    Expanded(
                      child: customButton(
                        title: buttonText ?? S.of(context).yes,
                        function: onConfirm!,

                        textStyle: StyleText.fontSize18Weight500.copyWith(
                          color: AppColors.textButton
                        ),
                        color: AppColors.primary,
                        height: 38.sp, // Match the original height
                      ),
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
