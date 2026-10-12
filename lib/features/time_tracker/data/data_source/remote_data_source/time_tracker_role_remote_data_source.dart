/// Module: time_tracker / data / data_source / remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_role_remote_data_source.dart
/// Purpose: Declares `TimeTrackerRoleRemoteDataSource` (the company's roles
///          and each role's Time Tracker switches) and `TimeTrackerRoleRecord`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 4: who holds the approval switches (notifications to HR
/// approvers). Reads through the app's `RoleRepository` — the same reader
/// `UserRequestsApproversRepository` uses — so the two role collections
/// (`Roles`, `Subscription_Admin`) and `time_tracker_module_permissions/
/// {roleId}` are read exactly as Role Management writes them. Throws raw
/// errors (playbook §3); the repository cleans them.

import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

/// One role: id, current name and selected modules.
class TimeTrackerRoleRecord {
  const TimeTrackerRoleRecord({
    required this.id,
    required this.name,
    required this.modules,
  });

  final String id;
  final String name;
  final List<String> modules;
}

class TimeTrackerRoleRemoteDataSource {
  TimeTrackerRoleRemoteDataSource({RoleRepository? roles}) : _injected = roles;

  final RoleRepository? _injected;
  RoleRepository? _lazy;

  RoleRepository get _roles => _injected ?? (_lazy ??= RoleRepository());

  /// Function Name: [fetchRoles]
  ///
  /// Purpose: Every non-deleted role of the company.
  ///
  /// Return type: [Future<List<TimeTrackerRoleRecord>>]
  Future<List<TimeTrackerRoleRecord>> fetchRoles() async {
    final dynamic result = await _roles.getUnDeletedRoles();
    final List<RoleHistoryModel> roles = result.fold(
      (dynamic failure) => throw Exception('Could not load the roles.'),
      (dynamic value) =>
          value is List ? value.whereType<RoleHistoryModel>().toList() : <RoleHistoryModel>[],
    );
    return <TimeTrackerRoleRecord>[
      for (final RoleHistoryModel r in roles)
        TimeTrackerRoleRecord(
          id: r.roleId,
          name: r.currentRoleName,
          modules: List<String>.of(r.currentSelectedModules),
        ),
    ];
  }

  /// Function Name: [fetchTimeTrackerSwitches]
  ///
  /// Purpose: The role's `time_tracker_module_permissions/{roleId}` document
  /// (each value a bool or a history list whose last entry is current).
  ///
  /// Return type: [Future<Map<String, dynamic>>] — empty when none stored.
  Future<Map<String, dynamic>> fetchTimeTrackerSwitches(String roleId) async {
    final dynamic result = await _roles.getRolePermissions(
      roleId: roleId,
      module: TimeTrackerFirestorePaths.moduleKey,
    );
    return result.fold(
      (dynamic failure) => throw Exception('Could not load the role switches.'),
      (dynamic value) => value is Map<String, dynamic> ? value : <String, dynamic>{},
    );
  }
}
