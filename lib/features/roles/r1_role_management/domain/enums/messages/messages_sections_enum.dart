/// Module: roles / r1_role_management / domain / enums / messages
///
///*************************** FILE INFO ****************************///
/// File Name: messages_sections_enum.dart
/// Purpose: Declares `MessagesPermissionsSections` — the two switch groups the
///          Messages block on "Adding New Role" is built from.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH → ROLE MANAGEMENT → Adding New Role → Permissions Control →
/// Messages. The block draws two headed columns, each with its own master
/// toggle above a list of switches.
///
/// ─── WHY TWO SECTIONS AND NOT ONE LIST ───────────────────────────────
/// The master toggle is the point. Each section implements BOTH
/// [ModulePermissionsSections] (so it can own a list of permissions) and
/// [ModulePermissionsSectionsPermission] (so it can be asked about ITSELF with
/// `permission: null`), which is what lets a role turn a whole column off
/// without touching the fourteen switches underneath it. That is the same
/// double-implement `KnowledgeHubPermissionsSections` uses, and it is why the
/// enum cannot simply be a flat list of fourteen values.
///
/// Read the columns as: [messagesPermissions] is what a member may DO in a
/// conversation; [morePermissions] is what they may ATTACH to a message or
/// CONFIGURE about the conversation.
///
/// ─── COLUMN ORDER IS THE FIGMA ORDER ─────────────────────────────────
/// [firstColumnValues] and [lastColumnValues] are read by
/// `Modules.moduleFirstColumnPermissions` / `moduleLastColumnPermissions` to
/// lay the block out. Swapping them swaps the columns on screen.
///
/// ⚠️ [getDataBaseName] is stored in Firestore. Renaming one orphans every
/// role document already written with it.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'messages_permissions_enum.dart';
import 'more_permissions_enum.dart';

enum MessagesPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  messagesPermissions,
  morePermissions;

  @override
  String get getName {
    switch (this) {
      case MessagesPermissionsSections.messagesPermissions:
        return S.current.messagesPermissions;
      case MessagesPermissionsSections.morePermissions:
        return S.current.morePermissions;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case MessagesPermissionsSections.messagesPermissions:
        return 'Messages_Permissions';
      case MessagesPermissionsSections.morePermissions:
        return 'More_Permissions';
    }
  }

  @override
  String get getUiName => getName;

  @override
  bool get isChild {
    return false;
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case MessagesPermissionsSections.messagesPermissions:
        return MessagesPermissions.values;
      case MessagesPermissionsSections.morePermissions:
        return MoreMessagesPermissions.values;
    }
  }

  /// Left column in the design.
  static List<Enum> get firstColumnValues {
    return <Enum>[
      MessagesPermissionsSections.messagesPermissions,
    ];
  }

  /// Right column in the design.
  static List<Enum> get lastColumnValues {
    return <Enum>[
      MessagesPermissionsSections.morePermissions,
    ];
  }
}
