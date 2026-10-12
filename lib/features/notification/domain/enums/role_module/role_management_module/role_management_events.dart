/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_events.dart
/// Purpose: Notification event catalog: role management events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: role_management_events.dart
/// Module:    Role Management
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

enum RoleManagementNotificationEvent implements NotificationEvent {
  roleCreated(
    key: 'role_created',
    group: '',
    titleEn: 'New Role Created',
    titleAr: 'تم إنشاء دور جديد',
    bodyEn: 'A new role, {{roleName}}, has been created by {{userName}}. Please review the role details.',
    bodyAr: 'تم إنشاء دور جديد باسم {{roleName}} بواسطة {{userName}}. يرجى مراجعة تفاصيل الدور.',
    variables: {TemplateVariable.roleName, TemplateVariable.userName},
  ),
  roleUpdated(
    key: 'role_updated',
    group: '',
    titleEn: 'Role Updated',
    titleAr: 'تم تحديث الدور',
    bodyEn: 'The role {{roleName}} has been updated by {{userName}}. Please review the latest role configuration and permissions.',
    bodyAr: 'تم تحديث الدور {{roleName}} بواسطة {{userName}}. يرجى مراجعة أحدث إعدادات الدور والصلاحيات الخاصة به.',
    variables: {TemplateVariable.roleName, TemplateVariable.userName},
  ),
  roleDeleted(
    key: 'role_deleted',
    group: '',
    titleEn: 'Role Deleted',
    titleAr: 'تم حذف الدور',
    bodyEn: 'The role {{roleName}} has been deleted by {{userName}}.',
    bodyAr: 'تم حذف الدور {{roleName}} بواسطة {{userName}}.',
    variables: {TemplateVariable.roleName, TemplateVariable.userName},
  ),
  roleStatusChanged(
    key: 'role_status_changed',
    group: '',
    titleEn: 'Role Status Updated',
    titleAr: 'تم تحديث حالة الدور',
    bodyEn: 'The status of role {{roleName}} has been changed from {{oldStatus}} to {{newStatus}} by {{userName}}.',
    bodyAr: 'تم تغيير حالة الدور {{roleName}} من {{oldStatus}} إلى {{newStatus}} بواسطة {{userName}}.',
    variables: {TemplateVariable.roleName, TemplateVariable.oldStatus, TemplateVariable.newStatus, TemplateVariable.userName},
  );

  const RoleManagementNotificationEvent({
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
  AppModule get module => AppModule.roleManagement;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static RoleManagementNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
