/// Module: messaging / main_controller / helper / chat_settings_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: chat_settings_service.dart
/// Purpose: Per-chat settings behind the chat ⋮ menu — Pin, Mute
///          Notifications and Disappearing Messages (messages bug report
///          #19–#22). All three were empty TODOs / a local-only strip.
/// Author: Knowticed Team
/// Created At: 26/9/2026
///
/// STORAGE
/// -------
/// One Firestore doc per chat in [collection]:
///
///   Messaging_Chat_Settings/{chatKey}
///     Pinned_By:          [userId, …]  — who pinned the chat (per user)
///     Muted_By:           [userId, …]  — who muted it (per user)
///     Disappearing_Since: Timestamp?   — shared by everyone in the chat
///
/// Firestore rather than local storage because:
///   • Mute has to be known by the SENDER — notifications are pushed from the
///     sender's device (MessagesNotificationService), so the recipient's
///     choice must be readable there.
///   • Disappearing messages is a property of the chat, not of one viewer.
///   • Pin then follows the user across devices for free.
///
/// chatKey: a direct chat is the two user ids sorted and joined with "__"
/// (the same key from both sides); a group is "group__{groupId}".
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatSettings {
  final Timestamp? disappearingSince;

  /// How long a message lives once Disappearing Messages is on (Figma
  /// 6799:16789: 24 Hours / 7 Days / 90 Days / Always). 0 = "Always": a
  /// message disappears as soon as it has been seen. Null (older docs) = 24.
  final int? disappearingHours;

  /// Per-user mute expiry (Figma 6799:16763: 8 Hours / 1 Week / Always).
  /// A null value = muted with no end.
  final Map<String, Timestamp?> mutedUntil;

  /// Whether the doc states Disappearing Messages at all (even as null =
  /// explicitly off). When it does not, a group falls back to the switch it
  /// was created with.
  final bool hasDisappearingSetting;
  final Set<String> pinnedBy;
  final Set<String> mutedBy;

  const ChatSettings({
    this.disappearingSince,
    this.disappearingHours,
    this.mutedUntil = const <String, Timestamp?>{},
    this.hasDisappearingSetting = false,
    this.pinnedBy = const <String>{},
    this.mutedBy = const <String>{},
  });

  bool get isDisappearing => disappearingSince != null;

  /// Hours a message lives; see [disappearingHours].
  int get effectiveDisappearingHours => disappearingHours ?? 24;

  /// Whether [userId] (normalised) is muted right now.
  bool isMutedNow(String userId) {
    if (!mutedBy.contains(userId)) return false;
    if (!mutedUntil.containsKey(userId)) return true; // muted before expiry existed
    final Timestamp? until = mutedUntil[userId];
    return until == null || until.toDate().isAfter(DateTime.now());
  }
}

class ChatSettingsService {
  ChatSettingsService._();

  static const String collection = 'Messaging_Chat_Settings';
  static const String pinnedByKey = 'Pinned_By';
  static const String mutedByKey = 'Muted_By';
  static const String disappearingSinceKey = 'Disappearing_Since';
  static const String disappearingHoursKey = 'Disappearing_Hours';
  static const String mutedUntilKey = 'Muted_Until';

  /// Messages sent while Disappearing Messages is on vanish this long after
  /// they were sent (WhatsApp's default).
  static const Duration disappearAfter = Duration(hours: 24);

  // ── Keys ─────────────────────────────────────────────────────────────────

  static String _norm(String id) => id.trim().toLowerCase();

  static String directKey(String userA, String userB) {
    final List<String> ids = <String>[_norm(userA), _norm(userB)]..sort();
    return ids.join('__');
  }

  static String groupKey(String groupId) => 'group__$groupId';

  static DocumentReference<Map<String, dynamic>> _doc(String chatKey) =>
      FirebaseFirestore.instance.collection(collection).doc(chatKey);

  // ── Live state for the signed-in user (drives the chat-list icons) ───────

  /// Chat keys the signed-in user has pinned. Tiles listen to this.
  static final ValueNotifier<Set<String>> pinnedChats =
      ValueNotifier<Set<String>>(<String>{});

  /// Chat keys the signed-in user has muted. Tiles listen to this.
  static final ValueNotifier<Set<String>> mutedChats =
      ValueNotifier<Set<String>>(<String>{});

  static String? _watchingUserId;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _pinSub;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _muteSub;

  /// The user whose pins / mutes are being watched (null before [watch]).
  static String? get currentUserId => _watchingUserId;

  /// Start mirroring the signed-in user's pinned / muted chats into
  /// [pinnedChats] / [mutedChats]. Safe to call repeatedly.
  static void watch(String userId) {
    final String me = _norm(userId);
    if (me.isEmpty || me == _watchingUserId) return;
    _watchingUserId = me;
    _pinSub?.cancel();
    _muteSub?.cancel();
    debugPrint('[ChatSettings] watching pins/mutes for $me');

    _pinSub = FirebaseFirestore.instance
        .collection(collection)
        .where(pinnedByKey, arrayContains: me)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> s) =>
              pinnedChats.value = s.docs.map((d) => d.id).toSet(),
          onError: (Object e) =>
              debugPrint('[ChatSettings] ✗ pinned stream error: $e'),
        );

    _muteSub = FirebaseFirestore.instance
        .collection(collection)
        .where(mutedByKey, arrayContains: me)
        .snapshots()
        .listen(
          // 30/9/2026: a timed mute (8 Hours / 1 Week) that has run out no
          // longer counts, even though the id is still in Muted_By.
          (QuerySnapshot<Map<String, dynamic>> s) => mutedChats.value = s.docs
              .where((d) => _settingsFrom(d.data()).isMutedNow(me))
              .map((d) => d.id)
              .toSet(),
          onError: (Object e) =>
              debugPrint('[ChatSettings] ✗ muted stream error: $e'),
        );
  }

  static bool isPinned(String chatKey) => pinnedChats.value.contains(chatKey);
  static bool isMuted(String chatKey) => mutedChats.value.contains(chatKey);

  // ── Reads ────────────────────────────────────────────────────────────────

  static final Map<String, ChatSettings> _cache = <String, ChatSettings>{};

  /// Last settings loaded for [chatKey] (defaults when never loaded).
  static ChatSettings cached(String chatKey) =>
      _cache[chatKey] ?? const ChatSettings();

  static Future<ChatSettings> load(String chatKey) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _doc(chatKey).get();
      final Map<String, dynamic> data = snap.data() ?? <String, dynamic>{};
      final ChatSettings settings = _settingsFrom(data);
      _cache[chatKey] = settings;
      return settings;
    } catch (e) {
      debugPrint('[ChatSettings] ✗ load($chatKey) failed: $e');
      return cached(chatKey);
    }
  }

  static ChatSettings _settingsFrom(Map<String, dynamic> data) {
    final Object? rawUntil = data[mutedUntilKey];
    final Map<String, Timestamp?> until = <String, Timestamp?>{};
    if (rawUntil is Map) {
      rawUntil.forEach((dynamic k, dynamic v) {
        until[k.toString()] = v is Timestamp ? v : null;
      });
    }
    return ChatSettings(
      disappearingSince: data[disappearingSinceKey] as Timestamp?,
      disappearingHours: (data[disappearingHoursKey] as num?)?.toInt(),
      hasDisappearingSetting: data.containsKey(disappearingSinceKey),
      pinnedBy: List<String>.from(
              data[pinnedByKey] as List<dynamic>? ?? const <dynamic>[])
          .toSet(),
      mutedBy: List<String>.from(
              data[mutedByKey] as List<dynamic>? ?? const <dynamic>[])
          .toSet(),
      mutedUntil: until,
    );
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  static Future<bool> _toggleMember({
    required String chatKey,
    required String field,
    required String userId,
    required bool add,
  }) async {
    final String me = _norm(userId);
    try {
      await _doc(chatKey).set(<String, dynamic>{
        field: add
            ? FieldValue.arrayUnion(<String>[me])
            : FieldValue.arrayRemove(<String>[me]),
      }, SetOptions(merge: true));
      debugPrint('[ChatSettings] $field ${add ? '+' : '-'} $me on $chatKey');
      return true;
    } catch (e) {
      debugPrint('[ChatSettings] ✗ $field update on $chatKey failed: $e');
      return false;
    }
  }

  static void _setMembership(
      ValueNotifier<Set<String>> notifier, String chatKey, bool member) {
    final Set<String> next = Set<String>.of(notifier.value);
    if (member) {
      next.add(chatKey);
    } else {
      next.remove(chatKey);
    }
    notifier.value = next;
  }

  /// Pins / unpins the chat for [userId]. Returns the NEW pinned state.
  static Future<bool> togglePinned(String chatKey, String userId) async {
    final bool pin = !isPinned(chatKey);
    // Optimistic, so the tile icon flips immediately; reverted on failure.
    _setMembership(pinnedChats, chatKey, pin);
    final bool ok = await _toggleMember(
        chatKey: chatKey, field: pinnedByKey, userId: userId, add: pin);
    if (!ok) _setMembership(pinnedChats, chatKey, !pin);
    return ok ? pin : !pin;
  }

  /// Mutes / unmutes the chat for [userId]. Returns the NEW muted state.
  static Future<bool> toggleMuted(String chatKey, String userId) async {
    final bool mute = !isMuted(chatKey);
    _setMembership(mutedChats, chatKey, mute);
    final bool ok = await _toggleMember(
        chatKey: chatKey, field: mutedByKey, userId: userId, add: mute);
    if (!ok) _setMembership(mutedChats, chatKey, !mute);
    return ok ? mute : !mute;
  }

  /// Mutes the chat for [userId] for [duration] — null = until unmuted
  /// ("Always"). ADDED 30/9/2026 for the Mute Notifications dialog (Figma
  /// 6799:16763). Returns true on success.
  static Future<bool> muteFor(
      String chatKey, String userId, Duration? duration) async {
    final String me = _norm(userId);
    final Timestamp? until =
        duration == null ? null : Timestamp.fromDate(DateTime.now().add(duration));
    _setMembership(mutedChats, chatKey, true);
    try {
      await _doc(chatKey).set(<String, dynamic>{
        mutedByKey: FieldValue.arrayUnion(<String>[me]),
        mutedUntilKey: <String, dynamic>{me: until},
      }, SetOptions(merge: true));
      debugPrint('[ChatSettings] muted $chatKey for $me until $until');
      return true;
    } catch (e) {
      _setMembership(mutedChats, chatKey, false);
      debugPrint('[ChatSettings] ✗ mute $chatKey failed: $e');
      return false;
    }
  }

  /// Removes [userId]'s mute on [chatKey]. Returns true on success.
  static Future<bool> unmute(String chatKey, String userId) async {
    final String me = _norm(userId);
    _setMembership(mutedChats, chatKey, false);
    try {
      await _doc(chatKey).set(<String, dynamic>{
        mutedByKey: FieldValue.arrayRemove(<String>[me]),
        mutedUntilKey: <String, dynamic>{me: FieldValue.delete()},
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      _setMembership(mutedChats, chatKey, true);
      debugPrint('[ChatSettings] ✗ unmute $chatKey failed: $e');
      return false;
    }
  }

  /// Turns Disappearing Messages on (from now) or off for everyone in the
  /// chat. Returns the NEW state.
  ///
  /// [hours] (ADDED 30/9/2026, Figma 6799:16789): how long a message lives —
  /// 24, 168 (7 days), 2160 (90 days) or 0 for "Always" (gone once seen).
  static Future<bool> setDisappearing(String chatKey, bool enabled,
      {int hours = 24}) async {
    final Timestamp? since = enabled ? Timestamp.now() : null;
    try {
      await _doc(chatKey).set(<String, dynamic>{
        disappearingSinceKey: since,
        disappearingHoursKey: enabled ? hours : null,
      }, SetOptions(merge: true));
      final ChatSettings old = cached(chatKey);
      _cache[chatKey] = ChatSettings(
        disappearingSince: since,
        disappearingHours: enabled ? hours : null,
        hasDisappearingSetting: true,
        pinnedBy: old.pinnedBy,
        mutedBy: old.mutedBy,
        mutedUntil: old.mutedUntil,
      );
      debugPrint('[ChatSettings] disappearing=$enabled on $chatKey');
      return enabled;
    } catch (e) {
      debugPrint('[ChatSettings] ✗ disappearing update on $chatKey failed: $e');
      return !enabled;
    }
  }

  /// Users (normalised ids) who muted [chatKey]. Used by the notification
  /// sender to skip them. Never throws.
  static Future<Set<String>> mutedBy(String chatKey) async {
    final ChatSettings settings = await load(chatKey);
    // Timed mutes that have run out no longer silence anyone.
    return settings.mutedBy.where(settings.isMutedNow).toSet();
  }

  /// Whether a message sent at [sentAt] has disappeared under [since].
  ///
  /// [hours]: the chat's timer (see [ChatSettings.disappearingHours]); 0 means
  /// "Always" — the message disappears once it has been seen ([isSeen]).
  static bool hasDisappeared(DateTime sentAt, DateTime? since,
      {int hours = 24, bool isSeen = false}) {
    if (since == null) return false;
    if (sentAt.isBefore(since)) return false; // sent before it was turned on
    if (hours <= 0) return isSeen;
    return DateTime.now().difference(sentAt) >= Duration(hours: hours);
  }
}
