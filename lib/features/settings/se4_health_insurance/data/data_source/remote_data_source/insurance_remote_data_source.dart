/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: insurance_remote_data_source.dart
/// Purpose: Firestore reads and writes for the insurance document.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N03: moved into the `remote_data_source/` sub-folder.

// PORTED into services_app under features/settings.
// Source: services_app features/employees/data/data_source/remote_data_source/remote_data_source/insurance_remote_data_source.dart
// Imports rewired to the equivalents that already exist in services_app.

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

///*********************** FILE INFO ****************************
/// Purpose: This file contains the remote data source for insurance data
/// Author: Amr Mesbah
/// created At: 20/11/2024
class InsuranceRemoteDataSource {
  Future<Either<FirebaseFailure, dynamic>> getEmployeeInsuranceData(
      {required String employeeId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.insurance, documentId: employeeId);
  }

  Future<Either<FirebaseFailure, dynamic>> addEmployeeInsuranceData(
      {required String documentId, required Map<String, dynamic> data}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.insurance, data: data, documentId: documentId);
  }
}
