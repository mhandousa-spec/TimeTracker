/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_calendar_picker.dart
/// Purpose: Declares `CustomCalendarPicker`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 29/8/2026 - Month navigation uses the app's own chevron assets.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/models/calendar_date_picker2_config.dart';
import 'package:knowticed_plus/core/extensions/calendar_package/src/widgets/calendar_date_picker2.dart';


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

// ignore: must_be_immutable
class CustomCalendarPicker extends StatefulWidget {
  CustomCalendarPicker(
      {super.key,
      this.firstDate,
      required this.calendarType,
      this.isReviewJob = false,
      this.isHome = false,
      required this.selectedDate,
      required this.selectedDateState});
  final CalendarDatePicker2Type calendarType;
  DateTime? firstDate;
  List<DateTime?> selectedDate;
  ValueChanged<List<DateTime?>> selectedDateState;
  bool? isReviewJob;
  bool? isHome;

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  List<DateTime> selectedDate = [DateTime.now()];

  @override
  Widget build(BuildContext context) {
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double isReviewJob =
        isPortrait ? FontConstants.fontSize016.h : FontConstants.fontSize024.h;
    return CalendarDatePicker2(
      isHome: widget.isHome!,
      config: CalendarDatePicker2Config(
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: DateTime(2100),
        rangeBidirectional: true,
        calendarViewMode: DatePickerMode.day,
        centerAlignModePicker: true,
        dayBorderRadius: BorderRadius.circular(8),
        // EDIT 29/8/2026: month navigation used `arrow_back_curved.svg` — the
        // curved BACK arrow — flipped 180° to stand in for "next". The app has
        // a matched pair of plain chevrons; they are used here, and picked by
        // direction rather than rotated, so neither arrow is a mirror image of
        // the other's asset.
        //
        // The package positions these two by physical side, not by reading
        // order, so in Arabic "previous month" is the arrow on the RIGHT —
        // which is why the pair swaps with the locale.
        lastMonthIcon: _monthArrow(
          context.isEnglish
              ? 'assets/icons_assets/main_icons_assets/chevron_left.svg'
              : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
        ),
        nextMonthIcon: _monthArrow(
          context.isEnglish
              ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
              : 'assets/icons_assets/main_icons_assets/chevron_left.svg',
        ),
        weekdayLabelTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w600,
          color: AppColors.switchSettings,
        ),
        controlsTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : FontConstants.fontSize015.w,
            fontWeight: FontWeight.w600,
            color: AppColors.switchSettings,
            height: 1.45),
        selectedYearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : FontConstants.fontSize015.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onInverseSurface),
        selectedDayHighlightColor: AppColors.switchSettings,
        dayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : widget.isHome == true
                    ? FontConstants.fontSize013.w
                    : (FontConstants.fontSize023.h),
            height: widget.isReviewJob == true
                ? 1.6
                : widget.isHome == true
                    ? (isLargeTablet ? 1.7 : 1.6)
                    : 0,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.inverseSurface),
        selectedDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : widget.isHome == true
                  ? FontConstants.fontSize013.w
                  : FontConstants.fontSize023.h,
          fontWeight: FontWeight.w500,
          height:
              widget.isReviewJob == true ? 1.6 : (isLargeTablet ? 1.7 : 1.6),
          color: AppColors.textButton,
        ),
        selectedRangeDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w500,
          color: AppColors.colorWhite,
          height: 0.0019.h,
        ),
        yearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        todayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : widget.isHome == true
                  ? FontConstants.fontSize013.w
                  : FontConstants.fontSize023.h,
          fontWeight: FontWeight.w500,
          height: isLargeTablet ? 1.6 : 1.6,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        selectedRangeHighlightColor: AppColors.bubbleColor,
        customModePickerIcon: Container(),
        calendarType: widget.calendarType,
      ),
      value: widget.selectedDate,
      onValueChanged: ((value) {
        setState(() {
          widget.selectedDate = value;
          widget.selectedDateState(widget.selectedDate);
        });
      }),
    );
  }

  /// One month-navigation chevron. The two assets differ slightly in intrinsic
  /// size, so both are drawn into the same box with `BoxFit.contain` to keep
  /// the pair visually identical.
  Widget _monthArrow(String assetPath) => SvgPicture.asset(
        assetPath,
        height: 16,
        width: 16,
        fit: BoxFit.contain,
        // ignore: deprecated_member_use
        color: AppColors.lightPrimary,
      );
}
