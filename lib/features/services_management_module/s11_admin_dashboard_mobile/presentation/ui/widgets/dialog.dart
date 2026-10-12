// ******************* FILE INFO *******************
// File Name: dialog
// Description: Dialog.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final double? width;
  final double? lottieSize;

  const CustomConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.confirmText = 'Yes',
    this.cancelText = 'No',
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.titleStyle,
    this.messageStyle,
    this.width,
    this.lottieSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: SizedBox(
          width: width ?? 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lottieAsset != null) ...[
                Lottie.asset(
                  lottieAsset!,
                  width: lottieSize ?? 70.sp,
                  height: lottieSize ?? 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: titleStyle ??
                    StyleText.fontSize20Weight500.copyWith(
                      color: AppColors.text
                    ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: messageStyle ??
                    StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText
                    ),
              ),
              SizedBox(height: 20.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customButton(
                    title: FormatHelper.capitalize(cancelText),
                    function: onCancel ?? () => Navigator.pop(context, false),
                    textStyle: StyleText.fontSize15Weight400.copyWith(color: AppColors.onSecondaryAction),
                    width: 120.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: cancelButtonColor ?? AppColors.secondaryAction,
                  ),
                  SizedBox(width: 15.sp),
                  customButton(
                    title: FormatHelper.capitalize(confirmText),
                    function: onConfirm ?? () => Navigator.pop(context, true),
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                    width: 120.sp,
                    height: 38.sp,
                    radius: 4.r,
                    color: confirmButtonColor ?? AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Static method for easy usage
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? lottieAsset,
    String confirmText = 'Yes',
    String cancelText = 'No',
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    double? width,
    double? lottieSize,
    bool barrierDismissible = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomConfirmationDialog(
        title: title,
        message: message,
        lottieAsset: lottieAsset,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
        width: width,
        lottieSize: lottieSize,
      ),
    );
    return result == true;
  }
}


/// Call this to open the dialog:
/// final result = await showConfirmationDialog(context, lottiePath: 'assets/lottie_assets/main_lottie_assets/question.json', title: '...', message: '...');
/// if (result == true) { /* user tapped Yes */ }
Future<bool?> showSuccessMaster(
    BuildContext context, {
      required String lottiePath,
      required String title,
      required String message,
      VoidCallback? onConfirm,   // optional: action to run when user confirms
      VoidCallback? onCancel,    // optional: action to run when user cancels
      bool barrierDismissible = true,
    })
{
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => ConfirmationDialog(
      lottiePath: lottiePath,
      title: title,
      message: message,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );
}

class ConfirmationDialog extends StatelessWidget {
  final String lottiePath;
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    super.key,
    required this.lottiePath,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: SizedBox(
          width: 411.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottiePath,
                width: 70.sp,
                height: 70.sp,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
