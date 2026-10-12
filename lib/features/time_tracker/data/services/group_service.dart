/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: group_service.dart
/// Purpose: Declares `GroupService` — create / edit / delete an employee
///          group AND write its rules into its members' assignments, with
///          the System Log entry.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3 brief: "a group's rules apply to its members' assignments"
/// (`GroupAssignmentPlanner`, assumption A7). Permission gates are checked
/// here too (fail-closed, the UI hides the buttons): Create_Group /
/// Edit_Group / Delete_Group — and, because saving a group re-assigns its
/// members, the company must not have HR (HR owns assignments). Delete is
/// soft (`Is_Deleted`, A4). Throws `Exception`s from the repositories.

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';

class GroupService {
  const GroupService({
    required GroupBaseRepository groups,
    required LocationAssignmentBaseRepository assignments,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
  })  : _groups = groups,
        _assignments = assignments,
        _access = access,
        _log = log;

  final GroupBaseRepository _groups;
  final LocationAssignmentBaseRepository _assignments;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;

  /// Function Name: [create]
  ///
  /// Purpose: Save a new group, then assign its members.
  ///
  /// Parameters:
  ///   [EmployeeGroup] draft · [List<LocationAssignment>] stored assignments
  ///   · [bool] companyHasHr
  ///
  /// Return type: [Future<EmployeeGroup>]
  Future<EmployeeGroup> create(
    EmployeeGroup draft, {
    required List<LocationAssignment> stored,
    required bool companyHasHr,
  }) async {
    if (companyHasHr || !_access.canCreateGroup) throw const TimeTrackerPermissionDenied();
    final EmployeeGroup saved = await _groups.createGroup(group: draft);
    await _apply(saved, previousMembers: const <String>[], stored: stored);
    _log.log(TimeTrackerLogService.actionCreateGroup);
    return saved;
  }

  /// Function Name: [update]
  ///
  /// Purpose: Save an edited group, then re-apply it to its members (a
  /// member who left keeps their location; only the group tag is cleared).
  ///
  /// Return type: [Future<EmployeeGroup>]
  Future<EmployeeGroup> update(
    EmployeeGroup group, {
    required EmployeeGroup before,
    required List<LocationAssignment> stored,
    required bool companyHasHr,
  }) async {
    if (companyHasHr || !_access.canEditGroup) throw const TimeTrackerPermissionDenied();
    final EmployeeGroup saved = await _groups.updateGroup(group: group);
    await _apply(saved, previousMembers: before.memberEmails, stored: stored);
    _log.log(TimeTrackerLogService.actionEditGroup);
    return saved;
  }

  /// Function Name: [delete]
  ///
  /// Purpose: Soft-delete [group]; its members keep their location.
  ///
  /// Return type: [Future<void>]
  Future<void> delete(
    EmployeeGroup group, {
    required List<LocationAssignment> stored,
    required bool companyHasHr,
  }) async {
    if (companyHasHr || !_access.canDeleteGroup) throw const TimeTrackerPermissionDenied();
    final EmployeeGroup saved =
        await _groups.updateGroup(group: group.copyWith(isDeleted: true));
    await _apply(saved, previousMembers: group.memberEmails, stored: stored);
    _log.log(TimeTrackerLogService.actionDeleteGroup);
  }

  Future<void> _apply(
    EmployeeGroup group, {
    required List<String> previousMembers,
    required List<LocationAssignment> stored,
  }) async {
    final List<LocationAssignment> writes = GroupAssignmentPlanner.plan(
      group: group,
      previousMembers: previousMembers,
      stored: stored,
    );
    for (final LocationAssignment a in writes) {
      await _assignments.saveAssignment(assignment: a);
    }
  }
}
