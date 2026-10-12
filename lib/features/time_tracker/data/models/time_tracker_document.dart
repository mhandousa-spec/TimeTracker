/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_document.dart
/// Purpose: Declares `TimeTrackerDocument` — one raw Firestore document (id +
///          data) as it travels from the data sources to the models.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Keeps `DocumentSnapshot` inside the data sources, so the repositories and
/// their tests only deal with plain maps.

class TimeTrackerDocument {
  const TimeTrackerDocument({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;
}
