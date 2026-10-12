/// Module: test / todo / t3_todo_details
///
///*************************** FILE INFO ****************************///
/// File Name: todo_actions_cubit_test.dart
/// Purpose: Every `TodoActionsCubit` mutation — mark done / reopen, soft
///          delete, restore, checklist add / remove / tick — on the happy
///          path, with the permission switched off (permissionDenied
///          sentinel, NO repository write, NO log) and with the repository
///          throwing (failure + message, NO log).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';

import '../_support/todo_test_fakes.dart';

/// One mutation under test: how to run it, which permission gates it, and
/// what a successful run must log (null = silent).
class _Case {
  const _Case({
    required this.name,
    required this.kind,
    required this.subject,
    required this.run,
    required this.deny,
    required this.log,
  });

  final String name;
  final TodoActionKind kind;
  final TodoEntity subject;
  final Future<void> Function(TodoActionsCubit cubit, TodoEntity todo) run;
  final void Function(FakeTodoAccess access) deny;
  final String? log;
}

const List<TodoItem> _items = <TodoItem>[
  TodoItem(id: 'i1', title: 'Milk'),
  TodoItem(id: 'i2', title: 'Bread', isDone: true),
];

final TodoEntity _open = makeTodo('t1', name: 'Shop', items: _items);
final TodoEntity _done = makeTodo(
  't2',
  isDone: true,
  completedAt: DateTime(2026, 10, 1),
);
final TodoEntity _deleted = makeTodo(
  't3',
  isDeleted: true,
  deletedAt: DateTime(2026, 10, 2),
);

final List<_Case> _cases = <_Case>[
  _Case(
    name: 'toggleDone (mark done)',
    kind: TodoActionKind.toggleDone,
    subject: _open,
    run: (TodoActionsCubit c, TodoEntity t) => c.toggleDone(t),
    deny: (FakeTodoAccess a) => a.canEdit = false,
    log: TodoLogService.actionMarkDone,
  ),
  _Case(
    name: 'toggleDone (reopen)',
    kind: TodoActionKind.toggleDone,
    subject: _done,
    run: (TodoActionsCubit c, TodoEntity t) => c.toggleDone(t),
    deny: (FakeTodoAccess a) => a.canEdit = false,
    log: TodoLogService.actionReopen,
  ),
  _Case(
    name: 'delete',
    kind: TodoActionKind.delete,
    subject: _open,
    run: (TodoActionsCubit c, TodoEntity t) => c.delete(t),
    deny: (FakeTodoAccess a) => a.canDelete = false,
    log: TodoLogService.actionDelete,
  ),
  _Case(
    name: 'restore',
    kind: TodoActionKind.restore,
    subject: _deleted,
    run: (TodoActionsCubit c, TodoEntity t) => c.restore(t),
    deny: (FakeTodoAccess a) => a.canRestore = false,
    log: TodoLogService.actionRestore,
  ),
  _Case(
    name: 'addItem',
    kind: TodoActionKind.addItem,
    subject: _open,
    run: (TodoActionsCubit c, TodoEntity t) => c.addItem(t, 'Eggs'),
    deny: (FakeTodoAccess a) => a.canEdit = false,
    log: TodoLogService.actionUpdate,
  ),
  _Case(
    name: 'removeItem',
    kind: TodoActionKind.removeItem,
    subject: _open,
    run: (TodoActionsCubit c, TodoEntity t) => c.removeItem(t, 'i1'),
    deny: (FakeTodoAccess a) => a.canEdit = false,
    log: TodoLogService.actionUpdate,
  ),
  _Case(
    name: 'toggleItem',
    kind: TodoActionKind.toggleItem,
    subject: _open,
    run: (TodoActionsCubit c, TodoEntity t) => c.toggleItem(t, 'i1'),
    deny: (FakeTodoAccess a) => a.canEdit = false,
    log: null,
  ),
];

void main() {
  late FakeTodoRepository repo;
  late FakeTodoAccess access;
  late FakeTodoLogService log;
  late TodoActionsCubit cubit;
  late List<TodoActionsState> emitted;
  late StreamSubscription<TodoActionsState> sub;

  setUp(() {
    repo = FakeTodoRepository();
    access = FakeTodoAccess();
    log = FakeTodoLogService();
    cubit = TodoActionsCubit(
      repository: repo,
      access: access,
      logService: log,
    );
    emitted = <TodoActionsState>[];
    sub = cubit.stream.listen(emitted.add);
  });

  tearDown(() async {
    await sub.cancel();
    await cubit.close();
  });

  /// Let the broadcast stream deliver the last emits.
  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('starts idle with no kind and no error', () {
    expect(cubit.state.status, TodoActionStatus.idle);
    expect(cubit.state.kind, isNull);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.isSubmitting, isFalse);
  });

  for (final _Case c in _cases) {
    group(c.name, () {
      test('success: submitting → success, one write, logs ${c.log}', () async {
        await c.run(cubit, c.subject);
        await flush();

        expect(
          emitted.map((TodoActionsState s) => s.status).toList(),
          <TodoActionStatus>[
            TodoActionStatus.submitting,
            TodoActionStatus.success,
          ],
        );
        expect(emitted.first.isSubmitting, isTrue);
        expect(emitted.every((TodoActionsState s) => s.kind == c.kind), isTrue);
        expect(cubit.state.errorMessage, isNull);
        expect(repo.updated, hasLength(1));
        expect(repo.updated.single.id, c.subject.id);
        expect(log.actions, c.log == null ? isEmpty : <String>[c.log!]);
      });

      test('permission denied: failure + sentinel, no write, no log', () async {
        c.deny(access);
        await c.run(cubit, c.subject);
        await flush();

        expect(emitted, hasLength(1));
        expect(cubit.state.status, TodoActionStatus.failure);
        expect(cubit.state.kind, c.kind);
        expect(cubit.state.errorMessage, TodoActionsCubit.permissionDenied);
        expect(repo.writeCount, 0);
        expect(log.actions, isEmpty);
      });

      test('repository throws: failure with its message, no log', () async {
        repo.failWith = Exception('offline');
        await c.run(cubit, c.subject);
        await flush();

        expect(
          emitted.map((TodoActionsState s) => s.status).toList(),
          <TodoActionStatus>[
            TodoActionStatus.submitting,
            TodoActionStatus.failure,
          ],
        );
        expect(cubit.state.kind, c.kind);
        expect(cubit.state.errorMessage, contains('offline'));
        expect(
          cubit.state.errorMessage,
          isNot(TodoActionsCubit.permissionDenied),
        );
        expect(log.actions, isEmpty);
      });
    });
  }

  group('payloads written', () {
    test('mark done sets isDone and stamps completedAt ≈ now', () async {
      final DateTime before = DateTime.now();
      await cubit.toggleDone(_open);
      final TodoEntity saved = repo.updated.single;
      expect(saved.isDone, isTrue);
      expect(saved.completedAt, isNotNull);
      expect(saved.completedAt!.isBefore(before), isFalse);
      expect(saved.completedAt!.isAfter(DateTime.now()), isFalse);
      expect(saved.name, _open.name);
      expect(saved.items, hasLength(2));
    });

    test('reopen clears isDone AND completedAt', () async {
      await cubit.toggleDone(_done);
      final TodoEntity saved = repo.updated.single;
      expect(saved.isDone, isFalse);
      expect(saved.completedAt, isNull);
    });

    test('delete is soft: isDeleted + deletedAt, everything else kept',
        () async {
      await cubit.delete(_open);
      final TodoEntity saved = repo.updated.single;
      expect(saved.isDeleted, isTrue);
      expect(saved.deletedAt, isNotNull);
      expect(saved.id, _open.id);
      expect(saved.name, _open.name);
      expect(saved.items.map((TodoItem i) => i.id), <String>['i1', 'i2']);
    });

    test('restore clears isDeleted AND deletedAt', () async {
      await cubit.restore(_deleted);
      final TodoEntity saved = repo.updated.single;
      expect(saved.isDeleted, isFalse);
      expect(saved.deletedAt, isNull);
    });

    test('addItem appends a trimmed, unticked line at the end', () async {
      await cubit.addItem(_open, '  Eggs  ');
      final List<TodoItem> items = repo.updated.single.items;
      expect(items, hasLength(3));
      expect(items.take(2).map((TodoItem i) => i.id), <String>['i1', 'i2']);
      expect(items.last.title, 'Eggs');
      expect(items.last.isDone, isFalse);
      expect(items.last.id, isNotEmpty);
      expect(<String>{for (final TodoItem i in items) i.id}, hasLength(3));
    });

    for (final String blank in <String>['', '   ', '\n\t']) {
      test('addItem ignores blank title "${blank.replaceAll('\n', r'\n')}"',
          () async {
        await cubit.addItem(_open, blank);
        await flush();
        expect(repo.writeCount, 0);
        expect(emitted, isEmpty);
        expect(log.actions, isEmpty);
        expect(cubit.state.status, TodoActionStatus.idle);
      });
    }

    test('removeItem drops only the matching line', () async {
      await cubit.removeItem(_open, 'i1');
      final List<TodoItem> items = repo.updated.single.items;
      expect(items.map((TodoItem i) => i.id), <String>['i2']);
    });

    test('removeItem with an unknown id writes nothing and logs nothing',
        () async {
      await cubit.removeItem(_open, 'nope');
      expect(repo.updated, isEmpty);
    });

    test('toggleItem flips only the matching line, both directions', () async {
      await cubit.toggleItem(_open, 'i1');
      await cubit.toggleItem(_open, 'i2');
      final List<TodoItem> first = repo.updated[0].items;
      final List<TodoItem> second = repo.updated[1].items;
      expect(first.map((TodoItem i) => i.isDone), <bool>[true, true]);
      expect(second.map((TodoItem i) => i.isDone), <bool>[false, false]);
      // Order and titles preserved.
      expect(first.map((TodoItem i) => i.title), <String>['Milk', 'Bread']);
    });

    test('the input entity is never mutated', () async {
      await cubit.toggleDone(_open);
      await cubit.delete(_open);
      await cubit.addItem(_open, 'X');
      expect(_open.isDone, isFalse);
      expect(_open.isDeleted, isFalse);
      expect(_open.items, hasLength(2));
    });
  });

  group('permission gating is per action', () {
    test('Delete off does not block Edit actions', () async {
      access.canDelete = false;
      await cubit.toggleDone(_open);
      expect(cubit.state.status, TodoActionStatus.success);
      await cubit.delete(_open);
      expect(cubit.state.errorMessage, TodoActionsCubit.permissionDenied);
      expect(repo.updated, hasLength(1));
    });

    test('Edit off does not block Delete / Restore', () async {
      access.canEdit = false;
      await cubit.delete(_open);
      expect(cubit.state.status, TodoActionStatus.success);
      await cubit.restore(_deleted);
      expect(cubit.state.status, TodoActionStatus.success);
      expect(repo.updated, hasLength(2));
    });

    test('Restore off blocks only restore', () async {
      access.canRestore = false;
      await cubit.restore(_deleted);
      expect(cubit.state.errorMessage, TodoActionsCubit.permissionDenied);
      await cubit.delete(_open);
      expect(cubit.state.status, TodoActionStatus.success);
    });
  });

  group('reset / close', () {
    test('reset returns to idle after a failure', () async {
      access.canEdit = false;
      await cubit.toggleDone(_open);
      expect(cubit.state.status, TodoActionStatus.failure);
      cubit.reset();
      expect(cubit.state.status, TodoActionStatus.idle);
      expect(cubit.state.kind, isNull);
      expect(cubit.state.errorMessage, isNull);
    });

    test('a write finishing after close does not throw or emit', () async {
      final Completer<void> gate = Completer<void>();
      final _SlowRepository slow = _SlowRepository(gate.future);
      final TodoActionsCubit c = TodoActionsCubit(
        repository: slow,
        access: access,
        logService: log,
      );
      final Future<void> pending = c.toggleDone(_open);
      expect(c.state.status, TodoActionStatus.submitting);
      await c.close();
      gate.complete();
      await pending;
      expect(c.isClosed, isTrue);
      expect(c.state.status, TodoActionStatus.submitting);
    });
  });
}

/// Repository whose update waits on [gate] (close-while-writing test).
class _SlowRepository extends FakeTodoRepository {
  _SlowRepository(this.gate);

  final Future<void> gate;

  @override
  Future<void> updateTodo({required TodoEntity todo}) async {
    await gate;
    updated.add(todo);
  }
}
