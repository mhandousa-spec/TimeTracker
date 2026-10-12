// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_entity.dart
// Purpose: Defines the HR employee entity used throughout the HR module.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import '../../../h3_add_employee/utils/add_employee_currency_option.dart';
import '../../../h3_add_employee/utils/add_employee_days_off_option.dart';
import '../../../h3_add_employee/utils/add_employee_degree_option.dart';
import '../../../h3_add_employee/utils/add_employee_employee_grade_option.dart';
import '../../../h3_add_employee/utils/add_employee_field_of_study_option.dart';
import '../../../h3_add_employee/utils/add_employee_gender_option.dart';
import '../../../h3_add_employee/utils/add_employee_issuing_authority_option.dart';
import '../../../h3_add_employee/utils/add_employee_job_type_option.dart';
import '../../../h3_add_employee/utils/add_employee_language_option.dart';
import '../../../h3_add_employee/utils/add_employee_marital_status_option.dart';
import '../../../h3_add_employee/utils/add_employee_relationship_option.dart';
import '../../../h3_add_employee/utils/add_employee_remote_status_option.dart';
import '../../../h3_add_employee/utils/add_employee_work_arrangement_option.dart';
import '../../../h3_add_employee/utils/add_employee_work_location_option.dart';
import '../../../../roles/r4_active_directory/domain/entities/employee_entity.dart';

/// HR employee entity with typed access to add-employee selector values.
class HrEmployeeEntity extends EmployeeEntityPro {
  HrEmployeeEntity({
    super.id,
    super.firstName,
    super.middleName,
    super.lastName,
    super.firstNameInArabic,
    super.middleNameInArabic,
    super.lastNameInArabic,
    super.nationalId,
    super.nationalIdExpirationDate,
    super.nationality,
    super.passport,
    super.passportExpirationDate,
    super.email,
    super.mobilePhone,
    super.officePhone,
    super.homePhone,
    super.officePhoneNumber,
    super.homePhoneNumber,
    super.firstEmergencyPhone,
    super.secondEmergencyPhone,
    super.extension,
    super.birthDay,
    super.gender,
    super.country,
    super.province,
    super.city,
    super.postalCode,
    super.street,
    super.maritalStatus,
    super.language,
    super.departmentId,
    super.supervisor,
    super.role,
    super.title,
    super.titleInArabic,
    super.workLocation,
    super.drivingLicenseId,
    super.carPlates,
    super.academicHistory,
    super.bio,
    super.photo,
    super.skills,
    super.hobbies,
    super.status,
    super.personalEmail,
    super.homeCountryCode,
    super.officeCountryCode,
    super.jobType,
    super.workArrangement,
    super.remoteStatus,
    super.employeeGrade,
    super.startDate,
    super.startTime,
    super.endTime,
    super.daysOff,
    super.salary,
    super.currency,
    super.institutionName,
    super.degree,
    super.fieldOfStudy,
    super.certificationStartDate,
    super.certificationEndDate,
    super.gradeOrScore,
    super.certificateId,
    super.issuingAuthority,
    super.certificationDocumentUrl,
    super.certificationNotes,
    super.insuranceName,
    super.insurancePolicyNumber,
    super.insuranceProviderContact,
    super.firstContactFirstName,
    super.firstContactLastName,
    super.firstContactRelationship,
    super.firstContactEmail,
    super.firstContactPhone,
    super.firstContactLanguage,
    super.firstContactCountry,
    super.firstContactProvince,
    super.firstContactCity,
    super.firstContactStreet,
    super.firstContactFirstNameArabic,
    super.firstContactLastNameArabic,
    super.secondContactFirstName,
    super.secondContactLastName,
    super.secondContactRelationship,
    super.secondContactEmail,
    super.secondContactPhone,
    super.secondContactLanguage,
    super.secondContactCountry,
    super.secondContactProvince,
    super.secondContactCity,
    super.secondContactStreet,
    super.secondContactFirstNameArabic,
    super.secondContactLastNameArabic,
    super.passportDocumentUrl,
    super.nationalIdFrontUrl,
    super.nationalIdBackUrl,
    super.drivingLicenseDocumentUrl,
    super.password,
    super.defaultPassword,
    super.firstLogin,
    super.lastLogin,
    super.deactivationDate,
    super.activationDate,
  });

  /// Method Name: [getFirstAndLastName]
  ///
  /// Purpose: Returns the English employee name without the middle name for
  /// compact HR presentations.
  ///
  /// Returns: The trimmed English first and last name.
  String getFirstAndLastName() {
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Method Name: [getFirstAndLastNameArabic]
  ///
  /// Purpose: Returns the Arabic employee name without the middle name for
  /// compact HR presentations.
  ///
  /// Returns: The trimmed Arabic first and last name.
  String getFirstAndLastNameArabic() {
    return '${firstNameInArabic ?? ''} ${lastNameInArabic ?? ''}'.trim();
  }

  /// Method Name: [firstNameForLanguage]
  ///
  /// Purpose: Resolves the employee's first name for the active table locale.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the caller requires the English value.
  ///
  /// Returns: The requested first name, or the English value when Arabic is
  /// unavailable.
  String firstNameForLanguage({required bool isEnglish}) {
    return _valueForLanguage(
      englishValue: firstName,
      arabicValue: firstNameInArabic,
      isEnglish: isEnglish,
    );
  }

  /// Method Name: [middleNameForLanguage]
  ///
  /// Purpose: Resolves the employee's middle name for the active detail locale.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the caller requires the English value.
  ///
  /// Returns: The requested middle name, or the English value when Arabic is
  /// unavailable.
  String middleNameForLanguage({required bool isEnglish}) {
    return _valueForLanguage(
      englishValue: middleName,
      arabicValue: middleNameInArabic,
      isEnglish: isEnglish,
    );
  }

  /// Method Name: [lastNameForLanguage]
  ///
  /// Purpose: Resolves the employee's last name for the active table locale.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the caller requires the English value.
  ///
  /// Returns: The requested last name, or the English value when Arabic is
  /// unavailable.
  String lastNameForLanguage({required bool isEnglish}) {
    return _valueForLanguage(
      englishValue: lastName,
      arabicValue: lastNameInArabic,
      isEnglish: isEnglish,
    );
  }

  /// Method Name: [jobTitleForLanguage]
  ///
  /// Purpose: Resolves the employee's job title for the active table locale.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the caller requires the English value.
  ///
  /// Returns: The requested title, or the English value when Arabic is
  /// unavailable.
  String jobTitleForLanguage({required bool isEnglish}) {
    return _valueForLanguage(
      englishValue: title,
      arabicValue: titleInArabic,
      isEnglish: isEnglish,
    );
  }

  /// Method Name: [fullNameForLanguage]
  ///
  /// Purpose: Builds a complete employee name with language fallback applied to
  /// every individual name component.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether the caller requires English values.
  ///
  /// Returns: The localized full name without empty name segments.
  String fullNameForLanguage({required bool isEnglish}) {
    return [
      firstNameForLanguage(isEnglish: isEnglish),
      middleNameForLanguage(isEnglish: isEnglish),
      lastNameForLanguage(isEnglish: isEnglish),
    ].where((value) => value.isNotEmpty).join(' ');
  }

  /// Method Name: [_valueForLanguage]
  ///
  /// Purpose: Returns a localized employee value while preventing blank Arabic
  /// table cells when older records lack Arabic data.
  ///
  /// Parameters:
  /// - [englishValue]: Stored English field value.
  /// - [arabicValue]: Stored Arabic field value.
  /// - [isEnglish]: Whether the English value is requested.
  ///
  /// Returns: The requested value, with English fallback for missing Arabic.
  String _valueForLanguage({
    required String? englishValue,
    required String? arabicValue,
    required bool isEnglish,
  }) {
    if (isEnglish) return englishValue?.trim() ?? '';
    final localizedValue = arabicValue?.trim() ?? '';
    return localizedValue.isEmpty
        ? (englishValue?.trim() ?? '')
        : localizedValue;
  }

  /// Method Name: [fromEmployee]
  ///
  /// Purpose: Converts a base employee into the HR module employee type.
  ///
  /// Parameters:
  /// - [employee]: Base employee loaded by the Active Directory module.
  ///
  /// Returns: An HR employee containing the complete employee data.
  factory HrEmployeeEntity.fromEmployee(EmployeeEntityPro employee) {
    return HrEmployeeEntity(
      id: employee.id,
      firstName: employee.firstName,
      middleName: employee.middleName,
      lastName: employee.lastName,
      firstNameInArabic: employee.firstNameInArabic,
      middleNameInArabic: employee.middleNameInArabic,
      lastNameInArabic: employee.lastNameInArabic,
      nationalId: employee.nationalId,
      nationalIdExpirationDate: employee.nationalIdExpirationDate,
      nationality: employee.nationality,
      passport: employee.passport,
      passportExpirationDate: employee.passportExpirationDate,
      email: employee.email,
      mobilePhone: employee.mobilePhone,
      officePhone: employee.officePhone,
      homePhone: employee.homePhone,
      officePhoneNumber: employee.officePhoneNumber,
      homePhoneNumber: employee.homePhoneNumber,
      firstEmergencyPhone: employee.firstEmergencyPhone,
      secondEmergencyPhone: employee.secondEmergencyPhone,
      extension: employee.extension,
      birthDay: employee.birthDay,
      gender: employee.gender,
      country: employee.country,
      province: employee.province,
      city: employee.city,
      postalCode: employee.postalCode,
      street: employee.street,
      maritalStatus: employee.maritalStatus,
      language: employee.language,
      departmentId: employee.departmentId,
      supervisor: employee.supervisor,
      role: employee.role,
      title: employee.title,
      titleInArabic: employee.titleInArabic,
      workLocation: employee.workLocation,
      drivingLicenseId: employee.drivingLicenseId,
      carPlates: employee.carPlates,
      academicHistory: employee.academicHistory,
      bio: employee.bio,
      photo: employee.photo,
      skills: employee.skills,
      hobbies: employee.hobbies,
      status: employee.status,
      personalEmail: employee.personalEmail,
      homeCountryCode: employee.homeCountryCode,
      officeCountryCode: employee.officeCountryCode,
      jobType: employee.jobType,
      workArrangement: employee.workArrangement,
      remoteStatus: employee.remoteStatus,
      employeeGrade: employee.employeeGrade,
      startDate: employee.startDate,
      startTime: employee.startTime,
      endTime: employee.endTime,
      daysOff: employee.daysOff,
      salary: employee.salary,
      currency: employee.currency,
      institutionName: employee.institutionName,
      degree: employee.degree,
      fieldOfStudy: employee.fieldOfStudy,
      certificationStartDate: employee.certificationStartDate,
      certificationEndDate: employee.certificationEndDate,
      gradeOrScore: employee.gradeOrScore,
      certificateId: employee.certificateId,
      issuingAuthority: employee.issuingAuthority,
      certificationDocumentUrl: employee.certificationDocumentUrl,
      certificationNotes: employee.certificationNotes,
      insuranceName: employee.insuranceName,
      insurancePolicyNumber: employee.insurancePolicyNumber,
      insuranceProviderContact: employee.insuranceProviderContact,
      firstContactFirstName: employee.firstContactFirstName,
      firstContactLastName: employee.firstContactLastName,
      firstContactRelationship: employee.firstContactRelationship,
      firstContactEmail: employee.firstContactEmail,
      firstContactPhone: employee.firstContactPhone,
      firstContactLanguage: employee.firstContactLanguage,
      firstContactCountry: employee.firstContactCountry,
      firstContactProvince: employee.firstContactProvince,
      firstContactCity: employee.firstContactCity,
      firstContactStreet: employee.firstContactStreet,
      firstContactFirstNameArabic: employee.firstContactFirstNameArabic,
      firstContactLastNameArabic: employee.firstContactLastNameArabic,
      secondContactFirstName: employee.secondContactFirstName,
      secondContactLastName: employee.secondContactLastName,
      secondContactRelationship: employee.secondContactRelationship,
      secondContactEmail: employee.secondContactEmail,
      secondContactPhone: employee.secondContactPhone,
      secondContactLanguage: employee.secondContactLanguage,
      secondContactCountry: employee.secondContactCountry,
      secondContactProvince: employee.secondContactProvince,
      secondContactCity: employee.secondContactCity,
      secondContactStreet: employee.secondContactStreet,
      secondContactFirstNameArabic: employee.secondContactFirstNameArabic,
      secondContactLastNameArabic: employee.secondContactLastNameArabic,
      passportDocumentUrl: employee.passportDocumentUrl,
      nationalIdFrontUrl: employee.nationalIdFrontUrl,
      nationalIdBackUrl: employee.nationalIdBackUrl,
      drivingLicenseDocumentUrl: employee.drivingLicenseDocumentUrl,
      password: employee.password,
      defaultPassword: employee.defaultPassword,
      firstLogin: employee.firstLogin,
      lastLogin: employee.lastLogin,
      deactivationDate: employee.deactivationDate,
      activationDate: employee.activationDate,
    );
  }

  GenderOption? get genderEnum => _byName(GenderOption.values, gender);
  MaritalStatusOption? get maritalStatusEnum =>
      _byName(MaritalStatusOption.values, maritalStatus);
  LanguageOption? get languageEnum => _byName(LanguageOption.values, language);
  JobTypeOption? get jobTypeEnum => _byName(JobTypeOption.values, jobType);
  WorkArrangementOption? get workArrangementEnum =>
      _byName(WorkArrangementOption.values, workArrangement);
  RemoteStatusOption? get remoteStatusEnum =>
      _byName(RemoteStatusOption.values, remoteStatus);
  WorkLocationOption? get workLocationEnum =>
      _byName(WorkLocationOption.values, workLocation);
  EmployeeGradeOption? get employeeGradeEnum =>
      _byName(EmployeeGradeOption.values, employeeGrade);
  DaysOffOption? get daysOffEnum => _byName(DaysOffOption.values, daysOff);
  DegreeOption? get degreeEnum => _byName(DegreeOption.values, degree);
  FieldOfStudyOption? get fieldOfStudyEnum =>
      _byName(FieldOfStudyOption.values, fieldOfStudy);
  IssuingAuthorityOption? get issuingAuthorityEnum =>
      _byName(IssuingAuthorityOption.values, issuingAuthority);
  CurrencyOption? get currencyEnum => _byName(CurrencyOption.values, currency);
  RelationshipOption? get firstContactRelationshipEnum =>
      _byName(RelationshipOption.values, firstContactRelationship);
  LanguageOption? get firstContactLanguageEnum =>
      _byName(LanguageOption.values, firstContactLanguage);
  RelationshipOption? get secondContactRelationshipEnum =>
      _byName(RelationshipOption.values, secondContactRelationship);
  LanguageOption? get secondContactLanguageEnum =>
      _byName(LanguageOption.values, secondContactLanguage);

  T? _byName<T extends Enum>(List<T> values, String? value) {
    if (value == null || value.isEmpty) return null;
    for (final item in values) {
      if (item.name == value) return item;
    }
    return null;
  }
}
