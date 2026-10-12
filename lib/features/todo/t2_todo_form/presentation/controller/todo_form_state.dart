/// Module: todo / t2_todo_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: todo_form_state.dart
/// Purpose: Declares `TodoFormState` — the draft behind "Creating / Editing To
///          Do List" plus validation and submit status.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Errors are emitted as [TodoFormError] KEYS, never translated strings
/// (MASTER_CODE_REVIEW §16) — the page maps them with `S.of(context)`.

part of 'todo_form_cubit.dart';

enum TodoFormStatus { editing, submitting, success, failure }

/// Most reminders one to-do can carry; "+ Reminder" disappears at this count.
const int kTodoMaxReminders = 3;

/// Bounds of the "− N +" steppers (reminder value, frequency interval).
const int kTodoStepperMin = 1;
const int kTodoStepperMax = 99;

enum TodoFormError {
  nameRequired,
  priorityRequired,
  datesRequired,
  endAfterStart,
  weekDaysRequired,
  permissionDenied,
}

@immutable
class TodoFormState {
  const TodoFormState({
    required this.draft,
    this.original,
    this.isEdit = false,
    this.priorityChosen = false,
    this.status = TodoFormStatus.editing,
    this.errors = const <TodoFormError>{},
    this.submitAttempted = false,
    this.nameTouched = false,
    this.errorMessage,
  });

  /// Everything the form edits, held as an entity so the repository receives
  /// exactly what the user saw.
  final TodoEntity draft;

  /// The to-do as it was when the edit form opened (null when creating) —
  /// [hasChanges] compares the draft against it.
  final TodoEntity? original;
  final bool isEdit;

  /// The Priority dropdown starts on "Choose" for a new to-do; the entity
  /// always carries a priority, so this flag records whether the user picked.
  final bool priorityChosen;
  final TodoFormStatus status;
  final Set<TodoFormError> errors;

  /// Errors are only shown after the first Create/Save tap (enabled or not).
  final bool submitAttempted;

  /// The user has typed a name at least once — clearing it again then shows
  /// "required" live, before any Create/Save tap.
  final bool nameTouched;

  /// Repository failure text (already safe to show), for the failure dialog.
  final String? errorMessage;

  bool get isSubmitting => status == TodoFormStatus.submitting;

  /// "+ Reminder" is offered only below [kTodoMaxReminders].
  bool get canAddReminder => draft.reminders.length < kTodoMaxReminders;

  /// Function Name: [validationErrors]
  ///
  /// Purpose: Every rule the draft currently breaks, whether or not the
  /// errors are being shown yet. Single source for [canSubmit] and the
  /// cubit's `validate()`.
  ///
  /// Return type: [Set<TodoFormError>]
  Set<TodoFormError> get validationErrors {
    final TodoEntity d = draft;
    final Set<TodoFormError> found = <TodoFormError>{};
    if (d.name.trim().isEmpty) found.add(TodoFormError.nameRequired);
    if (!priorityChosen) found.add(TodoFormError.priorityRequired);
    if (d.isScheduled) {
      final DateTime? start = d.startAt;
      final DateTime? end = d.endAt;
      if (start == null || end == null) {
        found.add(TodoFormError.datesRequired);
      } else if (!end.isAfter(start)) {
        found.add(TodoFormError.endAfterStart);
      }
    }
    if (d.hasFrequency &&
        d.frequency.unit == TodoFrequencyUnit.weekly &&
        d.frequency.weekDays.isEmpty) {
      found.add(TodoFormError.weekDaysRequired);
    }
    return found;
  }

  /// Function Name: [hasChanges]
  ///
  /// Purpose: Edit mode — whether the draft differs from [original] in
  /// anything the form edits (name, description, priority, schedule,
  /// reminders, frequency). Always true when creating.
  ///
  /// Return type: [bool]
  bool get hasChanges {
    final TodoEntity? before = original;
    if (before == null) return true;
    final TodoEntity after = draft;
    return after.name.trim() != before.name.trim() ||
        after.description.trim() != before.description.trim() ||
        after.priority != before.priority ||
        !_sameSchedule(before, after) ||
        !_sameFrequency(before, after);
  }

  /// Create / Save is enabled (yellow) only when the draft is valid, nothing
  /// is in flight and — when editing — something actually changed.
  bool get canSubmit => !isSubmitting && validationErrors.isEmpty && hasChanges;

  static bool _sameSchedule(TodoEntity a, TodoEntity b) {
    if (a.isScheduled != b.isScheduled) return false;
    if (!a.isScheduled) return true;
    if (a.startAt != b.startAt || a.endAt != b.endAt) return false;
    if (a.reminders.length != b.reminders.length) return false;
    for (int i = 0; i < a.reminders.length; i++) {
      if (a.reminders[i].value != b.reminders[i].value ||
          a.reminders[i].unit != b.reminders[i].unit) {
        return false;
      }
    }
    return true;
  }

  static bool _sameFrequency(TodoEntity a, TodoEntity b) {
    if (a.hasFrequency != b.hasFrequency) return false;
    if (!a.hasFrequency) return true;
    final TodoFrequency fa = a.frequency;
    final TodoFrequency fb = b.frequency;
    if (fa.interval != fb.interval || fa.unit != fb.unit) return false;
    if (fa.unit != TodoFrequencyUnit.weekly) return true;
    final List<int> da = <int>[...fa.weekDays]..sort();
    final List<int> db = <int>[...fb.weekDays]..sort();
    return listEquals(da, db);
  }

  /// Function Name: [showError]
  ///
  /// Purpose: Whether the page should draw [error] under its field.
  /// Shown after a submit attempt, and LIVE for mistakes the user just made
  /// (end before start, every weekday unticked, a typed name cleared) —
  /// Create/Save is disabled while any rule fails, so this is the only
  /// place those reasons surface. Untouched empty fields never nag.
  ///
  /// Parameters:
  ///   [TodoFormError] error
  ///
  /// Return type: [bool]
  bool showError(TodoFormError error) {
    if (submitAttempted && errors.contains(error)) return true;
    final bool live = error == TodoFormError.endAfterStart ||
        error == TodoFormError.weekDaysRequired ||
        (error == TodoFormError.nameRequired && (nameTouched || isEdit));
    return live && validationErrors.contains(error);
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [TodoFormState]
  TodoFormState copyWith({
    TodoEntity? draft,
    bool? priorityChosen,
    TodoFormStatus? status,
    Set<TodoFormError>? errors,
    bool? submitAttempted,
    bool? nameTouched,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) =>
      TodoFormState(
        draft: draft ?? this.draft,
        original: original,
        isEdit: isEdit,
        priorityChosen: priorityChosen ?? this.priorityChosen,
        status: status ?? this.status,
        errors: errors ?? this.errors,
        submitAttempted: submitAttempted ?? this.submitAttempted,
        nameTouched: nameTouched ?? this.nameTouched,
        errorMessage:
            clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      );
}
