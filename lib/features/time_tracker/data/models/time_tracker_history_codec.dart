/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_history_codec.dart
/// Purpose: Declares `TimeTrackerHistoryCodec` — the generic read/append rules of
///          the owner's "indexed history" document model.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
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
///
/// Module-local copy of `TodoHistoryCodec` (8/10/2026) so the Time Tracker
/// repo does not depend on the To-Do feature folder. Keep the two in step;
/// a shared `core/` codec is the long-term home (STATUS.md open question).
/// Updated: 9/10/2026 - phase 4: [rowCount] / [rowAt] — read the document
/// as it was at one history row (transaction revert).
/// Updated: 9/10/2026 - code review: [append] CARRIES a stored field the
/// writer does not know (its last value repeated) instead of dropping it —
/// a field added by a newer app version survives an older writer's `set`.

import 'package:cloud_firestore/cloud_firestore.dart';

class TimeTrackerHistoryCodec {
  const TimeTrackerHistoryCodec._();

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
  /// included (as a `Timestamp`). A field of [old] that is not in [values]
  /// is carried: its last value is appended again, so the full `set` never
  /// drops data the writer does not know about (code review, 9/10/2026).
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
    final Map<String, Object?> next = <String, Object?>{
      ...values,
      // Unknown stored fields keep their current value (9/10/2026).
      for (final String key in source.keys)
        if (key != fTimestamps && !values.containsKey(key)) key: lastOf(source, key),
    };
    final Map<String, List<Object?>> histories = <String, List<Object?>>{
      for (final String key in next.keys) key: historyOf(source, key),
    };
    final List<Timestamp> stamps = timestampsOf(source);

    int rows = stamps.length;
    for (final List<Object?> history in histories.values) {
      if (history.length > rows) rows = history.length;
    }

    return <String, dynamic>{
      for (final MapEntry<String, Object?> entry in next.entries)
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

  /// Function Name: [rowCount]
  ///
  /// Purpose: How many history rows the document holds (the longest field).
  ///
  /// Return type: [int]
  static int rowCount(Map<String, dynamic> map) {
    int rows = 0;
    for (final Object? value in map.values) {
      final int n = _asHistory(value).length;
      if (n > rows) rows = n;
    }
    return rows;
  }

  /// Function Name: [rowAt]
  ///
  /// Purpose: The document as it was at history row [index]: every field
  /// cut to its entries up to that row (aligned from the end, like
  /// [append] pads from the front), so [lastOf] reads that row's values.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map
  ///   [int] index: 0 … [rowCount] − 1.
  ///
  /// Return type: [Map<String, dynamic>]
  static Map<String, dynamic> rowAt(Map<String, dynamic> map, int index) {
    final int rows = rowCount(map);
    return <String, dynamic>{
      for (final MapEntry<String, dynamic> e in map.entries)
        e.key: _upTo(_asHistory(e.value), index + 1 - (rows - _asHistory(e.value).length)),
    };
  }

  static List<Object?> _upTo(List<Object?> history, int count) {
    if (count <= 0) return <Object?>[];
    return history.sublist(0, count > history.length ? history.length : count);
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
