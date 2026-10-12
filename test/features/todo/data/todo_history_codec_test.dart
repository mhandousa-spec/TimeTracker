/// Module: test / todo / data
///
///*************************** FILE INFO ****************************///
/// File Name: todo_history_codec_test.dart
/// Purpose: Unit tests for `TodoHistoryCodec` — the generic "indexed history"
///          read/append rules (`timestamps` written as Firestore `Timestamp`s,
///          legacy int-ms stamps still read).
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Timestamp timestamps (owner-approved schema).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/todo/data/models/todo_history_codec.dart';

void main() {
  Timestamp ms(int value) => Timestamp.fromMillisecondsSinceEpoch(value);
  DateTime at(int value) => DateTime.fromMillisecondsSinceEpoch(value);

  group('historyOf / lastOf', () {
    test('missing field is an empty history and a null current value', () {
      expect(TodoHistoryCodec.historyOf(<String, dynamic>{}, 'A'), isEmpty);
      expect(TodoHistoryCodec.lastOf(<String, dynamic>{}, 'A'), isNull);
    });

    test('a list is the history; the last element is current', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'Status': <dynamic>['active', 'locked', 'active'],
      };
      expect(TodoHistoryCodec.historyOf(map, 'Status'), hasLength(3));
      expect(TodoHistoryCodec.lastOf(map, 'Status'), 'active');
    });

    test('a non-list value is a one-entry history', () {
      final Map<String, dynamic> map = <String, dynamic>{'Status': 'locked'};
      expect(TodoHistoryCodec.historyOf(map, 'Status'), <Object?>['locked']);
    });
  });

  group('timestampsOf / lastWriteOf', () {
    test('reads Timestamps, DateTimes and legacy int ms alike', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'timestamps': <dynamic>[10, ms(20), at(30), 'junk'],
      };
      expect(TodoHistoryCodec.timestampsOf(map), <Timestamp>[
        ms(10),
        ms(20),
        ms(30),
        TodoHistoryCodec.unknownTime,
      ]);
    });

    test('last write is the last stamp; unknown / missing reads null', () {
      expect(
        TodoHistoryCodec.lastWriteOf(<String, dynamic>{
          'timestamps': <dynamic>[ms(10), ms(5000)],
        }),
        at(5000),
      );
      expect(
        TodoHistoryCodec.lastWriteOf(<String, dynamic>{
          'timestamps': <dynamic>[0],
        }),
        isNull,
      );
      expect(TodoHistoryCodec.lastWriteOf(<String, dynamic>{}), isNull);
    });
  });

  group('append', () {
    test('create: every field becomes [value] and timestamps [Timestamp]', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: null,
        now: at(1000),
        values: <String, Object?>{'A': 1, 'B': null},
      );
      expect(out, <String, dynamic>{
        'A': <Object?>[1],
        'B': <Object?>[null],
        'timestamps': <Timestamp>[ms(1000)],
      });
    });

    test('appends one entry to every field, changed or not', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: <String, dynamic>{
          'A': <dynamic>[1, 2],
          'B': <dynamic>['x', 'x'],
          'timestamps': <dynamic>[ms(10), ms(20)],
        },
        now: at(30),
        values: <String, Object?>{'A': 3, 'B': 'x'},
      );
      expect(out['A'], <Object?>[1, 2, 3]);
      expect(out['B'], <Object?>['x', 'x', 'x']);
      expect(out['timestamps'], <Timestamp>[ms(10), ms(20), ms(30)]);
    });

    test('legacy int-ms timestamps are rewritten as Timestamps', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: <String, dynamic>{
          'A': <dynamic>[1],
          'timestamps': <dynamic>[10],
        },
        now: at(20),
        values: <String, Object?>{'A': 2},
      );
      expect(out['timestamps'], <Timestamp>[ms(10), ms(20)]);
    });

    test('short or missing histories are front-padded to stay aligned', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: <String, dynamic>{
          'A': <dynamic>[1, 2],
          'timestamps': <dynamic>[ms(10), ms(20)],
        },
        now: at(30),
        values: <String, Object?>{'A': 3, 'New_Field': true},
      );
      expect(out['New_Field'], <Object?>[null, null, true]);
      expect(out['A'], hasLength(3));
      expect(out['timestamps'], hasLength(3));
    });

    test('missing timestamps are padded with the unknown time', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: <String, dynamic>{'A': 'flat'},
        now: at(5),
        values: <String, Object?>{'A': 'new'},
      );
      expect(out['A'], <Object?>['flat', 'new']);
      expect(out['timestamps'], <Timestamp>[
        TodoHistoryCodec.unknownTime,
        ms(5),
      ]);
    });

    test('fields not in values are dropped', () {
      final Map<String, dynamic> out = TodoHistoryCodec.append(
        old: <String, dynamic>{
          'A': <dynamic>[1],
          'Gone': <dynamic>['x'],
          'timestamps': <dynamic>[ms(1)],
        },
        now: at(2),
        values: <String, Object?>{'A': 2},
      );
      expect(out.keys.toSet(), <String>{'A', 'timestamps'});
    });
  });
}
