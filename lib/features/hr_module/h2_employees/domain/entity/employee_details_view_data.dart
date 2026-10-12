// ***************************** FILE INFO ***************************** //
// File Name: employee_details_view_data.dart
// Purpose: Defines the typed employee profile data displayed by HR details.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import '../../../h3_add_employee/data/models/employee_attachments_model.dart';
import '../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../../../h3_add_employee/data/models/employee_contact_details_model.dart';
import '../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

/// Holds optional HR documents read for one employee.
class EmployeeDetailsSupplementalData {
  const EmployeeDetailsSupplementalData({
    this.contactDetails,
    this.certificationDetails,
    this.insuranceDetails,
    this.emergencyDetails,
    this.attachments,
  });

  final EmployeeContactDetailsModel? contactDetails;
  final EmployeeCertificationDetailsModel? certificationDetails;
  final EmployeeInsuranceDetailsModel? insuranceDetails;
  final EmployeeEmergencyDetailsModel? emergencyDetails;
  final EmployeeAttachmentsModel? attachments;
}

/// Combines an employee profile with its optional HR detail records.
class EmployeeDetailsViewData extends EmployeeDetailsSupplementalData {
  const EmployeeDetailsViewData({
    required this.employee,
    super.contactDetails,
    super.certificationDetails,
    super.insuranceDetails,
    super.emergencyDetails,
    super.attachments,
  });

  final HrEmployeeEntity employee;
}
