/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: dashed_icon_container.dart
/// Purpose: Declares `DashedIconContainer`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:dotted_border/dotted_border.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

class DashedIconContainer extends StatelessWidget {
  final String svgAssetPath;
  final VoidCallback? onMinusTap;
  final Color dashColor;
  final Color backgroundColor;
  final double? width;
  final double? height;

  const DashedIconContainer({
    required this.svgAssetPath,
    this.onMinusTap,
    this.dashColor = const Color(0xFFFFC107),
    this.backgroundColor = const Color(0xFFFFF8E1),
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dashed border container
        DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: dashColor,
            strokeWidth: 3.sp,
            dashPattern: const [15, 10],
            radius: Radius.circular(8.r),
          ),
          child: Container(
            width: width ?? 120.w,
            height: height ?? 120.h,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgAssetPath,
                width: 26.sp,
                fit: BoxFit.fill,
                height: 26.sp,
                color: AppColors.textButton,
              ),
            ),
          ),
        ),

        // Minus button in top-right corner
        Positioned(
          top: -3.h,
          right: -4.w,
          child: GestureDetector(
            onTap: onMinusTap,
            child: Container(
              width: 15.w,
              height: 15.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 15.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}