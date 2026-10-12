/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: filters_appbar.dart
/// Purpose: Declares `FiltersAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :14/November/2023
// Objectives: this is a widget to customize the filters of the appbar
import 'dart:io';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class FiltersAppBar extends StatelessWidget {
  const FiltersAppBar(
      {super.key,
      required this.imageUrl,
      required this.title,
      this.hideIcon,
      this.iconColor,
      this.padding,
      this.titleLineHeight});
  final String imageUrl;
  final String title;
  final bool? hideIcon;
  final Color? iconColor;

  /// Overrides the header's own padding. Null keeps the historical
  /// `EdgeInsets.all(15.sp)`, so every existing caller is untouched.
  ///
  /// ADDED 15/8/2026 for compact dialogs that need to own the gap between the
  /// heading and the first field instead of inheriting a screen-sized one.
  final EdgeInsetsGeometry? padding;

  /// Overrides the title's line-height multiplier. Null keeps the historical
  /// 1.8 on tablet.
  ///
  /// 1.8 on a 28px title is a ~50px line box, so ~22px of leading is painted
  /// as empty space around the word. Invisible on a full screen; glaring
  /// inside a small dialog. Pass ~1.2 there.
  final double? titleLineHeight;

  double getIconSize(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;

    if (isDesktop && screenHeight >= 611 && screenHeight < 810) {
      return 0.8;
    } else if (isDesktop && screenHeight >= 810 && screenHeight < 900) {
      return 0.9;
    } else if (isDesktop && screenHeight >= 900 && screenHeight < 950) {
      return 1;
    } else if (isDesktop && screenHeight >= 950 && screenHeight < 1000) {
      return 1.2;
    } else if (isDesktop && screenHeight >= 1000) {
      return 1.3;
    }

    return 1.1;
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double screenHeight = MediaQuery.of(context).size.height;

    // Print the screen height
    return Padding(
      padding: padding ?? EdgeInsets.all(15.sp),
      child: Column(
        children: [
          Row(
            children: [

              CircleAvatar(
                      radius:
                         15.r,
                      backgroundColor: AppColors.primary,
                      child: Transform.scale(
                          scale: isDesktop
                              ? getIconSize(context)
                              : isTablet
                                  ? isPortrait
                                      ? (isLargeTablet ? 1 : 0.9)
                                      : (isLargeTablet ? 1 : 0.9)
                                  : 0.7,
                          child: SvgPicture.asset(
                            imageUrl,
                            width: 12.sp,
                            height: 12.sp,
                            color: AppColors.textButton,
                          )),
                    ),
              SizedBox(width: 8.sp),
              Text(
                title,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text
                ),
              ),
            ],
          ),
          SizedBox(height: 20.sp),
        ],
      ),
    );
  }
}
