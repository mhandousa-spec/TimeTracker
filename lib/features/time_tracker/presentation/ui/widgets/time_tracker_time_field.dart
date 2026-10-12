/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_time_field.dart
/// Purpose: Declares `TimeTrackerTimeField` — the "Choose Time 🕒" field
///          (12-hour, localized) that opens the platform time picker.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// The core has no time-picker field (core/custom has date pickers only), so
/// this is the module twin of To-Do's time field, drawn like the core date
/// field next to it: 36 high, grey fill (`kDropdownFillColor`), radius 4,
/// hint in `kDropdownHintColor`, value 12 regular, clock icon 16 at the end.
/// Times read "09:00 AM" (`hh:mm a`, owner rule) in both languages.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class TimeTrackerTimeField extends StatelessWidget {
  const TimeTrackerTimeField({
    super.key,
    required this.value,
    required this.hint,
    required this.onPicked,
    this.hasError = false,
  });

  final TimeOfDay? value;
  final String hint;
  final ValueChanged<TimeOfDay> onPicked;
  final bool hasError;

  Future<void> _pick(BuildContext context) async {
    HapticController.low();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TimeOfDay? time = value;
    final String text = time == null
        ? hint
        : LocalizedDate.of(
            context,
            DateTime(2000, 1, 1, time.hour, time.minute),
            pattern: 'hh:mm a',
          );
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        height: 36.sp,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 8.sp),
        decoration: BoxDecoration(
          color: kDropdownFillColor,
          borderRadius: BorderRadiusDirectional.circular(4.r),
          border: hasError ? Border.all(color: AppColors.red) : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: time == null ? kDropdownHintColor : AppColors.text,
                ),
              ),
            ),
            CustomSvgImage(
              assetPath: AppAssets.timeSelectorIcon,
              width: 16.sp,
              height: 16.sp,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}
