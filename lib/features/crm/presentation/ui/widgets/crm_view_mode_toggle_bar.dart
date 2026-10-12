// ****************** FILE INFO ******************
// File Name: crm_view_mode_toggle_bar.dart
// Purpose: General reusable CRM view mode toggle toolbar (Grid / Table switchers with optional export, compare, requests, and trailing actions)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class CrmViewModeToggleBar extends StatelessWidget {
  final bool isGridView;
  final ValueChanged<bool> onViewModeChanged;
  final List<Widget> leadingChildren;
  final List<Widget> trailingActions;
  final bool showExport;
  final VoidCallback? onExport;
  final bool showSwitchers;
  final Color? unselectedColor;
  final Color? selectedColor;

  const CrmViewModeToggleBar({
    super.key,
    required this.isGridView,
    required this.onViewModeChanged,
    this.leadingChildren = const <Widget>[],
    this.trailingActions = const <Widget>[],
    this.showExport = false,
    this.onExport,
    this.showSwitchers = true,
    this.unselectedColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveUnselected = unselectedColor ?? AppColors.white;
    final Color effectiveSelected = selectedColor ?? AppColors.primary;

    return Row(
      mainAxisAlignment: leadingChildren.isNotEmpty
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: <Widget>[
        // Left Actions
        if (leadingChildren.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: leadingChildren,
          ),

        // Right Actions (Custom Actions + Export + Grid/Table switchers)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...trailingActions,
            if (showExport) ...<Widget>[
              if (trailingActions.isNotEmpty) SizedBox(width: 8.sp),
              customButtonWithSvg(
                title: 'Export',
                function: onExport ?? () {},
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                color: AppColors.primary,
                image: AppAssets.export,
                svgColor: AppColors.black,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: AppColors.transparent,
              ),
            ],
            if (showSwitchers) ...<Widget>[
              if (trailingActions.isNotEmpty || showExport)
                SizedBox(width: 8.sp),
              customGridButton(
                isSelected: isGridView,
                color: effectiveUnselected,
                selectedColor: effectiveSelected,
                function: () => onViewModeChanged(true),
              ),
              SizedBox(width: 6.sp),
              customTableButton(
                isSelected: !isGridView,
                color: effectiveUnselected,
                selectedColor: effectiveSelected,
                function: () => onViewModeChanged(false),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
