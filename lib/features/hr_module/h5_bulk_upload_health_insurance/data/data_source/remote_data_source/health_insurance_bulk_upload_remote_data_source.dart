// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_bulk_upload_remote_data_source.dart
// Purpose: Reads and transactionally appends employee insurance histories.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/hr_module/h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import '../../models/health_insurance_bulk_upload_models.dart';

/// Firestore boundary for health-insurance workbook reads and updates.
class HealthInsuranceBulkUploadRemoteDataSource {
  HealthInsuranceBulkUploadRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Method Name: [loadPreflight]
  ///
  /// Purpose: Loads employee identities once before workbook validation.
  ///
  /// Returns: Employee entities keyed by employee identifier.
  Future<HealthInsuranceBulkUploadPreflight> loadPreflight() async {
    final snapshot = await _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .get();
    return HealthInsuranceBulkUploadPreflight({
      for (final document in snapshot.docs)
        document.id.trim(): EmployeeEntityController()
            .fromHistoryModel(NewEmployeeModelHistory.fromMap(document.data())),
    });
  }

  /// Method Name: [appendInsurance]
  ///
  /// Purpose: Preserves prior values while appending one complete insurance update.
  ///
  /// Parameters:
  /// - [employeeId]: Existing employee document identifier.
  /// - [insuranceName]: New provider plan name.
  /// - [policyNumber]: New provider policy number.
  /// - [providerContact]: New provider contact value.
  Future<void> appendInsurance({
    required String employeeId,
    required String insuranceName,
    required String policyNumber,
    required String providerContact,
  }) async {
    final employeeRef = _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .doc(employeeId);
    final detailsRef = _firestore
        .collection(HrEmployeeApiConstants.insuranceDetailsPath)
        .doc(employeeId);
    await _firestore.runTransaction((transaction) async {
      final employeeSnapshot = await transaction.get(employeeRef);
      if (!employeeSnapshot.exists) throw StateError('employee-not-found');
      final detailsSnapshot = await transaction.get(detailsRef);
      final employee =
          NewEmployeeModelHistory.fromMap(employeeSnapshot.data()!);
      employee.insuranceName.add(insuranceName);
      employee.insurancePolicyNumber.add(policyNumber);
      final details = detailsSnapshot.exists
          ? EmployeeInsuranceDetailsModel.fromMap(detailsSnapshot.data()!)
          : EmployeeInsuranceDetailsModel(
              employeeId: employeeId,
              timestamps: const [],
              providerContact: const []);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      transaction.update(employeeRef, {
        'Insurance_Name': employee.insuranceName,
        'Insurance_Policy_Number': employee.insurancePolicyNumber,
      });
      transaction.set(
          detailsRef,
          EmployeeInsuranceDetailsModel(
            employeeId: employeeId,
            timestamps: [...details.timestamps, timestamp],
            providerContact: [...details.providerContact, providerContact],
          ).toMap());
    });
  }
}
