/// Module: GRC shared widgets
/// Description: Text tabs with a primary underline under the selected one —
///              the same look as Role Management's
///              "Role Management / User Management / User Access" tabs
///              (roles/r1_role_management/.../role_screen.dart).
///
/// ADDED 28/9/2026 for GRC bug report p3 (Approvals: Reassign / Evidence /
/// Give Score), which asks for exactly that treatment.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class GrcUnderlineTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const GrcUnderlineTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 32.sp,
        children: [
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (i != selected) onChanged(i);
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      labels[i],
                      style: StyleText.fontSize20Weight500.copyWith(
                        height: 1.3,
                        color: i == selected
                            ? AppColors.primary
                            : AppColors.secondaryBlack,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 1.5.sp,
                      color: i == selected
                          ? AppColors.primary
                          : AppColors.transparent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
