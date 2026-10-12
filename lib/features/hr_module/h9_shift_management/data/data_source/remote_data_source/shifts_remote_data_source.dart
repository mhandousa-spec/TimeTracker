// ***************************** FILE INFO ***************************** //
// File Name: shifts_remote_data_source.dart
// Purpose: Reads and writes Shift Management records in Firestore.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../../../../../../core/services/firebase/repository/firebase_repository.dart';
import '../../../data/models/shift_model.dart';
import '../../../../../../core/helper/hr/hr_api_constants.dart';

/// Provides the Firestore boundary for shift records.
class ShiftsRemoteDataSource {
  /// Method Name: [getShifts]
  ///
  /// Purpose: Loads all persisted shifts.
  ///
  /// Returns: Shift models or a Firebase failure.
  Future<Either<FirebaseFailure, List<ShiftModel>>> getShifts() async {
    final result = await FirebaseRepository.getCollection(
      collectionPath: HrApiConstants.shiftsPath,
    );
    return result.fold(
      Left.new,
      (data) => Right(
        (data as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(ShiftModel.fromMap)
            .toList(),
      ),
    );
  }

  /// Method Name: [createShift]
  ///
  /// Purpose: Persists one shift under a generated stable document ID.
  ///
  /// Parameters:
  /// - [shift]: Shift record to persist.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> createShift(ShiftModel shift) async {
    final Either<FirebaseFailure, void> result =
        await FirebaseRepository.setDocumentWithId(
      collection: HrApiConstants.shiftsPath,
      documentId: shift.id,
      data: shift.toMap(),
    );
    return result;
  }

  /// Method Name: [appendShiftRevision]
  ///
  /// Purpose: Replaces one shift document with its appended revision history.
  ///
  /// Parameters:
  /// - [shift]: Shift containing the complete revision history.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> appendShiftRevision(
    ShiftModel shift,
  ) {
    return createShift(shift);
  }
}
