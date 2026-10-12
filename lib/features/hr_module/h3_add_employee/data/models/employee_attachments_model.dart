// ***************************** FILE INFO ***************************** //
// File Name: employee_attachments_model.dart
// Purpose: Stores synchronized uploaded HR document URL histories.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'employee_history_model_parser.dart';

/// Persisted attachment URL histories associated with one employee.
class EmployeeAttachmentsModel {
  const EmployeeAttachmentsModel({
    required this.employeeId,
    required this.timestamps,
    required this.passportDocumentUrl,
    required this.nationalIdFrontUrl,
    required this.nationalIdBackUrl,
    required this.drivingLicenseDocumentUrl,
  });

  static const employeeIdKey = 'Employee_Id';
  static const timestampsKey = 'timestamps';
  static const passportDocumentUrlKey = 'Passport_Document_Url';
  static const nationalIdFrontUrlKey = 'National_Id_Front_Url';
  static const nationalIdBackUrlKey = 'National_Id_Back_Url';
  static const drivingLicenseDocumentUrlKey = 'Driving_License_Document_Url';

  final String employeeId;
  final List<int> timestamps;
  final List<String> passportDocumentUrl;
  final List<String> nationalIdFrontUrl;
  final List<String> nationalIdBackUrl;
  final List<String> drivingLicenseDocumentUrl;

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes synchronized attachment histories for Firestore.
  ///
  /// Returns: The Firestore-compatible attachment history map.
  Map<String, dynamic> toMap() => {
        employeeIdKey: employeeId,
        timestampsKey: timestamps,
        passportDocumentUrlKey: passportDocumentUrl,
        nationalIdFrontUrlKey: nationalIdFrontUrl,
        nationalIdBackUrlKey: nationalIdBackUrl,
        drivingLicenseDocumentUrlKey: drivingLicenseDocumentUrl,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Restores attachment histories from history or legacy scalars.
  ///
  /// Parameters:
  /// - [map]: Firestore attachment map.
  ///
  /// Returns: An employee-attachments history model.
  factory EmployeeAttachmentsModel.fromMap(Map<String, dynamic> map) =>
      EmployeeAttachmentsModel(
        employeeId: map[employeeIdKey]?.toString() ?? '',
        timestamps: EmployeeHistoryModelParser.timestamps(map),
        passportDocumentUrl: EmployeeHistoryModelParser.stringHistory(
          map[passportDocumentUrlKey],
        ),
        nationalIdFrontUrl: EmployeeHistoryModelParser.stringHistory(
          map[nationalIdFrontUrlKey],
        ),
        nationalIdBackUrl: EmployeeHistoryModelParser.stringHistory(
          map[nationalIdBackUrlKey],
        ),
        drivingLicenseDocumentUrl: EmployeeHistoryModelParser.stringHistory(
          map[drivingLicenseDocumentUrlKey],
        ),
      );
}
