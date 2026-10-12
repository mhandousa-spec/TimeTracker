// ***************************** FILE INFO ***************************** //
// File Name: salary_bulk_upload_remote_data_source.dart
// Purpose: Reads identities and appends synchronized salary histories.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';

/// Firestore boundary for salary workbook operations.
class SalaryBulkUploadRemoteDataSource {
  SalaryBulkUploadRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  /// Method Name: [loadEmployees]
  ///
  /// Purpose: Returns current personal information for identity verification.
  Future<Map<String, HrEmployeeEntity>> loadEmployees() async {
    final snapshot = await _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .get();
    return {
      for (final document in snapshot.docs)
        document.id.trim(): EmployeeEntityController()
            .fromHistoryModel(NewEmployeeModelHistory.fromMap(document.data()))
    };
  }

  /// Method Name: [appendSalary]
  ///
  /// Purpose: Adds a complete visible salary update while carrying hidden fields forward.
  Future<void> appendSalary(
      {required String employeeId,
      required String jobType,
      required String currency,
      required String salary,
      required String daysOff,
      required String startTime,
      required String endTime}) async {
    final employeeRef = _firestore
        .collection(HrEmployeeApiConstants.employeesInfoPath)
        .doc(employeeId);
    await _firestore.runTransaction((transaction) async {
      final employeeSnapshot = await transaction.get(employeeRef);
      if (!employeeSnapshot.exists) {
        throw StateError('employee-not-found');
      }
      final employee = NewEmployeeModelHistory.fromMap(employeeSnapshot.data());
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      employee.timestamps.add(timestamp);
      employee.jobType.add(jobType);
      employee.salary.add(salary);
      employee.currency.add(currency);
      employee.daysOff.add(daysOff);
      employee.startTime.add(startTime);
      employee.endTime.add(endTime);
      transaction.set(employeeRef, employee.toMap());
    });
  }
}
