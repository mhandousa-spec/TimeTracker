/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_calendar_events.dart
/// Module:    Role Management
/// Purpose: Every calendar entry the role-management module can place on the
///          calendar — the opening and closing of a role's access window.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Written to complete CR-SKEL-CAL-N03, alongside `services_calendar_events`
/// and `user_access_calendar_events`.
///
/// The notification module's `role_management_events.dart` covers role CRUD
/// (created / updated / deleted / status changed) and has no twin for the
/// access-window entries below, so the wording here follows the register of
/// `user_access_events.dart`, which is the closest existing copy.
///
/// SOURCE: `From_Date` and `To_Date` on the role document. Both are history
/// lists, which is what lets [accessGrantedDateUpdated] and
/// [accessRevokedDateUpdated] exist at all — the builder detects a change by
/// comparing the last two entries. User Access cannot do the same because its
/// equivalent fields are single strings.
///
/// Every call site passes both `accessGrantedDate` and `accessRevokedDate`,
/// so each entry declares only the one it actually renders; the assert in
/// [CalendarEventModel.fromType] requires the declared set to be a subset of
/// what is passed, never the reverse.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum RoleManagementCalendarEvent implements CalendarEventType {
  // ── Access window opens ───────────────────────────────────────────────────

  accessGrantedImmediate(
    key: 'access_granted_immediate',
    scope: 'Access Window',
    trigger: 'Role Access Granted',
    titleEn: 'Role Access Granted',
    titleAr: 'تم منح صلاحية الدور',
    descriptionEn:
        'Access for this role has been granted effective {{accessGrantedDate}}. You now hold the permissions associated with the role.',
    descriptionAr:
        'تم منح صلاحية الوصول لهذا الدور اعتباراً من {{accessGrantedDate}}. أصبحت الآن تملك الصلاحيات المرتبطة بالدور.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Placed on `From_Date`. Emitted unconditionally whenever a start date exists, including retrospectively for windows that opened in the past.',
  ),

  accessStartsToday(
    key: 'access_starts_today',
    scope: 'Access Window',
    trigger: 'Role Access Window Opens Today',
    titleEn: 'Role Access Begins Today',
    titleAr: 'تبدأ صلاحية الدور اليوم',
    descriptionEn:
        'The access window for this role opens today, {{accessGrantedDate}}. Please review the permissions attached to the role.',
    descriptionAr:
        'تبدأ فترة صلاحية الوصول لهذا الدور اليوم، {{accessGrantedDate}}. يرجى مراجعة الصلاحيات المرتبطة بالدور.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Also placed on `From_Date`, so it lands on the same day as [accessGrantedImmediate]; the two are deliberately separate cards, one stating the grant and one marking the day.',
  ),

  accessScheduled14DaysBeforeStart(
    key: 'access_scheduled_14_days_before_start',
    scope: 'Access Window',
    trigger: 'Role Access Scheduled — 14-Day Advance Notice',
    titleEn: 'Role Access Scheduled',
    titleAr: 'تمت جدولة صلاحية الدور',
    descriptionEn:
        'Access for this role is scheduled to begin on {{accessGrantedDate}}. You will receive a confirmation once access has been granted.',
    descriptionAr:
        'من المقرر أن تبدأ صلاحية الوصول لهذا الدور بتاريخ {{accessGrantedDate}}. ستتلقى تأكيداً فور منح صلاحية الوصول.',
    statusCode: 'Reminders',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Fourteen days before `From_Date`, and only when the start is still in the future — a window that already opened gets no advance notice. The offset is applied by `CalendarEventType.dateFor`, so the builder passes the raw start date.',
  ),

  accessGrantedDateUpdated(
    key: 'access_granted_date_updated',
    scope: 'Access Window',
    trigger: 'Role Access Start Date Changed',
    titleEn: 'Role Access Schedule Updated',
    titleAr: 'تم تحديث جدول صلاحية الدور',
    descriptionEn:
        'The start of the access window for this role has been revised to {{accessGrantedDate}}. Please review the updated schedule.',
    descriptionAr:
        'تم تعديل بداية فترة صلاحية الوصول لهذا الدور إلى {{accessGrantedDate}}. يرجى مراجعة الجدول المحدّث.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Emitted only when `From_Date` has more than one history entry AND the last two differ — an unchanged re-save must not raise a card.',
  ),

  // ── Access window closes ──────────────────────────────────────────────────

  accessExpiringIn14Days(
    key: 'access_expiring_in_14_days',
    scope: 'Access Window',
    trigger: 'Role Access Expires in 14 Days',
    titleEn: 'Role Access Expiring Soon',
    titleAr: 'قرب انتهاء صلاحية الدور',
    descriptionEn:
        'Access for this role is scheduled to expire on {{accessRevokedDate}}. Please arrange an extension if continued access is required.',
    descriptionAr:
        'من المقرر أن تنتهي صلاحية الوصول لهذا الدور بتاريخ {{accessRevokedDate}}. يرجى ترتيب التمديد إذا كانت هناك حاجة لاستمرار الوصول.',
    statusCode: 'Expiring',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote:
        'Fourteen days before `To_Date`. Unlike the start-side reminder this is emitted whenever an end date exists, so an already-expired window still shows the run-up on the calendar.',
  ),

  accessRevokedExpiryDateReached(
    key: 'access_revoked_expiry_date_reached',
    scope: 'Access Window',
    trigger: 'Role Access Expiry Date Reached',
    titleEn: 'Role Access Revoked — Expiry Reached',
    titleAr: 'تم إلغاء صلاحية الدور — انتهاء المدة',
    descriptionEn:
        'Access for this role ended on {{accessRevokedDate}}. The permissions associated with the role are no longer in effect.',
    descriptionAr:
        'انتهت صلاحية الوصول لهذا الدور بتاريخ {{accessRevokedDate}}. لم تعد الصلاحيات المرتبطة بالدور سارية.',
    statusCode: 'Expiring',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote: 'Placed on `To_Date` itself.',
  ),

  accessRevokedDateUpdated(
    key: 'access_revoked_date_updated',
    scope: 'Access Window',
    trigger: 'Role Access End Date Changed',
    titleEn: 'Role Access Expiry Updated',
    titleAr: 'تم تحديث تاريخ انتهاء صلاحية الدور',
    descriptionEn:
        'The end of the access window for this role has been revised to {{accessRevokedDate}}. Please review the updated schedule.',
    descriptionAr:
        'تم تعديل نهاية فترة صلاحية الوصول لهذا الدور إلى {{accessRevokedDate}}. يرجى مراجعة الجدول المحدّث.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote:
        'The `To_Date` mirror of [accessGrantedDateUpdated], with the same two-entry comparison.',
  );

  const RoleManagementCalendarEvent({
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
  AppModule get module => AppModule.roleManagement;

  @override
  String get id => '${module.key}_$key';

  static RoleManagementCalendarEvent? fromKey(String key) {
    for (final RoleManagementCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
