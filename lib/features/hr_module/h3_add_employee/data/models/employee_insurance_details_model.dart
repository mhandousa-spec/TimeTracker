// ***************************** FILE INFO ***************************** //
// File Name: employee_insurance_details_model.dart
// Purpose: Stores historical insurance values unsupported by the legacy model.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'employee_history_model_parser.dart';

/// Persisted supplemental insurance histories for one employee.
class EmployeeInsuranceDetailsModel {
  const EmployeeInsuranceDetailsModel({
    required this.employeeId,
    required this.timestamps,
    required this.providerContact,
  });

  static const employeeIdKey = 'Employee_Id';
  static const timestampsKey = 'Timestamps';
  static const providerContactKey = 'Provider_Contact';

  final String employeeId;
  final List<int> timestamps;
  final List<String> providerContact;

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes synchronized insurance histories for Firestore.
  ///
  /// Returns: The Firestore-compatible insurance history map.
  Map<String, dynamic> toMap() => {
        employeeIdKey: employeeId,
        timestampsKey: timestamps,
        providerContactKey: providerContact,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Restores insurance histories from history or legacy scalars.
  ///
  /// Parameters:
  /// - [map]: Firestore insurance map.
  ///
  /// Returns: An insurance-details history model.
  factory EmployeeInsuranceDetailsModel.fromMap(Map<String, dynamic> map) =>
      EmployeeInsuranceDetailsModel(
        employeeId: map[employeeIdKey]?.toString() ?? '',
        timestamps: EmployeeHistoryModelParser.timestamps(map),
        providerContact: EmployeeHistoryModelParser.stringHistory(
          map[providerContactKey],
        ),
      );
}
