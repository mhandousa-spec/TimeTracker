/// Module: todo / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: todo_model.dart
/// Purpose: Declares `TodoModel` — Firestore <-> `TodoEntity` mapping for one
///          "indexed history" document under
///          `Modules/todo/{email}`.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Every field is a LIST of past values aligned with `timestamps`
/// (`Timestamp`s); the current value is the last element (rules in
/// `TodoHistoryCodec`). List fields wrap each entry as `{Values: [...]}` (see
/// `TodoPartsMapper`). The owner is NOT stored in the document — it is the
/// `{email}` folder the document lives in, and `TodoEntity.ownerEmail` is
/// filled from that path when reading. Everything that knows about
/// `Timestamp` and field-name strings lives in this folder, so the entity
/// stays plain Dart.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/todo/data/models/todo_history_codec.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_history_row.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_parts_mapper.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';

class TodoModel {
  const TodoModel._();

  /// Field names (Title_Snake_Case, owner-approved 7/10/2026). Each one holds
  /// a history list. A typo here is a silently empty screen.
  static const String fTodoId = 'To_Do_Id';
  static const String fName = 'To_Do_Name';
  static const String fDescription = 'Description';
  static const String fPriority = 'Priority_Level';
  static const String fIsDone = 'Is_Completed';
  static const String fCompletedAt = 'Completion_Date';
  static const String fIsDeleted = 'Is_Deleted';
  static const String fDeletedAt = 'Deletion_Date';
  static const String fIsScheduled = 'Is_Scheduled';
  static const String fStartAt = 'Start_Date_Time';
  static const String fEndAt = 'Due_Date_Time';
  static const String fReminders = 'Reminders';
  static const String fHasFrequency = 'Is_Recurring';
  static const String fFrequency = 'Recurrence';
  static const String fItems = 'Checklist_Items';
  static const String fCreatedAt = 'Creation_Date';
  static const String fTimestamps = TodoHistoryCodec.fTimestamps;

  /// Function Name: [fromSnapshot]
  ///
  /// Purpose: Read one document (see [fromMap]). The owner comes from
  /// [ownerEmail] when given, else from the document's path
  /// (`.../Modules/todo/{email}/{id}` — the collection id is the email).
  ///
  /// Parameters:
  ///   [DocumentSnapshot<Map<String, dynamic>>] snapshot
  ///   [String?] ownerEmail: the folder email, if the caller knows it.
  ///
  /// Return type: [TodoEntity]
  static TodoEntity fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    String? ownerEmail,
  }) =>
      fromMap(
        snapshot.id,
        snapshot.data() ?? <String, dynamic>{},
        ownerEmail: ownerEmail ?? snapshot.reference.parent.id,
      );

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  /// Missing or short lists read as defaults.
  ///
  /// Parameters:
  ///   [String] id: the document id.
  ///   [Map<String, dynamic>] map: the raw document.
  ///   [String] ownerEmail: the `{email}` folder the document lives in.
  ///
  /// Return type: [TodoEntity]
  static TodoEntity fromMap(
    String id,
    Map<String, dynamic> map, {
    String ownerEmail = '',
  }) {
    Object? now(String key) => TodoHistoryCodec.lastOf(map, key);
    return TodoEntity(
      id: id.isNotEmpty ? id : _string(now(fTodoId)),
      ownerEmail: ownerEmail.trim().toLowerCase(),
      name: _string(now(fName)),
      description: _string(now(fDescription)),
      priority: TodoPriority.fromStorageKey(_string(now(fPriority))),
      isDone: now(fIsDone) == true,
      completedAt: _date(now(fCompletedAt)),
      isDeleted: now(fIsDeleted) == true,
      deletedAt: _date(now(fDeletedAt)),
      isScheduled: now(fIsScheduled) == true,
      startAt: _date(now(fStartAt)),
      endAt: _date(now(fEndAt)),
      reminders: TodoPartsMapper.remindersFrom(now(fReminders)),
      hasFrequency: now(fHasFrequency) == true,
      frequency: TodoPartsMapper.frequencyFrom(now(fFrequency)),
      items: TodoPartsMapper.itemsFrom(now(fItems)),
      createdAt: _date(now(fCreatedAt)),
      updatedAt: TodoHistoryCodec.lastWriteOf(map),
    );
  }

  /// Function Name: [toCreateMap]
  ///
  /// Purpose: The first version of a document: every field = `[value]`,
  /// `timestamps = [Timestamp(now)]`, `Creation_Date = [Timestamp(now)]`.
  ///
  /// Parameters:
  ///   [TodoEntity] todo: the draft.
  ///   [String] id: the new document id (also stored in `To_Do_Id`).
  ///   [DateTime] now: the write time.
  ///
  /// Return type: [Map<String, dynamic>]
  static Map<String, dynamic> toCreateMap(
    TodoEntity todo, {
    required String id,
    required DateTime now,
  }) =>
      TodoHistoryCodec.append(
        old: null,
        now: now,
        values: TodoHistoryRow.values(
          todo,
          id: id,
          createdAt: Timestamp.fromDate(now),
        ),
      );

  /// Function Name: [toAppendMap]
  ///
  /// Purpose: The next version of a stored document: the new value of EVERY
  /// field (changed or not) appended to its history, plus `timestamps`. The
  /// creation date carries forward from the stored document. Write the
  /// result with a full `set` (no merge).
  ///
  /// Parameters:
  ///   [Map<String, dynamic>?] old: the stored document.
  ///   [TodoEntity] todo: the full updated to-do.
  ///   [DateTime] now: the write time.
  ///
  /// Return type: [Map<String, dynamic>]
  static Map<String, dynamic> toAppendMap(
    Map<String, dynamic>? old,
    TodoEntity todo, {
    required DateTime now,
  }) {
    final Map<String, dynamic> stored = old ?? <String, dynamic>{};
    final DateTime? createdAt =
        _date(TodoHistoryCodec.lastOf(stored, fCreatedAt)) ?? todo.createdAt;
    return TodoHistoryCodec.append(
      old: stored,
      now: now,
      values: TodoHistoryRow.values(
        todo,
        id: todo.id,
        createdAt: createdAt == null ? null : Timestamp.fromDate(createdAt),
      ),
    );
  }

  static String _string(Object? raw) => raw is String ? raw : '';

  static DateTime? _date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }
}
