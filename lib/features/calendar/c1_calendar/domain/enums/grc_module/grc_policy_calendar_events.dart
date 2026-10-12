/// Module: calendar / c1_calendar / domain / enums / grc_module
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_policy_calendar_events.dart
/// Purpose: The GRC **Policy** calendar entries — the date-driven half of the
///          policy spec. Sibling of [GrcModuleCalendarEvent], same shape.
/// Author: Knowticed Plus team
/// Created At: 14/9/2026
///
/// WHY THESE ARE CALENDAR EVENTS AND NOT NOTIFICATIONS
/// ---------------------------------------------------
/// "…in 14 days", "…today" and "…date reached" are not things a cubit can
/// observe: nobody is running the app at the moment a date arrives. The
/// calendar derives its entries from the policy document on every read, so a
/// date that has arrived produces its card without anything having fired.
/// The action-driven half (policy created, weight updated, …) lives in
/// GrcPolicyNotificationService instead.
///
/// ONE COLOUR FOR GRC
/// ------------------
/// `colorValue` is `CalendarModulePalette.grc` (0xFFB5AF3D) on every entry,
/// the same literal GrcModuleCalendarEvent uses, so GRC reads as one module
/// on the month view rather than two.
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum GrcPolicyCalendarEvent implements CalendarEventType {
  startDateReached(
    key: 'policy_start_date_reached',
    scope: 'GRC Module - Policy',
    trigger: 'Policy Start Date Reached',
    titleEn: 'Policy Start Date Reached',
    titleAr: 'تم الوصول إلى تاريخ تفعيل السياسة',
    descriptionEn: '{{policyName}} will become active on {{startDate}}.',
    descriptionAr: 'سيتم تفعيل السياسة {{policyName}} بتاريخ {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.policyName, TemplateVariable.startDate},
    schedulingNote:
        'Placed on the activation day itself, which is what "highlighted on '
        'the activation day" means here. Unconditional: a policy whose start '
        'date has already passed still gets its card, the same rule '
        'GrcModuleCalendarEvent.activationDateDefined follows.',
  ),

  startDateUpdated(
    key: 'policy_start_date_updated',
    scope: 'GRC Module - Policy',
    trigger: 'Policy Start Date Updated',
    titleEn: 'Policy Start Date Updated',
    titleAr: 'تم تحديث تاريخ تفعيل السياسة',
    descriptionEn:
        '{{policyName}} activation date updated from {{oldStartDate}} to {{newStartDate}}.',
    descriptionAr:
        'تم تحديث موعد تفعيل السياسة {{policyName}} من {{oldStartDate}} إلى {{newStartDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.policyName,
      TemplateVariable.oldStartDate,
      TemplateVariable.newStartDate,
    },
    schedulingNote:
        'Placed on the NEW start date. The spec says the existing entry is '
        'updated rather than duplicated — because this calendar derives '
        'entries from the policy document on every read instead of storing '
        'them, that happens by construction: the old date is no longer the '
        'policy start date, so its cards simply stop being produced.',
  ),

  endDateDefined(
    key: 'policy_end_date_defined',
    scope: 'GRC Module - Policy',
    trigger: 'Policy End Date Defined',
    titleEn: 'Policy End Date Defined',
    titleAr: 'تم تحديد تاريخ انتهاء السياسة',
    descriptionEn: '{{policyName}} will expire on {{endDate}}.',
    descriptionAr: 'ستنتهي صلاحية السياسة {{policyName}} بتاريخ {{endDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.policyName, TemplateVariable.endDate},
    schedulingNote:
        'Placed on the end date, created as soon as an end date exists. NOTE '
        'this lands on the same day as expiresToday — that is what the spec '
        'asks for (one entry for "the date is set", one for "it is today"). '
        'Whoever builds these in calendar_data_service should decide whether '
        'to emit both or collapse them once the day arrives.',
  ),

  expiresIn14Days(
    key: 'policy_expires_in_14_days',
    scope: 'GRC Module - Policy',
    trigger: 'Policy Expires in 14 Days',
    titleEn: 'Policy Expires in 14 Days',
    titleAr: 'انتهاء صلاحية السياسة خلال ١٤ يوماً',
    descriptionEn: '{{policyName}} will expire on {{endDate}}.',
    descriptionAr: 'ستنتهي صلاحية السياسة {{policyName}} بتاريخ {{endDate}}.',
    statusCode: 'Reminder',
    colorValue: 0xFFB5AF3D,
    // NEGATIVE, because dateFor() ADDS this to the source date: the card must
    // land 14 days BEFORE the end date it is warning about.
    reminderOffsetDays: -14,
    variables: {TemplateVariable.policyName, TemplateVariable.endDate},
    schedulingNote:
        'Placed 14 days before the end date. The builder should skip it when '
        'that day has already passed, so a policy created inside its own '
        '14-day window does not get a reminder dated in the past — the same '
        'guard GrcModuleCalendarEvent.activationIn14Days documents.',
  ),

  expiresToday(
    key: 'policy_expires_today',
    scope: 'GRC Module - Policy',
    trigger: 'Policy Expires Today',
    titleEn: 'Policy Expires Today',
    titleAr: 'تنتهي صلاحية السياسة اليوم',
    descriptionEn: '{{policyName}} expires on {{endDate}}.',
    descriptionAr: 'تنتهي صلاحية السياسة {{policyName}} بتاريخ {{endDate}}.',
    statusCode: 'Expiring',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.policyName, TemplateVariable.endDate},
    schedulingNote:
        'Placed on the expiration date itself — "the calendar highlights the '
        'expiration date". Shares its day with endDateDefined; see the note '
        'there.',
  ),

  endDateUpdated(
    key: 'policy_end_date_updated',
    scope: 'GRC Module - Policy',
    trigger: 'Policy End Date Updated',
    titleEn: 'Policy End Date Updated',
    titleAr: 'تم تحديث تاريخ انتهاء السياسة',
    descriptionEn:
        '{{policyName}} expiration date updated from {{oldEndDate}} to {{newEndDate}}.',
    descriptionAr:
        'تم تحديث موعد انتهاء السياسة {{policyName}} من {{oldEndDate}} إلى {{newEndDate}}.',
    statusCode: 'Updated',
    colorValue: 0xFFB5AF3D,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.policyName,
      TemplateVariable.oldEndDate,
      TemplateVariable.newEndDate,
    },
    schedulingNote:
        'Placed on the NEW end date, and the old date stops producing cards '
        'by construction — same derive-on-read reasoning as startDateUpdated.',
  );

  const GrcPolicyCalendarEvent({
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
    required this.variables,
    required this.schedulingNote,
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
  final Set<TemplateVariable> variables;
  @override
  final String schedulingNote;

  @override
  AppModule get module => AppModule.grc;

  @override
  String get id => '${module.key}_$key';

  static GrcPolicyCalendarEvent? fromKey(String key) {
    for (final GrcPolicyCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
