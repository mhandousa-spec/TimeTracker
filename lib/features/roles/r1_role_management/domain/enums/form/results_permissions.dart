/// Module: roles / r1_role_management / domain / enums / form
///
///*************************** FILE INFO ****************************///
/// File Name: results_permissions.dart
/// Purpose: Declares `ResultsPermissions`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum ResultsPermissions implements ModulePermissionsSectionsPermission {
  users,
  pendingSubmissions,
  viewSubmissions,
  exportSubmissionData,
  downloadSubmissions,
  downloadFormDigitalAssets,
  analytics,
  exportAnalyticsData;

  @override
  bool get isChild {
    switch (this) {
      case ResultsPermissions.users:
        return false;
      case ResultsPermissions.analytics:
        return false;
      case ResultsPermissions.downloadFormDigitalAssets:
        return false;
      case ResultsPermissions.pendingSubmissions:
        return true;
      case ResultsPermissions.viewSubmissions:
        return true;
      case ResultsPermissions.exportSubmissionData:
        return true;
      case ResultsPermissions.downloadSubmissions:
        return true;
      case ResultsPermissions.exportAnalyticsData:
        return true;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case users:
        return 'Users';
      case pendingSubmissions:
        return 'Pending_Submissions';
      case viewSubmissions:
        return 'View_Submissions';
      case exportSubmissionData:
        return 'Export_Submission_Data';
      case downloadSubmissions:
        return 'Download_Submissions';
      case downloadFormDigitalAssets:
        return 'Download_Form_Digital_Assets';
      case analytics:
        return 'Analytics';
      case exportAnalyticsData:
        return 'Export_Analytics_Data';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case users:
        return 'Users';
      case pendingSubmissions:
        return 'Pending Submissions';
      case viewSubmissions:
        return 'View Submissions';
      case exportSubmissionData:
        return 'Export Submission Data';
      case downloadSubmissions:
        return 'Download Submissions';
      case downloadFormDigitalAssets:
        return 'Download Form Digital Assets';
      case analytics:
        return 'Analytics';
      case exportAnalyticsData:
        return 'Export Analytics Data';
    }
  }
}