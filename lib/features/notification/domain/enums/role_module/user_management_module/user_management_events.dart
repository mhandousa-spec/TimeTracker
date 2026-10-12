/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_events.dart
/// Purpose: Notification event catalog: user management events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: user_management_events.dart
/// Module:    User Management & Permissions
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

enum UserManagementNotificationEvent implements NotificationEvent {
  accessGrantedUser(
    key: 'access_granted_user',
    group: '',
    titleEn: 'System Access Granted',
    titleAr: 'تم منح صلاحيات الوصول إلى النظام',
    bodyEn: 'Access rights have been assigned to your account. You may now utilise the designated system features in accordance with your assigned role and permissions.',
    bodyAr: 'تم تعيين حقوق الوصول لحسابك. يمكنك الآن استخدام ميزات النظام المحددة وفقاً للدور والصلاحيات المخصصة لك.',
    variables: const {},
  ),
  accessUpdatedUser(
    key: 'access_updated_user',
    group: '',
    titleEn: 'System Access Permissions Updated',
    titleAr: 'تم تحديث صلاحيات الوصول إلى النظام',
    bodyEn: 'Your system access permissions have been updated. Please log in to review your current access rights, as available features or restrictions may have changed.',
    bodyAr: 'تم تحديث صلاحيات وصولك إلى النظام. يرجى تسجيل الدخول لمراجعة حقوق الوصول الحالية، إذ قد تكون الميزات المتاحة أو القيود المفروضة قد تغيرت.',
    variables: const {},
  ),
  accessRevokedUser(
    key: 'access_revoked_user',
    group: '',
    titleEn: 'System Access Revoked',
    titleAr: 'تم سحب صلاحيات الوصول إلى النظام',
    bodyEn: 'Your system access rights have been formally revoked. You no longer have authorization to access the platform. If you believe this is in error, please contact your system administrator.',
    bodyAr: 'تم سحب حقوق وصولك إلى النظام رسمياً. لم يعد لديك تفويض للوصول إلى المنصة. إذا اعتقدت أن ذلك خطأ فيرجى التواصل مع مسؤول النظام.',
    variables: const {},
  ),
  accessRevokedAdmin(
    key: 'access_revoked_admin',
    group: '',
    titleEn: 'User Access Revocation Confirmed',
    titleAr: 'تأكيد سحب صلاحيات الوصول للمستخدم',
    bodyEn: 'System access for {{userName}} has been formally revoked. The user no longer has authorisation to access any system resources.',
    bodyAr: 'تم سحب صلاحيات وصول المستخدم {{userName}} إلى النظام رسمياً. لم يعد للمستخدم تفويض بالوصول إلى أي موارد النظام.',
    variables: {TemplateVariable.userName},
  ),
  accessChangeScheduledUser(
    key: 'access_change_scheduled_user',
    group: '',
    titleEn: 'System Access Change Scheduled',
    titleAr: 'تمت جدولة تغيير صلاحيات النظام',
    bodyEn: 'A modification to your system access rights has been scheduled and will take effect on {{scheduledDate}}. Please review your permissions following this date.',
    bodyAr: 'تمت جدولة تعديل على صلاحيات وصولك إلى النظام وستسري اعتباراً من {{scheduledDate}}. يرجى مراجعة صلاحياتك بعد هذا التاريخ.',
    variables: {TemplateVariable.scheduledDate},
  ),
  scheduledAccessAppliedUser(
    key: 'scheduled_access_applied_user',
    group: '',
    titleEn: 'Scheduled Access Change Applied',
    titleAr: 'تم تطبيق تغيير الوصول المجدول',
    bodyEn: 'The pre-scheduled modification to your system access rights has been applied successfully. Please verify your current permissions to ensure they reflect the intended changes.',
    bodyAr: 'تم تطبيق التعديل المجدول مسبقاً على صلاحيات وصولك إلى النظام بنجاح. يرجى التحقق من صلاحياتك الحالية للتأكد من أنها تعكس التغييرات المقصودة.',
    variables: const {},
  ),
  scheduledAccessAppliedAdmin(
    key: 'scheduled_access_applied_admin',
    group: '',
    titleEn: 'Scheduled Access Change Executed Successfully',
    titleAr: 'تم تنفيذ تغيير الوصول المجدول للمستخدم بنجاح',
    bodyEn: 'The scheduled access modification for {{userName}} has been executed successfully. The user\'s permissions have been updated as planned.',
    bodyAr: 'تم تنفيذ التعديل المجدول على صلاحيات المستخدم {{userName}} بنجاح. تم تحديث أذونات المستخدم وفقاً للخطة المحددة.',
    variables: {TemplateVariable.userName},
  ),
  scheduledAccessCancelledUser(
    key: 'scheduled_access_cancelled_user',
    group: '',
    titleEn: 'Scheduled Access Change Cancelled',
    titleAr: 'تم إلغاء تغيير الوصول المجدول',
    bodyEn: 'The previously scheduled modification to your system access rights has been cancelled. Your current permissions remain active and unchanged.',
    bodyAr: 'تم إلغاء التعديل المجدول مسبقاً على صلاحيات وصولك إلى النظام. تظل صلاحياتك الحالية نشطة ودون تغيير.',
    variables: const {},
  );

  const UserManagementNotificationEvent({
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
  AppModule get module => AppModule.userManagement;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static UserManagementNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
