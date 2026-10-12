/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: roles_module_access.dart
/// Purpose: Declares `RolesModuleAccess` — the permission gate for the Roles
///          module's four sections.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Reported: "switches of user access and active directory not work". They did
/// not, because nothing read them. `UserAccess` and `ActiveDirectory` (in
/// `r1_role_management/domain/enums/roles/`) declare twelve permissions between
/// them, the role editor writes all twelve to Firebase, and neither the User
/// Access page nor the Active Directory table ever asked about a single one —
/// every button was unconditional. Toggling a switch changed a stored value
/// that no screen consulted.
///
/// THE SECTION SWITCH IS A SEPARATE VALUE
/// -------------------------------------
/// The role editor draws a master switch per SECTION ("صلاحيات المستخدم",
/// "الدليل النشط") above that section's leaf permissions, and the two are
/// stored independently: a role can have the section OFF while individual
/// leaves underneath are still ON — that is exactly what the bug report's
/// screenshot shows. `MainCoreEmployeeController.isHasPermission` checks ONE of
/// them per call: pass `permission: null` and it reads the section value, pass
/// a permission and it reads only that leaf, never the section above it.
///
/// So a leaf check on its own leaves the master switch inert. [can] ANDs the
/// two, which is what makes turning a section off actually turn its actions
/// off. Call [can] (or the two typed wrappers) rather than reaching for
/// `isHasPermission` directly at a Roles call site.
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/active_directory_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/role_management_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_access_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';

abstract class RolesModuleAccess {
  /// Function Name: [hasSection]
  ///
  /// Purpose: Whether the role has this section's MASTER switch on.
  ///
  /// Rarely the right check on its own — a section being on says nothing about
  /// which of its actions are allowed. Use it only to decide whether a whole
  /// section-level affordance exists at all.
  ///
  /// Parameters:
  /// - [section]: the Roles section to test.
  ///
  /// Returns: [bool]
  static bool hasSection(RolePermissionsSections section) =>
      AppControllers.employee.isHasPermission(
        module: Modules.roles,
        section: section,
        // null means "read the section's own value" — see isHasPermission.
        permission: null,
      );

  /// Function Name: [can]
  ///
  /// Purpose: Whether the role may perform [permission], honouring both the
  ///          leaf switch AND the section master switch above it.
  ///
  /// The AND is the point. A leaf left on under a section that was switched off
  /// must not grant anything: the person turning the section off means "none of
  /// this", and they should not have to walk every child switch to be obeyed.
  ///
  /// Parameters:
  /// - [section]: the section the permission belongs to.
  /// - [permission]: the leaf permission being requested.
  ///
  /// Returns: [bool]
  static bool can(
    RolePermissionsSections section,
    ModulePermissionsSectionsPermission permission,
  ) {
    if (!hasSection(section)) return false;
    return AppControllers.employee.isHasPermission(
      module: Modules.roles,
      section: section,
      permission: permission,
    );
  }

  /// Typed shorthand for [RolePermissionsSections.roleManagement].
  static bool roleManagement(RoleManagement permission) =>
      can(RolePermissionsSections.roleManagement, permission);

  /// Typed shorthand for [RolePermissionsSections.userManagement].
  static bool userManagement(UserManagement permission) =>
      can(RolePermissionsSections.userManagement, permission);

  /// Typed shorthand for [RolePermissionsSections.userAccess].
  static bool userAccess(UserAccess permission) =>
      can(RolePermissionsSections.userAccess, permission);

  /// Typed shorthand for [RolePermissionsSections.activeDirectory].
  static bool activeDirectory(ActiveDirectory permission) =>
      can(RolePermissionsSections.activeDirectory, permission);
}
