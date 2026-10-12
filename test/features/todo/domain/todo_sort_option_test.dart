/// Module: test / todo / domain
///
///*************************** FILE INFO ****************************///
/// File Name: todo_sort_option_test.dart
/// Purpose: Pins the per-tab sort entries (`TodoSortOption.forTab`), each
///          entry's ordering (`TodoSortOption.compare`) and how
///          `TodoListState.visible` applies them.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 7, 12);
  DateTime day(int d) => DateTime(2026, 10, d, 9);

  TodoEntity todo(
    String id, {
    TodoPriority priority = TodoPriority.medium,
    bool isDone = false,
    DateTime? completedAt,
    bool isDeleted = false,
    DateTime? deletedAt,
    bool isScheduled = false,
    DateTime? startAt,
    DateTime? endAt,
    bool hasFrequency = false,
    TodoFrequency frequency = const TodoFrequency(),
    DateTime? createdAt,
  }) =>
      TodoEntity(
        id: id,
        ownerEmail: 'me@x.com',
        name: id,
        priority: priority,
        isDone: isDone,
        completedAt: completedAt,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        isScheduled: isScheduled,
        startAt: startAt,
        endAt: endAt,
        hasFrequency: hasFrequency,
        frequency: frequency,
        createdAt: createdAt ?? day(1),
      );

  List<String> ids(Iterable<TodoEntity> list) =>
      list.map((TodoEntity t) => t.id).toList();

  List<String> sortedBy(TodoSortOption option, List<TodoEntity> list) =>
      ids(List<TodoEntity>.of(list)..sort(option.compare));

  group('forTab', () {
    test('final mapping', () {
      expect(TodoSortOption.forTab(TodoStatusTab.all), <TodoSortOption>[
        TodoSortOption.dueDate,
        TodoSortOption.priority,
        TodoSortOption.creationDate,
      ]);
      expect(TodoSortOption.forTab(TodoStatusTab.toDo), <TodoSortOption>[
        TodoSortOption.dueDate,
        TodoSortOption.priority,
        TodoSortOption.creationDate,
      ]);
      expect(TodoSortOption.forTab(TodoStatusTab.done), <TodoSortOption>[
        TodoSortOption.completionDate,
        TodoSortOption.priority,
      ]);
      expect(TodoSortOption.forTab(TodoStatusTab.overdue), <TodoSortOption>[
        TodoSortOption.dueDate,
        TodoSortOption.priority,
      ]);
      expect(TodoSortOption.forTab(TodoStatusTab.scheduled), <TodoSortOption>[
        TodoSortOption.startDate,
        TodoSortOption.frequency,
      ]);
      expect(TodoSortOption.forTab(TodoStatusTab.deleted), <TodoSortOption>[
        TodoSortOption.deletionDate,
        TodoSortOption.priority,
      ]);
    });

    test('Done never offers a scheduling sort (owner bug)', () {
      final List<TodoSortOption> done =
          TodoSortOption.forTab(TodoStatusTab.done);
      expect(done, isNot(contains(TodoSortOption.startDate)));
      expect(done, isNot(contains(TodoSortOption.frequency)));
      expect(done, isNot(contains(TodoSortOption.dueDate)));
    });

    test('every option is offered on at least one tab', () {
      final Set<TodoSortOption> offered =
          TodoStatusTab.values.expand(TodoSortOption.forTab).toSet();
      expect(offered, TodoSortOption.values.toSet());
    });

    test('isValidFor mirrors forTab', () {
      for (final TodoStatusTab tab in TodoStatusTab.values) {
        for (final TodoSortOption o in TodoSortOption.values) {
          expect(o.isValidFor(tab), TodoSortOption.forTab(tab).contains(o));
        }
      }
    });
  });

  group('compare', () {
    test('dueDate: soonest (= most overdue) first, missing last', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('none'),
        todo('late', endAt: day(5)),
        todo('later', endAt: day(6)),
        todo('earliest', endAt: day(2)),
      ];
      expect(sortedBy(TodoSortOption.dueDate, list),
          <String>['earliest', 'late', 'later', 'none']);
    });

    test('priority: High → Medium → Low, ties by due date', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('low', priority: TodoPriority.low, endAt: day(1)),
        todo('high-late', priority: TodoPriority.high, endAt: day(9)),
        todo('med', priority: TodoPriority.medium, endAt: day(1)),
        todo('high-soon', priority: TodoPriority.high, endAt: day(3)),
      ];
      expect(sortedBy(TodoSortOption.priority, list),
          <String>['high-soon', 'high-late', 'med', 'low']);
    });

    test('creationDate: newest first', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('old', createdAt: day(1)),
        todo('new', createdAt: day(5)),
        todo('mid', createdAt: day(3)),
      ];
      expect(sortedBy(TodoSortOption.creationDate, list),
          <String>['new', 'mid', 'old']);
    });

    test('completionDate: most recently completed first, missing last', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('a', isDone: true, completedAt: day(2)),
        todo('b', isDone: true),
        todo('c', isDone: true, completedAt: day(6)),
      ];
      expect(sortedBy(TodoSortOption.completionDate, list),
          <String>['c', 'a', 'b']);
    });

    test('startDate: soonest start first', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('b', isScheduled: true, startAt: day(9)),
        todo('a', isScheduled: true, startAt: day(8)),
      ];
      expect(sortedBy(TodoSortOption.startDate, list), <String>['a', 'b']);
    });

    test('frequency: recurring first, Daily → Weekly → Monthly, interval', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('once'),
        todo(
          'monthly',
          hasFrequency: true,
          frequency: const TodoFrequency(unit: TodoFrequencyUnit.monthly),
        ),
        todo(
          'every2weeks',
          hasFrequency: true,
          frequency:
              const TodoFrequency(interval: 2, unit: TodoFrequencyUnit.weekly),
        ),
        todo(
          'weekly',
          hasFrequency: true,
          frequency: const TodoFrequency(unit: TodoFrequencyUnit.weekly),
        ),
        todo('daily', hasFrequency: true),
      ];
      expect(sortedBy(TodoSortOption.frequency, list),
          <String>['daily', 'weekly', 'every2weeks', 'monthly', 'once']);
    });

    test('deletionDate: most recently deleted first', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('a', isDeleted: true, deletedAt: day(2)),
        todo('b', isDeleted: true, deletedAt: day(4)),
      ];
      expect(sortedBy(TodoSortOption.deletionDate, list), <String>['b', 'a']);
    });

    test('ties fall back to newest created first', () {
      final List<TodoEntity> list = <TodoEntity>[
        todo('older', endAt: day(5), createdAt: day(1)),
        todo('newer', endAt: day(5), createdAt: day(2)),
      ];
      expect(
          sortedBy(TodoSortOption.dueDate, list), <String>['newer', 'older']);
    });
  });

  group('TodoListState', () {
    final List<TodoEntity> todos = <TodoEntity>[
      todo('open-soon', endAt: day(9), createdAt: day(1)),
      todo('open-later', endAt: day(20), createdAt: day(3)),
      todo('done', isDone: true, completedAt: day(4), createdAt: day(2)),
      todo('gone', isDeleted: true, deletedAt: day(5), createdAt: day(4)),
    ];

    test('All shows deleted too and counts it', () {
      final TodoListState state = TodoListState(now: now, todos: todos);
      expect(ids(state.visible), contains('gone'));
      expect(state.countFor(TodoStatusTab.all), 4);
      expect(state.countFor(TodoStatusTab.deleted), 1);
      expect(state.countFor(TodoStatusTab.toDo), 2);
      expect(state.countFor(TodoStatusTab.done), 1);
    });

    test('no sort = newest created first', () {
      final TodoListState state = TodoListState(now: now, todos: todos);
      expect(ids(state.visible),
          <String>['gone', 'open-later', 'done', 'open-soon']);
    });

    test('picked sort is applied', () {
      final TodoListState state = TodoListState(
        now: now,
        todos: todos,
        tab: TodoStatusTab.toDo,
        sort: TodoSortOption.dueDate,
      );
      expect(ids(state.visible), <String>['open-soon', 'open-later']);
    });

    test('a sort not offered on the tab falls back to the default order', () {
      final TodoListState state = TodoListState(
        now: now,
        todos: todos,
        sort: TodoSortOption.startDate,
      );
      expect(ids(state.visible),
          <String>['gone', 'open-later', 'done', 'open-soon']);
    });

    test('sortOptions follows the tab', () {
      final TodoListState state =
          TodoListState(now: now, tab: TodoStatusTab.done);
      expect(state.sortOptions, TodoSortOption.forTab(TodoStatusTab.done));
    });
  });

  group('TodoItem progress', () {
    test('completedItemsCount counts ticked lines', () {
      final TodoEntity t = TodoEntity(
        id: 'x',
        ownerEmail: 'me@x.com',
        name: 'x',
        items: const <TodoItem>[
          TodoItem(id: '1', title: 'a', isDone: true),
          TodoItem(id: '2', title: 'b'),
        ],
      );
      expect(t.completedItemsCount, 1);
    });
  });
}
