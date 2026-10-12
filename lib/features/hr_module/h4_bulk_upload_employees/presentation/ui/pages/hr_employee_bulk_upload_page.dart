// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_bulk_upload_page.dart
// Purpose: Hosts the employee bulk-upload flow entry point.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../../../core/helper/role/main_core_employee_controller.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../controller/employee_bulk_upload_cubit.dart';
import 'employee_bulk_upload_view.dart';

/// Navigable HR employee bulk-upload page.
class HrEmployeeBulkUploadPage extends StatelessWidget {
  const HrEmployeeBulkUploadPage({
    required this.hrModuleDataCubit,
    super.key,
  });

  final HrModuleDataCubit hrModuleDataCubit;

  @override
  Widget build(BuildContext context) {
    final employeeController = Get.find<MainCoreEmployeeController>();
    return BlocProvider(
      create: (_) => EmployeeBulkUploadCubit(
        departmentCubit: Get.find<MainCoreDepartmentCubit>(),
        hrModuleDataCubit: hrModuleDataCubit,
        editorEmail: employeeController.employeeEntity?.email ?? '',
      ),
      child: const EmployeeBulkUploadView(),
    );
  }
}
