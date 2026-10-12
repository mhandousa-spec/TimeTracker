// ****************** FILE INFO ******************
// File Name: crm_activity_status_dropdown.dart
// Purpose: Status dropdown button with color coding for activity view mode (exact 38.sp button height)
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmActivityStatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const CrmActivityStatusDropdown({
    super.key,
    required this.currentStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.sp,
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      decoration: BoxDecoration(
        color: statusColor(currentStatus),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          isDense: true,
          style: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.white,
            fontSize: 14.sp,
          ),
          dropdownColor: AppColors.white,
          icon: Padding(
            padding: EdgeInsets.only(left: 6.sp),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.black,
              size: 18.sp,
            ),
          ),
          items: const <String>[
            'scheduled',
            'in_progress',
            'completed',
            'cancelled',
          ]
              .map((String s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(
                      statusLabel(s),
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (String? v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  static String statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'scheduled':
      case 'schedules':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return s;
    }
  }

  static Color statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'scheduled':
      case 'schedules':
        return AppColors.blue;
      case 'in_progress':
        return AppColors.orange;
      case 'completed':
        return AppColors.green;
      case 'cancelled':
        return AppColors.red;
      default:
        return AppColors.grey;
    }
  }
}
