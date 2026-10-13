/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: location_repository_impl.dart
/// Purpose: Declares `LocationRepositoryImpl` — Time Tracker-owned locations
///          in `Modules/time_tracker/Locations/{id}` (no-HR companies).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Delete is a status (`deleted`, STATUS.md assumption A4) so the history and
/// every attendance session pointing at the location stay readable.

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

class LocationRepositoryImpl extends TimeTrackerHistoryRepository<WorkLocation>
    implements LocationBaseRepository {
  LocationRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  static const int _minutesPerDay = 24 * 60;

  @override
  String get collectionPath => TimeTrackerFirestorePaths.locations;

  @override
  String get entityLabel => 'location';

  @override
  WorkLocation decode(TimeTrackerDocument document) =>
      WorkLocationModel.fromMap(document.id, document.data);

  @override
  Map<String, Object?> encode(
    WorkLocation entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      WorkLocationModel.row(entity, id: id, audit: audit);

  @override
  void validate(WorkLocation entity) {
    if (entity.nameEn.trim().isEmpty && entity.nameAr.trim().isEmpty) {
      throw Exception('A location needs a name.');
    }
    if (entity.isGeofenceEnabled &&
        (!entity.hasCoordinates || entity.geofenceRadiusMeters <= 0)) {
      throw Exception('A geofence needs coordinates and a radius.');
    }
    bool inDay(int m) => m >= 0 && m < _minutesPerDay;
    if (!inDay(entity.workStartMinutes) || !inDay(entity.workEndMinutes)) {
      throw Exception('Work start and end must be times of the day.');
    }
    if (entity.workStartMinutes == entity.workEndMinutes) {
      throw Exception('Work start and end cannot be the same time.');
    }
    if (entity.workingDays.isEmpty ||
        entity.workingDays.any((int d) => d < 1 || d > 7)) {
      throw Exception('Choose at least one working day.');
    }
    if (entity.isBreakAllowed && entity.breakMinutes <= 0) {
      throw Exception('Enter the break length.');
    }
  }

  @override
  Stream<List<WorkLocation>> watchLocations() => watchAll();

  @override
  Future<WorkLocation> createLocation({required WorkLocation location}) async =>
      write(location, id: null, mustExist: false, newId: const NewDocId('LOC'));

  @override
  Future<WorkLocation> updateLocation({required WorkLocation location}) async =>
      write(location, id: requireId(location.id), mustExist: true);
}
