// ***************************** FILE INFO ***************************** //
// File Name: shifts_repository.dart
// Purpose: Exposes typed Shift Management data operations.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:dartz/dartz.dart';

import '../../../../../../core/network/failure_model.dart';
import '../data_source/remote_data_source/shifts_remote_data_source.dart';
import '../models/shift_model.dart';

/// Repository boundary for persisted shift records.
class ShiftsRepository {
  ShiftsRepository({ShiftsRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ShiftsRemoteDataSource();

  final ShiftsRemoteDataSource _remoteDataSource;

  /// Method Name: [getShifts]
  ///
  /// Purpose: Retrieves all persisted shifts.
  ///
  /// Returns: Shift models or a Firebase failure.
  Future<Either<FirebaseFailure, List<ShiftModel>>> getShifts() {
    return _remoteDataSource.getShifts();
  }

  /// Method Name: [createShift]
  ///
  /// Purpose: Persists a new shift.
  ///
  /// Parameters:
  /// - [shift]: Shift to persist.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> createShift(ShiftModel shift) {
    return _remoteDataSource.createShift(shift);
  }

  /// Method Name: [appendShiftRevision]
  ///
  /// Purpose: Persists a shift containing an appended revision.
  ///
  /// Parameters:
  /// - [shift]: Shift with complete revision history.
  ///
  /// Returns: Success or a Firebase failure.
  Future<Either<FirebaseFailure, void>> appendShiftRevision(
    ShiftModel shift,
  ) {
    return _remoteDataSource.appendShiftRevision(shift);
  }
}
