/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_sender_info.dart
/// Purpose: Null-safe sender lookups for the notification cards and the
///          Department filter.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// WHY THIS EXISTS
/// ---------------
/// FIXED 7/10/2026 — the red "Null check operator used on a null value" box
/// on every To-Do notification (and on any other notification a person with
/// no department sent).
///
/// `MainCoreEmployeeController.getEmployeeDepartmentName` does
/// `departmentController.getDepartmentName(employee.departmentId!, …)`, and
/// `MainCoreDepartmentCubit.getDepartmentName` then does
/// `_departmentsEnglishNameFromDepartmentId[departmentId]!`. Both bangs throw
/// for a KNOWN employee whose `Department_Id` is empty or names a department
/// that is not loaded — exactly the company owner (Master Admin), whose record
/// carries `Department_Id: ""`. To-Do notifications are always sent by their
/// owner to themselves, so every one of them hit it inside the card's build.
///
/// This resolves the same name through the nullable getters instead, and
/// answers `''` whenever any link in the chain is missing. The core helpers
/// are left untouched (other modules call them); see the report for the
/// one-line core fix that would make them safe too.
library;

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

abstract class NotificationSenderInfo {
  /// Function Name: [departmentName]
  ///
  /// Purpose: The department of the person who sent a notification, in the
  /// requested language.
  ///
  /// Parameters:
  /// - [employeeController]: the employee directory.
  /// - [email]: `Sender_Email` as stored on the notification.
  /// - [isEnglish]: the READER's language.
  ///
  /// Returns: [String] — the department name, or `''` when the sender is not
  /// an employee, has no department, or the department is not loaded. Never
  /// throws.
  static String departmentName(
    MainCoreEmployeeController employeeController,
    String email, {
    required bool isEnglish,
  }) {
    final String departmentId =
        employeeController.getLocaleEmployee(email)?.departmentId?.trim() ??
            '';
    if (departmentId.isEmpty) return '';
    if (!Get.isRegistered<MainCoreDepartmentCubit>()) return '';

    final MainCoreDepartmentCubit departments =
        employeeController.departmentController;
    final String? name = isEnglish
        ? departments.getEnglishDepartmentNameFromDepartmentId(
            departmentId: departmentId)
        : departments.getArabicDepartmentNameFromDepartmentId(
            departmentId: departmentId);
    return name ?? '';
  }
}
