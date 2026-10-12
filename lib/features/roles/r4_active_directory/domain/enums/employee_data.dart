/// Module: roles / r4_active_directory / domain / enums
///
/// ********************** FILE INFO ********************///
/// FILE NAME: employee_data.dart
/// Purpose: contains all data items needed about employee in the active_directory file.
/// Author: Mohamed Elrashidy
/// created at: 15/12/2024

import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

enum EmployeeDataItems {
  id,
  firstName,
  middleName,
  lastName,
  firstNameArabic,
  middleNameArabic,
  lastNameArabic,
  email,
  mobileCountryCode,
  mobileNumber,
  homeCountryCode,
  homeNumber,
  officeCountryCode,
  officeNumber,
  extension,
  gender,
  country,
  province,
  city,
  postalCode,
  street,
  language,
  departmentId,
  departmentEnglishName,
  departmentArabicName,
  supervisorEmail,
  role,
  englishTitle,
  arabicTitle,
  workLocation,
  none;

  // Get localized name based on language
  String getLocalizedName(String languageCode) {
    final translations = {
      'en': _getEnglishName(),
      'ar': _getArabicName(),
    };
    return translations[languageCode] ?? _getEnglishName();
  }

  /// The field's **English** header name.
  ///
  /// Was `getLocalizedName(Get.locale?.languageCode ?? 'en')`. Two problems:
  /// GetX is banned, and every live call site compares this against the header
  /// row of an uploaded CSV — a file whose headers are always English. Under an
  /// Arabic locale this returned Arabic, so `data[0].contains(item.name)` never
  /// matched and header validation rejected every file. Display code that wants
  /// the translated label should call [getLocalizedName] with an explicit
  /// language code read from `Localizations.localeOf(context)`.
  String get name => _getEnglishName();

  // English names
  String _getEnglishName() {
    switch (this) {
      case EmployeeDataItems.id:
        return 'Employee ID';
      case EmployeeDataItems.firstName:
        return 'First Name';
      case EmployeeDataItems.middleName:
        return 'Middle Name';
      case EmployeeDataItems.lastName:
        return 'Last Name';
      case EmployeeDataItems.firstNameArabic:
        return 'First Name Arabic';
      case EmployeeDataItems.middleNameArabic:
        return 'Middle Name Arabic';
      case EmployeeDataItems.lastNameArabic:
        return 'Last Name Arabic';
      case EmployeeDataItems.email:
        return 'Email';
      case EmployeeDataItems.mobileCountryCode:
        return 'Country Code';
      case EmployeeDataItems.mobileNumber:
        return 'Mobile Phone';
      case EmployeeDataItems.homeCountryCode:
        return 'Country Code';
      case EmployeeDataItems.homeNumber:
        return 'Home Number';
      case EmployeeDataItems.officeCountryCode:
        return 'Country Code';
      case EmployeeDataItems.officeNumber:
        return 'Office Number';
      case EmployeeDataItems.extension:
        return 'Extension';
      case EmployeeDataItems.gender:
        return 'Gender';
      case EmployeeDataItems.country:
        return 'Country';
      case EmployeeDataItems.province:
        return 'Province';
      case EmployeeDataItems.city:
        return 'City';
      case EmployeeDataItems.postalCode:
        return 'Postal Code';
      case EmployeeDataItems.street:
        return 'Street';
      case EmployeeDataItems.language:
        return 'Language';
      case EmployeeDataItems.departmentId:
        return 'Department ID';
      case EmployeeDataItems.departmentEnglishName:
        return 'Department Name';
      case EmployeeDataItems.departmentArabicName:
        return 'Department Arabic';
      case EmployeeDataItems.supervisorEmail:
        return 'Supervisor';
      case EmployeeDataItems.role:
        return 'Role';
      case EmployeeDataItems.englishTitle:
        return 'Title';
      case EmployeeDataItems.arabicTitle:
        return 'Title In Arabic';
      case EmployeeDataItems.workLocation:
        return 'Work Location';
      case EmployeeDataItems.none:
        return '';
    }
  }

  // Arabic names
  String _getArabicName() {
    switch (this) {
      case EmployeeDataItems.id:
        return 'رقم الموظف';
      case EmployeeDataItems.firstName:
        return 'الاسم الأول';
      case EmployeeDataItems.middleName:
        return 'الاسم الأوسط';
      case EmployeeDataItems.lastName:
        return 'اسم العائلة';
      case EmployeeDataItems.firstNameArabic:
        return 'الاسم الأول بالعربية';
      case EmployeeDataItems.middleNameArabic:
        return 'الاسم الأوسط بالعربية';
      case EmployeeDataItems.lastNameArabic:
        return 'اسم العائلة بالعربية';
      case EmployeeDataItems.email:
        return 'البريد الإلكتروني';
      case EmployeeDataItems.mobileCountryCode:
        return 'رمز الدولة';
      case EmployeeDataItems.mobileNumber:
        return 'رقم الجوال';
      case EmployeeDataItems.homeCountryCode:
        return 'رمز الدولة';
      case EmployeeDataItems.homeNumber:
        return 'رقم المنزل';
      case EmployeeDataItems.officeCountryCode:
        return 'رمز الدولة';
      case EmployeeDataItems.officeNumber:
        return 'رقم المكتب';
      case EmployeeDataItems.extension:
        return 'التحويلة';
      case EmployeeDataItems.gender:
        return 'الجنس';
      case EmployeeDataItems.country:
        return 'الدولة';
      case EmployeeDataItems.province:
        return 'المحافظة';
      case EmployeeDataItems.city:
        return 'المدينة';
      case EmployeeDataItems.postalCode:
        return 'الرمز البريدي';
      case EmployeeDataItems.street:
        return 'الشارع';
      case EmployeeDataItems.language:
        return 'اللغة';
      case EmployeeDataItems.departmentId:
        return 'رقم القسم';
      case EmployeeDataItems.departmentEnglishName:
        return 'اسم القسم';
      case EmployeeDataItems.departmentArabicName:
        return 'اسم القسم بالعربية';
      case EmployeeDataItems.supervisorEmail:
        return 'المشرف';
      case EmployeeDataItems.role:
        return 'الدور الوظيفي';
      case EmployeeDataItems.englishTitle:
        return 'المسمى الوظيفي';
      case EmployeeDataItems.arabicTitle:
        return 'المسمى الوظيفي بالعربية';
      case EmployeeDataItems.workLocation:
        return 'موقع العمل';
      case EmployeeDataItems.none:
        return '';
    }
  }

  String? Function(dynamic value) get validate {
    switch (this) {
      case EmployeeDataItems.id:
        return (value) {
          return Validator.id(value, S.current.invalidEmployeeID);
        };
      case EmployeeDataItems.firstName:
        return (value) {
          return Validator.firstNameEnglish(
            value,
          );
        };
      case EmployeeDataItems.middleName:
        return (value) {
          return Validator.middleNameEnglish(
            value,
          );
        };
      case EmployeeDataItems.lastName:
        return (value) {
          return Validator.lastNameEnglish(value);
        };
      case EmployeeDataItems.firstNameArabic:
        return (value) {
          return Validator.firstNameArabic(value);
        };
      case EmployeeDataItems.middleNameArabic:
        return (value) {
          return Validator.middleNameArabic(value);
        };
      case EmployeeDataItems.lastNameArabic:
        return (value) {
          return Validator.lastNameArabic(value);
        };
      case EmployeeDataItems.email:
        return (value) {
          return Validator.email(value);
        };
      case EmployeeDataItems.mobileCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeDataItems.mobileNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeDataItems.homeCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeDataItems.homeNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeDataItems.officeCountryCode:
        return (value) {
          return Validator.countryCodeValidate(value);
        };
      case EmployeeDataItems.officeNumber:
        return (phone) {
          return Validator.formatPhoneNumber(phone);
        };
      case EmployeeDataItems.extension:
        return (value) {
          return Validator.extension(value);
        };
      case EmployeeDataItems.gender:
        return (value) {
          return Validator.gender(value);
        };
      case EmployeeDataItems.country:
        return (value) {
          return Validator.text(value, S.current.invalidCountryName);
        };
      case EmployeeDataItems.province:
        return (value) {
          return Validator.text(value, S.current.invalidProvince);
        };
      case EmployeeDataItems.city:
        return (value) {
          return Validator.text(value, S.current.invalidCity);
        };
      case EmployeeDataItems.postalCode:
        return (value) {
          return Validator.postalCode(value);
        };
      case EmployeeDataItems.street:
        return (value) {
          return Validator.location(value, S.current.invalidStreet);
        };
      case EmployeeDataItems.language:
        return (value) {
          return Validator.text(value, S.current.invalidLanguage);
        };
      case EmployeeDataItems.departmentId:
        return (value) {
          return Validator.departmentId(value);
        };
      case EmployeeDataItems.departmentEnglishName:
        return (value) {
          return Validator.text(
              value,
              S.current.kindlyEnterTheNameOfTheDepartmentToCompleteTheAssignmen);
        };
      case EmployeeDataItems.departmentArabicName:
        return (value) {
          return Validator.isArabic(
              value,
              S.current.pleaseProvideTheDepartmentNameInArabicForBilingualConsi,
              S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2);
        };
      case EmployeeDataItems.supervisorEmail:
        return (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          return Validator.email(value);
        };
      case EmployeeDataItems.role:
        return (value) {
          return Validator.text(
              value,
              S.current.kindlyAssignARoleToTheEmployeeThisIsARequiredFieldForAc);
        };
      case EmployeeDataItems.englishTitle:
        return (value) {
          return Validator.text(
              value,
              S.current.pleaseEnterTheEmployeeSJobTitleItIsEssentialForInternal);
        };
      case EmployeeDataItems.arabicTitle:
        return (value) {
          return Validator.isArabic(
              value,
              S.current.kindlyProvideTheArabicTranslationOfTheJobTitleForBiling,
              S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi2);
        };
      case EmployeeDataItems.workLocation:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      case EmployeeDataItems.none:
        return (value) {
          return null;
        };
    }
  }

  String? Function(dynamic value)? get validateTitle {
    switch (this) {
      case EmployeeDataItems.firstName:
        return (value) {
          return Validator.firstNameEnglishTtitle(value);
        };
      case EmployeeDataItems.middleName:
        return (value) {
          return Validator.middleNameEnglishTitle(
            value,
          );
        };
      case EmployeeDataItems.lastName:
        return (value) {
          return Validator.lastNameEnglishTitle(value);
        };
      case EmployeeDataItems.firstNameArabic:
        return (value) {
          return Validator.firstNameEnglishTtitle(value);
        };
      case EmployeeDataItems.middleNameArabic:
        return (value) {
          return Validator.middleNameArabicTitle(value);
        };
      case EmployeeDataItems.lastNameArabic:
        return (value) {
          return Validator.lastNameArabicTitle(value);
        };
      case EmployeeDataItems.email:
        return (value) {
          return Validator.emailTitle(value);
        };
      case EmployeeDataItems.mobileNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeDataItems.homeNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeDataItems.officeNumber:
        return (phone) {
          return Validator.formatPhoneNumberTitle(phone);
        };
      case EmployeeDataItems.extension:
        return (value) {
          return Validator.extensionTitle(value);
        };
      case EmployeeDataItems.gender:
        return (value) {
          return Validator.genderTitle(value);
        };
      case EmployeeDataItems.country:
        return (value) {
          return Validator.text(value, S.current.invalidCountryName);
        };
      case EmployeeDataItems.province:
        return (value) {
          return Validator.text(value, S.current.invalidProvince);
        };
      case EmployeeDataItems.city:
        return (value) {
          return Validator.text(value, S.current.invalidCity);
        };
      case EmployeeDataItems.postalCode:
        return (value) {
          return Validator.postalCodeTitle(value);
        };
      case EmployeeDataItems.street:
        return (value) {
          return Validator.location(value, S.current.invalidStreet);
        };
      case EmployeeDataItems.language:
        return (value) {
          return Validator.text(value, S.current.invalidLanguage);
        };
      case EmployeeDataItems.departmentId:
        return (value) {
          return Validator.departmentIdTitle(value);
        };
      case EmployeeDataItems.departmentEnglishName:
        return (value) {
          return Validator.text(value, S.current.departmentNameRequired);
        };
      case EmployeeDataItems.departmentArabicName:
        return (value) {
          return Validator.isArabic(value, S.current.arabicDepartmentNameMissing,
              S.current.arabicLanguageMandatory);
        };
      case EmployeeDataItems.supervisorEmail:
        return (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          return Validator.emailTitle(value);
        };
      case EmployeeDataItems.role:
        return (value) {
          return Validator.text(value, S.current.roleNotAssigned);
        };
      case EmployeeDataItems.englishTitle:
        return (value) {
          return Validator.text(value, S.current.jobTitleMissing);
        };
      case EmployeeDataItems.arabicTitle:
        return (value) {
          return Validator.isArabic(
            value,
            S.current.arabicJobTitleRequired,
            S.current.arabicLanguageMandatory,
          );
        };
      case EmployeeDataItems.workLocation:
        return (value) {
          return Validator.location(value, S.current.invalidWorkLocation);
        };
      default:
        return null;
    }
  }
}