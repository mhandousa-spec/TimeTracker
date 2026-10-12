/// Module: roles / r1_role_management / domain / enums / services
///
///*************************** FILE INFO ****************************///
/// File Name: services_permissions_sections.dart
/// Purpose: Declares `ServicePermissionsSections`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/request_service_permission.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/service_permissions.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import './Employee_services.dart';
import './approval_permission_work.dart';
import './dashboard_permissions.dart';
enum ServicePermissionsSections implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  servicesPermissions,
  requestServicePermissions,
  dashboardPermissions,
  approvalPermissions,
  requestedServices;

  @override
  String get getName {
    switch (this) {
      case ServicePermissionsSections.servicesPermissions:
        return 'Services Permissions';
      case ServicePermissionsSections.requestServicePermissions:
        return 'Request Service Permissions';
      case ServicePermissionsSections.dashboardPermissions:
        return 'Dashboard Permissions';
      case ServicePermissionsSections.approvalPermissions:
        return 'Approval Permissions';
      case ServicePermissionsSections.requestedServices:
        return 'Requested Services';
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case ServicePermissionsSections.servicesPermissions:
        return 'Services_Permissions_Module';
      case ServicePermissionsSections.requestServicePermissions:
        return 'Request_Service_Permissions_Module';
      case ServicePermissionsSections.dashboardPermissions:
        return 'Dashboard_Permissions_Module';
      case ServicePermissionsSections.approvalPermissions:
        return 'Approval_Permissions_Module';
      case ServicePermissionsSections.requestedServices:
        return 'Requested_Services_Module';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case ServicePermissionsSections.servicesPermissions:
        return 'Services Permissions Module';
      case ServicePermissionsSections.requestServicePermissions:
        return 'Request Service Permissions Module';
      case ServicePermissionsSections.dashboardPermissions:
        return 'Dashboard Permissions Module';
      case ServicePermissionsSections.approvalPermissions:
        return 'Approval Permissions Module';
      case ServicePermissionsSections.requestedServices:
        return 'Requested Services Module';
    }
  }

  @override
  bool get isChild {
    switch (this) {
      default:
        return false;
    }
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case ServicePermissionsSections.servicesPermissions:
        return ServicePermissions.values;
      case ServicePermissionsSections.requestServicePermissions:
        return RequestServicePermission.values;
      case ServicePermissionsSections.dashboardPermissions:
        return DashboardPermissions.values;
      case ServicePermissionsSections.approvalPermissions:
        return ApprovalPermissionsServices.values;
      case ServicePermissionsSections.requestedServices:
        return RequestServicesModule.values;
    }
  }

  static List<Enum> get lastColumnValues {
    return [
      requestServicePermissions,
      dashboardPermissions,
      approvalPermissions,
      requestedServices
    ];
  }

  static List<Enum> get firstColumnValues {
    return [
      servicesPermissions,
    ];
  }
}