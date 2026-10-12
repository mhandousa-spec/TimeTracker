/// Module: roles / r2_user_management / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: user_permission_entity.dart
/// Purpose: Declares `UserPermissionEntity`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

class UserPermissionEntity {
  String employeeEmail;
  String imagePath;
  String employeeId;
  String? gender;
  String englishName;
  String arabicName;
  String? accessName;
  String? grantorEnglishName;
  String? grantorArabicName;
  String? startDate;
  String? endDate;
  UserAccessStatus accessStatus;
  String? departmentId;
  String? arabicJobTitle;
  String? englishJobTitle;

  UserPermissionEntity(
      {required this.imagePath,
        required this.employeeEmail,
        required this.employeeId,
        required this.gender,
        required this.englishName,
        required this.arabicName,
        required this.accessName,
        required this.grantorEnglishName,
        required this.grantorArabicName,
        required this.startDate,
        required this.accessStatus,
        this.departmentId,
        this.arabicJobTitle,
        this.englishJobTitle,
        required this.endDate});

  /// The employee's name in the caller's language.
  ///
  /// Was a getter reading `Get.locale`. A domain entity must not reach into a
  /// service locator for presentation state — GetX is banned besides — so the
  /// locale is passed in, matching [departmentName] and [jobTitle] below.
  String userName(bool isArabic) => isArabic ? arabicName : englishName;

  /// The granting employee's name in the caller's language. Was `Get.locale`.
  String grantorName(bool isArabic) =>
      (isArabic ? grantorArabicName : grantorEnglishName) ?? '';

  /// Resolves [accessName] (a role id) to that role's display name.
  ///
  /// Was `roleCubit` inside a `try/catch` that existed only because
  /// the locator might not have the cubit registered. The shared `roleCubit`
  /// singleton is always constructible, and the locale is a parameter, so
  /// neither the lookup nor the catch is needed.
  ///
  /// Parameters:
  /// - [isArabic]: Selects the Arabic role name when one exists.
  ///
  /// Returns: [String] the localized role name, the raw id when the role is not
  /// loaded, or `'No Role'` when unset.
  String getLocalizedRoleName(bool isArabic) {
    if (accessName == null || accessName!.isEmpty) {
      return 'No Role';
    }

    for (final role in roleCubit.roles) {
      if (role.roleId == accessName || role.currentRoleName == accessName) {
        return isArabic
            ? (role.currentRoleNameAr.isNotEmpty
                ? role.currentRoleNameAr
                : role.currentRoleName)
            : role.currentRoleName;
      }
    }

    return accessName!;
  }

  static UserPermissionEntity fromEmployeeEntity(EmployeeEntityPro employee) {
    return UserPermissionEntity(
      employeeEmail: employee.email!,
      employeeId: employee.id!,
      gender: employee.gender,
      imagePath: EmployeeHelper.getEmployeeImage(employee: employee),
      englishName: employee.firstName! + ' ' + employee.lastName!,
      arabicName:
      employee.firstNameInArabic! + ' ' + employee.lastNameInArabic!,
      accessName: null,
      grantorEnglishName: null,
      grantorArabicName: null,
      startDate: null,
      accessStatus: UserAccessStatus.all,
      endDate: null,
      departmentId: employee.departmentId,
      arabicJobTitle: employee.titleInArabic,
      englishJobTitle: employee.title,
    );
  }

  /// [departments] is passed in rather than located, so this entity stays a
  /// plain data class with no service-locator dependency.
  String departmentName(bool isArabic, MainCoreDepartmentCubit departments) {
    if (departmentId == null) return '';
    return isArabic
        ? (departments.getArabicDepartmentNameFromDepartmentId(
                departmentId: departmentId!) ??
            "")
        : (departments.getEnglishDepartmentNameFromDepartmentId(
                departmentId: departmentId!) ??
            "");
  }

  String jobTitle (bool isArabic){
    return (isArabic ? arabicJobTitle : englishJobTitle)??'';
  }
}