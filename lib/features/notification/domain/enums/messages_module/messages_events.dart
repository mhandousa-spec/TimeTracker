/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: messages_events.dart
/// Module:    Messages
/// Purpose:   Every notification the messaging feature can raise, with its
///            default bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation", section 2.4.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// The messaging feature raised NO notifications. Not "some were missing" —
/// `AppNotificationSender` was not referenced anywhere under
/// `lib/features/messaging`. A message, a group invitation and a poll all
/// arrived silently, so the only way to learn about any of them was to open
/// the app and look. Every other module in the spec already had this file.
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/messages_<key>` from
/// Firestore first, so any text an admin edits in Notification Control still
/// wins. Editing this file changes the fallback + the "Reset to default"
/// value.
///
/// ─── ON {{messagePreview}} ───────────────────────────────────────────
/// It is a PREVIEW, not the message. The sender truncates it (see
/// `MessagesNotificationService.preview`), because this text reaches a push
/// payload and therefore a lock screen. Sending the whole body would put a
/// private conversation on a device nobody has unlocked.
///
/// ─── WHAT IS DELIBERATELY NOT HERE ───────────────────────────────────
/// The spec's "Unread Message Reminder" appears here as a notification AND in
/// `messages_calendar_events.dart` as a 24-hour calendar reminder. They are
/// two surfaces for one rule and share no code — that is the same split every
/// other module uses, not a duplicate.
///
/// RULE: never write an event key as a raw string. Use this enum.

import '../notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

enum MessagesNotificationEvent implements NotificationEvent {
  // ── Direct messages ───────────────────────────────────────────────────────

  textMessageReceived(
    key: 'text_message_received',
    group: '',
    titleEn: 'New Message from {{senderName}}',
    titleAr: 'رسالة جديدة من {{senderName}}',
    bodyEn: '{{senderName}} sent you a message: “{{messagePreview}}”',
    bodyAr: 'أرسل لك {{senderName}} رسالة: «{{messagePreview}}»',
    variables: {TemplateVariable.senderName, TemplateVariable.messagePreview},
  ),

  voiceMessageReceived(
    key: 'voice_message_received',
    group: '',
    titleEn: 'New Voice Message from {{senderName}}',
    titleAr: 'رسالة صوتية جديدة من {{senderName}}',
    bodyEn: '{{senderName}} sent you a voice message.',
    bodyAr: 'أرسل لك {{senderName}} رسالة صوتية.',
    // No preview: there is no text to preview, and the duration is not
    // something the spec asks for.
    variables: {TemplateVariable.senderName},
  ),

  fileAttachmentReceived(
    key: 'file_attachment_received',
    group: '',
    titleEn: 'New File from {{senderName}}',
    titleAr: 'ملف جديد من {{senderName}}',
    bodyEn: '{{senderName}} sent you a file: {{fileName}}.',
    bodyAr: 'أرسل لك {{senderName}} ملفًا: {{fileName}}.',
    variables: {TemplateVariable.senderName, TemplateVariable.fileName},
  ),

  unreadMessageReminder(
    key: 'unread_message_reminder',
    group: '',
    titleEn: 'Unread Message',
    titleAr: 'رسالة غير مقروءة',
    bodyEn: 'You have an unread message from {{senderName}}.',
    // The Arabic in the spec carries a second sentence the English does not
    // ("open the conversation to view it"). Kept as written — the spec is the
    // source, and trimming it to match English would be inventing copy.
    bodyAr: 'لديك رسالة غير مقروءة من {{senderName}}. افتح المحادثة لعرضها.',
    variables: {TemplateVariable.senderName},
  ),

  scheduledMessageSent(
    key: 'scheduled_message_sent',
    group: '',
    titleEn: 'Scheduled Message Sent',
    titleAr: 'تم إرسال الرسالة المجدولة',
    bodyEn:
        'Your scheduled message to {{recipientName}} was sent successfully.',
    bodyAr: 'تم إرسال رسالتك المجدولة إلى {{recipientName}} بنجاح.',
    // Goes to the SENDER, not the recipient — it confirms their own action.
    variables: {TemplateVariable.recipientName},
  ),

  // ── Groups ────────────────────────────────────────────────────────────────

  addedToGroup(
    key: 'added_to_group',
    group: '',
    titleEn: 'Added to a Group',
    titleAr: 'تمت إضافتك إلى مجموعة',
    bodyEn: '{{addedByName}} added you to {{groupName}}.',
    bodyAr: 'قام {{addedByName}} بإضافتك إلى مجموعة {{groupName}}.',
    variables: {TemplateVariable.addedByName, TemplateVariable.groupName},
  ),

  removedFromGroup(
    key: 'removed_from_group',
    group: '',
    titleEn: 'Removed from a Group',
    titleAr: 'تمت إزالتك من مجموعة',
    bodyEn: 'You have been removed from {{groupName}} by {{removedByName}}.',
    bodyAr:
        'تمت إزالتك من مجموعة {{groupName}} بواسطة {{removedByName}}.',
    variables: {TemplateVariable.groupName, TemplateVariable.removedByName},
  ),

  groupDeleted(
    key: 'group_deleted',
    group: '',
    titleEn: 'Group Deleted',
    titleAr: 'تم حذف المجموعة',
    bodyEn: '{{groupName}} has been deleted by {{deletedByName}}.',
    bodyAr: 'تم حذف مجموعة {{groupName}} بواسطة {{deletedByName}}.',
    variables: {TemplateVariable.groupName, TemplateVariable.deletedByName},
  ),

  userMentionedInGroup(
    key: 'user_mentioned_in_group',
    group: '',
    titleEn: 'Mention in {{groupName}}',
    titleAr: 'إشارة إليك في {{groupName}}',
    bodyEn:
        '{{senderName}} mentioned you in {{groupName}}: “{{messagePreview}}”',
    bodyAr:
        'أشار إليك {{senderName}} في مجموعة {{groupName}}: «{{messagePreview}}»',
    // Sent INSTEAD OF textMessageReceived for the members who were mentioned,
    // never as well as — see MessagesNotificationService.notifyGroupMessage.
    variables: {
      TemplateVariable.senderName,
      TemplateVariable.groupName,
      TemplateVariable.messagePreview,
    },
  ),

  // ── Polls ─────────────────────────────────────────────────────────────────

  newPollCreated(
    key: 'new_poll_created',
    group: '',
    titleEn: 'New Poll in {{chatName}}',
    titleAr: 'استطلاع جديد في {{chatName}}',
    bodyEn: '{{createdByName}} created a poll: “{{pollQuestion}}”',
    bodyAr: 'أنشأ {{createdByName}} استطلاعًا: «{{pollQuestion}}»',
    // {{chatName}} rather than {{groupName}}: the spec words it this way
    // because a poll can be raised in a one-to-one chat as well as a group,
    // and "New Poll in Ahmed" would be wrong with the group wording.
    variables: {
      TemplateVariable.chatName,
      TemplateVariable.createdByName,
      TemplateVariable.pollQuestion,
    },
  ),

  userVotedInPoll(
    key: 'user_voted_in_poll',
    group: '',
    titleEn: 'New Vote on Your Poll',
    titleAr: 'تصويت جديد على استطلاعك',
    bodyEn: '{{voterName}} voted for “{{optionName}}” in “{{pollQuestion}}”.',
    bodyAr:
        'صوّت {{voterName}} لصالح «{{optionName}}» في استطلاع «{{pollQuestion}}».',
    // Goes to the poll's AUTHOR only — "your poll". Notifying every member on
    // every vote would make a ten-person poll ninety notifications.
    variables: {
      TemplateVariable.voterName,
      TemplateVariable.optionName,
      TemplateVariable.pollQuestion,
    },
  );

  const MessagesNotificationEvent({
    required this.key,
    required this.group,
    required this.titleEn,
    required this.titleAr,
    required this.bodyEn,
    required this.bodyAr,
    required this.variables,
  });

  @override
  final String key;

  /// Sub-section this event belongs to inside the module (may be empty).
  ///
  /// Empty for all of them: the spec's Messages table has no sub-headings, and
  /// inventing groups here would add tabs to Notification Control that the
  /// spec does not describe.
  @override
  final String group;

  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String bodyEn;
  @override
  final String bodyAr;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.messages;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static MessagesNotificationEvent? fromKey(String key) {
    for (final MessagesNotificationEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
