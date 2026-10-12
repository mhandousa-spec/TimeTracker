/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: validator.dart
/// Purpose: Declares `Validator`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/// **************************** FILE INFO **************************** ///
/// Purpose: Single app-wide Validator.
/// Merged from:
///   - features/roles/r4_active_directory/core/helpers/validator.dart (CSV/employee
///     import validators — the superset, null-safe, long guidance messages)
///   - core/helper/main_helper/validator.dart (legacy validators used by the
///     sign-in / settings screens)
///   - core/helper/form_builder/validation_helper.dart (the former
///     ValidationHelper — form-builder field validators; see the section at the
///     bottom of this class)
/// Where the two versions of a method differed, the active_directory behaviour
/// is kept under the original name and the legacy behaviour is preserved under
/// an explicit alias, so no call site changed behaviour. See [emailLocalized].
import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';



class Validator {
  Validator();

  /// Returns "<label> required" when [value] is null or empty, else null.
  ///
  /// Ported from the messaging module's former ValidationHelper.isEmpty so
  /// generic "this field is required" checks have one home alongside the
  /// field-specific validators below.
  static String? isEmpty(String? value, String label) {
    if (value == null || value.isEmpty) {
      return '$label ${S.current.required}';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterAValidEmailAddressForCommunication;
    }

    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.theEmailMustFollowTheFormatUserDomainCom;
    } else {
      return null;
    }
  }

  static String? emailTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.emailRequired2;
    }

    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidEmailFormat;
    } else {
      return null;
    }
  }

// employee sheet
  static String? name(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z0-9-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.length <= 1) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? firstNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSFirstNameThisFieldIsMandatoryFor;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? firstNameEnglishTtitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.firstNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? middleNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSMiddleNameThisFieldIsMandatoryFo;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidMiddleName;
    } else {
      return null;
    }
  }

  static String? middleNameEnglishTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.middleNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidMiddleName;
    } else {
      return null;
    }
  }

  static String? lastNameEnglish(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.kindlyEnterTheEmployeeSLastNameThisFieldIsMandatoryForI;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsEnglishOnlyPleaseProvideYourEntryInEngl;
    } else if (value.length <= 1) {
      return S.current.invalidLastName;
    } else {
      return null;
    }
  }

  static String? lastNameEnglishTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.lastNameMissing;
    }
    String pattern = r'^(?=.*[a-zA-Z])[a-zA-Z-]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.englishLanguageMandatory;
    } else if (value.length <= 1) {
      return S.current.invalidFirstName;
    } else {
      return null;
    }
  }

  static String? firstNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheFirstNameInArabicThisIsARequiredFieldForL;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? firstNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicFirstNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static String? middleNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheMiddleNameInArabicThisIsARequiredFieldFor;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? middleNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicMiddleNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static String? lastNameArabic(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheLastNameInArabicThisIsARequiredFieldForLo;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.thisFieldAcceptsArabicOnlyPleaseProvideYourEntryInArabi;
    } else {
      return null;
    }
  }

  static String? lastNameArabicTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.arabicLastNameMissing;
    }
    RegExp regex = RegExp(r'^[\u0621-\u064A]+');
    if (!regex.hasMatch(value)) {
      return S.current.arabicLanguageMandatory;
    } else {
      return null;
    }
  }

  static dynamic isEnglish(String? value) {
    final RegExp english = RegExp(r'^[a-zA-Z]+');
    if (value != null && !english.hasMatch(value)) {
      return S.current.pleaseEnterTheTextInEnglishLanguage;
    } else {
      return null;
    }
  }

  static String? isArabic(String? value, String empty, String invalid) {
    if (value == null || value.isEmpty) {
      return empty;
    }
    final RegExp arabic = RegExp(r'^[\u0621-\u064A]+');
    if (!arabic.hasMatch(value)) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? isValidnumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invalid Data Type';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Invalid Data Type';
    }
    return null; // Input is a valid number
  }

  static String? work(String? value, String invalid) {
    String pattern =
        r"^(?:[a-zA-Z\u0600-\u06FF]+(([',.-][a-zA-Z\u0600-\u06FF])?[a-zA-Z\u0600-\u06FF]*)*)|(?:[\p{L}\s'-]+)$";
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value!) || value.length <= 1) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? date(String? value) {
    String pattern = r"(\d{4}-?\d\d-?\d\d)";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidDate;
    } else {
      return null;
    }
  }

  static String? id(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.length == 0) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? departmentId(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseProvideAValidDepartmentIDThisFieldIsMandatoryForO;
    }
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.theDepartmentIDMustBeNumericAndContainNoLetters;
    } else {
      return null;
    }
  }

  static String? departmentIdTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.missingDepartmentID;
    }
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value)) {
      return S.current.invalidDepartmentIDFormat;
    } else {
      return null;
    }
  }

  static String? location(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(?!\s*\d+\s*$)[a-zA-Z0-9\s,]*$';
    RegExp regex = RegExp(pattern, unicode: true);
    if (!regex.hasMatch(value) || value.length == 0) {
      return invalid;
    } else {
      return null;
    }
  }

  static String? isNationalIdDateValid(String dateString) {
    String invalidFormatMessage =
        S.current.pleaseEnterAValidDateInDDMMYYYYFormat;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now))
        return S.current.pleaseSelectADateLaterThanTodayForTheNationalIDExpirati;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isNationalIdDateValidTitle(String dateString) {
    String invalidFormatMessage = S.current.invalidExpiryDate;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) return S.current.expiryDateMustBeInTheFuture;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isPassportDateValid(String dateString) {
    String invalidFormatMessage =
        S.current.pleaseEnterAValidDateInDDMMYYYYFormat;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now))
        return S.current.pleaseSelectADateLaterThanTodayForTheNationalIDExpirati;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isPassportDateValidTitle(String dateString) {
    String invalidFormatMessage = S.current.invalidExpiryDate;

    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return invalidFormatMessage; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return invalidFormatMessage;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return invalidFormatMessage;
        } else {
          if (day > 28) return invalidFormatMessage;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return invalidFormatMessage;
      }

      // check if date is expired
      DateTime idDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (idDate.isBefore(now)) return S.current.expiryDateMustBeInTheFuture;
      return null;
    } catch (e) {
      return invalidFormatMessage;
    }
  }

  static String? isDateValid(String dateString) {
    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return S.current.pleaseEnterAValidDateInDDMMYYYYFormat; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29)
            return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
        } else {
          if (day > 28)
            return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30)
          return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
      }

      // check if date is in the future
      DateTime inputDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (inputDate.isAfter(now)) {
        return S.current.pleaseEnterAValidDateOfBirthFutureDatesAreNotAllowed;
      }

      return null;
    } catch (e) {
      return S.current.pleaseEnterAValidDateInDDMMYYYYFormat;
    }
  }

  static String? isDateValidTitle(String dateString) {
    try {
      // Split the dateString by '/'
      List<String> parts = dateString.split('/');
      if (parts.length != 3) {
        return S.current.invalidBirthDate; // Date format should be "dd/MM/yyyy"
      }

      // Parse parts into integers
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      // Check if the parsed values represent a valid date
      if (day < 1 || day > 31 || month < 1 || month > 12) {
        return S.current.invalidBirthDate;
      }
      // Handle leap years
      bool isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      if (month == 2) {
        if (isLeapYear) {
          if (day > 29) return S.current.invalidBirthDate;
        } else {
          if (day > 28) return S.current.invalidBirthDate;
        }
      }

      // Check for months with 30 days
      if ([4, 6, 9, 11].contains(month)) {
        if (day > 30) return S.current.invalidBirthDate;
      }

      // check if date is in the future
      DateTime inputDate = DateFormat('dd/MM/yyyy').parse(dateString);
      DateTime now = DateTime.now();
      if (inputDate.isAfter(now)) {
        return S.current.invalidBirthDate;
      }

      return null;
    } catch (e) {
      return S.current.invalidBirthDate;
    }
  }

  static String? extension(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.pleaseEnterTheOfficeExtensionNumber;
    }
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.onlyDigitsArePermittedInTheExtensionField;
    } else {
      return null;
    }
  }

  static String? extensionTitle(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.extensionRequired;
    }
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.onlyDigitsArePermittedInTheExtensionField;
    } else {
      return null;
    }
  }

  static String? countryCodeValidate(String? value) {
    bool isValid = CountryUtils.getCountryByDialCode('+$value') != null;
    if (isValid) {
      return null;
    } else {
      return 'Invalid Country Code';
    }
  }

  /// Function Name: [formatPhoneNumber]
  ///
  /// Purpose: Validate a `dialCode-number` phone string.
  ///
  /// Re-enabled 11/8/2026: this method began with an unconditional
  /// `return null;`, making every statement below it unreachable — phone
  /// validation was silently disabled everywhere this validator is used.
  ///
  /// Returns: [String?] an error message, or `null` when the number is valid.
  static String? formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null) {
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    if (phoneNumber.split('-').length < 2) {
      //means 1 field is missing
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    String dialCode = phoneNumber.split('-')[0];
    phoneNumber = phoneNumber.split('-')[1].trim();
    phoneNumber = phoneNumber.replaceAll(' ', '');
    bool isValid = CountryUtils.validatePhoneNumber(phoneNumber, '+$dialCode');

    if (isValid) {
      return null;
    } else {
      return S.current.thePhoneNumberMustBeBetween8And15Digit;
    }
  }

  /// Function Name: [formatPhoneNumberTitle]
  ///
  /// Purpose: Same validation as [formatPhoneNumber] with title-specific
  ///          messages. Also had an unconditional `return null;` first line.
  ///
  /// Returns: [String?] an error message, or `null` when the number is valid.
  static String? formatPhoneNumberTitle(String? phoneNumber) {
    if (phoneNumber == null) {
      return S.current.phoneRequired;
    }
    if (phoneNumber.split('-').length < 2) {
      //means 1 field is missing
      return S.current.pleaseEnterAValidPhoneNumberInTheFormatCountryCodeNumbe;
    }
    String dialCode = phoneNumber.split('-')[0];
    phoneNumber = phoneNumber.split('-')[1].trim();
    phoneNumber = phoneNumber.replaceAll(' ', '');
    bool isValid = CountryUtils.validatePhoneNumber(phoneNumber, '+$dialCode');

    if (isValid) {
      return null;
    } else {
      return S.current.invalidPhoneFormat;
    }
  }

  static String? countryName(String? value) {
    String pattern = r'^[a-zA-Z\s]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Name'
          : "اسم غير صالح";
    } else {
      return null;
    }
  }

  static String? validateTaxNumber(String? value) {
    String pattern = r'^\d{9,14}$'; // Allowing numbers from 9 to 14 digits
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value!)) {
      return 'Invalid Tax Number';
    } else {
      return null;
    }
  }

  static String? zip(String? value) {
    String pattern = r'^\d{4,14}$'; // Allowing numbers from 9 to 14 digits
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(value!)) {
      return 'Invalid Zip Code';
    } else {
      return null;
    }
  }

  static String? http(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else {
      if (!Uri.parse(value).isAbsolute) {
        return 'Invalid URL';
      }
      return null;
    }
  }

  ///validator link
  static String? isCorrectWebsiteLink(String websiteName, String link) {
    if (link == "") {
      return null;
    }
    bool isLink = isValidLink(link.trim());
    if (!isLink) {
      return "Invalid URL";
    }
    //String modelLink="https://www.$websiteName.com";
    bool correctWebsiteLink = link.contains(websiteName);
    String returnedMessage = "This link is not ${websiteName.capitalize} link";
    if (!correctWebsiteLink) {
      return returnedMessage;
    }

    return null;
  }

  static bool isValidLink(String link) {
    bool isLink = true;
    final urlRegex = RegExp(
        r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$');
    isLink = urlRegex.hasMatch(link);
    return isLink;
  }

  static String? zipCode(String? value) {
    String pattern = r"^\d{5}$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidPostalCode;
    } else {
      return null;
    }
  }

  static String? text(String? value, String invalid) {
    if (value == null || value.isEmpty) {
      return invalid;
    }
    return null;
  }

  static String? insurancePolicyNumber(String? value, String invalidMessage) {
    String pattern = r"^[a-zA-Z0-9]+$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!) || value.length <= 1) {
      return invalidMessage;
    } else {
      return null;
    }
  }

  static String? gpa(String? value) {
    if (value == null || value.isEmpty) {
      return Get.locale.toString().contains('en')
          ? 'GPA Cannot Be Empty'
          : "لا يمكن أن يكون المعدل التراكمي فارغًا";
    }

    double gpaValue;
    try {
      gpaValue = double.parse(value);
    } catch (e) {
      return Get.locale.toString().contains('en')
          ? 'Invalid GPA Format'
          : "تنسيق المعدل التراكمي غير صالح";
    }

    if (gpaValue < 0.0 || gpaValue > 4.0) {
      return Get.locale.toString().contains('en')
          ? 'GPA Must Be Between 0.0 and 4.0'
          : "يجب أن يتراوح المعدل التراكمي بين 0.0 و4.0";
    }

    return null;
  }

  static String? nationalId(String? value) {
    // check if value is null or empty
    if (value == null || value.isEmpty) {
      return null;
    }
    // check if national Id contains only digits
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.onlyDigitsAreAllowedPleaseRemoveAnyLettersOrSymbols;
    }
    // check if national Id is 14 digits
    if (value.length < 9 || value.length > 14) {
      return S.current.nationalIDMustBeExactly14DigitsLong;
    }
    return null;
  }

  static String? nationalIdTitle(String? value) {
    // check if value is null or empty
    if (value == null || value.isEmpty) {
      return null;
    }
    // check if national Id contains only digits
    String pattern = r'^\d+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return S.current.nonNumericCharactersInNationalID;
    }
    // check if national Id is 14 digits
    if (value.length != 14) {
      return S.current.invalidNationalID;
    }
  }

  static String? passportNumber(String? value) {
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return "Only letters and numbers are allowed. Please remove any other symbols.";
    } else if (value.length < 8 || value.length > 11) {
      return "The passport number must consist of 9 alphanumeric characters.";
    } else {
      return null;
    }
  }

  static String? passportNumberTitle(String? value) {
    String pattern = r'^[a-zA-Z0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.unsupportedCharactersInPassportNumber;
    } else if (value.length < 9 || value.length > 9) {
      return S.current.invalidPassportNumber;
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(male|female|other)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return S.current.genderFieldMustBeEitherMaleFemaleOrOther;
    } else {
      return null;
    }
  }

  static String? genderTitle(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    String pattern = r'^(male|female|other)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidGender;
    }
  }

  static String? postalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String pattern = r'^\d{5}(?:[-\s]?\d{4})?$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.pleaseProvideAValidPostalCodeItMustMatchTheCityAndProvi;
    } else {
      return null;
    }
  }

  static String? postalCodeTitle(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    String pattern = r'^\d{5}(?:[-\s]?\d{4})?$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return S.current.invalidPostalCode;
    } else {
      return null;
    }
  }

  static String? maritalStatus(String? value) {
    String pattern = r'^(single|married|divorced|widowed)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Marital Status'
          : "حالة زواج غير صالحة";
    } else {
      return null;
    }
  }

  static String? relationship(String? value) {
    String pattern =
        r'^(brother|sister|father|mother|son|daughter|uncle|aunt|cousin|nephew|niece|grandfather|grandmother|grandson|granddaughter)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Relationship Name'
          : "اسم العلاقة غير صالح";
    } else {
      return null;
    }
  }

  static String? validateSalary(String? value) {
    String pattern = r'^[0-9]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Salary'
          : "الراتب غير صالح";
    } else {
      return null;
    }
  }

  static String? validateCurrencyCode(String? value) {
    String pattern = r'^[A-Z]{3}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Currency Code'
          : "رمز العملة غير صالح";
    } else {
      return null;
    }
  }

  static String? validateWorkDays(String? value) {
    String pattern =
        r'^(saturday|sunday|monday|tuesday|wednesday|thursday|friday|SAT|SUN|MON|TUE|WED|THU|FRI)(,\s*(saturday|sunday|monday|tuesday|wednesday|thursday|friday|SAT|SUN|MON|TUE|WED|THU|FRI))*$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Workdays'
          : "أيام العمل غير صالحة";
    } else {
      return null;
    }
  }

  static String? validateTime(String? value) {
    String pattern = r'^(1[012]|[1-9]):[0-5][0-9]\s(AM|PM)$';
    RegExp regex = RegExp(pattern, caseSensitive: false);
    if (!regex.hasMatch(value!)) {
      return Get.locale.toString().contains('en')
          ? 'Invalid Time'
          : "وقت غير صالح";
    } else {
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Merged in from the legacy core/helper/main_helper/validator.dart
  // ───────────────────────────────────────────────────────────────────────────

  /// Phone validator from the legacy validator (kept for the settings screens).
  static String? number(String? value) {
    if (value == null || value.isEmpty) {
      return S.current.invalidPhoneNumber;
    }
    String pattern0 = r'^\D?(\d{3})\D?\D?(\d{5})\D?(\d{4})$';
    String pattern1 = r'^\D?(\d{3})\D?\D?(\d{5})\D?(\d{3})$';
    RegExp regex0 = RegExp(pattern0);
    RegExp regex1 = RegExp(pattern1);
    if (!regex0.hasMatch(value) && !regex1.hasMatch(value)) {
      return S.current.invalidPhoneNumber;
    } else {
      return null;
    }
  }

  /// Email validator preserving the LEGACY message (`S.current.invalidEmail`),
  /// used by the sign-in screens. Same regex as [email]; only the returned
  /// message differs. [email] keeps the longer CSV-import guidance text.
  /// A null/empty guard was added — the legacy version threw on null.
  static String? emailLocalized(String? value) {
    if (value == null || value.isEmpty) {
      return Get.locale.toString().contains("en")
          ? S.current.invalidEmail
          : 'حساب غير صحيح';
    }
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return Get.locale.toString().contains("en")
          ? S.current.invalidEmail
          : 'حساب غير صحيح';
    } else {
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Merged in from the former core/helper/form_builder/validation_helper.dart
  // (class ValidationHelper). Bodies are unchanged so call sites keep their
  // exact messages. `isEnglish` / `isArabic` were NOT carried over — this class
  // already had equivalents and the ValidationHelper versions had no callers.
  // ───────────────────────────────────────────────────────────────────────────

  /// Email check returning [S.current.pleaseEnterTheValidEmail]. Kept distinct
  /// from [email] / [emailLocalized], which return different messages.
  static String? isEmailValid(String email) {
    var exp = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
    if (!exp) {
      return S.current.pleaseEnterTheValidEmail;
    }
    return null;
  }

  /// Required-field check that builds its own "<label> required" message.
  /// Differs from [text], which takes the whole message from the caller.
  static dynamic isEmptyy(String? value, String label, {bool? isArabic}) {
    if (value == null || value.trim().isEmpty) {
      return isArabic == null
          ? '$label ${'Required'}'
          : isArabic
              ? "$label ${'مطلوب'}"
              : "$label ${'required'}";
    } else {
      return null;
    }
  }

  static String? isNumber(String value) {
    // Remove any whitespace
    final trimmedValue = value.trim();

    // Check if string contains only numbers using RegExp
    final numberRegExp = RegExp(r'^[0-9٠-٩]+$');
    if (!numberRegExp.hasMatch(trimmedValue)) {
      return 'Please enter numbers only';
    }

    return null; // Return null if validation passes
  }

  static String? isNumberWithNegative(String value) {
    // Remove any whitespace
    final trimmedValue = value.trim();

    // Check if string contains only numbers or a negative sign followed by
    // numbers using RegExp
    final numberRegExp = RegExp(r'^-?[0-9]+$');
    if (!numberRegExp.hasMatch(trimmedValue)) {
      return 'Please enter numbers only';
    }

    return null; // Return null if validation passes
  }

  static bool isBetween(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// Function to check if latitude is valid
  static String? isValidLatitude(double latitude) {
    if (!isBetween(latitude, -90.0, 90.0)) {
      return S.current.latitudeInvalid;
    }

    return null;
  }

  /// Function to check if longitude is valid
  static String? isValidLongitude(double longitude) {
    if (!isBetween(longitude, -180.0, 180.0)) {
      return S.current.longitudeInvalid;
    }

    return null;
  }

  static String? isGoogleMapsLink(String url) {
    final googleMapsPattern = RegExp(
      r'^(https?:\/\/)?(www\.)?(google\.)?(com|[a-z]{2})(\/maps)?\/([a-zA-Z0-9@:%._\+~#=]{1,256})$',
      caseSensitive: false,
    );
    if (!googleMapsPattern.hasMatch(url)) {
      return S.current.linkInvalid;
    }
    return null;
  }

  /// Link check returning [S.current.pleaseEnterAValidLink]. Distinct from
  /// [isValidLink] (returns a bool) and [http] (returns 'Invalid URL').
  static String? isLink(String value) {
    final linkPattern = RegExp(
      r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9@:%._\+~#=-]+\.)+[a-z]{2,6}(\/[a-zA-Z0-9@:%._\+~#?&//=~-]*)?$',
      caseSensitive: false,
    );

    if (!linkPattern.hasMatch(value)) {
      return S.current.pleaseEnterAValidLink;
    }

    return null;
  }

  static String? isMoreThanZero(String value) {
    String? error = isNumber(value);
    if (error != null) {
      return error;
    }
    final trimmedValue = value.trim();
    final convertedValue = trimmedValue.toEnglishNumber();

    if (convertedValue <= 0) {
      return S.current.pleaseEnterNumbersOnlyMoreThen0;
    }

    return null; // Return null if validation passes
  }

  static String? isNotDuplicateOption(List<String> options, String option) {
    // Check if the option already exists in the list
    if (options.where((element) => element == option).length > 1) {
      return S.current.youCannotAddAnOptionThatAlreadyExists;
    }
    return null; // No duplicate found
  }

  static bool isPasswordValid(String password) {
    return RegExp(
            r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$")
        .hasMatch(password);
  }

  static bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(phoneNumber);
  }

  static bool isAgeAboveSixteen(String dobString) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final DateTime dob = dateFormat.parse(dobString);

    final DateTime now = DateTime.now();
    int age = now.year - dob.year;

    // check if the birthday has passed this year
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 16;
  }

  static bool hasLowerCase(String password) {
    return RegExp(r'^(?=.*[a-z])').hasMatch(password);
  }

  static bool hasUpperCase(String password) {
    return RegExp(r'^(?=.*[A-Z])').hasMatch(password);
  }

  static bool hasNumber(String password) {
    return RegExp(r'^(?=.*?[0-9])').hasMatch(password);
  }

  static bool hasSpecialCharacter(String password) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(password);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'^(?=.{8,})').hasMatch(password);
  }
}
