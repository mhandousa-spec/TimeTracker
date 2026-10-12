/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: messages_calendar_events.dart
/// Module:    Messages
/// Purpose:   Every calendar entry the messaging feature can place on the
///            calendar, per section 2 of "Knowticed Plus — Notification &
///            Validation".
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// `features/calendar` had per-module event files for knowledge hub, services,
/// role management, user access and settings. Messages is the sixth, and the
/// last module the spec's calendar table describes that had no file.
///
/// ─── THE THREE ENTRIES ARE NOT THE SAME SHAPE ────────────────────────
/// Two of them are about a message that has NOT been sent yet, and one is
/// about messages that HAVE been sent and not read. That matters for where the
/// source date comes from:
///
///   * [scheduledMessageDueToday] and [scheduledMessageUpcoming] both hang off
///     the scheduled SEND date, and are the same date with two different
///     offsets — `0` and `-14`. That is exactly the pattern
///     `user_access_calendar_events.dart` uses for activation reminders, and
///     it is why neither needs date arithmetic at the call site:
///     `CalendarEventModel.fromType` applies [reminderOffsetDays] itself.
///   * [messagesUnreadAfter24Hours] hangs off the DELIVERY date of the oldest
///     unread message, with a `+1` offset. It is the only entry here that is
///     placed after the fact rather than ahead of it.
///
/// ─── WORDING ─────────────────────────────────────────────────────────
/// The spec's calendar table puts the whole sentence in the "Notification
/// Title" column for these three rows, unlike every other module where the
/// title is a short label. Split here: [titleEn] is the short card label and
/// the spec's sentence is the [descriptionEn], because a calendar card renders
/// both and a full sentence as a title truncates. The spec's exact sentence is
/// preserved as the description, so nothing is lost.
///
/// Aligned with `notification/domain/enums/messages_module/messages_events.dart`
/// so a calendar card and the notification that accompanies it read the same.
///
/// ⚠️ STATUS CODES ARE ENGLISH AND MUST STAY MATCHED. `statusCode` is compared
/// as a raw string by the calendar screen's filter chips, in both languages.
/// Both codes used here — `Pending Approval` is NOT one of them — are
/// `Milestone` and `Reminder`, which the settings and user-access files already
/// rely on. Inventing a new code silently drops every card from every chip in
/// Arabic.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum MessagesCalendarEvent implements CalendarEventType {
  // ── Scheduled messages ────────────────────────────────────────────────────

  scheduledMessageUpcoming(
    key: 'scheduled_message_upcoming',
    scope: 'Scheduled Messages',
    trigger: 'Scheduled Message in 14 Days',
    titleEn: 'Scheduled Message Coming Up',
    titleAr: 'رسالة مجدولة خلال 14 يومًا',
    descriptionEn:
        'Your scheduled message to {{recipientName}} is due to be sent in 14 days.',
    descriptionAr:
        'من المقرر إرسال رسالتك المجدولة إلى {{recipientName}} خلال 14 يومًا.',
    statusCode: 'Reminder',
    colorValue: 0xFF00796B,
    // -14: placed two weeks BEFORE the send date. The call site passes the
    // send date itself and fromType does the subtraction.
    reminderOffsetDays: -14,
    variables: {TemplateVariable.recipientName},
    schedulingNote:
        'Calendar reminder is created 14 days before the scheduled send date for {RecipientName}. Only raised when the send date is more than 14 days out — otherwise the reminder would land in the past and the due-today entry is the only one that applies.',
  ),

  scheduledMessageDueToday(
    key: 'scheduled_message_due_today',
    scope: 'Scheduled Messages',
    trigger: 'Scheduled Message Due Today',
    titleEn: 'Scheduled Message Due Today',
    titleAr: 'رسالة مجدولة اليوم',
    descriptionEn:
        'Your scheduled message to {{recipientName}} is due to be sent today.',
    descriptionAr:
        'من المقرر إرسال رسالتك المجدولة إلى {{recipientName}}.',
    statusCode: 'Milestone',
    colorValue: 0xFF00796B,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.recipientName},
    schedulingNote:
        'Calendar reminder appears on the scheduled send date before the message is sent. Both this and the 14-day reminder are for the SENDER — a scheduled message is not visible to its recipient until it is delivered, so placing either on the recipient\'s calendar would disclose it early.',
  ),

  // ── Unread ────────────────────────────────────────────────────────────────

  messagesUnreadAfter24Hours(
    key: 'messages_unread_after_24_hours',
    scope: 'Unread',
    trigger: 'Messages Unread After 24 Hours',
    titleEn: 'Unread Messages',
    titleAr: 'رسائل غير مقروءة',
    descriptionEn:
        'You have {{unreadMessageCount}} unread messages from {{recipientName}}.',
    descriptionAr:
        'لديك {{unreadMessageCount}} رسائل غير مقروءة من {{recipientName}}.',
    statusCode: 'Reminder',
    colorValue: 0xFF00796B,
    // +1: a full day AFTER delivery, so the source date passed by the call
    // site is the delivery time of the oldest unread message.
    reminderOffsetDays: 1,
    variables: {
      TemplateVariable.unreadMessageCount,
      TemplateVariable.recipientName,
    },
    schedulingNote:
        'Create the calendar reminder 24 hours after message delivery if {UnreadMessageCount} is greater than 0. Update the count if the number of unread messages changes — the entry is found by its stable id and rewritten, never duplicated, so one conversation never produces two unread cards. It is removed once the count reaches zero.',
  );

  const MessagesCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.schedulingNote,
    this.variables = const <TemplateVariable>{},
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final String schedulingNote;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.messages;

  @override
  String get id => '${module.key}_$key';

  static MessagesCalendarEvent? fromKey(String key) {
    for (final MessagesCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
