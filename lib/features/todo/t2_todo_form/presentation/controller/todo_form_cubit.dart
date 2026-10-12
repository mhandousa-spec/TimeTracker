/// Module: todo / t2_todo_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_cubit.dart
/// Purpose: Declares `TodoFormCubit` — drives "Creating To Do List" and
///          "Editing To Do List": draft edits, validation, submit, logging.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// The page owns the TextEditingControllers (MASTER_CODE_REVIEW §16) and
/// forwards text through [nameChanged] / [descriptionChanged]. The confirm
/// dialog ("Are you sure…?") is shown by the page BEFORE [submit] is called.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_log_service.dart';
import 'package:knowticed_plus/features/todo/domain/base_repository/todo_base_repository.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

part 'todo_form_state.dart';

class TodoFormCubit extends Cubit<TodoFormState> {
  TodoFormCubit({
    required TodoBaseRepository repository,
    required TodoAccess access,
    required TodoLogService logService,
    TodoEntity? initial,
  })  : _repository = repository,
        _access = access,
        _log = logService,
        _original = initial,
        super(
          TodoFormState(
            draft: initial ??
                TodoEntity(
                    id: '', ownerEmail: access.currentUserEmail, name: ''),
            original: initial,
            isEdit: initial != null,
            priorityChosen: initial != null,
          ),
        );

  final TodoBaseRepository _repository;
  final TodoAccess _access;
  final TodoLogService _log;
  final TodoEntity? _original;

  @override
  void emit(TodoFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void nameChanged(String value) => _update(
        state.draft.copyWith(name: value),
        nameTouched: state.nameTouched || value.trim().isNotEmpty,
      );

  void descriptionChanged(String value) =>
      _update(state.draft.copyWith(description: value));

  void priorityChanged(TodoPriority value) => _update(
        state.draft.copyWith(priority: value),
        priorityChosen: true,
      );

  /// Turning Scheduled off clears dates and reminders so nothing stale is
  /// saved; turning it on seeds one "1 Hour" first reminder like the Figma.
  void scheduledToggled(bool value) => _update(
        value
            ? state.draft.copyWith(
                isScheduled: true,
                reminders: state.draft.reminders.isEmpty
                    ? const <TodoReminder>[TodoReminder()]
                    : state.draft.reminders,
              )
            : state.draft.copyWith(
                isScheduled: false,
                clearSchedule: true,
                reminders: const <TodoReminder>[],
              ),
      );

  void startChanged(DateTime value) =>
      _update(state.draft.copyWith(startAt: value));

  void endChanged(DateTime value) =>
      _update(state.draft.copyWith(endAt: value));

  /// "+ Reminder". Ignored once [kTodoMaxReminders] exist (the page also
  /// hides the button then).
  void addReminder() {
    if (!state.canAddReminder) return;
    _update(
      state.draft.copyWith(
        reminders: <TodoReminder>[
          ...state.draft.reminders,
          const TodoReminder(),
        ],
      ),
    );
  }

  /// Function Name: [updateReminder]
  ///
  /// Purpose: Edit one reminder's stepper value or unit.
  ///
  /// Parameters:
  ///   [int] index: position in the list.
  ///   [TodoReminder] reminder: the replacement (value clamped to
  ///   [kTodoStepperMin]…[kTodoStepperMax]).
  ///
  /// Return type: [void]
  void updateReminder(int index, TodoReminder reminder) {
    final List<TodoReminder> list = <TodoReminder>[...state.draft.reminders];
    if (index < 0 || index >= list.length) return;
    list[index] = reminder.copyWith(value: _clampStep(reminder.value));
    _update(state.draft.copyWith(reminders: list));
  }

  void removeReminder(int index) {
    final List<TodoReminder> list = <TodoReminder>[...state.draft.reminders];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    _update(state.draft.copyWith(reminders: list));
  }

  void frequencyToggled(bool value) =>
      _update(state.draft.copyWith(hasFrequency: value));

  /// Function Name: [frequencyChanged]
  ///
  /// Purpose: Edit the recurrence (stepper, unit, weekdays). Interval is
  /// clamped to [kTodoStepperMin]…[kTodoStepperMax]; weekdays are cleared
  /// when leaving Weekly. Switching TO Weekly with no day picked pre-selects
  /// the start date's weekday (today's when unscheduled) — the same default
  /// `TodoFrequency.occursOn` uses — so the chips appear with one yellow day.
  ///
  /// Parameters:
  ///   [TodoFrequency] frequency
  ///
  /// Return type: [void]
  void frequencyChanged(TodoFrequency frequency) {
    final bool weekly = frequency.unit == TodoFrequencyUnit.weekly;
    final bool enteringWeekly =
        weekly && state.draft.frequency.unit != TodoFrequencyUnit.weekly;
    List<int> days = weekly ? frequency.weekDays : const <int>[];
    if (enteringWeekly && days.isEmpty) {
      days = <int>[(state.draft.startAt ?? DateTime.now()).weekday];
    }
    _update(
      state.draft.copyWith(
        frequency: frequency.copyWith(
          interval: _clampStep(frequency.interval),
          weekDays: days,
        ),
      ),
    );
  }

  /// Function Name: [validate]
  ///
  /// Purpose: Run validation and reveal errors. The page calls this before
  /// opening the confirm dialog (only opening it when this returns true), and
  /// when the DISABLED Create / Save is tapped, to show what is missing.
  ///
  /// Return type: [bool] — true when the draft can be submitted.
  bool validate() {
    final Set<TodoFormError> errors = state.validationErrors;
    emit(state.copyWith(errors: errors, submitAttempted: true));
    return errors.isEmpty;
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Create or save the to-do after the user confirmed. Checks the
  /// Create/Edit permission again, writes, then logs.
  ///
  /// Return type: [Future<void>] — ends in `success` or `failure`.
  Future<void> submit() async {
    if (!validate() || !state.canSubmit) return;
    final bool allowed = state.isEdit ? _access.canEdit : _access.canCreate;
    if (!allowed) {
      emit(state.copyWith(
        status: TodoFormStatus.failure,
        errors: <TodoFormError>{TodoFormError.permissionDenied},
      ));
      return;
    }
    emit(state.copyWith(
        status: TodoFormStatus.submitting, clearErrorMessage: true));
    try {
      if (state.isEdit) {
        await _repository.updateTodo(todo: state.draft);
      } else {
        await _repository.createTodo(todo: state.draft);
      }
      _logSubmit();
      emit(state.copyWith(status: TodoFormStatus.success));
    } catch (error) {
      emit(state.copyWith(
        status: TodoFormStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Back to editing after a failure dialog closes.
  void acknowledgeFailure() =>
      emit(state.copyWith(status: TodoFormStatus.editing));

  /// Applies [draft] and, once the user has tried to submit, refreshes the
  /// visible errors from the NEW state (so picking a priority clears its
  /// error on the same frame).
  void _update(TodoEntity draft, {bool? priorityChosen, bool? nameTouched}) {
    final TodoFormState next = state.copyWith(
      draft: draft,
      priorityChosen: priorityChosen,
      nameTouched: nameTouched,
    );
    emit(next.submitAttempted
        ? next.copyWith(errors: next.validationErrors)
        : next);
  }

  static int _clampStep(int value) {
    if (value < kTodoStepperMin) return kTodoStepperMin;
    if (value > kTodoStepperMax) return kTodoStepperMax;
    return value;
  }

  /// Create → "create"; edit → "update" plus the specific actions the owner
  /// asked to see (priority change, recurrence set).
  void _logSubmit() {
    final TodoEntity? before = _original;
    final TodoEntity after = state.draft;
    if (before == null) {
      _log.log(TodoLogService.actionCreate);
      if (after.hasFrequency) _log.log(TodoLogService.actionSetRecurrence);
      return;
    }
    _log.log(TodoLogService.actionUpdate);
    if (before.priority != after.priority) {
      _log.log(TodoLogService.actionChangePriority);
    }
    if (after.hasFrequency &&
        (!before.hasFrequency ||
            before.frequency.unit != after.frequency.unit ||
            before.frequency.interval != after.frequency.interval)) {
      _log.log(TodoLogService.actionSetRecurrence);
    }
  }
}
