/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_history_codec_test.dart
/// Purpose: Unit tests for the module-local `TimeTrackerHistoryCodec` (same
///          "indexed history" rules as To-Do) and `TimeTrackerFieldCodec` /
///          `TimeTrackerAudit`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';

void main() {
  Timestamp ms(int value) => Timestamp.fromMillisecondsSinceEpoch(value);

  group('TimeTrackerHistoryCodec.append', () {
    test('create: every field becomes a one-entry list + timestamps', () {
      final Map<String, dynamic> doc = TimeTrackerHistoryCodec.append(
        old: null,
        values: <String, Object?>{'A': 1, 'B': 'x'},
        now: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      expect(doc['A'], <Object?>[1]);
      expect(doc['B'], <Object?>['x']);
      expect(doc['timestamps'], <Timestamp>[ms(1000)]);
    });

    test('append keeps index alignment, front-padding a new field', () {
      final Map<String, dynamic> first = TimeTrackerHistoryCodec.append(
        old: null,
        values: <String, Object?>{'A': 1},
        now: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      final Map<String, dynamic> second = TimeTrackerHistoryCodec.append(
        old: first,
        values: <String, Object?>{'A': 2, 'New': true},
        now: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      expect(second['A'], <Object?>[1, 2]);
      expect(second['New'], <Object?>[null, true]);
      expect(second['timestamps'], <Timestamp>[ms(1000), ms(2000)]);
      expect(TimeTrackerHistoryCodec.lastOf(second, 'A'), 2);
    });
  });

  group('TimeTrackerFieldCodec', () {
    test('wrap / unwrap lists inside a history entry', () {
      final Map<String, Object?> wrapped = TimeTrackerFieldCodec.wrap(<Object?>[1, 2]);
      expect(wrapped, <String, Object?>{'Values': <Object?>[1, 2]});
      expect(TimeTrackerFieldCodec.ints(wrapped), <int>[1, 2]);
      expect(TimeTrackerFieldCodec.strings(<Object?>['a', 3]), <String>['a']);
      expect(TimeTrackerFieldCodec.unwrap(null), isEmpty);
    });

    test('mistyped values read as safe defaults', () {
      expect(TimeTrackerFieldCodec.string(5), '');
      expect(TimeTrackerFieldCodec.integer('x', fallback: 7), 7);
      expect(TimeTrackerFieldCodec.boolean('true'), isFalse);
      expect(TimeTrackerFieldCodec.date('2026'), isNull);
      expect(TimeTrackerFieldCodec.nullableDecimal(3), 3.0);
    });
  });

  group('TimeTrackerAudit.next', () {
    test('create: creator = modifier = actor, creation = now', () {
      final TimeTrackerAudit audit = TimeTrackerAudit.next(
        null,
        actor: 'a@co.com',
        now: DateTime.fromMillisecondsSinceEpoch(5000),
      );
      expect(audit.fields, <String, Object?>{
        'Created_By': 'a@co.com',
        'Creation_Date': ms(5000),
        'Modified_By': 'a@co.com',
      });
    });

    test('update: creator and creation date carry forward', () {
      final Map<String, dynamic> stored = <String, dynamic>{
        'Created_By': <Object?>['first@co.com'],
        'Creation_Date': <Object?>[ms(1000)],
      };
      final TimeTrackerAudit audit = TimeTrackerAudit.next(
        stored,
        actor: 'second@co.com',
        now: DateTime.fromMillisecondsSinceEpoch(9000),
      );
      expect(audit.createdBy, 'first@co.com');
      expect(audit.createdAt, ms(1000));
      expect(audit.modifiedBy, 'second@co.com');
    });
  });
}
