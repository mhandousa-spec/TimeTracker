/// A single Policy/Control assignment pill used across GRC champion/owner
/// pages. Read-only when [onRemove] is null (details pages); shows a
/// remove icon when [onRemove] is provided (edit/reassign pages).
/// Extracted because both variants were copy-pasted 3x each on the
/// champion side and 3x each on the owner side.
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcAssignmentChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  /// Read-only chips default to the card colour (they sit on the grey page);
  /// pass [AppColors.background] when the chip sits inside a white card.
  final Color? backgroundColor;

  const GrcAssignmentChip({
    super.key,
    required this.label,
    this.onRemove,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (onRemove == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          FormatHelper.capitalize(label),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            FormatHelper.capitalize(label),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(width: 6.w),
          // The app's own red minus-circle, not a Material glyph.
          GestureDetector(
            onTap: onRemove,
            child: CustomSvgImage(
              assetPath: CardSvg.remove,
              width: 14.sp,
              height: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
