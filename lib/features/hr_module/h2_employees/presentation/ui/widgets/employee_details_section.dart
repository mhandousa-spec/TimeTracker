// ***************************** FILE INFO ***************************** //
// File Name: employee_details_section.dart
// Purpose: Provides an expandable section for employee detail content.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders one collapsible employee-detail section.
class EmployeeDetailsSection extends StatefulWidget {
  const EmployeeDetailsSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    super.key,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<EmployeeDetailsSection> createState() => _EmployeeDetailsSectionState();
}

/// Maintains only the expanded state for one visual detail section.
class _EmployeeDetailsSectionState extends State<EmployeeDetailsSection> {
  late bool _isExpanded = widget.initiallyExpanded;

  /// Method Name: [_toggle]
  ///
  /// Purpose: Toggles the visibility of the detail section body.
  ///
  /// Returns: Rebuilds this section with its updated expanded state.
  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(4.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.mediumGrey
                    : AppColors.secondaryBlack,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: StyleText.fontSize16Weight400.copyWith(color: Colors.white),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.white,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}
