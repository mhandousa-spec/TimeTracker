/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: success_dialog.dart
/// Purpose: Declares `SuccessDialog`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Success/result dialog.
///
/// Used as a *widget* — `SuccessDialog(title:, subtitle:, lottieAsset:)` — so it
/// cannot delegate to CustomDialogManager, whose helpers are imperative
/// (`Future<void>` calls that invoke `showDialog` internally and therefore
/// can't be returned from `build`). The presentation below was inlined from the
///
/// For imperative call sites use `CustomDialogManager.showMessage` (persistent)
/// or `CustomDialogManager.showSuccess` (auto-dismisses) instead.
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });

  final String title;
  final String subtitle;
  final String lottieAsset;

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.current.success),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.current.ok2),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet
              ? isPortrait
                  ? 150.w
                  : 310.w
              : 40.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.field, borderRadius: BorderRadius.circular(8)),
        width: 500.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Transform.scale(
                scale: isTablet
                    ? isPortrait
                        ? 1.5
                        : 0.8
                    : 1,
                child: Lottie.asset(
                  lottieAsset,
                  width: isTablet
                      ? isPortrait
                          ? 140.w
                          : 150.w
                      : 110.w,
                  fit: BoxFit.fitHeight,
                ),
              ),
              Text(title,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize18Weight500),
              SizedBox(
                  height: isTablet
                      ? isPortrait
                          ? 20.h
                          : 10.h
                      : 10.h),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack)
                      .copyWith(height: 1.4)),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}
