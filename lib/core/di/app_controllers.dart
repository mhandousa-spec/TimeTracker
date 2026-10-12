/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: app_controllers.dart
/// Purpose: Declares `AppControllers`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ******************* FILE INFO *******************
// File Name: app_controllers.dart
// Description: Single dependency-injection seam over the GetX service locator
//              for the app-wide controllers the services module depends on.
//              Centralising `Get.find<...>()` here means the eventual GetX
//              removal is a one-file change instead of touching ~160 call
//              sites. Call sites use `AppControllers.employee` /
//              `AppControllers.employee` and never reference GetX directly.
// Module: core / di
// *************************************************

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/wrong_employee_cubit.dart';
import 'package:knowticed_plus/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/settings/se3_company/presentation/controller/company_cubit.dart';

/// Resolves the shared "MainCore" controllers.
///
/// This is the ONLY place in the services module that should call
/// `Get.find` for these controllers. To drop GetX later, swap the two getter
/// bodies to your new DI container (e.g. `getIt<...>()`) — nothing else changes.
class AppControllers {
  const AppControllers._();

  static MainCoreEmployeeController get employee =>
      Get.find<MainCoreEmployeeController>();

  /// The settings cubit holding the signed-in employee's settings record.
  static SettingsController get settings => Get.find<SettingsController>();

  /// The theme controller. Still a `GetxController` in `core/theme/`, so this
  /// seam is what lets feature code stop importing GetX for it.
  ///
  /// `Get.put` rather than `Get.find`: the original call sites used `Get.put`,
  /// which is idempotent for an already-registered instance.
  static ThemeController get theme => Get.put(ThemeController());

  /// The active-directory (CSV import) controller.
  ///
  /// Registered by `CsvView` when the page opens; ~22 widgets and controllers
  /// in that feature used to call `Get.find<ActiveDirectoryController>()`
  /// directly.
  static ActiveDirectoryController get activeDirectory =>
      Get.find<ActiveDirectoryController>();

  /// Registers [activeDirectory] if it is not already in the locator.
  static void ensureActiveDirectory(ActiveDirectoryController Function() build) {
    if (!Get.isRegistered<ActiveDirectoryController>()) {
      Get.put(build());
    }
  }

  /// Registers a freshly initialised [EmployeeController] and returns it.
  ///
  /// Preserves the exact semantics of the original
  /// `Get.put(EmployeeController()..init())` call site — `Get.put` *replaces*
  /// any existing registration, so this must not be swapped for a `find`.
  static EmployeeController putEmployeeDirectory() =>
      Get.put(EmployeeController()..init());

  /// The wrong-employee (invalid CSV rows) cubit.
  static AddWrongEmployeeController get wrongEmployees =>
      Get.find<AddWrongEmployeeController>();

  /// The app-wide push/notification cubit, registered during login.
  ///
  /// Added so the user-access feature can drop its `Get.find<AppNotificationCubit>()`
  /// calls — one of which sat in a `domain/` use case, where a service-locator
  /// lookup is doubly wrong (GetX standing rule + §3 domain purity).
  static AppNotificationCubit get notifications => Get.find<AppNotificationCubit>();

  /// Whether [employee] can currently be resolved.
  ///
  /// Some data-layer code runs before the controller is registered and must
  /// degrade gracefully rather than throw. Exposed here so callers don't need
  /// `Get.isRegistered` — the locator stays behind this seam.
  static bool get isEmployeeRegistered =>
      Get.isRegistered<MainCoreEmployeeController>();

  /// The company-wide employee directory cubit.
  ///
  /// Distinct from [employee], which is the *current user*. Added so the user-
  /// management feature can drop its seven raw `Get.find<EmployeeController>()`
  /// calls (GetX standing rule).
  static EmployeeController get employeeDirectory => Get.find<EmployeeController>();

  /// The shared haptic-feedback controller.
  ///
  /// `Get.put(HapticController())` was called inline in six role-management
  /// widgets/pages, each one importing GetX just for that. `Get.put` is
  /// idempotent for an already-registered instance, so routing them through
  /// here is behaviour-preserving and confines GetX to this file.
  static HapticController get haptic => Get.put(HapticController());

  /// The system-logs cubit, used by the roles module to record page actions.
  static SystemLogsController get systemLogs => Get.find<SystemLogsController>();

  /// The app-wide company branding/info cubit, created and owned by main().
  ///
  /// Widgets should NOT use this — they get the cubit from the root
  /// BlocProvider via `context.read<CompanyCubit>()` / BlocBuilder. This seam
  /// exists only for the two non-widget leaves that have no context and no
  /// caller able to pass one down: RoleRepository.isCompanyAdminByEmail and
  /// UserManagementCubit's company-email lookup.
  static CompanyCubit get company => Get.find<CompanyCubit>();
}
