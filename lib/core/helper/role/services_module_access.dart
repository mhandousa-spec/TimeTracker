/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: services_module_access.dart
/// Purpose: Declares `ServicesModuleAccess` — the permission gate for the
///          Services module's five sections.
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Same failure as the Roles module had before [RolesModuleAccess]: the role
/// editor writes every Services permission to Firebase, and nothing in
/// `services_management_module` ever read one. Create Service, Bulk Upload,
/// Master Upload, Export, Edit, Delete, Approve/Reject, the two dashboards and
/// the request/cancel buttons were all unconditional, so toggling any of the
/// eighteen switches under `enums/services/` changed a stored value no screen
/// consulted.
///
/// THE SECTION SWITCH IS A SEPARATE VALUE
/// -------------------------------------
/// The role editor draws a master switch per SECTION above that section's leaf
/// permissions, and the two are stored independently: a role can have the
/// section OFF while individual leaves underneath are still ON.
/// `MainCoreEmployeeController.isHasPermission` checks ONE of them per call —
/// pass `permission: null` and it reads the section value, pass a permission
/// and it reads only that leaf, never the section above it.
///
/// So a leaf check on its own leaves the master switch inert. [can] ANDs the
/// two, which is what makes turning a section off actually turn its actions
/// off. Call the typed getters below (or [can]) rather than reaching for
/// `isHasPermission` directly at a Services call site.
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/dashboard_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/employee_services.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/request_service_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/service_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';

abstract class ServicesModuleAccess {
  /// Function Name: [hasSection]
  ///
  /// Purpose: Whether the role has this section's MASTER switch on.
  ///
  /// Rarely the right check on its own — a section being on says nothing about
  /// which of its actions are allowed. Use it only to decide whether a whole
  /// section-level affordance exists at all.
  ///
  /// Parameters:
  /// - [section]: the Services section to test.
  ///
  /// Returns: [bool]
  static bool hasSection(ServicePermissionsSections section) =>
      AppControllers.employee.isHasPermission(
        module: Modules.services,
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
    ServicePermissionsSections section,
    ModulePermissionsSectionsPermission permission,
  ) {
    if (!hasSection(section)) return false;
    return AppControllers.employee.isHasPermission(
      module: Modules.services,
      section: section,
      permission: permission,
    );
  }

  /// Typed shorthand for [ServicePermissionsSections.servicesPermissions].
  static bool services(ServicePermissions permission) =>
      can(ServicePermissionsSections.servicesPermissions, permission);

  /// Typed shorthand for [ServicePermissionsSections.requestServicePermissions].
  static bool requests(RequestServicePermission permission) =>
      can(ServicePermissionsSections.requestServicePermissions, permission);

  /// Typed shorthand for [ServicePermissionsSections.dashboardPermissions].
  static bool dashboards(DashboardPermissions permission) =>
      can(ServicePermissionsSections.dashboardPermissions, permission);

  /// Typed shorthand for [ServicePermissionsSections.approvalPermissions].
  static bool approvals(ApprovalPermissionsServices permission) =>
      can(ServicePermissionsSections.approvalPermissions, permission);

  /// Typed shorthand for [ServicePermissionsSections.requestedServices].
  static bool requestedServices(RequestServicesModule permission) =>
      can(ServicePermissionsSections.requestedServices, permission);

  // ── Named gates, one per action the UI actually draws ──────────────────
  //
  // Call sites read better as `ServicesModuleAccess.canCreateService` than as
  // `ServicesModuleAccess.services(ServicePermissions.createService)`, and the
  // indirection keeps the enum import out of ~20 widget files.

  /// "Create Service" — the Add Service entry in the management popup and the
  /// create-service page it opens.
  static bool get canCreateService =>
      services(ServicePermissions.createService);

  /// "Bulk Upload" — the CSV upload entry in the management popup.
  static bool get canBulkUpload => services(ServicePermissions.bulkUpload);

  /// "Master Bulk Upload" — the Master Upload button on the services home.
  static bool get canMasterBulkUpload =>
      services(ServicePermissions.masterBulkUpload);

  /// "Export Service" — every export of the services list itself.
  static bool get canExportService =>
      services(ServicePermissions.exportService);

  /// "Edit Service" — the Edit icon on service details.
  static bool get canEditService => services(ServicePermissions.editService);

  /// "Delete Service" — the Delete icon on service details.
  static bool get canDeleteService =>
      services(ServicePermissions.deleteService);

  /// "Change Service Status" — the active/inactive switch on a service.
  static bool get canChangeServiceStatus =>
      services(ServicePermissions.changeServiceStatus);

  /// "View Requesters" — the Requested Services tab on service details, i.e.
  /// seeing WHO asked for a service.
  static bool get canViewRequesters =>
      services(ServicePermissions.viewRequesters);

  /// "Export Requested Services" — exporting that requesters table.
  static bool get canExportRequestedServices =>
      services(ServicePermissions.exportRequestedServices);

  /// "Request Service" — the Service Requests entry point where an employee
  /// raises a new request.
  static bool get canRequestService =>
      requests(RequestServicePermission.requestService);

  /// "Cancel Service" — the Cancel button on the employee's own request.
  static bool get canCancelService =>
      requests(RequestServicePermission.cancelService);

  /// "Admin Dashboard" — the services admin dashboard.
  static bool get canViewAdminDashboard =>
      dashboards(DashboardPermissions.adminDashboard);

  /// "Department Dashboard" — the per-department services dashboard.
  static bool get canViewDepartmentDashboard =>
      dashboards(DashboardPermissions.departmentDashboard);

  /// "Approve And Reject" — the approvals screen and its action buttons.
  static bool get canApproveAndReject =>
      approvals(ApprovalPermissionsServices.approveAndReject);

  /// "Status Requested" — the Requested Services screen listing the services
  /// this employee provides.
  static bool get canViewRequestedServices =>
      requestedServices(RequestServicesModule.statusRequested);
}
