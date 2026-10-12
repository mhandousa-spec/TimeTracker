// ***************************** FILE INFO ***************************** //
// File Name: department_locations_remote_data_source.dart
// Purpose: Persists Department location records in Firestore.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../models/department_location_model.dart';

/// Provides the Firestore boundary for Department locations.
class DepartmentLocationsRemoteDataSource {
  /// Method Name: [getLocations]
  ///
  /// Purpose: Loads all persisted locations from the active tenant's HR path.
  ///
  /// Returns: Location models or the Firebase failure returned by the gateway.
  Future<Either<FirebaseFailure, List<DepartmentLocationModel>>>
      getLocations() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrApiConstants.locationsPath,
    );
    return result.fold(
      Left.new,
      (data) => Right(
        (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(DepartmentLocationModel.fromMap)
            .toList(),
      ),
    );
  }

  /// Method Name: [createLocation]
  ///
  /// Purpose: Saves one location under the active tenant's HR module path.
  ///
  /// Parameters:
  /// - [location]: Location record with its generated document ID.
  ///
  /// Returns: Success or the Firebase failure returned by the shared gateway.
  Future<Either<FirebaseFailure, void>> createLocation(
    DepartmentLocationModel location,
  ) async {
    return await FirebaseRepository.setDocumentWithId(
      collection: HrApiConstants.locationsPath,
      documentId: location.id,
      data: location.toMap(),
    );
  }
}
