// ***************************** FILE INFO ***************************** //
// File Name: employee_contact_details_model.dart
// Purpose: Stores historical contact values unsupported by the legacy profile.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'employee_history_model_parser.dart';

/// Persisted HR contact histories associated with one employee.
class EmployeeContactDetailsModel {
  const EmployeeContactDetailsModel({
    required this.employeeId,
    required this.timestamps,
    required this.personalEmail,
    required this.homeCountryCode,
    required this.officeCountryCode,
  });

  static const employeeIdKey = 'Employee_Id';
  static const timestampsKey = 'Timestamps';
  static const personalEmailKey = 'Personal_Email';
  static const homeCountryCodeKey = 'Home_Country_Code';
  static const officeCountryCodeKey = 'Office_Country_Code';

  final String employeeId;
  final List<int> timestamps;
  final List<String> personalEmail;
  final List<String> homeCountryCode;
  final List<String> officeCountryCode;

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes synchronized contact histories for Firestore.
  ///
  /// Returns: The Firestore-compatible contact history map.
  Map<String, dynamic> toMap() => {
        employeeIdKey: employeeId,
        timestampsKey: timestamps,
        personalEmailKey: personalEmail,
        homeCountryCodeKey: homeCountryCode,
        officeCountryCodeKey: officeCountryCode,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Restores contact histories from history or legacy scalar values.
  ///
  /// Parameters:
  /// - [map]: Firestore contact map.
  ///
  /// Returns: A contact-details history model.
  factory EmployeeContactDetailsModel.fromMap(Map<String, dynamic> map) =>
      EmployeeContactDetailsModel(
        employeeId: map[employeeIdKey]?.toString() ?? '',
        timestamps: EmployeeHistoryModelParser.timestamps(map),
        personalEmail: EmployeeHistoryModelParser.stringHistory(
          map[personalEmailKey],
        ),
        homeCountryCode: EmployeeHistoryModelParser.stringHistory(
          map[homeCountryCodeKey],
        ),
        officeCountryCode: EmployeeHistoryModelParser.stringHistory(
          map[officeCountryCodeKey],
        ),
      );
}
