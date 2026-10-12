/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_dashboard_remote_data_source.dart
/// Purpose: Declares `TimeTrackerDashboardRemoteDataSource` — the read-only
///          Firestore queries of the HR dashboard: a document-id RANGE of a
///          collection (many employees' attendance, one range each) and a
///          whole set-up collection (assignments, shifts, locations).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Separate from `TimeTrackerRemoteDataSource` (which owns every write) so
/// that class and its test double stay unchanged. Paths are relative to the
/// company root (`Demo/{cid}/…`, `getBaseUrl`) and refused while no company
/// is signed in (same guard as the other data sources). Throws on failure;
/// the repository turns throws into clean messages, so there is no
/// try/catch here.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';

class TimeTrackerDashboardRemoteDataSource {
  TimeTrackerDashboardRemoteDataSource({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _collection(String relativePath) {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'Time Tracker path "$relativePath" cannot be resolved.',
      );
    }
    return _firestore.collection(getBaseUrl(relativePath));
  }

  static List<TimeTrackerDocument> _documents(QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
      .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => TimeTrackerDocument(id: d.id, data: d.data()))
      .toList(growable: false);

  /// Function Name: [fetchIdRange]
  ///
  /// Purpose: One-shot read of the documents of [relativePath] whose id is
  /// between [firstId] and [lastId] (both included, lexicographic — e.g.
  /// `{email}_2026-10-01` … `{email}_2026-10-31`).
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchIdRange(
    String relativePath, {
    required String firstId,
    required String lastId,
  }) async =>
      _documents(
        await _collection(relativePath)
            .orderBy(FieldPath.documentId)
            .startAt(<Object>[firstId])
            .endAt(<Object>[lastId])
            .get(),
      );

  /// Function Name: [fetchCollection]
  ///
  /// Purpose: One-shot read of every document of [relativePath].
  ///
  /// Return type: [Future<List<TimeTrackerDocument>>]
  Future<List<TimeTrackerDocument>> fetchCollection(String relativePath) async =>
      _documents(await _collection(relativePath).get());
}
