/// Module: knowledge_hub / presentation / s8_dashboard / widgets/department_filter.dart
/// ************************* FILE INFO *************************** ///
/// File Name: department_filter.dart
/// Purpose: Department filter — Dashboard (S8) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/56-custom_services_multi_select.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget buildDepartmentFilterDropdown({
  required BuildContext context,
  required List<DepartmentModelPro> departments,
  required List<String> selectedDepartments, // ✅ Changed to List<String>
  required Function(List<String>) onChanged, // ✅ Changed to return List
  required bool lightMode,
}) {
  var isArabic = Get.locale.toString().contains('ar');
  var isMobile = ContextExtension(context).isPhone;

  // Check current locale
  final isEnglish = Get.locale.toString().contains('en');

  // Build department items list (just the display names)
  List<String> departmentItems = [
    S.of(context).all ?? 'All Departments',
    ...departments.map((dept) {
      return isEnglish
          ? (FormatHelper.capitalize(dept.departmentName!) ?? '')
          : (dept.departmentNameInArabic ?? '');
    }).toList(),
  ];

  // Build display text for selected items
  String displayText = selectedDepartments.isEmpty
      ? (S.of(context).select_department ?? 'Select Departments')
      : selectedDepartments.length == 1
      ? selectedDepartments.first
      : '${selectedDepartments.length} ${S.of(context).selected ?? 'selected'}';

  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      AppMultiSelectDropdown(

        forceDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        items: departmentItems,
        selectedItems: selectedDepartments,
        textButton: displayText,
        hintText: S.of(context).select_department ?? 'Select Departments',
        width: isMobile ? 200.w : 300.w,
        height: 36,
        fillColor: lightMode ? AppColors.white : AppColors.chatBackground,
        textStyle: StyleText.fontSize12Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
        onChanged: (item) {
          // Handle "All Departments" selection
          if (item == (S.of(context).all ?? 'All Departments')) {
            if (selectedDepartments.contains(item)) {
              // If "All" is being deselected, clear everything
              onChanged([]);
            } else {
              // If "All" is being selected, select all departments
              onChanged([item, ...departmentItems.where((d) => d != item)]);
            }
            return;
          }

          // Handle individual department selection
          List<String> updatedList = List.from(selectedDepartments);

          // Remove "All" if it was selected
          updatedList.remove(S.of(context).all ?? 'All Departments');

          if (updatedList.contains(item)) {
            updatedList.remove(item);
          } else {
            updatedList.add(item);
          }

          onChanged(updatedList);
        },
      ),
    ],
  );
}