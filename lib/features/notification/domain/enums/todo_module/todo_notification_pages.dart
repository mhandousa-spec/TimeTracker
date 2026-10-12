/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: todo_notification_pages.dart
/// Module:    To-Do List
/// Purpose:   Target pages a To-Do notification can navigate to (Firestore
///            field `name_of_page`).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Pattern: one `<module>_module/` folder per module holding every enum that
/// module owns (events + pages) — mirrors
/// `knowledge_hub_module/knowledge_hub_notification_pages.dart`.
///
/// Today `NotificationRouting` opens the To-Do module ROOT for every To-Do
/// notification (`AppModule.todo` → `Modules.todo`); there is no To-Do deep
/// link yet, so [todoList] is what every event writes. [todoDetails] is
/// reserved for when a deep link carrying the to-do id is added.
///
/// ⚠️ RULE: never write a page name as a raw string. Always use this enum.
///
/// ⚠️ [key] is stored in Firestore. Renaming a live value orphans the
/// `name_of_page` of every notification already written with it.

enum TodoNotificationPage {
  /// The module home — the personal to-do list (T1).
  todoList('TodoList'),

  /// One to-do's details screen (T3). Not routed yet — see the file header.
  todoDetails('TodoDetails');

  const TodoNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  /// Function Name: [fromKey]
  ///
  /// Purpose: Resolve a stored `name_of_page` back to its enum value.
  ///
  /// Parameters:
  ///   [String] key
  ///
  /// Return type: [TodoNotificationPage?] — null for an unknown key.
  static TodoNotificationPage? fromKey(String key) {
    for (final TodoNotificationPage p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
