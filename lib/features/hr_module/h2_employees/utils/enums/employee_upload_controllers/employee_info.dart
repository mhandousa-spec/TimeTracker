// ***************************** FILE INFO ***************************** //
// File Name: employee_info.dart
// Purpose: Defines employee fields, labels, and validation rules.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:get/get.dart';

import '../../../../../../core/helper/role/validator.dart';
import '../../../../../../generated/l10n.dart';

enum EmployeeInfo {
  id,
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
  email,
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
  language,
  departmentId,
  departmentEnglishName,
  departmentArabicName,
  supervisorEmail,
  role,
  englishTitle,
  arabicTitle,
  workLocation,
  drivingLicenseId,
  carPlates,
  none;

  // Get localized name based on language
  String getLocalizedName(String languageCode) {
    final translations = {
      'en': _getEnglishName(),
      'ar': _getArabicName(),
    };
    return translations[languageCode] ?? _getEnglishName();
  }

  // Quick access to localized name using current locale
  String get name {
    String currentLang = Get.locale?.languageCode ?? 'en';
    return getLocalizedName(currentLang);
  }

  // English names
  String _getEnglishName() {
    switch (this) {
      case EmployeeInfo.id:
        return 'Employee ID';
      case EmployeeInfo.firstName:
        return 'First Name';
      case EmployeeInfo.middleName:
        return 'Middle Name';
      case EmployeeInfo.lastName:
        return 'Last Name';
      case EmployeeInfo.firstNameArabic:
        return 'First Name Arabic';
      case EmployeeInfo.middleNameArabic:
        return 'Middle Name Arabic';
      case EmployeeInfo.lastNameArabic:
        return 'Last Name Arabic';
      case EmployeeInfo.nationalId:
        return 'National ID';
      case EmployeeInfo.nationalIdExpirationDate:
        return 'National ID Expiration';
      case EmployeeInfo.nationality:
        return 'Nationality';
      case EmployeeInfo.passport:
        return 'Passport';
      case EmployeeInfo.passportExpirationDate:
        return 'Passport Expiration';
      case EmployeeInfo.email:
        return 'Email';
      case EmployeeInfo.mobileCountryCode:
        return 'Country Code';
      case EmployeeInfo.mobileNumber:
        return 'Mobile Phone';
      case EmployeeInfo.homeCountryCode:
        return 'Country Code';
      case EmployeeInfo.homeNumber:
        return 'Home Number';
      case EmployeeInfo.officeCountryCode:
        return 'Country Code';
      case EmployeeInfo.officeNumber:
        return 'Office Number';
      case EmployeeInfo.extension:
        return 'Extension';
      case EmployeeInfo.birthDay:
        return 'Birth Date';
      case EmployeeInfo.gender:
        return 'Gender';
      case EmployeeInfo.country:
        return 'Country';
      case EmployeeInfo.province:
        return 'Province';
      case EmployeeInfo.city:
        return 'City';
      case EmployeeInfo.postalCode:
        return 'Postal Code';
      case EmployeeInfo.street:
        return 'Street';
      case EmployeeInfo.maritalStatus:
        return 'Marital Status';
      case EmployeeInfo.language:
        return 'Language';
      case EmployeeInfo.departmentId:
        return 'Department ID';
      case EmployeeInfo.departmentEnglishName:
        return 'Department Name';
      case EmployeeInfo.departmentArabicName:
        return 'Department Arabic';
      case EmployeeInfo.supervisorEmail:
        return 'Supervisor';
      case EmployeeInfo.role:
        return 'Role';
      case EmployeeInfo.englishTitle:
        return 'Title';
      case EmployeeInfo.arabicTitle:
        return 'Title In Arabic';
      case EmployeeInfo.workLocation:
        return 'Work Location';
      case EmployeeInfo.drivingLicenseId:
        return 'Driving License ID';
      case EmployeeInfo.carPlates:
        return 'Car Plates';
      case EmployeeInfo.none:
        return '';
    }
  }

  // Arabic names
  String _getArabicName() {
    switch (this) {
      case EmployeeInfo.id:
        return 'رقم الموظف';
      case EmployeeInfo.firstName:
        return 'الاسم الأول';
      case EmployeeInfo.middleName:
        return 'الاسم الأوسط';
      case EmployeeInfo.lastName:
        return 'اسم العائلة';
      case EmployeeInfo.firstNameArabic:
        return 'الاسم الأول بالعربية';
      case EmployeeInfo.middleNameArabic:
        return 'الاسم الأوسط بالعربية';
      case EmployeeInfo.lastNameArabic:
        return 'اسم العائلة بالعربية';
      case EmployeeInfo.nationalId:
        return 'الرقم القومي';
      case EmployeeInfo.nationalIdExpirationDate:
        return 'تاريخ انتهاء الرقم القومي';
      case EmployeeInfo.nationality:
        return 'الجنسية';
      case EmployeeInfo.passport:
        return 'جواز السفر';
      case EmployeeInfo.passportExpirationDate:
        return 'تاريخ انتهاء جواز السفر';
      case EmployeeInfo.email:
        return 'البريد الإلكتروني';
      case EmployeeInfo.mobileCountryCode:
        return 'رمز الدولة';
      case EmployeeInfo.mobileNumber:
        return 'رقم الجوال';
      case EmployeeInfo.homeCountryCode:
        return 'رمز الدولة';
      case EmployeeInfo.homeNumber:
        return 'رقم المنزل';
      case EmployeeInfo.officeCountryCode:
        return 'رمز الدولة';
      case EmployeeInfo.officeNumber:
        return 'رقم المكتب';
      case EmployeeInfo.extension:
        return 'التحويلة';
      case EmployeeInfo.birthDay:
        return 'تاريخ الميلاد';
      case EmployeeInfo.gender:
        return 'الجنس';
      case EmployeeInfo.country:
        return 'الدولة';
      case EmployeeInfo.province:
        return 'المحافظة';
      case EmployeeInfo.city:
        return 'المدينة';
      case EmployeeInfo.postalCode:
        return 'الرمز البريدي';
      case EmployeeInfo.street:
        return 'الشارع';
      case EmployeeInfo.maritalStatus:
        return 'الحالة الاجتماعية';
      case EmployeeInfo.language:
        return 'اللغة';
      case EmployeeInfo.departmentId:
        return 'رقم القسم';
      case EmployeeInfo.departmentEnglishName:
        return 'اسم القسم';
      case EmployeeInfo.departmentArabicName:
        return 'اسم القسم بالعربية';
      case EmployeeInfo.supervisorEmail:
        return 'المشرف';
      case EmployeeInfo.role:
        return 'الدور الوظيفي';
      case EmployeeInfo.englishTitle:
        return 'المسمى الوظيفي';
      case EmployeeInfo.arabicTitle:
        return 'المسمى الوظيفي بالعربية';
      case EmployeeInfo.workLocation:
        return 'موقع العمل';
      case EmployeeInfo.drivingLicenseId:
        return 'رقم رخصة القيادة';
      case EmployeeInfo.carPlates:
        return 'لوحات السيارات';
      case EmployeeInfo.none:
        return '';
    }
  }

  String? Function(dynamic value) get validate {
    switch (this) {
      case EmployeeInfo.id:
        return (value) {
          return Validator.id(value, S.current.invalidEmployeeId);
        };
      case EmployeeInfo.firstName:
        return (value) {
          return Validator.firstNameEnglish(
            value,
          );
        };
      case EmployeeInfo.middleName:
        return (value) {
          return Validator.middleNameEnglish(
            value,
          );
        };
      case EmployeeInfo.lastName:
        return (value) {
          return Validator.lastNameEnglish(value);
        };
      case EmployeeInfo.firstNameArabic:
        return (value) {
          return Validator.firstNameArabic(value);
        };
      case EmployeeInfo.middleNameArabic:
        return (value) {
          return Validator.middleNameArabic(value);
        };
      case EmployeeInfo.lastNameArabic:
        return (value) {
          return Validator.lastNameArabic(value);
        };
      case EmployeeInfo.nationalId:
        return (value) {
          return Validator.nationalId(value);
        };
      case EmployeeInfo.nationalIdExpirationDate:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.nationality:
        return (value) {
          return Validator.location(value, S.current.invalidCountryName);
        };
      case EmployeeInfo.passport:
        return (value) {
          return Validator.passportNumber(value);
        };
      case EmployeeInfo.passportExpirationDate:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.email:
        return (value) {
          return Validator.email(value);
        };
      case EmployeeInfo.mobileCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeInfo.mobileNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeInfo.homeCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeInfo.homeNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeInfo.officeCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeInfo.officeNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeInfo.extension:
        return (value) {
          return Validator.extension(value);
        };
      case EmployeeInfo.birthDay:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.gender:
        return (value) {
          return Validator.gender(value);
        };
      case EmployeeInfo.country:
        return (value) {
          return Validator.text(value, S.current.invalidCountryName);
        };
      case EmployeeInfo.province:
        return (value) {
          return Validator.text(value, S.current.invalidProvince);
        };
      case EmployeeInfo.city:
        return (value) {
          return Validator.text(value, S.current.invalidCity);
        };
      case EmployeeInfo.postalCode:
        return (value) {
          return Validator.postalCode(value);
        };
      case EmployeeInfo.street:
        return (value) {
          return Validator.location(value, S.current.invalidStreet);
        };
      case EmployeeInfo.maritalStatus:
        return (value) {
          return Validator.maritalStatus(value);
        };
      case EmployeeInfo.language:
        return (value) {
          return Validator.text(value, S.current.invalidLanguage);
        };
      case EmployeeInfo.departmentId:
        return (value) {
          return Validator.departmentId(value);
        };
      case EmployeeInfo.departmentEnglishName:
        return (value) {
          return Validator.text(
              value, S.current.departmentNameAssignmentRequired);
        };
      case EmployeeInfo.departmentArabicName:
        return (value) {
          return Validator.isArabic(
              value,
              S.current.departmentArabicNameBilingualRequired,
              S.current.arabicTextOnlyError);
        };
      case EmployeeInfo.supervisorEmail:
        return (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          return Validator.email(value);
        };
      case EmployeeInfo.role:
        return (value) {
          return Validator.text(value, S.current.employeeRoleRequired);
        };
      case EmployeeInfo.englishTitle:
        return (value) {
          return Validator.text(value, S.current.employeeJobTitleRequired);
        };
      case EmployeeInfo.arabicTitle:
        return (value) {
          return Validator.isArabic(
              value,
              S.current.arabicJobTitleTranslationRequired,
              S.current.arabicTextOnlyError);
        };
      case EmployeeInfo.workLocation:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      case EmployeeInfo.drivingLicenseId:
        return (value) {
          return Validator.id(value, S.current.invalidEmployeeId);
        };
      case EmployeeInfo.carPlates:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      case EmployeeInfo.none:
        return (value) {
          return null;
        };
    }
  }

  String? Function(dynamic value)? get validateTitle {
    switch (this) {
      case EmployeeInfo.firstName:
        return (value) {
          return Validator.firstNameEnglishTtitle(value);
        };
      case EmployeeInfo.middleName:
        return (value) {
          return Validator.middleNameEnglishTitle(
            value,
          );
        };
      case EmployeeInfo.lastName:
        return (value) {
          return Validator.lastNameEnglishTitle(value);
        };
      case EmployeeInfo.firstNameArabic:
        return (value) {
          return Validator.firstNameEnglishTtitle(value);
        };
      case EmployeeInfo.middleNameArabic:
        return (value) {
          return Validator.middleNameArabicTitle(value);
        };
      case EmployeeInfo.lastNameArabic:
        return (value) {
          return Validator.lastNameArabicTitle(value);
        };
      case EmployeeInfo.nationalId:
        return (value) {
          return Validator.nationalIdTitle(value);
        };
      case EmployeeInfo.nationalIdExpirationDate:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.nationality:
        return (value) {
          return Validator.location(value, S.current.invalidCountryName);
        };
      case EmployeeInfo.passport:
        return (value) {
          return Validator.passportNumberTitle(value);
        };
      case EmployeeInfo.passportExpirationDate:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.email:
        return (value) {
          return Validator.emailTitle(value);
        };
      case EmployeeInfo.mobileNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeInfo.homeNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeInfo.officeNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeInfo.extension:
        return (value) {
          return Validator.extensionTitle(value);
        };
      case EmployeeInfo.birthDay:
        return (value) {
          return Validator.date(value);
        };
      case EmployeeInfo.gender:
        return (value) {
          return Validator.genderTitle(value);
        };
      case EmployeeInfo.country:
        return (value) {
          return Validator.text(value, S.current.invalidCountryName);
        };
      case EmployeeInfo.province:
        return (value) {
          return Validator.text(value, S.current.invalidProvince);
        };
      case EmployeeInfo.city:
        return (value) {
          return Validator.text(value, S.current.invalidCity);
        };
      case EmployeeInfo.postalCode:
        return (value) {
          return Validator.postalCodeTitle(value);
        };
      case EmployeeInfo.street:
        return (value) {
          return Validator.location(value, S.current.invalidStreet);
        };
      case EmployeeInfo.maritalStatus:
        return (value) {
          return Validator.maritalStatus(value);
        };
      case EmployeeInfo.language:
        return (value) {
          return Validator.text(value, S.current.invalidLanguage);
        };
      case EmployeeInfo.departmentId:
        return (value) {
          return Validator.departmentIdTitle(value);
        };
      case EmployeeInfo.departmentEnglishName:
        return (value) {
          return Validator.text(value, S.current.departmentNameRequired);
        };
      case EmployeeInfo.departmentArabicName:
        return (value) {
          return Validator.isArabic(
              value,
              S.current.arabicDepartmentNameMissing,
              S.current.arabicLanguageMandatory);
        };
      case EmployeeInfo.supervisorEmail:
        return (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          return Validator.emailTitle(value);
        };
      case EmployeeInfo.role:
        return (value) {
          return Validator.text(value, S.current.roleNotAssigned);
        };
      case EmployeeInfo.englishTitle:
        return (value) {
          return Validator.text(value, S.current.jobTitleMissing);
        };
      case EmployeeInfo.arabicTitle:
        return (value) {
          return Validator.isArabic(
            value,
            S.current.arabicJobTitleRequired,
            S.current.arabicLanguageMandatory,
          );
        };
      case EmployeeInfo.workLocation:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      case EmployeeInfo.drivingLicenseId:
        return (value) {
          return Validator.id(value, S.current.invalidEmployeeId);
        };
      case EmployeeInfo.carPlates:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      default:
        return null;
    }
  }
}
