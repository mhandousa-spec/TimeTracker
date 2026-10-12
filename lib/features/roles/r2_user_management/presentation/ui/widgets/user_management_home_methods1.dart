/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_home_methods1.dart
/// Purpose: Declares `UserManagementHomeMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/user_management_home.dart';

extension UserManagementHomeMethods1 on _UserManagementHomeState {
  /// ✅ A role chip is visible ONLY if its key resolves to a role that still
  /// exists in RoleCubit.roles.
  ///
  /// KEY INSIGHT (confirmed via logs): RoleCubit.roles already EXCLUDES
  /// deleted/inactive roles. So a key from `roleFilteredUsersPermissions` that
  /// does NOT resolve means the role was deleted/inactive → hide it (and drop
  /// its users from the count/grid).
  bool _isRoleVisible(String roleKey) {
    try {
      final RoleCubit roleCubit = context.read<RoleCubit>();

      // Roles not loaded yet → don't hide anything (avoids an empty bar flicker
      // on first frame before RoleCubit populates).
      if (roleCubit.roles.isEmpty) return true;

      final RoleHistoryModel? role = _resolveRole(roleKey);

      // Not in the active roles list → deleted / inactive / removed → hide.
      if (role == null) return false;

      // Present, but double-check its current status as a safety net.
      final String statusName = role.currentStatus.name.trim().toLowerCase();
      return !_UserManagementHomeState._hiddenRoleStatuses.contains(statusName);
    } catch (e) {
      return true; // fail open on unexpected errors
    }
  }
  List<MapEntry<String, int>> _getSortedRolesWithAll() {
    // ✅ Only roles that still exist (non-deleted/non-inactive) in RoleCubit.
    final visibleEntries = controller.roleFilteredUsersPermissions.entries
        .where((e) => _isRoleVisible(e.key))
        .toList();

    // ✅ "all" count reflects ONLY the visible roles, so the badge matches the
    // grid below.
    int totalCount = 0;
    for (final entry in visibleEntries) {
      totalCount += entry.value.length;
    }

    List<MapEntry<String, int>> sortedRoles = [
      MapEntry('all', totalCount),
    ];

    var otherRoles = visibleEntries
        .map((e) => MapEntry(e.key, e.value.length))
        .toList();

    otherRoles.sort((a, b) => b.value.compareTo(a.value));
    sortedRoles.addAll(otherRoles);

    return sortedRoles;
  }
  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }
  // REMOVED 12/8/2026: `_buildDebugPanel()` — a debug panel shipped in the
  // production UI with no call sites.
  // REMOVED 9/10/2026: `_getDebugData`, `_testLimitCheck`, `_runLimitTest`
  // and `_getCompanyId` — an unused debug dialog (0 call sites) built on the
  // old limit helpers, which could never block (wrong role fields, wrong
  // collection, errors read as "OK"). The limits now show on the Add Access
  // page (`UserLimitUsagePanel`) and are enforced in the repository.
}
