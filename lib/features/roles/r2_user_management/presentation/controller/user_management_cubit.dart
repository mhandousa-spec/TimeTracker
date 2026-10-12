/// Module: roles / r2_user_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_cubit.dart
/// Purpose: Declares `UserManagementAccessCubit`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/usecases/delete_user_permission_use_case.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/usecases/update_selected_members_use_case.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/enums/user_access_status.dart';
// ADDED 9/10/2026 — per-module user limits on the Add Access / Edit flows.
import 'dart:async';
import 'package:knowticed_plus/features/roles/r2_user_management/data/services/module_user_limit_messages.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/services/module_user_limit_rule.dart';

part './user_management_state.dart';

/// App-wide shared UserManagementAccessCubit instance.
///
/// Moved here from role_responsive_page.dart when that wrapper page was
/// removed. Top-level variables are lazily initialised in Dart, so this is
/// only constructed on first use.
UserManagementAccessCubit userManagementCubit = UserManagementAccessCubit();

class UserManagementAccessCubit extends Cubit<UserManagementAccessState> {
  UserManagementAccessCubit() : super(UserManagementInitial());

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// This cubit is a long-lived top-level singleton driving `async` Firestore
  /// reads; guarding the emit keeps a completion that lands after a close from
  /// throwing.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(UserManagementAccessState state) {
    if (isClosed) return;
    emit(state);
  }

  TextEditingController homePageSearchController = TextEditingController();
  UserManagementAccessRepository repository = UserManagementAccessRepository();
  Map<String, List<UserPermissionEntity>> roleFilteredUsersPermissions = {};
  Map<UserAccessStatus, List<UserPermissionEntity>>
  accessStatusFilteredUsersPermissions = {};
  String selectedRole = 'all';
  UserAccessStatus selectedUserAccessStatus = UserAccessStatus.all;
  List<UserPermissionEntity> filteredUsersPermissions = [];
  DateTime accessGranted = DateTime.now();
  DateTime accessRevoked = DateTime.now().add(Duration(days: 30 * 6));
  String? newAccessSelectedRole = 'super admin';
  List<String> rolesName = [];
  List<String> rolesNameAr = [];
  List<UserPermissionEntity> employeeToGiveAccess = [];
  List<UserPermissionEntity> filteredEmployeeToGiveAccess = [];
  String? addNewAccessDepartmentId;
  TextEditingController addNewSearchController = TextEditingController();
  Set<String> selectedUsersIdToChangeAccess = {};
  DateTime? creationDate;

  /// Function Name: [getUserAccess]
  ///
  /// Purpose: Load the user-permission roster and rebuild the home-page filters.
  ///
  /// SECURITY/UX (silent failure): both failure paths used to end in a
  /// commented-out `emit(UserPermissionsDataError(...))`, so a failed load
  /// changed no state at all. `user_management_home.dart` has a proper
  /// error branch keyed on `UserPermissionsDataError`, but that state could
  /// never arrive — the page just kept rendering the previous (usually empty)
  /// roster with no error and no retry. Both paths now emit again.
  ///
  /// Returns: [Future<void>]
  Future<void> getUserAccess() async {
    try {
      emitSafely(UserPermissionsDataLoading());

      Either<Failure, dynamic> result = await repository.getUsersPermissionsData();

      if (result.isLeft()) {
        Failure failure = result.fold((l) => l, (r) => null)!;
        emitSafely(UserPermissionsDataError(failure.errMessage));
        return;
      }

      List<UserPermissionEntity> userPermissions = result.getOrElse(() => []);

      getUsersPermissionFilteredMaps(userPermissions);

      filterHomePageUser(homePageSearchController.text);
    } catch (e, stackTrace) {
      debugPrint('getUserAccess failed: $e\n$stackTrace');
      emitSafely(UserPermissionsDataError(e.toString()));
    }
  }

  void getUsersPermissionFilteredMaps(List<UserPermissionEntity> userPermissions) {

    try {
      roleFilteredUsersPermissions = {};
      accessStatusFilteredUsersPermissions = {};

      for (UserAccessStatus status in UserAccessStatus.values) {
        accessStatusFilteredUsersPermissions.putIfAbsent(status, () => []);
      }

      for (int i = 0; i < userPermissions.length; i++) {
        UserPermissionEntity userPermission = userPermissions[i];

        // ✅ Use role ID (accessName) as key - not localized name
        String roleKey = userPermission.accessName ?? 'unknown';
        roleFilteredUsersPermissions.putIfAbsent(roleKey, () => []);
        roleFilteredUsersPermissions[roleKey]!.add(userPermission);

        // Add to status filters
        accessStatusFilteredUsersPermissions[userPermission.accessStatus]!.add(userPermission);
        accessStatusFilteredUsersPermissions[UserAccessStatus.all]!.add(userPermission);

        // GROUPING chips (29/8/2026): "Access Granted" collects everyone who
        // currently holds access (active / scheduled / expiring soon), and
        // "Access Revoked" everyone whose access has ended (inactive). They are
        // views over the derived per-user status, not a new status a user is
        // ever assigned — so the chips are never empty for want of a mapping.
        final UserAccessStatus s = userPermission.accessStatus;
        if (s == UserAccessStatus.active ||
            s == UserAccessStatus.scheduled ||
            s == UserAccessStatus.expiringSoon) {
          accessStatusFilteredUsersPermissions[UserAccessStatus.accessGranted]!
              .add(userPermission);
        } else if (s == UserAccessStatus.inactive) {
          accessStatusFilteredUsersPermissions[UserAccessStatus.accessRevoked]!
              .add(userPermission);
        }
      }

    } catch (e, stackTrace) {
      // Was an empty `catch {}` — a failure here left the filter maps
      // half-built and the UI silently showed a truncated roster (§11.5).
      debugPrint('getUsersPermissionFilteredMaps failed: $e\n$stackTrace');
      emitSafely(UserPermissionsDataError(e.toString()));
    }
  }
  void selectNewRole(String role) {
    selectedRole = role;
    filterHomePageUser(homePageSearchController.text);
  }

  void selectNewAccessStatus(UserAccessStatus status) {
    selectedUserAccessStatus = status;
    filterHomePageUser(homePageSearchController.text);
  }

  void filterHomePageUser(String searchText) {

    try {
      filteredUsersPermissions = [];
      Map<UserPermissionEntity, int> userPermissionCount = {};

      // Get users based on selected role
      List<UserPermissionEntity> roleUsers = [];
      if (selectedRole == 'all') {
        int totalFromRoles = 0;
        roleFilteredUsersPermissions.forEach((key, value) {
          roleUsers.addAll(value);
          totalFromRoles += value.length;
        });
      } else {
        roleUsers = roleFilteredUsersPermissions[selectedRole] ?? [];
      }

      // Filter by role and search text
      int roleMatchCount = 0;
      for (UserPermissionEntity permission in roleUsers) {
        if (permission.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            permission.englishName.toLowerCase().contains(searchText.toLowerCase())) {
          userPermissionCount.putIfAbsent(permission, () => 0);
          userPermissionCount[permission] = userPermissionCount[permission]! + 1;
          roleMatchCount++;
        }
      }

      // Filter by access status and search text
      int statusMatchCount = 0;
      List<UserPermissionEntity> statusUsers =
          accessStatusFilteredUsersPermissions[selectedUserAccessStatus] ?? [];

      for (UserPermissionEntity permission in statusUsers) {
        if (permission.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            permission.englishName.toLowerCase().contains(searchText.toLowerCase())) {
          userPermissionCount.putIfAbsent(permission, () => 0);
          userPermissionCount[permission] = userPermissionCount[permission]! + 1;
          statusMatchCount++;
        }
      }

      // Add users that match both role and status filters (count == 2)
      int finalCount = 0;
      userPermissionCount.forEach((key, value) {
        if (value == 2) {
          filteredUsersPermissions.add(key);
          finalCount++;
        }
      });

      emitSafely(UserPermissionsDataLoaded());
    } catch (e, stackTrace) {
      // Was an empty `catch {}`: the filter blew up, no state was emitted and
      // the list stayed frozen on its previous contents (§11.5).
      debugPrint('filterHomePageUser failed: $e\n$stackTrace');
      emitSafely(UserPermissionsDataError(e.toString()));
    }
  }

  void initializeWithAllFilter() {
    selectedRole = 'all';
    selectedUserAccessStatus = UserAccessStatus.all;
  }

  initNewAccessController(List<String> roles, List<String> rolesAr, // ✅ Add rolesAr
          {String? selectedRole, DateTime? creationDate}) {
    accessGranted = DateTime.now();
    accessRevoked = DateTime.now().add(Duration(days: 30 * 6));
    newAccessSelectedRole = null;
    rolesName = roles;
    rolesNameAr = rolesAr; // ✅ Add this
    selectedUsersIdToChangeAccess = {};
    addNewAccessDepartmentId = null;
    addNewSearchController.clear();
    this.creationDate = creationDate;
    if (selectedRole == null) {
      getUsersToGiveAccess();
    } else {
      getSelectedRoleUsers(selectedRole);
    }
    // 9/10/2026 — fresh limits + usage every time the page opens.
    unawaited(loadLicenceUsage());
  }

  // ══════════════════════════════════════════════════════════════════
  //  USER LIMITS — ADDED 9/10/2026
  //
  //  The limits Knowticed Admin sets (per module + company total), shown
  //  under the Role Type once a role is picked, and checked against the
  //  employees selected so the Grant button can refuse BEFORE Save. This is
  //  a convenience read: the repository re-checks inside the transaction
  //  that writes the grant, so a seat taken meanwhile by someone else is
  //  still refused there with the same message.
  // ══════════════════════════════════════════════════════════════════

  /// The last snapshot read; null while loading or after a failed read.
  LicenceUsageSnapshot? licenceUsage;
  bool licenceUsageLoading = false;
  bool licenceUsageFailed = false;
  int _licenceUsageRequest = 0;

  /// Function Name: [loadLicenceUsage]
  ///
  /// Purpose: (Re)read the limits and current usage.
  ///
  /// Returns: [Future<void>] — never throws; a failed read leaves
  /// [licenceUsageFailed] set, which BLOCKS granting until a retry succeeds.
  Future<void> loadLicenceUsage() async {
    final int request = ++_licenceUsageRequest;
    licenceUsageLoading = true;
    licenceUsageFailed = false;
    emitSafely(UserLimitUsageUpdated());

    final Either<Failure, LicenceUsageSnapshot> result =
        await repository.readLicenceUsage();
    if (request != _licenceUsageRequest) return; // a newer read superseded it

    result.fold(
      (Failure _) {
        licenceUsage = null;
        licenceUsageFailed = true;
      },
      (LicenceUsageSnapshot snapshot) => licenceUsage = snapshot,
    );
    licenceUsageLoading = false;
    emitSafely(UserLimitUsageUpdated());
  }

  /// Usage of every limited module of the selected role ("Time Tracker: 8 of
  /// 10 users"), then the company total ("Users: 18 of 20", `module == null`)
  /// — empty until a role is picked and the snapshot has loaded.
  List<ModuleUsage> get selectedRoleUsage {
    final String? role = newAccessSelectedRole;
    final LicenceUsageSnapshot? usage = licenceUsage;
    if (role == null || role.isEmpty || usage == null) {
      return const <ModuleUsage>[];
    }
    final ModuleUsage? total = usage.totalUsage();
    return <ModuleUsage>[
      ...usage.usageForRole(role),
      if (total != null) total,
    ];
  }

  /// Function Name: [limitMessageFor]
  ///
  /// Purpose: Why giving [role] to [employeeIds] would be refused, or null
  /// when it would not.
  ///
  /// Fails closed: while the snapshot is loading, or when it could not be
  /// read, the answer is a message (so the Grant button stays disabled).
  String? limitMessageFor(Iterable<String> employeeIds, String role) {
    if (licenceUsageLoading) return ModuleUserLimitMessages.checking;
    final LicenceUsageSnapshot? usage = licenceUsage;
    if (licenceUsageFailed || usage == null) {
      return ModuleUserLimitMessages.checkFailed;
    }
    final LimitVerdict verdict = usage.check(<ProposedAssignment>[
      for (final String id in employeeIds)
        ProposedAssignment(employeeId: id, role: role),
    ]);
    return verdict.allowed ? null : ModuleUserLimitMessages.verdict(verdict);
  }

  /// [limitMessageFor] the current Add Access selection; null when there is
  /// nothing to refuse (no role or nobody selected yet, or within limits).
  String? get selectionLimitMessage {
    final String? role = newAccessSelectedRole;
    if (role == null || role.isEmpty || selectedUsersIdToChangeAccess.isEmpty) {
      return null;
    }
    return limitMessageFor(selectedUsersIdToChangeAccess, role);
  }
  void getUsersToGiveAccess() {
    employeeToGiveAccess = [];

    // ADDED 21/9/2026 — an employee who already holds a role was still offered
    // here, so "Adding New Access" could silently re-assign them (bug report
    // p.6). The roster loaded by [getUserAccess] already drops removed users,
    // so everyone in it is "under a role"; their role is changed from their
    // own card (Employee Details -> Edit), not from this page.
    final Set<String> alreadyAssignedIds = <String>{
      for (final List<UserPermissionEntity> users
          in roleFilteredUsersPermissions.values)
        for (final UserPermissionEntity user in users)
          if ((user.accessName ?? '').isNotEmpty &&
              user.accessName != Constants.removedEmployeePermission)
            user.employeeId,
    };

    AppControllers.employee
        .allEmployeesEntities!
        .forEach((element) {
      if (alreadyAssignedIds.contains(element.id)) return;
      if (element.email !=
          AppControllers.employee.employeeEntity!.email) {
        employeeToGiveAccess
            .add(UserPermissionEntity.fromEmployeeEntity(element));
      }
    });
    filterEmployeesToGiveAccess("");
  }

  void filterEmployeesToGiveAccess(String searchText) {

    filteredEmployeeToGiveAccess = [];

    // ✅ Check current employee email
    final mainCoreController = AppControllers.employee;
    final currentEmployeeEmail = mainCoreController.employeeEntity?.email;

    // ✅ Check company email step by step
    try {
      final companyEmail =
          AppControllers.company.state.company?.email?.emails?.lastOrNull;

      for (int i = 0; i < employeeToGiveAccess.length; i++) {
        var element = employeeToGiveAccess[i];

        // Search filter
        bool matchesSearch = element.arabicName.toLowerCase().contains(searchText.toLowerCase()) ||
            element.englishName.toLowerCase().contains(searchText.toLowerCase());

        // Department filter
        bool matchesDepartment = (addNewAccessDepartmentId == null) ||
            (element.departmentId == addNewAccessDepartmentId);

        if (matchesSearch && matchesDepartment) {
          // ✅ Safe comparison
          bool isCurrentEmployee = element.employeeEmail == currentEmployeeEmail;
          bool isCompanyEmail = companyEmail != null && element.employeeEmail == companyEmail;

          if (isCurrentEmployee || isCompanyEmail) {
            continue;
          }

          filteredEmployeeToGiveAccess.add(element);
        }
      }

      emitSafely(EmployeeToGiveAccessDataLoaded());

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  selectUserToChangeAccess(String employeeId) {
    if (selectedUsersIdToChangeAccess.contains(employeeId)) {
      selectedUsersIdToChangeAccess.remove(employeeId);
    } else {
      selectedUsersIdToChangeAccess.add(employeeId);
    }
    emitSafely(EmployeeToGiveAccessDataLoaded());
  }

  void getSelectedRoleUsers(String selectedRole) {
    employeeToGiveAccess = [];

    if (selectedRole == 'all') {
      roleFilteredUsersPermissions.forEach((key, value) {
        employeeToGiveAccess.addAll(value);
      });
    } else {
      for (var element in roleFilteredUsersPermissions[selectedRole] ?? []) {
        employeeToGiveAccess.add(element);
      }
    }

    filterEmployeesToGiveAccess("");
  }

  removeUserAccess(UserPermissionEntity userPermission) async {
    Either<Failure, dynamic> result =
    await DeleteUserPermissionUseCase(repository).execute(
        permission: userPermission,
        employeeEmail: userPermission.employeeEmail,
        currentUserEmail:
        AppControllers.employee.employeeEntity!.email!);
    if (result.isRight()) {
      getUserAccess();
      getSelectedRoleUsers(selectedRole);
    }
  }

  updateSelectedMembersAccess() async {

    Either<Failure, dynamic> result =
    await UpdateSelectedMembersUseCase(repository).execute(
      accessName: newAccessSelectedRole!,
      startDate:
      DateFormat(Constants.userAccessDateFormat).format(accessGranted),
      endDate: DateFormat(Constants.userAccessDateFormat).format(accessRevoked),
      selectedMembers: AppControllers.employee
          .allEmployeesEntities!
          .where(
            (element) => selectedUsersIdToChangeAccess.contains(element.id),
      )
          .toList(),
      currentUserEmail:
      AppControllers.employee.employeeEntity!.email!,
    );

    if (result.isRight()) {
      getUserAccess();
      emitSafely(EmployeeToGiveAccessDataLoaded()); // Refresh UI
    } else {
      // ✅ HANDLE ERROR - Show error message
      Failure failure = result.fold((l) => l, (r) => null)!;

      // Emit error state to show in UI
      emitSafely(UserManagementAccessError(failure.errMessage));
      // 9/10/2026 — a refusal at commit means the usage moved since the page
      // read it (someone else took the seats); show the current numbers.
      unawaited(loadLicenceUsage());
    }
  }

  Future<List<Map<String, dynamic>>> getUserAccessHistory(
      String userEmail) async {
    return [];
  }

  List<UserPermissionEntity> getUsersWithExpiringSoon({int days = 14}) {
    return filteredUsersPermissions
        .where((user) => user.accessStatus == UserAccessStatus.expiringSoon)
        .toList();
  }

  List<UserPermissionEntity> getUsersByRole(String roleName) {
    return roleFilteredUsersPermissions[roleName] ?? [];
  }

  Map<UserAccessStatus, int> getAccessSummary() {
    Map<UserAccessStatus, int> summary = {};
    for (UserAccessStatus status in UserAccessStatus.values) {
      summary[status] =
          accessStatusFilteredUsersPermissions[status]?.length ?? 0;
    }
    return summary;
  }

  List<Map<String, dynamic>> exportUserAccessData() {
    return filteredUsersPermissions
        .map((user) => {
      'employeeEmail': user.employeeEmail,
      'englishName': user.englishName,
      'arabicName': user.arabicName,
      'accessName': user.accessName,
      'accessStatus': user.accessStatus.toString(),
      'startDate': user.startDate,
      'endDate': user.endDate,
      'grantorEnglishName': user.grantorEnglishName,
      'grantorArabicName': user.grantorArabicName,
      'departmentId': user.departmentId,
      'jobTitle': user.englishJobTitle,
    })
        .toList();
  }

  Future<void> bulkUpdateAccess({
    required List<String> userIds,
    required String newRole,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    for (String userId in userIds) {
      selectedUsersIdToChangeAccess.add(userId);
    }

    newAccessSelectedRole = newRole;
    accessGranted = startDate;
    accessRevoked = endDate;

    await updateSelectedMembersAccess();
  }

  bool validateAccessDates(DateTime startDate, DateTime endDate) {
    return startDate.isBefore(endDate) && endDate.isAfter(DateTime.now());
  }

  List<UserPermissionEntity> getOverlappingAccess(String userId) {
    return [];
  }
}