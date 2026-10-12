/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contacts_model.dart
/// Purpose: The stored emergency-contact document.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N03: the Dart identifier `provionce` is spelled `province`;
///          the Firestore *key* keeps the original spelling.

// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/models/emergency_contacts_model/emergency_contacts_model.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:knowticed_plus/core/helper/main_helper/single_value_model.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';

class EmergencyContactsModel {
  String employeeId;
  EmergencyContactModel? firstEmergencyContact;
  EmergencyContactModel? secondEmergencyContact;

  EmergencyContactsModel({
    required this.employeeId,
    this.firstEmergencyContact,
    this.secondEmergencyContact,
  });

  static const String employeeIdKey = 'Employee_Id';
  static const String firstEmergencyContactKey = 'First_Emergency_Contact';
  static const String secondEmergencyContactKey = 'Second_Emergency_Contact';

  Map<String, dynamic> toMap() {
    return {
      employeeIdKey: employeeId,
      firstEmergencyContactKey: firstEmergencyContact?.toMap(),
      secondEmergencyContactKey: secondEmergencyContact?.toMap(),
    };
  }

  factory EmergencyContactsModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactsModel(
      employeeId: map[employeeIdKey] as String,
      firstEmergencyContact: EmergencyContactModel.fromMap(
          map[firstEmergencyContactKey] as Map<String, dynamic>),
      secondEmergencyContact: EmergencyContactModel.fromMap(
          map[secondEmergencyContactKey] as Map<String, dynamic>),
    );
  }
}

class EmergencyContactModel {
  SingleValueModel<String> firstName;
  SingleValueModel<String> middleName;
  SingleValueModel<String> lastName;
  SingleValueModel<String> relationShip;
  MobilePhone phone;
  SingleValueModel<String> email;
  SingleValueModel<String> country;
  SingleValueModel<String> province;
  SingleValueModel<String> city;
  SingleValueModel<String> street;
  SingleValueModel<String> language; // ADD THIS

  static const String firstNameKey = 'First_Name';
  static const String middleNameKey = 'Middle_Name';
  static const String lastNameKey = 'Last_Name';
  static const String relationShipKey = 'Relation_Ship';
  static const String phoneKey = 'Phone';
  static const String emailKey = 'Email';
  static const String countryKey = 'Country';
  // The Firestore key really is misspelled; the stored documents use it,
  // so only the Dart identifier was corrected (CR-SKEL-SE5-N03).
  static const String provinceKey = 'Provionce';
  static const String cityKey = 'City';
  static const String streetKey = 'Street';
  static const String languageKey = 'Language'; // ADD THIS

  EmergencyContactModel({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.relationShip,
    required this.phone,
    required this.email,
    required this.country,
    required this.province,
    required this.city,
    required this.street,
    required this.language, // ADD THIS
  });

  Map<String, dynamic> toMap() {
    return {
      firstNameKey: firstName.toMap(),
      middleNameKey: middleName.toMap(),
      lastNameKey: lastName.toMap(),
      relationShipKey: relationShip.toMap(),
      phoneKey: phone.toMap(),
      emailKey: email.toMap(),
      countryKey: country.toMap(),
      provinceKey: province.toMap(),
      cityKey: city.toMap(),
      streetKey: street.toMap(),
      languageKey: language.toMap(), // ADD THIS
    };
  }

  factory EmergencyContactModel.fromMap(Map<String, dynamic> map) {
    return EmergencyContactModel(
      firstName: SingleValueModel<String>.fromMap(
          map[firstNameKey] as Map<String, dynamic>),
      middleName: SingleValueModel<String>.fromMap(
          map[middleNameKey] as Map<String, dynamic>),
      lastName: SingleValueModel<String>.fromMap(
          map[lastNameKey] as Map<String, dynamic>),
      relationShip: SingleValueModel<String>.fromMap(
          map[relationShipKey] as Map<String, dynamic>),
      // services_app's MobilePhone.fromMap takes a non-nullable map (unlike
      // services_app's, which accepts null and returns an all-null instance).
      // An empty map produces the same all-null result.
      phone: MobilePhone.fromMap(
          (map[phoneKey] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      email: SingleValueModel<String>.fromMap(
          map[emailKey] as Map<String, dynamic>),
      country: SingleValueModel<String>.fromMap(
          map[countryKey] as Map<String, dynamic>),
      province: SingleValueModel<String>.fromMap(
          map[provinceKey] as Map<String, dynamic>),
      city: SingleValueModel<String>.fromMap(
          map[cityKey] as Map<String, dynamic>),
      street: SingleValueModel<String>.fromMap(
          map[streetKey] as Map<String, dynamic>),
      language: SingleValueModel<String>.fromMap( // ADD THIS
          map[languageKey] as Map<String, dynamic>),
    );
  }
}