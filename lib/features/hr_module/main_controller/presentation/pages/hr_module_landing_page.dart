// ***************************** FILE INFO ***************************** //
// File Name: hr_module_landing_page.dart
// Purpose: Provides shared HR data to the module's nested navigator.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../core/helper/hr/hr_routing.dart';
import '../../../../../core/helper/role/main_core_employee_controller.dart';
import '../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../controller/hr_module_data_cubit.dart';

class HrModuleLandingPage extends StatelessWidget {
  const HrModuleLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HrModuleDataCubit(
        employeeController: Get.find<MainCoreEmployeeController>(),
        departmentCubit: Get.find<MainCoreDepartmentCubit>(),
      )..load(),
      child: Builder(
        builder: (providerContext) {
          return Navigator(
            onGenerateRoute: (settings) => HRRouting.hrOnGenerateRoute(
              settings,
              hrModuleDataCubit: providerContext.read<HrModuleDataCubit>(),
            ),
            initialRoute: HRRoutes.hrModuleDashboardPage,
          );
        },
      ),
    );
  }
}
