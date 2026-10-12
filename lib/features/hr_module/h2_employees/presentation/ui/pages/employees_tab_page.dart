// ***************************** FILE INFO ***************************** //
// File Name: employees_tab_page.dart
// Purpose: Displays the employee information filter tabs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/custom/9-filter_tab_with_container.dart';
import '../../../../../../core/custom/9-filter_tab_with_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../controller/cubit/hr_employee_cubit.dart';
import '../../controller/cubit/hr_employee_state.dart';
import '../../../utils/enums/ui_controllers/employee_information_tabs.dart';
import '../../../utils/enums/ui_controllers/hr_employee_view_mode.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../widgets/hr_employees_grid_view.dart';
import '../widgets/hr_employee_search_row.dart';
import '../widgets/hr_employee_view_buttons.dart';
import '../widgets/hr_employees_table_view.dart';

class EmployeesTabPage extends StatefulWidget {
  const EmployeesTabPage({super.key});

  @override
  State<EmployeesTabPage> createState() => _EmployeesTabPageState();
}

class _EmployeesTabPageState extends State<EmployeesTabPage> {
  int _selectedTab = 0;
  late final HrEmployeeCubit _employeeCubit;

  @override
  void initState() {
    super.initState();
    _employeeCubit = HrEmployeeCubit(
      dataCubit: context.read<HrModuleDataCubit>(),
      departmentCubit: Get.find<MainCoreDepartmentCubit>(),
    );
  }

  @override
  void dispose() {
    _employeeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _employeeCubit,
      child: BlocBuilder<HrEmployeeCubit, HrEmployeeState>(
        builder: (context, state) {
          final selectedTab = EmployeeInformationTabs.fromIndex(_selectedTab);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth >= 1000.w;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HrEmployeeSearchRow(showViewButtons: !isLargeScreen),
                  SizedBox(height: 16.h),
                  if (isLargeScreen) ...[
                    _buildDesktopInformationControls(state.viewMode),
                    SizedBox(height: 16.h),
                  ],
                  Expanded(
                    child: _buildTabContent(
                      selectedTab,
                      state.viewMode,
                      showInformationTabs: !isLargeScreen,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Method Name: [_buildTabContent]
  ///
  /// Purpose: Builds the current employee-information filter content.
  ///
  /// Parameters:
  /// - [tab]: Selected employee information tab.
  ///
  /// Returns: The selected tab content placeholder.
  Widget _buildTabContent(
    EmployeeInformationTabs tab,
    HrEmployeeViewMode viewMode, {
    required bool showInformationTabs,
  }) {
    switch (tab) {
      case EmployeeInformationTabs.all:
      case EmployeeInformationTabs.personalInformation:
      case EmployeeInformationTabs.contactDetails:
      case EmployeeInformationTabs.addressDetails:
      case EmployeeInformationTabs.identificationDetails:
      case EmployeeInformationTabs.positionDetails:
        return viewMode == HrEmployeeViewMode.grid
            ? const HrEmployeesGridView()
            : HrEmployeesTableView(
                selectedTab: _selectedTab,
                onTabSelected: _selectTab,
                showInformationTabs: showInformationTabs,
              );
    }
  }

  /// Method Name: [_buildDesktopInformationControls]
  ///
  /// Purpose: Places employee information filters beside view controls on wide screens.
  ///
  /// Parameters:
  /// - [viewMode]: The active employee presentation mode.
  ///
  /// Returns: The desktop-only information filter and view-control row.
  Widget _buildDesktopInformationControls(HrEmployeeViewMode viewMode) {
    return Row(
      children: [
        Expanded(
          child: CustomSegmentedTabs(
            tabs:
                EmployeeInformationTabs.values.map((tab) => tab.title).toList(),
            selectedIndex: _selectedTab,
            onTabSelected: _selectTab,
            containerColor: AppColors.transparent,
            tabHorizontalPadding: 12.sp,
            tabVerticalPadding: 12.sp,
            spacing: 16.sp,
            borderRadius: 4.sp,
          ),
        ),
        SizedBox(width: 16.w),
        HrEmployeeViewButtons(
          selectedMode: viewMode,
          onChanged: _employeeCubit.updateViewMode,
        ),
      ],
    );
  }

  /// Method Name: [_selectTab]
  ///
  /// Purpose: Updates the selected employee-information filter tab.
  ///
  /// Parameters:
  /// - [index]: Selected filter tab index.
  ///
  /// Returns: Rebuilds the page with the selected tab.
  void _selectTab(int index) {
    setState(() => _selectedTab = index);
  }
}
