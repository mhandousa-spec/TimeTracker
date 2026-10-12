/// Module: roles / r1_role_management / domain / enums / settings
///
/******************** FILE INFO ********************/
/// File Name: settings_permissions.dart
/// Purpose: Enum for Settings Permissions in the application
/// Created by: Mohamed Elrashidy
/// Created on: 3/9/2025
/// Updated: Added debug logging to find translation issue
/// Updated: 31/8/2026 - Aligned with the Figma "Settings" permission card
///          (ROLE MANAGEMENT page): four new permissions — Notification,
///          Haptic, Watermark and Comment And Feedback — and the declaration
///          order now IS the on-screen order.
///
/// ORDER MATTERS. `SettingsPermissionsSections.settings.sectionPermissions`
/// returns `SettingsPermissions.values` verbatim and the switches page renders
/// that list top to bottom, so the sequence below is the row order the designer
/// specified. Adding a value in the middle moves rows on screen; append only if
/// the design says so.
///
/// EACH ONE HIDES SOMETHING. Every permission here is read by
/// `settings_layout.dart` through `MainCoreEmployeeController.isHasPermission`
/// and hides its matching entry in the employee's Settings page when off. The
/// two exceptions are Screen Share and Take Screen Shot: their switch tiles
/// were removed from Settings on 31/8/2026, so those two now gate the device
/// policy itself rather than a visible row.
///
/// A NEW VALUE IS NOT ENOUGH. The switches page only draws a switch for a
/// permission whose key exists — and is `true` — in the company's
/// `Demo_Permissions/<companyId>.settings` document; the settings module takes
/// the RAW branch in `ModulesCubit.getFilteredDefaultPermissionsForModule`, so
/// Firestore is the registry. Without those keys the row renders as a label
/// with blank space where the switch belongs. The keys are the
/// [getDataBaseName] values below.
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_app_module/core/constants/strings.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
enum SettingsPermissions implements ModulePermissionsSectionsPermission {
  companyInformation,
  branding,
  notification,
  haptic,
  animation,
  biometricsForLogin,
  screenShare,
  takeScreenShot,
  restrictedLocation,
  watermark,
  commentAndFeedback;

  @override
  String get getDataBaseName {
    switch (this) {
      case companyInformation:
        return 'Company_Information';

      case branding:
        return 'Branding';

      case notification:
        return 'Notification';

      case haptic:
        return 'Haptic';

      case animation:
        return 'Animation';

      case biometricsForLogin:
        return 'Biometrics_For_Login';

      case screenShare:
        return 'Screen_Share';

      case takeScreenShot:
        return 'Take_Screen_Shot';

      case restrictedLocation:
        return 'Restricted_Location';

      // Deliberately one word, not `Water_Mark`: `PermissionLabel` folds
      // underscores to spaces before looking the name up, and the l10n key is
      // `watermark`. `Water_Mark` would fold to "water mark" and miss.
      case watermark:
        return 'Watermark';

      case commentAndFeedback:
        return 'Comment_And_Feedback';
    }
  }

  @override
  String get getUiName {
    String result;

    switch (this) {
      case companyInformation:
        result = 'Company Information';
        break;

      case branding:
        result = 'Branding';
        break;

      case notification:
        result = 'Notification';
        break;

      case haptic:
        result = 'Haptic';
        break;

      case animation:
        result = 'Animation';
        break;

      case biometricsForLogin:
        result = 'Biometrics For Login';
        break;

      case screenShare:
        result = 'Screen Share';
        break;

      case takeScreenShot:
        result = 'Take Screen Shot';
        break;

      case restrictedLocation:
        result = 'Restricted Location';
        break;

      case watermark:
        result = 'Watermark';
        break;

      case commentAndFeedback:
        result = 'Comment And Feedback';
        break;
    }

    return result;
  }

  @override
  bool get isChild {
    return false;
  }
}
