/// Module: GRC shared widgets
/// Description: A label + switch row in the GRC house style (the same
///              FlutterSwitch look as "Equal Weights" on the control form).
///
/// ADDED 28/9/2026 for the switches the GRC bug report asks for:
///   p2 — "Give score" on Add Control Owner
///   p4 — "Reassign … without request" on the reassign forms
///   p5 — dashboard visibility / department switching on the Departments tab
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class GrcLabeledSwitch extends StatelessWidget {
  final String label;

  /// Optional one-line explanation under the label.
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const GrcLabeledSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
              if (description != null && description!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  description!,
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 12.w),
        FlutterSwitch(
          width: 38.sp,
          height: 22.sp,
          padding: 3.sp,
          borderRadius: 20.sp,
          toggleSize: 16.sp,
          activeColor: AppColors.secondaryPrimary,
          inactiveColor: Colors.grey.withValues(alpha: 0.16),
          value: value,
          disabled: onChanged == null,
          onToggle: onChanged ?? (_) {},
        ),
      ],
    );
  }
}
