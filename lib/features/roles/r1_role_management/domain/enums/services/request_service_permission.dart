/// Module: roles / r1_role_management / domain / enums / services
///
///*************************** FILE INFO ****************************///
/// File Name: request_service_permission.dart
/// Purpose: Declares `RequestServicePermission`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum RequestServicePermission implements ModulePermissionsSectionsPermission {
  requestService,
  cancelService;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case requestService:
        return 'Request_Service';
      case cancelService:
        return 'Cancel_Service';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case requestService:
        return 'Request Service';
      case cancelService:
        return 'Cancel Service';
    }
  }
}