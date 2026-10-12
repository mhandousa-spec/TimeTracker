/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_events.dart
/// Purpose: Notification event catalog: user access events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: user_access_events.dart
/// Module:    User Access
/// Purpose:   Every notification this module can raise, with its default
///            bilingual title/body exactly as specified in
///            "Knowticed Plus — Notification & Validation".
///
/// The enum is the DEFAULT / RESET source only. At runtime
/// AppNotificationSender reads `notification_templates/<module>_<key>`
/// from Firestore first, so any text an admin edits in Notification
/// Control still wins. Editing this file changes the fallback + the
/// "Reset to default" value.
///
/// RULE: never write an event key as a raw string. Use this enum.

import '../../notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

enum UserAccessNotificationEvent implements NotificationEvent {
  accountActivatedUser(
    key: 'account_activated_user',
    group: '',
    titleEn: 'Account Successfully Activated',
    titleAr: 'تم تفعيل حسابك بنجاح',
    bodyEn: 'Your account has been activated and you now have full access to the system. Please log in using your registered credentials.',
    bodyAr: 'تم تفعيل حسابك وأصبح بإمكانك الوصول الكامل إلى النظام. يرجى تسجيل الدخول باستخدام بيانات الاعتماد المسجلة لديك.',
    variables: const {},
  ),
  accountActivatedAdmin(
    key: 'account_activated_admin',
    group: '',
    titleEn: 'User Account Activation Confirmed',
    titleAr: 'تأكيد تفعيل حساب المستخدم',
    bodyEn: 'The system account for {{userName}} has been successfully activated. The user may now access the system using their registered credentials.',
    bodyAr: 'تم تفعيل حساب المستخدم {{userName}} بنجاح في النظام. يمكن للمستخدم الآن تسجيل الدخول باستخدام بيانات اعتماده المسجلة.',
    variables: {TemplateVariable.userName},
  ),
  accountDeactivatedAdmin(
    key: 'account_deactivated_admin',
    group: '',
    titleEn: 'User Account Deactivation Confirmed',
    titleAr: 'تأكيد تعطيل حساب المستخدم',
    bodyEn: 'The system account for {{userName}} has been successfully deactivated. The user\'s access to all system resources has been suspended with immediate effect.',
    bodyAr: 'تم تعطيل حساب المستخدم {{userName}} بنجاح في النظام. تم تعليق وصول المستخدم إلى جميع موارد النظام بشكل فوري.',
    variables: {TemplateVariable.userName},
  ),
  activationScheduledUser(
    key: 'activation_scheduled_user',
    group: '',
    titleEn: 'Account Activation Scheduled',
    titleAr: 'تمت جدولة تفعيل الحساب',
    bodyEn: 'Your account activation has been scheduled and will take effect on {{scheduledDate}}. You will receive a confirmation notification once access has been granted.',
    bodyAr: 'تمت جدولة تفعيل حسابك وسيكون سارياً اعتباراً من {{scheduledDate}}. ستتلقى إشعار تأكيد فور منح صلاحية الوصول.',
    variables: {TemplateVariable.scheduledDate},
  ),
  activationScheduledAdmin(
    key: 'activation_scheduled_admin',
    group: '',
    titleEn: 'Account Activation Successfully Scheduled',
    titleAr: 'تمت جدولة تفعيل حساب المستخدم بنجاح',
    bodyEn: 'The account activation for {{userName}} has been scheduled successfully and will be executed on the designated date.',
    bodyAr: 'تمت جدولة تفعيل حساب المستخدم {{userName}} بنجاح وسيتم تنفيذها في التاريخ المحدد.',
    variables: {TemplateVariable.userName},
  ),
  deactivationScheduledUser(
    key: 'deactivation_scheduled_user',
    group: '',
    titleEn: 'Account Deactivation Scheduled',
    titleAr: 'تمت جدولة تعطيل الحساب',
    bodyEn: 'Your account is scheduled for deactivation on {{scheduledDate}}. Following this date, access to the system will no longer be available. Please contact your administrator if you have any concerns.',
    bodyAr: 'تمت جدولة تعطيل حسابك اعتباراً من {{scheduledDate}}. بعد هذا التاريخ لن يكون بإمكانك الوصول إلى النظام. يرجى التواصل مع مسؤول النظام في حال وجود أي استفسار.',
    variables: {TemplateVariable.scheduledDate},
  ),
  deactivationScheduledAdmin(
    key: 'deactivation_scheduled_admin',
    group: '',
    titleEn: 'Account Deactivation Successfully Scheduled',
    titleAr: 'تمت جدولة تعطيل حساب المستخدم بنجاح',
    bodyEn: 'The account deactivation for {{userName}} has been scheduled successfully and will be executed on the designated date.',
    bodyAr: 'تمت جدولة تعطيل حساب المستخدم {{userName}} بنجاح وسيتم تنفيذها في التاريخ المحدد.',
    variables: {TemplateVariable.userName},
  ),
  accessScheduleUpdatedUser(
    key: 'access_schedule_updated_user',
    group: '',
    titleEn: 'Account Access Schedule Updated',
    titleAr: 'تم تحديث جدول صلاحيات الوصول',
    bodyEn: 'The access schedule associated with your account has been revised. Your access rights will be adjusted effective {{scheduledDate}}. Please review your updated access permissions.',
    bodyAr: 'تم تعديل جدول الوصول المرتبط بحسابك. ستُعدَّل صلاحيات وصولك اعتباراً من {{scheduledDate}}. يرجى مراجعة صلاحياتك المحدّثة.',
    variables: {TemplateVariable.scheduledDate},
  ),
  scheduledActionCancelledUser(
    key: 'scheduled_action_cancelled_user',
    group: '',
    titleEn: 'Scheduled Access Change Cancelled',
    titleAr: 'تم إلغاء تغيير الوصول المجدول',
    bodyEn: 'The scheduled access change for your account has been cancelled. Your current access rights remain unchanged unless modified by your system administrator.',
    bodyAr: 'تم إلغاء التغيير المجدول على صلاحيات الوصول لحسابك. تظل صلاحيات وصولك الحالية دون تغيير ما لم يُعدّلها مسؤول النظام.',
    variables: const {},
  ),
  accountUnlockedUser(
    key: 'account_unlocked_user',
    group: '',
    titleEn: 'Account Unlocked — Access Restored',
    titleAr: 'تم فتح الحساب — تم استعادة الوصول',
    bodyEn: 'Your account has been unlocked and full system access has been restored. You may log in immediately using your registered credentials.',
    bodyAr: 'تم فتح حسابك واستعادة وصولك الكامل إلى النظام. يمكنك تسجيل الدخول فوراً باستخدام بيانات اعتمادك المسجلة.',
    variables: const {},
  ),
  accountUnlockedAdmin(
    key: 'account_unlocked_admin',
    group: '',
    titleEn: 'User Account Unlocked Successfully',
    titleAr: 'تم فتح حساب المستخدم بنجاح',
    bodyEn: 'The system account for {{userName}} has been successfully unlocked. The user may now resume normal system access.',
    bodyAr: 'تم فتح حساب المستخدم {{userName}} بنجاح. يمكن للمستخدم الآن استئناف وصوله الاعتيادي إلى النظام.',
    variables: {TemplateVariable.userName},
  ),
  accountLockedFailedAttempts(
    key: 'account_locked_failed_attempts',
    group: '',
    titleEn: 'User Account Locked — Security Alert',
    titleAr: 'تنبيه أمني — تم قفل حساب المستخدم',
    bodyEn: 'The account for {{userName}} has been automatically locked following three consecutive failed authentication attempts. Please contact your system administrator to initiate the unlock process.',
    bodyAr: 'تم قفل حساب المستخدم {{userName}} تلقائياً إثر ثلاث محاولات مصادقة فاشلة متتالية. يرجى التواصل مع مسؤول النظام لاستئناف عملية فتح الحساب.',
    variables: {TemplateVariable.userName},
  ),

  /// ⚠️ NOT IN THE SPEC. Existing app behaviour: a locked-out user asks the
  /// Master Admins to unlock their account. Captured here so the text is
  /// admin-editable like every other notification, instead of being
  /// hardcoded inside AccountStatusNotificationService as it was before.
  accountUnlockRequestedAdmin(
    key: 'account_unlock_requested_admin',
    group: '',
    titleEn: 'Account Unlock Request',
    titleAr: 'طلب فتح الحساب',
    bodyEn:
        'User {{userName}} has requested to unlock their account. Please review the request and take the appropriate action.',
    bodyAr:
        'طلب المستخدم {{userName}} فتح حسابه. يرجى مراجعة الطلب واتخاذ الإجراء المناسب.',
    variables: {TemplateVariable.userName},
  );

  const UserAccessNotificationEvent({
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
  AppModule get module => AppModule.userAccess;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static UserAccessNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
