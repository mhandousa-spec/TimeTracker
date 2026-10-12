/// Module: roles / r2_user_management / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: user_role_repository.dart
/// Purpose: Declares `UserManagementAccessRepository`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/image_selector.dart';
// REMOVED 9/10/2026: api_constants.dart — only `_getCompanyId` used it (now in LicenceSeatGuard).
import 'package:knowticed_plus/core/network/failure_model.dart';


import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/new_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/data_source/remote_data_source/role_remote_data_source.dart';
// REMOVED 9/10/2026: firebase_collections.dart — only the old `getModuleUserLimits` used it.
import 'package:knowticed_plus/core/di/app_controllers.dart';
// ADDED 25/8/2026 — spec §1.5. See the NOTIFICATIONS section below.
import 'package:knowticed_plus/features/notification/data/repository/user_management_notification_service.dart';
// ADDED 26/8/2026 — the missing trigger for the eighth §1.5 row.
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/scheduled_access_applier.dart';
// ADDED 9/10/2026 — per-module user limits (see the USER LIMITS section).
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/licence_seat_guard.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/module_user_limit_messages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class UserManagementAccessRepository {
  final RoleRemoteDataSource remoteDataSource = RoleRemoteDataSource();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ADDED 9/10/2026 — reads the Admin user limits and re-checks them inside
  /// the grant's transaction. See [_commitWithSeatCheck].
  late final LicenceSeatGuard _seatGuard = LicenceSeatGuard(
    firestore: _firestore,
    parseDate: (String raw) =>
        parseAccessDate(raw, label: 'seat') ?? defaultParseAccessDate(raw),
    deactivatedOn: _deactivationDates,
  );

  /// Detects pre-dated access changes whose start date has arrived. See
  /// [ScheduledAccessApplier] — it is the trigger for §1.5's "Scheduled Access
  /// Applied" pair, which had none.
  final ScheduledAccessApplier _scheduledAccessApplier =
      ScheduledAccessApplier();

  getUsersPermissionsData() async {
    final totalStopwatch = Stopwatch()..start();

    try {
      Map<String, NewEmployeeModelHistory> users = await _getEmployees();

      if (users.isEmpty) {
        totalStopwatch.stop();
        return Right(<UserPermissionEntity>[]);
      }

      Either<Failure, dynamic> result = await _getUsersPermissions(users);

      // ADDED 26/8/2026 — unawaited on purpose. The screen is waiting on
      // [result] and has no use for the applier's outcome; a Firestore scan and
      // a notification fan-out behind it would otherwise be added to the load
      // time of a screen that is already slow enough to carry a stopwatch.
      // The applier never throws, so nothing escapes this call.
      unawaited(_scheduledAccessApplier.applyDue());

      totalStopwatch.stop();
      return result;
    } catch (e, stackTrace) {
      totalStopwatch.stop();
      return Left(FeatureFailure(e.toString()));
    }
  }

  Future<Map<String, NewEmployeeModelHistory>> _getEmployees() async {
    final stopwatch = Stopwatch()..start();

    try {
      // Was `Get.isRegistered<...>` — the locator now stays behind the
      // AppControllers seam (GetX standing rule).
      if (!AppControllers.isEmployeeRegistered) {
        return {};
      }

      MainCoreEmployeeController controller = AppControllers.employee;
      List<EmployeeEntityPro>? employeesList = controller.allEmployeesEntities;

      if (employeesList == null || employeesList.isEmpty) {
        stopwatch.stop();
        return {};
      }

      Map<String, NewEmployeeModelHistory> users = {};
      int validCount = 0;
      int invalidCount = 0;
      int fetchErrorCount = 0;

      final parallelStopwatch = Stopwatch()..start();

      List<Future<void>> fetchFutures = [];

      for (int i = 0; i < employeesList.length; i++) {
        EmployeeEntityPro entity = employeesList[i];

        if (entity.id == null || entity.id!.isEmpty || entity.email == null || entity.email!.isEmpty) {
          invalidCount++;
          continue;
        }

        fetchFutures.add(
            remoteDataSource.getEmployeeModel(entity.id!).then((result) {
              if (result.isRight()) {
                Map<String, dynamic>? data = result.getOrElse(() => null);
                if (data != null) {
                  NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(data);
                  if (employee.email.isNotEmpty) {
                    String latestEmail = employee.email.last;
                    users[latestEmail] = employee;
                    validCount++;
                  } else {
                    invalidCount++;
                  }
                } else {
                  fetchErrorCount++;
                }
              } else {
                fetchErrorCount++;
              }
            }).catchError((e) {
              fetchErrorCount++;
            })
        );
      }

      await Future.wait(fetchFutures);

      parallelStopwatch.stop();
      stopwatch.stop();

      return users;
    } catch (e, stackTrace) {
      stopwatch.stop();
      return {};
    }
  }

  // REMOVED 9/10/2026: `checkModuleUserLimitsSimple` — only the unused debug
  // dialog in user_management_home_methods1.dart called it, and it carried the
  // same three bugs as the old `getModuleUserCount` (camelCase role fields,
  // `Users_Access`, errors read as "OK"). See the USER LIMITS section.

  Future<Either<Failure, dynamic>> _getUsersPermissions(
      Map<String, NewEmployeeModelHistory> users) async {
    final stopwatch = Stopwatch()..start();

    if (users.isEmpty) {
      return Right(<UserPermissionEntity>[]);
    }

    try {
      List<UserPermissionEntity> userPermissions = [];
      int skippedNoData = 0;
      int skippedRemoved = 0;
      int successCount = 0;
      int errorCount = 0;

      final parallelStopwatch = Stopwatch()..start();

      List<String> userEmails = users.keys.toList();
      List<Future<void>> accessFutures = [];

      for (String userEmail in userEmails) {
        NewEmployeeModelHistory userValue = users[userEmail]!;
        String? employeeId = userValue.id;

        if (employeeId == null || employeeId.isEmpty) {
          errorCount++;
          continue;
        }

        if (userValue.role.isNotEmpty) {
          String currentRole = userValue.role.last;
          if (currentRole == Constants.removedEmployeePermission) {
            skippedRemoved++;
            continue;
          }
        }

        accessFutures.add(
            remoteDataSource.getUserAccessModels(id: employeeId).then((result) {
              if (result.isLeft()) {
                errorCount++;
                return;
              }

              Map<String, dynamic>? data = result.getOrElse(() => null);
              if (data == null) {
                skippedNoData++;
                return;
              }

              try {
                UserPermissionHistoryModel userAccessModel =
                UserPermissionHistoryModel.fromMap(data);

                UserPermissionEntity permission = _getUserPermissions(
                  users: users,
                  userData: userValue,
                  userAccessModel: userAccessModel,
                );

                successCount++;
                userPermissions.add(permission);
              } catch (e) {
                errorCount++;
              }
            }).catchError((e) {
              errorCount++;
            })
        );
      }

      await Future.wait(accessFutures);

      parallelStopwatch.stop();
      stopwatch.stop();

      return Right(userPermissions);
    } catch (e, stackTrace) {
      stopwatch.stop();
      return Left(FeatureFailure(e.toString()));
    }
  }

  UserPermissionEntity _getUserPermissions({
    required Map<String, NewEmployeeModelHistory> users,
    required NewEmployeeModelHistory userData,
    required UserPermissionHistoryModel userAccessModel,
  }) {
    try {
      NewEmployeeModelHistory? grantor = users[userAccessModel.currentEditBy];

      String employeeEmail = userData.email.isNotEmpty ? userData.email.last : '';
      String gender = userData.gender.isNotEmpty ? userData.gender.last : '';
      String departmentId = userData.departmentId.isNotEmpty ? userData.departmentId.last : '';

      return UserPermissionEntity(
        employeeEmail: employeeEmail,
        employeeId: userData.id!,
        gender: userData.gender.isNotEmpty ? userData.gender.last : null,
        departmentId: userData.departmentId.isNotEmpty ? userData.departmentId.last : null,
        arabicJobTitle: userData.titleInArabic.isNotEmpty ? userData.titleInArabic.last : null,
        englishJobTitle: userData.title.isNotEmpty ? userData.title.last : null,
        imagePath: ImageSelector.getUserImage(
          imagePath: null,
          gender: userData.gender.isNotEmpty ? userData.gender.last : null,
        ),
        englishName: _getEnglishName(userData),
        arabicName: _getArabicName(userData),
        accessName: userAccessModel.currentRole,
        grantorEnglishName: grantor != null ? _getEnglishName(grantor) : 'Unknown',
        grantorArabicName: grantor != null ? _getArabicName(grantor) : 'غير معروف',
        startDate: userAccessModel.currentFromDate,
        accessStatus: getUserAccessStatus(userAccessModel, userData.deactivationDate),
        endDate: userAccessModel.currentToDate,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  String _getEnglishName(NewEmployeeModelHistory employee) {
    String firstName = employee.firstName.isNotEmpty ? employee.firstName.last : '';
    String lastName = employee.lastName.isNotEmpty ? employee.lastName.last : '';
    return '$firstName $lastName'.trim();
  }

  String _getArabicName(NewEmployeeModelHistory employee) {
    String firstName = employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : '';
    String lastName = employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : '';
    return '$firstName $lastName'.trim();
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> _deleteEmployeePermission(
      String employeeId, String currentUserEmail) async {
    try {
      final dynamic fetchResult =
      await remoteDataSource.getUserAccessModels(id: employeeId);

      Either<Failure, dynamic> result;
      if (fetchResult is Either<Failure, dynamic>) {
        result = fetchResult;
      } else {
        result = Right<Failure, dynamic>(fetchResult);
      }

      if (result.isLeft()) return result;

      Map<String, dynamic>? data = result.getOrElse(() => null);
      if (data == null) {
        return Right(true);
      }

      UserPermissionHistoryModel userPermissionModel =
      UserPermissionHistoryModel.fromMap(data);

      UserPermissionHistoryModel updatedModel = userPermissionModel.copyWith(
        role: Constants.removedEmployeePermission,
        editBy: currentUserEmail,
      );

      remoteDataSource.updateRoleWithinTransaction(
          id: employeeId, data: updatedModel.toMap());
      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> _updateEmployeeRoles(
      String employeeId, String accessName) async {
    try {
      final dynamic fetchResult =
      await remoteDataSource.getEmployeeModel(employeeId);

      Either<Failure, dynamic> result;
      if (fetchResult is Either<Failure, dynamic>) {
        result = fetchResult;
      } else {
        result = Right<Failure, dynamic>(fetchResult);
      }

      if (result.isLeft()) return result;

      Map<String, dynamic>? data = result.getOrElse(() => null);
      if (data == null) {
        return Left(FeatureFailure("Employee not found"));
      }

      NewEmployeeModelHistory employeeModel =
      NewEmployeeModelHistory.fromMap(data);

      NewEmployeeModelHistory updatedModel =
      employeeModel.copyWithUpdateSynchronized(
        role: accessName,
      );

      remoteDataSource.updateEmployeeModel(
          id: employeeId, data: updatedModel.toMap());

      return Right(true);
    } catch (e) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ✅ FIXED: explicit return types to avoid Right<dynamic,bool> cast errors
  Future<Either<Failure, dynamic>> deleteEmployeePermission({
    required String employeeId,
    required String currentUserEmail,
  }) async {
    try {
      remoteDataSource.startTransaction();

      Either<Failure, dynamic> result =
      await _deleteEmployeePermission(employeeId, currentUserEmail);
      if (result.isLeft()) return result;

      Either<Failure, dynamic> result2 = await _updateEmployeeRoles(
          employeeId, Constants.removedEmployeePermission);
      if (result2.isLeft()) return result2;

      final dynamic commitResult = await remoteDataSource.commitTransaction();

      // ADDED 25/8/2026 — spec §1.5 "Access Revoked": the affected user, then
      // every Master Admin. Only once the revocation is actually persisted.
      final bool committed = commitResult is Either<Failure, dynamic>
          ? commitResult.isRight()
          : true;
      if (committed) {
        final EmployeeEntityPro? employee = _employeeById(employeeId);
        final String? email = employee?.email;
        if (email != null && email.isNotEmpty) {
          await UserManagementNotificationService.sendAccessRevokedNotification(
            userEmail: email,
            userName: _displayName(employee, email),
            senderEmail: currentUserEmail,
          );
        }
      }

      if (commitResult is Either<Failure, dynamic>) {
        return commitResult;
      }
      return Right<Failure, dynamic>(true);
    } catch (e, stackTrace) {
      return Left(FeatureFailure(e.toString()));
    }
  }

  // ══════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS — spec §1.5 "User Management & Permissions"
  //
  //  ADDED 25/8/2026. `user_management_events.dart` has carried all eight
  //  of these events since the catalog was written and
  //  `UserManagementNotificationService` has been able to send them since
  //  18/8/2026 — but nothing in this module ever called it, so every one of
  //  the eight admin-editable templates was dead weight. Its own header
  //  said as much: "It does NOT wire itself into r2_user_management."
  //  This section is that wiring.
  //
  //  Six of the eight fire from this file. Note SIX, not seven: the note that
  //  stood here said "seven of the eight now fire", which double-counted —
  //  `sendScheduledAccessAppliedNotification` sends BOTH the user and the
  //  admin row of that pair, so one uncalled method left two spec rows unsent.
  //
  //  UPDATE 26/8/2026 — the remaining pair now fires too, from
  //  `ScheduledAccessApplier`, called at the top of
  //  `getUsersPermissionsData()`. The note this replaces was right that no job
  //  existed and wrong about what the job had to be: `From_Date` is not a
  //  deferred write waiting to be flushed — `updateUserPermission` puts the
  //  role on the account in the same transaction that stores the date — so
  //  there was never anything to "execute". What was missing was something to
  //  NOTICE the date arriving. That is what the applier does, and its header
  //  carries the reasoning.
  //
  //  All eight §1.5 rows are therefore live.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [_employeeById]
  ///
  /// Purpose: The directory record for [employeeId].
  ///
  /// The permission collection is keyed by employee id but every
  /// notification is addressed by email, so one of the two has to be
  /// resolved against the other. `MainCoreEmployeeController` only indexes
  /// by email, hence the scan — the map is the already-loaded directory, so
  /// this costs no I/O.
  ///
  /// Parameters:
  /// - [employeeId]: the `Employee_Id` the permission document is keyed by.
  ///
  /// Returns: [EmployeeEntityPro?] — `null` when the directory has no such id.
  EmployeeEntityPro? _employeeById(String employeeId) {
    if (employeeId.trim().isEmpty) return null;
    for (final EmployeeEntityPro employee
        in AppControllers.employee.mapOfEmployeesWithEmailKey.values) {
      if (employee.id == employeeId) return employee;
    }
    return null;
  }

  /// The name to print inside an admin-facing notification. Falls back to the
  /// address rather than to the controller's "no name" sentinel.
  String _displayName(EmployeeEntityPro? employee, String email) {
    final String first = employee?.firstName?.trim() ?? '';
    final String last = employee?.lastName?.trim() ?? '';
    final String full = '$first $last'.trim();
    return full.isEmpty ? email : full;
  }

  /// Function Name: [_notifyAccessChanged]
  ///
  /// Purpose: Send the notification a saved permission change earns, once the
  /// write has committed.
  ///
  /// Which of the four it is:
  /// - a role assigned where the user had none, or a different one →
  ///   **Access Granted** (§1.5.1)
  /// - the same role re-saved with different dates or permissions →
  ///   **Access Updated** (§1.5.2)
  /// - the new start date is in the future → **Access Change Scheduled**
  ///   (§1.5.4), carrying that date
  /// - the start date WAS in the future and no longer is → **Scheduled Access
  ///   Change Cancelled** (§1.5.6)
  ///
  /// The scheduled pair is additive: a change that both takes effect now and
  /// withdraws a pending one legitimately sends two notices, because two
  /// distinct things happened to the user's access.
  ///
  /// Parameters:
  /// - [employeeId]: whose access changed.
  /// - [actorEmail]: the administrator who saved it; becomes the sender.
  /// - [isNewAssignment]: granted vs updated, as computed by the caller.
  /// - [accessBegin] / [previousAccessBegin]: the new and prior start dates.
  ///
  /// Returns: [Future<void>] — never throws. A notification that cannot be
  /// sent must not fail the permission change that has already been written.
  Future<void> _notifyAccessChanged({
    required String employeeId,
    required String actorEmail,
    required bool isNewAssignment,
    String? accessBegin,
    String? previousAccessBegin,
  }) async {
    try {
      final EmployeeEntityPro? employee = _employeeById(employeeId);
      final String? email = employee?.email;
      if (email == null || email.isEmpty) return;

      if (isNewAssignment) {
        await UserManagementNotificationService.sendAccessGrantedNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      } else {
        await UserManagementNotificationService.sendAccessUpdatedNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      }

      final DateTime now = DateTime.now();
      final DateTime? newStart = parseAccessDate(accessBegin, label: 'from');
      final DateTime? oldStart =
          parseAccessDate(previousAccessBegin, label: 'previous from');

      final bool startsInFuture = newStart != null && newStart.isAfter(now);
      final bool startedInFuture = oldStart != null && oldStart.isAfter(now);

      if (startsInFuture) {
        await UserManagementNotificationService
            .sendAccessChangeScheduledNotification(
          userEmail: email,
          scheduledDate: accessBegin ?? '',
          senderEmail: actorEmail,
        );
      }

      // A pending start date that is no longer pending — cleared, or moved to
      // a date that has already passed — is a withdrawn schedule.
      if (startedInFuture && !startsInFuture) {
        await UserManagementNotificationService
            .sendScheduledAccessCancelledNotification(
          userEmail: email,
          senderEmail: actorEmail,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('access-change notification failed: $e\n$stackTrace');
    }
  }

  // REMOVED 9/10/2026: `checkModuleUserLimitsBeforeAssignment` — 0 call
  // sites, and its catch returned `Right(null)`: any read error meant "OK".

  updateUserPermission({
    required String employeeId,
    required String currentUserEmail,
    String? accessName,
    String? accessBegin,
    String? accessEnd,
    bool isCommit = true,
  }) async {

    String? currentExistingRole;
    bool isActuallyNewAssignment = true;

    // The access start date as it stood BEFORE this save. Needed to tell a
    // newly scheduled change from one that was just withdrawn — see
    // `_notifyAccessChanged`.
    String? previousAccessBegin;

    Either<Failure, dynamic> currentCheck =
    await remoteDataSource.getUserAccessModels(id: employeeId);

    if (currentCheck.isRight()) {
      Map<String, dynamic>? currentData = currentCheck.getOrElse(() => null);
      if (currentData != null) {
        try {
          UserPermissionHistoryModel currentModel =
          UserPermissionHistoryModel.fromMap(currentData);
          currentExistingRole = currentModel.currentRole;
          previousAccessBegin = currentModel.currentFromDate;

          if (currentExistingRole != null &&
              currentExistingRole.isNotEmpty &&
              accessName != null &&
              currentExistingRole.toLowerCase() == accessName.toLowerCase()) {
            isActuallyNewAssignment = false;
          }
        } catch (e, stackTrace) {
          // Was an empty `catch {}`: a failure here silently left
          // `isActuallyNewAssignment` at its default, which decides whether a
          // notification fires (§11.5).
          debugPrint('assignment-kind check failed: $e\n$stackTrace');
        }
      }
    }

    // REPLACED 9/10/2026 — the old pre-check here only looked at `services`,
    // only on a role CHANGE, counted through `getModuleUserCount` (which found
    // ~0 holders: wrong role field names, wrong collection) and let any error
    // through. The limit is now checked for EVERY module of the role plus the
    // company total, inside the transaction that commits this write — see
    // [_commitWithSeatCheck]. A date-only save is checked too: extending an
    // expired user's end date gives them their seat back.
    final String effectiveRole = (accessName != null && accessName.isNotEmpty)
        ? accessName
        : (currentExistingRole ?? '');
    final List<ProposedAssignment> seatChange = _seatChangeFor(
        <String>[employeeId], effectiveRole);

    if (!isCommit && seatChange.isNotEmpty) {
      // The caller owns the batch, so the check cannot ride in a transaction
      // here; check now and refuse before anything is queued.
      final Either<Failure, void> pre = await precheckAssignments(seatChange);
      if (pre.isLeft()) {
        return Left<Failure, dynamic>(
            pre.fold((Failure f) => f, (_) => FeatureFailure('')));
      }
    }

    if (isCommit) {
      remoteDataSource.startTransaction();
    }

    Either<Failure, dynamic> result =
    await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) {
      return result;
    }

    Map<String, dynamic>? data = result.getOrElse(() => null);

    if (data == null) {
      await _createNewUserPermission(
        employeeId: employeeId,
        role: accessName!,
        fromDate: accessBegin!,
        toDate: accessEnd!,
        editBy: currentUserEmail,
      );

      await _updateEmployeeRoles(employeeId, accessName);
    } else {
      UserPermissionHistoryModel existingModel =
      UserPermissionHistoryModel.fromMap(data);

      String? effectiveRole = accessName?.isNotEmpty == true
          ? accessName
          : existingModel.currentRole;

      await _updateEmployeePermission(
        existingModel: existingModel,
        employeeId: employeeId,
        role: effectiveRole,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );

      if (accessName != null &&
          accessName.isNotEmpty &&
          accessName != existingModel.currentRole) {
        await _updateEmployeeRoles(employeeId, accessName);
      }
    }

    if (isCommit) {
      // 9/10/2026 — a grant commits in a transaction that re-checks the user
      // limits first; a revocation (no seat change) keeps the plain batch.
      final dynamic commitResult = seatChange.isNotEmpty
          ? await _commitWithSeatCheck(
              proposed: seatChange, actorEmail: currentUserEmail)
          : await remoteDataSource.commitTransaction();

      // ADDED 25/8/2026 — spec §1.5. Only after the write actually lands: a
      // failed commit must not tell the user their access changed.
      final bool committed = commitResult is Either<Failure, dynamic>
          ? commitResult.isRight()
          : true;
      if (committed) {
        await _notifyAccessChanged(
          employeeId: employeeId,
          actorEmail: currentUserEmail,
          isNewAssignment: isActuallyNewAssignment,
          accessBegin: accessBegin,
          previousAccessBegin: previousAccessBegin,
        );
      }

      if (commitResult is Either<Failure, dynamic>) {
        return commitResult;
      }
      return Right<Failure, dynamic>(true);
    }

    // `isCommit: false` means the caller owns the transaction — and therefore
    // owns the notification too, once it knows the commit succeeded.
    return Right(true);
  }

  _updateEmployeePermission({
    required UserPermissionHistoryModel existingModel,
    required String employeeId,
    String? role,
    String? fromDate,
    String? toDate,
    required String editBy,
  }) async {
    if (role != null && role != existingModel.currentRole) {
      await _updateEmployeeRoles(employeeId, role);
    }

    UserPermissionHistoryModel updatedModel = existingModel.copyWith(
      role: role,
      fromDate: fromDate,
      toDate: toDate,
      editBy: editBy,
    );

    remoteDataSource.updateRoleWithinTransaction(
        id: employeeId, data: updatedModel.toMap());
  }

  _createNewUserPermission({
    required String employeeId,
    required String role,
    required String fromDate,
    required String toDate,
    required String editBy,
  }) {
    UserPermissionHistoryModel userPermissionModel =
    UserPermissionHistoryModel.createNew(
      employeeId: employeeId,
      role: role,
      fromDate: fromDate,
      toDate: toDate,
      editBy: editBy,
    );

    remoteDataSource.updateRoleWithinTransaction(
        id: employeeId, data: userPermissionModel.toMap());
  }

  updateSelectedMembersPermission({
    required String currentUserEmail,
    required String accessName,
    required String startDate,
    required String endDate,
    required List<EmployeeEntityPro> selectedMembers,
  }) async {

    // REPLACED 9/10/2026 — the old pre-check here only looked at `services`,
    // added the whole selection to a count that found ~0 holders, and was
    // skipped entirely when the company id or the limit could not be read. The
    // selection is now checked against EVERY module of the role and the
    // company total inside the commit's transaction ([_commitWithSeatCheck]).

    remoteDataSource.startTransaction();

    int successCount = 0;
    int errorCount = 0;

    // Only the members whose write went through earn a notification, so the
    // ones that threw above are not told their access changed.
    final List<EmployeeEntityPro> written = <EmployeeEntityPro>[];

    for (EmployeeEntityPro selectedMember in selectedMembers) {
      try {
        final dynamic queued = await _updateUserPermissionWithoutLimitCheck(
          employeeId: selectedMember.id!,
          currentUserEmail: currentUserEmail,
          accessName: accessName,
          accessBegin: startDate,
          accessEnd: endDate,
        );
        // 9/10/2026 — a member whose permission read failed had nothing
        // queued; it was still counted as written (and notified).
        if (queued is Either && queued.isLeft()) {
          errorCount++;
          continue;
        }
        written.add(selectedMember);
        successCount++;
      } catch (e) {
        errorCount++;
      }
    }

    // 9/10/2026 — the whole selection is one seat change, checked and
    // committed in one transaction: all of it lands or none of it does.
    final List<ProposedAssignment> seatChange = _seatChangeFor(
        <String>[for (final EmployeeEntityPro m in written) m.id!], accessName);
    final dynamic commitResult = seatChange.isNotEmpty
        ? await _commitWithSeatCheck(
            proposed: seatChange, actorEmail: currentUserEmail)
        : await remoteDataSource.commitTransaction();

    // ADDED 25/8/2026 — spec §1.5, the bulk path. One notification per member,
    // after the single shared commit: the loop above only queues writes into
    // the transaction, so nothing is persisted until this returns.
    final bool committed = commitResult is Either<Failure, dynamic>
        ? commitResult.isRight()
        : true;
    if (committed) {
      for (final EmployeeEntityPro member in written) {
        await _notifyAccessChanged(
          employeeId: member.id!,
          actorEmail: currentUserEmail,
          // This screen assigns one role to a batch of people, so from each
          // recipient's side it is a grant. Distinguishing per member would
          // need the prior role of each, which this path never reads.
          isNewAssignment: true,
          accessBegin: startDate,
        );
      }
    }

    if (commitResult is Either<Failure, dynamic>) {
      return commitResult;
    }
    return Right<Failure, dynamic>(true);
  }

  // REMOVED 12/8/2026: `_getRoleModules` — dead code, 0 call sites.

  // NOTE 9/10/2026: "WithoutLimitCheck" means only that this QUEUES writes
  // without checking; its one caller, `updateSelectedMembersPermission`,
  // checks the whole selection when it commits (`_commitWithSeatCheck`).
  _updateUserPermissionWithoutLimitCheck({
    required String employeeId,
    required String currentUserEmail,
    required String accessName,
    required String accessBegin,
    required String accessEnd,
  }) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) return result;

    Map<String, dynamic>? data = result.getOrElse(() => null);

    if (data == null) {
      await _createNewUserPermission(
        employeeId: employeeId,
        role: accessName,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );
      await _updateEmployeeRoles(employeeId, accessName);
    } else {
      UserPermissionHistoryModel existingModel =
      UserPermissionHistoryModel.fromMap(data);
      await _updateEmployeePermission(
        existingModel: existingModel,
        employeeId: employeeId,
        role: accessName,
        fromDate: accessBegin,
        toDate: accessEnd,
        editBy: currentUserEmail,
      );
    }
  }

  /// Arabic (transliterated Gregorian) month name → month number.
  static const Map<String, int> _arabicMonths = {
    'يناير': 1,
    'فبراير': 2,
    'مارس': 3,
    'أبريل': 4, 'ابريل': 4,
    'مايو': 5,
    'يونيو': 6, 'يونيه': 6,
    'يوليو': 7, 'يوليه': 7,
    'أغسطس': 8, 'اغسطس': 8,
    'سبتمبر': 9,
    'أكتوبر': 10, 'اكتوبر': 10,
    'نوفمبر': 11,
    'ديسمبر': 12,
  };

  /// Convert Arabic-Indic (٠-٩) and Persian (۰-۹) digits to Western (0-9).
  String _normalizeDigits(String input) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    String r = input;
    for (int i = 0; i < 10; i++) {
      r = r.replaceAll(arabicIndic[i], western[i]).replaceAll(persian[i], western[i]);
    }
    return r;
  }

  /// Parse a date written in Arabic, e.g. "أكتوبر ١٩, ٢٠٢٦".
  /// Digits are already normalized before this is called.
  DateTime? _tryParseArabic(String normalized) {
    // Treat both Western and Arabic commas as separators.
    final cleaned = normalized.replaceAll(',', ' ').replaceAll('،', ' ');
    final tokens =
    cleaned.split(RegExp(r'\s+')).where((t) => t.trim().isNotEmpty).toList();
    if (tokens.length < 3) return null;

    int? month, day, year;
    for (final t in tokens) {
      if (_arabicMonths.containsKey(t)) {
        month = _arabicMonths[t];
      } else {
        final n = int.tryParse(t);
        if (n == null) continue;
        if (n > 31) {
          year = n; // 4-digit year
        } else if (day == null) {
          day = n; // first 1-2 digit number is the day
        } else {
          year ??= n;
        }
      }
    }

    if (month != null && day != null && year != null) {
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }
    return null;
  }

  /// ✅ Robust date parser — handles BOTH English and Arabic stored dates.
  /// Some records were saved in Arabic (e.g. "أكتوبر ١٩, ٢٠٢٦") because the
  /// write side formatted with the Arabic locale; this reads them all.
  /// Returns null only if NONE of the formats matched.
  /// Function Name: [parseAccessDate]
  ///
  /// Purpose: Parse a stored access date, tolerating every format this data
  /// has been written in (ISO, dd/MM/yyyy, English named-month, Arabic
  /// named-month, and `Constants.userAccessDateFormat`).
  ///
  /// Made public 12/8/2026: `UserManagementController.getExpiringPermissions`
  /// and `validatePermissionDates` were calling `DateTime.parse` on strings
  /// written as "MMM dd, yyyy". `DateTime.parse` accepts ISO-8601 only, so both
  /// threw on every row, were swallowed by their local catch, and silently
  /// returned `[]` / `false` — the "expiring soon" surfacing and the date
  /// validation had never worked. They now share this parser.
  ///
  /// Parameters:
  /// - [raw]: The stored date string.
  /// - [label]: Optional tag used in the diagnostic log.
  ///
  /// Returns: [DateTime?] `null` when no known format matches.
  DateTime? parseAccessDate(String? raw, {String label = ''}) {
    if (raw == null || raw.trim().isEmpty || raw == '-' || raw == 'null') {
      return null;
    }

    // Normalize Arabic/Persian digits up front so every branch benefits.
    final s = _normalizeDigits(raw.trim());

    // 1) ISO / yyyy-MM-dd (also yyyy-MM-ddTHH:mm:ss)
    try {
      final d = DateTime.parse(s);
      return d;
    } catch (_) {}

    // 2) dd/MM/yyyy
    if (s.contains('/')) {
      final parts = s.split('/');
      if (parts.length == 3) {
        try {
          final d = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return d;
        } catch (_) {}
      }
    }

    // 3) English named-month formats (with / without comma)
    const formats = [
      'MMM dd, yyyy',
      'dd MMM, yyyy',
      'MMMM dd, yyyy',
      'dd MMMM, yyyy',
      'dd MMM yyyy',
      'MMM dd yyyy',
      'dd MMMM yyyy',
      'MMMM dd yyyy',
    ];
    for (final f in formats) {
      try {
        final d = DateFormat(f, 'en').parse(s);
        return d;
      } catch (_) {}
    }

    // 4) Arabic month names (e.g. "أكتوبر 19, 2026" after digit normalization)
    final ar = _tryParseArabic(s);
    if (ar != null) {
      return ar;
    }

    // 5) the configured app format, last resort
    try {
      final d = DateFormat(Constants.userAccessDateFormat, 'en').parse(s);
      return d;
    } catch (_) {}

    return null;
  }

  /// ✅ Status logic:
  ///   - end unparseable                  → active (loud warning, fix data)
  ///   - now > end                        → inactive
  ///   - now < start                      → scheduled (not started yet)
  ///   - deactivated and that date passed → inactive
  ///   - <= 12 days left until end        → expiringSoon
  ///   - between start and end (>12 left) → active
  /// Heavy prints so you can see WHY a card got its status.
  UserAccessStatus getUserAccessStatus(
      UserPermissionHistoryModel userAccessModel, String? deactivationDate) {

    final now = DateTime.now();

    final DateTime? startDate =
    parseAccessDate(userAccessModel.currentFromDate, label: 'start');
    final DateTime? endDate =
    parseAccessDate(userAccessModel.currentToDate, label: 'end');

    // 🔴 If we cannot read the END date, DON'T silently mark inactive.
    if (endDate == null) {
      return UserAccessStatus.active;
    }

    // 1) Past the end date → inactive
    if (now.isAfter(endDate)) {
      return UserAccessStatus.inactive;
    }

    // 2) Hasn't started yet (now < start) → scheduled
    if (startDate != null && now.isBefore(startDate)) {
      return UserAccessStatus.scheduled;
    }

    if (startDate == null) {
    }

    // 3) Deactivated and that date has passed → inactive
    final DateTime? deact = parseAccessDate(deactivationDate, label: 'deactivation');
    if (deact != null && now.isAfter(deact)) {
      return UserAccessStatus.inactive;
    }

    // 4) 12 days or fewer left until the end date → expiring soon
    final int daysLeft = endDate.difference(now).inDays;
    if (daysLeft <= 12) {
      return UserAccessStatus.expiringSoon;
    }

    // 5) Between start and end with more than 12 days left → active
    return UserAccessStatus.active;
  }

  Future<List<Map<String, dynamic>>> getUserPermissionHistory(
      String employeeId) async {
    Either<Failure, dynamic> result =
    await remoteDataSource.getUserAccessModels(id: employeeId);

    if (result.isLeft()) return [];

    Map<String, dynamic>? data = result.getOrElse(() => null);
    if (data == null) return [];

    UserPermissionHistoryModel model = UserPermissionHistoryModel.fromMap(data);
    return model.getHistory();
  }

  // ══════════════════════════════════════════════════════════════════
  //  USER LIMITS — per-module and total, set in Knowticed Admin
  //
  //  ADDED 9/10/2026. Replaces `_getCompanyId`, `getModuleUserLimits` and
  //  `getModuleUserCount`, which only ever ran for `services` and could not
  //  block anything:
  //   1. the count matched roles on `roleName` / `selectedModules`, but roles
  //      are saved as `Name` / `Selected_Modules` (role_model.dart toMap) —
  //      only the seeded Master Admin used camelCase, so no role matched;
  //   2. it counted holders in `Users_Access`, while every grant from this
  //      screen is written to `User_Management`;
  //   3. any error (read refused, offline) returned 0 / {} — "no limit".
  //
  //  Now: the rule is `ModuleUserLimitRule` (pure Dart, unit-tested), the
  //  reads are `LicenceSeatGuard`, and every grant commits through
  //  [_commitWithSeatCheck] — a Firestore transaction that re-counts before
  //  it writes. Every failure blocks.
  // ══════════════════════════════════════════════════════════════════

  /// Function Name: [readLicenceUsage]
  ///
  /// Purpose: The limits and current usage, for the User Management screens
  /// (usage lines under the Role Type, and the pre-check of a selection).
  ///
  /// Returns: [Future<Either<Failure, LicenceUsageSnapshot>>] — `Left` with
  /// the "could not verify" message on any read failure. Callers must treat
  /// `Left` as BLOCKED, never as "no limits".
  Future<Either<Failure, LicenceUsageSnapshot>> readLicenceUsage() async {
    try {
      return Right<Failure, LicenceUsageSnapshot>(
          await _seatGuard.readSnapshot());
    } catch (e, stackTrace) {
      debugPrint('readLicenceUsage failed: $e\n$stackTrace');
      return Left<Failure, LicenceUsageSnapshot>(
          FeatureFailure(ModuleUserLimitMessages.checkFailed));
    }
  }

  /// Function Name: [precheckAssignments]
  ///
  /// Purpose: Check [proposed] against a fresh (non-transactional) read. For
  /// the paths whose writes cannot ride in the checked transaction
  /// (`updateUserPermission(isCommit: false)`, the legacy import page).
  ///
  /// Returns: [Future<Either<Failure, void>>] — `Left(ModuleUserLimitFailure)`
  /// when a limit blocks, `Left` with the "could not verify" message when the
  /// read fails, `Right` otherwise.
  Future<Either<Failure, void>> precheckAssignments(
      List<ProposedAssignment> proposed) async {
    final Either<Failure, LicenceUsageSnapshot> snapshot =
        await readLicenceUsage();
    return snapshot.fold(
      (Failure failure) => Left<Failure, void>(failure),
      (LicenceUsageSnapshot usage) {
        final LimitVerdict verdict = usage.check(proposed);
        return verdict.allowed
            ? const Right<Failure, void>(null)
            : Left<Failure, void>(ModuleUserLimitFailure(verdict));
      },
    );
  }

  /// The seat change of giving [role] to [employeeIds] — empty when [role]
  /// grants nothing (blank or revoked), i.e. there is nothing to check.
  List<ProposedAssignment> _seatChangeFor(
      List<String> employeeIds, String role) {
    if (role.trim().isEmpty || role == Constants.removedEmployeePermission) {
      return const <ProposedAssignment>[];
    }
    return <ProposedAssignment>[
      for (final String id in employeeIds)
        if (id.trim().isNotEmpty)
          ProposedAssignment(employeeId: id, role: role),
    ];
  }

  /// Function Name: [_commitWithSeatCheck]
  ///
  /// Purpose: Commit the queued permission writes inside a Firestore
  /// transaction that first re-checks the user limits for [proposed].
  ///
  /// Returns: [Future<Either<Failure, dynamic>>]
  /// - `Right(true)` once written;
  /// - `Left(ModuleUserLimitFailure)` — EN/AR message naming the module and
  ///   the limit — when a limit blocks; nothing is written;
  /// - `Left` with the "could not verify" message when the check itself could
  ///   not run (offline, read refused, malformed data); nothing is written;
  /// - `Left` with the raw error when the check passed but the write failed.
  Future<Either<Failure, dynamic>> _commitWithSeatCheck({
    required List<ProposedAssignment> proposed,
    required String actorEmail,
  }) async {
    LimitVerdict? refused;
    bool checked = false;

    final Either<Failure, dynamic> result =
        await remoteDataSource.commitTransactionChecked(
            (Transaction transaction) async {
      // Reset on every attempt: Firestore re-runs this on contention.
      refused = null;
      checked = false;
      try {
        await _seatGuard.checkInTransaction(transaction,
            proposed: proposed, actorEmail: actorEmail);
        checked = true;
      } on LicenceSeatLimitException catch (e) {
        refused = e.verdict;
        rethrow;
      }
    });

    if (result.isRight()) return result;
    final LimitVerdict? verdict = refused;
    if (verdict != null) return Left(ModuleUserLimitFailure(verdict));
    if (!checked) return Left(FeatureFailure(ModuleUserLimitMessages.checkFailed));
    return result;
  }

  /// Employee id → deactivation date, from the already-loaded directory.
  /// Unknown → the employee is counted (the strict side).
  Map<String, DateTime?> _deactivationDates() {
    if (!AppControllers.isEmployeeRegistered) return const <String, DateTime?>{};
    final List<EmployeeEntityPro> employees =
        AppControllers.employee.allEmployeesEntities ?? const <EmployeeEntityPro>[];
    return <String, DateTime?>{
      for (final EmployeeEntityPro e in employees)
        if ((e.id ?? '').isNotEmpty && (e.deactivationDate ?? '').trim().isNotEmpty)
          e.id!: parseAccessDate(e.deactivationDate, label: 'deactivation'),
    };
  }
}
