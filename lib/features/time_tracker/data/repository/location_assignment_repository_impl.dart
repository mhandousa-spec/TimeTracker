/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: location_assignment_repository_impl.dart
/// Purpose: Declares `LocationAssignmentRepositoryImpl` — employee → location
///          assignments in `Modules/time_tracker/Location_Assignments/{email}`
///          (no-HR companies).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// One document per employee (id = lower-cased email); its history is the
/// Reassign log. Assign creates it, Reassign / Remove append.

import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

class LocationAssignmentRepositoryImpl
    extends TimeTrackerHistoryRepository<LocationAssignment>
    implements LocationAssignmentBaseRepository {
  LocationAssignmentRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.locationAssignments;

  @override
  String get entityLabel => 'assignment';

  @override
  LocationAssignment decode(TimeTrackerDocument document) =>
      LocationAssignmentModel.fromMap(document.id, document.data);

  @override
  Map<String, Object?> encode(
    LocationAssignment entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      LocationAssignmentModel.row(entity, id: id, audit: audit);

  @override
  void validate(LocationAssignment entity) {
    if (entity.rules.isBreakAllowed && entity.rules.breakMinutes <= 0) {
      throw Exception('Enter the break length.');
    }
  }

  @override
  Stream<List<LocationAssignment>> watchAssignments() => watchAll();

  @override
  Future<LocationAssignment> saveAssignment({
    required LocationAssignment assignment,
  }) async =>
      write(
        assignment,
        id: keyOf(
          () => TimeTrackerFirestorePaths.emailKey(assignment.employeeEmail),
        ),
        mustExist: false,
      );
}
