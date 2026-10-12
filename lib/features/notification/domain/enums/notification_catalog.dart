/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_catalog.dart
/// Purpose: Notification event catalog: notification catalog.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: notification_catalog.dart
/// Purpose:   THE registry. One place that knows which events exist for
///            which module. Both the Notification Control screen (tabs +
///            rows) and NotificationTemplateService (default / reset
///            templates) read from here, so the two can never drift apart
///            again.
///
/// Adding a notification is now a 2-step job:
///   1. add the value to `<module>_module/<module>_events.dart`
///   2. nothing else — the Control screen and the template defaults pick
///      it up automatically.
///
/// Adding a whole module:
///   1. add it to AppModule
///   2. create `<module>_module/<module>_events.dart`
///   3. register it in `_registry` below.

import './database_module/database_events.dart';
import './grc_module/grc_events.dart';
import './knowledge_hub_module/knowledge_hub_events.dart';
import './messages_module/messages_events.dart';
import './notification_control_module/notification_control_events.dart';
import './qiyas_module/qiyas_events.dart';
import './role_module/role_management_module/role_management_events.dart';
import './services_module/services_events.dart';
import './settings_module/settings_events.dart';
import './time_tracker_module/time_tracker_events.dart';
import './todo_module/todo_events.dart';
import './role_module/user_access_module/user_access_events.dart';
import './role_module/user_management_module/user_management_events.dart';
import './notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';

abstract final class NotificationCatalog {
  static const Map<AppModule, List<NotificationEvent>> _registry = {
    AppModule.knowledgeHub: KnowledgeHubNotificationEvent.values,
    AppModule.todo: TodoNotificationEvent.values,
    AppModule.services: ServicesNotificationEvent.values,
    AppModule.roleManagement: RoleManagementNotificationEvent.values,
    AppModule.userAccess: UserAccessNotificationEvent.values,
    AppModule.userManagement: UserManagementNotificationEvent.values,
    AppModule.timeTracker: TimeTrackerNotificationEvent.values,
    AppModule.database: DatabaseNotificationEvent.values,
    AppModule.qiyas: QiyasNotificationEvent.values,
    AppModule.grc: GrcNotificationEvent.values,
    AppModule.settings: SettingsNotificationEvent.values,
    AppModule.notificationControl:
        NotificationControlNotificationEvent.values,
    // ADDED 2/9/2026. Registering it here is what puts a Messages tab in the
    // Notification Control screen and gives its eleven events default
    // templates — see the "Adding a whole module" note above.
    AppModule.messages: MessagesNotificationEvent.values,
  };

  /// Modules that actually have events — this is what drives the tabs in
  /// the Notification Control screen.
  static List<AppModule> get modules => _registry.keys.toList();

  /// Every event of one module, in spec order.
  static List<NotificationEvent> eventsOf(AppModule module) =>
      _registry[module] ?? const [];

  /// Events of one module bucketed by their `group` sub-section, in spec
  /// order. Events with no group land under the empty key.
  static Map<String, List<NotificationEvent>> groupedEventsOf(
    AppModule module,
  ) {
    final grouped = <String, List<NotificationEvent>>{};
    for (final event in eventsOf(module)) {
      grouped.putIfAbsent(event.group, () => []).add(event);
    }
    return grouped;
  }

  /// Flat list of every event in the app.
  static List<NotificationEvent> get allEvents =>
      _registry.values.expand((e) => e).toList();

  /// Look an event up by module + key — used to resolve a default template
  /// when Firestore has no document yet.
  ///
  /// FIXED 27/9/2026 — matches on the event's OWN `module`, not the registry
  /// bucket it sits in. The nine Settings change-request events report
  /// `AppModule.userManagement` (see `SettingsNotificationEvent.module`, 21/9)
  /// but are registered under `AppModule.settings`, so looking them up in
  /// `eventsOf(userManagement)` found nothing: with no admin template in
  /// Firestore, every change-request notification was dropped with
  /// "no template and no catalog default".
  static NotificationEvent? find({
    required AppModule module,
    required String key,
  }) {
    for (final event in allEvents) {
      if (event.module == module && event.key == key) return event;
    }
    // Fallback: the registry bucket. The Notification Control screen asks by
    // TAB (Settings) for the same events, and must keep finding them.
    for (final event in eventsOf(module)) {
      if (event.key == key) return event;
    }
    return null;
  }

  /// Same, but from the raw strings stored in Firestore.
  static NotificationEvent? findByKeys({
    required String moduleKey,
    required String eventKey,
  }) {
    final module = AppModule.fromKey(moduleKey);
    if (module == null) return null;
    return find(module: module, key: eventKey);
  }

  /// Resolve a full template id (`services_request_submitted`).
  static NotificationEvent? findByTemplateId(String templateId) {
    for (final event in allEvents) {
      if (event.templateId == templateId) return event;
    }
    return null;
  }
}
