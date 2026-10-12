/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_work_setup_source.dart
/// Purpose: Declares `TimeTrackerWorkSetupSource` — `WorkSetupSource` for a
///          company WITHOUT HR: Time Tracker's own Locations +
///          Location_Assignments.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 13 (8/10/2026): without HR there are no shifts — the
/// location's Work Start / End Time + Working Days are the schedule, for
/// everyone at that location. The assignment's own rules (break / pause /
/// different location — set in the Grant Access dialog) apply to the person;
/// a group writes the same rules into its members' assignments, so the
/// assignment is the single answer (STATUS.md assumption A7).
/// Updated: 9/10/2026 - owner decision 33: the rules are RESOLVED at read
/// time (`EffectiveRulesResolver`: employee custom → the group's custom
/// rules (its `Groups` doc is read) → the location's), so a location edit
/// applies to everyone who follows it at once.

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';

class TimeTrackerWorkSetupSource implements WorkSetupSource {
  TimeTrackerWorkSetupSource({required TimeTrackerRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final TimeTrackerRemoteDataSource _remote;

  @override
  WorkSetupOwner get owner => WorkSetupOwner.timeTracker;

  @override
  Future<List<WorkLocation>> loadLocations() async {
    try {
      final List<TimeTrackerDocument> docs =
          await _remote.fetchCollection(TimeTrackerFirestorePaths.locations);
      return List<WorkLocation>.unmodifiable(
        docs
            .map((TimeTrackerDocument d) => WorkLocationModel.fromMap(d.id, d.data))
            .where((WorkLocation l) => l.isActive),
      );
    } catch (error) {
      throw _clean(error, 'load the locations');
    }
  }

  @override
  Future<EmployeeWorkSetup?> loadWorkSetup({
    required String employeeEmail,
    required String employeeId,
  }) async {
    try {
      final TimeTrackerDocument? assignmentDoc = await _remote.fetchDocument(
        TimeTrackerFirestorePaths.locationAssignments,
        TimeTrackerFirestorePaths.emailKey(employeeEmail),
      );
      if (assignmentDoc == null) return null;
      final LocationAssignment assignment = LocationAssignmentModel.fromMap(
        assignmentDoc.id,
        assignmentDoc.data,
      );
      if (!assignment.isAssigned) return null;
      final TimeTrackerDocument? locationDoc = await _remote.fetchDocument(
        TimeTrackerFirestorePaths.locations,
        assignment.locationId,
      );
      if (locationDoc == null) return null;
      final WorkLocation location =
          WorkLocationModel.fromMap(locationDoc.id, locationDoc.data);
      if (!location.isActive) return null;
      EmployeeGroup? group;
      if (assignment.groupId.isNotEmpty && !assignment.rules.isCustom) {
        final TimeTrackerDocument? groupDoc =
            await _remote.fetchDocument(TimeTrackerFirestorePaths.groups, assignment.groupId);
        if (groupDoc != null) group = EmployeeGroupModel.fromMap(groupDoc.id, groupDoc.data);
      }
      final EffectiveRules effective =
          EffectiveRulesResolver.resolve(location: location, assignment: assignment, group: group);
      return EmployeeWorkSetup(
        owner: owner,
        location: location,
        schedule: location.schedule,
        rules: effective.rules,
        startDate: assignment.startDate,
        rulesSource: effective.source,
      );
    } catch (error) {
      throw _clean(error, 'load your work set-up');
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
