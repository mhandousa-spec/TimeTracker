/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_calendar_events.dart
/// Module:    User Access
/// Purpose: Every calendar entry the user-access module can place on the
///          calendar — account activation and deactivation dates.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Written to complete CR-SKEL-CAL-N03, alongside `services_calendar_events`
/// and `role_management_calendar_events`.
///
/// Wording follows `notification/domain/enums/role_module/user_access_module/
/// user_access_events.dart` — the `account_activated_user`,
/// `activation_scheduled_user` and `deactivation_scheduled_user` entries — so
/// a calendar card and its notification read the same.
///
/// ⚠️ PLACEHOLDERS. Most entries declare none: the date is the card's own
/// position on the calendar and the employee name is its `taskName`, so
/// neither needs interpolating. The two `*DateUpdated` entries are the
/// exception — a card that says a date MOVED is worthless without saying what
/// it moved from and to. The assert in [CalendarEventModel.fromType] fires if
/// a declared placeholder is not supplied, so those two are raised through the
/// builder's `addWith` helper rather than its plain `add`.
///
/// ─── SCOPE: COMPLETED 1/9/2026 ───────────────────────────────────────────
///
/// This file used to carry four of the spec's eight §2 User Access entries,
/// and a note explaining that the other four were impossible. That note was
/// half wrong, and the wrong half had been copied into
/// `calendar_data_service.dart` where it kept the gap closed:
///
///   • It said `Status` "records locked/unlocked with no timestamp to hang a
///     card on". `Status` is a history list on `Employees_Info`, and
///     `NewEmployeeModelHistory.copyWithUpdateSynchronized` appends to it and
///     to the shared `timestamps` list in the SAME call — every field moves
///     forward together, which is what "synchronized" in its name means. So
///     `Status[i]` has always been dated by `timestamps[i]`; the timestamp was
///     never missing, just never looked for. This is the same index-pairing
///     the Knowledge Hub and Services builders already use.
///
///   • It said `Activation_Date` / `Deactivation_Date` are "single strings
///     with no history, so a change to either cannot be detected". True when
///     written — and superseded on 26/8/2026, when
///     `UserAccessRepository._recordScheduleChange` began stamping
///     `Activation_Date_Changed_At` / `Deactivation_Date_Changed_At` (epoch
///     ms) plus `<field>_Previous` on the EDIT branch of each scheduler. That
///     method's own doc comment says it exists "so the calendar has a date to
///     hang its '… Date Updated' card on". The stamp was added; the card was
///     not.
///
/// All eight §2 rows are now represented.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';

enum UserAccessCalendarEvent implements CalendarEventType {
  // ── Activation ────────────────────────────────────────────────────────────

  accountActivationToday(
    key: 'account_activation_today',
    scope: 'Account Lifecycle',
    trigger: 'Account Activation Date Reached',
    titleEn: 'Account Successfully Activated',
    titleAr: 'تم تفعيل الحساب بنجاح',
    descriptionEn:
        'This account has been activated and now has full access to the system. Sign-in is available using the registered credentials.',
    descriptionAr:
        'تم تفعيل هذا الحساب وأصبح لديه وصول كامل إلى النظام. يمكن تسجيل الدخول باستخدام بيانات الاعتماد المسجلة.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    schedulingNote:
        'Placed on `Activation_Date`. Emitted whenever the field parses, including for dates already past, so the activation stays visible in history.',
  ),

  accountActivationIn14Days(
    key: 'account_activation_in_14_days',
    scope: 'Account Lifecycle',
    trigger: 'Account Activation in 14 Days',
    titleEn: 'Account Activation Scheduled',
    titleAr: 'تمت جدولة تفعيل الحساب',
    descriptionEn:
        'This account is scheduled for activation and access will take effect on the scheduled date. A confirmation follows once access has been granted.',
    descriptionAr:
        'تمت جدولة تفعيل هذا الحساب وسيصبح الوصول سارياً في التاريخ المحدد. سيتم إرسال تأكيد فور منح صلاحية الوصول.',
    statusCode: 'Reminders',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    schedulingNote:
        'Fourteen days before `Activation_Date`, and only when the activation is still in the future. The offset is applied by `CalendarEventType.dateFor`, so the builder passes the raw activation date.',
  ),

  // ── Deactivation ──────────────────────────────────────────────────────────

  accountDeactivationToday(
    key: 'account_deactivation_today',
    scope: 'Account Lifecycle',
    trigger: 'Account Deactivation Date Reached',
    titleEn: 'Account Deactivated',
    titleAr: 'تم تعطيل الحساب',
    descriptionEn:
        'This account has been deactivated. Access to all system resources is suspended with immediate effect.',
    descriptionAr:
        'تم تعطيل هذا الحساب. تم تعليق الوصول إلى جميع موارد النظام بشكل فوري.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    schedulingNote:
        'The `Deactivation_Date` mirror of [accountActivationToday], with the same placement rule.',
  ),

  accountDeactivationIn14Days(
    key: 'account_deactivation_in_14_days',
    scope: 'Account Lifecycle',
    trigger: 'Account Deactivation in 14 Days',
    titleEn: 'Account Deactivation Scheduled',
    titleAr: 'تمت جدولة تعطيل الحساب',
    descriptionEn:
        'This account is scheduled for deactivation. Following that date, access to the system will no longer be available. Please contact your administrator if you have any concerns.',
    descriptionAr:
        'تمت جدولة تعطيل هذا الحساب. بعد ذلك التاريخ لن يكون الوصول إلى النظام متاحاً. يرجى التواصل مع مسؤول النظام في حال وجود أي استفسار.',
    statusCode: 'Reminders',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    schedulingNote:
        'The `Deactivation_Date` mirror of [accountActivationIn14Days], also emitted only when the date is still in the future.',
  ),

  // ── Lock / unlock ─────────────────────────────────────────────────────────
  //
  // ADDED 1/9/2026. Both are dated from the `Status` history: the index of the
  // status entry into the parallel `timestamps` list. See the header for why
  // the previous note claimed this was impossible.

  accountLocked(
    key: 'account_locked',
    scope: 'Account Lifecycle',
    trigger: 'Account Locked',
    titleEn: 'Account Locked',
    titleAr: 'تم قفل الحساب',
    descriptionEn:
        'This account has been locked and sign-in is currently blocked. Contact your system administrator to have access restored.',
    descriptionAr:
        'تم قفل هذا الحساب وتم حظر تسجيل الدخول حالياً. يرجى التواصل مع مسؤول النظام لاستعادة الوصول.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    schedulingNote:
        'Spec: "Calendar entry is created immediately on the day the account is locked." Placed on the timestamp paired with the most recent `locked` entry in the `Status` history. Only the MOST RECENT lock is raised, not every lock the account has ever had — `Status` records every status change for the life of the account, and a card per historical lock would bury the current state. The full sequence lives in System Logs.',
  ),

  accountUnlocked(
    key: 'account_unlocked',
    scope: 'Account Lifecycle',
    trigger: 'Account Unlocked',
    titleEn: 'Account Unlocked',
    titleAr: 'تم فتح الحساب',
    descriptionEn:
        'This account has been unlocked and access has been restored. Sign-in is available again; a password reset may be required on the next sign-in.',
    descriptionAr:
        'تم فتح هذا الحساب واستعادة الوصول إليه. أصبح تسجيل الدخول متاحاً مجدداً، وقد يُطلب إعادة تعيين كلمة المرور عند تسجيل الدخول التالي.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    schedulingNote:
        'An unlock is not a status of its own — it is the TRANSITION from a locked state back to `active`. Detected as an `active` entry in the `Status` history whose predecessor was `locked` or `locked with send request`, and placed on that entry\'s timestamp. Only the most recent one, matching [accountLocked]. The description mentions the password reset because `updateAccountStatus` clears the password on unlock and forces a reset on the next sign-in.',
  ),

  // ── Rescheduling ──────────────────────────────────────────────────────────
  //
  // ADDED 1/9/2026. The only two entries in this file that interpolate.

  scheduledActivationDateUpdated(
    key: 'scheduled_activation_date_updated',
    scope: 'Account Lifecycle',
    trigger: 'Scheduled Activation Date Updated',
    titleEn: 'Account Activation Date Updated',
    titleAr: 'تم تحديث موعد تفعيل الحساب',
    descriptionEn:
        'The scheduled activation date for this account has been changed from {{oldActivationDate}} to {{newActivationDate}}. Access will now take effect on the new date.',
    descriptionAr:
        'تم تغيير موعد تفعيل هذا الحساب من {{oldActivationDate}} إلى {{newActivationDate}}. سيصبح الوصول سارياً في التاريخ الجديد.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.oldActivationDate,
      TemplateVariable.newActivationDate,
    },
    schedulingNote:
        'Placed on `Activation_Date_Changed_At` — the moment the date was MOVED, not the date it was moved to. The spec says "the existing calendar event is automatically updated from {OldActivationDate} to {NewActivationDate}", and [accountActivationToday] already sits on the new date; this card records the amendment itself, so it belongs on the day the amendment was made.',
  ),

  scheduledDeactivationDateUpdated(
    key: 'scheduled_deactivation_date_updated',
    scope: 'Account Lifecycle',
    trigger: 'Scheduled Deactivation Date Updated',
    titleEn: 'Account Deactivation Date Updated',
    titleAr: 'تم تحديث موعد إيقاف الحساب',
    descriptionEn:
        'The scheduled deactivation date for this account has been changed from {{oldDeactivationDate}} to {{newDeactivationDate}}. Access will now end on the new date.',
    descriptionAr:
        'تم تغيير موعد إيقاف هذا الحساب من {{oldDeactivationDate}} إلى {{newDeactivationDate}}. سينتهي الوصول في التاريخ الجديد.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {
      TemplateVariable.oldDeactivationDate,
      TemplateVariable.newDeactivationDate,
    },
    schedulingNote:
        'The `Deactivation_Date_Changed_At` mirror of [scheduledActivationDateUpdated], with the same placement rule.',
  );

  const UserAccessCalendarEvent({
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
  AppModule get module => AppModule.userAccess;

  @override
  String get id => '${module.key}_$key';

  static UserAccessCalendarEvent? fromKey(String key) {
    for (final UserAccessCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
