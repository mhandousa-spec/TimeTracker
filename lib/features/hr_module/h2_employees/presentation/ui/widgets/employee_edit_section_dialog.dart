// ***************************** FILE INFO ***************************** //
// File Name: employee_edit_section_dialog.dart
// Purpose: Selects the employee section to edit from Employee Details.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/77-default_dialog.dart';
import '../../../../../../core/custom/77-default_dialog.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../h3_add_employee/utils/add_employee_step.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays the section selector used before opening employee edit mode.
class EmployeeEditSectionDialog extends StatefulWidget {
  const EmployeeEditSectionDialog({super.key});

  @override
  State<EmployeeEditSectionDialog> createState() =>
      _EmployeeEditSectionDialogState();
}

class _EmployeeEditSectionDialogState extends State<EmployeeEditSectionDialog> {
  AddEmployeeStep? _selected;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(500.sp, screenSize.width - 32.w);
    final optionsHeight = math.min(
      420.h,
      math.max(180.h, screenSize.height * 0.48),
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: DefaultDialog(
        autoClose: false,
        width: dialogWidth,
        customWidget: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      HRAssets.editDialogProfile,
                      width: 14.r,
                      height: 19.r,
                      colorFilter: ColorFilter.mode(
                        AppColors.text,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    localization.profileChange,
                    style: StyleText.fontSize20Weight600,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                localization.whichSectionDoYouWantToChange,
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryBlack),
              ),
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: optionsHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AddEmployeeStep.values.map(_buildOption).toList(),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: localization.discard,
                    color: AppColors.secondaryButton,
                    textStyle: StyleText.fontSize15Weight400,
                    function: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 12.w),
                  customButton(
                    title: localization.continueText,
                    color: _selected == null
                        ? AppColors.disabledGrey
                        : AppColors.primary,
                    textStyle: StyleText.fontSize15Weight400.copyWith(
                      color: AppColors.textButton,
                    ),
                    function: _selected == null
                        ? () {}
                        : () => Navigator.of(context).pop(_selected),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Method Name: [_buildOption]
  ///
  /// Purpose: Renders one selectable employee-edit section.
  ///
  /// Parameters:
  /// - [step]: Section represented by this radio option.
  ///
  /// Returns: A localized section selector row.
  Widget _buildOption(AddEmployeeStep step) {
    final isSelected = _selected == step;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: InkWell(
        onTap: () => setState(() => _selected = step),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Container(
                width: 13.r,
                height: 13.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.disabledGrey,
                          width: 2.r,
                        ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 4.5.r,
                          height: 4.5.r,
                          decoration: BoxDecoration(
                            color: AppColors.textButton,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(child: Text(step.title)),
          ],
        ),
      ),
    );
  }
}
