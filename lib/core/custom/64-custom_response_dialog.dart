/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: response_dialog.dart
/// Purpose: Declares `ResponseDialog`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:lottie/lottie.dart';
class ResponseDialog extends StatelessWidget {
  const ResponseDialog({
    Key? key,
    required this.subtitle,
    required this.title,
    required this.lottieAsset,
  }) : super(key: key);

  final String subtitle;
  final String title;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
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
                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                    height: 1.4
                  )
              ),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}
