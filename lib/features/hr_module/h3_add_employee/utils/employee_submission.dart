// ***************************** FILE INFO ***************************** //
// File Name: employee_submission.dart
// Purpose: Groups prepared employee records for one atomic Firestore write.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import '../../../roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import '../../../onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import '../data/models/employee_attachments_model.dart';
import '../data/models/employee_certification_details_model.dart';
import '../data/models/employee_contact_details_model.dart';
import '../data/models/employee_emergency_details_model.dart';
import '../data/models/employee_insurance_details_model.dart';

/// Prepared persistence payload for one employee creation transaction.
class EmployeeSubmission {
  const EmployeeSubmission({
    required this.employee,
    required this.accountOverview,
    required this.contactDetails,
    required this.certificationDetails,
    required this.insuranceDetails,
    required this.emergencyDetails,
    required this.attachments,
  });

  final NewEmployeeModelHistory employee;
  final DemoUserAccountOverview accountOverview;
  final EmployeeContactDetailsModel contactDetails;
  final EmployeeCertificationDetailsModel certificationDetails;
  final EmployeeInsuranceDetailsModel insuranceDetails;
  final EmployeeEmergencyDetailsModel emergencyDetails;
  final EmployeeAttachmentsModel attachments;
}
