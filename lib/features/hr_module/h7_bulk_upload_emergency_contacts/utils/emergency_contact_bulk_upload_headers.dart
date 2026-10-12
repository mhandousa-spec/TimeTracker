// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_headers.dart
// Purpose: Defines the emergency-contact workbook contract.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import '../../shared/bulk_upload/bulk_upload_template.dart';

/// Stable spreadsheet columns for updating existing emergency contacts.
abstract final class EmergencyContactBulkUploadHeaders {
  static const number = 'NO';
  static const employeeId = 'Employee ID';
  static const firstName = 'First Contact First Name';
  static const firstLastName = 'First Contact Last Name';
  static const firstNameArabic = 'First Contact First Name Arabic';
  static const firstLastNameArabic = 'First Contact Last Name Arabic';
  static const firstRelationship = 'First Contact Relationship';
  static const firstEmail = 'First Contact Email';
  static const firstPhone = 'First Contact Phone';
  static const firstPhoneCountryCode = 'First Contact Phone Country Code';
  static const firstLanguage = 'First Contact Language';
  static const firstCountry = 'First Contact Country';
  static const firstProvince = 'First Contact Province';
  static const firstCity = 'First Contact City';
  static const firstStreet = 'First Contact Street';
  static const secondName = 'Second Contact First Name';
  static const secondLastName = 'Second Contact Last Name';
  static const secondNameArabic = 'Second Contact First Name Arabic';
  static const secondLastNameArabic = 'Second Contact Last Name Arabic';
  static const secondRelationship = 'Second Contact Relationship';
  static const secondEmail = 'Second Contact Email';
  static const secondPhone = 'Second Contact Phone';
  static const secondPhoneCountryCode = 'Second Contact Phone Country Code';
  static const secondLanguage = 'Second Contact Language';
  static const secondCountry = 'Second Contact Country';
  static const secondProvince = 'Second Contact Province';
  static const secondCity = 'Second Contact City';
  static const secondStreet = 'Second Contact Street';

  static const values = <String>[
    number,
    employeeId,
    firstName,
    firstLastName,
    firstNameArabic,
    firstLastNameArabic,
    firstRelationship,
    firstEmail,
    firstPhone,
    firstPhoneCountryCode,
    firstLanguage,
    firstCountry,
    firstProvince,
    firstCity,
    firstStreet,
    secondName,
    secondLastName,
    secondNameArabic,
    secondLastNameArabic,
    secondRelationship,
    secondEmail,
    secondPhone,
    secondPhoneCountryCode,
    secondLanguage,
    secondCountry,
    secondProvince,
    secondCity,
    secondStreet,
  ];

  static const template = BulkUploadTemplate(
    headers: values,
    maxRows: 100,
  );
}
