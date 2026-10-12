/// Module: roles / r1_role_management / domain / enums / notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_permissions_enum.dart
/// Purpose: Declares `NotificationPermissions` — the switches under the
///          Notification Control block on the "Adding New Role" screen.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH → ROLE MANAGEMENT → Adding New Role → Permissions Control →
/// Notification Control. ONE column, not two: the block draws a single headed
/// card with a master toggle above five switches, and the right-hand column of
/// that row in the design is empty. That is why there is no
/// `more_permissions_enum.dart` beside this file the way `messages/` has one —
/// the second column would be an empty card.
///
/// ─── WHAT THESE FIVE ACTUALLY GATE ───────────────────────────────────
/// They are not five flavours of "can open the Notification Control screen".
/// The screen stays reachable; what changes is what a member may CHANGE on it:
///
///   * [editNotification] — may open a notification template at all and save
///     it. Without it the templates are read-only and the four below have
///     nothing left to gate.
///   * [editPushNotificationMessages] / [editEmailNotificationMessages] — may
///     rewrite the subject and body for that channel. They are separate
///     because the two channels are edited by different people in practice:
///     the push copy is short and product-owned, the email copy is long and
///     usually legal- or HR-owned. A role can be given one and not the other.
///   * [changeNotificationStatus] — may turn a single notification on or off.
///   * [changeNotificationChannel] — may change WHICH channels a notification
///     goes out on (the Email / Push checkboxes), which is a different right
///     from writing the copy that goes in them.
///
/// ⚠️ [getDataBaseName] is the exact string stored in Firestore under
/// `Demo_Permissions`. Renaming an enum CONSTANT is free; renaming its
/// database name orphans every role document already written with it — the
/// same rule `MessagesPermissions` and `KnowledgeHubPermissions` document.
///
/// ⚠️ The five labels below were added to `intl_en.arb` / `intl_ar.arb` with
/// this file. `notificationControl` (the section heading) already existed.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum NotificationPermissions implements ModulePermissionsSectionsPermission {
  editNotification,
  editPushNotificationMessages,
  editEmailNotificationMessages,
  changeNotificationStatus,
  changeNotificationChannel;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case editNotification:
        return 'Edit_Notification';
      case editPushNotificationMessages:
        return 'Edit_Push_Notification_Messages';
      case editEmailNotificationMessages:
        return 'Edit_Email_Notification_Messages';
      case changeNotificationStatus:
        return 'Change_Notification_Status';
      case changeNotificationChannel:
        return 'Change_Notification_Channel';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case editNotification:
        return S.current.editNotification;
      case editPushNotificationMessages:
        return S.current.editPushNotificationMessages;
      case editEmailNotificationMessages:
        return S.current.editEmailNotificationMessages;
      case changeNotificationStatus:
        return S.current.changeNotificationStatus;
      case changeNotificationChannel:
        return S.current.changeNotificationChannel;
    }
  }
}
