// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_headers.dart
// Purpose: Defines the fixed employee bulk-upload spreadsheet contract.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

/// Stable external headers accepted by the employee bulk-upload flow.
abstract final class EmployeeBulkUploadHeaders {
  static const String number = 'NO';
  static const String employeeId = 'Employee ID';
  static const String firstName = 'First Name';
  static const String middleName = 'Middle Name';
  static const String lastName = 'Last Name';
  static const String firstNameArabic = 'الاسم الأول';
  static const String middleNameArabic = 'الاسم الأوسط';
  static const String lastNameArabic = 'الاسم الأخير';
  static const String nationalId = 'National ID';
  static const String nationalIdExpiration = 'National ID Expiration';
  static const String nationality = 'Nationality';
  static const String passport = 'Passport';
  static const String passportExpiration = 'Passport Expiration';
  static const String email = 'Email';
  static const String mobilePhone = 'Mobile Phone';
  static const String homeNumber = 'Home Number';
  static const String officeNumber = 'Office Number';
  static const String extension = 'Extension';
  static const String birthDate = 'Birth Date';
  static const String gender = 'Gender';
  static const String country = 'Country';
  static const String province = 'Province';
  static const String city = 'City';
  static const String postalCode = 'Postal Code';
  static const String street = 'Street';
  static const String maritalStatus = 'Martial Status';
  static const String language = 'Language';
  static const String departmentId = 'Department ID';
  static const String departmentName = 'Department Name';
  static const String departmentArabic = 'Department Arabic';
  static const String supervisor = 'Supervisor';
  static const String role = 'Role';
  static const String title = 'Title';
  static const String titleArabic = 'Title Arabic';
  static const String workLocation = 'Work Location';
  static const String drivingLicenseId = 'Driving License ID';
  static const String carPlates = 'Car Plates';
  static const String countryCode = 'Country Code';

  static const int maxRows = 100;
  static const int maxWriteOperations = 450;
  static const int writesPerEmployee = 8;

  static const List<String> values = [
    number,
    employeeId,
    firstName,
    middleName,
    lastName,
    firstNameArabic,
    middleNameArabic,
    lastNameArabic,
    nationalId,
    nationalIdExpiration,
    nationality,
    passport,
    passportExpiration,
    email,
    mobilePhone,
    homeNumber,
    officeNumber,
    extension,
    birthDate,
    gender,
    country,
    province,
    city,
    postalCode,
    street,
    maritalStatus,
    language,
    departmentId,
    departmentName,
    departmentArabic,
    supervisor,
    role,
    title,
    titleArabic,
    workLocation,
    drivingLicenseId,
    carPlates,
  ];

  static const Set<String> optional = {
    number,
    passport,
    passportExpiration,
    gender,
    country,
    province,
    city,
    postalCode,
    street,
    language,
    supervisor,
    role,
    workLocation,
    drivingLicenseId,
    carPlates,
  };

  /// Header aliases accepted from the Active Directory export layout.
  static const Map<String, String> activeDirectoryAliases = {
    'First Name Arabic': firstNameArabic,
    'Middle Name Arabic': middleNameArabic,
    'Last Name Arabic': lastNameArabic,
    'Marital Status': maritalStatus,
    'Title In Arabic': titleArabic,
  };

  static bool isRequired(String header) => !optional.contains(header);
}
