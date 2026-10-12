import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

Widget buildDropdowns(
  BuildContext context, {
  required bool isMobile,
  required bool lightMode,
  required void Function(String?) onChanged,
  required void Function(String?) onDocTypeChanged,
  required void Function(String?) onOwningStatusChanged,
  required List<Map<String, String>> departmentItems,
  required List<Map<String, String>> docTypeItems,
  required List<Map<String, String>> owningStatusItems,
  required String? owningDepartmentText,
  required String? docType,
  required String? owningStatusText,
  required bool isAdmin,
}) {
  final owningDeptDropdown = _buildDropdown(
    selectedValue: owningDepartmentText,
    items: departmentItems,
    onChanged: onChanged,
    hint: S.of(context).owning_department,
    lightMode: lightMode,
    isMobile: isMobile,
  );

  final docTypeDropdown = _buildDropdown(
    selectedValue: docType,
    items: docTypeItems,
    onChanged: onDocTypeChanged,
    hint: S.of(context).document_type,
    lightMode: lightMode,
    isMobile: isMobile,
  );

  final owningStatusDropDown = _buildDropdown(
    selectedValue: owningStatusText,
    items: owningStatusItems,
    onChanged: onOwningStatusChanged,
    hint: S.of(context)!.owningStatus,
    lightMode: lightMode,
    isMobile: isMobile,
  );

  // Mobile layout: All dropdowns in a column
  if (isMobile) {
    return Column(
      children: [
        owningDeptDropdown,
        SizedBox(height: 15.h),
        docTypeDropdown,
        if (isAdmin) ...[SizedBox(height: 15.h), owningStatusDropDown],
      ],
    );
  }

  // Desktop layout
  // If admin: show all 3 dropdowns in a row
  // If not admin: show 2 dropdowns in a row
  if (isAdmin) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: owningStatusDropDown),
            SizedBox(width: 15.w),
            Expanded(child: docTypeDropdown),

          ],
        ),
    
      ],
    );
  } else {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: owningStatusDropDown),
            SizedBox(width: 15.w),
            Expanded(child: docTypeDropdown),

          ],
        ),
      ],
    );
  }
}

Widget _buildDropdown({
  required String? selectedValue,
  required List<Map<String, String>> items,
  required ValueChanged<String?> onChanged,
  required String hint,
  required bool lightMode,
  required bool isMobile,
}) {
  return SizedBox(
           width: isMobile ? double.infinity : null,
           height: 36,
           child: CustomDropdown<String>(
             // FIXED 12/9/2026 — see the same note in approval_filter.dart: a
             // 14.sp selected value plus the default 10.sp vertical padding does
             // not fit the 36 box above, so the picked option rendered clipped
             // on phones while the 12.sp hint looked fine.
             triggerPadding: isMobile
                 ? EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp)
                 : null,
             value: selectedValue,
             items: items
             .map((e) => DropdownItem<String>(
               value: e['key'] ?? '',
               label: e['value'] ?? '',
             ))
             .toList(),
             onChanged: (v) => onChanged(v),
             hint: hint,
             hintStyle: StyleText.fontSize12Weight400.copyWith(
        color: AppColors.secondaryText,
      ),
             fillColor: AppColors.background,
           ),
         );
}
