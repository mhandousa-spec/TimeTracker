// ******************* FILE INFO *******************
// File Name: dashboard_department_filter
// Description: Dashboard department filter.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/controller/admin_state.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/widgets/filter_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DashboardDepartmentFilter extends StatelessWidget {
  final DashboardAdminState state;

  const DashboardDepartmentFilter({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardAdminCubit>();

    // ✅ Pass the dynamic departmentCounts directly from state
    return DepartmentFilterWidget(
      totalServices: state.totalServices,
      selectedStatus: state.selectStatus,
      departmentCounts: state.departmentCounts,
      onStatusChanged: (newStatus) => cubit.onDepartmentChanged(newStatus),
      statusChipBuilder:
          (count, displayLabel, logicKey, {required isSelected}) {
        return _DepartmentChip(
          count: count,
          displayLabel: displayLabel,
          logicKey: logicKey,
          isSelected: isSelected,
          onTap: () => cubit.onDepartmentChanged(logicKey),
        );
      },
    );
  }
}

class _DepartmentChip extends StatelessWidget {
  final String count;
  final String displayLabel;
  final String logicKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _DepartmentChip({
    required this.count,
    required this.displayLabel,
    required this.logicKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    Color getLabelColor() {
      if (isSelected) {
        return light ? AppColors.blackButton : AppColors.white;
      }
      return light ? AppColors.secondaryText : AppColors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight600.copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : light
                      ? AppColors.secondaryText
                      : AppColors.grey,
                )
                    : StyleText.fontSize20Weight500.copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : light
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            displayLabel,
            style: isMobile
                ? StyleText.fontSize14Weight600.copyWith(color: getLabelColor())
                : StyleText.fontSize16Weight600.copyWith(color: getLabelColor()),
          ),
          SizedBox(width: 30.w),
        ],
      ),
    );
  }
}
