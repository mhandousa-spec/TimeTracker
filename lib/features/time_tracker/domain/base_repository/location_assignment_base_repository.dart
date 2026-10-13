/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: location_assignment_base_repository.dart
/// Purpose: Declares `LocationAssignmentBaseRepository` — the contract for employee → location assignments (no-HR companies).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

abstract class LocationAssignmentBaseRepository {
  /// Function Name: [watchAssignments]
  ///
  /// Purpose: Live list of every assignment (unassigned ones included).
  ///
  /// Return type: [Stream<List<LocationAssignment>>]
  Stream<List<LocationAssignment>> watchAssignments();

  /// Function Name: [saveAssignment]
  ///
  /// Purpose: Assign / reassign / remove — appends the employee's next row
  /// (`Location_Assignments/{email}`, created on first assign).
  ///
  /// Parameters:
  ///   [LocationAssignment] assignment
  ///
  /// Return type: [Future<LocationAssignment>] — as stored.
  Future<LocationAssignment> saveAssignment({
    required LocationAssignment assignment,
  });

  /// Function Name: [historyOf]
  ///
  /// Purpose: ADDED 13/10/2026 (owner T8) — the employee's location history,
  /// NEWEST first: one entry per change of work locations (rows that only
  /// changed rules are folded into the step before).
  ///
  /// Return type: [Future<List<AssignmentHistoryEntry>>] — empty when the
  /// employee was never assigned.
  Future<List<AssignmentHistoryEntry>> historyOf(String employeeEmail);
}
