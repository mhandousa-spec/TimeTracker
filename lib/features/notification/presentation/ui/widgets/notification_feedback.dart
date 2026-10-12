/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_feedback.dart
/// Purpose: (removed) — used to hold the notification pages' snackbars.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
/// Updated: 26/8/2026 — emptied.
///
/// `NotificationFeedback.success` / `.failure` wrapped a
/// `ScaffoldMessenger ..hideCurrentSnackBar() ..showSnackBar(...)` cascade and
/// was called from clear_page_notification.dart, notification_page.dart and
/// pin_notification.dart. All snackbars were removed from the notification
/// feature, so the class has no callers left and is deleted here rather than
/// kept as dead UI code.
///
/// The file itself is kept only so nothing breaks on a stale import; it can be
/// deleted outright — no source in lib/ references it any more.
