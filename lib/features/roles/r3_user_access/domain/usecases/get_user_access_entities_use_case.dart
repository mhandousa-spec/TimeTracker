/// Module: roles / r3_user_access / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: get_user_access_entities_use_case.dart
/// Purpose: Declares `GetUserAccessEntitiesUseCase`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Bucketing mirrors UserAccessCard._displayStatus.

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';

class GetUserAccessEntitiesUseCase {
  UserAccessRepository repository;

  GetUserAccessEntitiesUseCase(this.repository);

  /// Method Name: [execute]
  ///
  /// Purpose: get all employees account status categorized according to status.
  /// ✅ FIXED: Prevent double-counting users with scheduled dates
  ///
  /// return: [Either<Failure, dynamic>]
  ///                                - Failure: if there is an error in the process or  [Map< EmployeeStatusEnum,UserAccessEntity>] data.
  Future<Either<Failure, dynamic>> execute() async {
    Either<Failure, dynamic> result =
    await repository.getAccountsStatusEntities();
    // Was `if (result.isLeft()) result;` — an expression statement with no
    // `return`, so a repository failure fell through and the caller received
    // an empty-but-successful map instead of the error.
    if (result.isLeft()) return result;
    List<UserAccessEntity> entities = result.getOrElse(() => []);
    Map<EmployeeStatusEnum, List<UserAccessEntity>> map = {};

    for (EmployeeStatusEnum status in EmployeeStatusEnum.values) {
      map[status] = [];
    }


    for (UserAccessEntity entity in entities) {
      final EmployeeStatusEnum primaryCategory = _bucketFor(entity);

      // ✅ Add to PRIMARY category only (never double-add)
      map[primaryCategory]!.add(entity);

      // ✅ ALWAYS add to "All" category
      map[EmployeeStatusEnum.all]!.add(entity);
    }

    result = Right(map);
    return result;
  }

  /// Function Name: [_bucketFor]
  ///
  /// Purpose: The one chip an account is counted under.
  ///
  /// FIXED 25/8/2026 — "the card in the تفعيل مجدول chip has no Edit Schedule,
  /// and it is painted green".
  ///
  /// The old rule bucketed on the DATE alone:
  ///
  ///     if (willBeActivated) -> willBeActivated            // status ignored
  ///     else if (willBeDeactivated) -> willBeDeactivated
  ///     else -> status
  ///
  /// while `UserAccessCard` decides what a card IS from the status and the date
  /// together (`_displayStatus` / `_hasSchedule`: locked first, then
  /// `!isActive && willBeActivated`, then `isActive && willBeDeactivated`).
  ///
  /// The two disagreed for an ACTIVE account still carrying an old
  /// `reactivationDate`: the chip counted it as Scheduled Activation, while the
  /// card read it as plain active — so it painted green and offered
  /// `[Edit, Deactivate]` with no Edit Schedule. Same for a LOCKED account with
  /// a leftover date, which the chip pulled out of the Locked bucket even
  /// though its card shows the locked ribbon and only offers Unlock.
  ///
  /// This now mirrors `UserAccessCard._displayStatus` exactly, so a chip and
  /// the cards inside it can no longer disagree. A stale date on an account
  /// whose status has moved on is ignored, which is also what the Figma implies
  /// (MESBAH / ROLE MANAGEMENT, User Access MAIN PAGE): Scheduled Activation is
  /// a state an INACTIVE account is in — its menu is
  /// `Edit / Edit Schedule / Cancel Activate`, while a deactivated account with
  /// no schedule gets `Edit / Active`, and an active one `Edit / Deactivate`.
  ///
  /// KEEP THE TWO IN STEP: if `_displayStatus` changes, change this with it.
  ///
  /// Parameters:
  /// - [entity]: the account to place.
  ///
  /// Returns: [EmployeeStatusEnum] the single chip it belongs under.
  EmployeeStatusEnum _bucketFor(UserAccessEntity entity) {
    // Locked wins over everything, as it does on the card.
    if (entity.isLocked || entity.isLockedWithRequest) {
      return EmployeeStatusEnum.locked;
    }

    // A schedule only counts when it agrees with where the account is now.
    if (!entity.isActive && entity.willBeActivated) {
      return EmployeeStatusEnum.willBeActivated;
    }
    if (entity.isActive && entity.willBeDeactivated) {
      return EmployeeStatusEnum.willBeDeactivated;
    }

    return _displayableCategory(entity.status);
  }

  /// Function Name: [_displayableCategory]
  ///
  /// Purpose: Map a stored status onto one the status row actually renders.
  ///
  /// ADDED 13/8/2026. `AccountStatusConstants.employeeStatus` — the chip list —
  /// renders six of the nine [EmployeeStatusEnum] values; `inactive`,
  /// `lockedWithRequest` and `resetPassword` are commented out there. Every
  /// entity was still bucketed under its raw status, so anyone holding one of
  /// those three counted towards `all` and towards no visible chip. The chips
  /// therefore could not sum to the total — the reported "how 88 and 8, the
  /// total is 98": the two missing accounts sit in a hidden bucket.
  ///
  /// Folding them into the nearest rendered equivalent keeps every account
  /// visible and makes the arithmetic hold, without inventing new chips (which
  /// is a design decision, not a bug fix). If you would rather surface these as
  /// their own chips — `lockedWithRequest` in particular is actionable, since
  /// somebody is waiting on an unlock — uncomment them in
  /// `AccountStatusConstants` and delete this method.
  EmployeeStatusEnum _displayableCategory(EmployeeStatusEnum status) {
    switch (status) {
      // Both are "access is off"; `newStatusFor` likewise treats them as one.
      case EmployeeStatusEnum.inactive:
        return EmployeeStatusEnum.deactivated;

      // Locked pending an unlock request is still locked.
      case EmployeeStatusEnum.lockedWithRequest:
        return EmployeeStatusEnum.locked;

      // The account works; it is only flagged to change password at next login.
      case EmployeeStatusEnum.resetPassword:
        return EmployeeStatusEnum.active;

      default:
        return status;
    }
  }
}