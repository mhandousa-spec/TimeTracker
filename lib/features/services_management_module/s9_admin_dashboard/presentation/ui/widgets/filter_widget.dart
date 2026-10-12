// ******************* FILE INFO *******************
// File Name: filter_widget
// Description: Filter widget.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentFilterWidget extends StatelessWidget {
  final int totalServices;
  final String selectedStatus;
  final Map<String, int> departmentCounts;
  final Function(String) onStatusChanged;
  final Widget Function(String count, String label, String key,
      {required bool isSelected}) statusChipBuilder;

  const DepartmentFilterWidget({
    Key? key,
    required this.totalServices,
    required this.selectedStatus,
    required this.departmentCounts,
    required this.onStatusChanged,
    required this.statusChipBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    // ✅ Get Arabic names dynamically from controller
    final departmentController = context.read<MainCoreDepartmentCubit>();

    String _getDisplayName(String englishName) {
      // W27: no try/catch in the widget (§11.2); the controller lookups are
      // null-safe and fall back to the English name.
      if (!isArabic) return englishName;
      final deptId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: englishName.toLowerCase(),
      );
      if (deptId != null) {
        return departmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: deptId) ??
            englishName;
      }
      return englishName;
    }

    // Create department data list sorted by count descending
    List<Map<String, dynamic>> departmentData = departmentCounts.entries
        .map((entry) => {
      "key": entry.key,
      "count": entry.value,
    })
        .toList();

    departmentData.sort((a, b) => b['count'].compareTo(a['count']));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // First item: All
          GestureDetector(
            onTap: () => onStatusChanged("All"),
            child: statusChipBuilder(
              "$totalServices",
              isArabic ? "الكل" : "All",
              "All",
              isSelected: selectedStatus == "All",
            ),
          ),
          // Dynamic departments
          ...departmentData.map((dept) => GestureDetector(
            onTap: () => onStatusChanged(dept['key']),
            child: statusChipBuilder(
              "${dept['count']}",
              _getDisplayName(dept['key']),
              dept['key'],
              isSelected: selectedStatus == dept['key'],
            ),
          )),
        ],
      ),
    );
  }
}