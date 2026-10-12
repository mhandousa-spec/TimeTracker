// ***************************** FILE INFO ***************************** //
// File Name: hr_employees_page.dart
// Purpose: Hosts the HR employee module and its main tabs.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/features/../core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../utils/enums/ui_controllers/employee_main_tabs.dart';

class HREmployeesPage extends StatefulWidget {
  const HREmployeesPage({super.key});

  @override
  State<HREmployeesPage> createState() => _HREmployeesPageState();
}

class _HREmployeesPageState extends State<HREmployeesPage> {
  int _selectedTab = 0;

  /// Method Name: [_selectTab]
  ///
  /// Purpose: Updates the selected HR employee main tab.
  ///
  /// Parameters:
  /// - [index]: Selected main tab index.
  ///
  /// Returns: Rebuilds the page with the selected tab.
  void _selectTab(int index) {
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final hrModuleDataState = context.watch<HrModuleDataCubit>().state;
    final isLoadingWithoutData = hrModuleDataState is HrModuleDataInitial ||
        hrModuleDataState is HrModuleDataLoading &&
            hrModuleDataState.employees.isEmpty &&
            hrModuleDataState.departments.isEmpty;
    final isErrorWithoutData = hrModuleDataState is HrModuleDataError &&
        hrModuleDataState.employees.isEmpty &&
        hrModuleDataState.departments.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  localization.humanResources,
                  localization.employees,
                ],
              ),
              Expanded(
                child: isLoadingWithoutData
                    ? const CircleProgressMaster()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTabs(
                            tabs: EmployeeMainTabs.values
                                .map((tab) => tab.title)
                                .toList(),
                            selectedValue: _selectedTab,
                            onChanged: _selectTab,
                          ),
                          SizedBox(height: 16.sp),
                          Expanded(
                            child:
                                EmployeeMainTabs.fromIndex(_selectedTab).widget,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
