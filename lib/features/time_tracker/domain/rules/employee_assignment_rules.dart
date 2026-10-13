/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: employee_assignment_rules.dart
/// Purpose: Declares the pure rules of the Employees / Groups screens:
///          `AssignmentError` + `AssignmentRules` (the Review / Grant Access
///          dialog and the group form share them), `EmployeeAssignmentRow`
///          + `EmployeesView` (assigned / unassigned lists, counters,
///          search, department scope) and `GroupAssignmentPlanner` (a
///          group's rules applied to its members' assignments).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:93542` / `661:93830` / `661:95280` / `661:95712`. Assumption
/// A7 (STATUS.md): the assignment's own rules are the answer at check-in;
/// a group COPIES its rules into its members' assignments when it is saved.
/// A member removed from a group, or the members of a deleted group, keep
/// their location (nothing is unassigned behind HR's back) — only the
/// assignment's `Group_Id` is cleared. Pure Dart, unit-tested.
/// Updated: 9/10/2026 - owner decision 33: a group links its members instead
/// of copying its rules (an employee's own custom rules are kept; a leaving
/// member goes back to the location's rules); break length is only checked
/// for CUSTOM rules ("Use the location's rules" needs none).

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

enum AssignmentError {
  locationRequired,
  startDateRequired,
  breakLengthRequired,
  allowedLocationsRequired,
}

class AssignmentRules {
  const AssignmentRules._();

  /// Longest break accepted (one day).
  static const int maxBreakMinutes = 24 * 60;

  /// Function Name: [validate]
  ///
  /// Purpose: Every problem of a Grant Access / group draft.
  ///
  /// Parameters:
  ///   [String] locationId · [DateTime?] startDate · [AttendanceRules] rules
  ///
  /// Return type: [Set<AssignmentError>]
  static Set<AssignmentError> validate({
    required String locationId,
    required DateTime? startDate,
    required AttendanceRules rules,
  }) =>
      <AssignmentError>{
        if (locationId.trim().isEmpty) AssignmentError.locationRequired,
        if (startDate == null) AssignmentError.startDateRequired,
        if (rules.isCustom &&
            rules.isBreakAllowed &&
            (rules.breakMinutes <= 0 || rules.breakMinutes > maxBreakMinutes))
          AssignmentError.breakLengthRequired,
      };
}

/// One employee and their current assignment (null = never assigned).
class EmployeeAssignmentRow {
  const EmployeeAssignmentRow({required this.employee, this.assignment});

  final TimeTrackerEmployee employee;
  final LocationAssignment? assignment;

  bool get isAssigned => assignment?.isAssigned ?? false;
  String get locationId => isAssigned ? assignment!.locationId : '';
}

class EmployeesView {
  const EmployeesView._();

  /// Function Name: [rows]
  ///
  /// Purpose: Join [employees] with their [assignments], keeping only the
  /// employees [covers] lets the viewer see (department scope).
  ///
  /// Return type: [List<EmployeeAssignmentRow>]
  static List<EmployeeAssignmentRow> rows({
    required List<TimeTrackerEmployee> employees,
    required List<LocationAssignment> assignments,
    required bool Function(String departmentId) covers,
  }) {
    final Map<String, LocationAssignment> byEmail = <String, LocationAssignment>{
      for (final LocationAssignment a in assignments)
        a.employeeEmail.trim().toLowerCase(): a,
    };
    return <EmployeeAssignmentRow>[
      for (final TimeTrackerEmployee e in employees)
        if (covers(e.departmentId))
          EmployeeAssignmentRow(employee: e, assignment: byEmail[e.email]),
    ];
  }

  /// Function Name: [filter]
  ///
  /// Purpose: The rows matching [query] (name / title / department /
  /// e-mail), [departmentId] ('' = all) and [locationId] ('' = all).
  ///
  /// Return type: [List<EmployeeAssignmentRow>]
  static List<EmployeeAssignmentRow> filter(
    List<EmployeeAssignmentRow> rows, {
    String query = '',
    String departmentId = '',
    String locationId = '',
  }) {
    final String q = query.trim().toLowerCase();
    return <EmployeeAssignmentRow>[
      for (final EmployeeAssignmentRow r in rows)
        if ((q.isEmpty || r.employee.searchText.contains(q)) &&
            (departmentId.isEmpty || r.employee.departmentId == departmentId) &&
            (locationId.isEmpty || r.locationId == locationId))
          r,
    ];
  }

  /// Function Name: [countsByLocation]
  ///
  /// Purpose: Assigned employees per location id (Locations sub-view chips).
  ///
  /// Return type: [Map<String, int>]
  static Map<String, int> countsByLocation(List<EmployeeAssignmentRow> rows) {
    final Map<String, int> counts = <String, int>{};
    for (final EmployeeAssignmentRow r in rows) {
      if (!r.isAssigned) continue;
      counts[r.locationId] = (counts[r.locationId] ?? 0) + 1;
    }
    return counts;
  }
}

class GroupAssignmentPlanner {
  const GroupAssignmentPlanner._();

  /// Function Name: [plan]
  ///
  /// Purpose: The assignments to write after [group] is saved (or deleted):
  ///   * each current member (not deleted group) gets the group's location
  ///     and start date, tagged with the group id. Since 9/10/2026 (owner
  ///     decision 33) the group's rules are NOT copied: the member's row
  ///     only links to the group (the group's custom rules / the location's
  ///     are resolved at read time — `EffectiveRulesResolver`); a member who
  ///     has CUSTOM rules of their own keeps them (never overwritten);
  ///   * a member who left the group (or every member of a deleted group)
  ///     keeps their location, loses the group tag and goes back to the
  ///     LOCATION's rules (decision 33).
  /// Rows already equal to what is stored are left out.
  ///
  /// Parameters:
  ///   [EmployeeGroup] group: as saved (with its id).
  ///   [List<String>] previousMembers: the members before this save.
  ///   [List<LocationAssignment>] stored: every stored assignment.
  ///
  /// Return type: [List<LocationAssignment>]
  static List<LocationAssignment> plan({
    required EmployeeGroup group,
    required List<String> previousMembers,
    required List<LocationAssignment> stored,
  }) {
    final Map<String, LocationAssignment> byEmail = <String, LocationAssignment>{
      for (final LocationAssignment a in stored) a.employeeEmail.trim().toLowerCase(): a,
    };
    final Set<String> current = group.isDeleted
        ? <String>{}
        : <String>{for (final String e in group.memberEmails) e.trim().toLowerCase()};
    final List<LocationAssignment> out = <LocationAssignment>[];
    for (final String email in current) {
      if (email.isEmpty) continue;
      final LocationAssignment? now = byEmail[email];
      final AttendanceRules? own = now != null && now.rules.isCustom ? now.rules : null;
      final LocationAssignment next = LocationAssignment(
        employeeEmail: email,
        locationId: group.locationId,
        startDate: group.startDate,
        rules: own ?? AttendanceRules.fromLocation,
        groupId: group.id,
      );
      if (now == null || !_same(now, next)) out.add(next);
    }
    final Set<String> leaving = <String>{
      for (final String e in <String>[...previousMembers, ...group.memberEmails])
        e.trim().toLowerCase(),
    }..removeAll(current);
    for (final String email in leaving) {
      final LocationAssignment? now = byEmail[email];
      if (now == null || now.groupId != group.id) continue;
      out.add(LocationAssignment(
        employeeEmail: now.employeeEmail,
        locationId: now.locationId,
        startDate: now.startDate,
        rules: AttendanceRules.fromLocation,
      ));
    }
    return out;
  }

  static bool _same(LocationAssignment a, LocationAssignment b) {
    final AttendanceRules x = a.rules;
    final AttendanceRules y = b.rules;
    return a.locationId == b.locationId &&
        a.groupId == b.groupId &&
        x.isCustom == y.isCustom &&
        _day(a.startDate) == _day(b.startDate) &&
        x.isBreakAllowed == y.isBreakAllowed &&
        x.breakMinutes == y.breakMinutes &&
        x.isPauseAllowed == y.isPauseAllowed &&
        x.pauseMinutes == y.pauseMinutes &&
        x.isDifferentLocationAllowed == y.isDifferentLocationAllowed &&
        x.allowedLocationIds.join(',') == y.allowedLocationIds.join(',');
  }

  static DateTime? _day(DateTime? d) =>
      d == null ? null : DateTime(d.year, d.month, d.day);
}
