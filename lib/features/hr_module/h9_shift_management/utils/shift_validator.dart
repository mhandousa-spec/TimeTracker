// ***************************** FILE INFO ***************************** //
// File Name: shift_validator.dart
// Purpose: Validates HR shift values and location relationships.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import '../data/models/branch_model.dart';
import '../data/models/shift_model.dart';
import '../domain/entity/shift_entity.dart';

/// Defines validation codes for Shift Management form errors.
enum ShiftValidationError {
  locationRequired,
  branchRequired,
  invalidLocation,
  invalidBranch,
  branchLocationMismatch,
  startTimeInvalid,
  endTimeInvalid,
  duplicateWorkingHours,
}

/// Provides feature-specific validation for recurring shifts.
abstract final class ShiftValidator {
  /// Method Name: [validate]
  ///
  /// Purpose: Validates shift relationships and time boundaries.
  ///
  /// Parameters:
  /// - [shift]: Shift values to validate.
  /// - [locationIds]: Available location IDs.
  /// - [branches]: Available branch records.
  ///
  /// Returns: A validation code, or null when the shift is valid.
  static ShiftValidationError? validate({
    required ShiftModel shift,
    required Iterable<String> locationIds,
    required Iterable<BranchModel> branches,
    Iterable<ShiftModel> existingShifts = const [],
    String? excludedShiftId,
  }) {
    if (shift.locationId.trim().isEmpty) {
      return ShiftValidationError.locationRequired;
    }
    if (shift.branchId.trim().isEmpty) {
      return ShiftValidationError.branchRequired;
    }
    if (!locationIds.contains(shift.locationId)) {
      return ShiftValidationError.invalidLocation;
    }
    final branch = _findBranch(branches, shift.branchId);
    if (branch == null) return ShiftValidationError.invalidBranch;
    if (branch.locationId != shift.locationId) {
      return ShiftValidationError.branchLocationMismatch;
    }
    if (!isValidMinutes(shift.startMinutes)) {
      return ShiftValidationError.startTimeInvalid;
    }
    if (!isValidMinutes(shift.endMinutes)) {
      return ShiftValidationError.endTimeInvalid;
    }
    if (hasDuplicateWorkingHours(
      shift: shift,
      existingShifts: existingShifts,
      excludedShiftId: excludedShiftId,
    )) {
      return ShiftValidationError.duplicateWorkingHours;
    }
    return null;
  }

  /// Method Name: [hasDuplicateWorkingHours]
  ///
  /// Purpose: Detects another shift with the same working hours.
  ///
  /// Parameters:
  /// - [shift]: Shift being created or edited.
  /// - [existingShifts]: Persisted shifts to compare.
  /// - [excludedShiftId]: Current shift ID when editing.
  ///
  /// Returns: True when another matching shift already exists.
  static bool hasDuplicateWorkingHours({
    required ShiftModel shift,
    required Iterable<ShiftModel> existingShifts,
    String? excludedShiftId,
  }) {
    return existingShifts.any((existingShift) {
      final isAnotherShift = existingShift.id != excludedShiftId;
      return isAnotherShift &&
          existingShift.startMinutes == shift.startMinutes &&
          existingShift.endMinutes == shift.endMinutes;
    });
  }

  /// Method Name: [isValidMinutes]
  ///
  /// Purpose: Checks whether a time value is within one calendar day.
  ///
  /// Parameters:
  /// - [minutes]: Minutes from midnight.
  ///
  /// Returns: True for values from 0 through 1439.
  static bool isValidMinutes(int minutes) {
    return minutes >= 0 && minutes < ShiftEntity.minutesPerDay;
  }

  static BranchModel? _findBranch(
    Iterable<BranchModel> branches,
    String branchId,
  ) {
    for (final branch in branches) {
      if (branch.id == branchId) return branch;
    }
    return null;
  }
}
