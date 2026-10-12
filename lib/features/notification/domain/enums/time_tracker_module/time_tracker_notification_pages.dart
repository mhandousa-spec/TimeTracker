/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_notification_pages.dart
/// Module:    Time Tracker & Attendance
/// Purpose:   Target pages a Time Tracker notification can navigate to
///            (Firestore field `name_of_page`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Same pattern as `todo_notification_pages.dart`. Every Time Tracker
/// request notification carries the request's id (`Request_Id`); the page
/// says WHICH details View opens:
///   * [requestDetails] — the requester's own Request Details (approved,
///     rejected, canceled…);
///   * [approvalDetails] — the approver's details with Approve / Reject
///     (pending approvals, reminders, cancellation requests).
/// `NotificationRouting.timeTrackerLinkFor` reads it.
/// Updated: 9/10/2026 - phase 6: [mainPage] (time-driven reminders with no
/// request — View opens the module's main page).
///
/// ⚠️ RULE: never write a page name as a raw string. Always use this enum.
///
/// ⚠️ [key] is stored in Firestore. Renaming a live value orphans the
/// `name_of_page` of every notification already written with it.

enum TimeTrackerNotificationPage {
  /// The requester's Request Details.
  requestDetails('TimeTrackerRequestDetails'),

  /// The approver's Approval Details.
  approvalDetails('TimeTrackerApprovalDetails'),

  /// ADDED 9/10/2026 (phase 6) — the module's main page with the Check In /
  /// Check Out control: the missed check-in / check-out reminders. They carry
  /// no `Request_Id`, so View opens the module root.
  mainPage('TimeTrackerMainPage');

  const TimeTrackerNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  /// Function Name: [fromKey]
  ///
  /// Purpose: Resolve a stored `name_of_page` back to its enum value.
  ///
  /// Parameters:
  ///   [String] key
  ///
  /// Return type: [TimeTrackerNotificationPage?] — null for an unknown key.
  static TimeTrackerNotificationPage? fromKey(String key) {
    for (final TimeTrackerNotificationPage p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
