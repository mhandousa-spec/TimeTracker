/// Module: time_tracker / tt8_request_types / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_types_state.dart
/// Purpose: Declares `RequestTypesState` (+ `RequestTypesLoadStatus`) —
///          the company's request types, the locations / departments their
///          availability refers to, the search, the status filter and the
///          card / table toggle of the Request Types tab.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:35833` (cards) / `661:36293` (table). One immutable state +
/// `copyWith` + derived getters (playbook §3). "All" lists every status,
/// Removed included (owner rule "All means everything").

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_type_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum RequestTypesLoadStatus { initial, loading, loaded, failure }

class RequestTypesState {
  const RequestTypesState({
    this.status = RequestTypesLoadStatus.initial,
    this.types = const <RequestType>[],
    this.locations = const <WorkLocation>[],
    this.departments = const <String, String>{},
    this.employees = const <TimeTrackerEmployee>[],
    this.query = '',
    this.statusFilter,
    this.isGrid = true,
    this.failure = TimeTrackerActionFailure.none,
    this.errorMessage = '',
  });

  final RequestTypesLoadStatus status;
  final List<RequestType> types;
  final List<WorkLocation> locations;

  /// Department id → name.
  final Map<String, String> departments;

  /// For "Added By" (creator e-mail → name / photo).
  final List<TimeTrackerEmployee> employees;
  final String query;

  /// null = every status.
  final RequestTypeStatus? statusFilter;
  final bool isGrid;
  final TimeTrackerActionFailure failure;
  final String errorMessage;

  bool get isLoading =>
      status == RequestTypesLoadStatus.initial || status == RequestTypesLoadStatus.loading;

  List<RequestType> get visible =>
      RequestTypeList.filter(types, query: query, status: statusFilter);

  TimeTrackerEmployee? employeeByEmail(String email) {
    final String key = email.trim().toLowerCase();
    for (final TimeTrackerEmployee e in employees) {
      if (e.email == key) return e;
    }
    return null;
  }

  RequestType? byId(String id) {
    for (final RequestType t in types) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearStatusFilter] = "All".
  ///
  /// Return type: [RequestTypesState]
  RequestTypesState copyWith({
    RequestTypesLoadStatus? status,
    List<RequestType>? types,
    List<WorkLocation>? locations,
    Map<String, String>? departments,
    List<TimeTrackerEmployee>? employees,
    String? query,
    RequestTypeStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isGrid,
    TimeTrackerActionFailure? failure,
    String? errorMessage,
  }) =>
      RequestTypesState(
        status: status ?? this.status,
        types: types ?? this.types,
        locations: locations ?? this.locations,
        departments: departments ?? this.departments,
        employees: employees ?? this.employees,
        query: query ?? this.query,
        statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
        isGrid: isGrid ?? this.isGrid,
        failure: failure ?? this.failure,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
