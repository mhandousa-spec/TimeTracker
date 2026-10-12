/// Module: todo / domain / constants
///
///*************************** FILE INFO ****************************///
/// File Name: todo_firestore_paths.dart
/// Purpose: Declares `TodoFirestorePaths` — every collection path the To-Do
///          module reads or writes, relative to the company root.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// All paths go through `getBaseUrl(...)`, i.e. `Demo/{companyId}/<path>`.
/// The legacy `Creating_Task` collection is NOT read (owner decision
/// 7/10/2026 — start on a fresh schema).
///
/// PER-USER LAYOUT (owner-approved 7/10/2026): to-dos are personal, so each
/// user's data lives under their own folder keyed by their email (trimmed +
/// lower-cased; emails never change, so it is a stable key — NOT the
/// employee id):
///
///   Demo/{companyId}/Modules/todo/{email}/{todoId}
///   Demo/{companyId}/Modules/todo_notification_log/{email}/{id}
///
/// Owner rule (8/10/2026): in the Firebase console it must be
/// Modules → todo → {email} → the to-dos, with no extra click — so the
/// email IS the collection (no `Employees/{email}/Todos` level). The older
/// `Modules/todo/Todos` and `Modules/todo/Employees/...` layouts are
/// abandoned (not read; the owner deletes them in the console).

class TodoFirestorePaths {
  const TodoFirestorePaths._();

  /// The `todo` document; each user's to-dos are a collection under it,
  /// named by their email.
  static const String root = 'Modules/todo';

  /// The document holding each user's notification-log collection.
  static const String notificationLogRoot = 'Modules/todo_notification_log';

  /// Function Name: [emailKey]
  ///
  /// Purpose: The folder key for [email] — trimmed and lower-cased. Refuses an
  /// empty email (or one containing `/`, which would split the path), so a
  /// write can never land on an unscoped collection.
  ///
  /// Parameters:
  ///   [String] email: the signed-in user's email.
  ///
  /// Return type: [String]
  static String emailKey(String email) {
    final String key = email.trim().toLowerCase();
    if (key.isEmpty) {
      throw StateError(
        'No signed-in email — the per-user to-do path cannot be resolved.',
      );
    }
    if (key.contains('/')) {
      throw StateError('Invalid email for a to-do path: "$key".');
    }
    return key;
  }

  /// Function Name: [todosOf]
  ///
  /// Purpose: `Modules/todo/{email}` — one doc per to-do.
  ///
  /// "Indexed history" documents (owner rule 7/10/2026): EVERY field is a
  /// list and the doc carries `timestamps` (`List<Timestamp>`); each write
  /// appends one entry to every field, so index i = state at timestamps[i]
  /// and the last element is current. Fields: `To_Do_Id`, `To_Do_Name`,
  /// `Description`, `Priority_Level`, `Is_Completed`, `Completion_Date`,
  /// `Is_Deleted`, `Deletion_Date`, `Is_Scheduled`, `Start_Date_Time`,
  /// `Due_Date_Time`, `Reminders`, `Is_Recurring`, `Recurrence`,
  /// `Checklist_Items`, `Creation_Date`, `timestamps`. List-valued fields
  /// store each entry as `{Values: [...]}` (Firestore forbids arrays directly
  /// inside arrays). The owner is the folder, so there is no owner /
  /// creator / modifier field and no owner query.
  ///
  /// Parameters:
  ///   [String] email: the owner (see [emailKey]).
  ///
  /// Return type: [String] — throws `StateError` on an empty email.
  static String todosOf(String email) => '$root/${emailKey(email)}';

  /// Function Name: [notificationLogOf]
  ///
  /// Purpose: `Modules/todo_notification_log/{email}` — one marker
  /// per notification already sent (`{todoId}__{event}__{dueMs}`), so the
  /// client-side reminder sweep never sends the same reminder twice. Same
  /// history shape (`To_Do_Id`, `Event_Key`, `Due_Date_Millis`, `Sent_Date`,
  /// `timestamps` as `Timestamp`s), written once.
  ///
  /// Parameters:
  ///   [String] email: the owner (see [emailKey]).
  ///
  /// Return type: [String] — throws `StateError` on an empty email.
  static String notificationLogOf(String email) =>
      '$notificationLogRoot/${emailKey(email)}';

  /// `Demo/{companyId}/todo_module_permissions/{roleId}` — the role grants.
  /// Must match the admin app's `<module>_module_permissions` naming.
  static const String rolePermissions = 'todo_module_permissions';
}
