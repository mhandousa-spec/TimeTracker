/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_reminder_rule.dart
/// Purpose: Declares `RequestReminderRule` — "You Can Only Send A Reminder
///          Once Every Two Days" (Figma `661:16796`).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Only a PENDING request can be reminded about (the Send Reminder button is
/// drawn on Pending cards / details only). The window is a rolling 48 hours
/// from `Last_Reminder_Date_Time`.

import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

class RequestReminderRule {
  const RequestReminderRule._();

  /// Minimum gap between two reminders for the same request.
  static const Duration interval = Duration(days: 2);

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
