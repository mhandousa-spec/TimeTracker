/// Module: GRC / shared / helpers
///
/// ************************* FILE INFO *************************** ///
/// File Name: grc_permissions.dart
/// Purpose: One-line permission checks for the GRC module, so call sites read
///          as a condition rather than four lines of controller boilerplate.
/// Author: Knowticed Plus team
/// Created At: 13/9/2026
///
/// Every getter resolves to one [can] call -- the leaf switch ANDed with its
/// section's master switch:
///
/// ```dart
/// AppControllers.employee.isHasPermission(
///   module: Modules.grc,
///   section: GrcPermissionsSections.modulePermissions,
///   permission: GrcModulePermissions.createModule,
/// );
/// ```
///
/// Wrapped here for three reasons. The boilerplate appears at two dozen call
/// sites across a dozen pages, and a raw controller lookup inside `build` is
/// easy to get subtly wrong. The section/permission pairing matters: passing a
/// permission from one section with another section's header silently returns
/// false, and a mis-paired check is invisible -- the control just never
/// appears. And the section master switch is a SEPARATE stored value that a
/// leaf check does not read, so it has to be ANDed in one place rather than
/// remembered at every call site -- see [can].
///
/// The database keys behind these come from the admin dashboard; see
/// roles/r1_role_management/domain/enums/grc/grc_module_permissions_enum.dart
/// for the contract.
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_control_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_dashboards_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_module_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_permissions_sections_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/grc/grc_policy_permissions_enum.dart';

/// Permission checks for the GRC **Module** section and its Dashboards.
abstract class GrcPermission {
  GrcPermission._();

  /// function name: [hasSection]
  ///
  /// purpose: whether the role has this section's MASTER switch on.
  ///
  ///          Rarely the right check on its own -- a section being on says
  ///          nothing about which of its actions are allowed. Use it only to
  ///          decide whether a whole section-level affordance exists.
  ///
  /// parameters:
  ///            [GrcPermissionsSections] section: the section to test
  ///
  /// return type: [bool]
  static bool hasSection(GrcPermissionsSections section) =>
      // The controller is read per call, never cached in a field: it is
      // replaced on sign-out, and a captured instance would keep answering
      // for the previous user.
      AppControllers.employee.isHasPermission(
        module: Modules.grc,
        section: section,
        // null means "read the section's own value" -- see isHasPermission.
        permission: null,
      );

  /// function name: [can]
  ///
  /// purpose: whether the role may perform [permission], honouring both the
  ///          leaf switch AND the section master switch above it.
  ///
  ///          THE AND IS THE POINT. The role editor draws a master switch per
  ///          SECTION above that section's leaves, and the two are stored
  ///          independently: a role can have Policy Permissions OFF while
  ///          Edit Policy underneath is still ON.
  ///          `MainCoreEmployeeController.isHasPermission` reads ONE of them
  ///          per call, so a leaf check on its own leaves the four section
  ///          headers inert. Same shape as `ServicesModuleAccess.can` and
  ///          `RolesModuleAccess`; those two are the precedent to follow for
  ///          any other module.
  ///
  /// parameters:
  ///            [GrcPermissionsSections] section: the owning section
  ///            [ModulePermissionsSectionsPermission] permission: the leaf
  ///
  /// return type: [bool]
  static bool can(
    GrcPermissionsSections section,
    ModulePermissionsSectionsPermission permission,
  ) {
    if (!hasSection(section)) return false;
    return AppControllers.employee.isHasPermission(
      module: Modules.grc,
      section: section,
      permission: permission,
    );
  }

  static bool _moduleSection(GrcModulePermissions permission) =>
      can(GrcPermissionsSections.modulePermissions, permission);

  static bool _policySection(GrcPolicyPermissions permission) =>
      can(GrcPermissionsSections.policyPermissions, permission);

  static bool _controlSection(GrcControlPermissions permission) =>
      can(GrcPermissionsSections.controlPermissions, permission);

  static bool _dashboardsSection(GrcDashboardsPermissions permission) =>
      can(GrcPermissionsSections.dashboards, permission);

  // ── Module Permissions ─────────────────────────────────────────────────
  static bool get canCreateModule =>
      _moduleSection(GrcModulePermissions.createModule);

  static bool get canEditModule =>
      _moduleSection(GrcModulePermissions.editModule);

  static bool get canChangeModuleStatus =>
      _moduleSection(GrcModulePermissions.changeStatusOfModule);

  static bool get canDeleteModule =>
      _moduleSection(GrcModulePermissions.deleteModule);

  static bool get canRestoreModule =>
      _moduleSection(GrcModulePermissions.restoreModule);

  static bool get canViewPreviousOwnerHistory =>
      _moduleSection(GrcModulePermissions.previousModuleOwnerHistory);

  static bool get canSeeComplianceScore =>
      _moduleSection(GrcModulePermissions.showComplianceScore);

  // ── Policy Permissions ────────────────────────────────────────────────
  static bool get canCreateSinglePolicy =>
      _policySection(GrcPolicyPermissions.createSinglePolicy);

  static bool get canBulkUploadPolicy =>
      _policySection(GrcPolicyPermissions.createBulkUploadPolicy);

  /// Either route into creating a policy. Gates the "+ Policy" button itself:
  /// with neither switch on there is nothing behind it to open.
  static bool get canCreateAnyPolicy =>
      canCreateSinglePolicy || canBulkUploadPolicy;

  static bool get canDraftPolicy =>
      _policySection(GrcPolicyPermissions.draftPolicy);

  static bool get canEditPolicy =>
      _policySection(GrcPolicyPermissions.editPolicy);

  static bool get canChangePolicyStatus =>
      _policySection(GrcPolicyPermissions.changeStatusOfPolicy);

  static bool get canDeletePolicy =>
      _policySection(GrcPolicyPermissions.deletePolicy);

  static bool get canOpenPolicyWeightIssue =>
      _policySection(GrcPolicyPermissions.policyWeightIssue);

  static bool get canEditPolicyWeightIssue =>
      _policySection(GrcPolicyPermissions.editPolicyWeightIssue);

  static bool get canViewPolicyWeightHistory =>
      _policySection(GrcPolicyPermissions.policyWeightHistory);

  static bool get canSeePolicyScore =>
      _policySection(GrcPolicyPermissions.policyScore);

  // ── Control Permissions ───────────────────────────────────────────────
  //
  // Same shape as the Policy block above, because the Controls list inside a
  // policy is the Policies list one level down: same "+" button, same menu,
  // same weight-issue entry, so the same gates.
  static bool get canCreateSingleControl =>
      _controlSection(GrcControlPermissions.createSingleControl);

  static bool get canBulkUploadControl =>
      _controlSection(GrcControlPermissions.createBulkUploadControl);

  /// Either route into creating a control. Gates the "+ Control" button
  /// itself: with neither switch on there is nothing behind it to open.
  static bool get canCreateAnyControl =>
      canCreateSingleControl || canBulkUploadControl;

  static bool get canDraftControl =>
      _controlSection(GrcControlPermissions.draftControl);

  static bool get canEditControl =>
      _controlSection(GrcControlPermissions.editControl);

  static bool get canChangeControlStatus =>
      _controlSection(GrcControlPermissions.changeStatusOfControl);

  static bool get canDeleteControl =>
      _controlSection(GrcControlPermissions.deleteControl);

  static bool get canOpenControlWeightIssue =>
      _controlSection(GrcControlPermissions.controlWeightIssue);

  static bool get canEditControlWeightIssue =>
      _controlSection(GrcControlPermissions.editControlWeightIssue);

  static bool get canViewPreviousControlOwners =>
      _controlSection(GrcControlPermissions.previousControlOwners);

  // ── Dashboards ─────────────────────────────────────────────────────────
  static bool get canOpenMainModuleDashboard =>
      _dashboardsSection(GrcDashboardsPermissions.mainModuleDashboard);

  /// Cancel_Service. Gates "Cancel Request" on the GRC Requests screens
  /// (GrcRequestDetailsPage and GrcRequestsListPage `_canCancel`) -- the
  /// only cancel-a-service action GRC has.
  static bool get canCancelService =>
      _dashboardsSection(GrcDashboardsPermissions.cancelService);
}
