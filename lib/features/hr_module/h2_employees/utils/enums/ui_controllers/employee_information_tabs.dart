// ***************************** FILE INFO ***************************** //
// File Name: employee_information_tabs.dart
// Purpose: Defines employee information filter tabs and localized labels.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/generated/l10n.dart';

import '../employee_upload_controllers/employee_info.dart';

enum EmployeeInformationTabs {
  all,
  personalInformation,
  contactDetails,
  addressDetails,
  identificationDetails,
  positionDetails;

  static const List<EmployeeInfo> _identityOptions = [
    EmployeeInfo.id,
    EmployeeInfo.firstName,
    EmployeeInfo.middleName,
    EmployeeInfo.lastName,
    EmployeeInfo.firstNameArabic,
    EmployeeInfo.middleNameArabic,
    EmployeeInfo.lastNameArabic,
  ];

  static const List<EmployeeInfo> _personalInformationOptions = [
    ..._identityOptions,
    EmployeeInfo.nationality,
    EmployeeInfo.birthDay,
    EmployeeInfo.gender,
    EmployeeInfo.maritalStatus,
    EmployeeInfo.language,
  ];

  static const List<EmployeeInfo> _contactDetailsOptions = [
    ..._identityOptions,
    EmployeeInfo.email,
    EmployeeInfo.mobileNumber,
    EmployeeInfo.homeNumber,
    EmployeeInfo.officeNumber,
    EmployeeInfo.extension,
  ];

  static const List<EmployeeInfo> _addressDetailsOptions = [
    ..._identityOptions,
    EmployeeInfo.nationalId,
    EmployeeInfo.country,
    EmployeeInfo.province,
    EmployeeInfo.city,
    EmployeeInfo.postalCode,
    EmployeeInfo.street,
  ];

  static const List<EmployeeInfo> _identificationDetailsOptions = [
    ..._identityOptions,
    EmployeeInfo.nationalId,
    EmployeeInfo.nationalIdExpirationDate,
    EmployeeInfo.passport,
    EmployeeInfo.passportExpirationDate,
    EmployeeInfo.drivingLicenseId,
    EmployeeInfo.carPlates,
  ];

  static const List<EmployeeInfo> _positionDetailsOptions = [
    ..._identityOptions,
    EmployeeInfo.departmentId,
    EmployeeInfo.departmentEnglishName,
    EmployeeInfo.departmentArabicName,
    EmployeeInfo.supervisorEmail,
    EmployeeInfo.role,
    EmployeeInfo.englishTitle,
    EmployeeInfo.arabicTitle,
    EmployeeInfo.workLocation,
  ];

  static const List<EmployeeInfo> _allTargetOptions = [
    ..._identityOptions,
    EmployeeInfo.nationalId,
    EmployeeInfo.nationalIdExpirationDate,
    EmployeeInfo.nationality,
    EmployeeInfo.passport,
    EmployeeInfo.passportExpirationDate,
    EmployeeInfo.email,
    EmployeeInfo.mobileNumber,
    EmployeeInfo.homeNumber,
    EmployeeInfo.officeNumber,
    EmployeeInfo.extension,
    EmployeeInfo.birthDay,
    EmployeeInfo.gender,
    EmployeeInfo.country,
    EmployeeInfo.province,
    EmployeeInfo.city,
    EmployeeInfo.postalCode,
    EmployeeInfo.street,
    EmployeeInfo.maritalStatus,
    EmployeeInfo.language,
    EmployeeInfo.departmentId,
    EmployeeInfo.departmentEnglishName,
    EmployeeInfo.departmentArabicName,
    EmployeeInfo.supervisorEmail,
    EmployeeInfo.role,
    EmployeeInfo.englishTitle,
    EmployeeInfo.arabicTitle,
    EmployeeInfo.workLocation,
    EmployeeInfo.drivingLicenseId,
    EmployeeInfo.carPlates,
  ];

  /// Method Name: [title]
  ///
  /// Purpose: Resolves the localized label for the employee information tab.
  ///
  /// Returns: A centralized localization value for this tab.
  String get title {
    switch (this) {
      case EmployeeInformationTabs.all:
        return S.current.all;
      case EmployeeInformationTabs.personalInformation:
        return S.current.personalInformation;
      case EmployeeInformationTabs.contactDetails:
        return S.current.contactDetails;
      case EmployeeInformationTabs.addressDetails:
        return S.current.addressDetails;
      case EmployeeInformationTabs.identificationDetails:
        return S.current.identificationDetails;
      case EmployeeInformationTabs.positionDetails:
        return S.current.positionDetails;
    }
  }

  /// Method Name: [targetOptions]
  ///
  /// Purpose: Provides the employee fields displayed by the selected tab.
  ///
  /// Returns: Ordered employee fields for the table columns.
  List<EmployeeInfo> get targetOptions {
    switch (this) {
      case EmployeeInformationTabs.all:
        return _allTargetOptions;
      case EmployeeInformationTabs.personalInformation:
        return _personalInformationOptions;
      case EmployeeInformationTabs.contactDetails:
        return _contactDetailsOptions;
      case EmployeeInformationTabs.addressDetails:
        return _addressDetailsOptions;
      case EmployeeInformationTabs.identificationDetails:
        return _identificationDetailsOptions;
      case EmployeeInformationTabs.positionDetails:
        return _positionDetailsOptions;
    }
  }

  /// Method Name: [fromIndex]
  ///
  /// Purpose: Safely resolves a tab enum value from a selected index.
  ///
  /// Parameters:
  /// - [index]: Selected filter tab index.
  ///
  /// Returns: The matching tab, or [all] for an invalid index.
  static EmployeeInformationTabs fromIndex(int index) {
    if (index < 0 || index >= values.length) return all;
    return values[index];
  }
}
