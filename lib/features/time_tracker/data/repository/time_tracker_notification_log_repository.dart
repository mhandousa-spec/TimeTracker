/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_notification_log_repository.dart
/// Purpose: Declares `TimeTrackerNotificationLogRepository` — the reminder
///          sweep's "send this once" gate over
///          `Modules/time_tracker/Notification_Log` — and
///          `TimeTrackerNotificationMarker`, one stored marker.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 6 (brief §C), same scheme as To-Do's
/// `TodoNotificationLogRepository`: before a time-driven notification is
/// sent, the marker `{refId}__{eventKey}__{dueMillis}`
/// (`TimeTrackerFirestorePaths.notificationLogDocId`) is CREATED in a
/// transaction; only the call that created it sends. Re-running the sweep —
/// on this device or another — stays silent; a new due time (another day)
/// is a new marker.
///
/// The marker is an indexed-history document like every other Time Tracker
/// document (one row, never edited): `Notification_Log_Id`, `Reference_Id`,
/// `Event_Key`, `Due_Date` (Timestamp), `Due_Date_Millis`,
/// `Receiver_Email` + the audit trio + `timestamps`.
///
/// Fail-closed: when the log cannot be reached the answer is
/// [TimeTrackerClaimResult.failed] and the notification is NOT sent (the
/// next sweep retries). try/catch lives in the base repository (house rule).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

/// Outcome of one [TimeTrackerNotificationLogRepository.claim].
enum TimeTrackerClaimResult {
  /// This call created the marker — the notification is ours to send.
  claimed,

  /// The marker already existed — sent earlier (this or another device).
  alreadySent,

  /// The log could not be read or written — do NOT send; retried next sweep.
  failed,
}

/// One "already sent" marker.
class TimeTrackerNotificationMarker {
  const TimeTrackerNotificationMarker({
    required this.refId,
    required this.eventKey,
    required this.dueAt,
    required this.receiverEmail,
  });

  final String refId;
  final String eventKey;
  final DateTime dueAt;
  final String receiverEmail;
}

class TimeTrackerNotificationLogRepository
    extends TimeTrackerHistoryRepository<TimeTrackerNotificationMarker> {
  TimeTrackerNotificationLogRepository({
    required super.remoteDataSource,
    required super.access,
  });

  static const String fLogId = 'Notification_Log_Id';
  static const String fReferenceId = 'Reference_Id';
  static const String fEventKey = 'Event_Key';
  static const String fDueDate = 'Due_Date';
  static const String fDueMillis = 'Due_Date_Millis';
  static const String fReceiverEmail = 'Receiver_Email';

  @override
  String get collectionPath => TimeTrackerFirestorePaths.notificationLog;

  @override
  String get entityLabel => 'notification log';

  @override
  TimeTrackerNotificationMarker decode(TimeTrackerDocument document) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(document.data, key);
    return TimeTrackerNotificationMarker(
      refId: TimeTrackerFieldCodec.string(now(fReferenceId)),
      eventKey: TimeTrackerFieldCodec.string(now(fEventKey)),
      dueAt: DateTime.fromMillisecondsSinceEpoch(TimeTrackerFieldCodec.integer(now(fDueMillis))),
      receiverEmail: TimeTrackerFieldCodec.string(now(fReceiverEmail)),
    );
  }

  @override
  Map<String, Object?> encode(
    TimeTrackerNotificationMarker entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fLogId: id,
        fReferenceId: entity.refId,
        fEventKey: entity.eventKey,
        fDueDate: Timestamp.fromDate(entity.dueAt),
        fDueMillis: entity.dueAt.millisecondsSinceEpoch,
        fReceiverEmail: entity.receiverEmail.trim().toLowerCase(),
        ...audit.fields,
      };

  /// Function Name: [claim]
  ///
  /// Purpose: Reserve `{refId}__{eventKey}__{dueMillis}` (create-only).
  ///
  /// Parameters:
  ///   [TimeTrackerNotificationMarker] marker
  ///
  /// Return type: [Future<TimeTrackerClaimResult>] — never throws.
  Future<TimeTrackerClaimResult> claim(TimeTrackerNotificationMarker marker) async {
    try {
      final bool created = await createOnly(
        marker,
        id: TimeTrackerFirestorePaths.notificationLogDocId(
          marker.refId,
          marker.eventKey,
          marker.dueAt.millisecondsSinceEpoch,
        ),
      );
      return created ? TimeTrackerClaimResult.claimed : TimeTrackerClaimResult.alreadySent;
    } catch (_) {
      // Unreachable log (offline, rules, no company / user): do not send —
      // a sweep that cannot remember what it sent would repeat itself.
      return TimeTrackerClaimResult.failed;
    }
  }
}
