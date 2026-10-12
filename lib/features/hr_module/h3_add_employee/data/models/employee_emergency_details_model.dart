// ***************************** FILE INFO ***************************** //
// File Name: employee_emergency_details_model.dart
// Purpose: Stores historical emergency values unsupported by the legacy model.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'employee_history_model_parser.dart';

/// Persisted supplemental emergency-contact histories for one employee.
class EmployeeEmergencyDetailsModel {
  const EmployeeEmergencyDetailsModel({
    required this.employeeId,
    required this.timestamps,
    required this.firstContactFirstNameArabic,
    required this.firstContactLastNameArabic,
    required this.firstContactCountryCode,
    required this.secondContactFirstNameArabic,
    required this.secondContactLastNameArabic,
    required this.secondContactCountryCode,
  });

  static const employeeIdKey = 'Employee_Id';
  static const timestampsKey = 'Timestamps';
  static const legacyMiddleNameKeys = <String>[
    'First_Contact_Middle_Name',
    'First_Contact_Middle_Name_Arabic',
    'Second_Contact_Middle_Name',
    'Second_Contact_Middle_Name_Arabic',
  ];
  static const firstContactFirstNameArabicKey =
      'First_Contact_First_Name_Arabic';
  static const firstContactLastNameArabicKey = 'First_Contact_Last_Name_Arabic';
  static const firstContactCountryCodeKey = 'First_Contact_Country_Code';
  static const secondContactFirstNameArabicKey =
      'Second_Contact_First_Name_Arabic';
  static const secondContactLastNameArabicKey =
      'Second_Contact_Last_Name_Arabic';
  static const secondContactCountryCodeKey = 'Second_Contact_Country_Code';

  final String employeeId;
  final List<int> timestamps;
  final List<String> firstContactFirstNameArabic;
  final List<String> firstContactLastNameArabic;
  final List<String> firstContactCountryCode;
  final List<String> secondContactFirstNameArabic;
  final List<String> secondContactLastNameArabic;
  final List<String> secondContactCountryCode;

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes synchronized emergency histories for Firestore.
  ///
  /// Returns: The Firestore-compatible emergency history map.
  Map<String, dynamic> toMap() => {
        employeeIdKey: employeeId,
        timestampsKey: timestamps,
        firstContactFirstNameArabicKey: firstContactFirstNameArabic,
        firstContactLastNameArabicKey: firstContactLastNameArabic,
        firstContactCountryCodeKey: firstContactCountryCode,
        secondContactFirstNameArabicKey: secondContactFirstNameArabic,
        secondContactLastNameArabicKey: secondContactLastNameArabic,
        secondContactCountryCodeKey: secondContactCountryCode,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Restores emergency histories from history or legacy scalars.
  ///
  /// Parameters:
  /// - [map]: Firestore emergency map.
  ///
  /// Returns: An emergency-details history model.
  factory EmployeeEmergencyDetailsModel.fromMap(Map<String, dynamic> map) =>
      EmployeeEmergencyDetailsModel(
        employeeId: map[employeeIdKey]?.toString() ?? '',
        timestamps: EmployeeHistoryModelParser.timestamps(map),
        firstContactFirstNameArabic: EmployeeHistoryModelParser.stringHistory(
          map[firstContactFirstNameArabicKey],
        ),
        firstContactLastNameArabic: EmployeeHistoryModelParser.stringHistory(
          map[firstContactLastNameArabicKey],
        ),
        firstContactCountryCode: EmployeeHistoryModelParser.stringHistory(
          map[firstContactCountryCodeKey],
        ),
        secondContactFirstNameArabic: EmployeeHistoryModelParser.stringHistory(
          map[secondContactFirstNameArabicKey],
        ),
        secondContactLastNameArabic: EmployeeHistoryModelParser.stringHistory(
          map[secondContactLastNameArabicKey],
        ),
        secondContactCountryCode: EmployeeHistoryModelParser.stringHistory(
          map[secondContactCountryCodeKey],
        ),
      );
}
