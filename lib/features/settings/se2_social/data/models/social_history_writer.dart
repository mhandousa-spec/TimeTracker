/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_history_writer.dart
/// Purpose: Turn one Social Information save into ONE appended Employees_Info
///          revision, and the exact field map to write for it.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// ADDED 9/10/2026 (owner request, Settings schema 9 Oct). The social save
/// used to `update()` the employee document with `Bio: [bio]`,
/// `Skills: [...]` … — overwriting each history array with a single value and
/// never touching `timestamps`. Employees_Info is a history document: every
/// field is a LIST, the document carries `timestamps`, index i of any field is
/// its value at `timestamps[i]`, and the current value is the LAST element.
///
/// This class appends a social save the way every other Employees_Info edit is
/// appended — through the model's own helper,
/// `NewEmployeeModelHistory.copyWithUpdateSynchronized` (the one the change
/// request approval path uses via `updateFieldSynchronized`):
///   * ONE new entry in `timestamps` (int ms, like the rest of the document);
///   * ONE new entry in every synchronized field list — the new value for each
///     changed social field, the last value repeated for every other field.
///
/// Before appending, the five social lists are first brought up to the
/// `timestamps` length (the previous save left them short or long), carrying
/// the last known value forward. So after a save each of them is exactly as
/// long as `timestamps`.
///
/// No Firestore calls — unit-tested without an emulator.

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/entities/social_profile.dart';
import 'package:knowticed_plus/features/settings/se2_social/domain/use_cases/build_social_update.dart';

abstract final class SocialHistoryWriter {
  const SocialHistoryWriter._();

  /// Function Name: [appendRevision]
  ///
  /// Purpose: The employee history with one social revision appended.
  ///
  /// Parameters:
  /// - [stored]: the employee document exactly as read from Firestore.
  /// - [changes]: the output of `BuildSocialUpdate` — field name → the value
  ///   of the new revision, for changed fields only.
  /// - [timestamp]: the revision time in ms (defaults to now; tests pin it).
  ///
  /// Returns: [NewEmployeeModelHistory] the appended history.
  static NewEmployeeModelHistory appendRevision({
    required Map<String, dynamic> stored,
    required Map<String, dynamic> changes,
    int? timestamp,
  }) {
    final NewEmployeeModelHistory history =
        NewEmployeeModelHistory.fromMap(stored);
    final int rows = history.timestamps.length;

    // Align the five social lists with `timestamps` before the append, so the
    // append leaves them exactly as long as `timestamps`.
    history
      ..bio = alignTo<String>(history.bio, rows, '')
      ..bioInArabic = alignTo<String>(history.bioInArabic, rows, '')
      ..skills = alignTo<List<String>>(history.skills, rows, <String>[])
      ..hobbies = alignTo<List<String>>(history.hobbies, rows, <String>[])
      ..academicHistory = alignTo<Map<String, dynamic>>(
        history.academicHistory,
        rows,
        BuildSocialUpdate.academicRevision(const []),
      );

    return history.copyWithUpdateSynchronized(
      addTimestamp: timestamp,
      bio: changes[SocialProfile.fieldBio] as String?,
      bioInArabic: changes[SocialProfile.fieldBioInArabic] as String?,
      skills: _strings(changes[SocialProfile.fieldSkills]),
      hobbies: _strings(changes[SocialProfile.fieldHobbies]),
      academicHistory: _map(changes[SocialProfile.fieldAcademicHistory]),
    );
  }

  /// Function Name: [buildWrite]
  ///
  /// Purpose: The fields to `update()` for one social save.
  ///
  /// Every key the append changed — `timestamps` and every appended history
  /// list — and nothing else. Values the append does not touch are left out,
  /// so a social save never rewrites `Password`, `Default_Password`,
  /// `First_Login`, `Id` … and never adds placeholder keys the document did
  /// not have.
  ///
  /// Parameters: as [appendRevision].
  ///
  /// Returns: [Map<String, dynamic>] the Firestore update map.
  static Map<String, dynamic> buildWrite({
    required Map<String, dynamic> stored,
    required Map<String, dynamic> changes,
    int? timestamp,
  }) {
    final Map<String, dynamic> before =
        NewEmployeeModelHistory.fromMap(stored).toMap();
    final Map<String, dynamic> after = appendRevision(
      stored: stored,
      changes: changes,
      timestamp: timestamp,
    ).toMap();

    return <String, dynamic>{
      for (final MapEntry<String, dynamic> entry in after.entries)
        if (!_deepEquals(before[entry.key], entry.value))
          entry.key: entry.value,
    };
  }

  /// Function Name: [alignTo]
  ///
  /// Purpose: Bring a history list up to [rows] entries.
  ///
  /// A short list is extended by repeating its last value (the revisions it
  /// missed are ones in which it did not change); [filler] is used only when
  /// the list is empty. A list that is already long enough is returned as a
  /// copy, untouched — nothing is ever dropped.
  ///
  /// Parameters:
  /// - [list]: the stored history.
  /// - [rows]: the target length (`timestamps.length`).
  /// - [filler]: the value for an empty history.
  ///
  /// Returns: [List<T>] a new list of at least [rows] entries.
  static List<T> alignTo<T>(List<T> list, int rows, T filler) {
    final List<T> result = List<T>.of(list);
    while (result.length < rows) {
      result.add(result.isEmpty ? filler : result.last);
    }
    return result;
  }

  static List<String>? _strings(Object? value) => value is List
      ? value.map((dynamic e) => e?.toString() ?? '').toList()
      : null;

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  /// Structural equality for Firestore-shaped values (lists, maps, scalars).
  static bool _deepEquals(Object? a, Object? b) {
    if (identical(a, b)) return true;
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final Object? key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }
    return a == b;
  }
}
