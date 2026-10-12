/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/knowledge_hub_date_time_picker.dart
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_date_time_picker.dart
/// Purpose: Date & time picker helpers for scheduling knowledge publishing.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

/// Brand-themed wrapper for the native [showTimePicker] dialog.
///
/// - Time display + AM/PM: SELECTED = [AppColors.textButton] on an
///   [AppColors.primary] background; UNSELECTED = [AppColors.text].
/// - Cancel (left) is a grey button, OK (right) is a primary button, so both
///   read as the app's buttons.
Widget themedKnowledgeTimePicker(BuildContext context, Widget? child) {
  MaterialStateColor sel(Color selected, Color unselected) =>
      MaterialStateColor.resolveWith(
        (states) =>
            states.contains(MaterialState.selected) ? selected : unselected,
      );

  return Theme(
    data: Theme.of(context).copyWith(
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.card,
        // Big hour : minute display.
        hourMinuteColor: sel(AppColors.primary, AppColors.field),
        hourMinuteTextColor: sel(AppColors.textButton, AppColors.text),
        // AM / PM.
        dayPeriodColor: sel(AppColors.primary, AppColors.field),
        dayPeriodTextColor: sel(AppColors.textButton, AppColors.text),
        dayPeriodBorderSide: BorderSide(color: AppColors.border),
        // Dial.
        dialHandColor: AppColors.primary,
        dialBackgroundColor: AppColors.field,
        dialTextColor: sel(AppColors.textButton, AppColors.text),
        entryModeIconColor: AppColors.text,
        helpTextStyle: TextStyle(color: AppColors.text),
        // Action buttons: Cancel (left) grey, OK (right) primary.
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.secondaryButton,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.textButton,
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

class KnowledgeHubDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;
  final bool lightMode;

  const KnowledgeHubDateTimePicker({
    Key? key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.lightMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        SizedBox(height: 4.h,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _DateField(
                date: date,
                onDateSelected: onDateSelected,
                lightMode: lightMode,
              ),
            ),
            SizedBox(width: 10.w,),
            Expanded(
              flex: 1,
              child: _TimeField(
                time: time,
                onTimeSelected: onTimeSelected,
                lightMode: lightMode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final Function(DateTime) onDateSelected;
  final bool lightMode;

  const _DateField({
    Key? key,
    required this.date,
    required this.onDateSelected,
    required this.lightMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: lightMode
              ? AppColors.background
              : AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 8.sp,
          vertical: 10.sp,
        ),
        child: Row(
          children: [
            Text(
              date == null ? 'DD/MM/YYYY' : DateFormat('dd/MM/yyyy').format(date!),
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            const Spacer(),
            CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
      log('Selected date: ${pickedDate.toString()}');
    }
  }
}

class _TimeField extends StatelessWidget {
  final TimeOfDay? time;
  final Function(TimeOfDay) onTimeSelected;
  final bool lightMode;

  const _TimeField({
    Key? key,
    required this.time,
    required this.onTimeSelected,
    required this.lightMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(
      time ?? TimeOfDay.now(),
      alwaysUse24HourFormat: true,
    );

    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: lightMode
              ? AppColors.background
              : AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.only(
          start: 8.w,
          end: 10.w,
          top: 10.w,
          bottom: 10.w,
        ),
        child: Row(
          children: [
            Text(
              time == null ? '00:00' : formattedTime,
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            const Spacer(),
            CustomSvgImage(
              assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_clock.svg',
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => themedKnowledgeTimePicker(context, child),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
      log('Selected time: ${pickedTime.format(context)}');
    }
  }
}