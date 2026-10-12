
// ignore_for_file: deprecated_member_use
import 'package:get/get.dart';


import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract class GetDatePickerHelper {
  static Future<List<DateTime?>?> customDatePicker({
    required BuildContext context,
    CalendarDatePicker2Type? calenderType,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final isTablet = ContextExtension(context).isTablett;

    return showCalendarDatePicker2Dialog(
      context: context,
      dialogSize: isTablet ? Size(550.w, 390.h) : Size(365.w, 350.h),
      borderRadius: BorderRadius.circular(10.r),
      dialogBackgroundColor: AppColors.dialog,
      config: CalendarDatePicker2WithActionButtonsConfig(
        dayBuilder: ({
          required date,
          decoration,
          isDisabled,
          isSelected,
          isToday,
          textStyle,
        }) {
          return Center(
            child: Container(
              width: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isToday ?? false ? AppColors.primary : AppColors.transparent,
                ),
                borderRadius: BorderRadius.circular(8.r),
                color: isSelected ?? false
                    ? AppColors.primary
                    : AppColors.transparent,
              ),
              child: Text(
                FormDateTimeHelper.formatInt(date.day),
                style: isSelected ?? false
                    ? StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.textButton)
                    : StyleText.fontSize16Weight400,
              ),
            ),
          );
        },
        centerAlignModePicker: true,
        closeDialogOnCancelTapped: true,
        closeDialogOnOkTapped: true,
        firstDate: firstDate ?? DateTime(2022),
        lastDate: lastDate ?? DateTime(2090),
        calendarType: calenderType ?? CalendarDatePicker2Type.single,
        calendarViewMode: CalendarDatePicker2Mode.day,
        dayBorderRadius: BorderRadius.circular(8.r),
        yearBorderRadius: BorderRadius.circular(8.r),
        monthBorderRadius: BorderRadius.circular(8.r),
        hideMonthPickerDividers: true,
        hideYearPickerDividers: true,
        buttonPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 60.w : 25.w,
        ),
        customModePickerIcon: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
          ),
          child: SvgPicture.asset(
            AppAssets.arrowDown,
            color: AppColors.secondaryPrimary,
            width: isTablet ? 8.w : 8.w,
            height: isTablet ? 8.h : 8.h,
          ),
        ),
        okButton: Container(
          alignment: Alignment.center,
          height: isTablet ? 40.h : 30.h,
          width: isTablet ? 150.w : 120.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.primary,
          ),
          child: Text(
            S.current.setDate,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
              fontSize: isTablet ? 19.sp : 16.sp,
            ),
          ),
        ),
        cancelButton: Container(
          alignment: Alignment.center,
          height: isTablet ? 40.h : 30.h,
          width: isTablet ? 150.w : 120.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.darkWhiteShadow,
          ),
          child: Text(
            S.current.Cancel,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.textButton,
              fontSize: isTablet ? 19.sp : 16.sp,
            ),
          ),
        ),
        lastMonthIcon: Transform.rotate(
          angle: context.isArabic ? 3.14 : 0,
          child: SvgPicture.asset(
            AppAssets.arrowLeft,
            color: AppColors.primary,
            width: isTablet ? 24.w : 16.w,
            height: isTablet ? 24.h : 16.h,
          ),
        ),
        nextMonthIcon: Transform.rotate(
          angle: context.isArabic ? 0 : 3.14,
          child: SvgPicture.asset(
            AppAssets.arrowLeft,
            color: AppColors.primary,
            width: isTablet ? 24.w : 16.w,
            height: isTablet ? 24.h : 16.h,
          ),
        ),
        daySplashColor: AppColors.transparent,
        weekdayLabelTextStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryPrimary),
        controlsTextStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryPrimary),
        todayTextStyle: StyleText.fontSize16Weight400,
        dayTextStyle: StyleText.fontSize16Weight400,
        monthTextStyle: StyleText.fontSize16Weight400,
        yearTextStyle: StyleText.fontSize16Weight400,
        selectedDayHighlightColor: AppColors.primary,
        selectedRangeDayTextStyle:
            StyleText.fontSize16Weight400.copyWith(
          color: AppColors.textButton,
          fontSize: isTablet ? 19.sp : 16.sp,
        ),
        selectedRangeHighlightColor: AppColors.primary,
        selectedDayTextStyle: StyleText.fontSize16Weight400,
        selectedMonthTextStyle: StyleText.fontSize16Weight400,
        selectedYearTextStyle: StyleText.fontSize16Weight400,
        disabledDayTextStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.lightGrey),
        disabledMonthTextStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.lightGrey),
        disabledYearTextStyle: StyleText.fontSize16Weight400.copyWith(color: AppColors.lightGrey),
      ),
    );
  }
}
