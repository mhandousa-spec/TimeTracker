/// Module: form_builder_module/core
///
/// FILE INFO
/// File Name   : form_filter_dialog.dart
/// Objective   : Filter dialog of the Form Builder home list (bug report #11 —
///               the Filter button did nothing because
///               `AppDialogs.filterDialog` was an empty stub). Same shape as
///               the Knowticed Admin filter dialogs: header, fields, Reset
///               (darkGrey / white) and Apply. Filters by Access Management
///               and Published Date, using the filter state HomeCubit already
///               had (`currentDropDownValue`, `currentDate`, `setFilter`,
///               `reset`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';

class FormFilterDialog extends StatefulWidget {
  const FormFilterDialog({super.key, required this.cubit});

  final HomeCubit cubit;

  static Future<void> show(BuildContext context, HomeCubit cubit) {
    return showDialog<void>(
      context: context,
      builder: (_) => FormFilterDialog(cubit: cubit),
    );
  }

  @override
  State<FormFilterDialog> createState() => _FormFilterDialogState();
}

class _FormFilterDialogState extends State<FormFilterDialog> {
  static const List<String> _accessValues = <String>[
    'Open Access',
    'Restricted Access',
    'Personal Access',
  ];

  late String? _access = widget.cubit.currentDropDownValue;
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.isArabic;
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: 520.sp,
        padding: EdgeInsets.all(15.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15.sp,
                  backgroundColor: AppColors.primary,
                  child: SvgPicture.asset(
                    AppAssets.filter,
                    width: 16.sp,
                    height: 16.sp,
                    colorFilter:
                        ColorFilter.mode(AppColors.textButton, BlendMode.srcIn),
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(isAr ? 'تصفية' : 'Filter',
                    style: StyleText.fontSize16Weight500),
              ],
            ),
            SizedBox(height: 15.sp),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    label: isAr ? 'إدارة الوصول' : 'Access Management',
                    hint: isAr ? 'اختر هنا' : 'Choose Here',
                    value: _access,
                    height: 38,
                    fillColor: AppColors.background,
                    items: [
                      for (final String v in _accessValues)
                        DropdownItem<String>(
                          value: v,
                          label: AccessManagementExtension.labelFor(v),
                        ),
                    ],
                    onChanged: (String v) => setState(() => _access = v),
                  ),
                ),
                SizedBox(width: 15.sp),
                Expanded(
                  child: CustomDropdownCalendar(
                    label: isAr ? 'تاريخ النشر' : 'Published Date',
                    // Bug report p.33: pinned to the dropdown's 38 so the two
                    // boxes in this row are the same height.
                    height: 38,
                    fillColor: AppColors.background,
                    value: _date,
                    hint: isAr ? 'اختر التاريخ' : 'Choose The Date',
                    onChanged: (DateTime? d) => setState(() => _date = d),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.sp),
            Row(
              children: [
                customButton(
                  title: isAr ? 'إعادة تعيين' : 'Reset',
                  color: AppColors.darkGrey,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.white),
                  function: () => widget.cubit.reset(context),
                ),
                const Spacer(),
                customButton(
                  title: isAr ? 'تطبيق' : 'Apply',
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.textButton),
                  function: () {
                    widget.cubit.onChangeFilterDropDownValue(_access);
                    widget.cubit.onChangeDateValue(
                        _date == null ? null : FormDateTimeHelper.formatDate(_date!));
                    // setFilter pops this dialog itself.
                    widget.cubit.setFilter(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
