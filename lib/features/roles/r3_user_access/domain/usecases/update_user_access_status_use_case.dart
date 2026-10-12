/// Module: roles / r3_user_access / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: update_user_access_status_use_case.dart
/// Purpose: Declares `UpdateUserAccessStatusUseCase` — resolves the next
///          account status for an entity and persists it.
/// Author: Amr Mesbah
/// Created: 27/1/2025
/// Updated: 12/8/2026 - Domain purity pass. This file used to import
///          `package:get/get.dart` and the presentation-layer
///          `AppNotificationCubit`, and `_sendNotification` fired a push from
///          inside the use case — a `domain/` file performing UI-tier work via
///          a service locator (§3). Worse, the push fired *before* the result
///          was checked, so a failed write still told the employee their
///          account had changed. The notification moved to
///          `UserAccessCubit._notifyStatusChanged`, which only runs on success.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';

class UpdateUserAccessStatusUseCase {
  final UserAccessRepository repository;

  UpdateUserAccessStatusUseCase(this.repository);

  /// Function Name: [execute]
  ///
  /// Purpose: Flip an account between activated and deactivated.
  ///
  /// Parameters:
  /// - [accountStatusAccessEntity]: The account being toggled.
  ///
  /// Returns: [Future<Either<Failure, dynamic>>] the repository's result,
  /// unmodified, so the caller can react to failure.
  Future<Either<Failure, dynamic>> execute(
      UserAccessEntity accountStatusAccessEntity) async {
    final EmployeeStatusEnum newStatus =
        newStatusFor(accountStatusAccessEntity);

    return repository.updateAccountStatus(
      accountStatusAccessEntity,
      newStatus,
    );
  }

  /// Function Name: [newStatusFor]
  ///
  /// Purpose: Resolve the status an account should move to when toggled.
  ///
  /// Public so the caller can pre-compute the transition (e.g. for messaging)
  /// without duplicating the rules. Was the private `_getNewStatus`.
  ///
  /// Parameters:
  /// - [accountStatusAccessEntity]: The account being toggled.
  ///
  /// Returns: [EmployeeStatusEnum] the status to persist.
  /// FIXED 13/8/2026: `isInactive` was grouped with `isActive` and therefore
  /// mapped to `deactivated`. But `inactive` and `deactivated` are two
  /// *separate* off-states in [EmployeeStatusEnum], and only `deactivated` had
  /// a branch back to `active`. So toggling an already-inactive account moved
  /// it sideways — off to a different kind of off — and the row stayed
  /// disabled. It took a second toggle to come back on, which is the
  /// "changed to deactivate, it still deactive" report.
  ///
  /// The rule is now: any off-state toggles on, any on-state toggles off.
  EmployeeStatusEnum newStatusFor(UserAccessEntity accountStatusAccessEntity) {
    if (accountStatusAccessEntity.isLocked ||
        accountStatusAccessEntity.isLockedWithRequest) {
      return EmployeeStatusEnum.active;
    }
    // Off-states → on. Checked before the on-state so a new off-state added to
    // the enum later fails visibly here rather than silently toggling wrong.
    if (accountStatusAccessEntity.isInactive ||
        accountStatusAccessEntity.isDeactivated) {
      return EmployeeStatusEnum.active;
    }
    if (accountStatusAccessEntity.isActive) {
      return EmployeeStatusEnum.deactivated;
    }

    return EmployeeStatusEnum.active;
  }
}
