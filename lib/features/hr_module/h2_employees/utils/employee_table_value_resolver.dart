// ***************************** FILE INFO ***************************** //
// File Name: employee_table_value_resolver.dart
// Purpose: Resolves employee entity values for HR employee table columns.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'employee_details_phone_formatter.dart';
import 'enums/employee_upload_controllers/employee_info.dart';

/// Resolves display-ready values for HR employee table fields.
class EmployeeTableValueResolver {
  EmployeeTableValueResolver._();

  /// Method Name: [valueFor]
  ///
  /// Purpose: Resolves one employee field into a display-safe table value.
  ///
  /// Parameters:
  /// - [employee]: Employee data displayed in the table row.
  /// - [field]: Configured employee field for the table column.
  /// - [departmentCubit]: Shared department name resolver.
  ///
  /// Returns: A display-safe field value, or an empty value when unavailable.
  static String valueFor({
    required HrEmployeeEntity employee,
    required EmployeeInfo field,
    required MainCoreDepartmentCubit departmentCubit,
  }) {
    switch (field) {
      case EmployeeInfo.id:
        return employee.id ?? '';
      case EmployeeInfo.firstName:
        return employee.firstName ?? '';
      case EmployeeInfo.middleName:
        return employee.middleName ?? '';
      case EmployeeInfo.lastName:
        return employee.lastName ?? '';
      case EmployeeInfo.firstNameArabic:
        return employee.firstNameInArabic ?? '';
      case EmployeeInfo.middleNameArabic:
        return employee.middleNameInArabic ?? '';
      case EmployeeInfo.lastNameArabic:
        return employee.lastNameInArabic ?? '';
      case EmployeeInfo.nationalId:
        return employee.nationalId ?? '';
      case EmployeeInfo.nationalIdExpirationDate:
        return employee.nationalIdExpirationDate ?? '';
      case EmployeeInfo.nationality:
        return employee.nationality ?? '';
      case EmployeeInfo.passport:
        return employee.passport ?? '';
      case EmployeeInfo.passportExpirationDate:
        return employee.passportExpirationDate ?? '';
      case EmployeeInfo.email:
        return employee.email ?? '';
      case EmployeeInfo.mobileCountryCode:
        return (employee.mobilePhone?.countryCode ?? '').replaceAll('+', '');
      case EmployeeInfo.mobileNumber:
        return EmployeeDetailsPhoneFormatter.format(
          countryCode: employee.mobilePhone?.countryCode,
          number: employee.mobilePhone?.number,
        );
      case EmployeeInfo.homeCountryCode:
        return (employee.homeCountryCode ?? '').replaceAll('+', '');
      case EmployeeInfo.homeNumber:
        return EmployeeDetailsPhoneFormatter.format(
          countryCode: employee.homeCountryCode,
          number: employee.homePhone,
        );
      case EmployeeInfo.officeCountryCode:
        return (employee.officeCountryCode ?? '').replaceAll('+', '');
      case EmployeeInfo.officeNumber:
        return EmployeeDetailsPhoneFormatter.format(
          countryCode: employee.officeCountryCode,
          number: employee.officePhone,
        );
      case EmployeeInfo.extension:
        return employee.extension ?? '';
      case EmployeeInfo.birthDay:
        return employee.birthDay ?? '';
      case EmployeeInfo.gender:
        return employee.gender ?? '';
      case EmployeeInfo.country:
        return employee.country ?? '';
      case EmployeeInfo.province:
        return employee.province ?? '';
      case EmployeeInfo.city:
        return employee.city ?? '';
      case EmployeeInfo.postalCode:
        return employee.postalCode ?? '';
      case EmployeeInfo.street:
        return employee.street ?? '';
      case EmployeeInfo.maritalStatus:
        return employee.maritalStatus ?? '';
      case EmployeeInfo.language:
        return employee.language ?? '';
      case EmployeeInfo.departmentId:
        return employee.departmentId ?? '';
      case EmployeeInfo.departmentEnglishName:
        return _departmentName(
          departmentId: employee.departmentId,
          isEnglish: true,
          departmentCubit: departmentCubit,
        );
      case EmployeeInfo.departmentArabicName:
        return _departmentName(
          departmentId: employee.departmentId,
          isEnglish: false,
          departmentCubit: departmentCubit,
        );
      case EmployeeInfo.supervisorEmail:
        return employee.supervisor ?? '';
      case EmployeeInfo.role:
        return employee.role ?? '';
      case EmployeeInfo.englishTitle:
        return employee.title ?? '';
      case EmployeeInfo.arabicTitle:
        return employee.titleInArabic ?? '';
      case EmployeeInfo.workLocation:
        return employee.workLocation ?? '';
      case EmployeeInfo.drivingLicenseId:
        return employee.drivingLicenseId ?? '';
      case EmployeeInfo.carPlates:
        return employee.carPlates
                ?.whereType<String>()
                .where((plate) => plate.trim().isNotEmpty)
                .join(', ') ??
            '';
      case EmployeeInfo.none:
        return '';
    }
  }

  /// Method Name: [_departmentName]
  ///
  /// Purpose: Resolves a stable department ID to its localized display name.
  ///
  /// Parameters:
  /// - [departmentId]: Stored department identifier.
  /// - [isEnglish]: Whether to return the English department name.
  /// - [departmentCubit]: Shared department data provider.
  ///
  /// Returns: The localized department name, or an empty value when unknown.
  static String _departmentName({
    required String? departmentId,
    required bool isEnglish,
    required MainCoreDepartmentCubit departmentCubit,
  }) {
    final value = departmentId?.trim() ?? '';
    if (value.isEmpty || !departmentCubit.departmentIds.contains(value)) {
      return '';
    }
    return departmentCubit.getDepartmentName(value, isEnglish);
  }
}
