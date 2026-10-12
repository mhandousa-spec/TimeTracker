/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: todo_calendar_events.dart
/// Module:    To-Do List
/// Purpose: Every calendar entry the To-Do module can place on the calendar.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Updated: 7/10/2026 - Owner feedback: `taskDue` added. The DUE date (the
///          to-do's end date) is a "Task Due — Action Required" entry (same
///          wording as the To-Do 'task now due' notification); "Task Scheduled"
///          now covers only the days BEFORE the due date.
///
/// The three To-Do rows of "Knowticed Plus — Notification & Validation" §2
/// (Calendar Event Triggers) plus the owner's Due entry.
/// `calendar_data_service.getTodoCalendarEvents`
/// builds every To-Do card from these through `CalendarEventModel.fromType`;
/// it used to read the legacy `Creating_Task` collection and glue literal
/// English/Arabic strings together.
///
/// To-dos are PERSONAL: every entry is shown to the to-do's owner only.
///
/// ⚠️ NO `{{toDoName}}` PLACEHOLDER. The to-do name is already the card's
/// `taskName`, so repeating it in the body would print it twice, and
/// `CalendarEventModel.fromType` asserts declared variables against the call
/// site.
///
/// Status codes reuse chips that already exist on the calendar screen
/// ('Scheduled', 'Due', 'Overdue', 'Frequency') — filtering is an exact English
/// string compare. Colour is the To-Do entry of `CalendarModulePalette`
/// (0xFF00BCD4) so the card matches the module's dot and chip.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum TodoCalendarEvent implements CalendarEventType {
  taskScheduled(
    key: 'task_scheduled',
    scope: 'Scheduling',
    trigger: 'Task Scheduled',
    titleEn: 'Task Scheduled',
    titleAr: 'تمت جدولة المهمة',
    descriptionEn:
        'This task has been scheduled and is planned to be carried out within the designated start and end dates. Please ensure it is completed within this timeframe.',
    descriptionAr:
        'تمت جدولة هذه المهمة ومن المخطط تنفيذها ضمن تاريخي البدء والانتهاء المحددين. يرجى التأكد من إنجازها ضمن هذا الإطار الزمني.',
    statusCode: 'Scheduled',
    colorValue: 0xFF00BCD4,
    reminderOffsetDays: 0,
    schedulingNote:
        'Shown on every day from the start date up to the day BEFORE the due (end) date of a scheduled to-do, at the start time (clamped to the loaded window). A to-do that starts and is due on the same day has no Scheduled entry — only Task Due. Kept after the to-do is done; hidden once it is deleted.',
  ),

  taskDue(
    key: 'task_due',
    scope: 'Scheduling',
    trigger: 'Task Due',
    titleEn: 'Task Due — Action Required',
    titleAr: 'موعد تنفيذ المهمة — مطلوب إجراء',
    descriptionEn:
        'This task is due on this date. Please complete it by its scheduled end time.',
    descriptionAr:
        'يحين موعد تنفيذ هذه المهمة في هذا التاريخ. يرجى إنجازها قبل وقت الانتهاء المحدد.',
    statusCode: 'Due',
    colorValue: 0xFF00BCD4,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the due (end) date of a scheduled to-do, at the end time, while that end time has not passed or the to-do is done. Once the end time passes and the to-do is not done, Task Overdue replaces it on the same day. Kept after the to-do is done; hidden once it is deleted.',
  ),

  taskOverdue(
    key: 'task_overdue',
    scope: 'Scheduling',
    trigger: 'Task Overdue',
    titleEn: 'Task Overdue — Action Required',
    titleAr: 'المهمة متأخرة — يتطلب اتخاذ إجراء',
    descriptionEn:
        'This task has passed its scheduled end date and has not been completed. Please complete it or update its schedule as soon as possible.',
    descriptionAr:
        'تجاوزت هذه المهمة تاريخ الانتهاء المجدول ولم يتم إنجازها بعد. يرجى إنجازها أو تحديث جدولها في أقرب وقت ممكن.',
    statusCode: 'Overdue',
    colorValue: 0xFF00BCD4,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on the to-do end (due) date once that end time has passed and the to-do is not done (TodoEntity.isOverdue) — instead of Task Due.',
  ),

  recurringTaskReminder(
    key: 'recurring_task_reminder',
    scope: 'Recurrence',
    trigger: 'Recurring Task Occurrence',
    titleEn: 'Recurring Task Reminder',
    titleAr: 'تذكير بالمهمة الدورية',
    descriptionEn:
        'This is a recurring task scheduled to repeat on this date according to its configured frequency. Please complete this occurrence on time.',
    descriptionAr:
        'هذه مهمة دورية مجدولة للتكرار في هذا التاريخ وفقاً للتكرار المحدد لها. يرجى إنجاز هذا التكرار في الوقت المحدد.',
    statusCode: 'Frequency',
    colorValue: 0xFF00BCD4,
    reminderOffsetDays: 0,
    schedulingNote:
        'One entry per day TodoFrequency.occursOn accepts (Daily / Weekly with week days / Monthly), from the recurrence anchor, within the loaded window. For a scheduled to-do the first occurrence is its own start → due span (Task Scheduled / Task Due / Task Overdue), so no recurring entry is placed on any day of that span; every later occurrence day gets one. Not shown for done or deleted to-dos.',
  );

  const TodoCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.schedulingNote,
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final String schedulingNote;
  /// No placeholders — see the file header.
  @override
  Set<TemplateVariable> get variables => const <TemplateVariable>{};

  @override
  AppModule get module => AppModule.todo;

  /// `<module>_<key>` — see [CalendarEventType.id].
  @override
  String get id => '${module.key}_$key';

  /// Function Name: [fromKey]
  ///
  /// Purpose: Resolve a stored key back to its enum value.
  ///
  /// Parameters:
  ///   [String] key
  ///
  /// Return type: [TodoCalendarEvent?]
  static TodoCalendarEvent? fromKey(String key) {
    for (final TodoCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
