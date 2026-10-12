/// Module: messaging / main_controller / notifications
///
///*************************** FILE INFO ****************************///
/// File Name: messages_notification_service.dart
/// Purpose: The one place the messaging feature raises a notification.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// Before this, `lib/features/messaging` contained no reference to
/// `AppNotificationSender` at all. Messages, group invitations and polls all
/// arrived silently.
///
/// The controllers call the named methods below and pass domain values —
/// a sender name, a group name, a member id. No controller builds a
/// notification payload, picks a page key, or decides who the recipients are;
/// all of that is here, so the eleven triggers in
/// `messages_events.dart` cannot drift apart from one another.
///
/// ─── THE ID / EMAIL QUESTION ─────────────────────────────────────────
/// ⚠️ FIXED 2/9/2026. THIS FILE SHIPPED WITH A WRONG PREMISE AND SENT
/// NOTHING — read this before touching [emailForUserId].
///
/// **In this app the messaging `userId` / `memberId` IS THE EMAIL.**
/// `MessagingInterfaceImplementation.getAllUsersData` builds every connection
/// with `userId: employee.email`, and `MemberEntity.fromSingleConnectionEntity`
/// carries that straight through to `memberId`. There is no separate messaging
/// identifier anywhere in the feature.
///
/// The first version of this file assumed messaging used opaque ids and
/// resolved them by scanning `allEmployeesEntities` for `employee.id == userId`
/// — comparing a document id against an email address. That never matched, so
/// [emailForUserId] returned null for every recipient, [_send] found an empty
/// recipient set, and **every single messaging notification was dropped before
/// it was sent.** No error, no log at the sender: the module simply showed 0
/// notifications forever.
///
/// So the resolution is now: an id that looks like an email IS the address.
/// The directory scan is kept only as a fallback for a caller that genuinely
/// has a document id, and it memoises into [_emailByUserId] because a group
/// fan-out would otherwise rescan per member.
///
/// If an id cannot be resolved the send is SKIPPED, not guessed — a
/// notification delivered to the wrong person is worse than one not delivered.
///
/// ─── EVERY METHOD IS FIRE-AND-FORGET ─────────────────────────────────
/// They return `Future<void>` and swallow their own failures. A notification
/// that fails to send must never take down the message that triggered it —
/// the message is the thing the user asked for; the notification is a
/// courtesy. Call sites are free to `await` or not.

import '../helper/chat_settings_service.dart';
import 'dart:developer';

import 'package:get/get.dart';

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages_module/messages_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/messages_module/messages_notification_pages.dart';
import 'package:knowticed_plus/features/notification/services/app_notification_sender.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

abstract final class MessagesNotificationService {
  const MessagesNotificationService._();

  /// How much of a message body reaches a notification.
  ///
  /// A push payload ends up on a lock screen, so this is a POINTER to the
  /// conversation, not a copy of it. 50 characters is enough to recognise
  /// which thread is being talked about and not enough to read a private
  /// exchange over someone's shoulder.
  static const int previewLength = 50;

  /// See the ID / EMAIL PROBLEM note. Session-lived, never persisted.
  static final Map<String, String> _emailByUserId = <String, String>{};

  // ── Plumbing ──────────────────────────────────────────────────────────────

  /// Function Name: [emailForUserId]
  ///
  /// Purpose: Turn a messaging `userId` / `memberId` into the email address
  ///          [AppNotificationSender] needs.
  ///
  /// ⚠️ FIXED 2/9/2026 — this is why the Messages module showed 0
  /// notifications. The body was ONLY the directory scan below, matching
  /// `employee.id == userId`. Messaging ids are EMAILS
  /// (`MessagingInterfaceImplementation.getAllUsersData` sets
  /// `userId: employee.email`), so that compared an address against a document
  /// id, never matched, and returned null for every recipient — [_send] then
  /// found an empty recipient set and returned silently. Nothing reached
  /// Firestore and nothing reached FCM.
  ///
  /// Returns: null when the id belongs to nobody the employee directory knows
  ///          — a deleted account, or a directory that has not loaded yet.
  ///          Callers skip the send on null; see the note above on why
  ///          guessing is worse.
  static String? emailForUserId(String userId) {
    final String id = userId.trim();
    if (id.isEmpty) return null;

    // THE COMMON CASE, and in practice the only one: the messaging id already
    // IS the address. No directory lookup, so this also works before
    // `allEmployeesEntities` has loaded — which the scan below does not.
    if (id.contains('@')) return id;

    final String? memo = _emailByUserId[id];
    if (memo != null) return memo;

    // FALLBACK for a caller that genuinely holds an employee document id. Kept
    // rather than deleted because nothing stops a future call site passing one,
    // and silently addressing a notification to nobody is how this bug
    // happened in the first place.
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    final MainCoreEmployeeController controller =
        Get.find<MainCoreEmployeeController>();

    // Typed empty fallback, not `const []` — an untyped literal would make
    // `employee` dynamic and turn a renamed field into a runtime crash instead
    // of a compile error.
    for (final EmployeeEntityPro employee
        in controller.allEmployeesEntities ?? const <EmployeeEntityPro>[]) {
      if (employee.id == id) {
        final String? email = employee.email;
        if (email == null || email.trim().isEmpty) return null;
        _emailByUserId[id] = email;
        return email;
      }
    }

    log('⏭️ unresolvable recipient id "$id" — no employee matches it, and it '
        'is not an email. Notification skipped.',
        name: 'MessagesNotifications');
    return null;
  }

  /// The signed-in employee's email — every notification's `senderEmail`.
  static String? get _currentUserEmail {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return null;
    return Get.find<MainCoreEmployeeController>().employeeEntity?.email;
  }

  /// Function Name: [currentUserName]
  ///
  /// Purpose: The signed-in employee's display name, for the `{{addedByName}}`
  ///          / `{{removedByName}}` / `{{deletedByName}}` slots.
  ///
  /// Here rather than at each call site so every "X did this to you" event
  /// names the actor the same way, and in the reader's language —
  /// `getEmployeeName` already picks Arabic or English from the active locale.
  ///
  /// Returns: an empty string when the directory cannot answer. The template
  ///          then renders with a blank actor, which is worse copy but still a
  ///          true statement; the alternative is not telling the reader they
  ///          were removed from a group.
  static String get currentUserName {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return '';
    final MainCoreEmployeeController controller =
        Get.find<MainCoreEmployeeController>();
    final String? email = controller.employeeEntity?.email;
    if (email == null || email.trim().isEmpty) return '';
    final String name = controller.getEmployeeName(email).trim();
    // getEmployeeName returns the literal 'no name' when the record is
    // missing — a sentinel, not a name, so it must not reach a notification.
    return name == 'no name' ? '' : name;
  }

  /// Whether the app is currently showing Arabic.
  ///
  /// Read from GetX rather than a BuildContext because this service is called
  /// from cubits and repositories that have no context. Matches how
  /// `MainCoreEmployeeController.getEmployeeName` decides the same thing.
  static bool get _isArabic => Get.locale?.languageCode == 'ar';

  /// Function Name: [preview]
  ///
  /// Purpose: Shorten a message body for a notification.
  ///
  /// Collapses whitespace first, so a message typed across several lines does
  /// not spend its 50 characters on newlines.
  static String preview(String body) {
    final String flat = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= previewLength) return flat;
    return '${flat.substring(0, previewLength).trimRight()}…';
  }

  /// Function Name: [_send]
  ///
  /// Purpose: The single call every trigger below funnels through.
  ///
  /// Parameters:
  /// - [recipientUserIds]: messaging ids. Resolved to emails here, the sender
  ///   removed, and duplicates dropped.
  ///
  /// Skips silently — and logs — rather than throwing. See the fire-and-forget
  /// note in the file header.
  static Future<void> _send({
    required MessagesNotificationEvent event,
    required MessagesNotificationPage page,
    required Iterable<String> recipientUserIds,
    required Map<TemplateVariable, String> variables,
    String? chatKey,
  }) async {
    try {
      // Bug report #20 — recipients who muted this chat get nothing.
      final Set<String> muted = chatKey == null
          ? const <String>{}
          : await ChatSettingsService.mutedBy(chatKey);
      if (muted.isNotEmpty) {
        recipientUserIds = recipientUserIds
            .where((id) => !muted.contains(id.trim().toLowerCase()))
            .toList();
        log('🔕 ${event.key}: ${muted.length} user(s) muted $chatKey',
            name: 'MessagesNotifications');
      }

      final String? sender = _currentUserEmail;
      if (sender == null || sender.trim().isEmpty) {
        log('⏭️ ${event.key}: no signed-in sender, skipping',
            name: 'MessagesNotifications');
        return;
      }

      final Set<String> recipients = <String>{};
      for (final String userId in recipientUserIds) {
        final String? email = emailForUserId(userId);
        if (email == null) continue;
        // Never notify yourself about your own action. The one deliberate
        // exception is scheduledMessageSent, which confirms the sender's own
        // action to them — it calls the sender directly rather than going
        // through this filter.
        if (email.toLowerCase().trim() == sender.toLowerCase().trim()) continue;
        recipients.add(email);
      }

      // LOGGED, not silent — ADDED 2/9/2026. This early return is where every
      // messaging notification died for a day: `emailForUserId` could not
      // resolve anybody, the set came out empty, and the method returned
      // without a word. From the UI that is indistinguishable from the trigger
      // never firing, which is exactly the wrong signal when debugging.
      if (recipients.isEmpty) {
        log('⏭️ ${event.key}: no resolvable recipients out of '
            '${recipientUserIds.length} id(s) — nothing sent',
            name: 'MessagesNotifications');
        return;
      }

      log('📨 ${event.key} → ${recipients.length} recipient(s)',
          name: 'MessagesNotifications');

      await AppNotificationSender.sendEventToAll(
        event: event,
        pageKey: page.key,
        senderEmail: sender,
        receiverEmails: recipients,
        isArabic: _isArabic,
        variables: variables,
      );
    } catch (e) {
      // Deliberately swallowed — see the file header.
      log('⚠️ ${event.key} failed: $e', name: 'MessagesNotifications');
    }
  }

  // ── Direct messages ───────────────────────────────────────────────────────

  /// Function Name: [notifyDirectMessage]
  ///
  /// Purpose: One of the three "message received" events, chosen by what was
  ///          actually sent.
  ///
  /// Parameters:
  /// - [isVoice] / [fileName]: which of the three events applies. A voice note
  ///   is a file too, so [isVoice] is tested FIRST — the spec gives voice its
  ///   own event and it would otherwise be reported as a generic attachment.
  /// - [body]: the text, ignored for the voice and file events.
  ///
  /// One call site covers all three so a new message type cannot be added and
  /// silently notify nobody.
  static Future<void> notifyDirectMessage({
    required String recipientUserId,
    required String senderName,
    String body = '',
    bool isVoice = false,
    String? fileName,
    String? chatKey,
  }) {
    if (isVoice) {
      return _send(
        event: MessagesNotificationEvent.voiceMessageReceived,
        page: MessagesNotificationPage.chat,
        recipientUserIds: <String>[recipientUserId],
        chatKey: chatKey,
        variables: <TemplateVariable, String>{
          TemplateVariable.senderName: senderName,
        },
      );
    }

    if (fileName != null && fileName.trim().isNotEmpty) {
      return _send(
        event: MessagesNotificationEvent.fileAttachmentReceived,
        page: MessagesNotificationPage.chat,
        recipientUserIds: <String>[recipientUserId],
        chatKey: chatKey,
        variables: <TemplateVariable, String>{
          TemplateVariable.senderName: senderName,
          TemplateVariable.fileName: fileName,
        },
      );
    }

    return _send(
      event: MessagesNotificationEvent.textMessageReceived,
      page: MessagesNotificationPage.chat,
      recipientUserIds: <String>[recipientUserId],
      chatKey: chatKey,
      variables: <TemplateVariable, String>{
        TemplateVariable.senderName: senderName,
        TemplateVariable.messagePreview: preview(body),
      },
    );
  }

  /// Function Name: [notifyGroupMessage]
  ///
  /// Purpose: Tell a group about a new message, and tell the mentioned members
  ///          they were mentioned.
  ///
  /// Parameters:
  /// - [memberUserIds]: everyone in the group. The sender is filtered out by
  ///   [_send].
  /// - [mentionedUserIds]: the subset that was @-mentioned.
  ///
  /// ⚠️ A mentioned member gets the MENTION event and NOT the plain message
  /// event — never both. Two notifications for one message reads as a bug, and
  /// the mention is the more specific of the two. That is why the plain send
  /// goes to `memberUserIds` MINUS `mentionedUserIds`.
  static Future<void> notifyGroupMessage({
    required Iterable<String> memberUserIds,
    required String groupName,
    required String senderName,
    String body = '',
    Iterable<String> mentionedUserIds = const <String>[],
    String? chatKey,
  }) async {
    final Set<String> mentioned = mentionedUserIds.toSet();
    final Set<String> others =
        memberUserIds.toSet().difference(mentioned);

    await Future.wait(<Future<void>>[
      if (mentioned.isNotEmpty)
        _send(
          event: MessagesNotificationEvent.userMentionedInGroup,
          page: MessagesNotificationPage.groupChat,
          recipientUserIds: mentioned,
          chatKey: chatKey,
          variables: <TemplateVariable, String>{
            TemplateVariable.senderName: senderName,
            TemplateVariable.groupName: groupName,
            TemplateVariable.messagePreview: preview(body),
          },
        ),
      if (others.isNotEmpty)
        _send(
          event: MessagesNotificationEvent.textMessageReceived,
          page: MessagesNotificationPage.groupChat,
          recipientUserIds: others,
          chatKey: chatKey,
          variables: <TemplateVariable, String>{
            TemplateVariable.senderName: senderName,
            TemplateVariable.messagePreview: preview(body),
          },
        ),
    ]);
  }

  /// Function Name: [notifyUnreadMessage]
  ///
  /// Purpose: The spec's "Unread Message Reminder".
  ///
  /// Raised by whatever sweeps for stale unread conversations, NOT at send
  /// time — at send time the message is not yet unread-and-ignored, it is just
  /// new. The 24-hour rule lives with the calendar entry
  /// (`MessagesCalendarEvent.messagesUnreadAfter24Hours`); this is its inbox
  /// counterpart.
  static Future<void> notifyUnreadMessage({
    required String recipientUserId,
    required String senderName,
  }) {
    return _send(
      event: MessagesNotificationEvent.unreadMessageReminder,
      page: MessagesNotificationPage.chat,
      recipientUserIds: <String>[recipientUserId],
      variables: <TemplateVariable, String>{
        TemplateVariable.senderName: senderName,
      },
    );
  }

  /// Function Name: [notifyScheduledMessageSent]
  ///
  /// Purpose: Confirm to the SENDER that their scheduled message went out.
  ///
  /// The only event addressed to the person who caused it, which is why it
  /// bypasses [_send] — that method's job is to filter the actor out of the
  /// recipients, and here the actor IS the recipient.
  static Future<void> notifyScheduledMessageSent({
    required String recipientName,
  }) async {
    try {
      final String? me = _currentUserEmail;
      if (me == null || me.trim().isEmpty) return;

      await AppNotificationSender.sendEvent(
        event: MessagesNotificationEvent.scheduledMessageSent,
        pageKey: MessagesNotificationPage.chat.key,
        senderEmail: me,
        receiverEmail: me,
        isArabic: _isArabic,
        variables: <TemplateVariable, String>{
          TemplateVariable.recipientName: recipientName,
        },
      );
    } catch (e) {
      log('⚠️ scheduled_message_sent failed: $e',
          name: 'MessagesNotifications');
    }
  }

  // ── Groups ────────────────────────────────────────────────────────────────

  static Future<void> notifyAddedToGroup({
    required Iterable<String> addedUserIds,
    required String groupName,
    required String addedByName,
  }) {
    return _send(
      event: MessagesNotificationEvent.addedToGroup,
      page: MessagesNotificationPage.groupChat,
      recipientUserIds: addedUserIds,
      variables: <TemplateVariable, String>{
        TemplateVariable.addedByName: addedByName,
        TemplateVariable.groupName: groupName,
      },
    );
  }

  /// Lands on the messaging HOME, not the group.
  ///
  /// The reader has just lost access to that conversation, so a notification
  /// that deep-links into it opens a screen they cannot read. Same reasoning
  /// for [notifyGroupDeleted].
  static Future<void> notifyRemovedFromGroup({
    required Iterable<String> removedUserIds,
    required String groupName,
    required String removedByName,
  }) {
    return _send(
      event: MessagesNotificationEvent.removedFromGroup,
      page: MessagesNotificationPage.messagingHome,
      recipientUserIds: removedUserIds,
      variables: <TemplateVariable, String>{
        TemplateVariable.groupName: groupName,
        TemplateVariable.removedByName: removedByName,
      },
    );
  }

  /// ⚠️ Call this BEFORE the group document is deleted. The recipients are its
  /// members, and once the document is gone there is no list left to read.
  static Future<void> notifyGroupDeleted({
    required Iterable<String> memberUserIds,
    required String groupName,
    required String deletedByName,
  }) {
    return _send(
      event: MessagesNotificationEvent.groupDeleted,
      page: MessagesNotificationPage.messagingHome,
      recipientUserIds: memberUserIds,
      variables: <TemplateVariable, String>{
        TemplateVariable.groupName: groupName,
        TemplateVariable.deletedByName: deletedByName,
      },
    );
  }

  // ── Polls ─────────────────────────────────────────────────────────────────

  /// Parameters:
  /// - [chatName]: the group name, or the other person's name in a one-to-one
  ///   chat. The spec words this event with `{{chatName}}` rather than
  ///   `{{groupName}}` for exactly that reason.
  static Future<void> notifyPollCreated({
    required Iterable<String> memberUserIds,
    required String chatName,
    required String createdByName,
    required String pollQuestion,
    bool isGroup = true,
  }) {
    return _send(
      event: MessagesNotificationEvent.newPollCreated,
      page: isGroup
          ? MessagesNotificationPage.groupChat
          : MessagesNotificationPage.chat,
      recipientUserIds: memberUserIds,
      variables: <TemplateVariable, String>{
        TemplateVariable.chatName: chatName,
        TemplateVariable.createdByName: createdByName,
        TemplateVariable.pollQuestion: pollQuestion,
      },
    );
  }

  /// Goes to the poll's AUTHOR alone — the event reads "New Vote on Your
  /// Poll". Notifying every member on every vote turns a ten-person poll into
  /// ninety notifications.
  ///
  /// A vote by the author on their own poll is filtered out by [_send].
  static Future<void> notifyPollVote({
    required String pollAuthorUserId,
    required String voterName,
    required String optionName,
    required String pollQuestion,
  }) {
    return _send(
      event: MessagesNotificationEvent.userVotedInPoll,
      page: MessagesNotificationPage.pollDetails,
      recipientUserIds: <String>[pollAuthorUserId],
      variables: <TemplateVariable, String>{
        TemplateVariable.voterName: voterName,
        TemplateVariable.optionName: optionName,
        TemplateVariable.pollQuestion: pollQuestion,
      },
    );
  }

  /// Drops the memoised id→email lookups.
  ///
  /// Call on sign-out: the next account's directory is a different set of
  /// people, and a stale entry here would address a notification to the
  /// previous user.
  static void clearCache() => _emailByUserId.clear();

  /// The module these notifications belong to. Exposed so a caller can assert
  /// against it without importing the AppModule enum for one comparison.
  static AppModule get module => AppModule.messages;
}
