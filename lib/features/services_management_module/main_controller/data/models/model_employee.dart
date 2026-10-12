// ******************* FILE INFO *******************
// File Name: model_employee
// Description: Employee DTO used by the services module (serialisation to/from Firestore).
// Module: services_management_module / data / models
// *************************************************

import 'package:knowticed_plus/core/helper/main_helper/phone_number.dart';

class ServicesMobilePhoneEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String PHONE = 'phone';
  static const String COUNTRY_CODE = 'countryCode';
  static const String COUNTRY_APP = 'countryApp';

  final String? phone;
  final String? countryCode;
  final String? countryApp;

  ServicesMobilePhoneEntity({
    this.phone,
    this.countryCode,
    this.countryApp,
  });
  factory ServicesMobilePhoneEntity.fromMobilePhoneEntity(
      PhoneNumber entity) {
    return ServicesMobilePhoneEntity(
      phone: entity.phone,
      countryCode: entity.countryCode,
      countryApp: entity.countryApp,
    );
  }
  factory ServicesMobilePhoneEntity.fromJson(Map<String, dynamic> json) {
    return ServicesMobilePhoneEntity(
      phone: json[PHONE],
      countryCode: json[COUNTRY_CODE],
      countryApp: json[COUNTRY_APP],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PHONE: phone,
      COUNTRY_CODE: countryCode,
      COUNTRY_APP: countryApp,
    };
  }
}

class AcademicHistoryEntity {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String GPA = 'gpa';
  static const String GRADUATE_FROM = 'graduateFrom';
  static const String UNIVERSITY = 'university';
  static const String YEAR_OF_GRADUATION = 'yearOfGraduation';
  static const String GRADUATE_FROM_STATUS = 'graduateFromStatus';
  static const String UNIVERSITY_STATUS = 'universityStatus';
  static const String YEAR_OF_GRADUATION_STATUS = 'yearOfGraduationStatus';
  static const String GPA_STATUS = 'gpaStatus';

  final String? gpa;
  final String? graduateFrom;
  final String? university;
  final String? yearOfGraduation;
  final String? graduateFromStatus;
  final String? universityStatus;
  final String? yearOfGraduationStatus;
  final String? gpaStatus;

  AcademicHistoryEntity({
    this.gpa,
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
  });

  factory AcademicHistoryEntity.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryEntity(
      gpa: json[GPA],
      graduateFrom: json[GRADUATE_FROM],
      university: json[UNIVERSITY],
      yearOfGraduation: json[YEAR_OF_GRADUATION],
      graduateFromStatus: json[GRADUATE_FROM_STATUS],
      universityStatus: json[UNIVERSITY_STATUS],
      yearOfGraduationStatus: json[YEAR_OF_GRADUATION_STATUS],
      gpaStatus: json[GPA_STATUS],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      GPA: gpa,
      GRADUATE_FROM: graduateFrom,
      UNIVERSITY: university,
      YEAR_OF_GRADUATION: yearOfGraduation,
      GRADUATE_FROM_STATUS: graduateFromStatus,
      UNIVERSITY_STATUS: universityStatus,
      YEAR_OF_GRADUATION_STATUS: yearOfGraduationStatus,
      GPA_STATUS: gpaStatus,
    };
  }
}

class EmployeeEntityModell {
  // ---- Firestore field keys (in-class, SCREAMING_SNAKE_CASE) ----
  static const String ID = 'id';
  static const String STATE = 'state';
  static const String FIRST_NAME = 'firstName';
  static const String MIDDLE_NAME = 'middleName';
  static const String LAST_NAME = 'lastName';
  static const String FIRST_NAME_IN_ARABIC = 'firstNameInArabic';
  static const String MIDDLE_NAME_IN_ARABIC = 'middleNameInArabic';
  static const String LAST_NAME_IN_ARABIC = 'lastNameInArabic';
  static const String NATIONAL_ID = 'nationalId';
  static const String NATIONAL_ID_EXPIRATION_DATE = 'nationalIdExpirationDate';
  static const String NATIONALITY = 'nationality';
  static const String PASSPORT = 'passport';
  static const String PASSPORT_EXPIRATION_DATE = 'passportExpirationDate';
  static const String EMAIL = 'email';
  static const String MOBILE_PHONE = 'mobilePhone';
  static const String OFFICE_PHONE = 'officePhone';
  static const String HOME_PHONE = 'homePhone';
  static const String EXTENSION = 'extension';
  static const String BIRTH_DAY = 'birthDay';
  static const String GENDER = 'gender';
  static const String COUNTRY = 'country';
  static const String IMAGE_URL = 'imageUrl';
  static const String PROVINCE = 'province';
  static const String CITY = 'city';
  static const String POSTAL_CODE = 'postalCode';
  static const String STREET = 'street';
  static const String MARITAL_STATUS = 'maritalStatus';
  static const String LANGUAGE = 'language';
  static const String DEPARTMENT_ID = 'departmentId';
  static const String SUPERVISOR = 'supervisor';
  static const String ROLE = 'role';
  static const String TITLE = 'title';
  static const String TITLE_IN_ARABIC = 'titleInArabic';
  static const String WORK_LOCATION = 'workLocation';
  static const String DRIVING_LICENSE_ID = 'drivingLicenseId';
  static const String CAR_PLATES = 'carPlates';
  static const String ACADEMIC_HISTORY = 'academicHistory';
  static const String BIO = 'bio';
  static const String PHOTO = 'photo';
  static const String SKILLS = 'skills';
  static const String HOBBIES = 'hobbies';
  static const String STATUS = 'status';
  static const String FIRST_LOGIN = 'firstLogin';
  static const String LAST_LOGIN = 'lastLogin';
  static const String DEACTIVATION_DATE = 'deactivationDate';
  static const String ACTIVATION_DATE = 'activationDate';

  final String? id;

  final String? state;
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
  final ServicesMobilePhoneEntity? mobilePhone;
  final String? officePhone;
  final String? homePhone;
  final String? extension;
  final String? birthDay;
  final String? gender;
  final String? country;
  final String? imageUrl;
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
  final String? firstLogin;
  final String? lastLogin;
  final String? deactivationDate;
  final String? activationDate;

  EmployeeEntityModell({
    this.id,
    this.state,
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
    this.extension,
    this.birthDay,
    this.gender,
    this.country,
    this.imageUrl,
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
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });





  EmployeeEntityModell copyWith({
    String? id,
    String? state,
    String? firstName,
    String? middleName,
    String? lastName,
    String? firstNameInArabic,
    String? middleNameInArabic,
    String? lastNameInArabic,
    String? nationalId,
    String? nationalIdExpirationDate,
    String? nationality,
    String? passport,
    String? passportExpirationDate,
    String? email,
    ServicesMobilePhoneEntity? mobilePhone,
    String? officePhone,
    String? homePhone,
    String? extension,
    String? birthDay,
    String? gender,
    String? country,
    String? imageUrl,
    String? province,
    String? city,
    String? postalCode,
    String? street,
    String? maritalStatus,
    String? language,
    String? departmentId,
    String? supervisor,
    String? role,
    String? title,
    String? titleInArabic,
    String? workLocation,
    String? drivingLicenseId,
    List<String?>? carPlates,
    AcademicHistoryEntity? academicHistory,
    String? bio,
    String? photo,
    List<String?>? skills,
    List<String?>? hobbies,
    String? status,
    String? firstLogin,
    String? lastLogin,
    String? deactivationDate,
    String? activationDate,
  }) {
    return EmployeeEntityModell(
      id: id ?? this.id,
      state: state ?? this.state,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      middleNameInArabic: middleNameInArabic ?? this.middleNameInArabic,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      nationalId: nationalId ?? this.nationalId,
      nationalIdExpirationDate: nationalIdExpirationDate ?? this.nationalIdExpirationDate,
      nationality: nationality ?? this.nationality,
      passport: passport ?? this.passport,
      passportExpirationDate: passportExpirationDate ?? this.passportExpirationDate,
      email: email ?? this.email,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      officePhone: officePhone ?? this.officePhone,
      homePhone: homePhone ?? this.homePhone,
      extension: extension ?? this.extension,
      birthDay: birthDay ?? this.birthDay,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      language: language ?? this.language,
      departmentId: departmentId ?? this.departmentId,
      supervisor: supervisor ?? this.supervisor,
      role: role ?? this.role,
      title: title ?? this.title,
      titleInArabic: titleInArabic ?? this.titleInArabic,
      workLocation: workLocation ?? this.workLocation,
      drivingLicenseId: drivingLicenseId ?? this.drivingLicenseId,
      carPlates: carPlates ?? this.carPlates,
      academicHistory: academicHistory ?? this.academicHistory,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      skills: skills ?? this.skills,
      hobbies: hobbies ?? this.hobbies,
      status: status ?? this.status,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      activationDate: activationDate ?? this.activationDate,
    );
  }


  factory EmployeeEntityModell.fromEntity(dynamic entity) {
    if (entity is EmployeeEntityModell) return entity;

    return EmployeeEntityModell(
      id: entity.id,
      state: entity.state,
      firstName: entity.firstName,
      middleName: entity.middleName,
      lastName: entity.lastName,
      firstNameInArabic: entity.firstNameInArabic,
      middleNameInArabic: entity.middleNameInArabic,
      lastNameInArabic: entity.lastNameInArabic,
      nationalId: entity.nationalId,
      nationalIdExpirationDate: entity.nationalIdExpirationDate,
      nationality: entity.nationality,
      passport: entity.passport,
      passportExpirationDate: entity.passportExpirationDate,
      email: entity.email,
      mobilePhone: entity.mobilePhone,
      officePhone: entity.officePhone,
      homePhone: entity.homePhone,
      extension: entity.extension,
      birthDay: entity.birthDay,
      gender: entity.gender,
      country: entity.country,
      imageUrl: entity.imageUrl,
      province: entity.province,
      city: entity.city,
      postalCode: entity.postalCode,
      street: entity.street,
      maritalStatus: entity.maritalStatus,
      language: entity.language,
      departmentId: entity.departmentId,
      supervisor: entity.supervisor,
      role: entity.role,
      title: entity.title,
      titleInArabic: entity.titleInArabic,
      workLocation: entity.workLocation,
      drivingLicenseId: entity.drivingLicenseId,
      carPlates: entity.carPlates,
      academicHistory: entity.academicHistory,
      bio: entity.bio,
      photo: entity.photo,
      skills: entity.skills,
      hobbies: entity.hobbies,
      status: entity.status,
      firstLogin: entity.firstLogin,
      lastLogin: entity.lastLogin,
      deactivationDate: entity.deactivationDate,
      activationDate: entity.activationDate,
    );
  }



  factory EmployeeEntityModell.fromJson(Map<String, dynamic> json) {
    return EmployeeEntityModell(
      id: json[ID],
      state: json[STATE],
      firstName: json[FIRST_NAME],
      middleName: json[MIDDLE_NAME],
      lastName: json[LAST_NAME],
      firstNameInArabic: json[FIRST_NAME_IN_ARABIC],
      middleNameInArabic: json[MIDDLE_NAME_IN_ARABIC],
      lastNameInArabic: json[LAST_NAME_IN_ARABIC],
      nationalId: json[NATIONAL_ID],
      nationalIdExpirationDate: json[NATIONAL_ID_EXPIRATION_DATE],
      nationality: json[NATIONALITY],
      passport: json[PASSPORT],
      passportExpirationDate: json[PASSPORT_EXPIRATION_DATE],
      email: json[EMAIL],
      mobilePhone: json[MOBILE_PHONE] != null
          ? ServicesMobilePhoneEntity.fromJson(json[MOBILE_PHONE])
          : null,
      officePhone: json[OFFICE_PHONE],
      homePhone: json[HOME_PHONE],
      extension: json[EXTENSION],
      birthDay: json[BIRTH_DAY],
      gender: json[GENDER],
      country: json[COUNTRY],
      imageUrl: json[IMAGE_URL],
      province: json[PROVINCE],
      city: json[CITY],
      postalCode: json[POSTAL_CODE],
      street: json[STREET],
      maritalStatus: json[MARITAL_STATUS],
      language: json[LANGUAGE],
      departmentId: json[DEPARTMENT_ID],
      supervisor: json[SUPERVISOR],
      role: json[ROLE],
      title: json[TITLE],
      titleInArabic: json[TITLE_IN_ARABIC],
      workLocation: json[WORK_LOCATION],
      drivingLicenseId: json[DRIVING_LICENSE_ID],
      carPlates: (json[CAR_PLATES] as List?)?.cast<String?>(),
      academicHistory: json[ACADEMIC_HISTORY] != null
          ? AcademicHistoryEntity.fromJson(json[ACADEMIC_HISTORY])
          : null,
      bio: json[BIO],
      photo: json[PHOTO],
      skills: (json[SKILLS] as List?)?.cast<String?>(),
      hobbies: (json[HOBBIES] as List?)?.cast<String?>(),
      status: json[STATUS],
      firstLogin: json[FIRST_LOGIN],
      lastLogin: json[LAST_LOGIN],
      deactivationDate: json[DEACTIVATION_DATE],
      activationDate: json[ACTIVATION_DATE],
    );
  }

  // Canonical map serialization (§10) — delegates to toJson()/fromJson().
  Map<String, dynamic> toMap() => toJson();

  factory EmployeeEntityModell.fromMap(Map<String, dynamic> map) =>
      EmployeeEntityModell.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      ID: id,
      STATE: state,
      FIRST_NAME: firstName,
      MIDDLE_NAME: middleName,
      LAST_NAME: lastName,
      FIRST_NAME_IN_ARABIC: firstNameInArabic,
      MIDDLE_NAME_IN_ARABIC: middleNameInArabic,
      LAST_NAME_IN_ARABIC: lastNameInArabic,
      NATIONAL_ID: nationalId,
      NATIONAL_ID_EXPIRATION_DATE: nationalIdExpirationDate,
      NATIONALITY: nationality,
      PASSPORT: passport,
      PASSPORT_EXPIRATION_DATE: passportExpirationDate,
      EMAIL: email,
      MOBILE_PHONE: mobilePhone?.toJson(),
      OFFICE_PHONE: officePhone,
      HOME_PHONE: homePhone,
      EXTENSION: extension,
      BIRTH_DAY: birthDay,
      GENDER: gender,
      COUNTRY: country,
      IMAGE_URL: imageUrl,
      PROVINCE: province,
      CITY: city,
      POSTAL_CODE: postalCode,
      STREET: street,
      MARITAL_STATUS: maritalStatus,
      LANGUAGE: language,
      DEPARTMENT_ID: departmentId,
      SUPERVISOR: supervisor,
      ROLE: role,
      TITLE: title,
      TITLE_IN_ARABIC: titleInArabic,
      WORK_LOCATION: workLocation,
      DRIVING_LICENSE_ID: drivingLicenseId,
      CAR_PLATES: carPlates,
      ACADEMIC_HISTORY: academicHistory?.toJson(),
      BIO: bio,
      PHOTO: photo,
      SKILLS: skills,
      HOBBIES: hobbies,
      STATUS: status,
      FIRST_LOGIN: firstLogin,
      LAST_LOGIN: lastLogin,
      DEACTIVATION_DATE: deactivationDate,
      ACTIVATION_DATE: activationDate,
    };
  }
}