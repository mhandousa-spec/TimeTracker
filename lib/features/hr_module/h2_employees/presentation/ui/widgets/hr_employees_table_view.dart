// ***************************** FILE INFO ***************************** //
// File Name: hr_employees_table_view.dart
// Purpose: Displays filtered HR employees in an enum-configured data table.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/custom/9-filter_tab_with_container.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../controller/cubit/hr_employee_cubit.dart';
import '../../controller/cubit/hr_employee_state.dart';
import '../../../utils/employee_table_value_resolver.dart';
import '../../../utils/hr_table_display_value.dart';
import '../../../utils/enums/employee_upload_controllers/employee_info.dart';
import '../../../utils/enums/ui_controllers/employee_information_tabs.dart';
import 'hr_table_viewport.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays HR employees in a horizontally scrollable, filter-driven table.
class HrEmployeesTableView extends StatelessWidget {
  const HrEmployeesTableView({
    required this.selectedTab,
    required this.onTabSelected,
    this.showInformationTabs = true,
    super.key,
  });

  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final bool showInformationTabs;

  @override
  Widget build(BuildContext context) {
    final selectedInformationTab =
        EmployeeInformationTabs.fromIndex(selectedTab);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showInformationTabs) ...[
          CustomSegmentedTabs(
            tabs:
                EmployeeInformationTabs.values.map((tab) => tab.title).toList(),
            selectedIndex: selectedTab,
            onTabSelected: onTabSelected,
            containerColor: AppColors.transparent,
            spacing: 16.sp,
            borderRadius: 4.sp,
          ),
          SizedBox(height: 16.sp),
        ],
        Expanded(
          child: BlocBuilder<HrEmployeeCubit, HrEmployeeState>(
            builder: (context, state) {
              final employees = state.employees;
              if ((state is HrEmployeeInitial || state is HrEmployeeLoading) &&
                  employees.isEmpty) {
                return const CircleProgressMaster();
              }

              return _buildDataTable(
                context: context,
                employees: employees,
                targetOptions: selectedInformationTab.targetOptions,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Method Name: [_buildDataTable]
  ///
  /// Purpose: Builds the table columns and rows selected by the active tab.
  ///
  /// Parameters:
  /// - [context]: Build context used for localization and theme access.
  /// - [employees]: Search and filter matched employee records.
  /// - [targetOptions]: Ordered fields selected by the active information tab.
  ///
  /// Returns: The scrollable HR employee data table.
  Widget _buildDataTable({
    required BuildContext context,
    required List<HrEmployeeEntity> employees,
    required List<EmployeeInfo> targetOptions,
  }) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final departmentCubit = Get.find<MainCoreDepartmentCubit>();

    return HrTableViewport(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
        child: DataTable(
          border: TableBorder(
            horizontalInside: BorderSide(
              width: 0,
              color: isLightMode ? AppColors.white : AppColors.totalBlack,
            ),
          ),
          headingRowColor: WidgetStatePropertyAll(AppColors.header),
          dataRowMinHeight: 46.h,
          dataRowMaxHeight: 46.h,
          headingRowHeight: 46.h,
          horizontalMargin: 16.w,
          columnSpacing: 36.w,
          dividerThickness: 0,
          columns: [
            DataColumn(label: _headerCell(context, S.of(context).number)),
            ...targetOptions.map((field) => DataColumn(
                  label: _headerCell(context, field.name),
                )),
          ],
          rows: List.generate(
            employees.length,
            (index) => DataRow(
              color: WidgetStatePropertyAll(
                index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
              ),
              cells: [
                DataCell(_valueCell('${index + 1}', capitalize: false)),
                ...targetOptions.map(
                  (field) => DataCell(
                    _valueCell(
                      EmployeeTableValueResolver.valueFor(
                        employee: employees[index],
                        field: field,
                        departmentCubit: departmentCubit,
                      ),
                      capitalize: field != EmployeeInfo.id,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Method Name: [_headerCell]
  ///
  /// Purpose: Creates a consistently styled table header label.
  ///
  /// Parameters:
  /// - [value]: Localized header value.
  ///
  /// Returns: Header text styled for the table heading row.
  Widget _headerCell(BuildContext context, String value) {
    return Text(
      value,
      style: StyleText.fontSize14Weight600.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.white
            : AppColors.textButton,
      ),
    );
  }

  /// Method Name: [_valueCell]
  ///
  /// Purpose: Creates a fixed-height, single-line employee table cell.
  ///
  /// Parameters:
  /// - [value]: Value shown in the table cell.
  ///
  /// Returns: Employee value text constrained to one table row.
  Widget _valueCell(String value, {bool capitalize = true}) {
    return SizedBox(
      height: 46.h,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          HrTableDisplayValue.format(value, capitalize: capitalize),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StyleText.fontSize14Weight600,
        ),
      ),
    );
  }
}
