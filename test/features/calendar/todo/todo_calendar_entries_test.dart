/// Module: test / calendar / todo
///
///*************************** FILE INFO ****************************///
/// File Name: todo_calendar_entries_test.dart
/// Purpose: Unit tests for `CalendarDataService.todoCalendarEntries` — the
///          pure half of the To-Do calendar loader (no Firestore): which
///          cards a to-do raises (Scheduled / Due / Overdue / Recurring), the
///          60-back / 180-ahead window, and the module name / palette key /
///          status codes the calendar screen filters on.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Owner feedback: Scheduled only BEFORE the due date,
///          Due (or Overdue) ON it; recurring skips the to-do's own span.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/calendar_data_service.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/theme/calendar_module_palette.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

void main() {
  // Wednesday 7 Oct 2026, 12:00 — the clock every case is evaluated against.
  final DateTime now = DateTime(2026, 10, 7, 12);

  // The loader formats times with DateFormat('hh:mm a', 'en'); the app
  // initialises locale data at start-up, the test has to do it itself.
  setUpAll(() => initializeDateFormatting('en'));

  List<CalendarEventModel> run(TodoEntity todo, {bool isArabic = false}) =>
      CalendarDataService.todoCalendarEntries(
        todo,
        now: now,
        isArabic: isArabic,
        userEmail: 'owner@x.com',
      );

  TodoEntity todo({
    bool isScheduled = false,
    DateTime? startAt,
    DateTime? endAt,
    bool isDone = false,
    bool isDeleted = false,
    bool hasFrequency = false,
    TodoFrequency frequency = const TodoFrequency(),
    DateTime? createdAt,
    String name = 'Pay rent',
  }) =>
      TodoEntity(
        id: 't1',
        ownerEmail: 'owner@x.com',
        name: name,
        isScheduled: isScheduled,
        startAt: startAt,
        endAt: endAt,
        isDone: isDone,
        isDeleted: isDeleted,
        hasFrequency: hasFrequency,
        frequency: frequency,
        createdAt: createdAt,
      );

  Iterable<CalendarEventModel> ofType(
    List<CalendarEventModel> events,
    TodoCalendarEvent type,
  ) =>
      events.where((CalendarEventModel e) => e.type == type);

  group('Task Scheduled / Task Due', () {
    test('owner example: Mon 09:00 → Wed 17:00 = Scheduled, Scheduled, Due',
        () {
      // 12 Oct 2026 is a Monday.
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 12, 9),
        endAt: DateTime(2026, 10, 14, 17),
      ));
      expect(
        events
            .map((CalendarEventModel e) => '${e.date.day} ${e.time} '
                '${(e.type! as TodoCalendarEvent).name}')
            .toList(),
        <String>[
          '12 09:00 AM taskScheduled',
          '13 09:00 AM taskScheduled',
          '14 05:00 PM taskDue',
        ],
      );
      final CalendarEventModel due = events.last;
      expect(due.taskName, 'Pay rent');
      expect(due.status, 'Due');
      expect(due.requestId, 't1');
      expect(due.userEmail, 'owner@x.com');
      expect(due.description, TodoCalendarEvent.taskDue.descriptionEn);
    });

    test('scheduled cards sit at the start time, due card at the end time',
        () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 10, 9, 30),
        endAt: DateTime(2026, 10, 12, 17),
      ));
      expect(
        ofType(events, TodoCalendarEvent.taskScheduled)
            .map((CalendarEventModel e) => e.date)
            .toList(),
        <DateTime>[DateTime(2026, 10, 10, 9, 30), DateTime(2026, 10, 11, 9, 30)],
      );
      expect(ofType(events, TodoCalendarEvent.taskScheduled).first.time,
          '09:30 AM');
      expect(ofType(events, TodoCalendarEvent.taskDue).single.date,
          DateTime(2026, 10, 12, 17));
      expect(events.length, 3);
    });

    test('start and due on the same day → only the Due card', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 9, 9),
        endAt: DateTime(2026, 10, 9, 18, 45),
      ));
      expect(events, hasLength(1));
      expect(events.single.type, TodoCalendarEvent.taskDue);
      expect(events.single.time, '06:45 PM');
    });

    test('due later today (not yet passed) is Due, not Overdue', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 6, 9),
        endAt: DateTime(2026, 10, 7, 15),
      ));
      expect(ofType(events, TodoCalendarEvent.taskDue), hasLength(1));
      expect(ofType(events, TodoCalendarEvent.taskOverdue), isEmpty);
    });

    test('an unscheduled to-do raises no Scheduled or Due card', () {
      expect(run(todo(endAt: DateTime(2026, 10, 20))), isEmpty);
    });

    test('a done to-do keeps its Scheduled and Due cards', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        isDone: true,
        startAt: DateTime(2026, 10, 1, 8),
        endAt: DateTime(2026, 10, 2, 8),
      ));
      expect(ofType(events, TodoCalendarEvent.taskScheduled).length, 1);
      expect(ofType(events, TodoCalendarEvent.taskDue).single.date,
          DateTime(2026, 10, 2, 8));
      expect(ofType(events, TodoCalendarEvent.taskOverdue), isEmpty);
    });

    test('a range that starts before the window is clamped to it', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 1, 1, 8),
        endAt: DateTime(2026, 8, 10, 8),
        isDone: true,
      ));
      // Window starts 60 days before 7 Oct = 8 Aug → Scheduled 8, 9 Aug and
      // Due 10 Aug.
      expect(ofType(events, TodoCalendarEvent.taskScheduled).length, 2);
      expect(ofType(events, TodoCalendarEvent.taskDue).single.date,
          DateTime(2026, 8, 10, 8));
      expect(events.first.date, DateTime(2026, 8, 8, 8));
    });
  });

  group('Task Overdue', () {
    test('replaces Due on the end date once passed and not done', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 5, 9),
        endAt: DateTime(2026, 10, 6, 14, 15),
      ));
      final List<CalendarEventModel> overdue =
          ofType(events, TodoCalendarEvent.taskOverdue).toList();
      expect(overdue, hasLength(1));
      expect(overdue.single.date, DateTime(2026, 10, 6, 14, 15));
      expect(overdue.single.time, '02:15 PM');
      expect(overdue.single.status, 'Overdue');
      expect(ofType(events, TodoCalendarEvent.taskDue), isEmpty);
      // The day before the due date is still a Scheduled day.
      expect(ofType(events, TodoCalendarEvent.taskScheduled).single.date,
          DateTime(2026, 10, 5, 9));
    });

    test('not raised for a done to-do or a future end', () {
      expect(
        ofType(
          run(todo(endAt: DateTime(2026, 10, 6), isDone: true)),
          TodoCalendarEvent.taskOverdue,
        ),
        isEmpty,
      );
      expect(
        ofType(run(todo(endAt: DateTime(2026, 10, 8))),
            TodoCalendarEvent.taskOverdue),
        isEmpty,
      );
    });

    test('not raised when the end date is older than the window', () {
      expect(run(todo(endAt: DateTime(2026, 5, 1))), isEmpty);
    });
  });

  group('Recurring Task Reminder', () {
    test('daily from the creation date when unscheduled', () {
      final List<CalendarEventModel> events = run(todo(
        hasFrequency: true,
        createdAt: DateTime(2026, 10, 6, 7, 45),
      ));
      final List<CalendarEventModel> recurring =
          ofType(events, TodoCalendarEvent.recurringTaskReminder).toList();
      // 6 Oct → 7 Oct + 180 days (5 Apr 2027) inclusive.
      final int expectedDays = DateTime.utc(2027, 4, 5)
              .difference(DateTime.utc(2026, 10, 6))
              .inDays +
          1;
      expect(recurring.length, expectedDays);
      expect(recurring.first.date, DateTime(2026, 10, 6, 7, 45));
      expect(recurring.first.status, 'Frequency');
    });

    test('skips the first day of a scheduled to-do (its own card covers it)',
        () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        hasFrequency: true,
        startAt: DateTime(2026, 10, 7, 9),
        endAt: DateTime(2026, 10, 7, 10),
        frequency: const TodoFrequency(unit: TodoFrequencyUnit.weekly),
      ));
      final List<DateTime> days = ofType(
        events,
        TodoCalendarEvent.recurringTaskReminder,
      ).map((CalendarEventModel e) => e.date).toList();
      expect(days.first, DateTime(2026, 10, 14, 9));
      expect(days.every((DateTime d) => d.weekday == DateTime.wednesday),
          isTrue);
      expect(ofType(events, TodoCalendarEvent.taskScheduled), isEmpty);
      // 10:00 has passed at 12:00 → Overdue on the day instead of Due.
      expect(ofType(events, TodoCalendarEvent.taskOverdue), hasLength(1));
      expect(ofType(events, TodoCalendarEvent.taskDue), isEmpty);
    });

    test('skips every day of the to-do\'s own start → due span', () {
      final List<CalendarEventModel> events = run(todo(
        isScheduled: true,
        hasFrequency: true,
        startAt: DateTime(2026, 10, 12, 9),
        endAt: DateTime(2026, 10, 14, 17),
      ));
      final List<DateTime> days = ofType(
        events,
        TodoCalendarEvent.recurringTaskReminder,
      ).map((CalendarEventModel e) => e.date).toList();
      // Daily: Mon 12 / Tue 13 / Wed 14 are Scheduled, Scheduled, Due.
      expect(days.first, DateTime(2026, 10, 15, 9));
    });

    test('monthly lands on the anchor day of month', () {
      final List<CalendarEventModel> events = run(todo(
        hasFrequency: true,
        createdAt: DateTime(2026, 9, 15, 10),
        frequency: const TodoFrequency(unit: TodoFrequencyUnit.monthly),
      ));
      final List<DateTime> days = ofType(
        events,
        TodoCalendarEvent.recurringTaskReminder,
      ).map((CalendarEventModel e) => e.date).toList();
      expect(days.first, DateTime(2026, 9, 15, 10));
      expect(days.every((DateTime d) => d.day == 15), isTrue);
    });

    test('not raised for a done to-do', () {
      expect(
        run(todo(
          hasFrequency: true,
          isDone: true,
          createdAt: DateTime(2026, 10, 1),
        )),
        isEmpty,
      );
    });
  });

  test('a deleted to-do raises nothing', () {
    expect(
      run(todo(
        isDeleted: true,
        isScheduled: true,
        hasFrequency: true,
        startAt: DateTime(2026, 10, 1),
        endAt: DateTime(2026, 10, 3),
      )),
      isEmpty,
    );
  });

  test('blank name falls back to the catalog title in the active language',
      () {
    final TodoEntity t = todo(
      name: '  ',
      isScheduled: true,
      startAt: DateTime(2026, 10, 9, 9),
      endAt: DateTime(2026, 10, 9, 10),
    );
    expect(run(t).single.taskName, TodoCalendarEvent.taskDue.titleEn);
    expect(run(t, isArabic: true).single.taskName,
        TodoCalendarEvent.taskDue.titleAr);
  });

  group('calendar screen contract', () {
    late CalendarEventModel card;
    setUp(() {
      card = run(todo(
        isScheduled: true,
        startAt: DateTime(2026, 10, 9, 9),
        endAt: DateTime(2026, 10, 9, 10),
      )).single;
    });

    test("module name is AppModule.todo.labelEn ('To-Do List')", () {
      expect(card.moduleName, AppModule.todo.labelEn);
      expect(card.moduleName, 'To-Do List');
    });

    test('the palette resolves it to the To-Do colour', () {
      expect(CalendarModulePalette.colorOf(card.moduleName),
          CalendarModulePalette.todo);
      expect(CalendarModulePalette.colorOf('قائمة المهام'),
          CalendarModulePalette.todo);
    });

    test('status codes match the calendar status chips', () {
      expect(
        TodoCalendarEvent.values.map((TodoCalendarEvent e) => e.statusCode),
        <String>['Scheduled', 'Due', 'Overdue', 'Frequency'],
      );
    });

    test('Task Due uses the To-Do "task now due" notification wording', () {
      expect(TodoCalendarEvent.taskDue.titleEn, 'Task Due — Action Required');
      expect(TodoCalendarEvent.taskDue.titleAr,
          'موعد تنفيذ المهمة — مطلوب إجراء');
      expect(TodoCalendarEvent.taskDue.colorValue,
          TodoCalendarEvent.taskScheduled.colorValue);
    });
  });
}
