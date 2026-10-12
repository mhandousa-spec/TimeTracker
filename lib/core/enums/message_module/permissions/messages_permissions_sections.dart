/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messages_permissions_sections.dart
/// Purpose: Enum `MessagesPermissionsSections` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

/******************** FILE INFO ********************/
/// File Name: messages_permissions_sections.dart
/// Purpose: Permission sections for the Messaging module.
/// Note: Lives inside features/messaging so the module stays self-contained.
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

import 'package:knowticed_plus/core/enums/message_module/permissions/messages_more_permissions.dart';
import 'package:knowticed_plus/core/enums/message_module/permissions/messages_permissions.dart';

enum MessagesPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  messagesPermissions,
  morePermissions;

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case MessagesPermissionsSections.messagesPermissions:
        return MessagesPermissions.values;
      case MessagesPermissionsSections.morePermissions:
        return MessagesMorePermissions.values;
    }
  }

  static List<Enum> get lastColumnValues => [morePermissions];
  static List<Enum> get firstColumnValues => [messagesPermissions];

  @override
  bool get isChild => false;

  String get getName {
    switch (this) {
      case MessagesPermissionsSections.messagesPermissions:
        return 'Messages Permissions';
      case MessagesPermissionsSections.morePermissions:
        return 'More Permissions';
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
}
