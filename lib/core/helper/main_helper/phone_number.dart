/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: phone_number.dart
/// Purpose: Declares `NumberTooLongException`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/helper/main_helper/countries.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumber {
  String countryISOCode;
  String countryCode;
  String number;

  /// The app's own country marker persisted alongside the number (Firestore
  /// `Country_App`). It is NOT an ISO country code, so it is kept separate
  /// from [countryISOCode]. Only employee records populate it.
  String? countryApp;

  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
    this.countryApp,
  });

  /// Alias for [number], kept so employee call sites can read `.phone`.
  String get phone => number;

  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == "") {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }

    try {
      Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(1 + country.dialCode.length + country.regionCode.length);
      } else {
        number = completeNumber.substring(country.dialCode.length + country.regionCode.length);
      }
      return PhoneNumber(
          countryISOCode: country.code, countryCode: country.dialCode + country.regionCode, number: number);
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumber(countryISOCode: "", countryCode: "", number: "");
    }
  }

  bool isValidNumber() {
    Country country = getCountry(completeNumber);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  String get completeNumber {
    return countryCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == "") {
      throw NumberTooShortException();
    }

    final validPhoneNumber = RegExp(r'^[+0-9]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countries
          .firstWhere((country) => phoneNumber.substring(1).startsWith(country.dialCode + country.regionCode));
    }
    return countries.firstWhere((country) => phoneNumber.startsWith(country.dialCode + country.regionCode));
  }

  @override
  String toString() => 'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
}

/// Firestore history of a phone number over time.
///
/// Moved here from features/onboarding/o3_authentication/data/models/
/// phone_model.dart (author: Amr Mesbah, 31/12/2024). Unlike [PhoneNumber],
/// which is a single value object with country parsing/validation, this keeps
/// parallel lists of every value the number has had plus when it changed.
class PhoneModel {
  List<String> phoneNumber;
  List<String> countryCode;
  List<Timestamp> timestamps;

  PhoneModel({
    required this.phoneNumber,
    required this.countryCode,
    required this.timestamps,
  });

  static const String PHONE_NUMBER = 'Phone_Number';
  static const String COUNTRY_CODE = 'Country_Code';
  static const String TIMESTAMPS = 'Timestamps';

  Map<String, dynamic> toMap() {
    return {
      PHONE_NUMBER: phoneNumber,
      COUNTRY_CODE: countryCode,
      TIMESTAMPS: timestamps,
    };
  }

  factory PhoneModel.fromMap(Map<String, dynamic> map) {
    return PhoneModel(
      phoneNumber: List<String>.from(map[PHONE_NUMBER]),
      countryCode: List<String>.from(map[COUNTRY_CODE]),
      timestamps: List<Timestamp>.from(map[TIMESTAMPS]),
    );
  }
}
