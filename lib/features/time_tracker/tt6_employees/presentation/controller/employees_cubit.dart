/// Module: time_tracker / tt6_employees / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: employees_cubit.dart
/// Purpose: Declares `EmployeesCubit` — loads the company's employees and
///          streams assignments / groups / locations for the Employees tab
///          (Employees | Locations, Assigned · Unassigned · Groups), and runs
///          Assign / Reassign / Remove and the group writes.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3, no-HR companies (owner decision 14 — with HR the tab is hidden
/// and every write is refused). Scope (FINAL SPEC §1): without
/// `Employees_All_Departments` only the viewer's own department is listed.
/// Gates: `Assign_Employee`, `Reassign_Employee_Location`,
/// `Remove_Employee_Assignment` (remove = empty `Location_Id`, history kept)
/// and, through `GroupService`, `Create_Group` / `Edit_Group` /
/// `Delete_Group`. A personal assign / reassign clears the group tag.
/// Async work starts in [init]; streams cancelled in [close]; emit-after-
/// close guarded (playbook §3).
/// Updated: 9/10/2026 - code review: no stream opened after [close] ran
/// during [init]'s awaits.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/group_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/employee_assignment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt6_employees/presentation/controller/employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  EmployeesCubit({
    required EmployeeDirectoryBaseRepository directory,
    required LocationAssignmentBaseRepository assignments,
    required GroupBaseRepository groups,
    required LocationBaseRepository locations,
    required GroupService groupService,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    TimeTrackerNotificationService notifications = const TimeTrackerNotificationService(),
  })  : _directory = directory,
        _notifications = notifications,
        _assignments = assignments,
        _groups = groups,
        _locations = locations,
        _groupService = groupService,
        _resolver = resolver,
        _access = access,
        _log = log,
        super(const EmployeesState());

  final EmployeeDirectoryBaseRepository _directory;
  final LocationAssignmentBaseRepository _assignments;
  final GroupBaseRepository _groups;
  final LocationBaseRepository _locations;
  final GroupService _groupService;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final TimeTrackerNotificationService _notifications;

  /// The app language at [init] (the notification sender's language).
  bool _isArabic = false;
  final TimeTrackerLogService _log;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  @override
  void emit(EmployeesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Read the HR licence and the employees, then stream the
  /// assignments, groups and locations.
  ///
  /// Parameters:
  ///   [bool] isArabic: the language department names are read in.
  ///
  /// Return type: [Future<void>]
  Future<void> init({bool isArabic = false}) async {
    _isArabic = isArabic;
    emit(state.copyWith(
      status: EmployeesLoadStatus.loading,
      errorMessage: '',
      // Only Groups can be seen without View_Time_Tracker_Employees.
      segment: _access.canViewEmployees ? state.segment : EmployeesSegment.groups,
    ));
    try {
      final bool hasHr = await _resolver.hasHrModule();
      final List<TimeTrackerEmployee> people = await _directory.fetchEmployees(isArabic: isArabic);
      emit(state.copyWith(companyHasHr: hasHr, employees: people));
    } catch (error) {
      emit(state.copyWith(status: EmployeesLoadStatus.failure, errorMessage: error.toString()));
      return;
    }
    for (final StreamSubscription<dynamic> s in _subs) {
      await s.cancel();
    }
    // 9/10/2026 (code review): closed during the awaits → open nothing.
    if (isClosed) return;
    _subs
      ..clear()
      ..add(_assignments.watchAssignments().listen(
        (List<LocationAssignment> list) => _publish(assignments: list),
        onError: _failed,
      ))
      ..add(_groups.watchGroups().listen(
        (List<EmployeeGroup> list) => emit(state.copyWith(groups: list)),
        onError: _failed,
      ))
      ..add(_locations.watchLocations().listen(
        (List<WorkLocation> list) => emit(state.copyWith(locations: list)),
        onError: _failed,
      ));
  }

  void _failed(Object error) => emit(state.copyWith(
        status: EmployeesLoadStatus.failure,
        errorMessage: error.toString(),
      ));

  void _publish({required List<LocationAssignment> assignments}) => emit(state.copyWith(
        status: EmployeesLoadStatus.loaded,
        assignments: assignments,
        rows: EmployeesView.rows(
          employees: state.employees,
          assignments: assignments,
          covers: _access.employeesCover,
        ),
      ));

  // ── Tab state ─────────────────────────────────────────────────────────────

  void setView(EmployeesSubView view) => emit(state.copyWith(view: view));
  void setSegment(EmployeesSegment segment) =>
      emit(state.copyWith(segment: segment, selected: const <String>{}));
  void searchChanged(String query) => emit(state.copyWith(query: query));
  void departmentChanged(String departmentId) => emit(state.copyWith(departmentId: departmentId));
  void applyLocationFilter(String locationId) => emit(state.copyWith(locationFilter: locationId));
  void openChip(String locationId) => emit(state.copyWith(chipLocationId: locationId));
  void groupSearchChanged(String query) => emit(state.copyWith(groupQuery: query));
  /// [sort] null = the chosen sort was tapped again → cleared (owner T10).
  void groupSortChanged(GroupSort? sort) =>
      emit(sort == null ? state.copyWith(clearGroupSort: true) : state.copyWith(groupSort: sort));
  void clearSelection() => emit(state.copyWith(selected: const <String>{}));

  /// Function Name: [toggleSelected]
  ///
  /// Purpose: Tick / untick an unassigned employee for a multi-assign.
  ///
  /// Return type: [void]
  void toggleSelected(String email) {
    final Set<String> next = Set<String>.of(state.selected);
    next.contains(email) ? next.remove(email) : next.add(email);
    emit(state.copyWith(selected: next));
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Function Name: [grantAccess]
  ///
  /// Purpose: Assign (or reassign) [emails] to [locationId] from [startDate]
  /// with [rules] — the Review dialog's Grant Access. Gate: Assign_Employee
  /// for employees with no location, Reassign_Employee_Location otherwise.
  ///
  /// Return type: [Future<bool>] — every employee saved.
  Future<bool> grantAccess({
    required List<String> emails,
    required String locationId,
    required DateTime startDate,
    required AttendanceRules rules,
  }) =>
      _run(() async {
        final bool hr = state.companyHasHr;
        for (final String email in emails) {
          final bool reassign = state.assignmentOf(email)?.isAssigned ?? false;
          final bool allowed = reassign
              ? _access.canReassignEmployeeLocation(companyHasHr: hr)
              : _access.canAssignEmployee(companyHasHr: hr);
          if (!allowed) throw const TimeTrackerPermissionDenied();
        }
        for (final String email in emails) {
          final LocationAssignment? before = state.assignmentOf(email);
          final bool reassign = before?.isAssigned ?? false;
          await _assignments.saveAssignment(
            assignment: LocationAssignment(
              employeeEmail: email,
              locationId: locationId,
              startDate: startDate,
              rules: rules,
            ),
          );
          _log.log(reassign
              ? TimeTrackerLogService.actionReassignEmployee
              : TimeTrackerLogService.actionAssignEmployee);
          // 13/10/2026 (decision 34): tell the employee — never blocks the save.
          final bool placeChanged =
              before == null || before.locationId != locationId || !before.rules.samePlacesAs(rules);
          final bool shiftChanged = before != null && before.isAssigned && !before.rules.sameShiftAs(rules);
          final String me = _access.currentUserEmail;
          if (placeChanged) {
            unawaited(_notifications.notifyWorkLocationUpdated(
                senderEmail: me, employeeEmail: email, isArabic: _isArabic));
          }
          if (shiftChanged) {
            unawaited(_notifications.notifyShiftUpdated(senderEmail: me, employeeEmail: email, isArabic: _isArabic));
          }
        }
        emit(state.copyWith(selected: const <String>{}));
      });

  /// Function Name: [removeAssignment]
  ///
  /// Purpose: Remove [email]'s assignment (Remove_Employee_Assignment): an
  /// empty location, history kept.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> removeAssignment(String email) => _run(() async {
        if (!_access.canRemoveEmployeeAssignment(companyHasHr: state.companyHasHr)) {
          throw const TimeTrackerPermissionDenied();
        }
        final LocationAssignment? now = state.assignmentOf(email);
        await _assignments.saveAssignment(
          assignment: LocationAssignment(
            employeeEmail: email,
            startDate: now?.startDate,
            rules: now?.rules ?? const AttendanceRules(),
          ),
        );
        _log.log(TimeTrackerLogService.actionRemoveEmployee);
      });

  /// Function Name: [saveGroup]
  ///
  /// Purpose: Create ([before] null) or edit a group and apply it to its
  /// members (`GroupService`).
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> saveGroup(EmployeeGroup group, {EmployeeGroup? before}) => _run(() async {
        final EmployeeGroup? old = before;
        if (old == null) {
          await _groupService.create(group,
              stored: state.assignments, companyHasHr: state.companyHasHr);
        } else {
          await _groupService.update(group,
              before: old, stored: state.assignments, companyHasHr: state.companyHasHr);
        }
      });

  /// Function Name: [deleteGroup]
  ///
  /// Purpose: Soft-delete [group]; members keep their location.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> deleteGroup(EmployeeGroup group) => _run(() => _groupService.delete(
        group,
        stored: state.assignments,
        companyHasHr: state.companyHasHr,
      ));

  /// Function Name: [acknowledgeFailure]
  ///
  /// Purpose: The page showed the failure message.
  ///
  /// Return type: [void]
  void acknowledgeFailure() => emit(state.copyWith(failure: TimeTrackerActionFailure.none));

  Future<bool> _run(Future<void> Function() action) async {
    emit(state.copyWith(failure: TimeTrackerActionFailure.none));
    try {
      await action();
      return true;
    } catch (error) {
      emit(state.copyWith(failure: timeTrackerFailureOf(error)));
      return false;
    }
  }

  @override
  Future<void> close() async {
    for (final StreamSubscription<dynamic> s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}
