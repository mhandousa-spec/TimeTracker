/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_error_dialog.dart
/// Purpose: The "could not submit" dialog shown when a request fails.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N05. This 60-line inline `Dialog` was duplicated
/// verbatim in `preview_changes_page.dart` and
/// `se4/preview_health_changes_page.dart`, both with a hardcoded `'Error'`
/// title, a hardcoded `'Close'` button and the raw exception text interpolated
/// into the body. One copy now, localized, and the raw failure text is no
/// longer put in front of the user.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract class RequestErrorDialog {
  /// Function Name: [show]
  ///
  /// Purpose: Present the failure dialog over [context].
  static Future<void> show(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor:
            lightMode ? AppColors.white : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(height: 20.sp),
                Text(
                  S.of(context).error,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color:
                        lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).errorOccurred,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color:
                        lightMode ? AppColors.secondaryText : AppColors.grey,
                  ),
                ),
                SizedBox(height: 15.sp),
                customButton(
                  title: S.of(context).Done,
                  function: () => Navigator.pop(dialogContext),
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 135.sp,
                  height: 38.sp,
                  radius: 4.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
