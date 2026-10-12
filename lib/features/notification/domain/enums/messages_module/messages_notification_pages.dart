/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: messages_notification_pages.dart
/// Module:    Messages
/// Purpose:   Target pages a Messages notification can navigate to
///            (Firestore field `name_of_page`).
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Pattern: one `<module>_module/` folder per module holding every enum that
/// module owns (events + pages) — mirrors
/// `knowledge_hub_module/knowledge_hub_notification_pages.dart`.
///
/// A messaging notification is only useful if tapping it lands on the
/// conversation it is about, so every event names a screen that can act on it
/// rather than the module home.
///
/// ⚠️ RULE: never write a page name as a raw string. Always use this enum.
///
/// ⚠️ [key] is stored in Firestore. Renaming a live value orphans the
/// `name_of_page` of every notification already written with it.

enum MessagesNotificationPage {
  /// The messaging home — the chat list (M4). Used only where the
  /// notification does not point at one surviving conversation, i.e. after a
  /// group is deleted or the reader is removed from it.
  messagingHome('MessagingHome'),

  /// One direct conversation (M1). The landing page for every direct-message
  /// event.
  chat('Chat'),

  /// One group conversation (M1, group mode). Where a mention, a group
  /// message and a poll are read.
  groupChat('GroupChat'),

  /// The poll's own result view — where a vote is actually inspected.
  pollDetails('PollDetails');

  const MessagesNotificationPage(this.key);

  /// The exact string stored in Firestore (`name_of_page`).
  final String key;

  static MessagesNotificationPage? fromKey(String key) {
    for (final MessagesNotificationPage p in values) {
      if (p.key == key) return p;
    }
    return null;
  }
}
