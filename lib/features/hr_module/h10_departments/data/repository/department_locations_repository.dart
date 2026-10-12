// ***************************** FILE INFO ***************************** //
// File Name: department_locations_repository.dart
// Purpose: Exposes typed Department location persistence operations.
// Author: Mohamed Elrashidy
// Created At: 2026-08-27
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../data_source/remote_data_source/department_locations_remote_data_source.dart';
import '../models/department_location_model.dart';
import '../../domain/entity/department_location_entity.dart';

/// Repository boundary for Department location records.
class DepartmentLocationsRepository {
  DepartmentLocationsRepository()
      : _remoteDataSource = DepartmentLocationsRemoteDataSource();

  final DepartmentLocationsRemoteDataSource _remoteDataSource;

  /// Method Name: [getLocations]
  ///
  /// Purpose: Retrieves persisted locations as presentation-safe entities.
  ///
  /// Returns: Location entities or a Firebase failure.
  Future<Either<FirebaseFailure, List<DepartmentLocationEntity>>>
      getLocations() async {
    final result = await _remoteDataSource.getLocations();
    return result.fold(
      Left.new,
      (models) => Right(models.map((model) => model.toEntity()).toList()),
    );
  }

  /// Method Name: [createLocation]
  ///
  /// Purpose: Persists a typed Department location.
  ///
  /// Parameters:
  /// - [location]: Location record to save.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> createLocation(
    DepartmentLocationModel location,
  ) {
    return _remoteDataSource.createLocation(location);
  }
}
