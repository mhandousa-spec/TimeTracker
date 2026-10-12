// ******************* FILE INFO *******************
// File Name: department_filter_chips_widget
// Description: Department filter chips widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/data/department_count_model.dart';

class DepartmentFilterChipsWidget extends StatelessWidget {
  final String selectedDepartment;
  final DepartmentCountModel departmentCounts;
  final Function(String) onDepartmentChanged;

  const DepartmentFilterChipsWidget({
    required this.selectedDepartment,
    required this.departmentCounts,
    required this.onDepartmentChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return StatusChipFilter(
      selectedKey: selectedDepartment,
      onSelected: (key) {
        onDepartmentChanged(key);
      },
      items: departmentChipItems(
        totalCount: departmentCounts.total,
        departmentCounts: departmentCounts.departmentCounts,
        isArabic: isArabic,
      ),
    );
  }
}
