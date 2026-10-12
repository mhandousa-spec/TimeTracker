/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: account_status_constants.dart
/// Purpose: Declares `AccountStatusConstants`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Chip order matches the Figma User Access page.

import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

abstract class AccountStatusConstants {
  /// The status chips on the User Access screen, in render order.
  ///
  /// REORDERED 25/8/2026 to match the Figma (MESBAH / ROLE MANAGEMENT, the
  /// User Access MAIN PAGE, node 4717:37009), which reads:
  ///
  ///   All · Active · Deactivate · Locked · Scheduled Deactivation ·
  ///   Scheduled Activation
  ///
  /// The list used to interleave them —
  /// `all, active, willBeDeactivated, deactivated, willBeActivated, locked` —
  /// which split the two plain lifecycle states apart and left a scheduled
  /// chip sitting between them. The design groups the states an account IS
  /// first, then the two states it is only SCHEDULED for.
  ///
  /// Order is the only thing this list controls, and it is what the row
  /// renders; the counts come from `GetUserAccessEntitiesUseCase`.
  static List<EmployeeStatusEnum> employeeStatus = [
    EmployeeStatusEnum.all,
    EmployeeStatusEnum.active,
    EmployeeStatusEnum.deactivated,
    EmployeeStatusEnum.locked,
    EmployeeStatusEnum.willBeDeactivated,
    EmployeeStatusEnum.willBeActivated,
    // Not rendered — folded into the chips above by
    // `GetUserAccessEntitiesUseCase._displayableCategory` so every account
    // still lands in a visible bucket and the counts sum to `all`.
    //  EmployeeStatusEnum.inactive,
    //   EmployeeStatusEnum.lockedWithRequest,
    //   EmployeeStatusEnum.resetPassword,
  ];
}
