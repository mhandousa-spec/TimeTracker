// ***************************** FILE INFO ***************************** //
// File Name: shift_management_department_filter_dialog.dart
// Purpose: Filters Shift Management employees by department.
// Author: Mohamed Elrashidy
// Created At: 2026-08-24
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../h2_employees/presentation/ui/widgets/hr_filter_dialog_title.dart';

/// Shows the department-only filter used by Shift Management.
class ShiftManagementDepartmentFilterDialog extends StatefulWidget {
  const ShiftManagementDepartmentFilterDialog({
    required this.items,
    required this.selectedDepartmentId,
    required this.onApply,
    super.key,
  });

  final List<DropdownItem<String>> items;
  final String? selectedDepartmentId;
  final ValueChanged<String?> onApply;

  @override
  State<ShiftManagementDepartmentFilterDialog> createState() =>
      _ShiftManagementDepartmentFilterDialogState();
}

class _ShiftManagementDepartmentFilterDialogState
    extends State<ShiftManagementDepartmentFilterDialog> {
  late String? _departmentId = widget.selectedDepartmentId;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final fieldColor = Theme.of(context).scaffoldBackgroundColor;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 645.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HrFilterDialogTitle(),
              SizedBox(height: 20.h),
              CustomDropdown<String>(
                value: _departmentId,
                hint: localization.department,
                items: widget.items,
                onChanged: (value) => setState(() => _departmentId = value),
                fillColor: fieldColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: localization.reset,
                    function: () {
                      widget.onApply(null);
                      Navigator.of(context).pop();
                    },
                    color: AppColors.secondaryButton,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  customButton(
                    title: localization.apply,
                    function: () {
                      widget.onApply(_departmentId);
                      Navigator.of(context).pop();
                    },
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
