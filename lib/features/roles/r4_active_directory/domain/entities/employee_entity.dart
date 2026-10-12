/// Module: roles / r4_active_directory / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: employee_entity.dart
/// Purpose: Declares `EmployeeEntityController`, `EmployeeEntityPro`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/home_phone_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/office_phone_model.dart';

import '../../data/models/employees_model/mobile_phone_model.dart';
import '../../data/models/employees_model/new_employee_model.dart';
import '../../data/models/employees_model/academic_history_current_entity.dart';
import 'package:knowticed_plus/core/helper/main_helper/phone_number.dart';

class EmployeeEntityController {
  /// Converts NewEmployeeModelHistory to EmployeeEntity (PRIMARY METHOD)
  HrEmployeeEntity fromHistoryModel(NewEmployeeModelHistory model) {
    return HrEmployeeEntity(
      id: model.id,
      firstName: model.firstName.lastOrNull,
      middleName: model.middleName.lastOrNull,
      lastName: model.lastName.lastOrNull,
      firstNameInArabic: model.firstNameInArabic.lastOrNull,
      middleNameInArabic: model.middleNameInArabic.lastOrNull,
      lastNameInArabic: model.lastNameInArabic.lastOrNull,
      nationalId: model.nationalId.lastOrNull,
      nationalIdExpirationDate: model.nationalIdExpirationDate.lastOrNull,
      nationality: model.nationality.lastOrNull,
      passport: model.passport.lastOrNull,
      passportExpirationDate: model.passportExpirationDate.lastOrNull,
      email: model.email.lastOrNull,
      mobilePhone: _extractMobilePhone(model.mobilePhone),
      officePhone: model.officePhone.lastOrNull,
      homePhone: model.homePhone.lastOrNull,
      officePhoneNumber: _extractOfficePhone(model.officePhoneDetails),
      homePhoneNumber: _extractHomePhone(model.homePhoneDetails),
      firstEmergencyPhone: _extractMobilePhone(model.firstContactPhoneDetails),
      secondEmergencyPhone:
      _extractMobilePhone(model.secondContactPhoneDetails),
      extension: model.extension.lastOrNull,
      birthDay: model.birthDay.lastOrNull,
      gender: model.gender.lastOrNull,
      country: model.country.lastOrNull,
      province: model.province.lastOrNull,
      city: model.city.lastOrNull,
      postalCode: model.postalCode.lastOrNull,
      street: model.street.lastOrNull,
      maritalStatus: model.maritalStatus.lastOrNull,
      language: model.language.lastOrNull,
      departmentId: model.departmentId.lastOrNull,
      supervisor: model.supervisor.lastOrNull,
      role: model.role.lastOrNull,
      title: model.title.lastOrNull,
      titleInArabic: model.titleInArabic.lastOrNull,
      workLocation: model.workLocation.lastOrNull,
      drivingLicenseId: model.drivingLicenseId.lastOrNull,
      carPlates: model.carPlates.lastOrNull,
      academicHistory: _extractAcademicHistory(model.academicHistory),
      bio: model.bio.lastOrNull,
      photo: model.photo.lastOrNull,
      skills: model.skills.lastOrNull,
      hobbies: model.hobbies.lastOrNull,
      status: model.status.lastOrNull,
      personalEmail: model.personalEmail.lastOrNull,
      homeCountryCode: model.homeCountryCode.lastOrNull,
      officeCountryCode: model.officeCountryCode.lastOrNull,
      jobType: model.jobType.lastOrNull,
      workArrangement: model.workArrangement.lastOrNull,
      remoteStatus: model.remoteStatus.lastOrNull,
      employeeGrade: model.employeeGrade.lastOrNull,
      startDate: model.startDate.lastOrNull,
      startTime: model.startTime.lastOrNull,
      endTime: model.endTime.lastOrNull,
      daysOff: model.daysOff.lastOrNull,
      salary: model.salary.lastOrNull,
      currency: model.currency.lastOrNull,
      institutionName: model.institutionName.lastOrNull,
      degree: model.degree.lastOrNull,
      fieldOfStudy: model.fieldOfStudy.lastOrNull,
      certificationStartDate: model.certificationStartDate.lastOrNull,
      certificationEndDate: model.certificationEndDate.lastOrNull,
      gradeOrScore: model.gradeOrScore.lastOrNull,
      certificateId: model.certificateId.lastOrNull,
      issuingAuthority: model.issuingAuthority.lastOrNull,
      certificationDocumentUrl: model.certificationDocumentUrl.lastOrNull,
      certificationNotes: model.certificationNotes.lastOrNull,
      insuranceName: model.insuranceName.lastOrNull,
      insurancePolicyNumber: model.insurancePolicyNumber.lastOrNull,
      insuranceProviderContact: model.insuranceProviderContact.lastOrNull,
      firstContactFirstName: model.firstContactFirstName.lastOrNull,
      firstContactLastName: model.firstContactLastName.lastOrNull,
      firstContactRelationship: model.firstContactRelationship.lastOrNull,
      firstContactEmail: model.firstContactEmail.lastOrNull,
      firstContactPhone: model.firstContactPhone.lastOrNull,
      firstContactLanguage: model.firstContactLanguage.lastOrNull,
      firstContactCountry: model.firstContactCountry.lastOrNull,
      firstContactProvince: model.firstContactProvince.lastOrNull,
      firstContactCity: model.firstContactCity.lastOrNull,
      firstContactStreet: model.firstContactStreet.lastOrNull,
      firstContactFirstNameArabic: model.firstContactFirstNameArabic.lastOrNull,
      firstContactLastNameArabic: model.firstContactLastNameArabic.lastOrNull,
      secondContactFirstName: model.secondContactFirstName.lastOrNull,
      secondContactLastName: model.secondContactLastName.lastOrNull,
      secondContactRelationship: model.secondContactRelationship.lastOrNull,
      secondContactEmail: model.secondContactEmail.lastOrNull,
      secondContactPhone: model.secondContactPhone.lastOrNull,
      secondContactLanguage: model.secondContactLanguage.lastOrNull,
      secondContactCountry: model.secondContactCountry.lastOrNull,
      secondContactProvince: model.secondContactProvince.lastOrNull,
      secondContactCity: model.secondContactCity.lastOrNull,
      secondContactStreet: model.secondContactStreet.lastOrNull,
      secondContactFirstNameArabic:
      model.secondContactFirstNameArabic.lastOrNull,
      secondContactLastNameArabic: model.secondContactLastNameArabic.lastOrNull,
      passportDocumentUrl: model.passportDocumentUrl.lastOrNull,
      nationalIdFrontUrl: model.nationalIdFrontUrl.lastOrNull,
      nationalIdBackUrl: model.nationalIdBackUrl.lastOrNull,
      drivingLicenseDocumentUrl: model.drivingLicenseDocumentUrl.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    );
  }

  /// Converts List<NewEmployeeModelHistory> to List<EmployeeEntity> (PRIMARY METHOD)
  List<HrEmployeeEntity> fromHistoryModelList(
      List<NewEmployeeModelHistory> models) {
    return models.map((model) => fromHistoryModel(model)).toList();
  }

  /// Helper method to extract mobile phone from history list
  static PhoneNumber? _extractMobilePhone(List<MobilePhone> mobilePhoneList) {
    if (mobilePhoneList.isEmpty) return null;

    MobilePhone lastPhone = mobilePhoneList.last;
    return PhoneNumber(
      countryISOCode: '',
      // FIXED 28/9/2026 (GRC bug report p6): these are history LISTS, and
      // `.toString()` on a list printed the brackets — the phone showed up as
      // "[4321614168]". Take the latest entry, like home/office phone do.
      number: lastPhone.phones?.lastOrNull ?? '',
      countryCode: lastPhone.countryCode?.lastOrNull ?? '',
      countryApp: lastPhone.countryApp?.lastOrNull,
    );
  }

  /// Method Name: [_extractHomePhone]
  ///
  /// Purpose: Converts the latest structured home-phone history value.
  ///
  /// Parameters:
  /// - [phoneList]: Structured home-phone history values.
  ///
  /// Returns: The latest normalized phone value, or null.
  static PhoneNumber? _extractHomePhone(List<HomePhone> phoneList) {
    if (phoneList.isEmpty) return null;
    final phone = phoneList.last;
    return _createPhoneNumber(
      number: phone.phones?.lastOrNull,
      countryCode: phone.countryCode?.lastOrNull,
      countryApp: phone.countryApp?.lastOrNull,
    );
  }

  /// Method Name: [_extractOfficePhone]
  ///
  /// Purpose: Converts the latest structured office-phone history value.
  ///
  /// Parameters:
  /// - [phoneList]: Structured office-phone history values.
  ///
  /// Returns: The latest normalized phone value, or null.
  static PhoneNumber? _extractOfficePhone(List<OfficePhone> phoneList) {
    if (phoneList.isEmpty) return null;
    final phone = phoneList.last;
    return _createPhoneNumber(
      number: phone.phones?.lastOrNull,
      countryCode: phone.countryCode?.lastOrNull,
      countryApp: phone.countryApp?.lastOrNull,
    );
  }

  /// Method Name: [_createPhoneNumber]
  ///
  /// Purpose: Creates a normalized phone only when a number is available.
  ///
  /// Parameters:
  /// - [number]: National phone number.
  /// - [countryCode]: International dial code.
  /// - [countryApp]: Application country marker.
  ///
  /// Returns: A normalized phone value, or null.
  static PhoneNumber? _createPhoneNumber({
    required String? number,
    required String? countryCode,
    String? countryApp,
  }) {
    if (number == null || number.trim().isEmpty) return null;
    return PhoneNumber(
      countryISOCode: '',
      number: number,
      countryCode: countryCode ?? '',
      countryApp: countryApp,
    );
  }

  /// Helper method to extract academic history from history list
  static AcademicHistoryEntity? _extractAcademicHistory(
      List<Map<String, dynamic>> academicHistoryList) {
    if (academicHistoryList.isEmpty) return null;

    Map<String, dynamic> lastHistory = academicHistoryList.last;
    return AcademicHistoryEntity(
      gpa: lastHistory['gpa']?.toString(),
      graduateFrom: lastHistory['graduateFrom']?.toString(),
      university: lastHistory['university']?.toString(),
      yearOfGraduation: lastHistory['yearOfGraduation']?.toString(),
      graduateFromStatus: lastHistory['graduateFromStatus']?.toString(),
      universityStatus: lastHistory['universityStatus']?.toString(),
      yearOfGraduationStatus: lastHistory['yearOfGraduationStatus']?.toString(),
      gpaStatus: lastHistory['gpaStatus']?.toString(),
    );
  }

  // ========================================================================
  // LEGACY SUPPORT (Keep for backward compatibility if needed)
  // ========================================================================

  /// Converts NewEmployeeModel to EmployeeEntity (Legacy support)
  EmployeeEntityPro fromModel(NewEmployeeModel model) {
    return EmployeeEntityPro(
      id: model.id,
      firstName: model.firstName?.firstNames?.lastOrNull,
      middleName: model.middleName?.middleName?.lastOrNull,
      lastName: model.lastName?.lastNames?.lastOrNull,
      firstNameInArabic:
      model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
      middleNameInArabic:
      model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
      lastNameInArabic: model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
      nationalId: model.nationalId?.nationalId?.lastOrNull,
      nationalIdExpirationDate:
      model.nationalIdExpirationDate?.nationalIdExpirationDate?.lastOrNull,
      nationality: model.nationality?.nationality?.lastOrNull,
      passport: model.passport?.passport?.lastOrNull,
      passportExpirationDate:
      model.passportExpirationDate?.passportExpirationDate?.lastOrNull,
      email: model.email?.emails?.lastOrNull,
      mobilePhone: PhoneNumber(
          countryISOCode: '',
          number: model.mobilePhone?.phones?.lastOrNull ?? '',
          countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
          countryApp: model.mobilePhone?.countryApp?.lastOrNull),
      officePhone: model.officePhone?.phones?.lastOrNull,
      homePhone: model.homePhone?.phones?.lastOrNull,
      extension: model.extension?.extension?.lastOrNull,
      birthDay: model.birthDay?.birthDays?.lastOrNull,
      gender: model.gender?.gender?.lastOrNull,
      country: model.country?.country?.lastOrNull,
      province: model.province?.province?.lastOrNull,
      city: model.city?.city?.lastOrNull,
      postalCode: model.postalCode?.postalCode?.lastOrNull,
      street: model.street?.street?.lastOrNull,
      maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
      language: model.language?.languages?.lastOrNull,
      departmentId: model.departmentid?.departmentId?.lastOrNull,
      supervisor: model.supervisor?.supervisors?.lastOrNull,
      role: model.role?.role?.lastOrNull,
      title: model.title?.title?.lastOrNull,
      titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
      workLocation: model.workLocation?.workLocation?.lastOrNull,
      drivingLicenseId: model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
      carPlates: model.carPlates?.carPlates,
      academicHistory: AcademicHistoryEntity(
        gpa: model.academicHistory?.gpa?.lastOrNull,
        graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
        university: model.academicHistory?.university?.lastOrNull,
        yearOfGraduation: model.academicHistory?.yearOfGraduation?.lastOrNull,
        graduateFromStatus:
        model.academicHistory?.graduateFromStatus?.lastOrNull,
        universityStatus: model.academicHistory?.universityStatus?.lastOrNull,
        yearOfGraduationStatus:
        model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
        gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
      ),
      bio: model.bio?.bio?.lastOrNull,
      photo: model.photo?.photos?.lastOrNull,
      skills: model.skills?.skills,
      hobbies: model.hobbies?.hobbies,
      status: model.status?.status?.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    );
  }

  /// Converts List<NewEmployeeModel> to List<EmployeeEntity> (Legacy support)
  List<EmployeeEntityPro> fromModelList(List<NewEmployeeModel> models) {
    return models
        .map((model) => EmployeeEntityPro(
      id: model.id,
      firstName: model.firstName?.firstNames?.lastOrNull,
      middleName: model.middleName?.middleName?.lastOrNull,
      lastName: model.lastName?.lastNames?.lastOrNull,
      firstNameInArabic:
      model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
      middleNameInArabic:
      model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
      lastNameInArabic:
      model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
      nationalId: model.nationalId?.nationalId?.lastOrNull,
      nationalIdExpirationDate: model.nationalIdExpirationDate
          ?.nationalIdExpirationDate?.lastOrNull,
      nationality: model.nationality?.nationality?.lastOrNull,
      passport: model.passport?.passport?.lastOrNull,
      passportExpirationDate: model
          .passportExpirationDate?.passportExpirationDate?.lastOrNull,
      email: model.email?.emails?.lastOrNull,
      mobilePhone: PhoneNumber(
        countryISOCode: '',
        number: model.mobilePhone?.phones?.lastOrNull ?? '',
        countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
        countryApp: model.mobilePhone?.countryApp?.lastOrNull,
      ),
      officePhone: model.officePhone?.phones?.lastOrNull,
      homePhone: model.homePhone?.phones?.lastOrNull,
      extension: model.extension?.extension?.lastOrNull,
      birthDay: model.birthDay?.birthDays?.lastOrNull,
      gender: model.gender?.gender?.lastOrNull,
      country: model.country?.country?.lastOrNull,
      province: model.province?.province?.lastOrNull,
      city: model.city?.city?.lastOrNull,
      postalCode: model.postalCode?.postalCode?.lastOrNull,
      street: model.street?.street?.lastOrNull,
      maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
      language: model.language?.languages?.lastOrNull,
      departmentId: model.departmentid?.departmentId?.lastOrNull,
      supervisor: model.supervisor?.supervisors?.lastOrNull,
      role: model.role?.role?.lastOrNull,
      title: model.title?.title?.lastOrNull,
      titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
      workLocation: model.workLocation?.workLocation?.lastOrNull,
      drivingLicenseId:
      model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
      carPlates: model.carPlates?.carPlates,
      academicHistory: AcademicHistoryEntity(
        gpa: model.academicHistory?.gpa?.lastOrNull,
        graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
        university: model.academicHistory?.university?.lastOrNull,
        yearOfGraduation:
        model.academicHistory?.yearOfGraduation?.lastOrNull,
        graduateFromStatus:
        model.academicHistory?.graduateFromStatus?.lastOrNull,
        universityStatus:
        model.academicHistory?.universityStatus?.lastOrNull,
        yearOfGraduationStatus:
        model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
        gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
      ),
      bio: model.bio?.bio?.lastOrNull,
      photo: model.photo?.photos?.lastOrNull,
      skills: model.skills?.skills,
      hobbies: model.hobbies?.hobbies,
      status: model.status?.status?.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    ))
        .toList();
  }
}

class EmployeeEntityPro {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? nationalId;
  final String? nationalIdExpirationDate;
  final String? nationality;
  final String? passport;
  final String? passportExpirationDate;
  final String? email;
  final PhoneNumber? mobilePhone;
  final String? officePhone;
  final String? homePhone;
  final PhoneNumber? officePhoneNumber;
  final PhoneNumber? homePhoneNumber;
  final PhoneNumber? firstEmergencyPhone;
  final PhoneNumber? secondEmergencyPhone;
  final String? extension;
  final String? birthDay;
  final String? gender;
  final String? country;
  final String? province;
  final String? city;
  final String? postalCode;
  final String? street;
  final String? maritalStatus;
  final String? language;
  final String? departmentId;
  final String? supervisor;
  final String? role;
  final String? title;
  final String? titleInArabic;
  final String? workLocation;
  final String? drivingLicenseId;
  final List<String?>? carPlates;
  final AcademicHistoryEntity? academicHistory;
  final String? bio;
  final String? photo;
  final List<String?>? skills;
  final List<String?>? hobbies;
  final String? status;
  final String? personalEmail;
  final String? homeCountryCode;
  final String? officeCountryCode;
  final String? jobType;
  final String? workArrangement;
  final String? remoteStatus;
  final String? employeeGrade;
  final String? startDate;
  final String? startTime;
  final String? endTime;
  final String? daysOff;
  final String? salary;
  final String? currency;
  final String? institutionName;
  final String? degree;
  final String? fieldOfStudy;
  final String? certificationStartDate;
  final String? certificationEndDate;
  final String? gradeOrScore;
  final String? certificateId;
  final String? issuingAuthority;
  final String? certificationDocumentUrl;
  final String? certificationNotes;
  final String? insuranceName;
  final String? insurancePolicyNumber;
  final String? insuranceProviderContact;
  final String? firstContactFirstName;
  final String? firstContactLastName;
  final String? firstContactRelationship;
  final String? firstContactEmail;
  final String? firstContactPhone;
  final String? firstContactLanguage;
  final String? firstContactCountry;
  final String? firstContactProvince;
  final String? firstContactCity;
  final String? firstContactStreet;
  final String? firstContactFirstNameArabic;
  final String? firstContactMiddleName;
  final String? firstContactMiddleNameArabic;
  final String? firstContactLastNameArabic;
  final String? secondContactFirstName;
  final String? secondContactLastName;
  final String? secondContactRelationship;
  final String? secondContactEmail;
  final String? secondContactPhone;
  final String? secondContactLanguage;
  final String? secondContactCountry;
  final String? secondContactProvince;
  final String? secondContactCity;
  final String? secondContactStreet;
  final String? secondContactFirstNameArabic;
  final String? secondContactMiddleName;
  final String? secondContactMiddleNameArabic;
  final String? secondContactLastNameArabic;
  final String? passportDocumentUrl;
  final String? nationalIdFrontUrl;
  final String? nationalIdBackUrl;
  final String? drivingLicenseDocumentUrl;
  final String? password;
  final String? defaultPassword;
  final String? firstLogin;
  final String? lastLogin;
  final String? deactivationDate;
  final String? activationDate;

  EmployeeEntityPro({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.nationalId,
    this.nationalIdExpirationDate,
    this.nationality,
    this.passport,
    this.passportExpirationDate,
    this.email,
    this.mobilePhone,
    this.officePhone,
    this.homePhone,
    this.officePhoneNumber,
    this.homePhoneNumber,
    this.firstEmergencyPhone,
    this.secondEmergencyPhone,
    this.extension,
    this.birthDay,
    this.gender,
    this.country,
    this.province,
    this.city,
    this.postalCode,
    this.street,
    this.maritalStatus,
    this.language,
    this.departmentId,
    this.supervisor,
    this.role,
    this.title,
    this.titleInArabic,
    this.workLocation,
    this.drivingLicenseId,
    this.carPlates,
    this.academicHistory,
    this.bio,
    this.photo,
    this.skills,
    this.hobbies,
    this.status,
    this.personalEmail,
    this.homeCountryCode,
    this.officeCountryCode,
    this.jobType,
    this.workArrangement,
    this.remoteStatus,
    this.employeeGrade,
    this.startDate,
    this.startTime,
    this.endTime,
    this.daysOff,
    this.salary,
    this.currency,
    this.institutionName,
    this.degree,
    this.fieldOfStudy,
    this.certificationStartDate,
    this.certificationEndDate,
    this.gradeOrScore,
    this.certificateId,
    this.issuingAuthority,
    this.certificationDocumentUrl,
    this.certificationNotes,
    this.insuranceName,
    this.insurancePolicyNumber,
    this.insuranceProviderContact,
    this.firstContactFirstName,
    this.firstContactLastName,
    this.firstContactRelationship,
    this.firstContactEmail,
    this.firstContactPhone,
    this.firstContactLanguage,
    this.firstContactCountry,
    this.firstContactProvince,
    this.firstContactCity,
    this.firstContactStreet,
    this.firstContactFirstNameArabic,
    this.firstContactMiddleName,
    this.firstContactMiddleNameArabic,
    this.firstContactLastNameArabic,
    this.secondContactFirstName,
    this.secondContactLastName,
    this.secondContactRelationship,
    this.secondContactEmail,
    this.secondContactPhone,
    this.secondContactLanguage,
    this.secondContactCountry,
    this.secondContactProvince,
    this.secondContactCity,
    this.secondContactStreet,
    this.secondContactFirstNameArabic,
    this.secondContactMiddleName,
    this.secondContactMiddleNameArabic,
    this.secondContactLastNameArabic,
    this.passportDocumentUrl,
    this.nationalIdFrontUrl,
    this.nationalIdBackUrl,
    this.drivingLicenseDocumentUrl,
    this.password,
    this.defaultPassword,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });

  /// Checks if the employee is a manager
  bool isManager() {
    return title?.toLowerCase().contains('manager') ?? false;
  }

  /// Gets full name in English
  String getFullName() {
    return '${firstName ?? ''} ${middleName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Gets full name in Arabic
  String getFullNameArabic() {
    return '${firstNameInArabic ?? ''} ${middleNameInArabic ?? ''} ${lastNameInArabic ?? ''}'
        .trim();
  }

  /// Checks if employee is active
  bool isActive() {
    return status?.toLowerCase() == 'active';
  }

  /// Checks if employee is deactivated
  bool isDeactivated() {
    return status?.toLowerCase() == 'deactivated';
  }
}

// class EmployeeEntityController {
//   /// Converts NewEmployeeModelHistory to EmployeeEntity (PRIMARY METHOD)
//   EmployeeEntityPro fromHistoryModel(NewEmployeeModelHistory model) {
//     return EmployeeEntityPro(
//       id: model.id,
//       firstName: model.firstName.lastOrNull,
//       middleName: model.middleName.lastOrNull,
//       lastName: model.lastName.lastOrNull,
//       firstNameInArabic: model.firstNameInArabic.lastOrNull,
//       middleNameInArabic: model.middleNameInArabic.lastOrNull,
//       lastNameInArabic: model.lastNameInArabic.lastOrNull,
//       nationalId: model.nationalId.lastOrNull,
//       nationalIdExpirationDate: model.nationalIdExpirationDate.lastOrNull,
//       nationality: model.nationality.lastOrNull,
//       passport: model.passport.lastOrNull,
//       passportExpirationDate: model.passportExpirationDate.lastOrNull,
//       email: model.email.lastOrNull,
//       mobilePhone: _extractMobilePhone(model.mobilePhone),
//       officePhone: model.officePhone.lastOrNull,
//       homePhone: model.homePhone.lastOrNull,
//       extension: model.extension.lastOrNull,
//       birthDay: model.birthDay.lastOrNull,
//       gender: model.gender.lastOrNull,
//       country: model.country.lastOrNull,
//       province: model.province.lastOrNull,
//       city: model.city.lastOrNull,
//       postalCode: model.postalCode.lastOrNull,
//       street: model.street.lastOrNull,
//       maritalStatus: model.maritalStatus.lastOrNull,
//       language: model.language.lastOrNull,
//       departmentId: model.departmentId.lastOrNull,
//       supervisor: model.supervisor.lastOrNull,
//       role: model.role.lastOrNull,
//       title: model.title.lastOrNull,
//       titleInArabic: model.titleInArabic.lastOrNull,
//       workLocation: model.workLocation.lastOrNull,
//       drivingLicenseId: model.drivingLicenseId.lastOrNull,
//       carPlates: model.carPlates.lastOrNull,
//       academicHistory: _extractAcademicHistory(model.academicHistory),
//       bio: model.bio.lastOrNull,
//       photo: model.photo.lastOrNull,
//       skills: model.skills.lastOrNull,
//       hobbies: model.hobbies.lastOrNull,
//       status: model.status.lastOrNull,
//       password: model.password,
//       defaultPassword: model.defaultPassword,
//       firstLogin: model.firstLogin,
//       lastLogin: model.lastLogin,
//       deactivationDate: model.deactivationDate,
//       activationDate: model.activationDate,
//     );
//   }
//
//   /// Converts List<NewEmployeeModelHistory> to List<EmployeeEntity> (PRIMARY METHOD)
//   List<EmployeeEntityPro> fromHistoryModelList(List<NewEmployeeModelHistory> models) {
//     return models.map((model) => fromHistoryModel(model)).toList();
//   }
//
//   /// Helper method to extract mobile phone from history list
//   static PhoneNumber? _extractMobilePhone(List<MobilePhone> mobilePhoneList) {
//     if (mobilePhoneList.isEmpty) return null;
//
//     MobilePhone lastPhone = mobilePhoneList.last;
//     return PhoneNumber(
//       countryISOCode: '',
//       number: lastPhone.phones?.toString() ?? '',
//       countryCode: lastPhone.countryCode?.toString() ?? '',
//       countryApp: lastPhone.countryApp?.toString(),
//     );
//   }
//
//   /// Helper method to extract academic history from history list
//   static AcademicHistoryEntity? _extractAcademicHistory(List<Map<String, dynamic>> academicHistoryList) {
//     if (academicHistoryList.isEmpty) return null;
//
//     Map<String, dynamic> lastHistory = academicHistoryList.last;
//     return AcademicHistoryEntity(
//       gpa: lastHistory['gpa']?.toString(),
//       graduateFrom: lastHistory['graduateFrom']?.toString(),
//       university: lastHistory['university']?.toString(),
//       yearOfGraduation: lastHistory['yearOfGraduation']?.toString(),
//       graduateFromStatus: lastHistory['graduateFromStatus']?.toString(),
//       universityStatus: lastHistory['universityStatus']?.toString(),
//       yearOfGraduationStatus: lastHistory['yearOfGraduationStatus']?.toString(),
//       gpaStatus: lastHistory['gpaStatus']?.toString(),
//     );
//   }
//
//   // ========================================================================
//   // LEGACY SUPPORT (Keep for backward compatibility if needed)
//   // ========================================================================
//
//   /// Converts NewEmployeeModel to EmployeeEntity (Legacy support)
//   EmployeeEntityPro fromModel(NewEmployeeModel model) {
//     return EmployeeEntityPro(
//       id: model.id,
//       firstName: model.firstName?.firstNames?.lastOrNull,
//       middleName: model.middleName?.middleName?.lastOrNull,
//       lastName: model.lastName?.lastNames?.lastOrNull,
//       firstNameInArabic:
//       model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
//       middleNameInArabic:
//       model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
//       lastNameInArabic: model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
//       nationalId: model.nationalId?.nationalId?.lastOrNull,
//       nationalIdExpirationDate:
//       model.nationalIdExpirationDate?.nationalIdExpirationDate?.lastOrNull,
//       nationality: model.nationality?.nationality?.lastOrNull,
//       passport: model.passport?.passport?.lastOrNull,
//       passportExpirationDate:
//       model.passportExpirationDate?.passportExpirationDate?.lastOrNull,
//       email: model.email?.emails?.lastOrNull,
//       mobilePhone: PhoneNumber(
//           countryISOCode: '',
//           number: model.mobilePhone?.phones?.lastOrNull ?? '',
//           countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
//           countryApp: model.mobilePhone?.countryApp?.lastOrNull),
//       officePhone: model.officePhone?.phones?.lastOrNull,
//       homePhone: model.homePhone?.phones?.lastOrNull,
//       extension: model.extension?.extension?.lastOrNull,
//       birthDay: model.birthDay?.birthDays?.lastOrNull,
//       gender: model.gender?.gender?.lastOrNull,
//       country: model.country?.country?.lastOrNull,
//       province: model.province?.province?.lastOrNull,
//       city: model.city?.city?.lastOrNull,
//       postalCode: model.postalCode?.postalCode?.lastOrNull,
//       street: model.street?.street?.lastOrNull,
//       maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
//       language: model.language?.languages?.lastOrNull,
//       departmentId: model.departmentid?.departmentId?.lastOrNull,
//       supervisor: model.supervisor?.supervisors?.lastOrNull,
//       role: model.role?.role?.lastOrNull,
//       title: model.title?.title?.lastOrNull,
//       titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
//       workLocation: model.workLocation?.workLocation?.lastOrNull,
//       drivingLicenseId: model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
//       carPlates: model.carPlates?.carPlates,
//       academicHistory: AcademicHistoryEntity(
//         gpa: model.academicHistory?.gpa?.lastOrNull,
//         graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
//         university: model.academicHistory?.university?.lastOrNull,
//         yearOfGraduation: model.academicHistory?.yearOfGraduation?.lastOrNull,
//         graduateFromStatus:
//         model.academicHistory?.graduateFromStatus?.lastOrNull,
//         universityStatus: model.academicHistory?.universityStatus?.lastOrNull,
//         yearOfGraduationStatus:
//         model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
//         gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
//       ),
//       bio: model.bio?.bio?.lastOrNull,
//       photo: model.photo?.photos?.lastOrNull,
//       skills: model.skills?.skills,
//       hobbies: model.hobbies?.hobbies,
//       status: model.status?.status?.lastOrNull,
//       password: model.password,
//       defaultPassword: model.defaultPassword,
//       firstLogin: model.firstLogin,
//       lastLogin: model.lastLogin,
//       deactivationDate: model.deactivationDate,
//       activationDate: model.activationDate,
//     );
//   }
//
//   /// Converts List<NewEmployeeModel> to List<EmployeeEntity> (Legacy support)
//   List<EmployeeEntityPro> fromModelList(List<NewEmployeeModel> models) {
//     return models
//         .map((model) => EmployeeEntityPro(
//       id: model.id,
//       firstName: model.firstName?.firstNames?.lastOrNull,
//       middleName: model.middleName?.middleName?.lastOrNull,
//       lastName: model.lastName?.lastNames?.lastOrNull,
//       firstNameInArabic:
//       model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
//       middleNameInArabic:
//       model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
//       lastNameInArabic:
//       model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
//       nationalId: model.nationalId?.nationalId?.lastOrNull,
//       nationalIdExpirationDate: model.nationalIdExpirationDate
//           ?.nationalIdExpirationDate?.lastOrNull,
//       nationality: model.nationality?.nationality?.lastOrNull,
//       passport: model.passport?.passport?.lastOrNull,
//       passportExpirationDate: model
//           .passportExpirationDate?.passportExpirationDate?.lastOrNull,
//       email: model.email?.emails?.lastOrNull,
//       mobilePhone: PhoneNumber(
//         countryISOCode: '',
//         number: model.mobilePhone?.phones?.lastOrNull ?? '',
//         countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
//         countryApp: model.mobilePhone?.countryApp?.lastOrNull,
//       ),
//       officePhone: model.officePhone?.phones?.lastOrNull,
//       homePhone: model.homePhone?.phones?.lastOrNull,
//       extension: model.extension?.extension?.lastOrNull,
//       birthDay: model.birthDay?.birthDays?.lastOrNull,
//       gender: model.gender?.gender?.lastOrNull,
//       country: model.country?.country?.lastOrNull,
//       province: model.province?.province?.lastOrNull,
//       city: model.city?.city?.lastOrNull,
//       postalCode: model.postalCode?.postalCode?.lastOrNull,
//       street: model.street?.street?.lastOrNull,
//       maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
//       language: model.language?.languages?.lastOrNull,
//       departmentId: model.departmentid?.departmentId?.lastOrNull,
//       supervisor: model.supervisor?.supervisors?.lastOrNull,
//       role: model.role?.role?.lastOrNull,
//       title: model.title?.title?.lastOrNull,
//       titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
//       workLocation: model.workLocation?.workLocation?.lastOrNull,
//       drivingLicenseId:
//       model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
//       carPlates: model.carPlates?.carPlates,
//       academicHistory: AcademicHistoryEntity(
//         gpa: model.academicHistory?.gpa?.lastOrNull,
//         graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
//         university: model.academicHistory?.university?.lastOrNull,
//         yearOfGraduation:
//         model.academicHistory?.yearOfGraduation?.lastOrNull,
//         graduateFromStatus:
//         model.academicHistory?.graduateFromStatus?.lastOrNull,
//         universityStatus:
//         model.academicHistory?.universityStatus?.lastOrNull,
//         yearOfGraduationStatus:
//         model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
//         gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
//       ),
//       bio: model.bio?.bio?.lastOrNull,
//       photo: model.photo?.photos?.lastOrNull,
//       skills: model.skills?.skills,
//       hobbies: model.hobbies?.hobbies,
//       status: model.status?.status?.lastOrNull,
//       password: model.password,
//       defaultPassword: model.defaultPassword,
//       firstLogin: model.firstLogin,
//       lastLogin: model.lastLogin,
//       deactivationDate: model.deactivationDate,
//       activationDate: model.activationDate,
//     ))
//         .toList();
//   }
// }
//
// class EmployeeEntityPro {
//   final String? id;
//   final String? firstName;
//   final String? middleName;
//   final String? lastName;
//   final String? firstNameInArabic;
//   final String? middleNameInArabic;
//   final String? lastNameInArabic;
//   final String? nationalId;
//   final String? nationalIdExpirationDate;
//   final String? nationality;
//   final String? passport;
//   final String? passportExpirationDate;
//   final String? email;
//   final PhoneNumber? mobilePhone;
//   final String? officePhone;
//   final String? homePhone;
//   final String? extension;
//   final String? birthDay;
//   final String? gender;
//   final String? country;
//   final String? province;
//   final String? city;
//   final String? postalCode;
//   final String? street;
//   final String? maritalStatus;
//   final String? language;
//   final String? departmentId;
//   final String? supervisor;
//   final String? role;
//   final String? title;
//   final String? titleInArabic;
//   final String? workLocation;
//   final String? drivingLicenseId;
//   final List<String?>? carPlates;
//   final AcademicHistoryEntity? academicHistory;
//   final String? bio;
//   final String? photo;
//   final List<String?>? skills;
//   final List<String?>? hobbies;
//   final String? status;
//   final String? password;
//   final String? defaultPassword;
//   final String? firstLogin;
//   final String? lastLogin;
//   final String? deactivationDate;
//   final String? activationDate;
//
//   EmployeeEntityPro({
//     this.id,
//     this.firstName,
//     this.middleName,
//     this.lastName,
//     this.firstNameInArabic,
//     this.middleNameInArabic,
//     this.lastNameInArabic,
//     this.nationalId,
//     this.nationalIdExpirationDate,
//     this.nationality,
//     this.passport,
//     this.passportExpirationDate,
//     this.email,
//     this.mobilePhone,
//     this.officePhone,
//     this.homePhone,
//     this.extension,
//     this.birthDay,
//     this.gender,
//     this.country,
//     this.province,
//     this.city,
//     this.postalCode,
//     this.street,
//     this.maritalStatus,
//     this.language,
//     this.departmentId,
//     this.supervisor,
//     this.role,
//     this.title,
//     this.titleInArabic,
//     this.workLocation,
//     this.drivingLicenseId,
//     this.carPlates,
//     this.academicHistory,
//     this.bio,
//     this.photo,
//     this.skills,
//     this.hobbies,
//     this.status,
//     this.password,
//     this.defaultPassword,
//     this.firstLogin,
//     this.lastLogin,
//     this.deactivationDate,
//     this.activationDate,
//   });
//
//   /// Checks if the employee is a manager
//   bool isManager() {
//     return title?.toLowerCase().contains('manager') ?? false;
//   }
//
//   /// Gets full name in English
//   String getFullName() {
//     return '${firstName ?? ''} ${middleName ?? ''} ${lastName ?? ''}'.trim();
//   }
//
//   /// Gets full name in Arabic
//   String getFullNameArabic() {
//     return '${firstNameInArabic ?? ''} ${middleNameInArabic ?? ''} ${lastNameInArabic ?? ''}'.trim();
//   }
//
//   /// Checks if employee is active
//   bool isActive() {
//     return status?.toLowerCase() == 'active';
//   }
//
//   /// Checks if employee is deactivated
//   bool isDeactivated() {
//     return status?.toLowerCase() == 'deactivated';
//   }
// }
