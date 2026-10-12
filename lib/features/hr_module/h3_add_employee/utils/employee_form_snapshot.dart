// ***************************** FILE INFO ***************************** //
// File Name: employee_form_snapshot.dart
// Purpose: Captures immutable add-employee form values for submission.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

/// Immutable values captured from the employee form before persistence starts.
class EmployeeFormSnapshot {
  EmployeeFormSnapshot({
    required Map<EmployeeFormField, String> values,
    required List<String> selectedLanguages,
    this.profileImagePath,
    this.passportDocumentPath,
    this.nationalIdFrontDocumentPath,
    this.nationalIdBackDocumentPath,
    this.drivingLicenseDocumentPath,
    this.certificationDocumentPath,
  })  : values = Map.unmodifiable(Map.of(values)),
        selectedLanguages = List.unmodifiable(List.of(selectedLanguages));

  final Map<EmployeeFormField, String> values;
  final List<String> selectedLanguages;
  final String? profileImagePath;
  final String? passportDocumentPath;
  final String? nationalIdFrontDocumentPath;
  final String? nationalIdBackDocumentPath;
  final String? drivingLicenseDocumentPath;
  final String? certificationDocumentPath;

  /// Method Name: [value]
  ///
  /// Purpose: Returns one captured form value without exposing controllers.
  ///
  /// Parameters:
  /// - [field]: Stable field identifier to read.
  ///
  /// Returns: The captured trimmed value, or an empty string.
  String value(EmployeeFormField field) => values[field]?.trim() ?? '';
}

/// Stable identifiers for values captured from the employee form.
enum EmployeeFormField {
  employeeId,
  firstName,
  middleName,
  lastName,
  firstNameArabic,
  middleNameArabic,
  lastNameArabic,
  nationalId,
  nationalIdExpirationDate,
  nationality,
  passport,
  passportExpirationDate,
  personalEmail,
  businessEmail,
  mobileCountryCode,
  mobileNumber,
  homeCountryCode,
  homeNumber,
  officeCountryCode,
  officeNumber,
  extension,
  birthDay,
  gender,
  country,
  province,
  city,
  postalCode,
  street,
  maritalStatus,
  departmentId,
  title,
  workLocation,
  drivingLicenseId,
  carPlates,
  jobType,
  workArrangement,
  remoteStatus,
  employeeGrade,
  startDate,
  startTime,
  endTime,
  daysOff,
  salary,
  currency,
  institutionName,
  degree,
  fieldOfStudy,
  certificationStartDate,
  certificationEndDate,
  gradeOrScore,
  certificateId,
  issuingAuthority,
  certificationNotes,
  insuranceName,
  insurancePolicyNumber,
  insuranceProviderContact,
  firstEmergencyFirstName,
  firstEmergencyLastName,
  firstEmergencyFirstNameArabic,
  firstEmergencyLastNameArabic,
  firstEmergencyRelationship,
  firstEmergencyEmail,
  firstEmergencyCountryCode,
  firstEmergencyMobile,
  firstEmergencyCountry,
  firstEmergencyProvince,
  firstEmergencyCity,
  firstEmergencyStreet,
  firstEmergencyLanguage,
  secondEmergencyFirstName,
  secondEmergencyLastName,
  secondEmergencyFirstNameArabic,
  secondEmergencyLastNameArabic,
  secondEmergencyRelationship,
  secondEmergencyEmail,
  secondEmergencyCountryCode,
  secondEmergencyMobile,
  secondEmergencyCountry,
  secondEmergencyProvince,
  secondEmergencyCity,
  secondEmergencyStreet,
  secondEmergencyLanguage,
}
