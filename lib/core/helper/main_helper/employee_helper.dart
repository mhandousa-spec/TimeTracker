/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: employee_helper.dart
/// Purpose: Declares `EmployeeHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EmployeeHelper {
  static String getEmployeeLocalizedName(
      {required EmployeeEntityPro employee, required BuildContext context}) {
  //  print('getEmployeeLocalizedName: ${employee.email} ${employee.lastName}');
    String name = '';
    if (!context.isArabic) {
      name = '${employee.firstName!} ${employee.lastName!}';
    } else {
      // print(
      //     'getEmployeeLocalizedName: ${employee.firstNameInArabic} ${employee.lastNameInArabic}');
      name = '${employee.firstNameInArabic!} ${employee.lastNameInArabic!}';
    }
    //print('getEmployeeLocalizedName name: $name');
    return name;
  }

  static String getEmployeeLocalizedNameWithId(
      {required String employeeId, required BuildContext context}) {
    EmployeeEntityPro employee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.id == employeeId);
    return getEmployeeLocalizedName(employee: employee, context: context);
  }

  static String getEmployeeImageWithId({required String employeeId}) {
    EmployeeEntityPro employee =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities!.firstWhere(
              (element) => element.id == employeeId,
            );
    return getEmployeeImage(employee: employee);
  }

  static String getEmployeeImageWithEmail({required String employeeEmail}) {
    EmployeeEntityPro employee =
        Get.find<MainCoreEmployeeController>().allEmployeesEntities!.firstWhere(
              (element) => element.email == employeeEmail,
            );
    return getEmployeeImage(employee: employee);
  }

  static String getEmployeeImage({required EmployeeEntityPro employee}) {
    String employeeImageUrl = employee.photo ?? "";

    // ✅ Check for null, empty string, or "[]"
    if (employee.photo == null ||
        employee.photo!.isEmpty ||
        employee.photo == "[]") {
      if (employee.gender == 'female') {
        employeeImageUrl = "assets/icons_assets/main_icons_assets/female_avatar.svg";
      } else {
        employeeImageUrl = "assets/icons_assets/main_icons_assets/male_avatar.svg";
      }
    }

    return employeeImageUrl;
  }

  static String getEmployeeLocalizedNameWithEmail(
      {required String employeeEmail}) {
    EmployeeEntityPro employee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities!
        .firstWhere((element) => element.email == employeeEmail);
    return getEmployeeLocalizedName(employee: employee, context: Get.context!);
  }

  static String getEmployeeLocalizeDepartment(
      {required EmployeeEntityPro employee, required BuildContext context}) {
    if (context.isArabic) {
      return context.read<MainCoreDepartmentCubit>()
              .getArabicDepartmentNameFromDepartmentId(
                  departmentId: employee.departmentId!) ??
          "";
    } else {
      return context.read<MainCoreDepartmentCubit>()
              .getEnglishDepartmentNameFromDepartmentId(
                  departmentId: employee.departmentId!) ??
          "";
    }
  }

  static getEmployeeLocalizedTitle(
      {required EmployeeEntityPro employee, required BuildContext context}) {
    if (context.isArabic) {
      return employee.titleInArabic;
    } else {
      return employee.title;
    }
  }
}
