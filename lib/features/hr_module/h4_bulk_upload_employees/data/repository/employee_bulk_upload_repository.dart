// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_repository.dart
// Purpose: Maps and atomically persists validated employee spreadsheet rows.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import '../../../../../core/helper/main_helper/single_value_model.dart';
import '../../../../roles/r1_role_management/data/models/role_access_model.dart';
import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../../roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
import '../../../../roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import '../../../../onboarding/o3_authentication/data/models/demo_user_account_overview.dart';
import '../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../h3_add_employee/data/models/employee_attachments_model.dart';
import '../../../h3_add_employee/data/models/employee_certification_details_model.dart';
import '../../../h3_add_employee/data/models/employee_contact_details_model.dart';
import '../../../h3_add_employee/data/models/employee_emergency_details_model.dart';
import '../../../h3_add_employee/data/models/employee_insurance_details_model.dart';
import '../../../h3_add_employee/utils/employee_submission.dart';
import '../../utils/constants/employee_bulk_upload_headers.dart';
import '../../utils/employee_bulk_upload_failure.dart';
import '../data_source/remote_data_source/employee_bulk_upload_remote_data_source.dart';
import '../models/employee_bulk_upload_preflight.dart';
import '../models/employee_bulk_upload_commit_result.dart';
import '../models/employee_bulk_upload_row.dart';

/// Repository coordinating validation preflight and atomic employee creation.
class EmployeeBulkUploadRepository {
  EmployeeBulkUploadRepository({
    EmployeeBulkUploadRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? EmployeeBulkUploadRemoteDataSource();

  final EmployeeBulkUploadRemoteDataSource _remoteDataSource;

  /// Method Name: [bulkCertificateDocumentUrl]
  ///
  /// Purpose: Keeps certificate files outside the employee bulk-upload
  /// contract; certificate documents are supported only by Create Employee.
  ///
  /// Returns: The intentionally empty certificate URL history value.
  static const List<String> bulkCertificateDocumentUrl = <String>[''];

  Future<Either<EmployeeBulkUploadFailure, EmployeeBulkUploadPreflight>>
      loadPreflightData() => _remoteDataSource.loadPreflightData();

  /// Method Name: [createEmployeesIndividually]
  ///
  /// Purpose: Rechecks the complete workbook before writing, then commits each
  /// employee independently so later row failures do not stop the import.
  ///
  /// Parameters:
  /// - [rows]: Fully validated employee rows in workbook order.
  /// - [newDepartments]: Departments created only with their first employee.
  /// - [editorEmail]: User recorded as the access-record editor.
  ///
  /// Returns: A preflight failure or the aggregate per-employee result.
  Future<Either<EmployeeBulkUploadFailure, EmployeeBulkUploadCommitResult>>
      createEmployeesIndividually({
    required List<EmployeeBulkUploadRow> rows,
    required List<DepartmentModelPro> newDepartments,
    required String editorEmail,
  }) async {
    final latest = await _remoteDataSource.loadPreflightData();
    final preflightFailure = latest.fold<EmployeeBulkUploadFailure?>(
      (failure) => failure,
      (preflight) => _preflightFailure(
        rows: rows,
        newDepartments: newDepartments,
        preflight: preflight,
      ),
    );
    if (preflightFailure != null) return Left(preflightFailure);

    final pendingDepartments = {
      for (final department in newDepartments)
        if (department.departmentID != null)
          department.departmentID!: department,
    };
    final failedEmployees = <EmployeeBulkUploadFailedEmployee>[];
    var createdEmployeeCount = 0;

    for (final row in rows) {
      final departmentId = row.value(EmployeeBulkUploadHeaders.departmentId);
      final department = pendingDepartments[departmentId];
      final now = DateTime.now();
      final result = await _remoteDataSource.commitEmployee(
        submission: _buildSubmission(row, now),
        userAccess: _buildUserAccess(row, now, editorEmail),
        newDepartment: department,
      );
      result.fold(
        (failure) => failedEmployees.add(EmployeeBulkUploadFailedEmployee(
          excelRowNumber: row.excelRowNumber,
          employeeId: row.value(EmployeeBulkUploadHeaders.employeeId),
          email: row.value(EmployeeBulkUploadHeaders.email),
          failure: failure,
        )),
        (_) {
          createdEmployeeCount++;
          if (department != null) pendingDepartments.remove(departmentId);
        },
      );
    }

    return Right(EmployeeBulkUploadCommitResult(
      createdEmployeeCount: createdEmployeeCount,
      failedEmployees: failedEmployees,
    ));
  }

  /// Method Name: [_preflightFailure]
  ///
  /// Purpose: Prevents any write when current employee, role, or department
  /// data conflicts with the fully validated workbook.
  ///
  /// Returns: The first detected safe failure, or null when writing may start.
  EmployeeBulkUploadFailure? _preflightFailure({
    required List<EmployeeBulkUploadRow> rows,
    required List<DepartmentModelPro> newDepartments,
    required EmployeeBulkUploadPreflight preflight,
  }) {
    for (final row in rows) {
      final id = row.value(EmployeeBulkUploadHeaders.employeeId);
      final email = row.value(EmployeeBulkUploadHeaders.email).toLowerCase();
      if (preflight.employeeIds.contains(id)) {
        return EmployeeBulkDuplicateEmployeeFailure('Employee ID $id exists.');
      }
      if (preflight.employeeEmails.contains(email)) {
        return EmployeeBulkDuplicateEmailFailure(
            'Employee email $email exists.');
      }
      final role = row.value(EmployeeBulkUploadHeaders.role).toLowerCase();
      if (role.isNotEmpty && !preflight.activeRoles.contains(role)) {
        return EmployeeBulkRoleLookupFailure(
            'Employee role $role is inactive.');
      }
    }
    for (final department in newDepartments) {
      final id = department.departmentID?.trim();
      final existing = id == null ? null : preflight.departmentsById[id];
      if (existing != null && !_sameDepartment(existing, department)) {
        return EmployeeBulkDepartmentConflictFailure(
            'Department $id conflicts.');
      }
    }
    return null;
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

  EmployeeSubmission _buildSubmission(EmployeeBulkUploadRow row, DateTime now) {
    final timestamp = now.millisecondsSinceEpoch;
    final employeeId = row.value(EmployeeBulkUploadHeaders.employeeId);
    List<String> history(String header) => [row.value(header)];
    const empty = <String>[''];

    final employee = NewEmployeeModelHistory(
      id: employeeId,
      timestamps: [timestamp],
      firstName: history(EmployeeBulkUploadHeaders.firstName),
      middleName: history(EmployeeBulkUploadHeaders.middleName),
      lastName: history(EmployeeBulkUploadHeaders.lastName),
      firstNameInArabic: history(EmployeeBulkUploadHeaders.firstNameArabic),
      middleNameInArabic: history(EmployeeBulkUploadHeaders.middleNameArabic),
      lastNameInArabic: history(EmployeeBulkUploadHeaders.lastNameArabic),
      nationalId: history(EmployeeBulkUploadHeaders.nationalId),
      nationalIdExpirationDate:
          history(EmployeeBulkUploadHeaders.nationalIdExpiration),
      nationality: history(EmployeeBulkUploadHeaders.nationality),
      passport: history(EmployeeBulkUploadHeaders.passport),
      passportExpirationDate:
          history(EmployeeBulkUploadHeaders.passportExpiration),
      email: [row.value(EmployeeBulkUploadHeaders.email).trim().toLowerCase()],
      mobilePhone: [
        MobilePhone(
          phones: [row.mobilePhone.number],
          countryCode: [row.mobilePhone.countryCode],
          countryApp: [
            row.mobilePhone.countryApp.isEmpty
                ? 'EG'
                : row.mobilePhone.countryApp,
          ],
          timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
        ),
      ],
      officePhone: [row.officePhone.number],
      homePhone: [row.homePhone.number],
      extension: history(EmployeeBulkUploadHeaders.extension),
      birthDay: history(EmployeeBulkUploadHeaders.birthDate),
      gender: [row.value(EmployeeBulkUploadHeaders.gender).toLowerCase()],
      country: history(EmployeeBulkUploadHeaders.country),
      province: history(EmployeeBulkUploadHeaders.province),
      city: history(EmployeeBulkUploadHeaders.city),
      postalCode: history(EmployeeBulkUploadHeaders.postalCode),
      street: history(EmployeeBulkUploadHeaders.street),
      maritalStatus: [
        row.value(EmployeeBulkUploadHeaders.maritalStatus).toLowerCase()
      ],
      language: history(EmployeeBulkUploadHeaders.language),
      departmentId: history(EmployeeBulkUploadHeaders.departmentId),
      supervisor: [
        row.value(EmployeeBulkUploadHeaders.supervisor).toLowerCase()
      ],
      role: [row.value(EmployeeBulkUploadHeaders.role).toLowerCase()],
      title: history(EmployeeBulkUploadHeaders.title),
      titleInArabic: history(EmployeeBulkUploadHeaders.titleArabic),
      workLocation: history(EmployeeBulkUploadHeaders.workLocation),
      drivingLicenseId: history(EmployeeBulkUploadHeaders.drivingLicenseId),
      carPlates: [_splitList(row.value(EmployeeBulkUploadHeaders.carPlates))],
      academicHistory: const [{}],
      bio: empty,
      photo: empty,
      skills: const [[]],
      hobbies: const [[]],
      status: const ['active'],
      insuranceName: empty,
      insurancePolicyNumber: empty,
      firstContactFirstName: empty,
      firstContactLastName: empty,
      firstContactRelationship: empty,
      firstContactEmail: empty,
      firstContactPhone: empty,
      firstContactLanguage: empty,
      firstContactCountry: empty,
      firstContactProvince: empty,
      firstContactCity: empty,
      firstContactStreet: empty,
      secondContactFirstName: empty,
      secondContactLastName: empty,
      secondContactRelationship: empty,
      secondContactEmail: empty,
      secondContactPhone: empty,
      secondContactLanguage: empty,
      secondContactCountry: empty,
      secondContactProvince: empty,
      secondContactCity: empty,
      secondContactStreet: empty,
      password: null,
      defaultPassword: null,
      passwordExpirationTime: null,
      passwordExpirationUnit: null,
      firstLogin: null,
      lastLogin: null,
      activationDate: now.toIso8601String(),
      deactivationDate: null,
    );

    return EmployeeSubmission(
      employee: employee,
      accountOverview: DemoUserAccountOverview(
        email: row.value(EmployeeBulkUploadHeaders.email).trim().toLowerCase(),
        companyId: HrEmployeeApiConstants.tenantId,
        isActivated: false,
        demoGranted: null,
        demoActivated: null,
      ),
      contactDetails: EmployeeContactDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        personalEmail: empty,
        homeCountryCode: [row.homePhone.countryCode],
        officeCountryCode: [row.officePhone.countryCode],
      ),
      certificationDetails: EmployeeCertificationDetailsModel(
        employeeId: employeeId,
        timestamps: [Timestamp.fromMillisecondsSinceEpoch(timestamp)],
        institutionName: empty,
        degree: empty,
        fieldOfStudy: empty,
        startDate: empty,
        endDate: empty,
        gradeOrScore: empty,
        certificateId: empty,
        issuingAuthority: empty,
        certificationDocumentUrl: bulkCertificateDocumentUrl,
        notes: empty,
      ),
      insuranceDetails: EmployeeInsuranceDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        providerContact: empty,
      ),
      emergencyDetails: EmployeeEmergencyDetailsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        firstContactFirstNameArabic: empty,
        firstContactLastNameArabic: empty,
        firstContactCountryCode: empty,
        secondContactFirstNameArabic: empty,
        secondContactLastNameArabic: empty,
        secondContactCountryCode: empty,
      ),
      attachments: EmployeeAttachmentsModel(
        employeeId: employeeId,
        timestamps: [timestamp],
        passportDocumentUrl: empty,
        nationalIdFrontUrl: empty,
        nationalIdBackUrl: empty,
        drivingLicenseDocumentUrl: empty,
      ),
    );
  }

  UserPermissionModel _buildUserAccess(
      EmployeeBulkUploadRow row, DateTime now, String editorEmail) {
    final timestamp = Timestamp.fromDate(now);
    return UserPermissionModel(
      employeeId: row.value(EmployeeBulkUploadHeaders.employeeId),
      role: SingleValueModel(
        values: [row.value(EmployeeBulkUploadHeaders.role).toLowerCase()],
        timestamps: [timestamp],
      ),
      fromDate: SingleValueModel(
        values: [DateFormat('MMM dd, yyyy').format(now)],
        timestamps: [timestamp],
      ),
      toDate: SingleValueModel(
        values: [
          DateFormat('MMM dd, yyyy').format(now.add(const Duration(days: 180)))
        ],
        timestamps: [timestamp],
      ),
      editBy: SingleValueModel(
        values: [editorEmail.trim().toLowerCase()],
        timestamps: [timestamp],
      ),
    );
  }

  List<String> _splitList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
