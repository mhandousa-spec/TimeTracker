/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_notification_pages.dart
/// Purpose: Notification event catalog: user access notification pages.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO ************************* ///
/// File Name: user_access_notification_pages.dart
/// Purpose: Target pages a notification from the User Access module can
///          navigate to (Firestore field `name_of_page`).
/// Pattern: One `<module>_notification_pages.dart` per module folder,
///          beside that module's event enum.
///
/// Values are the real screen widget names in the feature, so a key can
/// always be traced to a class that exists.
///
/// ⚠️ KNOWN GAP: the notification tap handlers
/// (notification_page / clear_page_notification / pin_notification)
/// currently route by MODULE only - they read `nameOfModule` and ignore
/// `nameOfPage`. These keys are stored correctly but not yet acted on.
/// They are what a future deep-link router will switch over.
///
/// ⚠️ RULE: Never write page names as raw strings. Always use this enum.

enum UserAccessNotificationPage {
  /// The screen AccountStatusNotificationService has always written. Keep this key.
  accountStatusPage('AccountStatusPage'),
  /// Landing list of accounts and their status.
  userAccessHomePage('UserAccessHomePage'),
  ;

  const UserAccessNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static UserAccessNotificationPage? fromKey(String key) {
    for (final p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
