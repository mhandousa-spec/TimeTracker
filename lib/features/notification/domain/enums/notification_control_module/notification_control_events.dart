/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_control_events.dart
/// Purpose: Notification event catalog: notification control events.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: notification_control_events.dart
/// Module:    Notifications Control
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

import '../notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

enum NotificationControlNotificationEvent implements NotificationEvent {
  notificationStatusChanged(
    key: 'notification_status_changed',
    group: '',
    titleEn: 'Notification Status Updated',
    titleAr: 'تم تحديث حالة الإشعار',
    bodyEn: 'The notification status for {{moduleName}}  {{requestStatus}} has been changed to {{status}}.',
    bodyAr: 'تم تغيير حالة إشعار {{moduleName}}  {{requestStatus}} إلى {{status}}.',
    variables: {TemplateVariable.moduleName, TemplateVariable.requestStatus, TemplateVariable.status},
  ),
  notificationTemplateUpdated(
    key: 'notification_template_updated',
    group: '',
    titleEn: 'Notification Template Updated',
    titleAr: 'تم تحديث قالب الإشعار',
    bodyEn: 'The {{channel}} notification template for {{moduleName}}  {{requestStatus}} has been updated.',
    bodyAr: 'تم تحديث قالب إشعار {{channel}} الخاص بـ {{moduleName}}  {{requestStatus}}.',
    variables: {TemplateVariable.channel, TemplateVariable.moduleName, TemplateVariable.requestStatus},
  ),
  notificationChannelAdded(
    key: 'notification_channel_added',
    group: '',
    titleEn: 'Notification Channel Added',
    titleAr: 'تم إضافة قناة إشعار',
    bodyEn: '{{channel}} has been added to {{requestStatus}} notifications in the {{moduleName}} module. Users will now receive notifications through this channel.',
    bodyAr: 'تم إضافة {{channel}} إلى إشعارات {{requestStatus}} في وحدة {{moduleName}}، وسيتم إرسال الإشعارات من خلال هذه القناة.',
    variables: {TemplateVariable.channel, TemplateVariable.requestStatus, TemplateVariable.moduleName},
  ),
  notificationChannelRemoved(
    key: 'notification_channel_removed',
    group: '',
    titleEn: 'Notification Channel Removed',
    titleAr: 'تم إزالة قناة إشعار',
    bodyEn: '{{channel}} has been removed from {{requestStatus}} notifications in the {{moduleName}} module. Notifications will no longer be sent through this channel.',
    bodyAr: 'تم إزالة {{channel}} من إشعارات {{requestStatus}} في وحدة {{moduleName}}، ولن يتم إرسال الإشعارات عبر هذه القناة بعد الآن.',
    variables: {TemplateVariable.channel, TemplateVariable.requestStatus, TemplateVariable.moduleName},
  );

  const NotificationControlNotificationEvent({
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
  AppModule get module => AppModule.notificationControl;

  /// Firestore template document id: `<module>_<key>`.
  @override
  String get templateId => '${module.key}_$key';

  static NotificationControlNotificationEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
