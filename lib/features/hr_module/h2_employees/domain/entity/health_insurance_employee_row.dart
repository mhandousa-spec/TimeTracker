// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_employee_row.dart
// Purpose: Defines a joined employee and health-insurance table row.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import '../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import 'employee_details_row.dart';

/// Provides display and search values for one health-insurance table row.
class HealthInsuranceEmployeeRow extends EmployeeDetailsRow {
  const HealthInsuranceEmployeeRow({
    required super.employee,
    this.insuranceDetails,
  });

  final EmployeeInsuranceDetailsModel? insuranceDetails;

  /// Returns the latest persisted insurance-provider contact.
  String get providerContact =>
      latestHistoryValue(insuranceDetails?.providerContact);

  /// Method Name: [detailSearchValues]
  ///
  /// Purpose: Exposes insurance values for shared row search.
  ///
  /// Returns: Normalized visible insurance values.
  @override
  List<String> get detailSearchValues => [
        employee.insuranceName ?? '',
        employee.insurancePolicyNumber ?? '',
        providerContact,
      ];
}
