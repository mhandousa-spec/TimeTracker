// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_filter_dialog.dart
// Purpose: Displays and submits HR employee filter criteria.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/3-custom_dropdwon_calander.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../presentation/controller/cubit/hr_employee_cubit.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'hr_filter_dialog_title.dart';

/// Filter dialog for department, job title, and employee first-login date.
class HrEmployeeFilterDialog extends StatefulWidget {
  const HrEmployeeFilterDialog({super.key});

  @override
  State<HrEmployeeFilterDialog> createState() => _HrEmployeeFilterDialogState();
}

class _HrEmployeeFilterDialogState extends State<HrEmployeeFilterDialog> {
  String? _departmentId;
  String? _jobTitle;
  DateTime? _startDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filters = context.read<HrEmployeeCubit>().state.filters;
    _departmentId ??= filters.departmentId;
    _jobTitle ??= filters.jobTitle;
    _startDate ??= filters.startDate;
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final cubit = context.read<HrEmployeeCubit>();
    final fieldColor = Theme.of(context).scaffoldBackgroundColor;
    final departmentOptions = cubit.departmentOptions(isEnglish);
    final jobTitleOptions = cubit.jobTitleOptions(isEnglish);

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
              Wrap(
                spacing: 16.w,
                runSpacing: 16.h,
                children: [
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdown<String>(
                      value: _departmentId,
                      hint: localization.department,
                      items: departmentOptions
                          .map(
                            (option) => DropdownItem<String>(
                              value: option.value,
                              label: option.label,
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _departmentId = value),
                      fillColor: fieldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdown<String>(
                      value: _jobTitle,
                      hint: localization.jobTitle,
                      items: jobTitleOptions
                          .map(
                            (option) => DropdownItem<String>(
                              value: option.value,
                              label: FormatHelper.capitalize(option.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _jobTitle = value),
                      fillColor: fieldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdownCalendar(
                      value: _startDate,
                      hint: localization.startDate,
                      onChanged: (value) => setState(() => _startDate = value),
                      fillColor: fieldColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: localization.reset,
                    function: () {
                      cubit.resetFilters();
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
                      cubit.applyFilters(
                        EmployeeFilterModel(
                          departmentId: _departmentId,
                          jobTitle: _jobTitle,
                          startDate: _startDate,
                        ),
                      );
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
