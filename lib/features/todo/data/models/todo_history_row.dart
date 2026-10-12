/// Module: todo / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: todo_history_row.dart
/// Purpose: Declares `TodoHistoryRow` — the value of every to-do field for
///          ONE history row (the entry a write appends to each list).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Split out of `TodoModel` to keep that file under the 200-line model limit
/// (MASTER_CODE_REVIEW §10). Field names come from `TodoModel`. There is no
/// owner / creator / modifier field: to-dos are personal and live under the
/// owner's own `Modules/todo/{email}` collection (owner decision 7/10/2026).

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/todo/data/models/todo_model.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_parts_mapper.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';

class TodoHistoryRow {
  const TodoHistoryRow._();

  /// Function Name: [values]
  ///
  /// Purpose: Field name -> new value for every field of a to-do, in a fixed
  /// order. Dates are `Timestamp`s (or null); list fields are wrapped maps.
  ///
  /// Parameters:
  ///   [TodoEntity] todo: the state being written.
  ///   [String] id: the document id (`To_Do_Id`).
  ///   [Timestamp?] createdAt: creation time.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> values(
    TodoEntity todo, {
    required String id,
    required Timestamp? createdAt,
  }) =>
      <String, Object?>{
        TodoModel.fTodoId: id,
        TodoModel.fName: todo.name.trim(),
        TodoModel.fDescription: todo.description.trim(),
        TodoModel.fPriority: todo.priority.storageKey,
        TodoModel.fIsDone: todo.isDone,
        TodoModel.fCompletedAt: _timestamp(todo.completedAt),
        TodoModel.fIsDeleted: todo.isDeleted,
        TodoModel.fDeletedAt: _timestamp(todo.deletedAt),
        TodoModel.fIsScheduled: todo.isScheduled,
        TodoModel.fStartAt: todo.isScheduled ? _timestamp(todo.startAt) : null,
        TodoModel.fEndAt: todo.isScheduled ? _timestamp(todo.endAt) : null,
        TodoModel.fReminders: TodoPartsMapper.remindersTo(
          todo.isScheduled ? todo.reminders : const <TodoReminder>[],
        ),
        TodoModel.fHasFrequency: todo.hasFrequency,
        TodoModel.fFrequency: TodoPartsMapper.frequencyTo(todo.frequency),
        TodoModel.fItems: TodoPartsMapper.itemsTo(todo.items),
        TodoModel.fCreatedAt: createdAt,
      };

  static Timestamp? _timestamp(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);
}
