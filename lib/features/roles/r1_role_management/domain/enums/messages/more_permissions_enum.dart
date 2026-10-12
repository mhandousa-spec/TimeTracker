/// Module: roles / r1_role_management / domain / enums / messages
///
///*************************** FILE INFO ****************************///
/// File Name: more_permissions_enum.dart
/// Purpose: Declares `MoreMessagesPermissions` — the right-hand column of the
///          Messages block on the "Adding New Role" screen.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH → ROLE MANAGEMENT → Adding New Role → Permissions Control →
/// Messages, right column ("More Permissions").
///
/// Named `MoreMessagesPermissions`, not `MorePermissions`. The Figma label is
/// just "More Permissions" because it sits under a Messages heading, but the
/// enum has no heading above it in code — a bare `MorePermissions` imported
/// into a file that also touches Services or GRC reads as "more permissions of
/// what?". `Modules.more` also already exists, which would make the short name
/// actively misleading.
///
/// The first four values are ATTACHMENT TYPES — what a sender may put in a
/// message. [poll] is the fifth thing that can be sent. The last three are
/// CONVERSATION SETTINGS the member may change rather than things they send;
/// they are in this column because the design puts them here, not because they
/// are the same kind of right.
///
/// ⚠️ [getDataBaseName] is the exact string stored in Firestore under
/// `Demo_Permissions`. See the note on [MessagesPermissions] — renaming one
/// orphans every role document already written with it.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum MoreMessagesPermissions implements ModulePermissionsSectionsPermission {
  contact,
  location,
  photo,
  documents,
  poll,
  muteNotifications,
  disappearingMessages,
  scheduleMessages;

  @override
  bool get isChild {
    return false;
  }

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
        return S.current.contact;
      case location:
        return S.current.location;
      case photo:
        return S.current.photo;
      case documents:
        return S.current.documents;
      case poll:
        return S.current.poll;
      case muteNotifications:
        return S.current.muteNotifications;
      case disappearingMessages:
        return S.current.disappearingMessages;
      case scheduleMessages:
        return S.current.scheduleMessages;
    }
  }
}
