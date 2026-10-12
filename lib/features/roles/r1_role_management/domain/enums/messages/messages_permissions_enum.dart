/// Module: roles / r1_role_management / domain / enums / messages
///
///*************************** FILE INFO ****************************///
/// File Name: messages_permissions_enum.dart
/// Purpose: Declares `MessagesPermissions` — the left-hand column of the
///          Messages block on the "Adding New Role" screen.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH → ROLE MANAGEMENT → Adding New Role → Permissions Control →
/// Messages. Two columns, and they are two SECTIONS rather than one list of
/// fourteen switches — see `messages_sections_enum.dart` for why that split
/// matters.
///
/// This column is about ACTING ON A CONVERSATION: making one, reading receipts
/// in it, and what may be done to a message once sent. The other column is
/// about WHAT MAY BE ATTACHED OR CONFIGURED — see `more_permissions_enum.dart`.
///
/// ⚠️ [getDataBaseName] is the exact string stored in Firestore under
/// `Demo_Permissions`. Renaming an enum CONSTANT is free; renaming its
/// database name orphans every role document already written with it — the
/// same rule `KnowledgeHubPermissions` documents.
///
/// ⚠️ Every label here already existed in `intl_en.arb` / `intl_ar.arb` before
/// this file — none were added. If a new permission is added, add its key to
/// both ARBs first, or `S.current.<key>` will not compile.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum MessagesPermissions implements ModulePermissionsSectionsPermission {
  createGroup,
  seenAndUnseen,
  editMessage,
  deleteMessage,
  reactions,
  forwardMessages;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case createGroup:
        return 'Create_Group';
      case seenAndUnseen:
        return 'Seen_And_Unseen';
      case editMessage:
        return 'Edit_Message';
      case deleteMessage:
        return 'Delete_Message';
      case reactions:
        return 'Reactions';
      case forwardMessages:
        return 'Forward_Messages';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createGroup:
        return S.current.createGroup;
      case seenAndUnseen:
        return S.current.seenAndUnseen;
      case editMessage:
        return S.current.editMessage;
      case deleteMessage:
        return S.current.deleteMessage;
      case reactions:
        return S.current.reactions;
      case forwardMessages:
        return S.current.forwardMessages;
    }
  }
}
