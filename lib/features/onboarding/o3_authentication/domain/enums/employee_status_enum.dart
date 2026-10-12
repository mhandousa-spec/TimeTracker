/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: employee_status_enum.dart
/// Purpose: The states an employee account can be in.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-O3-N31: `package:flutter/material.dart`, the
///          `color` getter (which returned `AppColors.*`, an inline
///          `Color(0xFFB02A37)` and `Colors.transparent`) and `localizedName`
///          moved to `presentation/ui/theme/employee_status_style.dart`. The
///          domain must not emit UI (§3). Call sites are unchanged — both are
///          extension members with the same names.

enum EmployeeStatusEnum {
  all,
  active,
  inactive,
  resetPassword,
  lockedWithRequest,
  locked,
  deactivated,
  willBeDeactivated,
  willBeActivated,
}
