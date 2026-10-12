// ***************************** FILE INFO ***************************** //
// File Name: add_employee_preview_section.dart
// Purpose: Renders an expandable section in the editable employee preview.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders one initially expanded preview section.
class AddEmployeePreviewSection extends StatefulWidget {
  const AddEmployeePreviewSection({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  State<AddEmployeePreviewSection> createState() =>
      _AddEmployeePreviewSectionState();
}

class _AddEmployeePreviewSectionState extends State<AddEmployeePreviewSection> {
  bool _isExpanded = true;

  /// Method Name: [_toggle]
  ///
  /// Purpose: Expands or collapses this preview section without affecting others.
  ///
  /// Returns: Rebuilds this section with the opposite expanded state.
  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = Theme.of(context).brightness == Brightness.light
        ? AppColors.grey
        : AppColors.mediumGrey;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  RotatedBox(
                    quarterTurns: _isExpanded ? 2 : 0,
                    child: CustomSvgImage(
                      assetPath: AppAssets.arrowDown,
                      width: 22.sp,
                      height: 22.sp,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 16.h),
            widget.content,
          ],
        ],
      ),
    );
  }
}
