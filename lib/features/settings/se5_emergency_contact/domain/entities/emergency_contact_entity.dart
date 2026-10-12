/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_entity.dart
/// Purpose: An employee's two emergency contacts.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N03/N09/N10: the `data/models/` import is
///          gone — `fromModel` moved to
///          `data/models/emergency_contact_mapper.dart`, so the domain no
///          longer depends on the data layer; every field is final; the stray
///          `// ADD THIS` comments are removed; and `provionce` is spelled
///          `province` (the *Firestore key* keeps the original spelling, since
///          the stored documents use it).
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/domain/entities/…

import 'package:flutter/foundation.dart';

@immutable
class EmergencyContactEntity {
  final String employeeId;
  final String? firstContactFirstName;
  final String? firstContactMiddleName;
  final String? firstContactLastName;
  final String? firstContactRelationShip;
  final String? firstContactPhone;
  final String? firstContactCountryCode;
  final String? firstContactEmail;
  final String? firstContactCountry;
  final String? firstContactProvince;
  final String? firstContactCity;
  final String? firstContactStreet;
  final String? firstContactLanguage;
  final String? secondContactFirstName;
  final String? secondContactMiddleName;
  final String? secondContactLastName;
  final String? secondContactRelationShip;
  final String? secondContactPhone;
  final String? secondContactCountryCode;
  final String? secondContactEmail;
  final String? secondContactCountry;
  final String? secondContactProvince;
  final String? secondContactCity;
  final String? secondContactStreet;
  final String? secondContactLanguage;
  final String? firstContactCountryApp;
  final String? secondContactCountryApp;

  const EmergencyContactEntity({
    required this.employeeId,
    this.firstContactFirstName,
    this.firstContactMiddleName,
    this.firstContactLastName,
    this.firstContactRelationShip,
    this.firstContactPhone,
    this.firstContactCountryCode,
    this.firstContactEmail,
    this.firstContactCountry,
    this.firstContactProvince,
    this.firstContactCity,
    this.firstContactStreet,
    this.firstContactLanguage,
    this.secondContactFirstName,
    this.secondContactMiddleName,
    this.secondContactLastName,
    this.secondContactRelationShip,
    this.secondContactPhone,
    this.secondContactCountryCode,
    this.secondContactEmail,
    this.secondContactCountry,
    this.secondContactProvince,
    this.secondContactCity,
    this.secondContactStreet,
    this.secondContactLanguage,
    required this.firstContactCountryApp,
    required this.secondContactCountryApp,
  });

  EmergencyContactEntity copyWith({
    String? employeeId,
    String? firstContactFirstName,
    String? firstContactMiddleName,
    String? firstContactLastName,
    String? firstContactRelationShip,
    String? firstContactPhone,
    String? firstContactCountryCode,
    String? firstContactEmail,
    String? firstContactCountry,
    String? firstContactProvince,
    String? firstContactCity,
    String? firstContactStreet,
    String? firstContactLanguage,
    String? secondContactFirstName,
    String? secondContactMiddleName,
    String? secondContactLastName,
    String? secondContactRelationShip,
    String? secondContactPhone,
    String? secondContactCountryCode,
    String? secondContactEmail,
    String? secondContactCountry,
    String? secondContactProvince,
    String? secondContactCity,
    String? secondContactStreet,
    String? secondContactLanguage,
    String? firstContactCountryApp,
    String? secondContactCountryApp,
  }) {
    return EmergencyContactEntity(
      employeeId: employeeId ?? this.employeeId,
      firstContactFirstName: firstContactFirstName ?? this.firstContactFirstName,
      firstContactMiddleName: firstContactMiddleName ?? this.firstContactMiddleName,
      firstContactLastName: firstContactLastName ?? this.firstContactLastName,
      firstContactRelationShip: firstContactRelationShip ?? this.firstContactRelationShip,
      firstContactPhone: firstContactPhone ?? this.firstContactPhone,
      firstContactCountryCode: firstContactCountryCode ?? this.firstContactCountryCode,
      firstContactEmail: firstContactEmail ?? this.firstContactEmail,
      firstContactCountry: firstContactCountry ?? this.firstContactCountry,
      firstContactProvince: firstContactProvince ?? this.firstContactProvince,
      firstContactCity: firstContactCity ?? this.firstContactCity,
      firstContactStreet: firstContactStreet ?? this.firstContactStreet,
      firstContactLanguage: firstContactLanguage ?? this.firstContactLanguage,
      secondContactFirstName: secondContactFirstName ?? this.secondContactFirstName,
      secondContactMiddleName: secondContactMiddleName ?? this.secondContactMiddleName,
      secondContactLastName: secondContactLastName ?? this.secondContactLastName,
      secondContactRelationShip: secondContactRelationShip ?? this.secondContactRelationShip,
      secondContactPhone: secondContactPhone ?? this.secondContactPhone,
      secondContactCountryCode: secondContactCountryCode ?? this.secondContactCountryCode,
      secondContactEmail: secondContactEmail ?? this.secondContactEmail,
      secondContactCountry: secondContactCountry ?? this.secondContactCountry,
      secondContactProvince: secondContactProvince ?? this.secondContactProvince,
      secondContactCity: secondContactCity ?? this.secondContactCity,
      secondContactStreet: secondContactStreet ?? this.secondContactStreet,
      secondContactLanguage: secondContactLanguage ?? this.secondContactLanguage,
      firstContactCountryApp: firstContactCountryApp ?? this.firstContactCountryApp,
      secondContactCountryApp: secondContactCountryApp ?? this.secondContactCountryApp,
    );
  }
}
