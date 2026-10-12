/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: manager_resolver.dart
/// Purpose: Declares `ManagerResolver` — answers "who is this employee's
///          DIRECT MANAGER?" for approval step 1.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 18 (8/10/2026): approval step 1 is the requester's direct
/// manager from the Org Chart. In this app the org chart is built ONLY from
/// each employee's `Supervisor` email on `Employees_Info/{employeeId}`
/// (indexed history, last entry = current) — departments carry no manager.
/// The implementation is `OrgChartManagerResolver`; screens and services only
/// see this interface.
///
/// Fallback (decision 18): no manager known → '' → the caller skips step 1
/// and the request goes straight to HR (`ApprovalRouter.initialSteps`).
///
/// Error policy: completes or throws a clean `Exception`.

abstract class ManagerResolver {
  /// Function Name: [managerEmailOf]
  ///
  /// Purpose: The lower-cased email of [employeeEmail]'s direct manager.
  ///
  /// Parameters:
  ///   [String] employeeEmail: the requester.
  ///   [String] employeeId: the requester's `Employees_Info` id ('' when
  ///     unknown — only the in-memory directory is asked then).
  ///
  /// Return type: [Future<String>] — '' when no manager is known, or when
  /// the stored manager is the employee themself.
  Future<String> managerEmailOf({
    required String employeeEmail,
    String employeeId = '',
  });
}
