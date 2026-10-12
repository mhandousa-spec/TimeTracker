/// Module: test / todo / t1_todo_list
///
///*************************** FILE INFO ****************************///
/// File Name: todo_optimistic_test.dart
/// Purpose: Optimistic ticks — `TodoListCubit.applyLocal` / `revertLocal`
///          (override shown at once, kept over stale snapshots, released by
///          a snapshot at least as new, dropped when the to-do disappears),
///          `TodoActionsCubit.bindOptimistic` (which actions apply, revert on
///          failure, nothing on permission denied), and both cubits wired
///          together the way `TodoModuleEntry` wires them.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_list_filters.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';

import '../_support/todo_test_fakes.dart';

/// [FakeTodoRepository] whose updates wait for [release] — the Firestore
/// transaction round-trip the optimistic display hides.
class _GatedRepository extends FakeTodoRepository {
  Completer<void> gate = Completer<void>();

  /// Let the pending update(s) finish.
  void release() {
    if (!gate.isCompleted) gate.complete();
  }

  @override
  Future<void> updateTodo({required TodoEntity todo}) async {
    await gate.future;
    return super.updateTodo(todo: todo);
  }
}

const List<TodoItem> _items = <TodoItem>[
  TodoItem(id: 'i1', title: 'Milk'),
  TodoItem(id: 'i2', title: 'Bread'),
];

/// Stored version of the test to-do, written [writtenAt].
TodoEntity _stored(DateTime writtenAt, {bool i1Done = false}) => makeTodo(
      't1',
      name: 'Shop',
      updatedAt: writtenAt,
      items: <TodoItem>[
        _items[0].copyWith(isDone: i1Done),
        _items[1],
      ],
    );

bool _i1Done(TodoListCubit cubit) =>
    cubit.state.byId('t1')!.items.first.isDone;

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late _GatedRepository repo;
  late FakeTodoAccess access;
  late TodoListCubit list;
  late TodoActionsCubit actions;
  late DateTime past;

  setUp(() {
    repo = _GatedRepository();
    access = FakeTodoAccess();
    list = TodoListCubit(
      repository: repo,
      access: access,
      reminderSweeper: FakeReminderSweeper(),
    );
    actions = TodoActionsCubit(
      repository: repo,
      access: access,
      logService: FakeTodoLogService(),
    );
    past = DateTime.now().subtract(const Duration(minutes: 5));
  });

  tearDown(() async {
    repo.release();
    await actions.close();
    await list.close();
    await repo.controller.close();
  });

  Future<void> load(List<TodoEntity> todos) async {
    list.init();
    repo.controller.add(todos);
    await _flush();
  }

  group('TodoListCubit.applyLocal / revertLocal', () {
    test('applyLocal shows the new version immediately', () async {
      await load(<TodoEntity>[_stored(past)]);
      final TodoEntity current = list.state.byId('t1')!;
      list.applyLocal(current.copyWith(isDone: true));
      expect(list.state.byId('t1')!.isDone, isTrue);
      // Derived counts follow the override too.
      expect(list.state.countFor(TodoStatusTab.done), 1);
    });

    test('a stale snapshot (older write) does not undo the override',
        () async {
      await load(<TodoEntity>[_stored(past)]);
      list.applyLocal(_stored(past, i1Done: true));
      repo.controller.add(<TodoEntity>[_stored(past)]);
      await _flush();
      expect(_i1Done(list), isTrue);
    });

    test('a snapshot written after the override releases it', () async {
      await load(<TodoEntity>[_stored(past)]);
      list.applyLocal(_stored(past, i1Done: true));
      // The server's newer copy wins, even if it differs.
      final DateTime later = DateTime.now().add(const Duration(seconds: 1));
      repo.controller.add(<TodoEntity>[_stored(later)]);
      await _flush();
      expect(_i1Done(list), isFalse);
    });

    test('revertLocal brings back the stream copy', () async {
      await load(<TodoEntity>[_stored(past)]);
      list.applyLocal(_stored(past, i1Done: true));
      list.revertLocal('t1');
      expect(_i1Done(list), isFalse);
    });

    test('revertLocal of an unknown id emits nothing', () async {
      await load(<TodoEntity>[_stored(past)]);
      final TodoListState before = list.state;
      list.revertLocal('nope');
      expect(identical(list.state, before), isTrue);
    });

    test('the override is dropped when the to-do leaves the stream',
        () async {
      await load(<TodoEntity>[_stored(past)]);
      list.applyLocal(_stored(past, i1Done: true));
      repo.controller.add(<TodoEntity>[]);
      await _flush();
      repo.controller.add(<TodoEntity>[_stored(past)]);
      await _flush();
      expect(_i1Done(list), isFalse);
    });

    test('an override never adds a to-do the stream does not have',
        () async {
      await load(<TodoEntity>[_stored(past)]);
      list.applyLocal(makeTodo('ghost'));
      expect(list.state.byId('ghost'), isNull);
      expect(list.state.todos, hasLength(1));
    });
  });

  group('TodoActionsCubit.bindOptimistic', () {
    late List<TodoEntity> applied;
    late List<String> reverted;

    setUp(() {
      applied = <TodoEntity>[];
      reverted = <String>[];
      actions.bindOptimistic(apply: applied.add, revert: reverted.add);
    });

    test('toggleItem applies BEFORE the write finishes', () async {
      final Future<void> pending =
          actions.toggleItem(_stored(past), 'i1');
      await _flush();
      expect(applied, hasLength(1));
      expect(applied.single.items.first.isDone, isTrue);
      expect(repo.updated, isEmpty);
      repo.release();
      await pending;
      expect(repo.updated, hasLength(1));
      expect(reverted, isEmpty);
    });

    test('toggleDone, addItem and removeItem are optimistic too', () async {
      repo.release();
      await actions.toggleDone(_stored(past));
      await actions.addItem(_stored(past), 'Eggs');
      await actions.removeItem(_stored(past), 'i2');
      expect(applied, hasLength(3));
      expect(applied[0].isDone, isTrue);
      expect(applied[1].items, hasLength(3));
      expect(applied[2].items, hasLength(1));
    });

    test('delete and restore are NOT optimistic', () async {
      repo.release();
      await actions.delete(_stored(past));
      await actions.restore(_stored(past).copyWith(isDeleted: true));
      expect(applied, isEmpty);
    });

    test('a failed write reverts and reports failure', () async {
      repo.failWith = Exception('offline');
      repo.release();
      await actions.toggleItem(_stored(past), 'i1');
      expect(applied, hasLength(1));
      expect(reverted, <String>['t1']);
      expect(actions.state.status, TodoActionStatus.failure);
    });

    test('permission denied: nothing applied, nothing written', () async {
      access.canEdit = false;
      await actions.toggleItem(_stored(past), 'i1');
      expect(applied, isEmpty);
      expect(reverted, isEmpty);
      expect(repo.updated, isEmpty);
      expect(actions.state.errorMessage, TodoActionsCubit.permissionDenied);
    });
  });

  group('wired like TodoModuleEntry', () {
    setUp(() {
      actions.bindOptimistic(apply: list.applyLocal, revert: list.revertLocal);
    });

    test('tick shows at once, then the snapshot confirms it', () async {
      await load(<TodoEntity>[_stored(past)]);
      final Future<void> pending =
          actions.toggleItem(list.state.byId('t1')!, 'i1');
      await _flush();
      expect(_i1Done(list), isTrue, reason: 'instant, write still pending');

      repo.release();
      await pending;
      final DateTime written = DateTime.now().add(const Duration(seconds: 1));
      repo.controller.add(<TodoEntity>[_stored(written, i1Done: true)]);
      await _flush();
      expect(_i1Done(list), isTrue);
      expect(list.state.byId('t1')!.updatedAt, written);
    });

    test('failure reverts the card to the stored state', () async {
      await load(<TodoEntity>[_stored(past)]);
      repo.failWith = Exception('offline');
      final Future<void> pending =
          actions.toggleItem(list.state.byId('t1')!, 'i1');
      await _flush();
      expect(_i1Done(list), isTrue);
      repo.release();
      await pending;
      expect(_i1Done(list), isFalse);
      expect(actions.state.status, TodoActionStatus.failure);
    });

    test('two quick ticks: the second builds on the first', () async {
      await load(<TodoEntity>[_stored(past)]);
      unawaited(actions.toggleItem(list.state.byId('t1')!, 'i1'));
      await _flush();
      unawaited(actions.toggleItem(list.state.byId('t1')!, 'i2'));
      await _flush();
      final List<TodoItem> items = list.state.byId('t1')!.items;
      expect(items.every((TodoItem i) => i.isDone), isTrue);
    });
  });
}
