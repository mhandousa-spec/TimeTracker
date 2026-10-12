/// Module: todo / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: todo_history_codec.dart
/// Purpose: Declares `TodoHistoryCodec` — the generic read/append rules of
///          the owner's "indexed history" document model.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Owner rule (7/10/2026, reference `Demo/{cid}/Employees_Info`): EVERY field
/// of a document is a LIST, and the document carries `timestamps`
/// (`List<Timestamp>` — readable dates in the Firebase console). Every write
/// appends ONE entry to EVERY field and ONE to `timestamps`, so index i of
/// any field is that field's value at `timestamps[i]`. The current value is
/// always the LAST element.
///
/// Reading accepts both `Timestamp` and the earlier int-millisecond stamps
/// (back-compat); writing always produces `Timestamp`s, so an old int column
/// is upgraded on its next append.
///
/// No Firestore calls (only the `Timestamp` value type) — unit-tested
/// without an emulator.

import 'package:cloud_firestore/cloud_firestore.dart';

class TodoHistoryCodec {
  const TodoHistoryCodec._();

  /// The write-time column every history document carries.
  static const String fTimestamps = 'timestamps';

  /// Filler for a missing write time (a row whose time is unknown).
  static final Timestamp unknownTime = Timestamp.fromMillisecondsSinceEpoch(0);

  /// Function Name: [historyOf]
  ///
  /// Purpose: The stored history of [key]. A missing field is an empty
  /// history; a non-list value is a one-entry history.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map: the raw document.
  ///   [String] key: the field name.
  ///
  /// Return type: [List<Object?>]
  static List<Object?> historyOf(Map<String, dynamic> map, String key) =>
      _asHistory(map[key]);

  /// Function Name: [lastOf]
  ///
  /// Purpose: The current value of [key] — the last history entry, or null.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map
  ///   [String] key
  ///
  /// Return type: [Object?]
  static Object? lastOf(Map<String, dynamic> map, String key) {
    final List<Object?> history = historyOf(map, key);
    return history.isEmpty ? null : history.last;
  }

  /// Function Name: [timestampsOf]
  ///
  /// Purpose: The `timestamps` column as `Timestamp`s. Accepts `Timestamp`,
  /// `DateTime` and legacy int epoch-ms entries; anything else reads as
  /// [unknownTime].
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map
  ///
  /// Return type: [List<Timestamp>]
  static List<Timestamp> timestampsOf(Map<String, dynamic> map) =>
      <Timestamp>[
        for (final Object? raw in _asHistory(map[fTimestamps])) _toTimestamp(raw),
      ];

  /// Function Name: [lastWriteOf]
  ///
  /// Purpose: The time of the latest write (last `timestamps` entry), or
  /// null when the column is missing or the time is unknown.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map
  ///
  /// Return type: [DateTime?]
  static DateTime? lastWriteOf(Map<String, dynamic> map) {
    final List<Timestamp> stamps = timestampsOf(map);
    if (stamps.isEmpty || stamps.last.millisecondsSinceEpoch <= 0) return null;
    return stamps.last.toDate();
  }

  /// Function Name: [append]
  ///
  /// Purpose: Build the next version of a history document. [values] holds
  /// the NEW value of every field (all fields, changed or not). Each field's
  /// old history is front-padded with null to the document's row count, so a
  /// field added later — or a short, hand-edited array — can never shift the
  /// index alignment; then one entry is appended everywhere, `timestamps`
  /// included (as a `Timestamp`). Fields of [old] that are not in [values]
  /// are dropped (the result is written with a full `set`).
  ///
  /// Parameters:
  ///   [Map<String, dynamic>?] old: the stored document (null on create).
  ///   [Map<String, Object?>] values: field name -> new value.
  ///   [DateTime] now: the write time.
  ///
  /// Return type: [Map<String, dynamic>] — the full document to `set`.
  static Map<String, dynamic> append({
    required Map<String, dynamic>? old,
    required Map<String, Object?> values,
    required DateTime now,
  }) {
    final Map<String, dynamic> source = old ?? <String, dynamic>{};
    final Map<String, List<Object?>> histories = <String, List<Object?>>{
      for (final String key in values.keys) key: historyOf(source, key),
    };
    final List<Timestamp> stamps = timestampsOf(source);

    int rows = stamps.length;
    for (final List<Object?> history in histories.values) {
      if (history.length > rows) rows = history.length;
    }

    return <String, dynamic>{
      for (final MapEntry<String, Object?> entry in values.entries)
        entry.key: <Object?>[
          ..._padFront<Object?>(histories[entry.key]!, rows, null),
          entry.value,
        ],
      fTimestamps: <Timestamp>[
        ..._padFront<Timestamp>(stamps, rows, unknownTime),
        Timestamp.fromDate(now),
      ],
    };
  }

  static Timestamp _toTimestamp(Object? raw) {
    if (raw is Timestamp) return raw;
    if (raw is DateTime) return Timestamp.fromDate(raw);
    if (raw is num) return Timestamp.fromMillisecondsSinceEpoch(raw.toInt());
    return unknownTime;
  }

  static List<Object?> _asHistory(Object? raw) {
    if (raw == null) return const <Object?>[];
    if (raw is List<dynamic>) return List<Object?>.of(raw);
    return <Object?>[raw];
  }

  static List<T> _padFront<T>(List<T> list, int length, T filler) =>
      list.length >= length
          ? list
          : <T>[...List<T>.filled(length - list.length, filler), ...list];
}
