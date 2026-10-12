/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_remote_data_source.dart
/// Purpose: Reads and writes the emergency-contact document.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N02/N07: moved into the `remote_data_source/`
///          sub-folder the standard prescribes, given the standard header, and
///          both methods now declare a return type instead of inferring
///          `dynamic`.
///
/// PORTED into services_app under features/settings.
/// Source: services_app features/employees/data/data_source/…

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';

class EmergencyContactRemoteDataSource {
  /// Function Name: [getEmergencyContactData]
  ///
  /// Purpose: Read one employee's emergency-contact document.
  ///
  /// Returns: [Future<Either<Failure, dynamic>>] — the payload is the raw
  ///          document map, mapped to a model by the repository.
  Future<Either<Failure, dynamic>> getEmergencyContactData(
      {required String employeeId}) async {
    return await FirebaseRepository.getDocumentWithId(
        collection: ApiConstants.emergencyContacts, documentId: employeeId);
  }

  /// Function Name: [addEmergencyContactData]
  ///
  /// Purpose: Merge-write one employee's emergency-contact document.
  Future<Either<Failure, dynamic>> addEmergencyContactData(
      {required Map<String, dynamic> data, required String documentId}) async {
    return await FirebaseRepository.setDocumentWithId(
        collection: ApiConstants.emergencyContacts,
        data: data,
        documentId: documentId);
  }
}
