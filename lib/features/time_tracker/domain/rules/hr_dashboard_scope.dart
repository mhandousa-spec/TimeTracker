/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_scope.dart
/// Purpose: Declares `HrDashboardFilters` (the HR view's Employee /
///          Department / Location filters) and `HrDashboardScope` — which
///          employees the HR dashboard counts for a viewer and a filter set.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// FINAL SPEC §1 section 2 + scope rules:
///   * `HR_Dashboard_All_Departments` ON → every department, and the
///     Department filter is shown; OFF → only the viewer's OWN department
///     (an unknown department never matches) and the filter is hidden, so a
///     stale department choice is ignored.
///   * `HR_Dashboard_Filter_By_Employee` OFF → the Employee picker is hidden
///     and any picked employees are ignored.
///   * Location = the employee's assigned location (placement), so absent
///     days (no check-in, no session location) still count for it.
/// Pure Dart — unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

/// The HR view's filters ('' / empty = no filter).
class HrDashboardFilters {
  const HrDashboardFilters({
    this.departmentId = '',
    this.locationId = '',
    this.employeeEmails = const <String>{},
  });

  final String departmentId;
  final String locationId;

  /// Lower-cased e-mails picked in the Employee picker.
  final Set<String> employeeEmails;

  static const HrDashboardFilters none = HrDashboardFilters();

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [HrDashboardFilters]
  HrDashboardFilters copyWith({
    String? departmentId,
    String? locationId,
    Set<String>? employeeEmails,
  }) =>
      HrDashboardFilters(
        departmentId: departmentId ?? this.departmentId,
        locationId: locationId ?? this.locationId,
        employeeEmails: employeeEmails ?? this.employeeEmails,
      );
}

class HrDashboardScope {
  const HrDashboardScope._();

  static String _norm(String v) => v.trim().toLowerCase();

  /// Function Name: [permitted]
  ///
  /// Purpose: The employees the viewer may see on the HR dashboard.
  ///
  /// Parameters:
  ///   [List<TimeTrackerEmployee>] all: the company's employees.
  ///   [bool] allDepartments: `HR_Dashboard_All_Departments`.
  ///   [String] ownDepartmentId: the viewer's department ('' = none → nobody
  ///   without All Departments, fail-closed).
  ///
  /// Return type: [List<TimeTrackerEmployee>]
  static List<TimeTrackerEmployee> permitted(
    List<TimeTrackerEmployee> all, {
    required bool allDepartments,
    required String ownDepartmentId,
  }) {
    final String own = ownDepartmentId.trim();
    return List<TimeTrackerEmployee>.unmodifiable(<TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in all)
        if (allDepartments || (own.isNotEmpty && e.departmentId.trim() == own)) e,
    ]);
  }

  /// Function Name: [apply]
  ///
  /// Purpose: [permitted] narrowed by [filters]. The Department filter only
  /// counts with [allDepartments], the picked employees only with
  /// [canFilterByEmployee] (their controls are hidden otherwise).
  ///
  /// Parameters:
  ///   [List<TimeTrackerEmployee>] permitted: see [permitted].
  ///   [HrDashboardFilters] filters
  ///   [Map<String, EmployeePlacement>] placements: keyed by e-mail.
  ///   [bool] allDepartments
  ///   [bool] canFilterByEmployee
  ///
  /// Return type: [List<TimeTrackerEmployee>]
  static List<TimeTrackerEmployee> apply(
    List<TimeTrackerEmployee> permitted, {
    required HrDashboardFilters filters,
    required Map<String, EmployeePlacement> placements,
    required bool allDepartments,
    required bool canFilterByEmployee,
  }) {
    final String department = allDepartments ? filters.departmentId.trim() : '';
    final String location = filters.locationId.trim();
    final Set<String> picked = canFilterByEmployee
        ? <String>{for (final String e in filters.employeeEmails) _norm(e)}
        : const <String>{};
    return List<TimeTrackerEmployee>.unmodifiable(<TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in permitted)
        if ((department.isEmpty || e.departmentId.trim() == department) &&
            (location.isEmpty || placements[_norm(e.email)]?.locationId == location) &&
            (picked.isEmpty || picked.contains(_norm(e.email))))
          e,
    ]);
  }

  /// Function Name: [emailsOf]
  ///
  /// Purpose: The lower-cased e-mails of [employees].
  ///
  /// Return type: [Set<String>]
  static Set<String> emailsOf(Iterable<TimeTrackerEmployee> employees) =>
      <String>{for (final TimeTrackerEmployee e in employees) if (_norm(e.email).isNotEmpty) _norm(e.email)};
}
