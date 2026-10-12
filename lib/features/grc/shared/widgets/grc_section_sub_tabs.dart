import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Small pill toggle shown at the top-right of a Details page's bottom
/// section — e.g. "Submission | Inquires" (Assignment Controls) or
/// "Approvals | Inquires". "Inquires" is always a placeholder today; the
/// full comment-thread feature is a separate, future spec.
class GrcSectionSubTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const GrcSectionSubTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          InkWell(
            onTap: () => onChanged(i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: selected == i ? AppColors.primary : null,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                labels[i],
                style: StyleText.fontSize12Weight400.copyWith(
                  color: selected == i ? AppColors.textButton : AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
