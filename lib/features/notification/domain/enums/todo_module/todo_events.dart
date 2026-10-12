/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: todo_events.dart
/// Purpose: Notification event catalog: todo events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: todo_events.dart
/// Module:    To-Do List
/// Purpose:   Every notification this module can raise, with its default
///            bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation".
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/<module>_<key>`
/// from Firestore first, so any text an admin edits in Notification
/// Control still wins. Editing this file changes the fallback + the
/// "Reset to default" value.
///
/// RULE: never write an event key as a raw string. Use this enum.

import '../notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

enum TodoNotificationEvent implements NotificationEvent {
  toDoReminder(
    key: 'to_do_reminder',
    group: '',
    titleEn: 'Task Reminder',
    titleAr: 'تذكير بالمهمة',
    bodyEn: 'This is a scheduled reminder for {{toDoName}}. Please ensure the task is completed within the designated timeframe in accordance with your planned schedule.',
    bodyAr: 'هذا تذكير مجدول بالمهمة {{toDoName}}. يرجى التأكد من إنجاز المهمة ضمن الإطار الزمني المحدد وفقاً للجدول الزمني المخطط.',
    variables: {TemplateVariable.toDoName},
  ),
  taskOverdue(
    key: 'task_overdue',
    group: '',
    titleEn: 'Task Overdue — Immediate Action Required',
    titleAr: 'المهمة متأخرة — مطلوب إجراء فوري',
    bodyEn: '{{toDoName}} has exceeded its scheduled completion date and is now overdue. Please address this task as a priority and ensure it is completed or escalated without further delay.',
    bodyAr: 'تجاوزت المهمة {{toDoName}} تاريخ الإنجاز المجدول وأصبحت متأخرة. يرجى معالجة هذه المهمة بشكل عاجل وضمان إنجازها أو تصعيدها دون مزيد من التأخير.',
    variables: {TemplateVariable.toDoName},
  ),
  taskNowDue(
    key: 'task_now_due',
    group: '',
    titleEn: 'Task Due — Action Required',
    titleAr: 'موعد تنفيذ المهمة — مطلوب إجراء',
    bodyEn: '{{toDoName}} is now due for completion. Please proceed with the necessary actions to fulfill this task in accordance with your assigned responsibilities.',
    bodyAr: 'حان الآن موعد إنجاز المهمة {{toDoName}}. يرجى المضي في اتخاذ الإجراءات اللازمة لتنفيذ هذه المهمة وفقاً للمسؤوليات المحددة لك.',
    variables: {TemplateVariable.toDoName},
  ),
  scheduledReminderDayBefore(
    key: 'scheduled_reminder_day_before',
    group: '',
    titleEn: 'Upcoming Task — Advance Reminder',
    titleAr: 'تذكير مسبق — مهمة مجدولة غداً',
    bodyEn: 'This is an advance reminder that {{toDoName}} is scheduled for completion tomorrow. Please make the necessary preparations to ensure timely delivery.',
    bodyAr: 'هذا تذكير مسبق بأن المهمة {{toDoName}} مجدولة للإنجاز غداً. يرجى اتخاذ الاستعدادات اللازمة لضمان التسليم في الوقت المحدد.',
    variables: {TemplateVariable.toDoName},
  );

  const TodoNotificationEvent({
    required this.key,
    required this.group,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.variables,
  });

  @override
  final String key;

  /// Sub-section this event belongs to inside the module (may be empty).
  @override
  final String group;

  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String bodyEn;
  @override
  final String bodyAr;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.todo;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static TodoNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
