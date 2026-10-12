// ***************************** FILE INFO ***************************** //
// File Name: employee_details_repository.dart
// Purpose: Composes the employee profile and its HR detail documents.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import 'package:knowticed_plus/features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import '../../domain/entity/employee_details_view_data.dart';
import '../data_source/remote_data_source/employee_details_remote_data_source.dart';

/// Repository exposing typed employee-detail data to presentation.
class EmployeeDetailsRepository {
  EmployeeDetailsRepository({EmployeeDetailsRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? EmployeeDetailsRemoteDataSource();

  final EmployeeDetailsRemoteDataSource _remoteDataSource;

  /// Method Name: [getEmployeeDetails]
  ///
  /// Purpose: Combines the selected employee with optional HR documents.
  ///
  /// Parameters:
  /// - [employee]: The already selected employee base profile.
  ///
  /// Returns: Display-ready typed employee details or a Firebase failure.
  Future<Either<FirebaseFailure, EmployeeDetailsViewData>> getEmployeeDetails(
    HrEmployeeEntity employee,
  ) async {
    final employeeId = employee.id?.trim() ?? '';
    if (employeeId.isEmpty) {
      return Right(EmployeeDetailsViewData(employee: employee));
    }

    final result = await _remoteDataSource.getSupplementalData(employeeId);
    return result.map(
      (data) => EmployeeDetailsViewData(
        employee: employee,
        contactDetails: data.contactDetails,
        certificationDetails: data.certificationDetails,
        insuranceDetails: data.insuranceDetails,
        emergencyDetails: data.emergencyDetails,
        attachments: data.attachments,
      ),
    );
  }
}
