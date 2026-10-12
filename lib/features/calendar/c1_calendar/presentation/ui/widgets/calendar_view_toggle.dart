/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_view_toggle.dart
/// Purpose: Month / week / day view switch.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N13: `package:get` removed; colours routed through AppColors.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Month/day view toggle, extracted from calendar_screen.dart.
class CalendarViewToggle extends StatelessWidget {
  final bool isMonthView;
  final VoidCallback onToggle;
  final String dayText;
  final String monthText;
  final Color activeColor;
  final Color inactiveColor;
  /// Nullable because [AppColors.white] is a theme-dependent *getter*, not a
  /// `const`, so it cannot be a default parameter value. Resolved at build
  /// time via [resolvedTextActiveColor], which also keeps it theme-reactive.
  final Color? textActiveColor;
  final Color textInactiveColor;

  const CalendarViewToggle({
    Key? key,
    required this.isMonthView,
    required this.onToggle,
    this.dayText = 'Day',
    this.monthText = 'Month',
    required this.activeColor,
    this.inactiveColor = AppColors.fieldFillLight,
    this.textActiveColor,
    this.textInactiveColor = AppColors.colorBlack,
  }) : super(key: key);

  /// The active-label colour, falling back to the current theme's white.
  Color get resolvedTextActiveColor => textActiveColor ?? AppColors.white;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 240.w,
        height: 40.h,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isMonthView ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 116.w,
                height: 36,
                margin: EdgeInsets.all(2.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      dayText,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: isArabic ? isMonthView ? AppColors.textButton : AppColors.text : !isMonthView ? AppColors.textButton : AppColors.text,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      monthText,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: isArabic ?!isMonthView ? AppColors.textButton : AppColors.text : isMonthView ? AppColors.textButton : AppColors.text,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
