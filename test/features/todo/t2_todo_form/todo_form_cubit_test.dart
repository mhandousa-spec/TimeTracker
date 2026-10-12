/// Module: test / todo / t2_todo_form
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_cubit_test.dart
/// Purpose: `TodoFormCubit` logic the page tests cannot reach: what each
///          submit logs (create / update / change priority / set
///          recurrence), submit blocked when invalid or unchanged,
///          permission denied, repository failure → acknowledgeFailure,
///          Scheduled toggle, reminder clamp + cap, frequency rules and
///          validation keys.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/controller/todo_form_cubit.dart';

import '../_support/todo_test_fakes.dart';

final DateTime _start = DateTime(2026, 10, 16, 14, 21);
final DateTime _end = DateTime(2026, 10, 17, 9, 5);

TodoEntity _existing({
  TodoPriority priority = TodoPriority.high,
  bool hasFrequency = false,
  TodoFrequency frequency = const TodoFrequency(),
  bool scheduled = false,
  List<TodoReminder> reminders = const <TodoReminder>[],
}) =>
    TodoEntity(
      id: 'e1',
      ownerEmail: 'owner@test.local',
      name: 'Pay rent',
      description: 'Monthly',
      priority: priority,
      hasFrequency: hasFrequency,
      frequency: frequency,
      isScheduled: scheduled,
      startAt: scheduled ? _start : null,
      endAt: scheduled ? _end : null,
      reminders: reminders,
    );

void main() {
  late FakeTodoRepository repo;
  late FakeTodoAccess access;
  late FakeTodoLogService log;

  setUp(() {
    repo = FakeTodoRepository();
    access = FakeTodoAccess();
    log = FakeTodoLogService();
  });

  TodoFormCubit build([TodoEntity? initial]) => TodoFormCubit(
        repository: repo,
        access: access,
        logService: log,
        initial: initial,
      );

  /// A create-form cubit with a valid draft (name + priority).
  TodoFormCubit validCreate() => build()
    ..nameChanged('Buy milk')
    ..priorityChanged(TodoPriority.low);

  group('initial state', () {
    test('create: empty draft owned by the signed-in user, priority unpicked',
        () {
      final TodoFormCubit c = build();
      expect(c.state.isEdit, isFalse);
      expect(c.state.original, isNull);
      expect(c.state.draft.ownerEmail, 'owner@test.local');
      expect(c.state.draft.name, '');
      expect(c.state.priorityChosen, isFalse);
      expect(c.state.status, TodoFormStatus.editing);
      expect(c.state.hasChanges, isTrue);
      expect(c.state.canSubmit, isFalse);
    });

    test('edit: draft = initial, priority counts as chosen, nothing changed',
        () {
      final TodoEntity initial = _existing();
      final TodoFormCubit c = build(initial);
      expect(c.state.isEdit, isTrue);
      expect(c.state.draft, same(initial));
      expect(c.state.priorityChosen, isTrue);
      expect(c.state.hasChanges, isFalse);
      expect(c.state.canSubmit, isFalse);
    });
  });

  group('create submit', () {
    test('success: createTodo once, logs create only', () async {
      final TodoFormCubit c = validCreate();
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
      expect(repo.created, hasLength(1));
      expect(repo.created.single.name, 'Buy milk');
      expect(repo.created.single.priority, TodoPriority.low);
      expect(repo.updated, isEmpty);
      expect(log.actions, <String>[TodoLogService.actionCreate]);
    });

    test('recurring create also logs set recurrence', () async {
      final TodoFormCubit c = validCreate()..frequencyToggled(true);
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
      expect(log.actions, <String>[
        TodoLogService.actionCreate,
        TodoLogService.actionSetRecurrence,
      ]);
    });

    test('blocked when name missing: errors shown, no write, no log', () async {
      final TodoFormCubit c = build()..priorityChanged(TodoPriority.high);
      await c.submit();
      expect(c.state.status, TodoFormStatus.editing);
      expect(c.state.submitAttempted, isTrue);
      expect(c.state.errors, <TodoFormError>{TodoFormError.nameRequired});
      expect(repo.writeCount, 0);
      expect(log.actions, isEmpty);
    });

    test('blocked when priority not picked', () async {
      final TodoFormCubit c = build()..nameChanged('X');
      await c.submit();
      expect(c.state.errors, <TodoFormError>{TodoFormError.priorityRequired});
      expect(repo.writeCount, 0);
    });

    test('whitespace-only name counts as missing', () async {
      final TodoFormCubit c = build()
        ..nameChanged('   ')
        ..priorityChanged(TodoPriority.high);
      expect(c.validate(), isFalse);
      expect(c.state.errors, contains(TodoFormError.nameRequired));
    });

    test('Create permission off → failure with permissionDenied, no write',
        () async {
      access.canCreate = false;
      final TodoFormCubit c = validCreate();
      await c.submit();
      expect(c.state.status, TodoFormStatus.failure);
      expect(c.state.errors, <TodoFormError>{TodoFormError.permissionDenied});
      expect(repo.writeCount, 0);
      expect(log.actions, isEmpty);
    });

    test('Edit off does not block Create', () async {
      access.canEdit = false;
      final TodoFormCubit c = validCreate();
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
    });

    test(
        'repository failure → failure + message, no log; '
        'acknowledgeFailure → editing, retry succeeds', () async {
      repo.failWith = Exception('network down');
      final TodoFormCubit c = validCreate();
      await c.submit();
      expect(c.state.status, TodoFormStatus.failure);
      expect(c.state.errorMessage, contains('network down'));
      expect(log.actions, isEmpty);

      c.acknowledgeFailure();
      expect(c.state.status, TodoFormStatus.editing);
      expect(c.state.draft.name, 'Buy milk'); // draft kept

      repo.failWith = null;
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
      expect(c.state.errorMessage, isNull); // cleared on resubmit
      expect(repo.created, hasLength(1));
    });

    test('passes through submitting before success', () async {
      final TodoFormCubit c = validCreate();
      final List<TodoFormStatus> seen = <TodoFormStatus>[];
      final sub = c.stream.listen((TodoFormState s) => seen.add(s.status));
      await c.submit();
      await Future<void>.delayed(Duration.zero);
      expect(
          seen,
          containsAllInOrder(<TodoFormStatus>[
            TodoFormStatus.submitting,
            TodoFormStatus.success,
          ]));
      await sub.cancel();
    });
  });

  group('edit submit', () {
    test('unchanged edit is blocked: no write, no log', () async {
      final TodoFormCubit c = build(_existing());
      await c.submit();
      expect(c.state.status, TodoFormStatus.editing);
      expect(repo.writeCount, 0);
      expect(log.actions, isEmpty);
    });

    test('whitespace-only change to the name is not a change', () {
      final TodoFormCubit c = build(_existing())..nameChanged('Pay rent  ');
      expect(c.state.hasChanges, isFalse);
      expect(c.state.canSubmit, isFalse);
    });

    test('name change → updateTodo, logs update only', () async {
      final TodoFormCubit c = build(_existing())..nameChanged('Pay rent now');
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
      expect(repo.updated.single.name, 'Pay rent now');
      expect(repo.updated.single.id, 'e1');
      expect(repo.created, isEmpty);
      expect(log.actions, <String>[TodoLogService.actionUpdate]);
    });

    test('priority change logs update + change priority', () async {
      final TodoFormCubit c = build(_existing())
        ..priorityChanged(TodoPriority.low);
      await c.submit();
      expect(log.actions, <String>[
        TodoLogService.actionUpdate,
        TodoLogService.actionChangePriority,
      ]);
    });

    test('turning recurrence on logs update + set recurrence', () async {
      final TodoFormCubit c = build(_existing())..frequencyToggled(true);
      await c.submit();
      expect(log.actions, <String>[
        TodoLogService.actionUpdate,
        TodoLogService.actionSetRecurrence,
      ]);
    });

    test('changing the interval of an existing recurrence logs set recurrence',
        () async {
      final TodoFormCubit c = build(_existing(hasFrequency: true))
        ..frequencyChanged(const TodoFrequency(interval: 3));
      await c.submit();
      expect(log.actions, contains(TodoLogService.actionSetRecurrence));
    });

    test('changing the unit of an existing recurrence logs set recurrence',
        () async {
      final TodoFormCubit c = build(_existing(hasFrequency: true))
        ..frequencyChanged(
          const TodoFrequency(unit: TodoFrequencyUnit.monthly),
        );
      await c.submit();
      expect(log.actions, contains(TodoLogService.actionSetRecurrence));
    });

    test('recurrence unchanged (only name edited) does NOT log set recurrence',
        () async {
      final TodoFormCubit c = build(_existing(hasFrequency: true))
        ..nameChanged('Other');
      await c.submit();
      expect(log.actions, <String>[TodoLogService.actionUpdate]);
    });

    test('turning recurrence OFF logs update only', () async {
      final TodoFormCubit c = build(_existing(hasFrequency: true))
        ..frequencyToggled(false);
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
      expect(log.actions, <String>[TodoLogService.actionUpdate]);
    });

    test('priority + recurrence together log all three, in order', () async {
      final TodoFormCubit c = build(_existing())
        ..priorityChanged(TodoPriority.medium)
        ..frequencyToggled(true);
      await c.submit();
      expect(log.actions, <String>[
        TodoLogService.actionUpdate,
        TodoLogService.actionChangePriority,
        TodoLogService.actionSetRecurrence,
      ]);
    });

    test('Edit permission off → permissionDenied, no write', () async {
      access.canEdit = false;
      final TodoFormCubit c = build(_existing())..nameChanged('New');
      await c.submit();
      expect(c.state.status, TodoFormStatus.failure);
      expect(c.state.errors, <TodoFormError>{TodoFormError.permissionDenied});
      expect(repo.writeCount, 0);
      expect(log.actions, isEmpty);
    });

    test('Create off does not block Edit', () async {
      access.canCreate = false;
      final TodoFormCubit c = build(_existing())..nameChanged('New');
      await c.submit();
      expect(c.state.status, TodoFormStatus.success);
    });

    test('repository failure → failure then acknowledgeFailure → editing',
        () async {
      repo.failWith = Exception('rules');
      final TodoFormCubit c = build(_existing())..nameChanged('New');
      await c.submit();
      expect(c.state.status, TodoFormStatus.failure);
      expect(c.state.errorMessage, contains('rules'));
      expect(log.actions, isEmpty);
      c.acknowledgeFailure();
      expect(c.state.status, TodoFormStatus.editing);
      expect(c.state.canSubmit, isTrue);
    });

    test('description / schedule / reminder edits each count as a change', () {
      expect(
        (build(_existing())..descriptionChanged('Yearly')).state.hasChanges,
        isTrue,
      );
      expect(
        (build(_existing())..scheduledToggled(true)).state.hasChanges,
        isTrue,
      );
      final TodoEntity sched = _existing(
        scheduled: true,
        reminders: const <TodoReminder>[TodoReminder()],
      );
      expect(
        (build(sched)..updateReminder(0, const TodoReminder(value: 2)))
            .state
            .hasChanges,
        isTrue,
      );
      expect(
        (build(sched)..endChanged(_end.add(const Duration(hours: 1))))
            .state
            .hasChanges,
        isTrue,
      );
    });
  });

  group('scheduled toggle', () {
    test('on seeds one default "1 Hour" reminder', () {
      final TodoFormCubit c = build()..scheduledToggled(true);
      expect(c.state.draft.isScheduled, isTrue);
      expect(c.state.draft.reminders, hasLength(1));
      expect(c.state.draft.reminders.single.value, 1);
      expect(c.state.draft.reminders.single.unit, TodoReminderUnit.hour);
    });

    test('on keeps existing reminders instead of re-seeding', () {
      final TodoFormCubit c = build(
        _existing(
          reminders: const <TodoReminder>[
            TodoReminder(value: 5, unit: TodoReminderUnit.day),
            TodoReminder(value: 2),
          ],
        ),
      )..scheduledToggled(true);
      expect(c.state.draft.reminders.map((TodoReminder r) => r.value),
          <int>[5, 2]);
    });

    test('off clears start, end and every reminder', () {
      final TodoFormCubit c = build(
        _existing(
          scheduled: true,
          reminders: const <TodoReminder>[TodoReminder(), TodoReminder()],
        ),
      )..scheduledToggled(false);
      expect(c.state.draft.isScheduled, isFalse);
      expect(c.state.draft.startAt, isNull);
      expect(c.state.draft.endAt, isNull);
      expect(c.state.draft.reminders, isEmpty);
    });

    test('scheduled without dates → datesRequired', () {
      final TodoFormCubit c = validCreate()..scheduledToggled(true);
      expect(c.validate(), isFalse);
      expect(c.state.errors, <TodoFormError>{TodoFormError.datesRequired});
    });

    test('end before / equal to start → endAfterStart (shown live)', () {
      final TodoFormCubit c = validCreate()
        ..scheduledToggled(true)
        ..startChanged(_start)
        ..endChanged(_start);
      expect(c.state.validationErrors, <TodoFormError>{
        TodoFormError.endAfterStart,
      });
      expect(c.state.showError(TodoFormError.endAfterStart), isTrue);
      c.endChanged(_start.subtract(const Duration(minutes: 1)));
      expect(c.state.validationErrors, contains(TodoFormError.endAfterStart));
      c.endChanged(_end);
      expect(c.state.validationErrors, isEmpty);
      expect(c.state.canSubmit, isTrue);
    });
  });

  group('reminders', () {
    TodoFormCubit scheduled() => build()..scheduledToggled(true);

    test('value clamps to 1..99', () {
      final TodoFormCubit c = scheduled();
      c.updateReminder(0, const TodoReminder(value: 0));
      expect(c.state.draft.reminders[0].value, kTodoStepperMin);
      c.updateReminder(0, const TodoReminder(value: -7));
      expect(c.state.draft.reminders[0].value, 1);
      c.updateReminder(0, const TodoReminder(value: 100));
      expect(c.state.draft.reminders[0].value, kTodoStepperMax);
      c.updateReminder(0, const TodoReminder(value: 42));
      expect(c.state.draft.reminders[0].value, 42);
    });

    test('unit change is kept', () {
      final TodoFormCubit c = scheduled()
        ..updateReminder(0, const TodoReminder(unit: TodoReminderUnit.week));
      expect(c.state.draft.reminders[0].unit, TodoReminderUnit.week);
    });

    test('max 3: addReminder ignored at the cap', () {
      final TodoFormCubit c = scheduled()
        ..addReminder()
        ..addReminder();
      expect(c.state.draft.reminders, hasLength(kTodoMaxReminders));
      expect(c.state.canAddReminder, isFalse);
      c.addReminder();
      expect(c.state.draft.reminders, hasLength(3));
    });

    test('remove frees a slot again', () {
      final TodoFormCubit c = scheduled()
        ..addReminder()
        ..addReminder()
        ..removeReminder(1);
      expect(c.state.draft.reminders, hasLength(2));
      expect(c.state.canAddReminder, isTrue);
    });

    test('out-of-range indexes are ignored', () {
      final TodoFormCubit c = scheduled();
      c.updateReminder(5, const TodoReminder(value: 9));
      c.updateReminder(-1, const TodoReminder(value: 9));
      c.removeReminder(3);
      c.removeReminder(-1);
      expect(c.state.draft.reminders, hasLength(1));
      expect(c.state.draft.reminders.single.value, 1);
    });
  });

  group('frequency', () {
    test('interval clamps to 1..99', () {
      final TodoFormCubit c = validCreate()..frequencyToggled(true);
      c.frequencyChanged(const TodoFrequency(interval: 0));
      expect(c.state.draft.frequency.interval, 1);
      c.frequencyChanged(const TodoFrequency(interval: 500));
      expect(c.state.draft.frequency.interval, 99);
    });

    test('entering Weekly pre-selects the start date weekday', () {
      final TodoFormCubit c = validCreate()
        ..scheduledToggled(true)
        ..startChanged(_start) // Friday
        ..frequencyToggled(true)
        ..frequencyChanged(
          const TodoFrequency(unit: TodoFrequencyUnit.weekly),
        );
      expect(c.state.draft.frequency.weekDays, <int>[_start.weekday]);
    });

    test('entering Weekly unscheduled pre-selects today', () {
      final TodoFormCubit c = validCreate()
        ..frequencyToggled(true)
        ..frequencyChanged(
          const TodoFrequency(unit: TodoFrequencyUnit.weekly),
        );
      expect(c.state.draft.frequency.weekDays, <int>[DateTime.now().weekday]);
    });

    test('leaving Weekly clears the weekdays', () {
      final TodoFormCubit c = validCreate()
        ..frequencyToggled(true)
        ..frequencyChanged(const TodoFrequency(
          unit: TodoFrequencyUnit.weekly,
          weekDays: <int>[1, 3],
        ))
        ..frequencyChanged(const TodoFrequency(unit: TodoFrequencyUnit.daily));
      expect(c.state.draft.frequency.weekDays, isEmpty);
    });

    test('Weekly with every day unticked → weekDaysRequired (live)', () {
      final TodoFormCubit c = validCreate()
        ..frequencyToggled(true)
        ..frequencyChanged(
          const TodoFrequency(unit: TodoFrequencyUnit.weekly),
        )
        ..frequencyChanged(const TodoFrequency(
          unit: TodoFrequencyUnit.weekly,
          weekDays: <int>[],
        ));
      expect(
        c.state.validationErrors,
        <TodoFormError>{TodoFormError.weekDaysRequired},
      );
      expect(c.state.showError(TodoFormError.weekDaysRequired), isTrue);
      expect(c.state.canSubmit, isFalse);
    });

    test('weekday order does not count as a change on edit', () {
      final TodoEntity initial = _existing(
        hasFrequency: true,
        frequency: const TodoFrequency(
          unit: TodoFrequencyUnit.weekly,
          weekDays: <int>[1, 3],
        ),
      );
      final TodoFormCubit c = build(initial)
        ..frequencyChanged(const TodoFrequency(
          unit: TodoFrequencyUnit.weekly,
          weekDays: <int>[3, 1],
        ));
      expect(c.state.hasChanges, isFalse);
    });
  });

  group('error visibility', () {
    test('errors refresh live after the first submit attempt', () {
      final TodoFormCubit c = build()..validate();
      expect(c.state.errors, <TodoFormError>{
        TodoFormError.nameRequired,
        TodoFormError.priorityRequired,
      });
      c.priorityChanged(TodoPriority.high);
      expect(c.state.errors, <TodoFormError>{TodoFormError.nameRequired});
      c.nameChanged('X');
      expect(c.state.errors, isEmpty);
    });

    test('before any submit, untouched empty fields never show errors', () {
      final TodoFormCubit c = build();
      expect(c.state.showError(TodoFormError.nameRequired), isFalse);
      expect(c.state.showError(TodoFormError.priorityRequired), isFalse);
    });

    test('typing then clearing the name shows "required" live', () {
      final TodoFormCubit c = build()
        ..nameChanged('abc')
        ..nameChanged('');
      expect(c.state.nameTouched, isTrue);
      expect(c.state.showError(TodoFormError.nameRequired), isTrue);
    });

    test('a closed cubit ignores late calls', () async {
      final TodoFormCubit c = validCreate();
      await c.close();
      c.nameChanged('after close');
      expect(c.state.draft.name, 'Buy milk');
    });
  });
}
