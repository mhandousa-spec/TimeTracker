/// Module: test / todo / data
///
///*************************** FILE INFO ****************************///
/// File Name: todo_model_test.dart
/// Purpose: Unit tests for `TodoModel` — create shape (no owner / creator /
///          modifier fields, `Timestamp` timestamps), append-on-update keeps
///          every list aligned, parsing from a raw map (owner from the path),
///          missing-field tolerance and legacy int timestamps.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - per-email schema (owner-approved).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/data/models/todo_model.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_parts_mapper.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_parts.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_priority.dart';
import 'package:knowticed_plus/features/todo/domain/enums/todo_time_unit.dart';

void main() {
  final DateTime created = DateTime(2026, 10, 7, 9);
  final DateTime edited = DateTime(2026, 10, 7, 10);
  final DateTime start = DateTime(2026, 10, 16, 14, 21);
  final DateTime end = DateTime(2026, 10, 16, 16);

  /// The full, final field list of a to-do document.
  const Set<String> allFields = <String>{
    'To_Do_Id',
    'To_Do_Name',
    'Description',
    'Priority_Level',
    'Is_Completed',
    'Completion_Date',
    'Is_Deleted',
    'Deletion_Date',
    'Is_Scheduled',
    'Start_Date_Time',
    'Due_Date_Time',
    'Reminders',
    'Is_Recurring',
    'Recurrence',
    'Checklist_Items',
    'Creation_Date',
    'timestamps',
  };

  final TodoEntity draft = TodoEntity(
    id: '',
    ownerEmail: 'Owner@Co.com',
    name: '  Prepare interview  ',
    description: 'Round 2',
    priority: TodoPriority.high,
    isScheduled: true,
    startAt: start,
    endAt: end,
    reminders: const <TodoReminder>[
      TodoReminder(value: 2, unit: TodoReminderUnit.hour),
    ],
    hasFrequency: true,
    frequency: const TodoFrequency(
      interval: 1,
      unit: TodoFrequencyUnit.weekly,
      weekDays: <int>[1, 3],
    ),
    items: const <TodoItem>[TodoItem(id: 'i1', title: 'Soft skills')],
  );

  Map<String, dynamic> create() =>
      TodoModel.toCreateMap(draft, id: 'doc1', now: created);

  group('toCreateMap', () {
    test('exactly the final field list — no owner / creator / modifier', () {
      final Map<String, dynamic> map = create();
      expect(map.keys.toSet(), allFields);
      expect(map.containsKey('Owner_Email'), isFalse);
      expect(map.containsKey('Created_By'), isFalse);
      expect(map.containsKey('Modified_By'), isFalse);
    });

    test('every field is a one-entry list; timestamps are Timestamps', () {
      final Map<String, dynamic> map = create();
      for (final MapEntry<String, dynamic> e in map.entries) {
        expect(e.value, isA<List<dynamic>>(), reason: e.key);
        expect(e.value, hasLength(1), reason: e.key);
      }
      expect(map[TodoModel.fTimestamps], <Timestamp>[
        Timestamp.fromDate(created),
      ]);
      expect((map[TodoModel.fTimestamps] as List).single, isA<Timestamp>());
      expect(map[TodoModel.fTodoId], <Object?>['doc1']);
      expect(map[TodoModel.fName], <Object?>['Prepare interview']);
      expect(map[TodoModel.fPriority], <Object?>['high']);
      expect(map[TodoModel.fCreatedAt], <Object?>[Timestamp.fromDate(created)]);
      expect(map[TodoModel.fStartAt], <Object?>[Timestamp.fromDate(start)]);
      expect(map[TodoModel.fCompletedAt], <Object?>[null]);
    });

    test('list fields wrap each entry in {Values: [...]} (no nested arrays)',
        () {
      final Map<String, dynamic> map = create();
      final Object? reminders = (map[TodoModel.fReminders] as List).single;
      expect(reminders, <String, dynamic>{
        TodoPartsMapper.fListValues: <Map<String, dynamic>>[
          <String, dynamic>{'Reminder_Value': 2, 'Reminder_Unit': 'hour'},
        ],
      });
      final Object? items = (map[TodoModel.fItems] as List).single;
      expect(items, <String, dynamic>{
        TodoPartsMapper.fListValues: <Map<String, dynamic>>[
          <String, dynamic>{
            'Item_Id': 'i1',
            'Item_Title': 'Soft skills',
            'Is_Item_Completed': false,
          },
        ],
      });
      for (final Object? v in map.values) {
        for (final Object? entry in v as List) {
          expect(entry, isNot(isA<List<dynamic>>()));
        }
      }
    });
  });

  group('toAppendMap', () {
    test('appends the new value of every field + a Timestamp, aligned', () {
      final Map<String, dynamic> stored = create();
      final TodoEntity edit = TodoModel.fromMap('doc1', stored)
          .copyWith(name: 'Renamed', isDone: true, completedAt: edited);

      final Map<String, dynamic> next =
          TodoModel.toAppendMap(stored, edit, now: edited);

      expect(next.keys.toSet(), allFields);
      for (final MapEntry<String, dynamic> e in next.entries) {
        expect(e.value, hasLength(2), reason: e.key);
      }
      expect(next[TodoModel.fName], <Object?>['Prepare interview', 'Renamed']);
      expect(next[TodoModel.fIsDone], <Object?>[false, true]);
      expect(next[TodoModel.fCompletedAt], <Object?>[
        null,
        Timestamp.fromDate(edited),
      ]);
      expect(next[TodoModel.fDescription], <Object?>['Round 2', 'Round 2']);
      expect(next[TodoModel.fCreatedAt], <Object?>[
        Timestamp.fromDate(created),
        Timestamp.fromDate(created),
      ]);
      expect(next[TodoModel.fTimestamps], <Timestamp>[
        Timestamp.fromDate(created),
        Timestamp.fromDate(edited),
      ]);

      final TodoEntity read = TodoModel.fromMap('doc1', next);
      expect(read.name, 'Renamed');
      expect(read.isDone, isTrue);
      expect(read.completedAt, edited);
      expect(read.createdAt, created);
      expect(read.updatedAt, edited);
    });

    test('drops stray fields (old Owner_Email / Created_By / Modified_By)', () {
      final Map<String, dynamic> stored = <String, dynamic>{
        ...create(),
        'Owner_Email': <Object?>['owner@co.com'],
        'Created_By': <Object?>['owner@co.com'],
        'Modified_By': <Object?>['owner@co.com'],
      };
      final Map<String, dynamic> next = TodoModel.toAppendMap(
        stored,
        TodoModel.fromMap('doc1', stored),
        now: edited,
      );
      expect(next.keys.toSet(), allFields);
    });

    test('upgrades legacy int-ms timestamps to Timestamps on append', () {
      final Map<String, dynamic> stored = create()
        ..[TodoModel.fTimestamps] = <dynamic>[created.millisecondsSinceEpoch];
      final Map<String, dynamic> next = TodoModel.toAppendMap(
        stored,
        TodoModel.fromMap('doc1', stored).copyWith(name: 'B'),
        now: edited,
      );
      expect(next[TodoModel.fTimestamps], <Timestamp>[
        Timestamp.fromDate(created),
        Timestamp.fromDate(edited),
      ]);
    });
  });

  group('fromMap', () {
    test('reads the LAST element of every history list', () {
      final TodoEntity todo = TodoModel.fromMap('doc1', <String, dynamic>{
        TodoModel.fName: <dynamic>['A', 'B', 'C'],
        TodoModel.fPriority: <dynamic>['low', 'high'],
        TodoModel.fIsDeleted: <dynamic>[false, true],
        TodoModel.fDeletedAt: <dynamic>[null, Timestamp.fromDate(edited)],
        TodoModel.fReminders: <dynamic>[
          <String, dynamic>{TodoPartsMapper.fListValues: <dynamic>[]},
          <String, dynamic>{
            TodoPartsMapper.fListValues: <dynamic>[
              <String, dynamic>{'Reminder_Value': 3, 'Reminder_Unit': 'day'},
            ],
          },
        ],
        TodoModel.fTimestamps: <dynamic>[
          Timestamp.fromDate(created),
          Timestamp.fromDate(created),
          Timestamp.fromDate(edited),
        ],
      });
      expect(todo.id, 'doc1');
      expect(todo.name, 'C');
      expect(todo.priority, TodoPriority.high);
      expect(todo.isDeleted, isTrue);
      expect(todo.deletedAt, edited);
      expect(todo.reminders.single.value, 3);
      expect(todo.reminders.single.unit, TodoReminderUnit.day);
      expect(todo.updatedAt, edited);
    });

    test('owner comes from the path email (lower-cased), not the doc', () {
      final TodoEntity todo = TodoModel.fromMap(
        'doc1',
        create(),
        ownerEmail: ' Owner@Co.com ',
      );
      expect(todo.ownerEmail, 'owner@co.com');
      expect(TodoModel.fromMap('doc1', create()).ownerEmail, '');
    });

    test('accepts legacy int-ms timestamps for updatedAt', () {
      final TodoEntity todo = TodoModel.fromMap('x', <String, dynamic>{
        TodoModel.fName: <dynamic>['A'],
        TodoModel.fTimestamps: <dynamic>[edited.millisecondsSinceEpoch],
      });
      expect(todo.updatedAt, edited);
    });

    test('tolerates an empty document and empty lists', () {
      final TodoEntity todo = TodoModel.fromMap('x', <String, dynamic>{
        TodoModel.fName: <dynamic>[],
        TodoModel.fItems: <dynamic>[],
      });
      expect(todo.name, '');
      expect(todo.priority, TodoPriority.medium);
      expect(todo.isDone, isFalse);
      expect(todo.items, isEmpty);
      expect(todo.reminders, isEmpty);
      expect(todo.frequency.interval, 1);
      expect(todo.createdAt, isNull);
      expect(todo.updatedAt, isNull);
      expect(TodoModel.fromMap('y', <String, dynamic>{}).name, '');
    });

    test('treats non-list values as a one-entry history', () {
      final TodoEntity todo = TodoModel.fromMap('x', <String, dynamic>{
        TodoModel.fName: 'Flat',
        TodoModel.fIsDone: true,
      });
      expect(todo.name, 'Flat');
      expect(todo.isDone, isTrue);
    });
  });
}
