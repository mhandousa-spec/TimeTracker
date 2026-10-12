/// Module: messaging / main_controller / helper / poll_votes_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: poll_votes_service.dart
/// Purpose: Votes on poll messages (Figma 6799:5666 — Poll).
/// Author: Knowticed Team
/// Created At: 30/9/2026
///
/// STORAGE
/// -------
///   Messaging_Poll_Votes/{pollKey}
///     Votes: { userId: [optionIndex, …], … }
///
/// Votes are kept outside the message document on purpose: the message
/// content is encrypted and its document is owned by the sender, so voting
/// never has to rewrite it. pollKey is the message id with '/' removed (a
/// Firestore id cannot contain it).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PollVotesService {
  PollVotesService._();

  static const String collection = 'Messaging_Poll_Votes';
  static const String votesKey = 'Votes';

  static String _norm(String id) => id.trim().toLowerCase();

  static String pollKey(String messageId) =>
      messageId.replaceAll('/', '_').trim();

  static DocumentReference<Map<String, dynamic>> _doc(String messageId) =>
      FirebaseFirestore.instance.collection(collection).doc(pollKey(messageId));

  /// Live votes of one poll: voter id → the option indexes they picked.
  static Stream<Map<String, List<int>>> watch(String messageId) {
    return _doc(messageId).snapshots().map((snap) {
      final Object? raw = snap.data()?[votesKey];
      final Map<String, List<int>> votes = <String, List<int>>{};
      if (raw is Map) {
        raw.forEach((dynamic user, dynamic picks) {
          if (picks is List) {
            votes[user.toString()] =
                picks.whereType<num>().map((n) => n.toInt()).toList();
          }
        });
      }
      return votes;
    });
  }

  /// Ticks / unticks [option] for [userId].
  ///
  /// Single-answer polls replace the user's previous pick; tapping the option
  /// they already picked removes their vote. Multiple-answer polls toggle the
  /// option on its own. Returns false when the write failed.
  static Future<bool> vote({
    required String messageId,
    required String userId,
    required int option,
    required bool allowMultiple,
  }) async {
    final String me = _norm(userId);
    final DocumentReference<Map<String, dynamic>> ref = _doc(messageId);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final DocumentSnapshot<Map<String, dynamic>> snap = await tx.get(ref);
        final Object? raw = snap.data()?[votesKey];
        final List<int> mine = <int>[
          if (raw is Map && raw[me] is List)
            ...(raw[me] as List).whereType<num>().map((n) => n.toInt()),
        ];
        final List<int> next;
        if (allowMultiple) {
          next = mine.contains(option)
              ? (mine..remove(option))
              : (mine..add(option));
        } else {
          next = mine.contains(option) ? <int>[] : <int>[option];
        }
        tx.set(
          ref,
          <String, dynamic>{
            votesKey: <String, dynamic>{me: next},
          },
          SetOptions(merge: true),
        );
      });
      return true;
    } catch (e) {
      debugPrint('[PollVotes] ✗ vote on $messageId failed: $e');
      return false;
    }
  }
}
