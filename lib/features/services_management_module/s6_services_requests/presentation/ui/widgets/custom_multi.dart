// ******************* FILE INFO *******************
// File Name: custom_multi
// Description: Custom multi.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/49-custom_view_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepartmentMultiSelectPage extends StatefulWidget {
  const DepartmentMultiSelectPage({
    super.key,
    required this.selectedKeys,
    required this.onChanged,
  });

  /// The selected department IDs from parent
  final List<String> selectedKeys;

  /// Callback with the updated list of selected department IDs
  final ValueChanged<List<String>> onChanged;

  @override
  State<DepartmentMultiSelectPage> createState() => _DepartmentMultiSelectPageState();
}

class _DepartmentMultiSelectPageState extends State<DepartmentMultiSelectPage> {
  late final MainCoreDepartmentCubit _departmentController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _departmentController = context.read<MainCoreDepartmentCubit>();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    // Ensure departments are loaded
    if (_departmentController.departmentModels.isEmpty) {
      await _departmentController.getAllDepartments();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleDepartment(String departmentId) {
    final List<String> next = List<String>.from(widget.selectedKeys);
    if (next.contains(departmentId)) {
      next.remove(departmentId);
    } else {
      next.add(departmentId);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (_isLoading) {
      return SizedBox(
        width: 190.sp,
        height: 38.sp,
        child: Container(
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    // Get department IDs
    final departmentIds = _departmentController.departmentIds;

    if (departmentIds.isEmpty) {
      return SizedBox(
        width: 190.sp,
        height: 38.sp,
        child: Container(
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              s.department,
              style: StyleText.fontSize14Weight400.copyWith(
                color: lightMode ? AppColors.secondaryText : AppColors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Build display names based on language
    final itemsDisplay = departmentIds.map((id) {
      return _departmentController.getDepartmentName(id, isArabic ? false : true);
    }).toList();

    // Map selected IDs to display names
    final selectedDisplay = widget.selectedKeys.map((id) {
      return _departmentController.getDepartmentName(id, isArabic ? false : true);
    }).toList();

    return SizedBox(
      width: 190.w,
      // ✅ FIX (bug report p31/p37): the outer box was 34.h while the dropdown
      // inside it asked for 36.h, and the sort control next to it is 38.sp —
      // three different heights in one filter row. 38.sp is the standard
      // toolbar control height used across the module.
      height: 38.sp,
      child: AppMultiSelectDropdownMaster(
        items: itemsDisplay,
        selectedItems: selectedDisplay,
        onChanged: (displayName) {
          // Find the department ID from the display name
          final index = itemsDisplay.indexOf(displayName.toString());
          if (index != -1) {
            final departmentId = departmentIds[index];
            _toggleDepartment(departmentId);
          }
        },
        textButton: s.department,
        textStyle: StyleText.fontSize14Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
        hintText: s.department,
        width: double.infinity,
        height: 38.sp,
        menuWidth: 190.sp,
        // Bug report p17: same 8.r corners as the search field and Sort
        // button beside it.
        buttonRadius: 8.r,
      ),
    );
  }
}
