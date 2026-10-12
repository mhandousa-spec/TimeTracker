/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: group_base_repository.dart
/// Purpose: Declares `GroupBaseRepository` — the contract for employee groups.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

abstract class GroupBaseRepository {
  /// Function Name: [watchGroups]
  ///
  /// Purpose: Live list of every group (deleted ones included).
  ///
  /// Return type: [Stream<List<EmployeeGroup>>]
  Stream<List<EmployeeGroup>> watchGroups();

  /// Function Name: [createGroup]
  ///
  /// Purpose: Persist a new group.
  ///
  /// Parameters:
  ///   [EmployeeGroup] group: the draft; its id is ignored.
  ///
  /// Return type: [Future<EmployeeGroup>] — with its new id.
  Future<EmployeeGroup> createGroup({required EmployeeGroup group});

  /// Function Name: [updateGroup]
  ///
  /// Purpose: Append the edited group (edit / delete).
  ///
  /// Parameters:
  ///   [EmployeeGroup] group
  ///
  /// Return type: [Future<EmployeeGroup>] — as stored.
  Future<EmployeeGroup> updateGroup({required EmployeeGroup group});
}
