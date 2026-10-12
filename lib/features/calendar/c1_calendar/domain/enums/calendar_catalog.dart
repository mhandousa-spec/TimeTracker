/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_catalog.dart
/// Purpose: THE registry of every calendar event type, per module.
/// Author: Knowticed Plus team
/// Created at: 27/9/2026
///
/// The calendar-side twin of `NotificationCatalog`. `calendar_event_type.dart`
/// has always referred to a "CalendarCatalog" that walks all modules; this is
/// it. Used by the "Apply all modules" demo seeder on Home to write one entry
/// of every type, and by `CalendarDataService.getSeededCalendarEvents` to turn
/// a stored `typeId` back into its enum value.
///
/// Adding a module's calendar enum: create it under `<module>_module/` and
/// register its `.values` in [_registry].

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'calendar_event_type.dart';
import 'grc_module/grc_control_calendar_events.dart';
import 'grc_module/grc_module_calendar_events.dart';
import 'grc_module/grc_policy_calendar_events.dart';
import 'knowledge_hub_module/knowledge_hub_calendar_events.dart';
import 'messages_module/messages_calendar_events.dart';
import 'role_module/role_management_module/role_management_calendar_events.dart';
import 'role_module/user_access_module/user_access_calendar_events.dart';
import 'services_module/services_calendar_events.dart';
import 'settings_module/settings_calendar_events.dart';
import 'todo_module/todo_calendar_events.dart';
// ADDED 9/10/2026 — Time Tracker phase 6.
import 'time_tracker_module/time_tracker_calendar_events.dart';

abstract final class CalendarCatalog {
  static const List<List<CalendarEventType>> _registry = [
    KnowledgeHubCalendarEvent.values,
    ServicesCalendarEvent.values,
    RoleManagementCalendarEvent.values,
    UserAccessCalendarEvent.values,
    SettingsCalendarEvent.values,
    GrcModuleCalendarEvent.values,
    GrcPolicyCalendarEvent.values,
    GrcControlCalendarEvent.values,
    MessagesCalendarEvent.values,
    TodoCalendarEvent.values,
    // ADDED 9/10/2026 — Time Tracker phase 6 (leaves, pending requests,
    // transactions, late / absent days, approvals waiting for me).
    TimeTrackerCalendarEvent.values,
  ];

  /// Every calendar event type in the app.
  static List<CalendarEventType> get allEvents =>
      _registry.expand((e) => e).toList();

  /// Modules that have at least one calendar event type.
  static List<AppModule> get modules =>
      allEvents.map((e) => e.module).toSet().toList();

  /// Every calendar event type of one module.
  static List<CalendarEventType> eventsOf(AppModule module) =>
      allEvents.where((e) => e.module == module).toList();

  /// Resolve a stored `<module>_<key>` id back to its enum value.
  static CalendarEventType? findById(String id) {
    for (final CalendarEventType type in allEvents) {
      if (type.id == id) return type;
    }
    return null;
  }
}
