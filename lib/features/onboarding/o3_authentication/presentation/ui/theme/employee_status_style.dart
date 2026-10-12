/// Module: onboarding/o3_authentication
///
///*************************** FILE INFO ****************************///
/// File Name: employee_status_style.dart
/// Purpose: How an [EmployeeStatusEnum] is rendered — its colour and its
///          localized label.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
/// Updated: 25/8/2026 - willBeActivated now shares the #FF814A scheduled accent.
///
/// Added for CR-SKEL-O3-N31. `employee_status_enum.dart` imported
/// `package:flutter/material.dart` and returned `AppColors.*`,
/// `Color(0xFFB02A37)` and `Colors.transparent` from a `color` getter — a
/// domain enum emitting UI (§3). The enum is pure data now; everything visual
/// is here.
///
/// PLACEMENT NOTE: this is consumed by `roles/r1_role_management` and
/// `roles/r3_user_access` as well as by auth. Its natural home is
/// `core/theme/`; it sits with the enum's own feature because this pass is not
/// permitted to add files under `lib/core`.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/generated/l10n.dart';

extension EmployeeStatusStyle on EmployeeStatusEnum {
  /// The accent colour for this status, used by pills and filter chips.
  Color get color {
    switch (this) {
      case EmployeeStatusEnum.all:
        return AppColors.text;
      case EmployeeStatusEnum.active:
        return AppColors.green;
      case EmployeeStatusEnum.deactivated:
        return AppColors.red;
      case EmployeeStatusEnum.locked:
        return AppColors.statusLocked;
      // Both scheduled states share one accent (#FF814A — `AppColors.orange`
      // resolves to 0xffFF814A in the light AND dark maps, so this is the
      // requested colour in both themes without a literal here).
      //
      // CHANGED 25/8/2026: `willBeActivated` was `AppColors.grey`, which read
      // as "no status" next to the coloured chips beside it — the
      // "تفعيل مجدول" chip looked unstyled. `willBeDeactivated` was already
      // this colour and is unchanged.
      //
      // The two are told apart by their LABEL, not their colour; if they ever
      // need to be distinguishable at a glance, give `willBeActivated` its own
      // named token in AppColors rather than an inline Color() here (§12).
      case EmployeeStatusEnum.willBeDeactivated:
      case EmployeeStatusEnum.willBeActivated:
        return AppColors.orange;
      case EmployeeStatusEnum.inactive:
      case EmployeeStatusEnum.resetPassword:
      case EmployeeStatusEnum.lockedWithRequest:
        return AppColors.transparent;
    }
  }

  /// The label for this status in the active locale.
  String localizedName(BuildContext context) {
    switch (this) {
      case EmployeeStatusEnum.all:
        return S.of(context).employeeStatusAll;
      case EmployeeStatusEnum.active:
        return S.of(context).employeeStatusActive;
      case EmployeeStatusEnum.inactive:
        return S.of(context).employeeStatusInactive;
      case EmployeeStatusEnum.resetPassword:
        return S.of(context).employeeStatusResetPassword;
      case EmployeeStatusEnum.lockedWithRequest:
        return S.of(context).employeeStatusLockedWithRequest;
      case EmployeeStatusEnum.locked:
        return S.of(context).employeeStatusLocked;
      case EmployeeStatusEnum.deactivated:
        return S.of(context).employeeStatusDeactivated;
      case EmployeeStatusEnum.willBeDeactivated:
        return S.of(context).employeeStatusWillBeDeactivated;
      case EmployeeStatusEnum.willBeActivated:
        return S.of(context).employeeStatusWillBeActivated;
    }
  }
}
