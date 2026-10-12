// ***************************** FILE INFO ***************************** //
// File Name: shift_assignments_repository.dart
// Purpose: Exposes typed employee shift assignment operations.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../data_source/remote_data_source/shift_assignments_remote_data_source.dart';
import '../models/shift_assignment_model.dart';

/// Repository boundary for employee shift assignments.
class ShiftAssignmentsRepository {
  ShiftAssignmentsRepository({
    ShiftAssignmentsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? ShiftAssignmentsRemoteDataSource();

  final ShiftAssignmentsRemoteDataSource _remoteDataSource;

  /// Method Name: [getAssignments]
  ///
  /// Purpose: Retrieves all assignment records.
  ///
  /// Returns: Assignment models or a Firebase failure.
  Future<Either<FirebaseFailure, List<ShiftAssignmentModel>>> getAssignments() {
    return _remoteDataSource.getAssignments();
  }

  /// Method Name: [createAssignments]
  ///
  /// Purpose: Persists selected employee assignments atomically.
  ///
  /// Parameters:
  /// - [assignments]: Assignment records to persist.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> createAssignments(
    List<ShiftAssignmentModel> assignments,
  ) {
    return _remoteDataSource.createAssignments(assignments);
  }

  /// Method Name: [updateAssignments]
  ///
  /// Purpose: Persists existing assignment histories in one batch.
  ///
  /// Parameters:
  /// - [assignments]: Existing documents with appended revisions.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> updateAssignments(
    List<ShiftAssignmentModel> assignments,
  ) {
    return _remoteDataSource.updateAssignments(assignments);
  }
}
