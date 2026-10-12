// ***************************** FILE INFO ***************************** //
// File Name: certifications_filter_dialog.dart
// Purpose: Filters certification rows by shared employee criteria.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/3-custom_dropdwon_calander.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/certifications_cubit.dart';
import '../../../utils/ui_controllers_models/employee_filter_model.dart';
import 'hr_filter_dialog_title.dart';

/// Applies the employee filters used by the Certifications table.
class CertificationsFilterDialog extends StatefulWidget {
  const CertificationsFilterDialog({super.key});

  @override
  State<CertificationsFilterDialog> createState() =>
      _CertificationsFilterDialogState();
}

class _CertificationsFilterDialogState
    extends State<CertificationsFilterDialog> {
  String? _departmentId;
  String? _jobTitle;
  DateTime? _startDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final filters = context.read<CertificationsCubit>().state.filters;
    _departmentId ??= filters.departmentId;
    _jobTitle ??= filters.jobTitle;
    _startDate ??= filters.startDate;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CertificationsCubit>();
    final localization = S.of(context);
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
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
                Wrap(spacing: 16.w, runSpacing: 16.h, children: [
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdown<String>(
                      value: _departmentId,
                      hint: localization.department,
                      items: cubit
                          .departmentOptions(isEnglish)
                          .map((item) => DropdownItem(
                              value: item.value, label: item.label))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _departmentId = value),
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdown<String>(
                      value: _jobTitle,
                      hint: localization.jobTitle,
                      items: cubit
                          .jobTitleOptions()
                          .map((item) => DropdownItem(
                              value: item.value, label: item.label))
                          .toList(),
                      onChanged: (value) => setState(() => _jobTitle = value),
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  SizedBox(
                    width: 290.w,
                    child: CustomDropdownCalendar(
                      value: _startDate,
                      hint: localization.startDate,
                      onChanged: (value) => setState(() => _startDate = value),
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ]),
                SizedBox(height: 24.h),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customButton(
                        title: localization.reset,
                        function: () {
                          cubit.resetFilters();
                          Navigator.pop(context);
                        },
                        color: AppColors.secondaryButton,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.text),
                      ),
                      customButton(
                        title: localization.apply,
                        function: () {
                          cubit.applyFilters(EmployeeFilterModel(
                            departmentId: _departmentId,
                            jobTitle: _jobTitle,
                            startDate: _startDate,
                          ));
                          Navigator.pop(context);
                        },
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500
                            .copyWith(color: AppColors.textButton),
                      ),
                    ]),
              ]),
        ),
      ),
    );
  }
}
