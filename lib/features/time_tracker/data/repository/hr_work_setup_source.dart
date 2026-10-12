/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: hr_work_setup_source.dart
/// Purpose: Declares `HrWorkSetupSource` — `WorkSetupSource` for a company
///          WITH HR: reads HR Shift Management (Shifts, Shift_Assignments,
///          Locations). Never writes.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decisions 4, 12–14 (8/10/2026). Today's HR data has gaps, filled
/// with documented defaults (STATUS.md open questions Q3/Q4):
///   * HR shifts have no working days → the schedule says "every day" but is
///     flagged `isWorkingWeekKnown: false` (9/10/2026, code review finding
///     1): no absent sweep / missed-check-in reminder / guessed absence for
///     it; vacation days are counted on a fallback week (`RequestEffects`).
///   * HR has no break / pause / different-location rules per employee →
///     pause allowed, no fixed break, and "work elsewhere" decided by the
///     `Work_From_Different_Location` switch alone (the rule is left open).
///   * HR locations are hard-coded in the HR module (no Firestore docs) → a
///     shift's location id without a document is a name-only location with
///     no geofence.

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/hr_work_setup_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/hr_work_setup_mapper.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

class HrWorkSetupSource implements WorkSetupSource {
  HrWorkSetupSource({required HrWorkSetupRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final HrWorkSetupRemoteDataSource _remote;

  /// The rules applied to every HR-assigned employee (see the file header).
  static const AttendanceRules defaultRules = AttendanceRules(
    isPauseAllowed: true,
    isDifferentLocationAllowed: true,
  );

  @override
  WorkSetupOwner get owner => WorkSetupOwner.hr;

  @override
  Future<List<WorkLocation>> loadLocations() async {
    try {
      final List<TimeTrackerDocument> shiftDocs = await _remote.fetchShifts();
      final List<TimeTrackerDocument> locationDocs = await _remote.fetchLocations();
      return HrWorkSetupMapper.locationsFrom(
        locationDocs,
        shiftDocs.map(HrWorkSetupMapper.shiftFrom).toList(growable: false),
      );
    } catch (error) {
      throw _clean(error, 'load the HR locations');
    }
  }

  @override
  Future<EmployeeWorkSetup?> loadWorkSetup({
    required String employeeEmail,
    required String employeeId,
  }) async {
    try {
      final TimeTrackerDocument? assignment =
          await _remote.fetchShiftAssignment(employeeId);
      if (assignment == null) return null;
      final String shiftId = HrWorkSetupMapper.shiftIdOf(assignment);
      final TimeTrackerDocument? shiftDoc = await _remote.fetchShift(shiftId);
      if (shiftDoc == null) return null;
      final HrShift shift = HrWorkSetupMapper.shiftFrom(shiftDoc);
      final TimeTrackerDocument? locationDoc =
          await _remote.fetchLocation(shift.locationId);
      final WorkLocation location = locationDoc != null
          ? HrWorkSetupMapper.locationFrom(locationDoc)
          : WorkLocation(id: shift.locationId, nameEn: shift.locationId);
      return EmployeeWorkSetup(
        owner: owner,
        location: location,
        // 9/10/2026 (code review finding 1): HR shifts store no working
        // days — the week is UNKNOWN, not "every day".
        schedule: WorkSchedule(
          startMinutes: shift.startMinutes,
          endMinutes: shift.endMinutes,
          isWorkingWeekKnown: false,
        ),
        rules: defaultRules,
      );
    } catch (error) {
      throw _clean(error, 'load your HR shift');
    }
  }

  Exception _clean(Object error, String action) {
    if (error is FirebaseException) {
      return Exception('Could not $action (${error.code}).');
    }
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not $action: $error');
  }
}
