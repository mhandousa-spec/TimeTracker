/// ************************* FILE INFO *************************** ///
/// File Name: grc_department_filter_button.dart
/// Purpose: The sliders "Filter" button on the phone Control Champions /
///          Control Owners tabs -- picks one department.
/// Author: Knowticed Plus team
/// Created At: 15/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Localized names of every department, in directory order.
List<String> grcDepartmentLabels(BuildContext context) {
  final departments = Get.find<MainCoreDepartmentCubit>();
  return [
    for (final id in departments.departmentIds)
      (context.isArabic
              ? departments.getArabicDepartmentNameFromDepartmentId(
                  departmentId: id)
              : departments.getEnglishDepartmentNameFromDepartmentId(
                  departmentId: id)) ??
          '',
  ].where((l) => l.isNotEmpty).toList();
}

/// class name: [GrcDepartmentFilterButton]
///
/// purpose: 38 x 38 sliders button (CustomSortButton, 47) whose menu lists
///          the departments. Tapping the selected one again clears it.
class GrcDepartmentFilterButton extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  /// Square side in logical pixels (already scaled). Null keeps the
  /// button's own 38 x 38.
  final double? size;

  const GrcDepartmentFilterButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSortButton<String>(
      value: value,
      items: grcDepartmentLabels(context),
      labelBuilder: (label) => label,
      onChanged: onChanged,
      title: S.of(context).filter,
      showTitle: false,
      svgPath: AppAssets.filter,
      menuWidth: 200.w,
      width: size,
      height: size,
    );
  }
}
