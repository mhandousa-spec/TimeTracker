// ignore_for_file: prefer_null_aware_operators

/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: new_employee_model.dart
/// Purpose: Declares `NewEmployeeModel`, `NewEmployeeModelHistory`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header; removed
///          the no-op `try/catch { rethrow }` around `fromMap`, the dead nested
///          `_createFieldMap`, and the GetX dependency; the two remaining empty
///          catches now log instead of swallowing.
///
/// KNOWN DEBT (from the r4 code review, not yet closed):
/// - ~1,590 LOC against a 200-LOC cap for models, and it declares two model
///   classes (`NewEmployeeModel`, `NewEmployeeModelHistory`). Splitting needs
///   new files, which the current change set is not allowed to add.
/// - Fields are mutable and there are no `static const` key constants; `toMap`
///   types its Firestore keys inline. Making the fields final requires a
///   const/final constructor plus updating every mutation site across the CSV
///   import path — a change that must be compiler-verified, not hand-checked.
/// - Two `try/catch` blocks remain in `_parseMobilePhoneList`. §11.2 forbids
///   try/catch under `data/models/`; they belong in a `data/utils/` parser
///   alongside the rest of the `_parse*` helpers.

import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import './city_model.dart';
import './country_model.dart';
import './province_model.dart';
import './academic_model.dart';
import './department_model.dart';
import './first_name_arabic_model.dart';
import './first_name_model.dart';
import './job_location_model.dart';
import './last_name_model.dart';
import './middle_name_model.dart';
import './bio_model.dart';
import './bio_in_arabic_model.dart';
import './birthday_model.dart';
import './email_model.dart';
import './gender_model.dart';
import './hobbies_model.dart';
import './language_model.dart';
import './last_name_arabic_model.dart';
import './marital_status_model.dart';
import './middle_name_arabic_model.dart';
import './national_id_date_model.dart';
import './national_id_model.dart';
import './nationality_model.dart';
import './passport_date_model.dart';
import './passport_model.dart';
import './postal_code_model.dart';
import './role_model.dart';
import './skills_model.dart';
import './status_model.dart';
import './title_arabic_model.dart';
import './title_model.dart';
import './car_plates_model.dart';
import './driving_license_id.dart';
import './employee_photo_model.dart';
import './extension_model.dart';
import './home_phone_model.dart';
import './supervisor_model.dart';
import './mobile_phone_model.dart';
import './office_phone_model.dart';
import './street_model.dart';




class NewEmployeeModel {
  String? id;
  FirstName? firstName;
  MiddleName? middleName;
  LastName? lastName;
  FirstNameInArabic? firstNameInArabic;
  MiddleNameInArabic? middleNameInArabic;
  LastNameInArabic? lastNameInArabic;
  NationalId? nationalId;
  NationalIdExpirationDate? nationalIdExpirationDate;
  Nationality? nationality;
  Passport? passport;
  PassportExpirationDate? passportExpirationDate;
  Email? email;
  MobilePhone? mobilePhone;
  OfficePhone? officePhone;
  HomePhone? homePhone;
  Extension? extension;
  BirthDay? birthDay;
  Gender? gender;
  Country? country;
  Province? province;
  City? city;
  PostalCode? postalCode;
  Street? street;
  MaritalStatus? maritalStatus;
  Language? language;
  DepartmentId? departmentid;
  Supervisor? supervisor;
  Role? role;
  TitleModel? title;
  TitleInArabic? titleInArabic;
  WorkLocation? workLocation;
  DrivingLicenseId? drivingLicenseId;
  CarPlates? carPlates;
  AcademicHistory? academicHistory;
  Bio? bio;
  BioInArabic? bioInArabic;
  Photo? photo;
  Skills? skills;
  Hobbies? hobbies;
  Status? status;
  String? password;
  String? defaultPassword;
  String? firstLogin;
  String? lastLogin;
  String? deactivationDate;
  String? activationDate;

  NewEmployeeModel({
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
    this.departmentid,
    this.supervisor,
    this.role,
    this.title,
    this.titleInArabic,
    this.workLocation,
    this.drivingLicenseId,
    this.carPlates,
    this.academicHistory,
    this.bio,
    this.bioInArabic,
    this.photo,
    this.skills,
    this.hobbies,
    this.status,
    this.password,
    this.defaultPassword,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });

  factory NewEmployeeModel.fromMap(Map? data) {
    return NewEmployeeModel(
      id: data?['Id'],
      firstName: FirstName.fromMap(data?['First_Name']),
      middleName: MiddleName.fromMap(data?['Middle_Name']),
      lastName: LastName.fromMap(data?['Last_Name']),
      firstNameInArabic:
      FirstNameInArabic.fromMap(data?['First_Name_In_Arabic']),
      middleNameInArabic:
      MiddleNameInArabic.fromMap(data?['Middle_Name_In_Arabic']),
      lastNameInArabic: LastNameInArabic.fromMap(data?['Last_Name_In_Arabic']),
      nationalId: data?['National_Id'] == null
          ? null
          : NationalId.fromMap(data?['National_Id']),
      nationalIdExpirationDate: data?['National_Id_Expiration_Date'] == null
          ? null
          : NationalIdExpirationDate.fromMap(
          data?['National_Id_Expiration_Date']),
      nationality: data?['Nationality'] == null
          ? null
          : Nationality.fromMap(data?['Nationality']),
      passport: data?['Passport'] == null
          ? null
          : Passport.fromMap(data?['Passport']),
      passportExpirationDate:
      PassportExpirationDate.fromMap(data?['Passport_Expiration_Date']),
      email: Email.fromMap(data?['Email']),
      mobilePhone: MobilePhone.fromMap(data?['Mobile_Phone']),
      officePhone: OfficePhone.fromMap(data?['Office_Phone']),
      homePhone: HomePhone.fromMap(data?['Home_Phone']),
      extension: Extension.fromMap(data?['Extension']),
      birthDay: data?['Birth_Day'] == null
          ? null
          : BirthDay.fromMap(data?['Birth_Day']),
      gender: data?['Gender'] == null ? null : Gender.fromMap(data?['Gender']),
      country:
      data?['Country'] == null ? null : Country.fromMap(data?['Country']),
      province: data?['Province'] == null
          ? null
          : Province.fromMap(data?['Province']),
      city: data?['City'] == null ? null : City.fromMap(data?['City']),
      postalCode: data?['Postal_Code'] == null
          ? null
          : PostalCode.fromMap(data?['Postal_Code']),
      street: data?['Street'] == null ? null : Street.fromMap(data?['Street']),
      maritalStatus: data?['Marital_Status'] == null
          ? null
          : MaritalStatus.fromMap(data?['Marital_Status']),
      language: data?['Language'] == null
          ? null
          : Language.fromMap(data?['Language']),
      departmentid: DepartmentId.fromMap(data?['Department_Id']),
      supervisor: Supervisor.fromMap(data?['Supervisor']),
      role: Role.fromMap(data?['Role']),
      workLocation: data?['Work_Location'] == null
          ? null
          : WorkLocation.fromMap(data?['Work_Location']),
      drivingLicenseId: data?['Driving_License_Id'] == null
          ? null
          : DrivingLicenseId.fromMap(data?['Driving_License_Id']),
      carPlates: data?['Car_Plates'] == null
          ? null
          : CarPlates.fromMap(data?['Car_Plates']),
      academicHistory: data?['Academic_History'] == null
          ? null
          : AcademicHistory.fromMap(data?['Academic_History']),
      bio: data?['Bio'] == null ? null : Bio.fromMap(data?['Bio']),
      bioInArabic: data?['Bio_In_Arabic'] == null
          ? null
          : BioInArabic.fromMap(data?['Bio_In_Arabic']),
      skills: data?['Skills'] == null ? null : Skills.fromMap(data?['Skills']),
      hobbies:
      data?['Hobbies'] == null ? null : Hobbies.fromMap(data?['Hobbies']),
      status: Status.fromMap(data?['Status']),
      photo: data?['Photo'] == null ? null : Photo.fromMap(data?['Photo']),
      title: data?['Title'] == null ? null : TitleModel.fromMap(data?['Title']),
      titleInArabic: data?['Title_In_Arabic'] == null
          ? null
          : TitleInArabic.fromMap(data?['Title_In_Arabic']),
      password: data?['Password'],
      defaultPassword: data?['Default_Password'],
      firstLogin: data?['First_Login'],
      lastLogin: data?['Last_Login'],
      deactivationDate: data?['Deactivation_Date'],
      activationDate: data?['Activation_Date'],
    );
  }

  Map<String, dynamic> toMap() => {
    'Id': id,
    'First_Name': firstName!.toMap(),
    'Middle_Name': middleName!.toMap(),
    'Last_Name': lastName!.toMap(),
    'First_Name_In_Arabic': firstNameInArabic!.toMap(),
    'Middle_Name_In_Arabic': middleNameInArabic!.toMap(),
    'Last_Name_In_Arabic': lastNameInArabic!.toMap(),
    'Email': email!.toMap(),
    'Mobile_Phone': mobilePhone!.toMap(),
    'Office_Phone': officePhone!.toMap(),
    'Home_Phone': homePhone!.toMap(),
    'Extension': extension!.toMap(),
    'Postal_Code': postalCode != null ? postalCode!.toMap() : null,
    'Street': street != null ? street!.toMap() : null,
    'National_Id': nationalId != null ? nationalId!.toMap() : null,
    'National_Id_Expiration_Date': nationalIdExpirationDate != null
        ? nationalIdExpirationDate!.toMap()
        : null,
    'Nationality': nationality != null ? nationality!.toMap() : null,
    'Passport': passport != null ? passport!.toMap() : null,
    'Passport_Expiration_Date': passportExpirationDate != null
        ? passportExpirationDate!.toMap()
        : null,
    'Country': country != null ? country!.toMap() : null,
    'Province': province != null ? province!.toMap() : null,
    'City': city != null ? city!.toMap() : null,
    'Gender': gender != null ? gender!.toMap() : null,
    'Marital_Status': maritalStatus != null ? maritalStatus!.toMap() : null,
    'Language': language != null ? language!.toMap() : null,
    'Birth_Day': birthDay != null ? birthDay!.toMap() : null,
    'Bio': bio != null ? bio!.toMap() : null,
    'Bio_In_Arabic': bioInArabic != null ? bioInArabic!.toMap() : null,
    'Academic_History':
    academicHistory != null ? academicHistory!.toMap() : null,
    'Skills': skills != null ? skills!.toMap() : null,
    'Hobbies': hobbies != null ? hobbies!.toMap() : null,
    'Password': password,
    'Default_Password': defaultPassword,
    'First_Login': firstLogin,
    'Last_Login': lastLogin,
    'Deactivation_Date': deactivationDate,
    'Activation_Date': activationDate,
    'Role': role!.toMap(),
    'Department_Id': departmentid!.toMap(),
    'Supervisor': supervisor!.toMap(),
    'Work_Location': workLocation != null ? workLocation!.toMap() : null,
    'Driving_License_Id':
    drivingLicenseId != null ? drivingLicenseId!.toMap() : null,
    'Car_Plates': carPlates != null ? carPlates!.toMap() : null,
    'Photo': photo != null ? photo!.toMap() : null,
    'Title': title!.toMap(),
    'Title_In_Arabic': titleInArabic!.toMap(),
    'Status': status!.toMap(),
  };

  String toJson() => json.encode(toMap());
  Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
}

class NewEmployeeModelHistory {
  String? id;
  List<int> timestamps;
  List<String> firstName;
  List<String> middleName;
  List<String> lastName;
  List<String> firstNameInArabic;
  List<String> middleNameInArabic;
  List<String> lastNameInArabic;
  List<String> nationalId;
  List<String> nationalIdExpirationDate;
  List<String> nationality;
  List<String> passport;
  List<String> passportExpirationDate;
  List<String> email;
  List<MobilePhone> mobilePhone;
  List<String> officePhone;
  List<String> homePhone;
  List<String> extension;
  List<String> birthDay;
  List<String> gender;
  List<String> country;
  List<String> province;
  List<String> city;
  List<String> postalCode;
  List<String> street;
  List<String> maritalStatus;
  List<String> language;
  List<String> departmentId;
  List<String> supervisor;
  List<String> role;
  List<String> title;
  List<String> titleInArabic;
  List<String> workLocation;
  List<String> drivingLicenseId;
  List<List<String>> carPlates;
  List<Map<String, dynamic>> academicHistory;
  List<String> bio;
  List<String> bioInArabic;
  List<String> photo;
  List<List<String>> skills;
  List<List<String>> hobbies;
  List<String> status;

  List<String?> personalEmail;
  List<String?> homeCountryCode;
  List<String?> officeCountryCode;
  List<HomePhone> homePhoneDetails;
  List<OfficePhone> officePhoneDetails;
  List<String?> jobType;
  List<String?> workArrangement;
  List<String?> remoteStatus;
  List<String?> employeeGrade;
  List<String?> startDate;
  List<String?> startTime;
  List<String?> endTime;
  List<String?> daysOff;
  List<String?> salary;
  List<String?> currency;
  List<String?> institutionName;
  List<String?> degree;
  List<String?> fieldOfStudy;
  List<String?> certificationStartDate;
  List<String?> certificationEndDate;
  List<String?> gradeOrScore;
  List<String?> certificateId;
  List<String?> issuingAuthority;
  List<String?> certificationDocumentUrl;
  List<String?> certificationNotes;

  // Health Insurance Fields
  List<String> insuranceName;
  List<String> insurancePolicyNumber;
  List<String?> insuranceProviderContact;

  // 1st Emergency Contact Fields
  List<String> firstContactFirstName;
  List<String> firstContactLastName;
  List<String> firstContactRelationship;
  List<String> firstContactEmail;
  List<String> firstContactPhone;
  List<String> firstContactLanguage;
  List<String> firstContactCountry;
  List<String> firstContactProvince;
  List<String> firstContactCity;
  List<String> firstContactStreet;
  List<String?> firstContactFirstNameArabic;
  List<String?> firstContactMiddleName;
  List<String?> firstContactMiddleNameArabic;
  List<String?> firstContactLastNameArabic;
  List<MobilePhone> firstContactPhoneDetails;

  // 2nd Emergency Contact Fields
  List<String> secondContactFirstName;
  List<String> secondContactLastName;
  List<String> secondContactRelationship;
  List<String> secondContactEmail;
  List<String> secondContactPhone;
  List<String> secondContactLanguage;
  List<String> secondContactCountry;
  List<String> secondContactProvince;
  List<String> secondContactCity;
  List<String> secondContactStreet;
  List<String?> secondContactFirstNameArabic;
  List<String?> secondContactMiddleName;
  List<String?> secondContactMiddleNameArabic;
  List<String?> secondContactLastNameArabic;
  List<MobilePhone> secondContactPhoneDetails;
  List<String?> passportDocumentUrl;
  List<String?> nationalIdFrontUrl;
  List<String?> nationalIdBackUrl;
  List<String?> drivingLicenseDocumentUrl;

  String? password;
  String? passwordExpirationTime;
  String? passwordExpirationUnit;
  String? defaultPassword;
  String? firstLogin;
  String? lastLogin;
  String? deactivationDate;
  String? activationDate;

  NewEmployeeModelHistory({
    this.id,
    List<int>? timestamps,
    List<String>? firstName,
    List<String>? middleName,
    List<String>? lastName,
    List<String>? firstNameInArabic,
    List<String>? middleNameInArabic,
    List<String>? lastNameInArabic,
    List<String>? nationalId,
    List<String>? nationalIdExpirationDate,
    List<String>? nationality,
    List<String>? passport,
    List<String>? passportExpirationDate,
    List<String>? email,
    List<MobilePhone>? mobilePhone,
    List<String>? officePhone,
    List<String>? homePhone,
    List<String>? extension,
    List<String>? birthDay,
    List<String>? gender,
    List<String>? country,
    List<String>? province,
    List<String>? city,
    List<String>? postalCode,
    List<String>? street,
    List<String>? maritalStatus,
    List<String>? language,
    List<String>? departmentId,
    List<String>? supervisor,
    List<String>? role,
    List<String>? title,
    List<String>? titleInArabic,
    List<String>? workLocation,
    List<String>? drivingLicenseId,
    List<List<String>>? carPlates,
    List<Map<String, dynamic>>? academicHistory,
    List<String>? bio,
    List<String>? bioInArabic,
    List<String>? photo,
    List<List<String>>? skills,
    List<List<String>>? hobbies,
    List<String>? status,
    List<String?>? personalEmail,
    List<String?>? homeCountryCode,
    List<String?>? officeCountryCode,
    List<HomePhone>? homePhoneDetails,
    List<OfficePhone>? officePhoneDetails,
    List<String?>? jobType,
    List<String?>? workArrangement,
    List<String?>? remoteStatus,
    List<String?>? employeeGrade,
    List<String?>? startDate,
    List<String?>? startTime,
    List<String?>? endTime,
    List<String?>? daysOff,
    List<String?>? salary,
    List<String?>? currency,
    List<String?>? institutionName,
    List<String?>? degree,
    List<String?>? fieldOfStudy,
    List<String?>? certificationStartDate,
    List<String?>? certificationEndDate,
    List<String?>? gradeOrScore,
    List<String?>? certificateId,
    List<String?>? issuingAuthority,
    List<String?>? certificationDocumentUrl,
    List<String?>? certificationNotes,
    // Health Insurance Parameters
    List<String>? insuranceName,
    List<String>? insurancePolicyNumber,
    List<String?>? insuranceProviderContact,
    // 1st Emergency Contact Parameters
    List<String>? firstContactFirstName,
    List<String>? firstContactLastName,
    List<String>? firstContactRelationship,
    List<String>? firstContactEmail,
    List<String>? firstContactPhone,
    List<String>? firstContactLanguage,
    List<String>? firstContactCountry,
    List<String>? firstContactProvince,
    List<String>? firstContactCity,
    List<String>? firstContactStreet,
    List<String?>? firstContactFirstNameArabic,
    List<String?>? firstContactMiddleName,
    List<String?>? firstContactMiddleNameArabic,
    List<String?>? firstContactLastNameArabic,
    List<MobilePhone>? firstContactPhoneDetails,
    // 2nd Emergency Contact Parameters
    List<String>? secondContactFirstName,
    List<String>? secondContactLastName,
    List<String>? secondContactRelationship,
    List<String>? secondContactEmail,
    List<String>? secondContactPhone,
    List<String>? secondContactLanguage,
    List<String>? secondContactCountry,
    List<String>? secondContactProvince,
    List<String>? secondContactCity,
    List<String>? secondContactStreet,
    List<String?>? secondContactFirstNameArabic,
    List<String?>? secondContactMiddleName,
    List<String?>? secondContactMiddleNameArabic,
    List<String?>? secondContactLastNameArabic,
    List<MobilePhone>? secondContactPhoneDetails,
    List<String?>? passportDocumentUrl,
    List<String?>? nationalIdFrontUrl,
    List<String?>? nationalIdBackUrl,
    List<String?>? drivingLicenseDocumentUrl,
    this.password,
    this.defaultPassword,
    this.passwordExpirationTime,
    this.passwordExpirationUnit,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  })  : timestamps = timestamps ?? [DateTime.now().millisecondsSinceEpoch],
        firstName = firstName ?? [],
        middleName = middleName ?? [],
        lastName = lastName ?? [],
        firstNameInArabic = firstNameInArabic ?? [],
        middleNameInArabic = middleNameInArabic ?? [],
        lastNameInArabic = lastNameInArabic ?? [],
        nationalId = nationalId ?? [],
        nationalIdExpirationDate = nationalIdExpirationDate ?? [],
        nationality = nationality ?? [],
        passport = passport ?? [],
        passportExpirationDate = passportExpirationDate ?? [],
        email = email ?? [],
        mobilePhone = mobilePhone ?? [],
        officePhone = officePhone ?? [],
        homePhone = homePhone ?? [],
        extension = extension ?? [],
        birthDay = birthDay ?? [],
        gender = gender ?? [],
        country = country ?? [],
        province = province ?? [],
        city = city ?? [],
        postalCode = postalCode ?? [],
        street = street ?? [],
        maritalStatus = maritalStatus ?? [],
        language = language ?? [],
        departmentId = departmentId ?? [],
        supervisor = supervisor ?? [],
        role = role ?? [],
        title = title ?? [],
        titleInArabic = titleInArabic ?? [],
        workLocation = workLocation ?? [],
        drivingLicenseId = drivingLicenseId ?? [],
        carPlates = carPlates ?? [],
        academicHistory = academicHistory ?? [],
        bio = bio ?? [],
        bioInArabic = bioInArabic ?? [],
        photo = photo ?? [],
        skills = skills ?? [],
        hobbies = hobbies ?? [],
        status = status ?? [],
        personalEmail = personalEmail ?? [null],
        homeCountryCode = homeCountryCode ?? [null],
        officeCountryCode = officeCountryCode ?? [null],
        homePhoneDetails = homePhoneDetails ?? [],
        officePhoneDetails = officePhoneDetails ?? [],
        jobType = jobType ?? [null],
        workArrangement = workArrangement ?? [null],
        remoteStatus = remoteStatus ?? [null],
        employeeGrade = employeeGrade ?? [null],
        startDate = startDate ?? [null],
        startTime = startTime ?? [null],
        endTime = endTime ?? [null],
        daysOff = daysOff ?? [null],
        salary = salary ?? [null],
        currency = currency ?? [null],
        institutionName = institutionName ?? [null],
        degree = degree ?? [null],
        fieldOfStudy = fieldOfStudy ?? [null],
        certificationStartDate = certificationStartDate ?? [null],
        certificationEndDate = certificationEndDate ?? [null],
        gradeOrScore = gradeOrScore ?? [null],
        certificateId = certificateId ?? [null],
        issuingAuthority = issuingAuthority ?? [null],
        certificationDocumentUrl = certificationDocumentUrl ?? [null],
        certificationNotes = certificationNotes ?? [null],
  // Health Insurance Initialization
        insuranceName = insuranceName ?? [],
        insurancePolicyNumber = insurancePolicyNumber ?? [],
        insuranceProviderContact = insuranceProviderContact ?? [null],
  // 1st Emergency Contact Initialization
        firstContactFirstName = firstContactFirstName ?? [],
        firstContactLastName = firstContactLastName ?? [],
        firstContactRelationship = firstContactRelationship ?? [],
        firstContactEmail = firstContactEmail ?? [],
        firstContactPhone = firstContactPhone ?? [],
        firstContactLanguage = firstContactLanguage ?? [],
        firstContactCountry = firstContactCountry ?? [],
        firstContactProvince = firstContactProvince ?? [],
        firstContactCity = firstContactCity ?? [],
        firstContactStreet = firstContactStreet ?? [],
        firstContactFirstNameArabic = firstContactFirstNameArabic ?? [null],
        firstContactMiddleName = firstContactMiddleName ?? [null],
        firstContactMiddleNameArabic = firstContactMiddleNameArabic ?? [null],
        firstContactLastNameArabic = firstContactLastNameArabic ?? [null],
        firstContactPhoneDetails = firstContactPhoneDetails ?? [],
  // 2nd Emergency Contact Initialization
        secondContactFirstName = secondContactFirstName ?? [],
        secondContactLastName = secondContactLastName ?? [],
        secondContactRelationship = secondContactRelationship ?? [],
        secondContactEmail = secondContactEmail ?? [],
        secondContactPhone = secondContactPhone ?? [],
        secondContactLanguage = secondContactLanguage ?? [],
        secondContactCountry = secondContactCountry ?? [],
        secondContactProvince = secondContactProvince ?? [],
        secondContactCity = secondContactCity ?? [],
        secondContactStreet = secondContactStreet ?? [],
        secondContactFirstNameArabic = secondContactFirstNameArabic ?? [null],
        secondContactMiddleName = secondContactMiddleName ?? [null],
        secondContactMiddleNameArabic = secondContactMiddleNameArabic ?? [null],
        secondContactLastNameArabic = secondContactLastNameArabic ?? [null],
        secondContactPhoneDetails = secondContactPhoneDetails ?? [],
        passportDocumentUrl = passportDocumentUrl ?? [null],
        nationalIdFrontUrl = nationalIdFrontUrl ?? [null],
        nationalIdBackUrl = nationalIdBackUrl ?? [null],
        drivingLicenseDocumentUrl = drivingLicenseDocumentUrl ?? [null];

  factory NewEmployeeModelHistory.fromMap(Map? data) {
    if (data == null) {
      return NewEmployeeModelHistory(id: null);
    }

    try {
      final List<int> sharedTimestamps = (data['timestamps'] as List<dynamic>?)
          ?.map((e) => e is int ? e : (e as num).toInt())
          .toList() ??
          [DateTime.now().millisecondsSinceEpoch];

      return NewEmployeeModelHistory(
        id: data['Id'],
        timestamps: sharedTimestamps,
        firstName: _parseListSafely(data['First_Name']),
        middleName: _parseListSafely(data['Middle_Name']),
        lastName: _parseListSafely(data['Last_Name']),
        firstNameInArabic: _parseListSafely(data['First_Name_In_Arabic']),
        middleNameInArabic: _parseListSafely(data['Middle_Name_In_Arabic']),
        lastNameInArabic: _parseListSafely(data['Last_Name_In_Arabic']),
        nationalId: _parseListSafely(data['National_Id']),
        nationalIdExpirationDate:
        _parseListSafely(data['National_Id_Expiration_Date']),
        nationality: _parseListSafely(data['Nationality']),
        passport: _parseListSafely(data['Passport']),
        passportExpirationDate:
        _parseListSafely(data['Passport_Expiration_Date']),
        email: _parseListSafely(data['Email']),
        mobilePhone: _parseMobilePhoneList(data['Mobile_Phone']),
        officePhone: _parseListSafely(data['Office_Phone']),
        homePhone: _parseListSafely(data['Home_Phone']),
        extension: _parseListSafely(data['Extension']),
        birthDay: _parseListSafely(data['Birth_Day']),
        gender: _parseListSafely(data['Gender']),
        country: _parseListSafely(data['Country']),
        province: _parseListSafely(data['Province']),
        city: _parseListSafely(data['City']),
        postalCode: _parseListSafely(data['Postal_Code']),
        street: _parseListSafely(data['Street']),
        maritalStatus: _parseListSafely(data['Marital_Status']),
        language: _parseListSafely(data['Language']),
        departmentId: _parseListSafely(data['Department_Id']),
        supervisor: _parseListSafely(data['Supervisor']),
        role: _parseListSafely(data['Role']),
        title: _parseListSafely(data['Title']),
        titleInArabic: _parseListSafely(data['Title_In_Arabic']),
        workLocation: _parseListSafely(data['Work_Location']),
        drivingLicenseId: _parseListSafely(data['Driving_License_Id']),
        carPlates: _parseNestedListSafely(data['Car_Plates']),
        academicHistory: _parseAcademicHistoryList(data['Academic_History']),
        bio: _parseListSafely(data['Bio']),
        bioInArabic: _parseListSafely(data['Bio_In_Arabic']),
        photo: _parseListSafely(data['Photo']),
        skills: _parseNestedListSafely(data['Skills']),
        hobbies: _parseNestedListSafely(data['Hobbies']),
        status: _parseListSafely(data['Status']),
        personalEmail: _parseNullableListSafely(data['Personal_Email']),
        homeCountryCode: _parseNullableListSafely(data['Home_Country_Code']),
        officeCountryCode:
        _parseNullableListSafely(data['Office_Country_Code']),
        homePhoneDetails: _parseHomePhoneList(data['Home_Phone_Details']),
        officePhoneDetails: _parseOfficePhoneList(data['Office_Phone_Details']),
        jobType: _parseNullableListSafely(data['Job_Type']),
        workArrangement: _parseNullableListSafely(data['Work_Arrangement']),
        remoteStatus: _parseNullableListSafely(data['Remote_Status']),
        employeeGrade: _parseNullableListSafely(data['Employee_Grade']),
        startDate: _parseNullableListSafely(data['Start_Date']),
        startTime: _parseNullableListSafely(data['Start_Time']),
        endTime: _parseNullableListSafely(data['End_Time']),
        daysOff: _parseNullableListSafely(data['Days_Off']),
        salary: _parseNullableListSafely(data['Salary']),
        currency: _parseNullableListSafely(data['Currency']),
        institutionName: _parseNullableListSafely(data['Institution_Name']),
        degree: _parseNullableListSafely(data['Degree']),
        fieldOfStudy: _parseNullableListSafely(data['Field_Of_Study']),
        certificationStartDate:
        _parseNullableListSafely(data['Certification_Start_Date']),
        certificationEndDate:
        _parseNullableListSafely(data['Certification_End_Date']),
        gradeOrScore: _parseNullableListSafely(data['Grade_Or_Score']),
        certificateId: _parseNullableListSafely(data['Certificate_Id']),
        issuingAuthority: _parseNullableListSafely(data['Issuing_Authority']),
        certificationDocumentUrl:
        _parseNullableListSafely(data['Certification_Document_Url']),
        certificationNotes:
        _parseNullableListSafely(data['Certification_Notes']),
        // Health Insurance Fields
        insuranceName: _parseListSafely(data['Insurance_Name']),
        insurancePolicyNumber:
        _parseListSafely(data['Insurance_Policy_Number']),
        insuranceProviderContact:
        _parseNullableListSafely(data['Provider_Contact']),
        // 1st Emergency Contact Fields
        firstContactFirstName:
        _parseListSafely(data['First_Contact_First_Name']),
        firstContactLastName: _parseListSafely(data['First_Contact_Last_Name']),
        firstContactRelationship:
        _parseListSafely(data['First_Contact_Relationship']),
        firstContactEmail: _parseListSafely(data['First_Contact_Email']),
        firstContactPhone: _parseListSafely(data['First_Contact_Phone']),
        firstContactLanguage: _parseListSafely(data['First_Contact_Language']),
        firstContactCountry: _parseListSafely(data['First_Contact_Country']),
        firstContactProvince: _parseListSafely(data['First_Contact_Province']),
        firstContactCity: _parseListSafely(data['First_Contact_City']),
        firstContactStreet: _parseListSafely(data['First_Contact_Street']),
        firstContactFirstNameArabic:
        _parseNullableListSafely(data['First_Contact_First_Name_Arabic']),
        firstContactMiddleName:
        _parseNullableListSafely(data['First_Contact_Middle_Name']),
        firstContactMiddleNameArabic:
        _parseNullableListSafely(data['First_Contact_Middle_Name_Arabic']),
        firstContactLastNameArabic:
        _parseNullableListSafely(data['First_Contact_Last_Name_Arabic']),
        firstContactPhoneDetails:
        _parseMobilePhoneList(data['First_Contact_Phone_Details']),
        // 2nd Emergency Contact Fields
        secondContactFirstName:
        _parseListSafely(data['Second_Contact_First_Name']),
        secondContactLastName:
        _parseListSafely(data['Second_Contact_Last_Name']),
        secondContactRelationship:
        _parseListSafely(data['Second_Contact_Relationship']),
        secondContactEmail: _parseListSafely(data['Second_Contact_Email']),
        secondContactPhone: _parseListSafely(data['Second_Contact_Phone']),
        secondContactLanguage:
        _parseListSafely(data['Second_Contact_Language']),
        secondContactCountry: _parseListSafely(data['Second_Contact_Country']),
        secondContactProvince:
        _parseListSafely(data['Second_Contact_Province']),
        secondContactCity: _parseListSafely(data['Second_Contact_City']),
        secondContactStreet: _parseListSafely(data['Second_Contact_Street']),
        secondContactFirstNameArabic:
        _parseNullableListSafely(data['Second_Contact_First_Name_Arabic']),
        secondContactMiddleName:
        _parseNullableListSafely(data['Second_Contact_Middle_Name']),
        secondContactMiddleNameArabic:
        _parseNullableListSafely(data['Second_Contact_Middle_Name_Arabic']),
        secondContactLastNameArabic:
        _parseNullableListSafely(data['Second_Contact_Last_Name_Arabic']),
        secondContactPhoneDetails:
        _parseMobilePhoneList(data['Second_Contact_Phone_Details']),
        passportDocumentUrl:
        _parseNullableListSafely(data['Passport_Document_Url']),
        nationalIdFrontUrl:
        _parseNullableListSafely(data['National_Id_Front_Url']),
        nationalIdBackUrl:
        _parseNullableListSafely(data['National_Id_Back_Url']),
        drivingLicenseDocumentUrl:
        _parseNullableListSafely(data['Driving_License_Document_Url']),
        password: data['Password'],
        defaultPassword: data['Default_Password'],
        passwordExpirationTime: data['Password_Expiration_Time'],
        passwordExpirationUnit: data['Password_Expiration_Unit'],
        firstLogin: data['First_Login'],
        lastLogin: data['Last_Login'],
        deactivationDate: data['Deactivation_Date'],
        activationDate: data['Activation_Date'],
      );
    } catch (e, stack) {
      print("❌ ERROR parsing NewEmployeeModel: $e");
      print("Stacktrace:\n$stack");
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    // Helper function to convert nested lists to a format Firebase accepts
    List<Map<String, dynamic>> convertNestedList(
        List<List<String>> nestedList) {
      return nestedList.map((innerList) {
        return {
          'items': innerList,
        };
      }).toList();
    }

    return {
      'Id': id,
      'timestamps': timestamps,
      'First_Name': firstName,
      'Middle_Name': middleName,
      'Last_Name': lastName,
      'First_Name_In_Arabic': firstNameInArabic,
      'Middle_Name_In_Arabic': middleNameInArabic,
      'Last_Name_In_Arabic': lastNameInArabic,
      'Email': email,
      'Mobile_Phone': mobilePhone.map((phone) => phone.toMap()).toList(),
      'Office_Phone': officePhone,
      'Home_Phone': homePhone,
      'Extension': extension,
      'Postal_Code': postalCode,
      'Street': street,
      'National_Id': nationalId,
      'National_Id_Expiration_Date': nationalIdExpirationDate,
      'Nationality': nationality,
      'Passport': passport,
      'Passport_Expiration_Date': passportExpirationDate,
      'Country': country,
      'Province': province,
      'City': city,
      'Gender': gender,
      'Marital_Status': maritalStatus,
      'Language': language,
      'Birth_Day': birthDay,
      'Bio': bio,
      'Bio_In_Arabic': bioInArabic,
      'Academic_History': academicHistory,
      'Skills': convertNestedList(skills),
      'Hobbies': convertNestedList(hobbies),
      'Password': password,
      'Default_Password': defaultPassword,
      'Password_Expiration_Time': passwordExpirationTime,
      'Password_Expiration_Unit': passwordExpirationUnit,
      'First_Login': firstLogin,
      'Last_Login': lastLogin,
      'Deactivation_Date': deactivationDate,
      'Activation_Date': activationDate,
      'Role': role,
      'Department_Id': departmentId,
      'Supervisor': supervisor,
      'Work_Location': workLocation,
      'Driving_License_Id': drivingLicenseId,
      'Car_Plates': convertNestedList(carPlates),
      'Photo': photo,
      'Title': title,
      'Title_In_Arabic': titleInArabic,
      'Status': status,
      'Personal_Email': personalEmail,
      'Home_Country_Code': homeCountryCode,
      'Office_Country_Code': officeCountryCode,
      'Home_Phone_Details':
      homePhoneDetails.map((phone) => phone.toMap()).toList(),
      'Office_Phone_Details':
      officePhoneDetails.map((phone) => phone.toMap()).toList(),
      'Job_Type': jobType,
      'Work_Arrangement': workArrangement,
      'Remote_Status': remoteStatus,
      'Employee_Grade': employeeGrade,
      'Start_Date': startDate,
      'Start_Time': startTime,
      'End_Time': endTime,
      'Days_Off': daysOff,
      'Salary': salary,
      'Currency': currency,
      'Institution_Name': institutionName,
      'Degree': degree,
      'Field_Of_Study': fieldOfStudy,
      'Certification_Start_Date': certificationStartDate,
      'Certification_End_Date': certificationEndDate,
      'Grade_Or_Score': gradeOrScore,
      'Certificate_Id': certificateId,
      'Issuing_Authority': issuingAuthority,
      'Certification_Document_Url': certificationDocumentUrl,
      'Certification_Notes': certificationNotes,
      // Health Insurance Fields
      'Insurance_Name': insuranceName,
      'Insurance_Policy_Number': insurancePolicyNumber,
      'Provider_Contact': insuranceProviderContact,
      // 1st Emergency Contact Fields
      'First_Contact_First_Name': firstContactFirstName,
      'First_Contact_Last_Name': firstContactLastName,
      'First_Contact_Relationship': firstContactRelationship,
      'First_Contact_Email': firstContactEmail,
      'First_Contact_Phone': firstContactPhone,
      'First_Contact_Language': firstContactLanguage,
      'First_Contact_Country': firstContactCountry,
      'First_Contact_Province': firstContactProvince,
      'First_Contact_City': firstContactCity,
      'First_Contact_Street': firstContactStreet,
      'First_Contact_First_Name_Arabic': firstContactFirstNameArabic,
      'First_Contact_Middle_Name': firstContactMiddleName,
      'First_Contact_Middle_Name_Arabic': firstContactMiddleNameArabic,
      'First_Contact_Last_Name_Arabic': firstContactLastNameArabic,
      'First_Contact_Phone_Details':
      firstContactPhoneDetails.map((phone) => phone.toMap()).toList(),
      // 2nd Emergency Contact Fields
      'Second_Contact_First_Name': secondContactFirstName,
      'Second_Contact_Last_Name': secondContactLastName,
      'Second_Contact_Relationship': secondContactRelationship,
      'Second_Contact_Email': secondContactEmail,
      'Second_Contact_Phone': secondContactPhone,
      'Second_Contact_Language': secondContactLanguage,
      'Second_Contact_Country': secondContactCountry,
      'Second_Contact_Province': secondContactProvince,
      'Second_Contact_City': secondContactCity,
      'Second_Contact_Street': secondContactStreet,
      'Second_Contact_First_Name_Arabic': secondContactFirstNameArabic,
      'Second_Contact_Middle_Name': secondContactMiddleName,
      'Second_Contact_Middle_Name_Arabic': secondContactMiddleNameArabic,
      'Second_Contact_Last_Name_Arabic': secondContactLastNameArabic,
      'Second_Contact_Phone_Details':
      secondContactPhoneDetails.map((phone) => phone.toMap()).toList(),
      'Passport_Document_Url': passportDocumentUrl,
      'National_Id_Front_Url': nationalIdFrontUrl,
      'National_Id_Back_Url': nationalIdBackUrl,
      'Driving_License_Document_Url': drivingLicenseDocumentUrl,
    };
  }

  static List<String?> _parseNullableListSafely(dynamic value) {
    if (value == null) return [null];
    if (value is List) {
      if (value.isEmpty) return [null];
      return value.map((item) => item?.toString()).toList();
    }
    return [value.toString()];
  }

  static List<HomePhone> _parseHomePhoneList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => HomePhone.fromMap(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  static List<OfficePhone> _parseOfficePhoneList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((item) => OfficePhone.fromMap(
      Map<String, dynamic>.from(item),
    ))
        .toList();
  }

  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];

    // Handle string representation of empty array
    if (value is String) {
      if (value == '[]' || value.trim().isEmpty) {
        return [];
      }
      return [value];
    }

    if (value is List) {
      // Handle empty list
      if (value.isEmpty) return [];

      List<String> result = [];
      for (var item in value) {
        // Skip if item is the string "[]"
        if (item is String && item == '[]') {
          continue;
        }

        // If item is a Map with a field name
        if (item is Map) {
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' &&
                entry.value != null &&
                entry.value is! Timestamp) {
              // Skip if value is the string "[]"
              if (entry.value is String && entry.value == '[]') {
                continue;
              }

              if (entry.value is List && (entry.value as List).isNotEmpty) {
                result.add((entry.value as List).first?.toString() ?? '');
              } else {
                result.add(entry.value?.toString() ?? '');
              }
              break;
            }
          }
        } else if (item is! Timestamp) {
          result.add(item?.toString() ?? '');
        }
      }
      return result;
    }

    // Single value (not a list)
    if (value is Map) {
      for (var entry in value.entries) {
        if (entry.key != 'Timestamp' &&
            entry.value != null &&
            entry.value is! Timestamp) {
          // Skip if value is the string "[]"
          if (entry.value is String && entry.value == '[]') {
            return [];
          }

          if (entry.value is List && (entry.value as List).isNotEmpty) {
            return [(entry.value as List).first?.toString() ?? ''];
          }
          return [entry.value?.toString() ?? ''];
        }
      }
      return [];
    }

    return [value.toString()];
  }

  static List<List<String>> _parseNestedListSafely(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      if (value.isEmpty) return [];

      List<List<String>> result = [];
      for (var item in value) {
        // If item is a Map with nested structure
        if (item is Map) {
          // Check for the 'items' key (our new format)
          if (item.containsKey('items') && item['items'] is List) {
            result.add(List<String>.from(
                (item['items'] as List).map((e) => e?.toString() ?? '')));
            continue;
          }

          // Find the first non-Timestamp value (old format)
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' &&
                entry.value != null &&
                entry.value is! Timestamp) {
              if (entry.value is List) {
                result.add(List<String>.from(
                    entry.value.map((e) => e?.toString() ?? '')));
              } else {
                result.add([entry.value?.toString() ?? '']);
              }
              break;
            }
          }
        } else if (item is List) {
          // Direct nested list (legacy format)
          result.add(List<String>.from(item.map((e) => e?.toString() ?? '')));
        }
      }
      return result.isEmpty ? [[]] : result;
    }

    return [];
  }

  static List<MobilePhone> _parseMobilePhoneList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      List<MobilePhone> result = [];
      for (var item in value) {
        if (item is Map) {
          try {
            // Check if this is a wrapped map like {Mobile_Phone: {...}, Timestamp: ...}
            Map<String, dynamic>? actualPhone;
            for (var entry in item.entries) {
              if (entry.key != 'Timestamp' && entry.value is Map) {
                actualPhone = Map<String, dynamic>.from(entry.value);
                break;
              }
            }

            if (actualPhone != null) {
              result.add(MobilePhone.fromMap(actualPhone));
            } else {
              // Direct MobilePhone map
              Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
              cleanMap.removeWhere(
                      (key, val) => val is Timestamp || key == 'Timestamp');
              if (cleanMap.isNotEmpty) {
                result.add(MobilePhone.fromMap(cleanMap));
              }
            }
          } catch (e) {
            print(
                "⚠️ Warning: Could not parse mobile phone item: $item, error: $e");
          }
        } else if (item is MobilePhone) {
          result.add(item);
        }
      }
      return result;
    }

    if (value is Map) {
      try {
        Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
        cleanMap
            .removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
        return cleanMap.isNotEmpty ? [MobilePhone.fromMap(cleanMap)] : [];
      } catch (e) {
        print(
            "⚠️ Warning: Could not parse mobile phone map: $value, error: $e");
      }
    }

    return [];
  }

  static List<Map<String, dynamic>> _parseAcademicHistoryList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      List<Map<String, dynamic>> result = [];
      for (var item in value) {
        if (item is Map) {
          // Check if this is a wrapped map
          Map<String, dynamic>? actualHistory;
          for (var entry in item.entries) {
            if (entry.key != 'Timestamp' && entry.value is Map) {
              actualHistory = Map<String, dynamic>.from(entry.value);
              break;
            }
          }
          if (actualHistory != null) {
            result.add(actualHistory);
          } else {
            // Direct map
            Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
            cleanMap.removeWhere(
                    (key, val) => val is Timestamp || key == 'Timestamp');
            if (cleanMap.isNotEmpty) {
              result.add(cleanMap);
            }
          }
        }
      }
      return result;
    }

    if (value is Map) {
      Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
      cleanMap
          .removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
      return cleanMap.isNotEmpty ? [cleanMap] : [];
    }

    return [];
  }

  /// Helper function to synchronize a field list with the target length
  ///
  /// FIXED 9/10/2026 — the gap was filled with `''`, so for an UNCHANGED
  /// field the "repeat the last value" step below repeated that blank instead
  /// of the real value: one approved health/emergency change wiped every
  /// other insurance / contact field whose list was shorter than `timestamps`
  /// (e.g. after an HR bulk upload that appended `timestamps` only). The gap
  /// now carries the last known value forward — the missing revisions are the
  /// ones in which this field did not change — so the current value survives
  /// and the list ends up exactly as long as `timestamps`.
  static List<String> _synchronizeFieldList(
      List<String> currentList, int targetLength, String? newValue) {
    List<String> result = List<String>.from(currentList);

    // First, ensure the list matches the OLD timestamp length (targetLength - 1)
    int oldLength = targetLength - 1;
    while (result.length < oldLength) {
      // 9/10/2026: carry the last value forward ('' only when there is none).
      result.add(result.isEmpty ? '' : result.last);
    }

    // Now add the new entry
    if (newValue != null) {
      result.add(newValue);
    } else {
      result.add(result.isEmpty ? '' : result.last);
    }

    return result;
  }

  /// Helper function to synchronize a MobilePhone list with the target length
  ///
  /// FIXED 9/10/2026 — same defect as [_synchronizeFieldList]: the gap was
  /// filled with an empty `MobilePhone()`, so any synchronized write on a
  /// document whose `Mobile_Phone` list was shorter than `timestamps` replaced
  /// the employee's current phone with a blank one. The gap now carries the
  /// last phone forward.
  static List<MobilePhone> _synchronizeMobilePhoneList(
      List<MobilePhone> currentList, int targetLength, MobilePhone? newValue) {
    List<MobilePhone> result = List<MobilePhone>.from(currentList);

    // First, ensure the list matches the OLD timestamp length (targetLength - 1)
    int oldLength = targetLength - 1;
    while (result.length < oldLength) {
      // 9/10/2026: carry the last phone forward (empty only when there is none).
      result.add(result.isEmpty ? MobilePhone() : result.last);
    }

    // Now add the new entry
    if (newValue != null) {
      result.add(newValue);
    } else {
      result.add(result.isEmpty ? MobilePhone() : result.last);
    }

    return result;
  }

  NewEmployeeModelHistory copyWithUpdateSynchronized({
    String? id,
    int? addTimestamp,
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
    MobilePhone? mobilePhone,
    String? officePhone,
    String? homePhone,
    String? extension,
    String? birthDay,
    String? gender,
    String? country,
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
    List<String>? carPlates,
    Map<String, dynamic>? academicHistory,
    String? bio,
    String? bioInArabic,
    String? photo,
    List<String>? skills,
    List<String>? hobbies,
    String? status,
    // Health Insurance Parameters
    String? insuranceName,
    String? insurancePolicyNumber,
    // 1st Emergency Contact Parameters
    String? firstContactFirstName,
    String? firstContactLastName,
    String? firstContactRelationship,
    String? firstContactEmail,
    String? firstContactPhone,
    String? firstContactLanguage,
    String? firstContactCountry,
    String? firstContactProvince,
    String? firstContactCity,
    String? firstContactStreet,
    // 2nd Emergency Contact Parameters
    String? secondContactFirstName,
    String? secondContactLastName,
    String? secondContactRelationship,
    String? secondContactEmail,
    String? secondContactPhone,
    String? secondContactLanguage,
    String? secondContactCountry,
    String? secondContactProvince,
    String? secondContactCity,
    String? secondContactStreet,
    String? password,
    String? defaultPassword,
    String? passwordExpirationTime,
    String? passwordExpirationUnit,
    String? firstLogin,
    String? lastLogin,
    String? deactivationDate,
    String? activationDate,
  }) {
    final timestamp = addTimestamp ?? DateTime.now().millisecondsSinceEpoch;
    final newTimestamps = List<int>.from(timestamps)..add(timestamp);

    return NewEmployeeModelHistory(
      id: id ?? this.id,
      timestamps: newTimestamps,

      // All existing fields get new entry - either new value or repeat last value
      firstName: List<String>.from(this.firstName)
        ..add(firstName ?? (this.firstName.isEmpty ? '' : this.firstName.last)),

      middleName: List<String>.from(this.middleName)
        ..add(middleName ??
            (this.middleName.isEmpty ? '' : this.middleName.last)),

      lastName: List<String>.from(this.lastName)
        ..add(lastName ?? (this.lastName.isEmpty ? '' : this.lastName.last)),

      firstNameInArabic: List<String>.from(this.firstNameInArabic)
        ..add(firstNameInArabic ??
            (this.firstNameInArabic.isEmpty
                ? ''
                : this.firstNameInArabic.last)),

      middleNameInArabic: List<String>.from(this.middleNameInArabic)
        ..add(middleNameInArabic ??
            (this.middleNameInArabic.isEmpty
                ? ''
                : this.middleNameInArabic.last)),

      lastNameInArabic: List<String>.from(this.lastNameInArabic)
        ..add(lastNameInArabic ??
            (this.lastNameInArabic.isEmpty ? '' : this.lastNameInArabic.last)),

      nationalId: List<String>.from(this.nationalId)
        ..add(nationalId ??
            (this.nationalId.isEmpty ? '' : this.nationalId.last)),

      nationalIdExpirationDate: List<String>.from(this.nationalIdExpirationDate)
        ..add(nationalIdExpirationDate ??
            (this.nationalIdExpirationDate.isEmpty
                ? ''
                : this.nationalIdExpirationDate.last)),

      nationality: List<String>.from(this.nationality)
        ..add(nationality ??
            (this.nationality.isEmpty ? '' : this.nationality.last)),

      passport: List<String>.from(this.passport)
        ..add(passport ?? (this.passport.isEmpty ? '' : this.passport.last)),

      passportExpirationDate: List<String>.from(this.passportExpirationDate)
        ..add(passportExpirationDate ??
            (this.passportExpirationDate.isEmpty
                ? ''
                : this.passportExpirationDate.last)),

      email: List<String>.from(this.email)
        ..add(email ?? (this.email.isEmpty ? '' : this.email.last)),

      mobilePhone: _synchronizeMobilePhoneList(
          this.mobilePhone, newTimestamps.length, mobilePhone),

      officePhone: List<String>.from(this.officePhone)
        ..add(officePhone ??
            (this.officePhone.isEmpty ? '' : this.officePhone.last)),

      homePhone: List<String>.from(this.homePhone)
        ..add(homePhone ?? (this.homePhone.isEmpty ? '' : this.homePhone.last)),

      extension: List<String>.from(this.extension)
        ..add(extension ?? (this.extension.isEmpty ? '' : this.extension.last)),

      birthDay: List<String>.from(this.birthDay)
        ..add(birthDay ?? (this.birthDay.isEmpty ? '' : this.birthDay.last)),

      gender: List<String>.from(this.gender)
        ..add(gender ?? (this.gender.isEmpty ? '' : this.gender.last)),

      country: List<String>.from(this.country)
        ..add(country ?? (this.country.isEmpty ? '' : this.country.last)),

      province: List<String>.from(this.province)
        ..add(province ?? (this.province.isEmpty ? '' : this.province.last)),

      city: List<String>.from(this.city)
        ..add(city ?? (this.city.isEmpty ? '' : this.city.last)),

      postalCode: List<String>.from(this.postalCode)
        ..add(postalCode ??
            (this.postalCode.isEmpty ? '' : this.postalCode.last)),

      street: List<String>.from(this.street)
        ..add(street ?? (this.street.isEmpty ? '' : this.street.last)),

      maritalStatus: List<String>.from(this.maritalStatus)
        ..add(maritalStatus ??
            (this.maritalStatus.isEmpty ? '' : this.maritalStatus.last)),

      language: List<String>.from(this.language)
        ..add(language ?? (this.language.isEmpty ? '' : this.language.last)),

      departmentId: List<String>.from(this.departmentId)
        ..add(departmentId ??
            (this.departmentId.isEmpty ? '' : this.departmentId.last)),

      supervisor: List<String>.from(this.supervisor)
        ..add(supervisor ??
            (this.supervisor.isEmpty ? '' : this.supervisor.last)),

      role: List<String>.from(this.role)
        ..add(role ?? (this.role.isEmpty ? '' : this.role.last)),

      title: List<String>.from(this.title)
        ..add(title ?? (this.title.isEmpty ? '' : this.title.last)),

      titleInArabic: List<String>.from(this.titleInArabic)
        ..add(titleInArabic ??
            (this.titleInArabic.isEmpty ? '' : this.titleInArabic.last)),

      workLocation: List<String>.from(this.workLocation)
        ..add(workLocation ??
            (this.workLocation.isEmpty ? '' : this.workLocation.last)),

      drivingLicenseId: List<String>.from(this.drivingLicenseId)
        ..add(drivingLicenseId ??
            (this.drivingLicenseId.isEmpty ? '' : this.drivingLicenseId.last)),

      carPlates: List<List<String>>.from(
          this.carPlates.map((e) => List<String>.from(e)))
        ..add(carPlates ?? (this.carPlates.isEmpty ? [] : this.carPlates.last)),

      academicHistory: List<Map<String, dynamic>>.from(this.academicHistory)
        ..add(academicHistory ??
            (this.academicHistory.isEmpty ? {} : this.academicHistory.last)),

      bio: List<String>.from(this.bio)
        ..add(bio ?? (this.bio.isEmpty ? '' : this.bio.last)),

      bioInArabic: List<String>.from(this.bioInArabic)
        ..add(bioInArabic ??
            (this.bioInArabic.isEmpty ? '' : this.bioInArabic.last)),

      photo: List<String>.from(this.photo)
        ..add(photo ?? (this.photo.isEmpty ? '' : this.photo.last)),

      skills:
      List<List<String>>.from(this.skills.map((e) => List<String>.from(e)))
        ..add(skills ?? (this.skills.isEmpty ? [] : this.skills.last)),

      hobbies:
      List<List<String>>.from(this.hobbies.map((e) => List<String>.from(e)))
        ..add(hobbies ?? (this.hobbies.isEmpty ? [] : this.hobbies.last)),

      status: List<String>.from(this.status)
        ..add(status ?? (this.status.isEmpty ? '' : this.status.last)),

      // Health Insurance Fields - Properly sync with existing timestamps
      insuranceName: _synchronizeFieldList(
          this.insuranceName, newTimestamps.length, insuranceName),
      insurancePolicyNumber: _synchronizeFieldList(this.insurancePolicyNumber,
          newTimestamps.length, insurancePolicyNumber),

      // 1st Emergency Contact Fields - Properly sync with existing timestamps
      firstContactFirstName: _synchronizeFieldList(this.firstContactFirstName,
          newTimestamps.length, firstContactFirstName),
      firstContactLastName: _synchronizeFieldList(this.firstContactLastName,
          newTimestamps.length, firstContactLastName),
      firstContactRelationship: _synchronizeFieldList(
          this.firstContactRelationship,
          newTimestamps.length,
          firstContactRelationship),
      firstContactEmail: _synchronizeFieldList(
          this.firstContactEmail, newTimestamps.length, firstContactEmail),
      firstContactPhone: _synchronizeFieldList(
          this.firstContactPhone, newTimestamps.length, firstContactPhone),
      firstContactLanguage: _synchronizeFieldList(this.firstContactLanguage,
          newTimestamps.length, firstContactLanguage),
      firstContactCountry: _synchronizeFieldList(
          this.firstContactCountry, newTimestamps.length, firstContactCountry),
      firstContactProvince: _synchronizeFieldList(this.firstContactProvince,
          newTimestamps.length, firstContactProvince),
      firstContactCity: _synchronizeFieldList(
          this.firstContactCity, newTimestamps.length, firstContactCity),
      firstContactStreet: _synchronizeFieldList(
          this.firstContactStreet, newTimestamps.length, firstContactStreet),

      // 2nd Emergency Contact Fields - Properly sync with existing timestamps
      secondContactFirstName: _synchronizeFieldList(this.secondContactFirstName,
          newTimestamps.length, secondContactFirstName),
      secondContactLastName: _synchronizeFieldList(this.secondContactLastName,
          newTimestamps.length, secondContactLastName),
      secondContactRelationship: _synchronizeFieldList(
          this.secondContactRelationship,
          newTimestamps.length,
          secondContactRelationship),
      secondContactEmail: _synchronizeFieldList(
          this.secondContactEmail, newTimestamps.length, secondContactEmail),
      secondContactPhone: _synchronizeFieldList(
          this.secondContactPhone, newTimestamps.length, secondContactPhone),
      secondContactLanguage: _synchronizeFieldList(this.secondContactLanguage,
          newTimestamps.length, secondContactLanguage),
      secondContactCountry: _synchronizeFieldList(this.secondContactCountry,
          newTimestamps.length, secondContactCountry),
      secondContactProvince: _synchronizeFieldList(this.secondContactProvince,
          newTimestamps.length, secondContactProvince),
      secondContactCity: _synchronizeFieldList(
          this.secondContactCity, newTimestamps.length, secondContactCity),
      secondContactStreet: _synchronizeFieldList(
          this.secondContactStreet, newTimestamps.length, secondContactStreet),

      personalEmail: List<String?>.from(this.personalEmail),
      homeCountryCode: List<String?>.from(this.homeCountryCode),
      officeCountryCode: List<String?>.from(this.officeCountryCode),
      homePhoneDetails: List<HomePhone>.from(this.homePhoneDetails),
      officePhoneDetails: List<OfficePhone>.from(this.officePhoneDetails),
      jobType: List<String?>.from(this.jobType),
      workArrangement: List<String?>.from(this.workArrangement),
      remoteStatus: List<String?>.from(this.remoteStatus),
      employeeGrade: List<String?>.from(this.employeeGrade),
      startDate: List<String?>.from(this.startDate),
      startTime: List<String?>.from(this.startTime),
      endTime: List<String?>.from(this.endTime),
      daysOff: List<String?>.from(this.daysOff),
      salary: List<String?>.from(this.salary),
      currency: List<String?>.from(this.currency),
      institutionName: List<String?>.from(this.institutionName),
      degree: List<String?>.from(this.degree),
      fieldOfStudy: List<String?>.from(this.fieldOfStudy),
      certificationStartDate: List<String?>.from(this.certificationStartDate),
      certificationEndDate: List<String?>.from(this.certificationEndDate),
      gradeOrScore: List<String?>.from(this.gradeOrScore),
      certificateId: List<String?>.from(this.certificateId),
      issuingAuthority: List<String?>.from(this.issuingAuthority),
      certificationDocumentUrl:
      List<String?>.from(this.certificationDocumentUrl),
      certificationNotes: List<String?>.from(this.certificationNotes),
      insuranceProviderContact:
      List<String?>.from(this.insuranceProviderContact),
      firstContactFirstNameArabic:
      List<String?>.from(this.firstContactFirstNameArabic),
      firstContactMiddleName: List<String?>.from(this.firstContactMiddleName),
      firstContactMiddleNameArabic:
      List<String?>.from(this.firstContactMiddleNameArabic),
      firstContactLastNameArabic:
      List<String?>.from(this.firstContactLastNameArabic),
      firstContactPhoneDetails:
      List<MobilePhone>.from(this.firstContactPhoneDetails),
      secondContactFirstNameArabic:
      List<String?>.from(this.secondContactFirstNameArabic),
      secondContactMiddleName: List<String?>.from(this.secondContactMiddleName),
      secondContactMiddleNameArabic:
      List<String?>.from(this.secondContactMiddleNameArabic),
      secondContactLastNameArabic:
      List<String?>.from(this.secondContactLastNameArabic),
      secondContactPhoneDetails:
      List<MobilePhone>.from(this.secondContactPhoneDetails),
      passportDocumentUrl: List<String?>.from(this.passportDocumentUrl),
      nationalIdFrontUrl: List<String?>.from(this.nationalIdFrontUrl),
      nationalIdBackUrl: List<String?>.from(this.nationalIdBackUrl),
      drivingLicenseDocumentUrl:
      List<String?>.from(this.drivingLicenseDocumentUrl),

      password: password ?? this.password,
      defaultPassword: defaultPassword ?? this.defaultPassword,
      passwordExpirationTime:
      passwordExpirationTime ?? this.passwordExpirationTime,
      passwordExpirationUnit:
      passwordExpirationUnit ?? this.passwordExpirationUnit,
      firstLogin: firstLogin ?? this.firstLogin,
      lastLogin: lastLogin ?? this.lastLogin,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      activationDate: activationDate ?? this.activationDate,
    );
  }

  /// Update a single field with synchronized history
  NewEmployeeModelHistory updateFieldSynchronized(
      String fieldName, dynamic value) {
    switch (fieldName) {
      case 'first_Name':
        return copyWithUpdateSynchronized(firstName: value.toString());
      case 'middle_Name':
        return copyWithUpdateSynchronized(middleName: value.toString());
      case 'last_name':
        return copyWithUpdateSynchronized(lastName: value.toString());
      case 'firstNameInArabic':
        return copyWithUpdateSynchronized(firstNameInArabic: value.toString());
      case 'middleNameInArabic':
        return copyWithUpdateSynchronized(middleNameInArabic: value.toString());
      case 'lastNameInArabic':
        return copyWithUpdateSynchronized(lastNameInArabic: value.toString());
      case 'nationalId':
        return copyWithUpdateSynchronized(nationalId: value.toString());
      case 'nationalIdExpirationDate':
        return copyWithUpdateSynchronized(
            nationalIdExpirationDate: value.toString());
      case 'nationality':
        return copyWithUpdateSynchronized(nationality: value.toString());
      case 'passport':
        return copyWithUpdateSynchronized(passport: value.toString());
      case 'passportExpirationDate':
        return copyWithUpdateSynchronized(
            passportExpirationDate: value.toString());
      case 'email':
        return copyWithUpdateSynchronized(email: value.toString());
      case 'mobilePhone':
        if (value is MobilePhone) {
          return copyWithUpdateSynchronized(mobilePhone: value);
        }
        throw ArgumentError(
            'Value for mobilePhone must be of type MobilePhone');
      case 'officePhone':
        return copyWithUpdateSynchronized(officePhone: value.toString());
      case 'homePhone':
        return copyWithUpdateSynchronized(homePhone: value.toString());
      case 'extension':
        return copyWithUpdateSynchronized(extension: value.toString());
      case 'birthDay':
        return copyWithUpdateSynchronized(birthDay: value.toString());
      case 'gender':
        return copyWithUpdateSynchronized(gender: value.toString());
      case 'country':
        return copyWithUpdateSynchronized(country: value.toString());
      case 'province':
        return copyWithUpdateSynchronized(province: value.toString());
      case 'city':
        return copyWithUpdateSynchronized(city: value.toString());
      case 'postalCode':
        return copyWithUpdateSynchronized(postalCode: value.toString());
      case 'street':
        return copyWithUpdateSynchronized(street: value.toString());
      case 'maritalStatus':
        return copyWithUpdateSynchronized(maritalStatus: value.toString());
      case 'language':
        return copyWithUpdateSynchronized(language: value.toString());
      case 'departmentId':
        return copyWithUpdateSynchronized(departmentId: value.toString());
      case 'supervisor':
        return copyWithUpdateSynchronized(supervisor: value.toString());
      case 'role':
        return copyWithUpdateSynchronized(role: value.toString());
      case 'title':
        return copyWithUpdateSynchronized(title: value.toString());
      case 'titleInArabic':
        return copyWithUpdateSynchronized(titleInArabic: value.toString());
      case 'workLocation':
        return copyWithUpdateSynchronized(workLocation: value.toString());
      case 'drivingLicenseId':
        return copyWithUpdateSynchronized(drivingLicenseId: value.toString());
      case 'carPlates':
        return copyWithUpdateSynchronized(carPlates: value as List<String>);
      case 'academicHistory':
        return copyWithUpdateSynchronized(
            academicHistory: value as Map<String, dynamic>);
      case 'bio':
        return copyWithUpdateSynchronized(bio: value.toString());
      case 'bioInArabic':
        return copyWithUpdateSynchronized(bioInArabic: value.toString());
      case 'photo':
        return copyWithUpdateSynchronized(photo: value.toString());
      case 'skills':
        return copyWithUpdateSynchronized(skills: value as List<String>);
      case 'hobbies':
        return copyWithUpdateSynchronized(hobbies: value as List<String>);
      case 'status':
        return copyWithUpdateSynchronized(status: value.toString());
    // Health Insurance Fields
      case 'insuranceName':
        return copyWithUpdateSynchronized(insuranceName: value.toString());
      case 'insurancePolicyNumber':
        return copyWithUpdateSynchronized(
            insurancePolicyNumber: value.toString());
    // 1st Emergency Contact Fields
      case 'firstContactFirstName':
        return copyWithUpdateSynchronized(
            firstContactFirstName: value.toString());
      case 'firstContactLastName':
        return copyWithUpdateSynchronized(
            firstContactLastName: value.toString());
      case 'firstContactRelationship':
        return copyWithUpdateSynchronized(
            firstContactRelationship: value.toString());
      case 'firstContactEmail':
        return copyWithUpdateSynchronized(firstContactEmail: value.toString());
      case 'firstContactPhone':
        return copyWithUpdateSynchronized(firstContactPhone: value.toString());
      case 'firstContactLanguage':
        return copyWithUpdateSynchronized(
            firstContactLanguage: value.toString());
      case 'firstContactCountry':
        return copyWithUpdateSynchronized(
            firstContactCountry: value.toString());
      case 'firstContactProvince':
        return copyWithUpdateSynchronized(
            firstContactProvince: value.toString());
      case 'firstContactCity':
        return copyWithUpdateSynchronized(firstContactCity: value.toString());
      case 'firstContactStreet':
        return copyWithUpdateSynchronized(firstContactStreet: value.toString());
    // 2nd Emergency Contact Fields
      case 'secondContactFirstName':
        return copyWithUpdateSynchronized(
            secondContactFirstName: value.toString());
      case 'secondContactLastName':
        return copyWithUpdateSynchronized(
            secondContactLastName: value.toString());
      case 'secondContactRelationship':
        return copyWithUpdateSynchronized(
            secondContactRelationship: value.toString());
      case 'secondContactEmail':
        return copyWithUpdateSynchronized(secondContactEmail: value.toString());
      case 'secondContactPhone':
        return copyWithUpdateSynchronized(secondContactPhone: value.toString());
      case 'secondContactLanguage':
        return copyWithUpdateSynchronized(
            secondContactLanguage: value.toString());
      case 'secondContactCountry':
        return copyWithUpdateSynchronized(
            secondContactCountry: value.toString());
      case 'secondContactProvince':
        return copyWithUpdateSynchronized(
            secondContactProvince: value.toString());
      case 'secondContactCity':
        return copyWithUpdateSynchronized(secondContactCity: value.toString());
      case 'secondContactStreet':
        return copyWithUpdateSynchronized(
            secondContactStreet: value.toString());
      case 'password':
        return copyWithUpdateSynchronized(password: value.toString());
      case 'defaultPassword':
        return copyWithUpdateSynchronized(defaultPassword: value.toString());
      case 'passwordExpirationTime':
        return copyWithUpdateSynchronized(
            passwordExpirationTime: value.toString());
      case 'passwordExpirationUnit':
        return copyWithUpdateSynchronized(
            passwordExpirationUnit: value.toString());
      case 'firstLogin':
        return copyWithUpdateSynchronized(firstLogin: value.toString());
      case 'lastLogin':
        return copyWithUpdateSynchronized(lastLogin: value.toString());
      case 'deactivationDate':
        return copyWithUpdateSynchronized(deactivationDate: value.toString());
      case 'activationDate':
        return copyWithUpdateSynchronized(activationDate: value.toString());
      default:
        throw ArgumentError('Unknown field: $fieldName');
    }
  }

  /// Convert NewEmployeeModelHistory to NewEmployeeModel
  NewEmployeeModel toNewEmployeeModel() {
    // Helper to convert list to map format that fromMap expects
    Map<String, dynamic> _createFieldMap(String fieldName, dynamic value) {
      if (value == null) return {};
      return {fieldName: value};
    }

    return NewEmployeeModel.fromMap({
      'Id': this.id,
      'First_Name': this.firstName,
      'Middle_Name': this.middleName,
      'Last_Name': this.lastName,
      'First_Name_In_Arabic': this.firstNameInArabic,
      'Middle_Name_In_Arabic': this.middleNameInArabic,
      'Last_Name_In_Arabic': this.lastNameInArabic,
      'National_Id': this.nationalId.isNotEmpty ? this.nationalId : null,
      'National_Id_Expiration_Date': this.nationalIdExpirationDate.isNotEmpty
          ? this.nationalIdExpirationDate
          : null,
      'Nationality': this.nationality.isNotEmpty ? this.nationality : null,
      'Passport': this.passport.isNotEmpty ? this.passport : null,
      'Passport_Expiration_Date': this.passportExpirationDate.isNotEmpty
          ? this.passportExpirationDate
          : null,
      'Email': this.email,
      'Mobile_Phone':
      this.mobilePhone.isNotEmpty ? this.mobilePhone.last.toMap() : null,
      'Office_Phone': this.officePhone,
      'Home_Phone': this.homePhone,
      'Extension': this.extension,
      'Birth_Day': this.birthDay.isNotEmpty ? this.birthDay : null,
      'Gender': this.gender.isNotEmpty ? this.gender : null,
      'Country': this.country.isNotEmpty ? this.country : null,
      'Province': this.province.isNotEmpty ? this.province : null,
      'City': this.city.isNotEmpty ? this.city : null,
      'Postal_Code': this.postalCode.isNotEmpty ? this.postalCode : null,
      'Street': this.street.isNotEmpty ? this.street : null,
      'Marital_Status':
      this.maritalStatus.isNotEmpty ? this.maritalStatus : null,
      'Language': this.language.isNotEmpty ? this.language : null,
      'Department_Id': this.departmentId,
      'Supervisor': this.supervisor,
      'Role': this.role,
      'Title': this.title.isNotEmpty ? this.title : null,
      'Title_In_Arabic':
      this.titleInArabic.isNotEmpty ? this.titleInArabic : null,
      'Work_Location': this.workLocation.isNotEmpty ? this.workLocation : null,
      'Driving_License_Id':
      this.drivingLicenseId.isNotEmpty ? this.drivingLicenseId : null,
      'Car_Plates': this.carPlates.isNotEmpty
          ? this.carPlates.map((plate) => {'items': plate}).toList()
          : null,
      'Academic_History':
      this.academicHistory.isNotEmpty ? this.academicHistory : null,
      'Bio': this.bio.isNotEmpty ? this.bio : null,
      'Bio_In_Arabic': this.bioInArabic.isNotEmpty ? this.bioInArabic : null,
      'Photo': this.photo.isNotEmpty ? this.photo : null,
      'Skills': this.skills.isNotEmpty
          ? this.skills.map((skill) => {'items': skill}).toList()
          : null,
      'Hobbies': this.hobbies.isNotEmpty
          ? this.hobbies.map((hobby) => {'items': hobby}).toList()
          : null,
      'Status': this.status,
      'Password': this.password,
      'Default_Password': this.defaultPassword,
      'First_Login': this.firstLogin,
      'Last_Login': this.lastLogin,
      'Deactivation_Date': this.deactivationDate,
      'Activation_Date': this.activationDate,
    });
  }

  /// Helper method to get current mobile phone
  MobilePhone? get currentMobilePhone {
    return mobilePhone.isNotEmpty ? mobilePhone.last : null;
  }

  /// Helper method to add a new mobile phone entry
  NewEmployeeModelHistory addMobilePhone(MobilePhone newPhone) {
    return copyWithUpdateSynchronized(mobilePhone: newPhone);
  }

  /// Get the current value of any field
  dynamic getCurrentValue(String fieldName) {
    switch (fieldName) {
    // Basic Information
      case 'firstName':
        return firstName.isNotEmpty ? firstName.last : '';
      case 'middleName':
        return middleName.isNotEmpty ? middleName.last : '';
      case 'lastName':
        return lastName.isNotEmpty ? lastName.last : '';
      case 'firstNameInArabic':
        return firstNameInArabic.isNotEmpty ? firstNameInArabic.last : '';
      case 'middleNameInArabic':
        return middleNameInArabic.isNotEmpty ? middleNameInArabic.last : '';
      case 'lastNameInArabic':
        return lastNameInArabic.isNotEmpty ? lastNameInArabic.last : '';
      case 'title':
        return title.isNotEmpty ? title.last : '';
      case 'titleInArabic':
        return titleInArabic.isNotEmpty ? titleInArabic.last : '';

    // Identification
      case 'nationalId':
        return nationalId.isNotEmpty ? nationalId.last : '';
      case 'nationalIdExpirationDate':
        return nationalIdExpirationDate.isNotEmpty
            ? nationalIdExpirationDate.last
            : '';
      case 'nationality':
        return nationality.isNotEmpty ? nationality.last : '';
      case 'passport':
        return passport.isNotEmpty ? passport.last : '';
      case 'passportExpirationDate':
        return passportExpirationDate.isNotEmpty
            ? passportExpirationDate.last
            : '';
      case 'drivingLicenseId':
        return drivingLicenseId.isNotEmpty ? drivingLicenseId.last : '';

    // Contact Information
      case 'email':
        return email.isNotEmpty ? email.last : '';
      case 'mobilePhone':
        return currentMobilePhone;
      case 'officePhone':
        return officePhone.isNotEmpty ? officePhone.last : '';
      case 'homePhone':
        return homePhone.isNotEmpty ? homePhone.last : '';
      case 'extension':
        return extension.isNotEmpty ? extension.last : '';

    // Personal Information
      case 'birthDay':
        return birthDay.isNotEmpty ? birthDay.last : '';
      case 'gender':
        return gender.isNotEmpty ? gender.last : '';
      case 'maritalStatus':
        return maritalStatus.isNotEmpty ? maritalStatus.last : '';
      case 'language':
        return language.isNotEmpty ? language.last : '';

    // Address Information
      case 'country':
        return country.isNotEmpty ? country.last : '';
      case 'province':
        return province.isNotEmpty ? province.last : '';
      case 'city':
        return city.isNotEmpty ? city.last : '';
      case 'postalCode':
        return postalCode.isNotEmpty ? postalCode.last : '';
      case 'street':
        return street.isNotEmpty ? street.last : '';

    // Employment Information
      case 'departmentId':
        return departmentId.isNotEmpty ? departmentId.last : '';
      case 'supervisor':
        return supervisor.isNotEmpty ? supervisor.last : '';
      case 'role':
        return role.isNotEmpty ? role.last : '';
      case 'workLocation':
        return workLocation.isNotEmpty ? workLocation.last : '';
      case 'status':
        return status.isNotEmpty ? status.last : '';

    // Additional Information
      case 'carPlates':
        return carPlates.isNotEmpty ? carPlates.last : [];
      case 'academicHistory':
        return academicHistory.isNotEmpty ? academicHistory.last : {};
      case 'bio':
        return bio.isNotEmpty ? bio.last : '';
      case 'bioInArabic':
        return bioInArabic.isNotEmpty ? bioInArabic.last : '';
      case 'photo':
        return photo.isNotEmpty ? photo.last : '';
      case 'skills':
        return skills.isNotEmpty ? skills.last : [];
      case 'hobbies':
        return hobbies.isNotEmpty ? hobbies.last : [];

    // Health Insurance
      case 'insuranceName':
        return insuranceName.isNotEmpty ? insuranceName.last : '';
      case 'insurancePolicyNumber':
        return insurancePolicyNumber.isNotEmpty
            ? insurancePolicyNumber.last
            : '';

    // 1st Emergency Contact
      case 'firstContactFirstName':
        return firstContactFirstName.isNotEmpty
            ? firstContactFirstName.last
            : '';
      case 'firstContactLastName':
        return firstContactLastName.isNotEmpty ? firstContactLastName.last : '';
      case 'firstContactRelationship':
        return firstContactRelationship.isNotEmpty
            ? firstContactRelationship.last
            : '';
      case 'firstContactEmail':
        return firstContactEmail.isNotEmpty ? firstContactEmail.last : '';
      case 'firstContactPhone':
        return firstContactPhone.isNotEmpty ? firstContactPhone.last : '';
      case 'firstContactLanguage':
        return firstContactLanguage.isNotEmpty ? firstContactLanguage.last : '';
      case 'firstContactCountry':
        return firstContactCountry.isNotEmpty ? firstContactCountry.last : '';
      case 'firstContactProvince':
        return firstContactProvince.isNotEmpty ? firstContactProvince.last : '';
      case 'firstContactCity':
        return firstContactCity.isNotEmpty ? firstContactCity.last : '';
      case 'firstContactStreet':
        return firstContactStreet.isNotEmpty ? firstContactStreet.last : '';

    // 2nd Emergency Contact
      case 'secondContactFirstName':
        return secondContactFirstName.isNotEmpty
            ? secondContactFirstName.last
            : '';
      case 'secondContactLastName':
        return secondContactLastName.isNotEmpty
            ? secondContactLastName.last
            : '';
      case 'secondContactRelationship':
        return secondContactRelationship.isNotEmpty
            ? secondContactRelationship.last
            : '';
      case 'secondContactEmail':
        return secondContactEmail.isNotEmpty ? secondContactEmail.last : '';
      case 'secondContactPhone':
        return secondContactPhone.isNotEmpty ? secondContactPhone.last : '';
      case 'secondContactLanguage':
        return secondContactLanguage.isNotEmpty
            ? secondContactLanguage.last
            : '';
      case 'secondContactCountry':
        return secondContactCountry.isNotEmpty ? secondContactCountry.last : '';
      case 'secondContactProvince':
        return secondContactProvince.isNotEmpty
            ? secondContactProvince.last
            : '';
      case 'secondContactCity':
        return secondContactCity.isNotEmpty ? secondContactCity.last : '';
      case 'secondContactStreet':
        return secondContactStreet.isNotEmpty ? secondContactStreet.last : '';

    // Account Information
      case 'password':
        return password ?? '';
      case 'defaultPassword':
        return defaultPassword ?? '';
      case 'passwordExpirationTime':
        return passwordExpirationTime ?? '';
      case 'passwordExpirationUnit':
        return passwordExpirationUnit ?? '';
      case 'firstLogin':
        return firstLogin ?? '';
      case 'lastLogin':
        return lastLogin ?? '';
      case 'deactivationDate':
        return deactivationDate ?? '';
      case 'activationDate':
        return activationDate ?? '';

    // Timestamps
      case 'timestamps':
        return timestamps.isNotEmpty ? timestamps.last : 0;

      default:
        return null;
    }
  }
}




// class NewEmployeeModel {
//   String? id;
//   FirstName? firstName;
//   MiddleName? middleName;
//   LastName? lastName;
//   FirstNameInArabic? firstNameInArabic;
//   MiddleNameInArabic? middleNameInArabic;
//   LastNameInArabic? lastNameInArabic;
//   NationalId? nationalId;
//   NationalIdExpirationDate? nationalIdExpirationDate;
//   Nationality? nationality;
//   Passport? passport;
//   PassportExpirationDate? passportExpirationDate;
//   Email? email;
//   MobilePhone? mobilePhone;
//   OfficePhone? officePhone;
//   HomePhone? homePhone;
//   Extension? extension;
//   BirthDay? birthDay;
//   Gender? gender;
//   Country? country;
//   Province? province;
//   City? city;
//   PostalCode? postalCode;
//   Street? street;
//   MaritalStatus? maritalStatus;
//   Language? language;
//   DepartmentId? departmentid;
//   Supervisor? supervisor;
//   Role? role;
//   TitleModel? title;
//   TitleInArabic? titleInArabic;
//   WorkLocation? workLocation;
//   DrivingLicenseId? drivingLicenseId;
//   CarPlates? carPlates;
//   AcademicHistory? academicHistory;
//   Bio? bio;
//   // ADDED 24/8/2026: the Arabic bio, its own Firestore field.
//   BioInArabic? bioInArabic;
//   Photo? photo;
//   Skills? skills;
//   Hobbies? hobbies;
//   Status? status;
//   String? password;
//   String? defaultPassword;
//   String? firstLogin;
//   String? lastLogin;
//   String? deactivationDate;
//   String? activationDate;
//
//   NewEmployeeModel({
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
//     this.departmentid,
//     this.supervisor,
//     this.role,
//     this.title,
//     this.titleInArabic,
//     this.workLocation,
//     this.drivingLicenseId,
//     this.carPlates,
//     this.academicHistory,
//     this.bio,
//     this.bioInArabic,
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
//   factory NewEmployeeModel.fromMap(Map? data) {
//     return NewEmployeeModel(
//       id: data?['Id'],
//       firstName: FirstName.fromMap(data?['First_Name']),
//       middleName: MiddleName.fromMap(data?['Middle_Name']),
//       lastName: LastName.fromMap(data?['Last_Name']),
//       firstNameInArabic:
//       FirstNameInArabic.fromMap(data?['First_Name_In_Arabic']),
//       middleNameInArabic:
//       MiddleNameInArabic.fromMap(data?['Middle_Name_In_Arabic']),
//       lastNameInArabic: LastNameInArabic.fromMap(data?['Last_Name_In_Arabic']),
//       nationalId:
//       data?['National_Id'] == null ? null :
//       NationalId.fromMap(data?['National_Id']),
//       nationalIdExpirationDate:
//       data?['National_Id_Expiration_Date'] == null ? null :
//       NationalIdExpirationDate.fromMap(
//           data?['National_Id_Expiration_Date']),
//       nationality:
//       data?['Nationality'] == null ? null :
//       Nationality.fromMap(data?['Nationality']),
//       passport:
//       data?['Passport'] == null ? null :
//       Passport.fromMap(data?['Passport']),
//       passportExpirationDate:
//       PassportExpirationDate.fromMap(data?['Passport_Expiration_Date']),
//       email: Email.fromMap(data?['Email']),
//       mobilePhone: MobilePhone.fromMap(data?['Mobile_Phone']),
//       officePhone: OfficePhone.fromMap(data?['Office_Phone']),
//       homePhone: HomePhone.fromMap(data?['Home_Phone']),
//       extension: Extension.fromMap(data?['Extension']),
//       birthDay:
//       data?['Birth_Day'] == null ? null :
//       BirthDay.fromMap(data?['Birth_Day']),
//       gender:
//       data?['Gender'] == null ? null :
//       Gender.fromMap(data?['Gender']),
//       country:
//       data?['Country'] == null ? null :
//       Country.fromMap(data?['Country']),
//       province:
//       data?['Province'] == null ? null :
//       Province.fromMap(data?['Province']),
//       city:
//       data?['City'] == null ? null :
//       City.fromMap(data?['City']),
//       postalCode:
//       data?['Postal_Code'] == null ? null :
//       PostalCode.fromMap(data?['Postal_Code']),
//       street:
//       data?['Street'] == null ? null :
//       Street.fromMap(data?['Street']),
//       maritalStatus:
//       data?['Marital_Status'] == null ? null :
//       MaritalStatus.fromMap(data?['Marital_Status']),
//       language:
//       data?['Language'] == null ? null :
//       Language.fromMap(data?['Language']),
//       departmentid: DepartmentId.fromMap(data?['Department_Id']),
//       supervisor: Supervisor.fromMap(data?['Supervisor']),
//       role: Role.fromMap(data?['Role']),
//       workLocation:
//       data?['Work_Location'] == null ? null :
//       WorkLocation.fromMap(data?['Work_Location']),
//       drivingLicenseId:
//       data?['Driving_License_Id'] == null ? null :
//       DrivingLicenseId.fromMap(data?['Driving_License_Id']),
//       carPlates:
//       data?['Car_Plates'] == null ? null :
//       CarPlates.fromMap(data?['Car_Plates']),
//       academicHistory:
//       data?['Academic_History'] == null ? null :
//       AcademicHistory.fromMap(data?['Academic_History']),
//       bio:
//       data?['Bio'] == null ? null :
//       Bio.fromMap(data?['Bio']),
//       bioInArabic:
//       data?['Bio_In_Arabic'] == null ? null :
//       BioInArabic.fromMap(data?['Bio_In_Arabic']),
//       skills:
//       data?['Skills'] == null ? null :
//       Skills.fromMap(data?['Skills']),
//       hobbies:
//       data?['Hobbies'] == null ? null :
//       Hobbies.fromMap(data?['Hobbies']),
//       status: Status.fromMap(data?['Status']),
//       photo:
//       data?['Photo'] == null ? null :
//       Photo.fromMap(data?['Photo']),
//       title:
//       data?['Title'] == null ? null :
//       TitleModel.fromMap(data?['Title']),
//       titleInArabic:
//       data?['Title_In_Arabic'] == null ? null :
//       TitleInArabic.fromMap(data?['Title_In_Arabic']),
//       password: data?['Password'],
//       defaultPassword: data?['Default_Password'],
//       firstLogin: data?['First_Login'],
//       lastLogin: data?['Last_Login'],
//       deactivationDate: data?['Deactivation_Date'],
//       activationDate: data?['Activation_Date'],
//     );
//   }
//
//   Map<String, dynamic> toMap() => {
//     'Id': id,
//     'First_Name': firstName!.toMap(),
//     'Middle_Name': middleName!.toMap(),
//     'Last_Name': lastName!.toMap(),
//     'First_Name_In_Arabic': firstNameInArabic!.toMap(),
//     'Middle_Name_In_Arabic': middleNameInArabic!.toMap(),
//     'Last_Name_In_Arabic': lastNameInArabic!.toMap(),
//     'Email': email!.toMap(),
//     'Mobile_Phone': mobilePhone!.toMap(),
//     'Office_Phone': officePhone!.toMap(),
//     'Home_Phone': homePhone!.toMap(),
//     'Extension': extension!.toMap(),
//     'Postal_Code': postalCode != null ? postalCode!.toMap() : null,
//     'Street': street != null ? street!.toMap() : null,
//     'National_Id': nationalId != null ? nationalId!.toMap() : null,
//     'National_Id_Expiration_Date': nationalIdExpirationDate != null
//         ? nationalIdExpirationDate!.toMap()
//         : null,
//     'Nationality': nationality != null ? nationality!.toMap() : null,
//     'Passport': passport != null ? passport!.toMap() : null,
//     'Passport_Expiration_Date': passportExpirationDate != null
//         ? passportExpirationDate!.toMap()
//         : null,
//     'Country': country != null ? country!.toMap() : null,
//     'Province': province != null ? province!.toMap() : null,
//     'City': city != null ? city!.toMap() : null,
//     'Gender': gender != null ? gender!.toMap() : null,
//     'Marital_Status': maritalStatus != null ? maritalStatus!.toMap() : null,
//     'Language': language != null ? language!.toMap() : null,
//     'Birth_Day': birthDay != null ? birthDay!.toMap() : null,
//     'Bio': bio != null ? bio!.toMap() : null,
//     'Bio_In_Arabic': bioInArabic != null ? bioInArabic!.toMap() : null,
//     'Academic_History':
//     academicHistory != null ? academicHistory!.toMap() : null,
//     'Skills': skills != null ? skills!.toMap() : null,
//     'Hobbies': hobbies != null ? hobbies!.toMap() : null,
//     'Password': password,
//     'Default_Password': defaultPassword,
//     'First_Login': firstLogin,
//     'Last_Login': lastLogin,
//     'Deactivation_Date': deactivationDate,
//     'Activation_Date': activationDate,
//     'Role': role!.toMap(),
//     'Department_Id': departmentid!.toMap(),
//     'Supervisor': supervisor!.toMap(),
//     'Work_Location': workLocation != null ? workLocation!.toMap() : null,
//     'Driving_License_Id':
//     drivingLicenseId != null ? drivingLicenseId!.toMap() : null,
//     'Car_Plates': carPlates != null ? carPlates!.toMap() : null,
//     'Photo': photo != null ? photo!.toMap() : null,
//     'Title': title!.toMap(),
//     'Title_In_Arabic': titleInArabic!.toMap(),
//     'Status': status!.toMap(),
//   };
//
//   String toJson() => json.encode(toMap());
//   Map<String, dynamic> fromJson(String jsonString) => json.decode(jsonString);
// }
//
//
// class NewEmployeeModelHistory {
//   String? id;
//   List<int> timestamps;
//   List<String> firstName;
//   List<String> middleName;
//   List<String> lastName;
//   List<String> firstNameInArabic;
//   List<String> middleNameInArabic;
//   List<String> lastNameInArabic;
//   List<String> nationalId;
//   List<String> nationalIdExpirationDate;
//   List<String> nationality;
//   List<String> passport;
//   List<String> passportExpirationDate;
//   List<String> email;
//   List<MobilePhone> mobilePhone;
//   List<String> officePhone;
//   List<String> homePhone;
//   List<String> extension;
//   List<String> birthDay;
//   List<String> gender;
//   List<String> country;
//   List<String> province;
//   List<String> city;
//   List<String> postalCode;
//   List<String> street;
//   List<String> maritalStatus;
//   List<String> language;
//   List<String> departmentId;
//   List<String> supervisor;
//   List<String> role;
//   List<String> title;
//   List<String> titleInArabic;
//   List<String> workLocation;
//   List<String> drivingLicenseId;
//   List<List<String>> carPlates;
//   List<Map<String, dynamic>> academicHistory;
//   List<String> bio;
//   List<String> bioInArabic;
//   List<String> photo;
//   List<List<String>> skills;
//   List<List<String>> hobbies;
//   List<String> status;
//
//   // Health Insurance Fields
//   List<String> insuranceName;
//   List<String> insurancePolicyNumber;
//
//   // 1st Emergency Contact Fields
//   List<String> firstContactFirstName;
//   List<String> firstContactLastName;
//   List<String> firstContactRelationship;
//   List<String> firstContactEmail;
//   List<String> firstContactPhone;
//   List<String> firstContactLanguage;
//   List<String> firstContactCountry;
//   List<String> firstContactProvince;
//   List<String> firstContactCity;
//   List<String> firstContactStreet;
//
//   // 2nd Emergency Contact Fields
//   List<String> secondContactFirstName;
//   List<String> secondContactLastName;
//   List<String> secondContactRelationship;
//   List<String> secondContactEmail;
//   List<String> secondContactPhone;
//   List<String> secondContactLanguage;
//   List<String> secondContactCountry;
//   List<String> secondContactProvince;
//   List<String> secondContactCity;
//   List<String> secondContactStreet;
//
//   String? password;
//   String? passwordExpirationTime;
//   String? passwordExpirationUnit;
//   String? defaultPassword;
//   String? firstLogin;
//   String? lastLogin;
//   String? deactivationDate;
//   String? activationDate;
//
//   NewEmployeeModelHistory({
//     this.id,
//     List<int>? timestamps,
//     List<String>? firstName,
//     List<String>? middleName,
//     List<String>? lastName,
//     List<String>? firstNameInArabic,
//     List<String>? middleNameInArabic,
//     List<String>? lastNameInArabic,
//     List<String>? nationalId,
//     List<String>? nationalIdExpirationDate,
//     List<String>? nationality,
//     List<String>? passport,
//     List<String>? passportExpirationDate,
//     List<String>? email,
//     List<MobilePhone>? mobilePhone,
//     List<String>? officePhone,
//     List<String>? homePhone,
//     List<String>? extension,
//     List<String>? birthDay,
//     List<String>? gender,
//     List<String>? country,
//     List<String>? province,
//     List<String>? city,
//     List<String>? postalCode,
//     List<String>? street,
//     List<String>? maritalStatus,
//     List<String>? language,
//     List<String>? departmentId,
//     List<String>? supervisor,
//     List<String>? role,
//     List<String>? title,
//     List<String>? titleInArabic,
//     List<String>? workLocation,
//     List<String>? drivingLicenseId,
//     List<List<String>>? carPlates,
//     List<Map<String, dynamic>>? academicHistory,
//     List<String>? bio,
//     List<String>? bioInArabic,
//     List<String>? photo,
//     List<List<String>>? skills,
//     List<List<String>>? hobbies,
//     List<String>? status,
//     // Health Insurance Parameters
//     List<String>? insuranceName,
//     List<String>? insurancePolicyNumber,
//     // 1st Emergency Contact Parameters
//     List<String>? firstContactFirstName,
//     List<String>? firstContactLastName,
//     List<String>? firstContactRelationship,
//     List<String>? firstContactEmail,
//     List<String>? firstContactPhone,
//     List<String>? firstContactLanguage,
//     List<String>? firstContactCountry,
//     List<String>? firstContactProvince,
//     List<String>? firstContactCity,
//     List<String>? firstContactStreet,
//     // 2nd Emergency Contact Parameters
//     List<String>? secondContactFirstName,
//     List<String>? secondContactLastName,
//     List<String>? secondContactRelationship,
//     List<String>? secondContactEmail,
//     List<String>? secondContactPhone,
//     List<String>? secondContactLanguage,
//     List<String>? secondContactCountry,
//     List<String>? secondContactProvince,
//     List<String>? secondContactCity,
//     List<String>? secondContactStreet,
//     this.password,
//     this.defaultPassword,
//     this.passwordExpirationTime,
//     this.passwordExpirationUnit,
//     this.firstLogin,
//     this.lastLogin,
//     this.deactivationDate,
//     this.activationDate,
//   })  : timestamps = timestamps ?? [DateTime.now().millisecondsSinceEpoch],
//         firstName = firstName ?? [],
//         middleName = middleName ?? [],
//         lastName = lastName ?? [],
//         firstNameInArabic = firstNameInArabic ?? [],
//         middleNameInArabic = middleNameInArabic ?? [],
//         lastNameInArabic = lastNameInArabic ?? [],
//         nationalId = nationalId ?? [],
//         nationalIdExpirationDate = nationalIdExpirationDate ?? [],
//         nationality = nationality ?? [],
//         passport = passport ?? [],
//         passportExpirationDate = passportExpirationDate ?? [],
//         email = email ?? [],
//         mobilePhone = mobilePhone ?? [],
//         officePhone = officePhone ?? [],
//         homePhone = homePhone ?? [],
//         extension = extension ?? [],
//         birthDay = birthDay ?? [],
//         gender = gender ?? [],
//         country = country ?? [],
//         province = province ?? [],
//         city = city ?? [],
//         postalCode = postalCode ?? [],
//         street = street ?? [],
//         maritalStatus = maritalStatus ?? [],
//         language = language ?? [],
//         departmentId = departmentId ?? [],
//         supervisor = supervisor ?? [],
//         role = role ?? [],
//         title = title ?? [],
//         titleInArabic = titleInArabic ?? [],
//         workLocation = workLocation ?? [],
//         drivingLicenseId = drivingLicenseId ?? [],
//         carPlates = carPlates ?? [],
//         academicHistory = academicHistory ?? [],
//         bio = bio ?? [],
//         bioInArabic = bioInArabic ?? [],
//         photo = photo ?? [],
//         skills = skills ?? [],
//         hobbies = hobbies ?? [],
//         status = status ?? [],
//   // Health Insurance Initialization
//         insuranceName = insuranceName ?? [],
//         insurancePolicyNumber = insurancePolicyNumber ?? [],
//   // 1st Emergency Contact Initialization
//         firstContactFirstName = firstContactFirstName ?? [],
//         firstContactLastName = firstContactLastName ?? [],
//         firstContactRelationship = firstContactRelationship ?? [],
//         firstContactEmail = firstContactEmail ?? [],
//         firstContactPhone = firstContactPhone ?? [],
//         firstContactLanguage = firstContactLanguage ?? [],
//         firstContactCountry = firstContactCountry ?? [],
//         firstContactProvince = firstContactProvince ?? [],
//         firstContactCity = firstContactCity ?? [],
//         firstContactStreet = firstContactStreet ?? [],
//   // 2nd Emergency Contact Initialization
//         secondContactFirstName = secondContactFirstName ?? [],
//         secondContactLastName = secondContactLastName ?? [],
//         secondContactRelationship = secondContactRelationship ?? [],
//         secondContactEmail = secondContactEmail ?? [],
//         secondContactPhone = secondContactPhone ?? [],
//         secondContactLanguage = secondContactLanguage ?? [],
//         secondContactCountry = secondContactCountry ?? [],
//         secondContactProvince = secondContactProvince ?? [],
//         secondContactCity = secondContactCity ?? [],
//         secondContactStreet = secondContactStreet ?? [];
//
//   factory NewEmployeeModelHistory.fromMap(Map? data) {
//     if (data == null) {
//       return NewEmployeeModelHistory(id: null);
//     }
//
//     // The `try { ... } catch (e, stack) { rethrow; }` that wrapped this body
//     // was removed 12/8/2026: rethrowing unchanged is a no-op, and §11.2 forbids
//     // try/catch under `data/models/`.
//     {
//       final List<int> sharedTimestamps = (data['timestamps'] as List<dynamic>?)
//           ?.map((e) => e is int ? e : (e as num).toInt())
//           .toList() ??
//           [DateTime.now().millisecondsSinceEpoch];
//
//       return NewEmployeeModelHistory(
//         id: data['Id'],
//         timestamps: sharedTimestamps,
//         firstName: _parseListSafely(data['First_Name']),
//         middleName: _parseListSafely(data['Middle_Name']),
//         lastName: _parseListSafely(data['Last_Name']),
//         firstNameInArabic: _parseListSafely(data['First_Name_In_Arabic']),
//         middleNameInArabic: _parseListSafely(data['Middle_Name_In_Arabic']),
//         lastNameInArabic: _parseListSafely(data['Last_Name_In_Arabic']),
//         nationalId: _parseListSafely(data['National_Id']),
//         nationalIdExpirationDate: _parseListSafely(data['National_Id_Expiration_Date']),
//         nationality: _parseListSafely(data['Nationality']),
//         passport: _parseListSafely(data['Passport']),
//         passportExpirationDate: _parseListSafely(data['Passport_Expiration_Date']),
//         email: _parseListSafely(data['Email']),
//         mobilePhone: _parseMobilePhoneList(data['Mobile_Phone']),
//         officePhone: _parseListSafely(data['Office_Phone']),
//         homePhone: _parseListSafely(data['Home_Phone']),
//         extension: _parseListSafely(data['Extension']),
//         birthDay: _parseListSafely(data['Birth_Day']),
//         gender: _parseListSafely(data['Gender']),
//         country: _parseListSafely(data['Country']),
//         province: _parseListSafely(data['Province']),
//         city: _parseListSafely(data['City']),
//         postalCode: _parseListSafely(data['Postal_Code']),
//         street: _parseListSafely(data['Street']),
//         maritalStatus: _parseListSafely(data['Marital_Status']),
//         language: _parseListSafely(data['Language']),
//         departmentId: _parseListSafely(data['Department_Id']),
//         supervisor: _parseListSafely(data['Supervisor']),
//         role: _parseListSafely(data['Role']),
//         title: _parseListSafely(data['Title']),
//         titleInArabic: _parseListSafely(data['Title_In_Arabic']),
//         workLocation: _parseListSafely(data['Work_Location']),
//         drivingLicenseId: _parseListSafely(data['Driving_License_Id']),
//         carPlates: _parseNestedListSafely(data['Car_Plates']),
//         academicHistory: _parseAcademicHistoryList(data['Academic_History']),
//         bio: _parseListSafely(data['Bio']),
//         bioInArabic: _parseListSafely(data['Bio_In_Arabic']),
//         photo: _parseListSafely(data['Photo']),
//         skills: _parseNestedListSafely(data['Skills']),
//         hobbies: _parseNestedListSafely(data['Hobbies']),
//         status: _parseListSafely(data['Status']),
//         // Health Insurance Fields
//         insuranceName: _parseListSafely(data['Insurance_Name']),
//         insurancePolicyNumber: _parseListSafely(data['Insurance_Policy_Number']),
//         // 1st Emergency Contact Fields
//         firstContactFirstName: _parseListSafely(data['First_Contact_First_Name']),
//         firstContactLastName: _parseListSafely(data['First_Contact_Last_Name']),
//         firstContactRelationship: _parseListSafely(data['First_Contact_Relationship']),
//         firstContactEmail: _parseListSafely(data['First_Contact_Email']),
//         firstContactPhone: _parseListSafely(data['First_Contact_Phone']),
//         firstContactLanguage: _parseListSafely(data['First_Contact_Language']),
//         firstContactCountry: _parseListSafely(data['First_Contact_Country']),
//         firstContactProvince: _parseListSafely(data['First_Contact_Province']),
//         firstContactCity: _parseListSafely(data['First_Contact_City']),
//         firstContactStreet: _parseListSafely(data['First_Contact_Street']),
//         // 2nd Emergency Contact Fields
//         secondContactFirstName: _parseListSafely(data['Second_Contact_First_Name']),
//         secondContactLastName: _parseListSafely(data['Second_Contact_Last_Name']),
//         secondContactRelationship: _parseListSafely(data['Second_Contact_Relationship']),
//         secondContactEmail: _parseListSafely(data['Second_Contact_Email']),
//         secondContactPhone: _parseListSafely(data['Second_Contact_Phone']),
//         secondContactLanguage: _parseListSafely(data['Second_Contact_Language']),
//         secondContactCountry: _parseListSafely(data['Second_Contact_Country']),
//         secondContactProvince: _parseListSafely(data['Second_Contact_Province']),
//         secondContactCity: _parseListSafely(data['Second_Contact_City']),
//         secondContactStreet: _parseListSafely(data['Second_Contact_Street']),
//         password: data['Password'],
//         defaultPassword: data['Default_Password'],
//         passwordExpirationTime: data['Password_Expiration_Time'],
//         passwordExpirationUnit: data['Password_Expiration_Unit'],
//         firstLogin: data['First_Login'],
//         lastLogin: data['Last_Login'],
//         deactivationDate: data['Deactivation_Date'],
//         activationDate: data['Activation_Date'],
//       );
//     }
//   }
//
//   Map<String, dynamic> toMap() {
//     // Helper function to convert nested lists to a format Firebase accepts
//     List<Map<String, dynamic>> convertNestedList(List<List<String>> nestedList) {
//       return nestedList.map((innerList) {
//         return {
//           'items': innerList,
//         };
//       }).toList();
//     }
//
//     return {
//       'Id': id,
//       'timestamps': timestamps,
//       'First_Name': firstName,
//       'Middle_Name': middleName,
//       'Last_Name': lastName,
//       'First_Name_In_Arabic': firstNameInArabic,
//       'Middle_Name_In_Arabic': middleNameInArabic,
//       'Last_Name_In_Arabic': lastNameInArabic,
//       'Email': email,
//       'Mobile_Phone': mobilePhone.map((phone) => phone.toMap()).toList(),
//       'Office_Phone': officePhone,
//       'Home_Phone': homePhone,
//       'Extension': extension,
//       'Postal_Code': postalCode,
//       'Street': street,
//       'National_Id': nationalId,
//       'National_Id_Expiration_Date': nationalIdExpirationDate,
//       'Nationality': nationality,
//       'Passport': passport,
//       'Passport_Expiration_Date': passportExpirationDate,
//       'Country': country,
//       'Province': province,
//       'City': city,
//       'Gender': gender,
//       'Marital_Status': maritalStatus,
//       'Language': language,
//       'Birth_Day': birthDay,
//       'Bio': bio,
//       'Bio_In_Arabic': bioInArabic,
//       'Academic_History': academicHistory,
//       'Skills': convertNestedList(skills),
//       'Hobbies': convertNestedList(hobbies),
//       'Password': password,
//       'Default_Password': defaultPassword,
//       'Password_Expiration_Time': passwordExpirationTime,
//       'Password_Expiration_Unit': passwordExpirationUnit,
//       'First_Login': firstLogin,
//       'Last_Login': lastLogin,
//       'Deactivation_Date': deactivationDate,
//       'Activation_Date': activationDate,
//       'Role': role,
//       'Department_Id': departmentId,
//       'Supervisor': supervisor,
//       'Work_Location': workLocation,
//       'Driving_License_Id': drivingLicenseId,
//       'Car_Plates': convertNestedList(carPlates),
//       'Photo': photo,
//       'Title': title,
//       'Title_In_Arabic': titleInArabic,
//       'Status': status,
//       // Health Insurance Fields
//       'Insurance_Name': insuranceName,
//       'Insurance_Policy_Number': insurancePolicyNumber,
//       // 1st Emergency Contact Fields
//       'First_Contact_First_Name': firstContactFirstName,
//       'First_Contact_Last_Name': firstContactLastName,
//       'First_Contact_Relationship': firstContactRelationship,
//       'First_Contact_Email': firstContactEmail,
//       'First_Contact_Phone': firstContactPhone,
//       'First_Contact_Language': firstContactLanguage,
//       'First_Contact_Country': firstContactCountry,
//       'First_Contact_Province': firstContactProvince,
//       'First_Contact_City': firstContactCity,
//       'First_Contact_Street': firstContactStreet,
//       // 2nd Emergency Contact Fields
//       'Second_Contact_First_Name': secondContactFirstName,
//       'Second_Contact_Last_Name': secondContactLastName,
//       'Second_Contact_Relationship': secondContactRelationship,
//       'Second_Contact_Email': secondContactEmail,
//       'Second_Contact_Phone': secondContactPhone,
//       'Second_Contact_Language': secondContactLanguage,
//       'Second_Contact_Country': secondContactCountry,
//       'Second_Contact_Province': secondContactProvince,
//       'Second_Contact_City': secondContactCity,
//       'Second_Contact_Street': secondContactStreet,
//     };
//   }
//
//   static List<String> _parseListSafely(dynamic value) {
//     if (value == null) return [];
//
//     // Handle string representation of empty array
//     if (value is String) {
//       if (value == '[]' || value.trim().isEmpty) {
//         return [];
//       }
//       return [value];
//     }
//
//     if (value is List) {
//       // Handle empty list
//       if (value.isEmpty) return [];
//
//       List<String> result = [];
//       for (var item in value) {
//         // Skip if item is the string "[]"
//         if (item is String && item == '[]') {
//           continue;
//         }
//
//         // If item is a Map with a field name
//         if (item is Map) {
//           for (var entry in item.entries) {
//             if (entry.key != 'Timestamp' && entry.value != null && entry.value is! Timestamp) {
//               // Skip if value is the string "[]"
//               if (entry.value is String && entry.value == '[]') {
//                 continue;
//               }
//
//               if (entry.value is List && (entry.value as List).isNotEmpty) {
//                 result.add((entry.value as List).first?.toString() ?? '');
//               } else {
//                 result.add(entry.value?.toString() ?? '');
//               }
//               break;
//             }
//           }
//         } else if (item is! Timestamp) {
//           result.add(item?.toString() ?? '');
//         }
//       }
//       return result;
//     }
//
//     // Single value (not a list)
//     if (value is Map) {
//       for (var entry in value.entries) {
//         if (entry.key != 'Timestamp' && entry.value != null && entry.value is! Timestamp) {
//           // Skip if value is the string "[]"
//           if (entry.value is String && entry.value == '[]') {
//             return [];
//           }
//
//           if (entry.value is List && (entry.value as List).isNotEmpty) {
//             return [(entry.value as List).first?.toString() ?? ''];
//           }
//           return [entry.value?.toString() ?? ''];
//         }
//       }
//       return [];
//     }
//
//     return [value.toString()];
//   }
//
//   /// Parses the `Skills` / `Hobbies` / `Car_Plates` shapes into a list of
//   /// entries, each entry being its own list of strings.
//   ///
//   /// FIXED 22/8/2026 — this is one of the reasons Skills and Hobbys read as
//   /// `-` on the employee profile even after the user had filled them in.
//   ///
//   /// Two defects:
//   ///
//   ///  1. **A top-level Map fell straight through to `return []`.** The current
//   ///     writer (`BuildSocialUpdate`) stores `Skills` as a *list* of
//   ///     `{items: [...]}` maps, which was handled — but the model classes in
//   ///     this same folder (`skills_model.dart`, `hobbies_model.dart`) describe
//   ///     the older shape, a single **map** of parallel history arrays:
//   ///     `{Skills: [...], Status: [...], Timestamp: [...]}`. Any document
//   ///     still in that shape lost its skills silently, with no log and no
//   ///     other branch. That case is handled now.
//   ///  2. **The `[[]]` sentinel.** Returning a list containing one empty list
//   ///     made `skills.isEmpty` false while every consumer's `map` produced
//   ///     `''` — so callers that guard on `isEmpty` to show `'-'` printed an
//   ///     empty string instead. An empty result is now simply empty.
//   static List<List<String>> _parseNestedListSafely(dynamic value) {
//     if (value == null) return [];
//
//     if (value is List) {
//       if (value.isEmpty) return [];
//
//       List<List<String>> result = [];
//       for (var item in value) {
//         // If item is a Map with nested structure
//         if (item is Map) {
//           // Check for the 'items' key (our new format)
//           if (item.containsKey('items') && item['items'] is List) {
//             result.add(List<String>.from((item['items'] as List).map((e) => e?.toString() ?? '')));
//             continue;
//           }
//
//           // Find the first non-Timestamp value (old format)
//           for (var entry in item.entries) {
//             if (entry.key != 'Timestamp' && entry.value != null && entry.value is! Timestamp) {
//               if (entry.value is List) {
//                 result.add(List<String>.from(entry.value.map((e) => e?.toString() ?? '')));
//               } else {
//                 result.add([entry.value?.toString() ?? '']);
//               }
//               break;
//             }
//           }
//         } else if (item is List) {
//           // Direct nested list (legacy format)
//           result.add(List<String>.from(item.map((e) => e?.toString() ?? '')));
//         }
//       }
//       return result;
//     }
//
//     // Legacy shape: one map of parallel history arrays, e.g.
//     // {Skills: ['Flutter', 'Dart'], Status: ['', ''], Timestamp: [...]}.
//     // Each element of the payload array is one entry, so it becomes its own
//     // single-element row — which is exactly what the `{items: [name]}` shape
//     // produces for a skill with no level.
//     if (value is Map) {
//       for (final entry in value.entries) {
//         if (entry.key == 'Timestamp' ||
//             entry.key == 'Status' ||
//             entry.value == null ||
//             entry.value is Timestamp) {
//           continue;
//         }
//
//         if (entry.value is List) {
//           return (entry.value as List)
//               .map((e) => <String>[e?.toString() ?? ''])
//               .where((row) => row.first.trim().isNotEmpty)
//               .toList();
//         }
//
//         final String single = entry.value.toString().trim();
//         return single.isEmpty ? <List<String>>[] : <List<String>>[<String>[single]];
//       }
//     }
//
//     return [];
//   }
//
//   static List<MobilePhone> _parseMobilePhoneList(dynamic value) {
//     if (value == null) return [];
//
//     if (value is List) {
//       List<MobilePhone> result = [];
//       for (var item in value) {
//         if (item is Map) {
//           try {
//             // Check if this is a wrapped map like {Mobile_Phone: {...}, Timestamp: ...}
//             Map<String, dynamic>? actualPhone;
//             for (var entry in item.entries) {
//               if (entry.key != 'Timestamp' && entry.value is Map) {
//                 actualPhone = Map<String, dynamic>.from(entry.value);
//                 break;
//               }
//             }
//
//             if (actualPhone != null) {
//               result.add(MobilePhone.fromMap(actualPhone));
//             } else {
//               // Direct MobilePhone map
//               Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
//               cleanMap.removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
//               if (cleanMap.isNotEmpty) {
//                 result.add(MobilePhone.fromMap(cleanMap));
//               }
//             }
//           } catch (e) {
//             // Malformed phone entry: skipped on purpose so one bad row does not
//             // lose the rest of the list. Was an empty `catch {}` (§11.5).
//             debugPrint('_parseMobilePhoneList: skipping malformed entry ($e)');
//           }
//         } else if (item is MobilePhone) {
//           result.add(item);
//         }
//       }
//       return result;
//     }
//
//     if (value is Map) {
//       try {
//         Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
//         cleanMap.removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
//         return cleanMap.isNotEmpty ? [MobilePhone.fromMap(cleanMap)] : [];
//       } catch (e) {
//         debugPrint('_parseMobilePhoneList: malformed single phone map ($e)');
//       }
//     }
//
//     return [];
//   }
//
//   static List<Map<String, dynamic>> _parseAcademicHistoryList(dynamic value) {
//     if (value == null) return [];
//
//     if (value is List) {
//       List<Map<String, dynamic>> result = [];
//       for (var item in value) {
//         if (item is Map) {
//           // Check if this is a wrapped map
//           Map<String, dynamic>? actualHistory;
//           for (var entry in item.entries) {
//             if (entry.key != 'Timestamp' && entry.value is Map) {
//               actualHistory = Map<String, dynamic>.from(entry.value);
//               break;
//             }
//           }
//           if (actualHistory != null) {
//             result.add(actualHistory);
//           } else {
//             // Direct map
//             Map<String, dynamic> cleanMap = Map<String, dynamic>.from(item);
//             cleanMap.removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
//             if (cleanMap.isNotEmpty) {
//               result.add(cleanMap);
//             }
//           }
//         }
//       }
//       return result;
//     }
//
//     if (value is Map) {
//       Map<String, dynamic> cleanMap = Map<String, dynamic>.from(value);
//       cleanMap.removeWhere((key, val) => val is Timestamp || key == 'Timestamp');
//       return cleanMap.isNotEmpty ? [cleanMap] : [];
//     }
//
//     return [];
//   }
//
//   /// Helper function to synchronize a field list with the target length
//   static List<String> _synchronizeFieldList(List<String> currentList, int targetLength, String? newValue) {
//     List<String> result = List<String>.from(currentList);
//
//     // First, ensure the list matches the OLD timestamp length (targetLength - 1)
//     int oldLength = targetLength - 1;
//     while (result.length < oldLength) {
//       result.add(''); // Fill missing entries with empty strings
//     }
//
//     // Now add the new entry
//     if (newValue != null) {
//       result.add(newValue);
//     } else {
//       result.add(result.isEmpty ? '' : result.last);
//     }
//
//     return result;
//   }
//
//   /// Helper function to synchronize a MobilePhone list with the target length
//   static List<MobilePhone> _synchronizeMobilePhoneList(List<MobilePhone> currentList, int targetLength, MobilePhone? newValue) {
//     List<MobilePhone> result = List<MobilePhone>.from(currentList);
//
//     // First, ensure the list matches the OLD timestamp length (targetLength - 1)
//     int oldLength = targetLength - 1;
//     while (result.length < oldLength) {
//       result.add(MobilePhone()); // Fill missing entries with empty MobilePhone
//     }
//
//     // Now add the new entry
//     if (newValue != null) {
//       result.add(newValue);
//     } else {
//       result.add(result.isEmpty ? MobilePhone() : result.last);
//     }
//
//     return result;
//   }
//
//   NewEmployeeModelHistory copyWithUpdateSynchronized({
//     String? id,
//     int? addTimestamp,
//     String? firstName,
//     String? middleName,
//     String? lastName,
//     String? firstNameInArabic,
//     String? middleNameInArabic,
//     String? lastNameInArabic,
//     String? nationalId,
//     String? nationalIdExpirationDate,
//     String? nationality,
//     String? passport,
//     String? passportExpirationDate,
//     String? email,
//     MobilePhone? mobilePhone,
//     String? officePhone,
//     String? homePhone,
//     String? extension,
//     String? birthDay,
//     String? gender,
//     String? country,
//     String? province,
//     String? city,
//     String? postalCode,
//     String? street,
//     String? maritalStatus,
//     String? language,
//     String? departmentId,
//     String? supervisor,
//     String? role,
//     String? title,
//     String? titleInArabic,
//     String? workLocation,
//     String? drivingLicenseId,
//     List<String>? carPlates,
//     Map<String, dynamic>? academicHistory,
//     String? bio,
//     String? bioInArabic,
//     String? photo,
//     List<String>? skills,
//     List<String>? hobbies,
//     String? status,
//     // Health Insurance Parameters
//     String? insuranceName,
//     String? insurancePolicyNumber,
//     // 1st Emergency Contact Parameters
//     String? firstContactFirstName,
//     String? firstContactLastName,
//     String? firstContactRelationship,
//     String? firstContactEmail,
//     String? firstContactPhone,
//     String? firstContactLanguage,
//     String? firstContactCountry,
//     String? firstContactProvince,
//     String? firstContactCity,
//     String? firstContactStreet,
//     // 2nd Emergency Contact Parameters
//     String? secondContactFirstName,
//     String? secondContactLastName,
//     String? secondContactRelationship,
//     String? secondContactEmail,
//     String? secondContactPhone,
//     String? secondContactLanguage,
//     String? secondContactCountry,
//     String? secondContactProvince,
//     String? secondContactCity,
//     String? secondContactStreet,
//     String? password,
//     String? defaultPassword,
//     String? passwordExpirationTime,
//     String? passwordExpirationUnit,
//     String? firstLogin,
//     String? lastLogin,
//     String? deactivationDate,
//     String? activationDate,
//   })
//   {
//     final timestamp = addTimestamp ?? DateTime.now().millisecondsSinceEpoch;
//     final newTimestamps = List<int>.from(timestamps)..add(timestamp);
//
//     return NewEmployeeModelHistory(
//       id: id ?? this.id,
//       timestamps: newTimestamps,
//
//       // All existing fields get new entry - either new value or repeat last value
//       firstName: List<String>.from(this.firstName)
//         ..add(firstName ?? (this.firstName.isEmpty ? '' : this.firstName.last)),
//
//       middleName: List<String>.from(this.middleName)
//         ..add(middleName ?? (this.middleName.isEmpty ? '' : this.middleName.last)),
//
//       lastName: List<String>.from(this.lastName)
//         ..add(lastName ?? (this.lastName.isEmpty ? '' : this.lastName.last)),
//
//       firstNameInArabic: List<String>.from(this.firstNameInArabic)
//         ..add(firstNameInArabic ?? (this.firstNameInArabic.isEmpty ? '' : this.firstNameInArabic.last)),
//
//       middleNameInArabic: List<String>.from(this.middleNameInArabic)
//         ..add(middleNameInArabic ?? (this.middleNameInArabic.isEmpty ? '' : this.middleNameInArabic.last)),
//
//       lastNameInArabic: List<String>.from(this.lastNameInArabic)
//         ..add(lastNameInArabic ?? (this.lastNameInArabic.isEmpty ? '' : this.lastNameInArabic.last)),
//
//       nationalId: List<String>.from(this.nationalId)
//         ..add(nationalId ?? (this.nationalId.isEmpty ? '' : this.nationalId.last)),
//
//       nationalIdExpirationDate: List<String>.from(this.nationalIdExpirationDate)
//         ..add(nationalIdExpirationDate ?? (this.nationalIdExpirationDate.isEmpty ? '' : this.nationalIdExpirationDate.last)),
//
//       nationality: List<String>.from(this.nationality)
//         ..add(nationality ?? (this.nationality.isEmpty ? '' : this.nationality.last)),
//
//       passport: List<String>.from(this.passport)
//         ..add(passport ?? (this.passport.isEmpty ? '' : this.passport.last)),
//
//       passportExpirationDate: List<String>.from(this.passportExpirationDate)
//         ..add(passportExpirationDate ?? (this.passportExpirationDate.isEmpty ? '' : this.passportExpirationDate.last)),
//
//       email: List<String>.from(this.email)
//         ..add(email ?? (this.email.isEmpty ? '' : this.email.last)),
//
//       mobilePhone: _synchronizeMobilePhoneList(this.mobilePhone, newTimestamps.length, mobilePhone),
//
//       officePhone: List<String>.from(this.officePhone)
//         ..add(officePhone ?? (this.officePhone.isEmpty ? '' : this.officePhone.last)),
//
//       homePhone: List<String>.from(this.homePhone)
//         ..add(homePhone ?? (this.homePhone.isEmpty ? '' : this.homePhone.last)),
//
//       extension: List<String>.from(this.extension)
//         ..add(extension ?? (this.extension.isEmpty ? '' : this.extension.last)),
//
//       birthDay: List<String>.from(this.birthDay)
//         ..add(birthDay ?? (this.birthDay.isEmpty ? '' : this.birthDay.last)),
//
//       gender: List<String>.from(this.gender)
//         ..add(gender ?? (this.gender.isEmpty ? '' : this.gender.last)),
//
//       country: List<String>.from(this.country)
//         ..add(country ?? (this.country.isEmpty ? '' : this.country.last)),
//
//       province: List<String>.from(this.province)
//         ..add(province ?? (this.province.isEmpty ? '' : this.province.last)),
//
//       city: List<String>.from(this.city)
//         ..add(city ?? (this.city.isEmpty ? '' : this.city.last)),
//
//       postalCode: List<String>.from(this.postalCode)
//         ..add(postalCode ?? (this.postalCode.isEmpty ? '' : this.postalCode.last)),
//
//       street: List<String>.from(this.street)
//         ..add(street ?? (this.street.isEmpty ? '' : this.street.last)),
//
//       maritalStatus: List<String>.from(this.maritalStatus)
//         ..add(maritalStatus ?? (this.maritalStatus.isEmpty ? '' : this.maritalStatus.last)),
//
//       language: List<String>.from(this.language)
//         ..add(language ?? (this.language.isEmpty ? '' : this.language.last)),
//
//       departmentId: List<String>.from(this.departmentId)
//         ..add(departmentId ?? (this.departmentId.isEmpty ? '' : this.departmentId.last)),
//
//       supervisor: List<String>.from(this.supervisor)
//         ..add(supervisor ?? (this.supervisor.isEmpty ? '' : this.supervisor.last)),
//
//       role: List<String>.from(this.role)
//         ..add(role ?? (this.role.isEmpty ? '' : this.role.last)),
//
//       title: List<String>.from(this.title)
//         ..add(title ?? (this.title.isEmpty ? '' : this.title.last)),
//
//       titleInArabic: List<String>.from(this.titleInArabic)
//         ..add(titleInArabic ?? (this.titleInArabic.isEmpty ? '' : this.titleInArabic.last)),
//
//       workLocation: List<String>.from(this.workLocation)
//         ..add(workLocation ?? (this.workLocation.isEmpty ? '' : this.workLocation.last)),
//
//       drivingLicenseId: List<String>.from(this.drivingLicenseId)
//         ..add(drivingLicenseId ?? (this.drivingLicenseId.isEmpty ? '' : this.drivingLicenseId.last)),
//
//       carPlates: List<List<String>>.from(this.carPlates.map((e) => List<String>.from(e)))
//         ..add(carPlates ?? (this.carPlates.isEmpty ? [] : this.carPlates.last)),
//
//       academicHistory: List<Map<String, dynamic>>.from(this.academicHistory)
//         ..add(academicHistory ?? (this.academicHistory.isEmpty ? {} : this.academicHistory.last)),
//
//       bio: List<String>.from(this.bio)
//         ..add(bio ?? (this.bio.isEmpty ? '' : this.bio.last)),
//
//       bioInArabic: List<String>.from(this.bioInArabic)
//         ..add(bioInArabic ??
//             (this.bioInArabic.isEmpty ? '' : this.bioInArabic.last)),
//
//       photo: List<String>.from(this.photo)
//         ..add(photo ?? (this.photo.isEmpty ? '' : this.photo.last)),
//
//       skills: List<List<String>>.from(this.skills.map((e) => List<String>.from(e)))
//         ..add(skills ?? (this.skills.isEmpty ? [] : this.skills.last)),
//
//       hobbies: List<List<String>>.from(this.hobbies.map((e) => List<String>.from(e)))
//         ..add(hobbies ?? (this.hobbies.isEmpty ? [] : this.hobbies.last)),
//
//       status: List<String>.from(this.status)
//         ..add(status ?? (this.status.isEmpty ? '' : this.status.last)),
//
//       // Health Insurance Fields - Properly sync with existing timestamps
//       insuranceName: _synchronizeFieldList(this.insuranceName, newTimestamps.length, insuranceName),
//       insurancePolicyNumber: _synchronizeFieldList(this.insurancePolicyNumber, newTimestamps.length, insurancePolicyNumber),
//
//       // 1st Emergency Contact Fields - Properly sync with existing timestamps
//       firstContactFirstName: _synchronizeFieldList(this.firstContactFirstName, newTimestamps.length, firstContactFirstName),
//       firstContactLastName: _synchronizeFieldList(this.firstContactLastName, newTimestamps.length, firstContactLastName),
//       firstContactRelationship: _synchronizeFieldList(this.firstContactRelationship, newTimestamps.length, firstContactRelationship),
//       firstContactEmail: _synchronizeFieldList(this.firstContactEmail, newTimestamps.length, firstContactEmail),
//       firstContactPhone: _synchronizeFieldList(this.firstContactPhone, newTimestamps.length, firstContactPhone),
//       firstContactLanguage: _synchronizeFieldList(this.firstContactLanguage, newTimestamps.length, firstContactLanguage),
//       firstContactCountry: _synchronizeFieldList(this.firstContactCountry, newTimestamps.length, firstContactCountry),
//       firstContactProvince: _synchronizeFieldList(this.firstContactProvince, newTimestamps.length, firstContactProvince),
//       firstContactCity: _synchronizeFieldList(this.firstContactCity, newTimestamps.length, firstContactCity),
//       firstContactStreet: _synchronizeFieldList(this.firstContactStreet, newTimestamps.length, firstContactStreet),
//
//       // 2nd Emergency Contact Fields - Properly sync with existing timestamps
//       secondContactFirstName: _synchronizeFieldList(this.secondContactFirstName, newTimestamps.length, secondContactFirstName),
//       secondContactLastName: _synchronizeFieldList(this.secondContactLastName, newTimestamps.length, secondContactLastName),
//       secondContactRelationship: _synchronizeFieldList(this.secondContactRelationship, newTimestamps.length, secondContactRelationship),
//       secondContactEmail: _synchronizeFieldList(this.secondContactEmail, newTimestamps.length, secondContactEmail),
//       secondContactPhone: _synchronizeFieldList(this.secondContactPhone, newTimestamps.length, secondContactPhone),
//       secondContactLanguage: _synchronizeFieldList(this.secondContactLanguage, newTimestamps.length, secondContactLanguage),
//       secondContactCountry: _synchronizeFieldList(this.secondContactCountry, newTimestamps.length, secondContactCountry),
//       secondContactProvince: _synchronizeFieldList(this.secondContactProvince, newTimestamps.length, secondContactProvince),
//       secondContactCity: _synchronizeFieldList(this.secondContactCity, newTimestamps.length, secondContactCity),
//       secondContactStreet: _synchronizeFieldList(this.secondContactStreet, newTimestamps.length, secondContactStreet),
//
//       password: password ?? this.password,
//       defaultPassword: defaultPassword ?? this.defaultPassword,
//       passwordExpirationTime: passwordExpirationTime ?? this.passwordExpirationTime,
//       passwordExpirationUnit: passwordExpirationUnit ?? this.passwordExpirationUnit,
//       firstLogin: firstLogin ?? this.firstLogin,
//       lastLogin: lastLogin ?? this.lastLogin,
//       deactivationDate: deactivationDate ?? this.deactivationDate,
//       activationDate: activationDate ?? this.activationDate,
//     );
//   }
//
//   /// Update a single field with synchronized history
//   ///
//   /// FIXED 13/8/2026: the first three cases read `first_Name`, `middle_Name`
//   /// and `last_name` while every caller passes the camelCase model field name
//   /// (`firstName`, `middleName`, `lastName`) — the settings request mapping,
//   /// `UserManagementController.mapFieldName` and the org-chart profile editor
//   /// all do. No call site anywhere in the app used the old spellings, so a
//   /// name change fell through to `default:` and threw `Unknown field`, which
//   /// aborted the whole approval batch and left the profile untouched. The
//   /// camelCase spellings are now the real cases; the old ones are kept as
//   /// fall-through aliases in case a stored request still carries them.
//   NewEmployeeModelHistory updateFieldSynchronized(String fieldName, dynamic value) {
//     switch (fieldName) {
//       case 'firstName':
//       case 'first_Name':
//         return copyWithUpdateSynchronized(firstName: value.toString());
//       case 'middleName':
//       case 'middle_Name':
//         return copyWithUpdateSynchronized(middleName: value.toString());
//       case 'lastName':
//       case 'last_name':
//         return copyWithUpdateSynchronized(lastName: value.toString());
//       case 'firstNameInArabic':
//         return copyWithUpdateSynchronized(firstNameInArabic: value.toString());
//       case 'middleNameInArabic':
//         return copyWithUpdateSynchronized(middleNameInArabic: value.toString());
//       case 'lastNameInArabic':
//         return copyWithUpdateSynchronized(lastNameInArabic: value.toString());
//       case 'nationalId':
//         return copyWithUpdateSynchronized(nationalId: value.toString());
//       case 'nationalIdExpirationDate':
//         return copyWithUpdateSynchronized(nationalIdExpirationDate: value.toString());
//       case 'nationality':
//         return copyWithUpdateSynchronized(nationality: value.toString());
//       case 'passport':
//         return copyWithUpdateSynchronized(passport: value.toString());
//       case 'passportExpirationDate':
//         return copyWithUpdateSynchronized(passportExpirationDate: value.toString());
//       case 'email':
//         return copyWithUpdateSynchronized(email: value.toString());
//       case 'mobilePhone':
//         if (value is MobilePhone) {
//           return copyWithUpdateSynchronized(mobilePhone: value);
//         }
//         throw ArgumentError('Value for mobilePhone must be of type MobilePhone');
//       case 'officePhone':
//         return copyWithUpdateSynchronized(officePhone: value.toString());
//       case 'homePhone':
//         return copyWithUpdateSynchronized(homePhone: value.toString());
//       case 'extension':
//         return copyWithUpdateSynchronized(extension: value.toString());
//       case 'birthDay':
//         return copyWithUpdateSynchronized(birthDay: value.toString());
//       case 'gender':
//         return copyWithUpdateSynchronized(gender: value.toString());
//       case 'country':
//         return copyWithUpdateSynchronized(country: value.toString());
//       case 'province':
//         return copyWithUpdateSynchronized(province: value.toString());
//       case 'city':
//         return copyWithUpdateSynchronized(city: value.toString());
//       case 'postalCode':
//         return copyWithUpdateSynchronized(postalCode: value.toString());
//       case 'street':
//         return copyWithUpdateSynchronized(street: value.toString());
//       case 'maritalStatus':
//         return copyWithUpdateSynchronized(maritalStatus: value.toString());
//       case 'language':
//         return copyWithUpdateSynchronized(language: value.toString());
//       case 'departmentId':
//         return copyWithUpdateSynchronized(departmentId: value.toString());
//       case 'supervisor':
//         return copyWithUpdateSynchronized(supervisor: value.toString());
//       case 'role':
//         return copyWithUpdateSynchronized(role: value.toString());
//       case 'title':
//         return copyWithUpdateSynchronized(title: value.toString());
//       case 'titleInArabic':
//         return copyWithUpdateSynchronized(titleInArabic: value.toString());
//       case 'workLocation':
//         return copyWithUpdateSynchronized(workLocation: value.toString());
//       case 'drivingLicenseId':
//         return copyWithUpdateSynchronized(drivingLicenseId: value.toString());
//       case 'carPlates':
//         return copyWithUpdateSynchronized(carPlates: value as List<String>);
//       case 'academicHistory':
//         return copyWithUpdateSynchronized(academicHistory: value as Map<String, dynamic>);
//       case 'bio':
//         return copyWithUpdateSynchronized(bio: value.toString());
//       case 'bioInArabic':
//         return copyWithUpdateSynchronized(bioInArabic: value.toString());
//       case 'photo':
//         return copyWithUpdateSynchronized(photo: value.toString());
//       case 'skills':
//         return copyWithUpdateSynchronized(skills: value as List<String>);
//       case 'hobbies':
//         return copyWithUpdateSynchronized(hobbies: value as List<String>);
//       case 'status':
//         return copyWithUpdateSynchronized(status: value.toString());
//     // Health Insurance Fields
//       case 'insuranceName':
//         return copyWithUpdateSynchronized(insuranceName: value.toString());
//       case 'insurancePolicyNumber':
//         return copyWithUpdateSynchronized(insurancePolicyNumber: value.toString());
//     // 1st Emergency Contact Fields
//       case 'firstContactFirstName':
//         return copyWithUpdateSynchronized(firstContactFirstName: value.toString());
//       case 'firstContactLastName':
//         return copyWithUpdateSynchronized(firstContactLastName: value.toString());
//       case 'firstContactRelationship':
//         return copyWithUpdateSynchronized(firstContactRelationship: value.toString());
//       case 'firstContactEmail':
//         return copyWithUpdateSynchronized(firstContactEmail: value.toString());
//       case 'firstContactPhone':
//         return copyWithUpdateSynchronized(firstContactPhone: value.toString());
//       case 'firstContactLanguage':
//         return copyWithUpdateSynchronized(firstContactLanguage: value.toString());
//       case 'firstContactCountry':
//         return copyWithUpdateSynchronized(firstContactCountry: value.toString());
//       case 'firstContactProvince':
//         return copyWithUpdateSynchronized(firstContactProvince: value.toString());
//       case 'firstContactCity':
//         return copyWithUpdateSynchronized(firstContactCity: value.toString());
//       case 'firstContactStreet':
//         return copyWithUpdateSynchronized(firstContactStreet: value.toString());
//     // 2nd Emergency Contact Fields
//       case 'secondContactFirstName':
//         return copyWithUpdateSynchronized(secondContactFirstName: value.toString());
//       case 'secondContactLastName':
//         return copyWithUpdateSynchronized(secondContactLastName: value.toString());
//       case 'secondContactRelationship':
//         return copyWithUpdateSynchronized(secondContactRelationship: value.toString());
//       case 'secondContactEmail':
//         return copyWithUpdateSynchronized(secondContactEmail: value.toString());
//       case 'secondContactPhone':
//         return copyWithUpdateSynchronized(secondContactPhone: value.toString());
//       case 'secondContactLanguage':
//         return copyWithUpdateSynchronized(secondContactLanguage: value.toString());
//       case 'secondContactCountry':
//         return copyWithUpdateSynchronized(secondContactCountry: value.toString());
//       case 'secondContactProvince':
//         return copyWithUpdateSynchronized(secondContactProvince: value.toString());
//       case 'secondContactCity':
//         return copyWithUpdateSynchronized(secondContactCity: value.toString());
//       case 'secondContactStreet':
//         return copyWithUpdateSynchronized(secondContactStreet: value.toString());
//       case 'password':
//         return copyWithUpdateSynchronized(password: value.toString());
//       case 'defaultPassword':
//         return copyWithUpdateSynchronized(defaultPassword: value.toString());
//       case 'passwordExpirationTime':
//         return copyWithUpdateSynchronized(passwordExpirationTime: value.toString());
//       case 'passwordExpirationUnit':
//         return copyWithUpdateSynchronized(passwordExpirationUnit: value.toString());
//       case 'firstLogin':
//         return copyWithUpdateSynchronized(firstLogin: value.toString());
//       case 'lastLogin':
//         return copyWithUpdateSynchronized(lastLogin: value.toString());
//       case 'deactivationDate':
//         return copyWithUpdateSynchronized(deactivationDate: value.toString());
//       case 'activationDate':
//         return copyWithUpdateSynchronized(activationDate: value.toString());
//       default:
//         throw ArgumentError('Unknown field: $fieldName');
//     }
//   }
//
//   /// Convert NewEmployeeModelHistory to NewEmployeeModel
//   NewEmployeeModel toNewEmployeeModel() {
//     // REMOVED 12/8/2026: nested `_createFieldMap` — declared here and never
//     // invoked, and a leading-underscore local identifier trips the lint.
//
//     return NewEmployeeModel.fromMap({
//       'Id': this.id,
//       'First_Name': this.firstName,
//       'Middle_Name': this.middleName,
//       'Last_Name': this.lastName,
//       'First_Name_In_Arabic': this.firstNameInArabic,
//       'Middle_Name_In_Arabic': this.middleNameInArabic,
//       'Last_Name_In_Arabic': this.lastNameInArabic,
//       'National_Id': this.nationalId.isNotEmpty ? this.nationalId : null,
//       'National_Id_Expiration_Date': this.nationalIdExpirationDate.isNotEmpty ? this.nationalIdExpirationDate : null,
//       'Nationality': this.nationality.isNotEmpty ? this.nationality : null,
//       'Passport': this.passport.isNotEmpty ? this.passport : null,
//       'Passport_Expiration_Date': this.passportExpirationDate.isNotEmpty ? this.passportExpirationDate : null,
//       'Email': this.email,
//       'Mobile_Phone': this.mobilePhone.isNotEmpty ? this.mobilePhone.last.toMap() : null,
//       'Office_Phone': this.officePhone,
//       'Home_Phone': this.homePhone,
//       'Extension': this.extension,
//       'Birth_Day': this.birthDay.isNotEmpty ? this.birthDay : null,
//       'Gender': this.gender.isNotEmpty ? this.gender : null,
//       'Country': this.country.isNotEmpty ? this.country : null,
//       'Province': this.province.isNotEmpty ? this.province : null,
//       'City': this.city.isNotEmpty ? this.city : null,
//       'Postal_Code': this.postalCode.isNotEmpty ? this.postalCode : null,
//       'Street': this.street.isNotEmpty ? this.street : null,
//       'Marital_Status': this.maritalStatus.isNotEmpty ? this.maritalStatus : null,
//       'Language': this.language.isNotEmpty ? this.language : null,
//       'Department_Id': this.departmentId,
//       'Supervisor': this.supervisor,
//       'Role': this.role,
//       'Title': this.title.isNotEmpty ? this.title : null,
//       'Title_In_Arabic': this.titleInArabic.isNotEmpty ? this.titleInArabic : null,
//       'Work_Location': this.workLocation.isNotEmpty ? this.workLocation : null,
//       'Driving_License_Id': this.drivingLicenseId.isNotEmpty ? this.drivingLicenseId : null,
//       'Car_Plates': this.carPlates.isNotEmpty ? this.carPlates.map((plate) => {'items': plate}).toList() : null,
//       'Academic_History': this.academicHistory.isNotEmpty ? this.academicHistory : null,
//       'Bio': this.bio.isNotEmpty ? this.bio : null,
//       'Bio_In_Arabic': this.bioInArabic.isNotEmpty ? this.bioInArabic : null,
//       'Photo': this.photo.isNotEmpty ? this.photo : null,
//       'Skills': this.skills.isNotEmpty ? this.skills.map((skill) => {'items': skill}).toList() : null,
//       'Hobbies': this.hobbies.isNotEmpty ? this.hobbies.map((hobby) => {'items': hobby}).toList() : null,
//       'Status': this.status,
//       'Password': this.password,
//       'Default_Password': this.defaultPassword,
//       'First_Login': this.firstLogin,
//       'Last_Login': this.lastLogin,
//       'Deactivation_Date': this.deactivationDate,
//       'Activation_Date': this.activationDate,
//     });
//   }
//
//   /// Helper method to get current mobile phone
//   MobilePhone? get currentMobilePhone {
//     return mobilePhone.isNotEmpty ? mobilePhone.last : null;
//   }
//
//   /// Helper method to add a new mobile phone entry
//   NewEmployeeModelHistory addMobilePhone(MobilePhone newPhone) {
//     return copyWithUpdateSynchronized(mobilePhone: newPhone);
//   }
//
//   /// Get the current value of any field
//   dynamic getCurrentValue(String fieldName) {
//     switch (fieldName) {
//     // Basic Information
//       case 'firstName':
//         return firstName.isNotEmpty ? firstName.last : '';
//       case 'middleName':
//         return middleName.isNotEmpty ? middleName.last : '';
//       case 'lastName':
//         return lastName.isNotEmpty ? lastName.last : '';
//       case 'firstNameInArabic':
//         return firstNameInArabic.isNotEmpty ? firstNameInArabic.last : '';
//       case 'middleNameInArabic':
//         return middleNameInArabic.isNotEmpty ? middleNameInArabic.last : '';
//       case 'lastNameInArabic':
//         return lastNameInArabic.isNotEmpty ? lastNameInArabic.last : '';
//       case 'title':
//         return title.isNotEmpty ? title.last : '';
//       case 'titleInArabic':
//         return titleInArabic.isNotEmpty ? titleInArabic.last : '';
//
//     // Identification
//       case 'nationalId':
//         return nationalId.isNotEmpty ? nationalId.last : '';
//       case 'nationalIdExpirationDate':
//         return nationalIdExpirationDate.isNotEmpty ? nationalIdExpirationDate.last : '';
//       case 'nationality':
//         return nationality.isNotEmpty ? nationality.last : '';
//       case 'passport':
//         return passport.isNotEmpty ? passport.last : '';
//       case 'passportExpirationDate':
//         return passportExpirationDate.isNotEmpty ? passportExpirationDate.last : '';
//       case 'drivingLicenseId':
//         return drivingLicenseId.isNotEmpty ? drivingLicenseId.last : '';
//
//     // Contact Information
//       case 'email':
//         return email.isNotEmpty ? email.last : '';
//       case 'mobilePhone':
//         return currentMobilePhone;
//       case 'officePhone':
//         return officePhone.isNotEmpty ? officePhone.last : '';
//       case 'homePhone':
//         return homePhone.isNotEmpty ? homePhone.last : '';
//       case 'extension':
//         return extension.isNotEmpty ? extension.last : '';
//
//     // Personal Information
//       case 'birthDay':
//         return birthDay.isNotEmpty ? birthDay.last : '';
//       case 'gender':
//         return gender.isNotEmpty ? gender.last : '';
//       case 'maritalStatus':
//         return maritalStatus.isNotEmpty ? maritalStatus.last : '';
//       case 'language':
//         return language.isNotEmpty ? language.last : '';
//
//     // Address Information
//       case 'country':
//         return country.isNotEmpty ? country.last : '';
//       case 'province':
//         return province.isNotEmpty ? province.last : '';
//       case 'city':
//         return city.isNotEmpty ? city.last : '';
//       case 'postalCode':
//         return postalCode.isNotEmpty ? postalCode.last : '';
//       case 'street':
//         return street.isNotEmpty ? street.last : '';
//
//     // Employment Information
//       case 'departmentId':
//         return departmentId.isNotEmpty ? departmentId.last : '';
//       case 'supervisor':
//         return supervisor.isNotEmpty ? supervisor.last : '';
//       case 'role':
//         return role.isNotEmpty ? role.last : '';
//       case 'workLocation':
//         return workLocation.isNotEmpty ? workLocation.last : '';
//       case 'status':
//         return status.isNotEmpty ? status.last : '';
//
//     // Additional Information
//       case 'carPlates':
//         return carPlates.isNotEmpty ? carPlates.last : [];
//       case 'academicHistory':
//         return academicHistory.isNotEmpty ? academicHistory.last : {};
//       case 'bio':
//         return bio.isNotEmpty ? bio.last : '';
//       case 'bioInArabic':
//         return bioInArabic.isNotEmpty ? bioInArabic.last : '';
//       case 'photo':
//         return photo.isNotEmpty ? photo.last : '';
//       case 'skills':
//         return skills.isNotEmpty ? skills.last : [];
//       case 'hobbies':
//         return hobbies.isNotEmpty ? hobbies.last : [];
//
//     // Health Insurance
//       case 'insuranceName':
//         return insuranceName.isNotEmpty ? insuranceName.last : '';
//       case 'insurancePolicyNumber':
//         return insurancePolicyNumber.isNotEmpty ? insurancePolicyNumber.last : '';
//
//     // 1st Emergency Contact
//       case 'firstContactFirstName':
//         return firstContactFirstName.isNotEmpty ? firstContactFirstName.last : '';
//       case 'firstContactLastName':
//         return firstContactLastName.isNotEmpty ? firstContactLastName.last : '';
//       case 'firstContactRelationship':
//         return firstContactRelationship.isNotEmpty ? firstContactRelationship.last : '';
//       case 'firstContactEmail':
//         return firstContactEmail.isNotEmpty ? firstContactEmail.last : '';
//       case 'firstContactPhone':
//         return firstContactPhone.isNotEmpty ? firstContactPhone.last : '';
//       case 'firstContactLanguage':
//         return firstContactLanguage.isNotEmpty ? firstContactLanguage.last : '';
//       case 'firstContactCountry':
//         return firstContactCountry.isNotEmpty ? firstContactCountry.last : '';
//       case 'firstContactProvince':
//         return firstContactProvince.isNotEmpty ? firstContactProvince.last : '';
//       case 'firstContactCity':
//         return firstContactCity.isNotEmpty ? firstContactCity.last : '';
//       case 'firstContactStreet':
//         return firstContactStreet.isNotEmpty ? firstContactStreet.last : '';
//
//     // 2nd Emergency Contact
//       case 'secondContactFirstName':
//         return secondContactFirstName.isNotEmpty ? secondContactFirstName.last : '';
//       case 'secondContactLastName':
//         return secondContactLastName.isNotEmpty ? secondContactLastName.last : '';
//       case 'secondContactRelationship':
//         return secondContactRelationship.isNotEmpty ? secondContactRelationship.last : '';
//       case 'secondContactEmail':
//         return secondContactEmail.isNotEmpty ? secondContactEmail.last : '';
//       case 'secondContactPhone':
//         return secondContactPhone.isNotEmpty ? secondContactPhone.last : '';
//       case 'secondContactLanguage':
//         return secondContactLanguage.isNotEmpty ? secondContactLanguage.last : '';
//       case 'secondContactCountry':
//         return secondContactCountry.isNotEmpty ? secondContactCountry.last : '';
//       case 'secondContactProvince':
//         return secondContactProvince.isNotEmpty ? secondContactProvince.last : '';
//       case 'secondContactCity':
//         return secondContactCity.isNotEmpty ? secondContactCity.last : '';
//       case 'secondContactStreet':
//         return secondContactStreet.isNotEmpty ? secondContactStreet.last : '';
//
//     // Account Information
//       case 'password':
//         return password ?? '';
//       case 'defaultPassword':
//         return defaultPassword ?? '';
//       case 'passwordExpirationTime':
//         return passwordExpirationTime ?? '';
//       case 'passwordExpirationUnit':
//         return passwordExpirationUnit ?? '';
//       case 'firstLogin':
//         return firstLogin ?? '';
//       case 'lastLogin':
//         return lastLogin ?? '';
//       case 'deactivationDate':
//         return deactivationDate ?? '';
//       case 'activationDate':
//         return activationDate ?? '';
//
//     // Timestamps
//       case 'timestamps':
//         return timestamps.isNotEmpty ? timestamps.last : 0;
//
//       default:
//         return null;
//     }
//   }
// }

/// Convert NewEmployeeModelHistory to NewEmployeeModel
/// This takes the history arrays and converts them to the model format with timestamps




