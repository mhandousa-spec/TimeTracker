/// Module: roles / r1_role_management / domain / enums / grc
///
///*************************** FILE INFO ****************************///
/// File Name: grc_permissions_sections_enum.dart
/// Purpose: Declares `GrcPermissionsSections` — the four section headers of
///          the GRC permission tree, each owning its own switch list.
/// Author: Knowticed Plus team
/// Created: 13/9/2026
///
/// Mirrors the GRC permissions design (MAGDY / node 869:126152): four
/// sections, each with a toggle of its own on the header, laid out in two
/// columns. [firstColumnValues] / [lastColumnValues] reproduce that split —
/// Module + Policy on the left, Dashboards + Control on the right.
///
/// The section headers ARE switches, exactly like Services'
/// `*_Permissions_Module` rows, so they carry a [getDataBaseName] too and have
/// twin keys in the admin dashboard's grc map.

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'grc_control_permissions_enum.dart';
import 'grc_dashboards_permissions_enum.dart';
import 'grc_module_permissions_enum.dart';
import 'grc_policy_permissions_enum.dart';

enum GrcPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  modulePermissions,
  dashboards,
  policyPermissions,
  controlPermissions;

  @override
  bool get isChild => false;

  @override
  String get getName => getUiName;

  @override
  String get getDataBaseName {
    switch (this) {
      case modulePermissions:
        return 'Module_Permissions';
      case dashboards:
        return 'Dashboards';
      case policyPermissions:
        return 'Policy_Permissions';
      case controlPermissions:
        return 'Control_Permissions';
    }
  }

  @override
  String get getUiName {
    // English off the design; no ARB keys yet. See the note in
    // grc_module_permissions_enum.dart.
    switch (this) {
      case modulePermissions:
        return 'Module Permissions';
      case dashboards:
        return 'Dashboards';
      case policyPermissions:
        return 'Policy Permissions';
      case controlPermissions:
        return 'Control Permissions';
    }
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case modulePermissions:
        return GrcModulePermissions.values;
      case dashboards:
        return GrcDashboardsPermissions.values;
      case policyPermissions:
        return GrcPolicyPermissions.values;
      case controlPermissions:
        return GrcControlPermissions.values;
    }
  }

  /// Left column in the design: Module Permissions above Policy Permissions.
  static List<Enum> get firstColumnValues => [
        GrcPermissionsSections.modulePermissions,
        GrcPermissionsSections.policyPermissions,
      ];

  /// Right column: Dashboards above Control Permissions.
  static List<Enum> get lastColumnValues => [
        GrcPermissionsSections.dashboards,
        GrcPermissionsSections.controlPermissions,
      ];

  /// Every database key this module owns — the four section headers plus each
  /// section's switches.
  ///
  /// Use this to verify the two repos agree: it should equal the key set of
  /// `_getDefaultPermissionsForModule('grc')` in the admin dashboard.
  static List<String> get allDatabaseNames => [
        for (final GrcPermissionsSections section
            in GrcPermissionsSections.values) ...[
          section.getDataBaseName,
          for (final Enum permission in section.sectionPermissions)
            (permission as ModulePermissionsSectionsPermission).getDataBaseName,
        ],
      ];
}
