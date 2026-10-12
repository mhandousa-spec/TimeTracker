/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: database_notification_pages.dart
/// Purpose: Notification event catalog: database notification pages.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// ************************* FILE INFO ************************* ///
/// File Name: database_notification_pages.dart
/// Purpose: Target pages a notification from the Database Management module
///          can navigate to (Firestore field `name_of_page`).
/// Pattern: One `<module>_notification_pages.dart` per module folder, beside
///          that module's event enum — same shape as
///          `services_notification_pages.dart` and
///          `user_access_notification_pages.dart`.
///
/// Values are the real screen widget names in `lib/features/database/`, so a
/// key stored in Firestore can always be traced back to a class that exists.
/// Every one of these four is a page that actually ships today:
///
///   DatabaseBuilderPage   db1_create_database/presentation/ui/pages/
///   DatabaseDetailsPage   db2_database_details/presentation/ui/pages/
///   DatabaseAccessPage    db2_database_details/presentation/ui/pages/
///   TableAccessPage       db3_create_table/presentation/ui/pages/
///
/// WHY FOUR AND NOT THIRTEEN. There is no page per event. The question a page
/// key answers is "where does tapping this notification take me", and the
/// thirteen database events land on one of exactly four answers: the module
/// landing list, one database's details, that database's access table, or one
/// table's access rule. A key per event would be thirteen strings pointing at
/// four screens, and the first rename would break twelve of them.
///
/// ⚠️ KNOWN GAP (inherited, not introduced here): the notification tap
/// handlers — `notification_page` / `clear_page_notification` /
/// `pin_notification` — route by MODULE only. They read `nameOfModule` and
/// ignore `nameOfPage`. These keys are stored correctly but not yet acted on;
/// they are what a future deep-link router will switch over.
///
/// ⚠️ RULE: Never write page names as raw strings. Always use this enum.

enum DatabaseNotificationPage {
  /// The module landing list — where "a database was created" belongs, because
  /// the recipient may not have a grant on the new record yet.
  databaseBuilderPage('DatabaseBuilderPage'),

  /// One database's details screen, including its table list. Structural news
  /// about a table (created / updated / deleted, a column added, the structure
  /// changed) lands here rather than on the table itself: the deleted case has
  /// no table left to open.
  databaseDetailsPage('DatabaseDetailsPage'),

  /// The Access table on the details screen — the answer to "who has access to
  /// this database", which is what an access grant / revoke / expiry is about.
  databaseAccessPage('DatabaseAccessPage'),

  /// One table's access rule, including its Viewable Fields control.
  tableAccessPage('TableAccessPage'),
  ;

  const DatabaseNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static DatabaseNotificationPage? fromKey(String key) {
    for (final DatabaseNotificationPage p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
