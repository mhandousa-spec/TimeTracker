/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_event.dart
/// Purpose: Notification event catalog: notification event.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).

/// ************************* FILE INFO *************************
/// File Name: notification_event.dart
/// Purpose:   The contract every per-module notification event enum
///            implements, so one registry (NotificationCatalog) can walk
///            all modules without knowing any of them.
///
/// One file per module lives in `events/<module>_events.dart`. Each of
/// those declares an `enum XNotificationEvent implements NotificationEvent`.
///
/// The values here are DEFAULTS ONLY. At send time
/// AppNotificationSender.sendFromTemplate reads
/// `notification_templates/<module>_<key>` from Firestore first, so text
/// edited by an admin in Notification Control always wins. These strings
/// are what a brand-new tenant starts with and what "Reset to default"
/// restores.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

abstract interface class NotificationEvent {
  /// Stable event key. Combined with the module it forms the Firestore
  /// template id: `<module>_<key>` (e.g. `services_request_submitted`).
  ///
  /// ⚠️ Never change a key that is already live — it would orphan every
  /// template document and in-app notification pointing at it.
  String get key;

  /// Optional sub-section inside the module (e.g. 'Policy & Control'),
  /// taken from the spec. Empty when the module has no sub-sections.
  /// Used to group rows in the Notification Control screen.
  String get group;

  /// Which module raises this event.
  AppModule get module;

  /// `<module>_<key>` — the Firestore `notification_templates` document id.
  String get templateId;

  /// Default English subject.
  String get titleEn;

  /// Default Arabic subject.
  String get titleAr;

  /// Default English body, with `{{camelCase}}` placeholders.
  String get bodyEn;

  /// Default Arabic body, with `{{camelCase}}` placeholders.
  String get bodyAr;

  /// Placeholders this event expects. Callers must supply a value for each
  /// one, otherwise the token is rendered literally.
  Set<TemplateVariable> get variables;
}

extension NotificationEventLocalisation on NotificationEvent {
  String title({required bool isArabic}) => isArabic ? titleAr : titleEn;

  String body({required bool isArabic}) => isArabic ? bodyAr : bodyEn;
}
