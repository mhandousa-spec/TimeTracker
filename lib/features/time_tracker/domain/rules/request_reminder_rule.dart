/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_reminder_rule.dart
/// Purpose: Declares `RequestReminderRule` — "You Can Only Send A Reminder
///          Once Every 24 Hours" (Figma `661:16796`; owner H3, 13/10/2026:
///          two days → 24 hours).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Only a PENDING request can be reminded about (the Send Reminder button is
/// drawn on Pending cards / details only). The window is a rolling 24 hours
/// from `Last_Reminder_Date_Time`.

import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

class RequestReminderRule {
  const RequestReminderRule._();

  /// Minimum gap between two reminders for the same request.
  static const Duration interval = Duration(hours: 24);

  /// Function Name: [waitLeft]
  ///
  /// Purpose: How long until the next reminder may go (null = it may go
  /// now) — the "You Can Remind Again In 23 h 59 m" countdown.
  ///
  /// Return type: [Duration?]
  static Duration? waitLeft(DateTime? lastReminderAt, DateTime now) {
    final DateTime? next = nextAllowedAt(lastReminderAt);
    if (next == null || !now.isBefore(next)) return null;
    return next.difference(now);
  }

  /// Function Name: [canSend]
  ///
  /// Purpose: Whether a reminder may be sent now.
  ///
  /// Parameters:
  ///   [RequestStatus] status
  ///   [DateTime?] lastReminderAt: null = never reminded.
  ///   [DateTime] now
  ///
  /// Return type: [bool]
  static bool canSend({
    required RequestStatus status,
    required DateTime? lastReminderAt,
    required DateTime now,
  }) {
    if (status != RequestStatus.pending) return false;
    if (lastReminderAt == null) return true;
    return !now.isBefore(lastReminderAt.add(interval));
  }

  /// Function Name: [nextAllowedAt]
  ///
  /// Purpose: The earliest time the next reminder may go (null = now).
  ///
  /// Return type: [DateTime?]
  static DateTime? nextAllowedAt(DateTime? lastReminderAt) =>
      lastReminderAt?.add(interval);
}
