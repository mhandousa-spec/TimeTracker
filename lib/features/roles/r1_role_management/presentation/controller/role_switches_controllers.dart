/// Module: roles / r1_role_management / presentation / controller
///
///********************** FILE INFO **********************
///
///  FILE NAME: role_switches_controllers.dart
///  Purpose: This file contains the RoleSwitchesControllers extension which manages permission states in the new multi-collection architecture.
///  Created by: Mohamed Elrashidy
///  Created on: 3/9/2025
///  Updated for: Multi-collection permission architecture

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

extension RoleSwitchesControllers on RoleCubit {
  /// NEW: Toggle permission state using string-based module system
  ///
  /// Purpose: Toggles a specific permission within a module using the new architecture
  ///
  /// Parameters:
  ///             moduleName[String]: The module name (e.g., 'services', 'services_app')
  ///             permissionKey[String]: The database permission key
  ///             value[bool]: The new permission value
  void togglePermissionState({
    required String moduleName,
    required String permissionKey,
    required bool value,
  }) {
    if (!selectedModules.contains(moduleName)) {
      return;
    }

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = {};
    }

    modulePermissions[moduleName]![permissionKey] = value;

    emitSafely(RolePermissionUpdated());
  }

  /// NEW: Toggle all permissions for a module (admin access equivalent)
  ///
  /// Purpose: Enables/disables all permissions for a module
  ///
  /// Parameters:
  ///             moduleName[String]: The module name
  ///             isAdmin[bool]: Whether to grant admin access
  void toggleModuleAdminAccess({
    required String moduleName,
    required bool isAdmin,
  }) {
    if (!selectedModules.contains(moduleName)) {
      return;
    }

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = {};
    }

    // Get default permissions for the module and set all to admin value
    Map<String, bool> defaultPermissions = _getDefaultPermissionsForModule(moduleName);
    defaultPermissions.forEach((key, _) {
      modulePermissions[moduleName]![key] = isAdmin;
    });

    emitSafely(RolePermissionUpdated());
  }

  /// NEW: Check if a specific permission is active
  ///
  /// Purpose: Checks if a permission is enabled for a module
  ///
  /// Parameters:
  ///             moduleName[String]: The module name
  ///             permissionKey[String]: The permission key
  bool isPermissionActive(String moduleName, String permissionKey) {
    return modulePermissions[moduleName]?[permissionKey] ?? false;
  }

  /// NEW: Check if module has admin access (all permissions enabled)
  ///
  /// Purpose: Determines if a module has all permissions enabled
  ///
  /// Parameters:
  ///             moduleName[String]: The module name
  bool isModuleAdminActive(String moduleName) {
    if (!modulePermissions.containsKey(moduleName)) return false;

    Map<String, bool> permissions = modulePermissions[moduleName]!;
    if (permissions.isEmpty) return false;

    // Check if all permissions are true
    return permissions.values.every((permission) => permission == true);
  }

  /// NEW: Get all permissions for a module
  ///
  /// Purpose: Returns all permissions for a specific module
  ///
  /// Parameters:
  ///             moduleName[String]: The module name
  Map<String, bool> getModulePermissions(String moduleName) {
    return Map<String, bool>.from(modulePermissions[moduleName] ?? {});
  }

  /// NEW: Update multiple permissions at once
  ///
  /// Purpose: Batch update permissions for a module
  ///
  /// Parameters:
  ///             moduleName[String]: The module name
  ///             permissions[Map<String, bool>]: The permissions to update
  void updateModulePermissions(String moduleName, Map<String, bool> permissions) {
    if (!selectedModules.contains(moduleName)) {
      return;
    }

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = {};
    }

    modulePermissions[moduleName]!.addAll(permissions);

    emitSafely(RolePermissionUpdated());
  }

  /// NEW: Save all permissions to database
  ///
  /// Purpose: Saves all current module permissions to their respective collections
  Future<void> saveAllPermissionsToDatabase() async {
    if (selectedRole == null) {
      return;
    }

    String roleId = selectedRole!.currentRoleName;

    // Per-module failures used to disappear into an empty `catch {}` and the
    // method still emitted RolePermissionSaved — the UI reported a successful
    // save for permissions that were never written (§11.5). Failures are now
    // collected and reported instead of the success state.
    final List<String> failedModules = <String>[];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        try {
          await roleRepository.updateModulePermissions(
            roleId: roleId,
            module: moduleName,
            permissions: modulePermissions[moduleName]!,
          );
        } catch (e, stackTrace) {
          failedModules.add(moduleName);
          debugPrint(
            'saveAllPermissionsToDatabase: $moduleName failed: $e\n$stackTrace',
          );
        }
      }
    }

    if (failedModules.isNotEmpty) {
      emitSafely(RoleError(
        'Could not save permissions for: ${failedModules.join(', ')}.',
      ));
      return;
    }

    emitSafely(RolePermissionSaved());
  }

  /// NEW: Load all permissions from database
  ///
  /// Purpose: Loads permissions for all selected modules from their collections
  Future<void> loadAllPermissionsFromDatabase() async {
    if (selectedRole == null) {
      return;
    }

    String roleId = selectedRole!.currentRoleName;
    modulePermissions.clear();

    for (String moduleName in selectedModules) {
      try {
        var result = await roleRepository.getRolePermissions(
          roleId: roleId,
          module: moduleName,
        );

        if (result.isRight()) {
          Map<String, dynamic>? permissions = result.getOrElse(() => null);
          if (permissions != null) {
            modulePermissions[moduleName] = {};

            permissions.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps' && value is List && value.isNotEmpty) {
                modulePermissions[moduleName]![key] = value.last == true;
              }
            });

          }
        }
      } catch (e) {
        // Create default permissions if loading fails
        modulePermissions[moduleName] = _getDefaultPermissionsForModule(moduleName);
      }
    }

    emitSafely(RolePermissionLoaded());
  }

  /// NEW: Reset all permissions to default
  ///
  /// Purpose: Resets all module permissions to their default values
  void resetAllPermissions() {
    for (String moduleName in selectedModules) {
      modulePermissions[moduleName] = _getDefaultPermissionsForModule(moduleName);
    }

    emitSafely(RolePermissionUpdated());
  }

  /// NEW: Clone permissions from another role
  ///
  /// Purpose: Copies permissions from another role
  ///
  /// Parameters:
  ///             sourceRole[RoleHistoryModel]: The role to copy permissions from
  Future<void> clonePermissionsFromRole(RoleHistoryModel sourceRole) async {
    String sourceRoleId = sourceRole.currentRoleName;
    List<String> sourceModules = sourceRole.currentSelectedModules;

    // Only clone permissions for modules that are selected in current role
    List<String> modulesToClone = selectedModules.where((module) =>
        sourceModules.contains(module)).toList();

    // A module whose clone fails used to vanish into an empty `catch {}`, so
    // the caller saw RolePermissionUpdated and assumed a complete copy (§11.5).
    final List<String> failedModules = <String>[];

    for (String moduleName in modulesToClone) {
      try {
        var result = await roleRepository.getRolePermissions(
          roleId: sourceRoleId,
          module: moduleName,
        );

        if (result.isRight()) {
          Map<String, dynamic>? permissions = result.getOrElse(() => null);
          if (permissions != null) {
            modulePermissions[moduleName] = {};

            permissions.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps' && value is List && value.isNotEmpty) {
                modulePermissions[moduleName]![key] = value.last == true;
              }
            });

          }
        }
      } catch (e, stackTrace) {
        failedModules.add(moduleName);
        debugPrint(
          'clonePermissionsFromRole: $moduleName failed: $e\n$stackTrace',
        );
      }
    }

    if (failedModules.isNotEmpty) {
      emitSafely(RoleError(
        'Could not copy permissions for: ${failedModules.join(', ')}.',
      ));
      return;
    }

    emitSafely(RolePermissionUpdated());
  }

  /// NEW: Get permission summary for all modules
  ///
  /// Purpose: Returns a summary of permissions across all modules
  Map<String, Map<String, dynamic>> getPermissionSummary() {
    Map<String, Map<String, dynamic>> summary = {};

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> permissions = modulePermissions[moduleName]!;
        int totalPermissions = permissions.length;
        int enabledPermissions = permissions.values.where((p) => p == true).length;

        summary[moduleName] = {
          'totalPermissions': totalPermissions,
          'enabledPermissions': enabledPermissions,
          'percentageEnabled': totalPermissions > 0 ? (enabledPermissions / totalPermissions * 100).round() : 0,
          'isFullAccess': enabledPermissions == totalPermissions && totalPermissions > 0,
          'permissions': Map<String, bool>.from(permissions),
        };
      }
    }

    return summary;
  }

  /// NEW: Validate permissions configuration
  ///
  /// Purpose: Validates that the permission configuration is valid
  List<String> validatePermissions() {
    List<String> errors = [];

    if (selectedModules.isEmpty) {
      errors.add('No modules selected');
      return errors;
    }

    for (String moduleName in selectedModules) {
      if (!modulePermissions.containsKey(moduleName)) {
        errors.add('Missing permissions for module: $moduleName');
        continue;
      }

      Map<String, bool> permissions = modulePermissions[moduleName]!;
      if (permissions.isEmpty) {
        errors.add('No permissions defined for module: $moduleName');
      }

      // Add module-specific validation here if needed
      switch (moduleName) {
        case 'services':
          if (!permissions.containsKey('Create_Service') &&
              !permissions.containsKey('Edit_Service')) {
            errors.add('Services module should have at least Create or Edit permission');
          }
          break;
        case 'services_app':
          if (!permissions.containsKey('Create_New_Form') &&
              !permissions.containsKey('Edit_Form')) {
            errors.add('Form Builder module should have at least Create or Edit permission');
          }
          break;
      }
    }

    return errors;
  }

  /// Helper method to get default permissions for a module
  Map<String, bool> _getDefaultPermissionsForModule(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':
        return {
          'Create_Service': false,
          'Edit_Service': false,
          'Delete_Service': false,
          'Bulk_Upload': false,
          'Master_Bulk_Upload': false,
          'Export_Service': false,
          'Admin_Dashboard': false,
        };
      case 'services_app':
        return {
          'Create_New_Form': false,
          'Edit_Form': false,
          'Delete_Form': false,
          'View_Submissions': false,
          'Export_Analytics_Data': false,
        };
      case 'messages':
        return {
          'Create_Group': false,
          'Edit_Message': false,
          'Delete_Message': false,
          'Forward_Messages': false,
        };
      case 'inventory':
        return {
          'Add_Product': false,
          'Edit_Product_Information': false,
          'View_Storage_Locations': false,
          'Create_Order': false,
        };
      case 'settings':
        return {
          'Take_Screenshot': false,
          'Lock_Geographical': false,
          'Company_Information': false,
          'Branding': false,
        };
      case 'qiyas':
        return {
          'Bulk_Upload': false,
          'Edit_Qiyas_Details': false,
          'Delete_Qiyas': false,
          'Dashboard': false,
        };
      case 'knowledge_hub':
        return {
          'Create_Knowledge_Hub': false,
          'Download_Documents': false,
          'View_Documents': false,
          'Analytics': false,
        };
    // ✅ ADDED: HR Module
      case 'hr':
        return {
          'HR_Module': false,
          'View_Employee_Records': false,
          'Add_Employee': false,
          'Edit_Employee': false,
          'Delete_Employee': false,
          'Bulk_Upload_Employees': false,
          'Export_Employee_Data': false,
          'Manage_Attendance': false,
          'View_Attendance_Reports': false,
          'Approve_Leave_Requests': false,
          'Manage_Payroll': false,
          'View_Payroll_Reports': false,
          'Process_Payroll': false,
          'Manage_Benefits': false,
          'View_Performance_Reviews': false,
          'Conduct_Performance_Reviews': false,
          'Manage_Training': false,
          'View_Training_Reports': false,
          'Manage_Departments': false,
          'Manage_Job_Positions': false,
          'View_HR_Analytics': false,
          'Export_HR_Reports': false,
          'Manage_Onboarding': false,
          'Manage_Offboarding': false,
          'Document_Management': false,
          'Employee_Self_Service': false,
        };
    // ✅ ADDED: CRM Module
      case 'crm':
        return {
          'CRM_Module': false,
          'View_Contacts': false,
          'Create_Contact': false,
          'Edit_Contact': false,
          'Delete_Contact': false,
          'Import_Contacts': false,
          'Export_Contacts': false,
          'View_Leads': false,
          'Create_Lead': false,
          'Edit_Lead': false,
          'Delete_Lead': false,
          'Convert_Lead': false,
          'Assign_Lead': false,
          'View_Deals': false,
          'Create_Deal': false,
          'Edit_Deal': false,
          'Delete_Deal': false,
          'Change_Deal_Stage': false,
          'View_Accounts': false,
          'Create_Account': false,
          'Edit_Account': false,
          'Delete_Account': false,
          'View_Pipeline': false,
          'Manage_Pipeline': false,
          'View_Activities': false,
          'Log_Activity': false,
          'View_CRM_Reports': false,
          'Export_CRM_Reports': false,
          'Configure_CRM_Settings': false,
          'Set_CRM_Permissions': false,
        };
    // ✅ ADDED: Notification Module
      case 'notification':
        return {
          'Notification_Module': false,
          'View_Only': false,
          'Show_Employees_Notifications': false,
          'Show_Services_Notifications': false,
          'Show_Tasks_Notifications': false,
          'Show_Todo_Notifications': false,
          'Show_Events_Notifications': false,
          'Show_Notes_Notifications': false,
          'Show_Requests_Notifications': false,
          'Show_Knowledge_Hub_Notifications': false,
          'Show_Qiyas_Notifications': false,
          'Show_Tracking_Notifications': false,
          'Show_Inventory_Notifications': false,
          'Show_Messages_Notifications': false,
          'Show_Database_Notifications': false,
          'Show_services_app_Notifications': false,
          'Show_Roles_Notifications': false,
          'Show_Settings_Notifications': false,
          'Show_GRC_Notifications': false,
          'Show_HR_Notifications': false,
          'Show_CRM_Notifications': false,
        };
    // ADDED 7/10/2026: To-Do Module (keys mirror TodoPermissions /
    // TodoPermissionsSections and the admin app).
      case 'todo':
        return {
          'To_Do_Permissions': false,
          'View_To_Do': false,
          'Create_To_Do': false,
          'Edit_To_Do': false,
          'Delete_To_Do': false,
          'Restore_To_Do': false,
        };
    // ADDED 8/10/2026: Time Tracker Module — 10 section masters + 48 switches,
    // all OFF (keys mirror TimeTrackerPermissionsSections /
    // TimeTrackerPermissions and FINAL SPEC §1).
      case 'time_tracker':
        return {
          'Check_In_Permissions': false,
          'Check_In_And_Out': false,
          'Work_From_Different_Location': false,
          'Time_Tracker_Dashboard_Permissions': false,
          'Personal_Dashboard': false,
          'HR_Dashboard': false,
          'HR_Dashboard_All_Departments': false,
          'HR_Dashboard_Filter_By_Employee': false,
          'Attendance_Permissions': false,
          'View_Attendance': false,
          'Request_Transaction': false,
          'Cancel_Transaction': false,
          'Export_Attendance': false,
          'Time_Tracker_Request_Permissions': false,
          'View_Time_Tracker_Requests': false,
          'Create_Time_Tracker_Request': false,
          'Cancel_Time_Tracker_Request': false,
          'Send_Request_Reminder': false,
          'Comment_On_Requests': false,
          'Export_Time_Tracker_Requests': false,
          'Approval_Permissions': false,
          'View_Approvals': false,
          'Approve_And_Reject': false,
          'Cancel_Request_After_Approving': false,
          'Approvals_All_Departments': false,
          'Comment_On_Approvals': false,
          'Request_Type_Permissions': false,
          'View_Request_Types': false,
          'Create_Request_Type': false,
          'Edit_Request_Type': false,
          'Change_Request_Type_Status': false,
          'Remove_Request_Type': false,
          'Export_Request_Types': false,
          'Location_Permissions': false,
          'View_Locations': false,
          'Create_Location': false,
          'Edit_Location': false,
          'Change_Location_Status': false,
          'Delete_Location': false,
          'Export_Locations': false,
          'Import_Locations': false,
          'Time_Tracker_Employee_Permissions': false,
          'View_Time_Tracker_Employees': false,
          'Employees_All_Departments': false,
          'Assign_Employee': false,
          'Reassign_Employee_Location': false,
          'Remove_Employee_Assignment': false,
          'Export_Time_Tracker_Employees': false,
          'Group_Permissions': false,
          'View_Groups': false,
          'Create_Group': false,
          'Edit_Group': false,
          'Delete_Group': false,
          'Vacation_Balance_Permissions': false,
          'View_Vacation_Balances': false,
          'Edit_Vacation_Balance': false,
          'Import_Vacation_Balances': false,
          'Export_Vacation_Balances': false,
        };
      default:
        return {
          'View_Access': false,
          'Edit_Access': false,
        };
    }
  }

  // LEGACY SUPPORT: Keep old methods for backward compatibility but mark as deprecated
  @Deprecated('Use new permission system with togglePermissionState instead')
  void toggleSwitchState({
    required Modules module,
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission permission,
  }) {
    // Convert to new system
    String moduleName = _moduleEnumToString(module);
    String permissionKey = permission.getDataBaseName;
    bool currentValue = isPermissionActive(moduleName, permissionKey);

    togglePermissionState(
      moduleName: moduleName,
      permissionKey: permissionKey,
      value: !currentValue,
    );
  }

  @Deprecated('Use new permission system with toggleModuleAdminAccess instead')
  void toggleAdminAccess({required Modules module}) {
    String moduleName = _moduleEnumToString(module);
    bool currentValue = isModuleAdminActive(moduleName);

    toggleModuleAdminAccess(
      moduleName: moduleName,
      isAdmin: !currentValue,
    );
  }

  @Deprecated('Use new permission system with isPermissionActive instead')
  bool isSwitchActive(
      Modules module,
      ModulePermissionsSections section,
      ModulePermissionsSectionsPermission permission,
      ) {
    String moduleName = _moduleEnumToString(module);
    String permissionKey = permission.getDataBaseName;
    return isPermissionActive(moduleName, permissionKey);
  }

  @Deprecated('Use new permission system with isModuleAdminActive instead')
  bool isAdminAccessActive(Modules module) {
    String moduleName = _moduleEnumToString(module);
    return isModuleAdminActive(moduleName);
  }

  /// Helper to convert Modules enum to string for legacy support
  String _moduleEnumToString(Modules module) {
    switch (module) {
      case Modules.employees:
        return 'employees';
      case Modules.services:
        return 'services';
      case Modules.tasks:
        return 'tasks';
      case Modules.todo:
        return 'todo';
      case Modules.events:
        return 'events';
      case Modules.notes:
        return 'notes';
      case Modules.requests:
        return 'requests';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.tracking:
        return 'tracking';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.database:
        return 'database_builder';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.roles:
        return 'roles';
      case Modules.settings:
        return 'settings';
      case Modules.hr:  // ✅ ADDED
        return 'hr';
      case Modules.crm:  // ✅ ADDED
        return 'crm';
      case Modules.notification:  // ✅ ADDED
        return 'notification';
      // ADDED 13/9/2026 — same fix as role_cubit.moduleEnumToString, which is
      // a duplicate of this switch. Without it GRC answered 'employees' and
      // this controller would have written GRC's switch values into the
      // employees permission document.
      case Modules.grc:
        return 'grc';
      case Modules.timeTracker: // ADDED 8/10/2026 — Time Tracker
        return 'time_tracker';
      default:
        return 'employees';
    }
  }
}