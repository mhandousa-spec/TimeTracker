/// Module: todo / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: todo_notification_log_repository.dart
/// Purpose: Declares `TodoNotificationLogRepository` — the reminder sweep's
///          "send this once" gate over `TodoNotificationLogDataSource`.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// try/catch lives HERE (MASTER_CODE_REVIEW §11), so the sweeper above it
/// never sees a Firestore exception and never throws to its caller.

import 'package:knowticed_plus/features/todo/data/data_source/remote_data_source/todo_notification_log_data_source.dart';

/// Outcome of one [TodoNotificationLogRepository.claim].
enum TodoClaimResult {
  /// This call created the marker — the notification is ours to send.
  claimed,

  /// The marker already existed — sent earlier (this or another device).
  alreadySent,

  /// The log could not be read or written — do NOT send; retried next sweep.
  failed,
}

class TodoNotificationLogRepository {
  TodoNotificationLogRepository({
    required TodoNotificationLogDataSource dataSource,
  }) : _dataSource = dataSource;

  final TodoNotificationLogDataSource _dataSource;

  /// Function Name: [claim]
  ///
  /// Purpose: Reserve `<todoId>__<eventKey>__<dueMillis>`.
  ///
  /// Fail-closed: if the log cannot be read or written (offline, rules,
  /// no company) the answer is [TodoClaimResult.failed], so the notification
  /// is NOT sent. A sweep that cannot remember what it sent would otherwise
  /// re-send everything on every run; the next run retries instead.
  ///
  /// Parameters:
  ///   [String] todoId
  ///   [String] eventKey
  ///   [int] dueMillis
  ///   [String] ownerEmail
  ///
  /// Return type: [Future<TodoClaimResult>]
  Future<TodoClaimResult> claim({
    required String todoId,
    required String eventKey,
    required int dueMillis,
    required String ownerEmail,
  }) async {
    try {
      final bool created = await _dataSource.claim(
        todoId: todoId,
        eventKey: eventKey,
        dueMillis: dueMillis,
        ownerEmail: ownerEmail,
      );
      return created ? TodoClaimResult.claimed : TodoClaimResult.alreadySent;
    } catch (_) {
      // Unreachable log: do not send (see the doc above). Reported as
      // `failed` so the sweeper can count it; nothing is lost because the
      // next sweep tries the same marker again.
      return TodoClaimResult.failed;
    }
  }
}
