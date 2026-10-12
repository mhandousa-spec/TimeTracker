// ***************************** FILE INFO ***************************** //
// File Name: shift_assignments_remote_data_source.dart
// Purpose: Reads and batch-writes employee shift assignments in Firestore.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/models/query_data_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';
import '../../../data/models/shift_assignment_model.dart';

/// Provides the Firestore boundary for employee shift assignments.
class ShiftAssignmentsRemoteDataSource {
  /// Method Name: [getAssignments]
  ///
  /// Purpose: Loads all stored employee shift assignments.
  ///
  /// Returns: Assignment models or a Firebase failure.
  Future<Either<FirebaseFailure, List<ShiftAssignmentModel>>>
      getAssignments() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrApiConstants.collectionPath,
    );
    return result.fold(
      Left.new,
      (data) => Right(
        (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(ShiftAssignmentModel.fromMap)
            .toList(),
      ),
    );
  }

  /// Method Name: [createAssignments]
  ///
  /// Purpose: Atomically creates or merges assignments for selected employees.
  ///
  /// Parameters:
  /// - [assignments]: Assignment documents to write.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> createAssignments(
    List<ShiftAssignmentModel> assignments,
  ) async {
    final requests = assignments
        .map(
          (assignment) => QueryDataModel(
            documentId: assignment.id,
            collectionPath: HrApiConstants.collectionPath,
            queryData: assignment.toMap(),
          ),
        )
        .toList();
    final Either<FirebaseFailure, void> result =
        await FirebaseRepository.setMultipleDocuments(
      queryDataModels: requests,
    );
    return result;
  }

  /// Method Name: [updateAssignments]
  ///
  /// Purpose: Atomically persists assignment documents containing appended
  /// tracking revisions.
  ///
  /// Parameters:
  /// - [assignments]: Existing employee assignment documents to update.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> updateAssignments(
    List<ShiftAssignmentModel> assignments,
  ) {
    return createAssignments(assignments);
  }
}
