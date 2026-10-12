// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_view_buttons.dart
// Purpose: Renders the HR employee list and grid view selection buttons.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/39-custom_grid_button.dart';
import '../../../../../../core/custom/40-custom_table_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../utils/enums/ui_controllers/hr_employee_view_mode.dart';

class HrEmployeeViewButtons extends StatelessWidget {
  const HrEmployeeViewButtons({
    required this.selectedMode,
    required this.onChanged,
    super.key,
  });

  final HrEmployeeViewMode selectedMode;
  final ValueChanged<HrEmployeeViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customTableButton(
          function: () => onChanged(HrEmployeeViewMode.table),
          isSelected: selectedMode == HrEmployeeViewMode.table,
          color: AppColors.card,
          selectedColor: AppColors.primary,
          svgColor: AppColors.text,
          selectedSvgColor: AppColors.textButton,
        ),
        SizedBox(width: 8.w),
        customGridButton(
          function: () => onChanged(HrEmployeeViewMode.grid),
          isSelected: selectedMode == HrEmployeeViewMode.grid,
          color: AppColors.card,
          selectedColor: AppColors.primary,
          svgColor: AppColors.text,
          selectedSvgColor: AppColors.textButton,
        ),
      ],
    );
  }
}
