/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messages_more_permissions.dart
/// Purpose: Enum `MessagesMorePermissions` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/******************** FILE INFO ********************/
/// File Name: messages_more_permissions.dart
/// Purpose: Enum for the Messaging module's "More" attachment permissions.
/// Note: Lives inside features/messaging so the module stays self-contained.
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

enum MessagesMorePermissions implements ModulePermissionsSectionsPermission {
  contact,
  location,
  photo,
  documents,
  poll,
  muteNotifications,
  disappearingMessages,
  scheduleMessages;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case contact:
        return 'Contact';
      case location:
        return 'Location';
      case photo:
        return 'Photo';
      case documents:
        return 'Documents';
      case poll:
        return 'Poll';
      case muteNotifications:
        return 'Mute_Notifications';
      case disappearingMessages:
        return 'Disappearing_Messages';
      case scheduleMessages:
        return 'Schedule_Messages';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case contact:
        return 'Contact';
      case location:
        return 'Location';
      case photo:
        return 'Photo';
      case documents:
        return 'Documents';
      case poll:
        return 'Poll';
      case muteNotifications:
        return 'Mute Notifications';
      case disappearingMessages:
        return 'Disappearing Messages';
      case scheduleMessages:
        return 'Schedule Messages';
    }
  }
}
