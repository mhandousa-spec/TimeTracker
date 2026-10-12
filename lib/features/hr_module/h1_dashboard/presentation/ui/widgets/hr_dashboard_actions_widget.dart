// ***************************** FILE INFO ***************************** //
// File Name: hr_dashboard_actions_widget.dart
// Purpose: Displays HR dashboard actions and employee data filters.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/31-custom_multi_select_dropdown.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../features/roles/r4_active_directory/data/models/department_model.dart';
import '../../../../../../features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../../../generated/l10n.dart';
import '../../controller/cubit/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class HRDashboardActionsWidget extends StatelessWidget {
  const HRDashboardActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HrDashboardCubit>();
    final localization = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.sp,
      children: [
        Row(
          spacing: 10.sp,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              title: localization.shiftsManagement,
              image: HRAssets.hrShiftsManagement,
              function: () => Navigator.of(context).pushNamed(
                HRRoutes.hrModuleShiftManagementPage,
              ),
            ),
            _buildActionButton(
              title: localization.employeeOperations,
              image: HRAssets.hrEmployees,
            ),
            Spacer(),
            _buildActionButton(
              title: localization.departments,
              image: HRAssets.hrGroupPeopleNetwork,
              function: () => Navigator.of(context).pushNamed(
                HRRoutes.hrModuleDepartmentsPage,
              ),
            ),
            _buildActionButton(
              title: localization.requests,
              image: HRAssets.hrRequests,
              function: () => Navigator.of(context).pushNamed(
                HRRoutes.hrModuleRequestsPage,
              ),
            ),
          ],
        ),
        Row(
          spacing: 10.sp,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              title: localization.trackingAttendance,
              image: HRAssets.hrShiftSchedule,
            ),
            _buildActionButton(
              title: localization.employees,
              image: HRAssets.hrEmployeeOperations,
              function: () => Navigator.of(context).pushNamed(
                HRRoutes.hrModuleEmployeesPage,
              ),
            ),
            Spacer(),
            _buildLocationDropdown(context, cubit),
            _buildDepartmentDropdown(context, cubit),
          ],
        ),
      ],
    );
  }

  /// Method Name: [_buildLocationDropdown]
  ///
  /// Purpose: Builds the dashboard work-location multi-select filter.
  ///
  /// Parameters:
  /// - [context]: Widget context used for localized labels.
  /// - [cubit]: Dashboard cubit that owns filter selections.
  ///
  /// Returns: The configured location dropdown.
  Widget _buildLocationDropdown(
    BuildContext context,
    HrDashboardCubit cubit,
  ) {
    final localization = S.of(context);
    final items = _locationItems(cubit.locations);

    return SizedBox(
      width: 160.w,
      child: CustomMultiSelectDropdown<String>(
        values: cubit.selectedLocations,
        items: items,
        onChanged: cubit.updateLocationSelection,
        label: null,
        hint: localization.location,
        enabled: items.isNotEmpty,
        fillColor: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        valueStyle: StyleText.fontSize14Weight500,
        itemStyle: StyleText.fontSize14Weight500,
        emptyWidget: Text(localization.noResults),
      ),
    );
  }

  /// Method Name: [_buildDepartmentDropdown]
  ///
  /// Purpose: Builds the dashboard department multi-select filter.
  ///
  /// Parameters:
  /// - [context]: Widget context used for localized labels.
  /// - [cubit]: Dashboard cubit that owns filter selections.
  ///
  /// Returns: The configured department dropdown.
  Widget _buildDepartmentDropdown(
    BuildContext context,
    HrDashboardCubit cubit,
  ) {
    final localization = S.of(context);
    final items = _departmentItems(context, cubit.departments);

    return SizedBox(
      width: 160.w,
      child: CustomMultiSelectDropdown<String>(
        values: cubit.selectedDepartmentIds,
        items: items,
        onChanged: cubit.updateDepartmentSelection,
        label: null,
        hint: localization.department,
        enabled: items.isNotEmpty,
        fillColor: AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        valueStyle: StyleText.fontSize14Weight500,
        itemStyle: StyleText.fontSize14Weight500,
        emptyWidget: Text(localization.noResults),
      ),
    );
  }

  /// Method Name: [_departmentItems]
  ///
  /// Purpose: Converts department models to stable dropdown values and labels.
  ///
  /// Parameters:
  /// - [context]: Widget context used to determine the active language.
  /// - [departments]: Department source data.
  ///
  /// Returns: Valid department dropdown items.
  List<MultiSelectDropdownItem<String>> _departmentItems(
    BuildContext context,
    List<DepartmentModelPro> departments,
  ) {
    final isEnglish = !context.isArabic;
    final departmentCubit = Get.find<MainCoreDepartmentCubit>();

    return departments
        .map((department) {
          final id = department.departmentID?.trim() ?? '';
          if (id.isEmpty) return null;

          final label = departmentCubit.getDepartmentName(id, isEnglish);
          if (label.trim().isEmpty) return null;

          return MultiSelectDropdownItem<String>(
            value: id,
            label: label,
          );
        })
        .whereType<MultiSelectDropdownItem<String>>()
        .toList();
  }

  /// Method Name: [_locationItems]
  ///
  /// Purpose: Converts work locations into dropdown items.
  ///
  /// Parameters:
  /// - [locations]: Available work locations.
  ///
  /// Returns: Location dropdown items.
  List<MultiSelectDropdownItem<String>> _locationItems(
    List<String> locations,
  ) {
    return locations
        .map(
          (location) => MultiSelectDropdownItem<String>(
            value: location,
            label: location,
          ),
        )
        .toList();
  }

  /// Method Name: [_buildActionButton]
  ///
  /// Purpose: Builds a styled HR dashboard action button.
  ///
  /// Parameters:
  /// - [title]: Localized action label.
  /// - [image]: SVG asset path.
  /// - [function]: Optional action callback.
  ///
  /// Returns: The configured action button.
  Widget _buildActionButton({
    required String title,
    required String image,
    VoidCallback? function,
  }) {
    return customButtonWithSvg(
      title: title,
      function: function ?? () {},
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: image,
      widthImage: 24.sp,
      heightImage: 24.sp,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }
}
