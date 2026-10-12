/// Module: GRC Policy Management
/// Description: Department multi-select + Equal Weights section for the
///              Add/Edit Control form (Edit mode only), extracted from
///              AddEditControlPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: flutter, flutter_switch, CustomMultiSelectDropdown,
///               CustomTextField
/// Revision History: 2026-07-15 - Initial creation (inline in
///                                add_edit_control_page.dart)
///                   2026-07-27 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_departments_section_widget.dart
/// Purpose: Contains ControlDepartmentsSectionWidget, the Department
///          multi-select and per-department weight rows. All selection
///          reconciliation logic (checking "All", equal-split, adding or
///          removing a department) stays on AddEditControlPage — this
///          widget is a pure display/toggle layer that reports every
///          interaction back via callbacks.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [ControlDepartmentsSectionWidget]
///
/// purpose: renders the Department multi-select next to the Equal Weights
///          toggle. Checking "All" (or every real department individually)
///          selects every department and locks Equal Weights on, since an
///          all-department split is always equal. Otherwise Equal Weights
///          is user-controlled: on auto-splits 100 across the selection,
///          off shows an editable weight row per selected department with
///          a running total below (highlighted in red until it sums to
///          100).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class ControlDepartmentsSectionWidget extends StatelessWidget {
  final String allDepartmentsValue;
  final List<String> availableDepartmentNames;
  final List<String> selectedDepartments;
  final List<String> realSelectedDepartments;
  final bool isAllDepartmentsSelected;
  final bool equalWeights;
  final Map<String, TextEditingController> departmentWeightControllers;
  final double totalDepartmentsWeight;
  final bool isDepartmentsWeightValid;
  final bool submitted;
  final void Function(List<String> newSelection) onDepartmentsChanged;
  final ValueChanged<bool> onEqualWeightsChanged;
  final ValueChanged<String> onRemoveDepartment;

  const ControlDepartmentsSectionWidget({
    super.key,
    required this.allDepartmentsValue,
    required this.availableDepartmentNames,
    required this.selectedDepartments,
    required this.realSelectedDepartments,
    required this.isAllDepartmentsSelected,
    required this.equalWeights,
    required this.departmentWeightControllers,
    required this.totalDepartmentsWeight,
    required this.isDepartmentsWeightValid,
    required this.submitted,
    required this.onDepartmentsChanged,
    required this.onEqualWeightsChanged,
    required this.onRemoveDepartment,
  });

  /// function name: [_buildDepartmentWeightRow]
  ///
  /// purpose: render a single selected department's name alongside its
  ///          weight field and a control to remove it from the selection.
  ///          The weight field is editable while Equal Weights is off, and
  ///          read-only (showing the auto-computed equal share) while it's
  ///          on — hidden entirely only when "All" is selected instead.
  ///
  /// parameters:
  ///            [String] department: the department name this row represents
  ///
  /// return type: [Widget] - the row widget for this department
  Widget _buildDepartmentWeightRow(BuildContext context, String department) {
    // 768 / 1024 split the row evenly. At 375 an even split leaves the
    // department name in ~145 logical px and truncates it, so the design
    // gives the name twice the width of the weight box.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      // GRC bug report p18 ("same height"):
      //  * the name box was 40.h against the weight field's 38 — both are 38
      //    now, the app's field height;
      //  * the remove icon used to sit OUTSIDE both halves and squeezed them,
      //    so this row's split did not line up with the fields above it. It
      //    now lives inside the right half, next to the weight field.
      child: Row(
        children: [
          Expanded(
            flex: isMobile ? 2 : 1,
            child: Container(
              height: 38.sp,
              alignment: AlignmentDirectional.centerStart,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                department,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.text),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hint: '0',
                    height: 38,
                    controller: departmentWeightControllers[department],
                    fillColor: AppColors.background,
                    readOnly: equalWeights,
                    onChanged: equalWeights ? null : (_) {},
                  ),
                ),
                SizedBox(width: 4.w),
                IconButton(
                  icon: Icon(Icons.remove_circle,
                      color: AppColors.red, size: 20.sp),
                  onPressed: () => onRemoveDepartment(department),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 768 / 1024 put the Department multi-select and the Equal Weights
    // toggle side by side. At 375 the design stacks them: dropdown full
    // width, toggle on the line under it.
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final Widget departmentDropdown = CustomMultiSelectDropdown<String>(
      label: S.of(context).department,
      hint: S.of(context).selectDepartment,
      items: [
        MultiSelectDropdownItem<String>(
            value: allDepartmentsValue, label: S.of(context).all),
        ...availableDepartmentNames.map(
          (d) => MultiSelectDropdownItem<String>(value: d, label: d),
        ),
      ],
      values: selectedDepartments,
      onChanged: onDepartmentsChanged,
      fillColor: AppColors.background,
      errorText: submitted && realSelectedDepartments.isEmpty
          ? S.of(context).thisFieldIsRequired
          : null,
    );

    final Widget equalWeightsToggle = Row(
      children: [
        Text(
          S.of(context).equalWeights,
          style:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        Spacer(),
        FlutterSwitch(
          width: 38.sp,
          height: 22.sp,
          padding: 3.sp,
          borderRadius: 20.sp,
          toggleSize: 16.sp,
          activeColor: AppColors.secondaryPrimary,
          inactiveColor: Colors.grey.withValues(alpha: 0.16),
          value: equalWeights,
          onToggle: onEqualWeightsChanged,
        ),
      ],
    );

    final Widget totalWeightBadge = Container(
            width: 160.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDepartmentsWeightValid
                    ? AppColors.border
                    : AppColors.red,
              ),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${S.of(context).totalWeight} : ${totalDepartmentsWeight.toStringAsFixed(0)}',
              style: StyleText.fontSize14Weight500.copyWith(
                color: isDepartmentsWeightValid ? AppColors.text : AppColors.red,
              ),
            ),
          );

    // The badge and its validation message hug the trailing edge at 375,
    // matching the design; they stay leading-aligned at 768 / 1024.
    final CrossAxisAlignment totalAlignment =
        isMobile ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile) ...[
          departmentDropdown,
          SizedBox(height: 15.h),
          equalWeightsToggle,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: departmentDropdown),
              SizedBox(width: 10.w),
              Expanded(child: equalWeightsToggle),
            ],
          ),
        if (realSelectedDepartments.isNotEmpty && !isAllDepartmentsSelected) ...[
          SizedBox(height: 15.h),
          ...realSelectedDepartments
              .map((d) => _buildDepartmentWeightRow(context, d)),
          // width: infinity so CrossAxisAlignment.end actually reaches the
          // trailing edge -- a bare Column shrink-wraps to the 160.w badge
          // and has nothing to align against.
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: totalAlignment,
              children: [
                totalWeightBadge,
                if (!isDepartmentsWeightValid) ...[
                  SizedBox(height: 4.h),
                  Text(
                    S.of(context).totalWeightShouldBe100,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.red),
                    textAlign: isMobile ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
