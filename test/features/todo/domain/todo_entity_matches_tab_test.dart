/// Module: test / todo / domain
///
///*************************** FILE INFO ****************************///
/// File Name: todo_entity_matches_tab_test.dart
/// Purpose: Pins `TodoEntity.matchesTab` (which status tab a to-do sits in)
///          and the derived flags behind the coloured chips / card border.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 7, 12);

  TodoEntity todo({
    bool isDone = false,
    DateTime? completedAt,
    bool isDeleted = false,
    bool isScheduled = false,
    DateTime? startAt,
    DateTime? endAt,
  }) =>
      TodoEntity(
        id: 'id',
        ownerEmail: 'me@x.com',
        name: 'n',
        isDone: isDone,
        completedAt: completedAt,
        isDeleted: isDeleted,
        isScheduled: isScheduled,
        startAt: startAt,
        endAt: endAt,
        createdAt: DateTime(2026, 10, 1),
      );

  Set<TodoStatusTab> tabsOf(TodoEntity t) => TodoStatusTab.values
      .where((TodoStatusTab tab) => t.matchesTab(tab, now))
      .toSet();

  group('matchesTab', () {
    test('a plain open to-do is in All and To Do only', () {
      expect(tabsOf(todo()), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.toDo,
      });
    });

    test('All includes deleted to-dos; Deleted holds only deleted ones', () {
      final TodoEntity deleted = todo(isDeleted: true);
      expect(tabsOf(deleted), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.deleted,
      });
      expect(todo().matchesTab(TodoStatusTab.deleted, now), isFalse);
    });

    test('deleted to-dos never show in Done / Overdue / Scheduled / To Do', () {
      final TodoEntity deletedDone = todo(isDeleted: true, isDone: true);
      final TodoEntity deletedLate = todo(
        isDeleted: true,
        endAt: now.subtract(const Duration(days: 1)),
      );
      for (final TodoEntity t in <TodoEntity>[deletedDone, deletedLate]) {
        expect(t.matchesTab(TodoStatusTab.done, now), isFalse);
        expect(t.matchesTab(TodoStatusTab.overdue, now), isFalse);
        expect(t.matchesTab(TodoStatusTab.scheduled, now), isFalse);
        expect(t.matchesTab(TodoStatusTab.toDo, now), isFalse);
        expect(t.matchesTab(TodoStatusTab.all, now), isTrue);
      }
    });

    test('done goes to Done, not To Do / Overdue', () {
      final TodoEntity done = todo(
        isDone: true,
        endAt: now.subtract(const Duration(days: 2)),
      );
      expect(tabsOf(done), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.done,
      });
    });

    test('past end and not done is Overdue, not To Do', () {
      final TodoEntity late = todo(
        isScheduled: true,
        startAt: now.subtract(const Duration(days: 3)),
        endAt: now.subtract(const Duration(minutes: 1)),
      );
      expect(late.isOverdue(now), isTrue);
      expect(tabsOf(late), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.overdue,
      });
    });

    test('scheduled with a future start is Scheduled, not To Do', () {
      final TodoEntity upcoming = todo(
        isScheduled: true,
        startAt: now.add(const Duration(days: 1)),
        endAt: now.add(const Duration(days: 2)),
      );
      expect(tabsOf(upcoming), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.scheduled,
      });
    });

    test('scheduled that already started (not ended) is To Do', () {
      final TodoEntity running = todo(
        isScheduled: true,
        startAt: now.subtract(const Duration(hours: 1)),
        endAt: now.add(const Duration(days: 2)),
      );
      expect(tabsOf(running), <TodoStatusTab>{
        TodoStatusTab.all,
        TodoStatusTab.toDo,
      });
    });

    test(
        'every to-do sits in exactly one of To Do/Done/Overdue/Scheduled/'
        'Deleted', () {
      final List<TodoEntity> samples = <TodoEntity>[
        todo(),
        todo(isDone: true),
        todo(isDeleted: true),
        todo(endAt: now.subtract(const Duration(hours: 1))),
        todo(isScheduled: true, startAt: now.add(const Duration(hours: 1))),
      ];
      for (final TodoEntity t in samples) {
        final Set<TodoStatusTab> tabs = tabsOf(t)..remove(TodoStatusTab.all);
        expect(tabs.length, 1, reason: '$tabs');
        expect(t.matchesTab(TodoStatusTab.all, now), isTrue);
      }
    });
  });

  group('isLive', () {
    test('false only for deleted', () {
      expect(todo().isLive, isTrue);
      expect(todo(isDone: true).isLive, isTrue);
      expect(todo(isDeleted: true).isLive, isFalse);
    });
  });

  group('isDueToday (red card border)', () {
    test('open, ends later today', () {
      expect(todo(endAt: DateTime(2026, 10, 7, 18)).isDueToday(now), isTrue);
    });

    test('not when already overdue, done, deleted or another day', () {
      expect(todo(endAt: DateTime(2026, 10, 7, 9)).isDueToday(now), isFalse);
      expect(
        todo(isDone: true, endAt: DateTime(2026, 10, 7, 18)).isDueToday(now),
        isFalse,
      );
      expect(
        todo(isDeleted: true, endAt: DateTime(2026, 10, 7, 18)).isDueToday(now),
        isFalse,
      );
      expect(todo(endAt: DateTime(2026, 10, 8, 9)).isDueToday(now), isFalse);
    });
  });

  group('isDoneOnTime (green date chip)', () {
    test('completed on or before the end', () {
      final DateTime end = DateTime(2026, 10, 7, 18);
      expect(
        todo(isDone: true, endAt: end, completedAt: end).isDoneOnTime,
        isTrue,
      );
      expect(
        todo(
          isDone: true,
          endAt: end,
          completedAt: end.subtract(const Duration(hours: 1)),
        ).isDoneOnTime,
        isTrue,
      );
    });

    test('completed after the end, or not done', () {
      final DateTime end = DateTime(2026, 10, 7, 18);
      expect(
        todo(
          isDone: true,
          endAt: end,
          completedAt: end.add(const Duration(minutes: 1)),
        ).isDoneOnTime,
        isFalse,
      );
      expect(todo(endAt: end).isDoneOnTime, isFalse);
    });
  });
}
