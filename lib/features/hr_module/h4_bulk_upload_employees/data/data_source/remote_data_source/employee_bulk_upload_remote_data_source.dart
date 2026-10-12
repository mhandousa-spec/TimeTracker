// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_remote_data_source.dart
// Purpose: Reads bulk-import lookups and commits employee bundles atomically.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../../../core/network/api_constants.dart';
import '../../../../../roles/r1_role_management/data/models/role_access_model.dart';
import '../../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../../h3_add_employee/utils/employee_submission.dart';
import '../../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../utils/constants/employee_bulk_upload_headers.dart';
import '../../../utils/employee_bulk_upload_failure.dart';
import '../../models/employee_bulk_upload_preflight.dart';
import 'department_conflict_exception.dart';
import 'employee_conflict_exception.dart';

/// Remote lookup and atomic-write boundary for employee bulk import.
class EmployeeBulkUploadRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<EmployeeBulkUploadFailure, EmployeeBulkUploadPreflight>>
      loadPreflightData() async {
    try {
      final results = await Future.wait([
        _firestore.collection(HrEmployeeApiConstants.employeesInfoPath).get(),
        _firestore.collection(ApiConstants.roles).get(),
        _firestore.collection(ApiConstants.departments).get(),
      ]);
      final employees = results[0];
      final roles = results[1];
      final departments = results[2];
      final employeeIds = <String>{};
      final employeeEmails = <String>{};
      for (final document in employees.docs) {
        employeeIds.add(document.id.trim());
        final emailValue = document.data()[EmployeeBulkUploadHeaders.email];
        if (emailValue is List) {
          for (final email in emailValue) {
            final normalized = email.toString().trim().toLowerCase();
            if (normalized.isNotEmpty) employeeEmails.add(normalized);
          }
        }
      }

      final activeRoles = <String>{};
      for (final document in roles.docs) {
        final data = document.data();
        final status = _lastString(data['Status']).toLowerCase();
        if (status.isNotEmpty && status != 'active') continue;
        final roleName = _lastString(
          data['Role_Name'] ?? data['Name'] ?? data['Access_Name'],
        ).toLowerCase();
        if (roleName.isNotEmpty) activeRoles.add(roleName);
      }

      final departmentsById = <String, DepartmentModelPro>{};
      for (final document in departments.docs) {
        final department = DepartmentModelPro.fromMap(document.data());
        final id = department.departmentID?.trim();
        if (id != null && id.isNotEmpty) departmentsById[id] = department;
      }

      return Right(EmployeeBulkUploadPreflight(
        employeeIds: employeeIds,
        employeeEmails: employeeEmails,
        activeRoles: activeRoles,
        departmentsById: departmentsById,
      ));
    } catch (error) {
      return Left(EmployeeBulkPreflightFailure(error.toString()));
    }
  }

  Future<Either<EmployeeBulkUploadFailure, bool>> commitEmployee({
    required EmployeeSubmission submission,
    required UserPermissionModel userAccess,
    DepartmentModelPro? newDepartment,
  }) async {
    try {
      final departmentForCommit = newDepartment;
      final employeeId = submission.employee.id!;
      final employeeRef = _firestore
          .collection(HrEmployeeApiConstants.employeesInfoPath)
          .doc(employeeId);
      final accountOverviewRef = _firestore
          .collection(ApiConstants.demoUsersAccounts)
          .doc(submission.accountOverview.email);
      final departmentRef = departmentForCommit == null
          ? null
          : _firestore
              .collection(ApiConstants.departments)
              .doc(departmentForCommit.departmentID);

      await _firestore.runTransaction((transaction) async {
        final employeeSnapshot = await transaction.get(employeeRef);
        final accountOverviewSnapshot =
            await transaction.get(accountOverviewRef);
        if (employeeSnapshot.exists) {
          throw EmployeeConflictException(employeeSnapshot.id);
        }
        if (accountOverviewSnapshot.exists) {
          throw EmployeeBulkDuplicateEmailFailure(
            'Employee email ${submission.accountOverview.email} already has an account overview.',
          );
        }
        if (departmentRef != null && departmentForCommit != null) {
          final departmentSnapshot = await transaction.get(departmentRef);
          if (departmentSnapshot.exists) {
            final stored =
                DepartmentModelPro.fromMap(departmentSnapshot.data()!);
            if (!_sameDepartment(stored, departmentForCommit)) {
              throw DepartmentConflictException(
                departmentForCommit.departmentID ?? '',
              );
            }
          } else {
            transaction.set(departmentRef, departmentForCommit.toMap());
          }
        }

        final employeeData = submission.employee.toMap()
          ..removeWhere(
            (key, _) => EmployeeEmergencyDetailsModel.legacyMiddleNameKeys
                .contains(key),
          );
        transaction.set(employeeRef, employeeData);
        transaction.set(accountOverviewRef, submission.accountOverview.toMap());
        transaction.set(
          _firestore
              .collection(HrEmployeeApiConstants.contactDetailsPath)
              .doc(employeeId),
          submission.contactDetails.toMap(),
        );
        transaction.set(
          _firestore
              .collection(HrEmployeeApiConstants.certificationsPath)
              .doc(employeeId),
          submission.certificationDetails.toMap(),
        );
        transaction.set(
          _firestore
              .collection(HrEmployeeApiConstants.insuranceDetailsPath)
              .doc(employeeId),
          submission.insuranceDetails.toMap(),
        );
        transaction.set(
          _firestore
              .collection(HrEmployeeApiConstants.emergencyDetailsPath)
              .doc(employeeId),
          submission.emergencyDetails.toMap(),
        );
        transaction.set(
          _firestore
              .collection(HrEmployeeApiConstants.attachmentsPath)
              .doc(employeeId),
          submission.attachments.toMap(),
        );
        transaction.set(
          _firestore.collection(ApiConstants.userAccess).doc(employeeId),
          userAccess.toMap(),
        );
      });
      return const Right(true);
    } on EmployeeConflictException catch (error) {
      return Left(EmployeeBulkDuplicateEmployeeFailure(error.toString()));
    } on EmployeeBulkDuplicateEmailFailure catch (error) {
      return Left(error);
    } on DepartmentConflictException catch (error) {
      return Left(EmployeeBulkDepartmentConflictFailure(error.toString()));
    } catch (error) {
      return Left(EmployeeBulkCommitFailure(error.toString()));
    }
  }

  String _lastString(dynamic value) {
    if (value is List && value.isNotEmpty) return value.last.toString().trim();
    return value?.toString().trim() ?? '';
  }

  bool _sameDepartment(
    DepartmentModelPro stored,
    DepartmentModelPro requested,
  ) {
    return stored.departmentID?.trim() == requested.departmentID?.trim() &&
        stored.departmentName?.trim().toLowerCase() ==
            requested.departmentName?.trim().toLowerCase() &&
        stored.departmentNameInArabic?.trim() ==
            requested.departmentNameInArabic?.trim();
  }
}
