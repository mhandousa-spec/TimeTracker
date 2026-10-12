/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: hr_work_setup_remote_data_source.dart
/// Purpose: Declares `HrWorkSetupRemoteDataSource` — READ-ONLY access to the
///          HR module's Shifts, Shift_Assignments and Locations collections.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decisions 4, 12–14 (8/10/2026): when the company has HR, HR owns
/// shifts, locations and assignments; Time Tracker only reads them. Paths come
/// from `TimeTrackerFirestorePaths.hr*` (built from `HrApiConstants` names).
/// Nothing here ever writes. Same empty-company guard as the module's own
/// data source. Throws on failure (no try/catch — repository's job).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

class HrWorkSetupRemoteDataSource {
  HrWorkSetupRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String relativePath) {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the HR '
        'path "$relativePath" cannot be resolved.',
      );
    }
    return _firestore.collection(getBaseUrl(relativePath));
  }

  Future<List<TimeTrackerDocument>> _all(String relativePath) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _collection(relativePath).get();
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              TimeTrackerDocument(id: d.id, data: d.data()),
        )
        .toList(growable: false);
  }

  Future<TimeTrackerDocument?> _one(String relativePath, String id) async {
    if (id.trim().isEmpty || id.contains('/')) return null;
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collection(relativePath).doc(id).get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return TimeTrackerDocument(id: snapshot.id, data: data);
  }

  /// Function Name: [fetchShifts]
  ///
  /// Purpose: Every `Modules/hr/Shifts` document.
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchShifts() =>
      _all(TimeTrackerFirestorePaths.hrShifts);

  /// Function Name: [fetchShift]
  ///
  /// Purpose: One `Modules/hr/Shifts/{shiftId}` document, or null.
  ///
  /// Return type: [Future<TimeTrackerDocument?>]
  Future<TimeTrackerDocument?> fetchShift(String shiftId) =>
      _one(TimeTrackerFirestorePaths.hrShifts, shiftId);

  /// Function Name: [fetchShiftAssignment]
  ///
  /// Purpose: `Modules/hr/Shift_Assignments/{employeeId}`, or null.
  ///
  /// Return type: [Future<TimeTrackerDocument?>]
  Future<TimeTrackerDocument?> fetchShiftAssignment(String employeeId) =>
      _one(TimeTrackerFirestorePaths.hrShiftAssignments, employeeId);

  /// Function Name: [fetchLocations]
  ///
  /// Purpose: Every `Modules/hr/Locations` document (empty today — HR still
  /// hard-codes its locations).
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchLocations() =>
      _all(TimeTrackerFirestorePaths.hrLocations);

  /// Function Name: [fetchLocation]
  ///
  /// Purpose: One `Modules/hr/Locations/{id}` document, or null.
  ///
  /// Return type: [Future<TimeTrackerDocument?>]
  Future<TimeTrackerDocument?> fetchLocation(String locationId) =>
      _one(TimeTrackerFirestorePaths.hrLocations, locationId);
}
