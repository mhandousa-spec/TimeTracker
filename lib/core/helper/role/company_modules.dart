/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: company_modules.dart
/// Purpose: Declares `CompanyModules` — "is this module part of what the
///          COMPANY bought?", as opposed to "does this employee's role reach
///          it?".
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// There are two separate module gates in this app and they answer different
/// questions:
///
///   * the ROLE layer — `AppControllers.employee.hasModuleAccess(module)` and
///     the `isHasPermission` family. "Is this employee allowed in?" Per person.
///   * the LICENCE layer — the company's `Demo_Requests/{companyId}.Modules`
///     map, read by `AppDrawerRepository.getCompanyLicensedModules` and held by
///     [AppDrawerCubit]. "Did this company buy it at all?" Per company.
///
/// Until now the licence layer had no public read-out. `AppDrawerCubit` kept it
/// private and exposed only `allowedDrawerModules`, which is already
/// role ∩ licence — so a screen asking "does this company have HR?" would have
/// got "no" for a company that owns HR whenever the CURRENT USER's role happens
/// not to include it. That is the wrong answer for a question about the
/// company. This class asks the licence layer directly.
///
/// ⚠️ FAIL-OPEN, deliberately, and the opposite of the drawer's own default.
/// The drawer fails CLOSED — no licence data means show no modules — because
/// there the cost of being wrong is showing a module the company never bought.
/// Here the callers are the reverse shape: they HIDE existing UI when a module
/// is present, so "unknown" must mean "do not hide" or a slow Firestore read
/// would make working screens vanish. [isActive] therefore returns false
/// whenever it cannot answer, and every caller should be written so that false
/// leaves the screen as it was.
library;

import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

abstract class CompanyModules {
  /// Function Name: [isActive]
  ///
  /// Purpose: Whether the current COMPANY is licensed for [module], regardless
  ///          of the signed-in employee's role.
  ///
  /// Synchronous and context-free: it reads the licence map [AppDrawerCubit]
  /// already holds in memory. That map is filled by an async Firestore read at
  /// drawer construction, so this answers false for the moment before that read
  /// lands, and false again if the cubit is not registered at all (mobile
  /// layouts `Get.delete` it). See the fail-open note on this library.
  ///
  /// Parameters:
  /// - [module]: The module being asked about.
  ///
  /// Returns: [bool] true only when the licence is known AND granted.
  static bool isActive(Modules module) {
    if (!Get.isRegistered<AppDrawerCubit>()) return false;

    try {
      return Get.find<AppDrawerCubit>().isModuleLicensed(module);
    } catch (_) {
      return false;
    }
  }

  /// Function Name: [hasHr]
  ///
  /// Purpose: Shorthand for the HR module, which is the one the Roles module
  ///          currently defers to.
  ///
  /// When a company owns HR, HR is where employee records and employee requests
  /// are administered, so the Roles module hides the two screens that would
  /// otherwise be a second front door onto the same data — the Active Directory
  /// tab and User Management's Requests queue.
  ///
  /// Returns: [bool]
  static bool get hasHr => isActive(Modules.hr);
}
