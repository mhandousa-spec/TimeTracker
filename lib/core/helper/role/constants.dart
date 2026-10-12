/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: constants.dart
/// Purpose: Declares `Constants`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

abstract class Constants {
  static List<String> tabletRolePageTabs = [
    'Role Management',
    'User Management',
    'User Access',
    'Active Directory',
    'Systems Logs',
  ];
  static List<String> mobileRolePageTabs = [
    'Role Management',
    'User Management',
    'User Access',
  ];
  static List<Modules> get modulesNeedsPermissions => [
        Modules.tasks,
        Modules.messages,
        Modules.employees,
        Modules.knowledgeHub,
        Modules.notes,
        Modules.tracking,
        Modules.requests,
        Modules.todo,
        Modules.formBuilder,
        Modules.database,
        Modules.inventory,
        Modules.qiyas,
        Modules.services,
        Modules.events
      ];
  static const String removedEmployeePermission = 'removed';

  static const String userAccessDateFormat = "MMM dd, yyyy";
}
