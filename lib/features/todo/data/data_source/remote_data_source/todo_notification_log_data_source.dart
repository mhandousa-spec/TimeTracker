/// Module: todo / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: todo_notification_log_data_source.dart
/// Purpose: Declares `TodoNotificationLogDataSource` — Firestore access for
///          the reminder sweep's "already sent" markers under the owner's
///          own `Modules/todo_notification_log/{email}`.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Throws on failure; the repository turns failures into `false` (same split
/// as `TodoRemoteDataSource`, so there is no try/catch here).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_history_codec.dart';
import 'package:knowticed_plus/features/todo/domain/constants/todo_firestore_paths.dart';

class TodoNotificationLogDataSource {
  TodoNotificationLogDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Marker field names. Markers follow the same "indexed history" shape as
  /// every other document (each field a one-entry list + `timestamps` as
  /// `Timestamp`s); a marker is written once and never edited, so its lists
  /// stay length 1. The owner is the `{email}` folder, not a field.
  static const String fTodoId = 'To_Do_Id';
  static const String fEventKey = 'Event_Key';
  static const String fDueMillis = 'Due_Date_Millis';
  static const String fRaisedAt = 'Sent_Date';
  static const String fTimestamps = TodoHistoryCodec.fTimestamps;

  /// `Demo/{companyId}/Modules/todo_notification_log/{email}`.
  /// Refuses to resolve with no company signed in (the path would collapse
  /// to a top-level collection Firestore happily accepts); an empty email
  /// throws `StateError` in `TodoFirestorePaths`.
  CollectionReference<Map<String, dynamic>> _logOf(String ownerEmail) {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(
        'No company is signed in (ApiConstants.baseUri is empty), so the '
        'to-do notification log path cannot be resolved.',
      );
    }
    return _firestore.collection(
      getBaseUrl(TodoFirestorePaths.notificationLogOf(ownerEmail)),
    );
  }

  /// Function Name: [markerId]
  ///
  /// Purpose: The marker document id — `<todoId>__<eventKey>__<dueMillis>`.
  /// The due time is part of the key on purpose: moving a to-do's dates
  /// produces a new key (so the owner is told about the NEW time), while
  /// re-running the sweep against unchanged dates stays silent.
  ///
  /// Parameters:
  ///   [String] todoId
  ///   [String] eventKey
  ///   [int] dueMillis
  ///
  /// Return type: [String]
  static String markerId({
    required String todoId,
    required String eventKey,
    required int dueMillis,
  }) =>
      '${todoId}__${eventKey}__$dueMillis';

  /// Function Name: [claim]
  ///
  /// Purpose: Create the marker if it does not exist yet, atomically (one
  /// transaction: read, then create only when absent). Two devices sweeping
  /// the same to-do at the same second cannot both win.
  ///
  /// Parameters:
  ///   [String] todoId
  ///   [String] eventKey
  ///   [int] dueMillis
  ///   [String] ownerEmail: whose `Notification_Log` folder holds it.
  ///
  /// Return type: [Future<bool>] — true when THIS call created the marker
  /// (the notification is ours to send), false when it already existed.
  Future<bool> claim({
    required String todoId,
    required String eventKey,
    required int dueMillis,
    required String ownerEmail,
  }) {
    final DocumentReference<Map<String, dynamic>> ref = _logOf(ownerEmail).doc(
      markerId(todoId: todoId, eventKey: eventKey, dueMillis: dueMillis),
    );
    return _firestore.runTransaction<bool>((Transaction tx) async {
      final DocumentSnapshot<Map<String, dynamic>> existing = await tx.get(ref);
      if (existing.exists) return false;
      // Client time: `FieldValue.serverTimestamp()` is not allowed inside
      // an array.
      final DateTime now = DateTime.now();
      tx.set(
        ref,
        TodoHistoryCodec.append(
          old: null,
          now: now,
          values: <String, Object?>{
            fTodoId: todoId,
            fEventKey: eventKey,
            fDueMillis: dueMillis,
            fRaisedAt: Timestamp.fromDate(now),
          },
        ),
      );
      return true;
    });
  }
}
