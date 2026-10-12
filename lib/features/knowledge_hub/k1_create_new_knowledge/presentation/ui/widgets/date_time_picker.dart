/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/date_time_picker.dart
/// ************************* FILE INFO *************************** ///
/// File Name: date_time_picker.dart
/// Purpose: Widget for selecting date and time with validation
/// Author: Youssef Khaled
/// Updated: Allow same day selection with time validation

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import './knowledge_hub_date_time_picker.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
class DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool lightMode;
  final DateTime? minDate; // Minimum selectable date
  final DateTime? maxDate; // Maximum selectable date
  final bool isEndDate; // Flag to identify if this is an end date picker
  final DateTime? startDate; // ✅ Pass start date for validation
  final TimeOfDay? startTime; // ✅ Pass start time for validation

  const DateTimePicker({
    super.key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.lightMode,
    this.minDate,
    this.maxDate,
    this.isEndDate = false,
    this.startDate,
    this.startTime,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    // ✅ Determine first date based on context
    DateTime firstDate;
    if (isEndDate && minDate != null) {
      // End date can be same day as start date
      firstDate = DateTime(
        minDate!.year,
        minDate!.month,
        minDate!.day,
      );
    } else {
      // For start date, use provided minDate or default to today
      firstDate = minDate ?? today;
    }

    // ✅ Use your custom DatePicker class
    final datePicker = DatePicker();
    final List<DateTime?>? pickedDates = await datePicker.showDatePicker(
      context,
      [date ?? firstDate], // Initial selected date as list
      date ?? firstDate, // Current date
      CalendarDatePicker2Type.single, // Single date selection
      firstDate: firstDate, // Pass minimum selectable date
    );

    // ✅ Handle the selected date
    if (pickedDates != null && pickedDates.isNotEmpty && pickedDates[0] != null) {
      onDateSelected(pickedDates[0]!);
    }
  }

  // ✅ Helper to check if two dates are the same day
  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ✅ Helper to convert TimeOfDay to minutes for comparison
  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // ✅ Validate if selected time is valid for end date
  bool _isValidEndTime(TimeOfDay selectedTime) {
    // If not end date, or no start date/time set, allow any time
    if (!isEndDate || startDate == null || startTime == null) {
      return true;
    }

    // If end date is NOT the same day as start date, allow any time
    if (!_isSameDay(date, startDate)) {
      return true;
    }

    // If end date IS the same day, time must be AFTER start time
    return _timeToMinutes(selectedTime) > _timeToMinutes(startTime!);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time ?? TimeOfDay.now(),
      builder: (context, child) => themedKnowledgeTimePicker(context, child),
    );

    if (picked != null) {
      // ✅ Validate time if this is end date on same day
      if (isEndDate && _isSameDay(date, startDate)) {
        if (!_isValidEndTime(picked)) {
          await showDialog(
            context: context,
            builder: (dialogContext) => _buildErrorDialog(dialogContext),
          );
          return; // Don't set invalid time
        }
      }

      onTimeSelected(picked);
    }
  }

  // ✅ Build error dialog
  Widget _buildErrorDialog(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: AppColors.transparent,
      child: Material(
        color: AppColors.transparent,
        child: Container(
          width: isMobile ? double.infinity : 411.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode
                ? AppColors.white
                : AppColors.background,
          ),
          padding: EdgeInsets.all(20.r),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                height: 70.h,
                width: 70.w,
              ),
              SizedBox(height: 20.h),
              Text(
                S.of(context).endDateMustBeAfterStartDate,
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: lightMode
                        ? AppColors.background
                        : AppColors.background,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Directionality(
                    textDirection: Directionality.of(context),
                    child: Row(
                      children: [
                        Directionality(
                          textDirection: Directionality.of(context),
                          child: Text(
                            date != null
                                ? DateFormat('dd MMM yyyy').format(date!)
                                : S.of(context).selectdate,
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: lightMode
                                  ? AppColors.secondaryText
                                  : AppColors.grey,
                            ),
                          ),
                        ),
                        Spacer(),
                        CustomSvgImage(
                            assetPath: "assets/icons_assets/main_icons_assets/images_Calendar.svg",
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.fill,
                            color: AppColors.secondaryText
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).time,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: () => _selectTime(context),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: lightMode
                        ? AppColors.background
                        : AppColors.background,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    children: [
                      Text(
                        time != null
                            ? time!.format(context)
                            : S.of(context).selectdate,
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                      Spacer(),
                      CustomSvgImage(
                          assetPath: "assets/icons_assets/knowledge_hub_assets/KnowledgeClock .svg",
                          width: 20.w,
                          height: 20.h,
                          fit: BoxFit.fill,
                          color: AppColors.secondaryText
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}