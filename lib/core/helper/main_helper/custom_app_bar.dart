/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_app_bar.dart
/// Purpose: Declares `CustomAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/messaging_package/core/configs/extensions/extensions.dart';


/// Date: 29/9/2024
/// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
/// Last update: 29/9/2024
/// Objectives: This file is responsible for building a common custom app bar between several services_management_module.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? actionWidget;
  final TextStyle? textStyle;
  final Widget? leadingIcon;
  final bool? centerTitle;
  final bool? paddedLeading;
  final Widget? mainLeadingIcon;
  final bool hideLeading;
  final double? titleSpace;

  /// Horizontal inset of the title row (already scaled). Null keeps the
  /// original 10.sp. Pass 0 to line the title up with the page content.
  final double? titleHorizontalPadding;

  /// Space above the title (already scaled). Null keeps the original
  /// 15.sp padding + 30.sp gap.
  final double? topPadding;
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.textStyle,
    this.actionWidget,
    this.leadingIcon,
    this.mainLeadingIcon,
    this.centerTitle,
    this.paddedLeading,
    this.hideLeading = false,
    this.titleSpace,
    this.titleHorizontalPadding,
    this.topPadding,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.sp, top: topPadding ?? 15.sp),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            if (topPadding == null) SizedBox(height: 30.sp),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: titleHorizontalPadding ?? 10.sp),
              child: Row(
                spacing: 15.sp,
                children: [
                  if (!hideLeading)
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Transform.rotate(
                          angle: context.isArabic ? -3.14 : 0,
                          child: SvgPicture.asset(
                            "assets/icons_assets/main_icons_assets/chevron_down.svg",
                            color: AppColors.text,
                            width: 20.sp,
                            height: 20.sp,
                          ),
                        )),
                  Text(
                    title,
                    style: textStyle ??
                        (StyleText.fontSize20Weight600
                            .copyWith(fontSize: 24.sp,color: AppColors.text)),
                    overflow: TextOverflow.ellipsis,
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
