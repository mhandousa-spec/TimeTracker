// ***************************** FILE INFO ***************************** //
// File Name: employee_certification_details_model.dart
// Purpose: Stores synchronized employee certification histories for HR.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import 'employee_history_model_parser.dart';

/// Persisted certification histories associated with one employee.
class EmployeeCertificationDetailsModel {
  const EmployeeCertificationDetailsModel({
    required this.employeeId,
    required this.timestamps,
    required this.institutionName,
    required this.degree,
    required this.fieldOfStudy,
    required this.startDate,
    required this.endDate,
    required this.gradeOrScore,
    required this.certificateId,
    required this.issuingAuthority,
    required this.certificationDocumentUrl,
    required this.notes,
  });

  static const employeeIdKey = 'Employee_Id';
  static const timestampsKey = 'Timestamps';
  static const institutionNameKey = 'Institution_Name';
  static const degreeKey = 'Degree';
  static const fieldOfStudyKey = 'Field_Of_Study';
  static const startDateKey = 'Start_Date';
  static const endDateKey = 'End_Date';
  static const gradeOrScoreKey = 'Grade_Or_Score';
  static const certificateIdKey = 'Certificate_Id';
  static const issuingAuthorityKey = 'Issuing_Authority';
  static const certificationDocumentUrlKey = 'Certification_Document_Url';
  static const notesKey = 'Notes';

  final String employeeId;
  final List<Timestamp> timestamps;
  final List<String> institutionName;
  final List<String> degree;
  final List<String> fieldOfStudy;
  final List<String> startDate;
  final List<String> endDate;
  final List<String> gradeOrScore;
  final List<String> certificateId;
  final List<String> issuingAuthority;
  final List<String> certificationDocumentUrl;
  final List<String> notes;

  /// Method Name: [toMap]
  ///
  /// Purpose: Serializes synchronized certification histories for Firestore.
  ///
  /// Returns: The Firestore-compatible certification history map.
  Map<String, dynamic> toMap() => {
        employeeIdKey: employeeId,
        timestampsKey: timestamps,
        institutionNameKey: institutionName,
        degreeKey: degree,
        fieldOfStudyKey: fieldOfStudy,
        startDateKey: startDate,
        endDateKey: endDate,
        gradeOrScoreKey: gradeOrScore,
        certificateIdKey: certificateId,
        issuingAuthorityKey: issuingAuthority,
        certificationDocumentUrlKey: certificationDocumentUrl,
        notesKey: notes,
      };

  /// Method Name: [fromMap]
  ///
  /// Purpose: Restores certification histories from history or legacy scalars.
  ///
  /// Parameters:
  /// - [map]: Firestore certification map.
  ///
  /// Returns: A certification-details history model.
  factory EmployeeCertificationDetailsModel.fromMap(
    Map<String, dynamic> map,
  ) =>
      EmployeeCertificationDetailsModel(
        employeeId: map[employeeIdKey]?.toString() ?? '',
        timestamps: EmployeeHistoryModelParser.firestoreTimestamps(map),
        institutionName:
            EmployeeHistoryModelParser.stringHistory(map[institutionNameKey]),
        degree: EmployeeHistoryModelParser.stringHistory(map[degreeKey]),
        fieldOfStudy:
            EmployeeHistoryModelParser.stringHistory(map[fieldOfStudyKey]),
        startDate: EmployeeHistoryModelParser.stringHistory(map[startDateKey]),
        endDate: EmployeeHistoryModelParser.stringHistory(map[endDateKey]),
        gradeOrScore:
            EmployeeHistoryModelParser.stringHistory(map[gradeOrScoreKey]),
        certificateId:
            EmployeeHistoryModelParser.stringHistory(map[certificateIdKey]),
        issuingAuthority:
            EmployeeHistoryModelParser.stringHistory(map[issuingAuthorityKey]),
        certificationDocumentUrl: EmployeeHistoryModelParser.stringHistory(
          map[certificationDocumentUrlKey],
        ),
        notes: EmployeeHistoryModelParser.stringHistory(map[notesKey]),
      );
}
