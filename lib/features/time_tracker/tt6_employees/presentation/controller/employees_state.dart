/// Module: time_tracker / tt6_employees / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employees_state.dart
/// Purpose: Declares `EmployeesState` (+ `EmployeesLoadStatus`,
///          `EmployeesSubView`, `EmployeesSegment`, `GroupSort`) — the
///          Employees tab: the employees in the viewer's scope joined with
///          their assignments, the groups, the locations, and every search /
///          filter / selection of the tab.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:93542` (Assigned) / `661:93830` (Unassigned) / `661:94406`
/// (Groups) / `661:94690` (Locations sub-view). One immutable state +
/// `copyWith` + derived getters (playbook §3). [rows] is already narrowed to
/// the viewer's department scope by the cubit (`Employees_All_Departments`).

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum EmployeesLoadStatus { initial, loading, loaded, failure }

/// The "Employees | Locations" toggle.
enum EmployeesSubView { employees, locations }

/// The three counters: Assigned · Unassigned · Groups.
enum EmployeesSegment { assigned, unassigned, groups }

/// Groups "Sort".
enum GroupSort { nameAsc, nameDesc, newest }

class EmployeesState {
  const EmployeesState({
    this.status = EmployeesLoadStatus.initial,
    this.employees = const <TimeTrackerEmployee>[],
    this.rows = const <EmployeeAssignmentRow>[],
    this.assignments = const <LocationAssignment>[],
    this.groups = const <EmployeeGroup>[],
    this.locations = const <WorkLocation>[],
    this.companyHasHr = false,
    this.view = EmployeesSubView.employees,
    this.segment = EmployeesSegment.assigned,
    this.query = '',
    this.departmentId = '',
    this.locationFilter = '',
    this.selected = const <String>{},
    this.chipLocationId = '',
    this.groupQuery = '',
    this.groupSort = GroupSort.nameAsc,
    this.failure = TimeTrackerActionFailure.none,
    this.errorMessage = '',
  });

  final EmployeesLoadStatus status;

  /// Every employee of the company (names for groups / details).
  final List<TimeTrackerEmployee> employees;

  /// The employees in the viewer's scope, with their assignments.
  final List<EmployeeAssignmentRow> rows;
  final List<LocationAssignment> assignments;
  final List<EmployeeGroup> groups;
  final List<WorkLocation> locations;
  final bool companyHasHr;
  final EmployeesSubView view;
  final EmployeesSegment segment;
  final String query;

  /// '' = every department (the dropdown is only shown with All Departments).
  final String departmentId;

  /// The Filter popup's location ('' = any).
  final String locationFilter;

  /// Unassigned employees ticked for a multi-assign.
  final Set<String> selected;

  /// Locations sub-view: the chip that is open ('' = the first one).
  final String chipLocationId;
  final String groupQuery;
  final GroupSort groupSort;
  final TimeTrackerActionFailure failure;
  final String errorMessage;

  bool get isLoading =>
      status == EmployeesLoadStatus.initial || status == EmployeesLoadStatus.loading;

  List<EmployeeAssignmentRow> _filtered() => EmployeesView.filter(
        rows,
        query: query,
        departmentId: departmentId,
        locationId: locationFilter,
      );

  List<EmployeeAssignmentRow> get assigned =>
      <EmployeeAssignmentRow>[for (final EmployeeAssignmentRow r in _filtered()) if (r.isAssigned) r];

  List<EmployeeAssignmentRow> get unassigned => EmployeesView.filter(
        rows,
        query: query,
        departmentId: departmentId,
      ).where((EmployeeAssignmentRow r) => !r.isAssigned).toList();

  int get assignedCount => rows.where((EmployeeAssignmentRow r) => r.isAssigned).length;
  int get unassignedCount => rows.length - assignedCount;

  /// Not deleted.
  List<EmployeeGroup> get liveGroups =>
      <EmployeeGroup>[for (final EmployeeGroup g in groups) if (!g.isDeleted) g];

  /// [liveGroups] narrowed by the group search and sorted.
  List<EmployeeGroup> get visibleGroups {
    final String q = groupQuery.trim().toLowerCase();
    final List<EmployeeGroup> out = <EmployeeGroup>[
      for (final EmployeeGroup g in liveGroups)
        if (q.isEmpty ||
            '${g.name} ${g.nameAr} ${g.description} ${g.descriptionAr}'.toLowerCase().contains(q))
          g,
    ];
    switch (groupSort) {
      case GroupSort.nameAsc:
        out.sort((EmployeeGroup a, EmployeeGroup b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case GroupSort.nameDesc:
        out.sort((EmployeeGroup a, EmployeeGroup b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case GroupSort.newest:
        out.sort((EmployeeGroup a, EmployeeGroup b) {
          final DateTime x = a.audit.createdAt ?? DateTime(2000);
          final DateTime y = b.audit.createdAt ?? DateTime(2000);
          return y.compareTo(x);
        });
    }
    return out;
  }

  /// Locations an employee can be assigned to (active only).
  List<WorkLocation> get activeLocations => <WorkLocation>[
        for (final WorkLocation l in locations)
          if (l.status == LocationStatus.active) l,
      ];

  /// Department id → name, for the Department dropdown (scope only).
  Map<String, String> get departments => <String, String>{
        for (final EmployeeAssignmentRow r in rows)
          if (r.employee.departmentId.isNotEmpty)
            r.employee.departmentId: r.employee.departmentName.isEmpty
                ? r.employee.departmentId
                : r.employee.departmentName,
      };

  WorkLocation? locationById(String id) {
    for (final WorkLocation l in locations) {
      if (l.id == id) return l;
    }
    return null;
  }

  EmployeeGroup? groupById(String id) {
    for (final EmployeeGroup g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  TimeTrackerEmployee? employeeByEmail(String email) {
    final String key = email.trim().toLowerCase();
    for (final TimeTrackerEmployee e in employees) {
      if (e.email == key) return e;
    }
    return null;
  }

  LocationAssignment? assignmentOf(String email) {
    final String key = email.trim().toLowerCase();
    for (final LocationAssignment a in assignments) {
      if (a.employeeEmail.trim().toLowerCase() == key) return a;
    }
    return null;
  }

  /// Function Name: [effectiveRulesOf]
  ///
  /// Purpose: Decision 33 (9/10/2026) — the break / pause rules that apply
  /// to [email] and where they come from ("From location" / "Custom");
  /// null = not assigned or the location is unknown.
  ///
  /// Return type: [EffectiveRules?]
  EffectiveRules? effectiveRulesOf(String email) {
    final LocationAssignment? a = assignmentOf(email);
    if (a == null || !a.isAssigned) return null;
    final WorkLocation? l = locationById(a.locationId);
    if (l == null) return null;
    return EffectiveRulesResolver.resolve(location: l, assignment: a, group: groupById(a.groupId));
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [EmployeesState]
  EmployeesState copyWith({
    EmployeesLoadStatus? status,
    List<TimeTrackerEmployee>? employees,
    List<EmployeeAssignmentRow>? rows,
    List<LocationAssignment>? assignments,
    List<EmployeeGroup>? groups,
    List<WorkLocation>? locations,
    bool? companyHasHr,
    EmployeesSubView? view,
    EmployeesSegment? segment,
    String? query,
    String? departmentId,
    String? locationFilter,
    Set<String>? selected,
    String? chipLocationId,
    String? groupQuery,
    GroupSort? groupSort,
    TimeTrackerActionFailure? failure,
    String? errorMessage,
  }) =>
      EmployeesState(
        status: status ?? this.status,
        employees: employees ?? this.employees,
        rows: rows ?? this.rows,
        assignments: assignments ?? this.assignments,
        groups: groups ?? this.groups,
        locations: locations ?? this.locations,
        companyHasHr: companyHasHr ?? this.companyHasHr,
        view: view ?? this.view,
        segment: segment ?? this.segment,
        query: query ?? this.query,
        departmentId: departmentId ?? this.departmentId,
        locationFilter: locationFilter ?? this.locationFilter,
        selected: selected ?? this.selected,
        chipLocationId: chipLocationId ?? this.chipLocationId,
        groupQuery: groupQuery ?? this.groupQuery,
        groupSort: groupSort ?? this.groupSort,
        failure: failure ?? this.failure,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
