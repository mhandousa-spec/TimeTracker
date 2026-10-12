/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_field_codec.dart
/// Purpose: Declares `TimeTrackerFieldCodec` — tolerant readers / writers for
///          ONE history entry (strings, numbers, dates, wrapped lists) — and
///          `TimeTrackerAudit`, the Created_By / Creation_Date / Modified_By
///          trio every document carries.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Firestore cannot store an array directly inside an array, so in the
/// history model a list-valued field stores each history entry as a MAP
/// wrapping the list under `Values` (same as To-Do):
///   `Working_Days: [ {Values: [1, 2, 3, 4, 5]}, … ]`
/// Readers also accept a bare list. Readers never throw: a missing or
/// mistyped value reads as a safe default.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';

class TimeTrackerFieldCodec {
  const TimeTrackerFieldCodec._();

  /// Key wrapping the list inside one history entry of a list-valued field.
  static const String fValues = 'Values';

  static String string(Object? raw) => raw is String ? raw : '';

  static bool boolean(Object? raw) => raw == true;

  static int integer(Object? raw, {int fallback = 0}) =>
      raw is num ? raw.toInt() : fallback;

  static double decimal(Object? raw, {double fallback = 0}) =>
      raw is num ? raw.toDouble() : fallback;

  static double? nullableDecimal(Object? raw) =>
      raw is num ? raw.toDouble() : null;

  /// A `Timestamp` / `DateTime` entry as a `DateTime`, else null.
  static DateTime? date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  /// A `DateTime` as a `Timestamp` (null stays null).
  static Timestamp? timestamp(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);

  /// The list inside one wrapped entry (`{Values: [...]}` or a bare list).
  static List<Object?> unwrap(Object? raw) {
    final Object? list = raw is Map ? raw[fValues] : raw;
    return list is List ? List<Object?>.of(list) : const <Object?>[];
  }

  static List<String> strings(Object? raw) =>
      List<String>.unmodifiable(unwrap(raw).whereType<String>());

  static List<int> ints(Object? raw) => List<int>.unmodifiable(
        unwrap(raw).whereType<num>().map((num n) => n.toInt()),
      );

  static List<Map<String, dynamic>> maps(Object? raw) =>
      unwrap(raw).whereType<Map<String, dynamic>>().toList(growable: false);

  /// One history entry of a list-valued field.
  static Map<String, Object?> wrap(List<Object?> list) =>
      <String, Object?>{fValues: list};

  /// Function Name: [auditOf]
  ///
  /// Purpose: The read-only audit info of a stored document.
  ///
  /// Parameters:
  ///   [Map<String, dynamic>] map: the raw document.
  ///
  /// Return type: [AuditInfo]
  static AuditInfo auditOf(Map<String, dynamic> map) => AuditInfo(
        createdBy: string(TimeTrackerHistoryCodec.lastOf(map, TimeTrackerAudit.fCreatedBy)),
        createdAt: date(TimeTrackerHistoryCodec.lastOf(map, TimeTrackerAudit.fCreationDate)),
        modifiedBy: string(TimeTrackerHistoryCodec.lastOf(map, TimeTrackerAudit.fModifiedBy)),
        updatedAt: TimeTrackerHistoryCodec.lastWriteOf(map),
      );
}

/// The audit fields written with every history row (playbook §3b).
class TimeTrackerAudit {
  const TimeTrackerAudit({
    required this.createdBy,
    required this.createdAt,
    required this.modifiedBy,
  });

  static const String fCreatedBy = 'Created_By';
  static const String fCreationDate = 'Creation_Date';
  static const String fModifiedBy = 'Modified_By';

  final String createdBy;
  final Timestamp createdAt;
  final String modifiedBy;

  /// Function Name: [next]
  ///
  /// Purpose: The audit values of the next row: creator and creation date
  /// carry forward from [stored] (or are [actor] / [now] on create); the
  /// modifier is always [actor].
  ///
  /// Parameters:
  ///   [Map<String, dynamic>?] stored: the stored document (null on create).
  ///   [String] actor: the signed-in user's email.
  ///   [DateTime] now
  ///
  /// Return type: [TimeTrackerAudit]
  static TimeTrackerAudit next(
    Map<String, dynamic>? stored, {
    required String actor,
    required DateTime now,
  }) {
    final Map<String, dynamic> map = stored ?? <String, dynamic>{};
    final Object? createdAt = TimeTrackerHistoryCodec.lastOf(map, fCreationDate);
    final String createdBy =
        TimeTrackerFieldCodec.string(TimeTrackerHistoryCodec.lastOf(map, fCreatedBy));
    return TimeTrackerAudit(
      createdBy: createdBy.isNotEmpty ? createdBy : actor,
      createdAt: createdAt is Timestamp ? createdAt : Timestamp.fromDate(now),
      modifiedBy: actor,
    );
  }

  /// The three audit columns of one history row.
  Map<String, Object?> get fields => <String, Object?>{
        fCreatedBy: createdBy,
        fCreationDate: createdAt,
        fModifiedBy: modifiedBy,
      };
}
