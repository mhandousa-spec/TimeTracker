/// Module: messaging / chat / data/repository/react_writer.dart
/// Purpose: One reaction per user per message (bug report #24).
///
/// Reactions used to be written with `FieldValue.arrayUnion([react])`, an
/// anonymous list: changing your reaction ADDED the new one next to the old
/// one, and tapping the same one again never removed it on the server.
///
/// Now each message keeps `reacts_by: {userKey: reactName}` — one entry per
/// user — and the old `reacts` list is rewritten from it, so every reader that
/// parses `reacts` keeps working unchanged. Anonymous reactions written by the
/// old code are preserved once in `reacts_legacy`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/enum/reacts.dart';

class ReactWriter {
  ReactWriter._();

  static const String reactsKey = 'reacts';
  static const String reactsByKey = 'reacts_by';
  static const String legacyKey = 'reacts_legacy';

  /// Sets [userId]'s reaction on the message at [messageRef] to [react], or
  /// removes it when it already is [react] (tap again = un-react).
  static Future<void> setReact({
    required DocumentReference<Map<String, dynamic>> messageRef,
    required String userId,
    required Reacts react,
  }) async {
    // Firestore map keys may not contain '.' in update paths; the whole map
    // is written, but keep the key dot-free anyway (same trick as members).
    final String userKey = userId.trim().toLowerCase().replaceAll('.', '---');

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(messageRef);
      final Map<String, dynamic> data = snap.data() ?? <String, dynamic>{};

      final bool hasMap = data[reactsByKey] is Map;
      final Map<String, String> byUser = hasMap
          ? Map<String, dynamic>.from(data[reactsByKey] as Map)
              .map((k, v) => MapEntry(k, v.toString()))
          : <String, String>{};

      final List<String> legacy = data[legacyKey] is List
          ? List<String>.from(data[legacyKey] as List)
          : (hasMap
              ? <String>[]
              : List<String>.from(
                  (data[reactsKey] as List<dynamic>?) ?? const <dynamic>[]));

      if (byUser[userKey] == react.name) {
        byUser.remove(userKey); // same reaction again → remove it
      } else {
        byUser[userKey] = react.name; // new or CHANGED reaction replaces old
      }

      tx.update(messageRef, <String, dynamic>{
        reactsByKey: byUser,
        legacyKey: legacy,
        reactsKey: <String>[...legacy, ...byUser.values],
      });
    });
  }
}
