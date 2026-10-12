/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: location_base_repository.dart
/// Purpose: Declares `LocationBaseRepository` — the contract for Time Tracker-owned locations (no-HR companies).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

abstract class LocationBaseRepository {
  /// Function Name: [watchLocations]
  ///
  /// Purpose: Live list of every location (deleted ones included).
  ///
  /// Return type: [Stream<List<WorkLocation>>]
  Stream<List<WorkLocation>> watchLocations();

  /// Function Name: [createLocation]
  ///
  /// Purpose: Persist a new location.
  ///
  /// Parameters:
  ///   [WorkLocation] location: the draft; its id is ignored.
  ///
  /// Return type: [Future<WorkLocation>] — with its new id.
  Future<WorkLocation> createLocation({required WorkLocation location});

  /// Function Name: [updateLocation]
  ///
  /// Purpose: Append the edited location (edit / status / delete).
  ///
  /// Parameters:
  ///   [WorkLocation] location
  ///
  /// Return type: [Future<WorkLocation>] — as stored.
  Future<WorkLocation> updateLocation({required WorkLocation location});
}
