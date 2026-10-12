// ***************************** FILE INFO ***************************** //
// File Name: certification_employee_row.dart
// Purpose: Defines one joined employee certification table row.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import 'employee_details_row.dart';

/// Joins employee identity, certification histories, and document URLs.
class CertificationEmployeeRow extends EmployeeDetailsRow {
  const CertificationEmployeeRow({
    required super.employee,
    this.certification,
  });

  final EmployeeCertificationDetailsModel? certification;

  /// Method Name: [certificationValues]
  ///
  /// Purpose: Returns current certification values in visible table order.
  List<String> get certificationValues => [
        latestHistoryValue(certification?.institutionName),
        latestHistoryValue(certification?.degree),
        latestHistoryValue(certification?.fieldOfStudy),
        latestHistoryValue(certification?.startDate),
        latestHistoryValue(certification?.endDate),
        latestHistoryValue(certification?.gradeOrScore),
        latestHistoryValue(certification?.certificateId),
        latestHistoryValue(certification?.issuingAuthority),
        _lastNonEmpty(certification?.certificationDocumentUrl),
        latestHistoryValue(certification?.notes),
      ];

  /// Method Name: [createdTimestamp]
  ///
  /// Purpose: Returns the first certification timestamp for table display.
  Timestamp? get createdTimestamp =>
      hasCertificationData ? _timestampAt(0) : null;

  /// Method Name: [updatedTimestamp]
  ///
  /// Purpose: Returns the latest certification timestamp for table display.
  Timestamp? get updatedTimestamp =>
      hasCertificationData && certification?.timestamps.isNotEmpty == true
          ? certification!.timestamps.last
          : null;

  /// Whether the employee has a certificate value or uploaded document.
  bool get hasCertificationData =>
      certificationValues.any((value) => value.trim().isNotEmpty);

  /// Method Name: [detailSearchValues]
  ///
  /// Purpose: Exposes certification values for shared row search.
  @override
  List<String> get detailSearchValues => certificationValues;

  Timestamp? _timestampAt(int index) {
    final timestamps = certification?.timestamps;
    if (timestamps == null || timestamps.length <= index) return null;
    return timestamps[index];
  }

  static String _lastNonEmpty(List<String>? values) =>
      values?.lastWhere((value) => value.trim().isNotEmpty, orElse: () => '') ??
      '';
}
