/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_search_and_filter.dart
/// Purpose: Declares `AccessSearchAndFilter`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';

class AccessSearchAndFilter extends StatefulWidget {
  AccessSearchAndFilter({super.key});

  @override
  State<AccessSearchAndFilter> createState() => _AccessSearchAndFilterState();
}

class _AccessSearchAndFilterState extends State<AccessSearchAndFilter> {
  late UserManagementAccessCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Row(
          spacing: 10.sp,
          children: [
            AppSearchTextField(
              controller: controller.addNewSearchController,
              onChanged: (value) {
                controller.filterEmployeesToGiveAccess(value);
              },
            ),
          // Role QA p.6: phones had no way to filter the employee list (the
          // department dropdown is too wide for the row). A 38×38 Filter
          // button opens the same department filter in a dialog.
          context.isPhone ? _filterButton(context) : _buildDepartment(context)
          ],
        ),
      ],
    );
  }

  Widget _filterButton(BuildContext context) {
    final bool active = controller.addNewAccessDepartmentId != null;
    return GestureDetector(
      onTap: () => _openFilterDialog(context),
      child: Container(
        height: 38.sp,
        width: 38.sp,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/filter_sliders.svg',
            width: 15.sp,
            height: 15.sp,
            color: active ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterDialog(BuildContext context) async {
    String? picked = controller.addNewAccessDepartmentId;
    final cubit = controller;
    final departments = context.read<MainCoreDepartmentCubit>();

    void apply(String? value) {
      cubit.addNewAccessDepartmentId = value;
      cubit.filterEmployeesToGiveAccess(cubit.addNewSearchController.text);
      if (mounted) setState(() {});
    }

    await CustomDialogManager.showContent<void>(
      context: context,
      width: 300.sp,
      child: StatefulBuilder(
        builder: (dialogContext, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15.sp,
                  backgroundColor: AppColors.primary,
                  child: CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.of(dialogContext).Filter,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.text),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            CustomDropdown<String>(
              label: S.of(dialogContext).select_department,
              hint: S.of(dialogContext).department,
              value: picked,
              fillColor: AppColors.background,
              height: 36,
              items: departments.departmentIds
                  .map((String id) => DropdownItem<String>(
                        value: id,
                        label: FormatHelper.capitalize(dialogContext.isArabic
                            ? departments
                                    .getArabicDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                ''
                            : departments
                                    .getEnglishDepartmentNameFromDepartmentId(
                                        departmentId: id) ??
                                ''),
                      ))
                  .toList(),
              onChanged: (value) => setDialogState(() => picked = value),
              required: false,
            ),
            SizedBox(height: 15.sp),
            Row(
              children: [
                Expanded(
                  child: customButton(
                    fullWidth: true,
                    color: AppColors.secondaryButton,
                    textStyle: StyleText.fontSize16Weight500
                        .copyWith(color: AppColors.blackButton),
                    title: S.of(dialogContext).reset,
                    function: () {
                      setDialogState(() => picked = null);
                      apply(null);
                    },
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: customButton(
                    fullWidth: true,
                    title: S.of(dialogContext).Save,
                    function: () {
                      apply(picked);
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartment(BuildContext context) {
    final departmentItems = context
        .read<MainCoreDepartmentCubit>()
        .departmentIds
        .map((String department) => department)
        .toList();

    // WIDTH 8/9/2026: the phone width was 120.sp, which is narrower than the
    // "Select Department" hint, so the trigger wrapped it onto two lines. 180.sp
    // fits it on one. The search field beside it is `Expanded`, so it simply
    // takes whatever is left.
    final width = ContextExtension(context).isTablet ? 200.sp : 180.sp;

    return SizedBox(
      width: width,
      child: CustomDropdown<String>(
        hint: context.isArabic ? S.of(context).department : 'Select Department',
        items: departmentItems.map((department) {
          final label = FormatHelper.capitalize(
            context.isArabic
                ? context
                        .read<MainCoreDepartmentCubit>()
                        .getArabicDepartmentNameFromDepartmentId(
                            departmentId: department) ??
                    ''
                : context
                        .read<MainCoreDepartmentCubit>()
                        .getEnglishDepartmentNameFromDepartmentId(
                            departmentId: department) ??
                    '',
          );
          return DropdownItem<String>(value: department, label: label);
        }).toList(),
        value: controller.addNewAccessDepartmentId,
        triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
        borderRadius: BorderRadius.circular(8.r),
        onChanged: (value) {
          if (controller.addNewAccessDepartmentId == value) {
            controller.addNewAccessDepartmentId = null;
          } else {
            controller.addNewAccessDepartmentId = value;
          }
          controller.filterEmployeesToGiveAccess(
              controller.addNewSearchController.text);
          setState(() {});
        },
        fillColor: AppColors.card,
        hintStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText.withOpacity(.7),
        ),
        itemStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.text,
        ),
        required: false,
      ),
    );
  }
}
