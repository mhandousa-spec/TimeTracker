/// Module: test / todo / t1_todo_list
///
///*************************** FILE INFO ****************************///
/// File Name: todo_list_cubit_test.dart
/// Purpose: `TodoListCubit` — live stream → loaded / failure, tab /
///          priority / sort / search filtering, invalid sort reset on tab
///          change, per-tab counts ("All" includes deleted), byId, the
///          reminder sweep trigger, and no emit after close.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';

import '../_support/todo_test_fakes.dart';

/// Fixture: one to-do per tab, relative to the real clock (the cubit stamps
/// `DateTime.now()` on every snapshot).
List<TodoEntity> _fixture() {
  final DateTime now = DateTime.now();
  return <TodoEntity>[
    makeTodo(
      'todo',
      name: 'Buy milk',
      priority: TodoPriority.high,
      createdAt: now.subtract(const Duration(days: 1)),
      items: const <TodoItem>[TodoItem(id: 'a', title: 'Skimmed')],
    ),
    makeTodo(
      'done',
      name: 'Pay rent',
      priority: TodoPriority.low,
      isDone: true,
      completedAt: now.subtract(const Duration(hours: 1)),
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    makeTodo(
      'overdue',
      name: 'File taxes',
      description: 'Before the deadline',
      priority: TodoPriority.high,
      isScheduled: true,
      startAt: now.subtract(const Duration(days: 3)),
      endAt: now.subtract(const Duration(days: 1)),
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    makeTodo(
      'scheduled',
      name: 'Dentist',
      priority: TodoPriority.medium,
      isScheduled: true,
      startAt: now.add(const Duration(days: 2)),
      endAt: now.add(const Duration(days: 2, hours: 1)),
      createdAt: now.subtract(const Duration(days: 5)),
    ),
    makeTodo(
      'deleted',
      name: 'Old idea',
      priority: TodoPriority.low,
      isDeleted: true,
      deletedAt: now.subtract(const Duration(hours: 2)),
      createdAt: now.subtract(const Duration(days: 6)),
    ),
  ];
}

List<String> _ids(List<TodoEntity> todos) =>
    todos.map((TodoEntity t) => t.id).toList();

void main() {
  late FakeTodoRepository repo;
  late FakeTodoAccess access;
  late FakeReminderSweeper sweeper;
  late TodoListCubit cubit;

  setUp(() {
    repo = FakeTodoRepository();
    access = FakeTodoAccess();
    sweeper = FakeReminderSweeper();
    cubit = TodoListCubit(
      repository: repo,
      access: access,
      reminderSweeper: sweeper,
    );
  });

  tearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  Future<void> load([List<TodoEntity>? todos]) async {
    cubit.init();
    repo.controller.add(todos ?? _fixture());
    await flush();
  }

  group('lifecycle', () {
    test('initial state: initial status, All tab, no filters', () {
      expect(cubit.state.status, TodoListStatus.initial);
      expect(cubit.state.tab, TodoStatusTab.all);
      expect(cubit.state.priority, isNull);
      expect(cubit.state.sort, isNull);
      expect(cubit.state.query, '');
      expect(cubit.state.todos, isEmpty);
    });

    test('init → loading, watches the signed-in owner only', () {
      cubit.init();
      expect(cubit.state.status, TodoListStatus.loading);
      expect(repo.watchedOwners, <String>['owner@test.local']);
    });

    test('init twice subscribes once', () {
      cubit.init();
      cubit.init();
      expect(repo.watchedOwners, hasLength(1));
    });

    test('stream emit → loaded, todos stored, everything visible on All',
        () async {
      await load();
      expect(cubit.state.status, TodoListStatus.loaded);
      expect(cubit.state.todos, hasLength(5));
      expect(cubit.state.visible, hasLength(5));
      expect(cubit.state.errorMessage, isNull);
    });

    test('later snapshots replace the list (live updates)', () async {
      await load();
      repo.controller.add(<TodoEntity>[makeTodo('only')]);
      await flush();
      expect(_ids(cubit.state.visible), <String>['only']);
    });

    test('stream error → failure with message', () async {
      cubit.init();
      repo.controller.addError(Exception('permission-denied'));
      await flush();
      expect(cubit.state.status, TodoListStatus.failure);
      expect(cubit.state.errorMessage, contains('permission-denied'));
    });

    test('a snapshot after an error recovers to loaded and clears the error',
        () async {
      cubit.init();
      repo.controller.addError(Exception('boom'));
      await flush();
      repo.controller.add(_fixture());
      await flush();
      expect(cubit.state.status, TodoListStatus.loaded);
      expect(cubit.state.errorMessage, isNull);
    });

    test('empty snapshot → loaded with nothing visible', () async {
      await load(const <TodoEntity>[]);
      expect(cubit.state.status, TodoListStatus.loaded);
      expect(cubit.state.visible, isEmpty);
      for (final TodoStatusTab tab in TodoStatusTab.values) {
        expect(cubit.state.countFor(tab), 0, reason: tab.name);
      }
    });

    test('close cancels the subscription: no emit afterwards', () async {
      await load();
      final List<TodoListState> after = <TodoListState>[];
      final StreamSubscription<TodoListState> sub =
          cubit.stream.listen(after.add);
      await cubit.close();
      expect(repo.controller.hasListener, isFalse);
      repo.controller.add(<TodoEntity>[makeTodo('late')]);
      repo.controller.addError(Exception('late error'));
      await flush();
      expect(after, isEmpty);
      expect(cubit.state.todos, hasLength(5));
      // Calls after close are swallowed by the emit guard, not thrown.
      cubit.selectTab(TodoStatusTab.done);
      cubit.searchChanged('x');
      expect(cubit.state.tab, TodoStatusTab.all);
      await sub.cancel();
    });
  });

  group('tabs and counts', () {
    test('countFor: one per tab, All includes the deleted one', () async {
      await load();
      final TodoListState s = cubit.state;
      expect(s.countFor(TodoStatusTab.all), 5);
      expect(s.countFor(TodoStatusTab.toDo), 1);
      expect(s.countFor(TodoStatusTab.done), 1);
      expect(s.countFor(TodoStatusTab.overdue), 1);
      expect(s.countFor(TodoStatusTab.scheduled), 1);
      expect(s.countFor(TodoStatusTab.deleted), 1);
    });

    final Map<TodoStatusTab, String> expected = <TodoStatusTab, String>{
      TodoStatusTab.toDo: 'todo',
      TodoStatusTab.done: 'done',
      TodoStatusTab.overdue: 'overdue',
      TodoStatusTab.scheduled: 'scheduled',
      TodoStatusTab.deleted: 'deleted',
    };
    expected.forEach((TodoStatusTab tab, String id) {
      test('selectTab(${tab.name}) shows only "$id"', () async {
        await load();
        cubit.selectTab(tab);
        expect(cubit.state.tab, tab);
        expect(_ids(cubit.state.visible), <String>[id]);
      });
    });

    test('counts ignore the search and priority filters', () async {
      await load();
      cubit.searchChanged('zzz');
      cubit.selectPriority(TodoPriority.low);
      expect(cubit.state.visible, isEmpty);
      expect(cubit.state.countFor(TodoStatusTab.all), 5);
      expect(cubit.state.countFor(TodoStatusTab.toDo), 1);
    });

    test('default order on All is newest created first', () async {
      await load();
      expect(
        _ids(cubit.state.visible),
        <String>['todo', 'done', 'overdue', 'scheduled', 'deleted'],
      );
    });
  });

  group('priority filter', () {
    test('selectPriority(high) keeps only high', () async {
      await load();
      cubit.selectPriority(TodoPriority.high);
      expect(cubit.state.priority, TodoPriority.high);
      expect(_ids(cubit.state.visible), <String>['todo', 'overdue']);
    });

    test('combines with the tab', () async {
      await load();
      cubit.selectTab(TodoStatusTab.overdue);
      cubit.selectPriority(TodoPriority.low);
      expect(cubit.state.visible, isEmpty);
      cubit.selectPriority(TodoPriority.high);
      expect(_ids(cubit.state.visible), <String>['overdue']);
    });

    test('selectPriority(null) = "All" clears it', () async {
      await load();
      cubit.selectPriority(TodoPriority.low);
      cubit.selectPriority(null);
      expect(cubit.state.priority, isNull);
      expect(cubit.state.visible, hasLength(5));
    });
  });

  group('search', () {
    test('matches name, case-insensitive and trimmed', () async {
      await load();
      cubit.searchChanged('  MILK ');
      expect(_ids(cubit.state.visible), <String>['todo']);
    });

    test('matches description', () async {
      await load();
      cubit.searchChanged('deadline');
      expect(_ids(cubit.state.visible), <String>['overdue']);
    });

    test('matches a checklist item title', () async {
      await load();
      cubit.searchChanged('skimmed');
      expect(_ids(cubit.state.visible), <String>['todo']);
    });

    test('no match → empty; clearing → everything back', () async {
      await load();
      cubit.searchChanged('nothing like this');
      expect(cubit.state.visible, isEmpty);
      cubit.searchChanged('');
      expect(cubit.state.visible, hasLength(5));
    });

    test('combines with tab and priority', () async {
      await load();
      cubit.selectTab(TodoStatusTab.deleted);
      cubit.searchChanged('idea');
      expect(_ids(cubit.state.visible), <String>['deleted']);
      cubit.selectPriority(TodoPriority.high);
      expect(cubit.state.visible, isEmpty);
    });
  });

  group('sort', () {
    test('selectSort(priority) orders high → low', () async {
      await load();
      cubit.selectSort(TodoSortOption.priority);
      final List<TodoPriority> order =
          cubit.state.visible.map((TodoEntity t) => t.priority).toList();
      expect(order.first, TodoPriority.high);
      expect(order.last, TodoPriority.low);
    });

    test('selectSort(null) clears back to default order', () async {
      await load();
      cubit.selectSort(TodoSortOption.priority);
      cubit.selectSort(null);
      expect(cubit.state.sort, isNull);
      expect(_ids(cubit.state.visible).first, 'todo');
    });

    test('sortOptions follow the tab', () async {
      await load();
      expect(cubit.state.sortOptions, TodoSortOption.forTab(TodoStatusTab.all));
      cubit.selectTab(TodoStatusTab.scheduled);
      expect(
        cubit.state.sortOptions,
        <TodoSortOption>[TodoSortOption.startDate, TodoSortOption.frequency],
      );
    });

    test('changing tab resets a sort the new tab does not offer', () async {
      await load();
      cubit.selectSort(TodoSortOption.creationDate); // All only
      cubit.selectTab(TodoStatusTab.done);
      expect(cubit.state.sort, isNull);
    });

    test('changing tab keeps a sort the new tab also offers', () async {
      await load();
      cubit.selectSort(TodoSortOption.priority);
      cubit.selectTab(TodoStatusTab.deleted);
      expect(cubit.state.sort, TodoSortOption.priority);
    });

    test('Deleted tab sorted by deletion date: most recent first', () async {
      final DateTime now = DateTime.now();
      await load(<TodoEntity>[
        makeTodo('d-old',
            isDeleted: true, deletedAt: now.subtract(const Duration(days: 3))),
        makeTodo('d-new',
            isDeleted: true, deletedAt: now.subtract(const Duration(hours: 1))),
      ]);
      cubit.selectTab(TodoStatusTab.deleted);
      cubit.selectSort(TodoSortOption.deletionDate);
      expect(_ids(cubit.state.visible), <String>['d-new', 'd-old']);
    });

    test('visible is unmodifiable', () async {
      await load();
      expect(
        () => cubit.state.visible.add(makeTodo('x')),
        throwsUnsupportedError,
      );
    });
  });

  group('byId', () {
    test('finds a live to-do, null when it disappears', () async {
      await load();
      expect(cubit.state.byId('done')?.name, 'Pay rent');
      repo.controller.add(<TodoEntity>[makeTodo('todo')]);
      await flush();
      expect(cubit.state.byId('done'), isNull);
    });
  });

  group('reminder sweep', () {
    test('runs once after the FIRST snapshot only', () async {
      await load();
      expect(sweeper.sweeps, hasLength(1));
      expect(sweeper.sweeps.single, hasLength(5));
      repo.controller.add(_fixture());
      await flush();
      expect(sweeper.sweeps, hasLength(1));
    });

    test('never runs before data arrives or after a stream error', () async {
      cubit.init();
      repo.controller.addError(Exception('x'));
      await flush();
      expect(sweeper.sweeps, isEmpty);
    });

    test('passes the language: ar → isArabic', () async {
      cubit.init(languageCode: 'ar');
      repo.controller.add(_fixture());
      await flush();
      expect(sweeper.arabicFlags, <bool>[true]);
    });

    test('a throwing sweep never breaks the list', () async {
      sweeper.throwOnSweep = true;
      await load();
      expect(cubit.state.status, TodoListStatus.loaded);
      expect(cubit.state.visible, hasLength(5));
    });
  });
}
