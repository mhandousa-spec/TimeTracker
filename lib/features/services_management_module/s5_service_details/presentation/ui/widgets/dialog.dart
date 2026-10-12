// ******************* FILE INFO *******************
// File Name: dialog
// Description: Dialog.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ShakeDialog extends StatefulWidget {
  final String lottiePath;
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const ShakeDialog({
    Key? key,
    required this.lottiePath,
    required this.title,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ShakeDialog> createState() => _ShakeDialogState();
}

class _ShakeDialogState extends State<ShakeDialog> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize shake animation controller
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create shake animation (moves left and right)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.easeInOut,
      ),
    );

    // Start shake animation when dialog appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shakeController.forward();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Dialog(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? AppColors.white
                : AppColors.chatBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 15.sp : 15.sp),
              child: SizedBox(
                width: 411.sp,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      widget.lottiePath,
                      width: 100.sp,
                      height: 100.sp,
                      fit: BoxFit.scaleDown,
                      repeat: true,
                      animate: true,
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      widget.title,
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        customButton(
                          title: S.of(context).no,
                          function: () => Navigator.pop(context),
                          textStyle: StyleText.fontSize18Weight500.copyWith(
                            color: AppColors.onSecondaryAction,
                          ),
                          width: isMobile ? 120.sp : 135.sp,
                          height: 38.sp,
                          radius: 4.r,
                          color: AppColors.secondaryAction,
                        ),
                        SizedBox(width: 28.sp),
                        customButton(
                          title: S.of(context).yes,
                          function: () {
                            Navigator.pop(context);
                            widget.onConfirm();
                          },
                          textStyle: StyleText.fontSize18Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          width: isMobile ? 120.sp : 135.sp,
                          height: 38.sp,
                          radius: 4.r,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

Future<void> showConfirmationDialogServicesDetails({
  required String lottiePath,
  required String title,
  required BuildContext context,
  required String message,
  required VoidCallback onConfirm,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => ShakeDialog(
      lottiePath: lottiePath,
      title: title,
      message: message,
      onConfirm: onConfirm,
    ),
  );
}

Future<void> showSuccessDialogServicesDetails({
  required String lottiePath,
  required String title,
  required BuildContext context,
  required String subtitle,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.white
          : AppColors.chatBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
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
              ),
              SizedBox(height: 20.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}