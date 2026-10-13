/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: requests_state.dart
/// Purpose: Declares `RequestsState` (+ `RequestsLoadStatus`, `RequestScope`,
///          `RequestViewConfig`) — the company's requests with the names they
///          need (types, employees, departments) and the view settings of
///          the Requests and Approvals tabs.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// One feed for both tabs (and both details pages): the Requests tab shows
/// the signed-in user's own requests + transactions (`RequestList.mine`),
/// the Approvals tab the ones that involve them as an approver
/// (`ApprovalInbox.of`). Each tab keeps its own counter / search / filter /
/// card-table toggle ([RequestViewConfig]); the Approvals tab adds the
/// Employees selector. One immutable state + `copyWith` + derived getters
/// (playbook §3).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';

enum RequestsLoadStatus { initial, loading, loaded, failure }

/// Which tab a view setting belongs to.
enum RequestScope { mine, approvals }

/// One tab's counter, search, filter, toggle and (Approvals) employee.
class RequestViewConfig {
  const RequestViewConfig({
    this.bucket = RequestBucket.all,
    this.query = '',
    this.filter = RequestFilter.none,
    this.isGrid = true,
    this.employeeEmail = '',
  });

  final RequestBucket bucket;
  final String query;
  final RequestFilter filter;
  final bool isGrid;

  /// '' = every employee (Approvals "Employees" selector).
  final String employeeEmail;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestViewConfig]
  RequestViewConfig copyWith({
    RequestBucket? bucket,
    String? query,
    RequestFilter? filter,
    bool? isGrid,
    String? employeeEmail,
  }) =>
      RequestViewConfig(
        bucket: bucket ?? this.bucket,
        query: query ?? this.query,
        filter: filter ?? this.filter,
        isGrid: isGrid ?? this.isGrid,
        employeeEmail: employeeEmail ?? this.employeeEmail,
      );
}

class RequestsState {
  const RequestsState({
    this.status = RequestsLoadStatus.initial,
    this.requests = const <TimeTrackerRequest>[],
    this.types = const <RequestType>[],
    this.employees = const <TimeTrackerEmployee>[],
    this.departments = const <String, String>{},
    this.myEmail = '',
    this.viewer = const ApproverView(
      email: '',
      departmentId: '',
      canApproveAndReject: false,
      allDepartments: false,
      canCancelAfterApproving: false,
    ),
    this.mine = const RequestViewConfig(),
    this.approvals = const RequestViewConfig(),
    this.errorMessage = '',
  });

  final RequestsLoadStatus status;

  /// Every request and transaction of the company (filtered per tab).
  final List<TimeTrackerRequest> requests;

  /// Every request type, removed ones included (old requests keep a name).
  final List<RequestType> types;
  final List<TimeTrackerEmployee> employees;

  /// Department id → name.
  final Map<String, String> departments;
  final String myEmail;
  final ApproverView viewer;
  final RequestViewConfig mine;
  final RequestViewConfig approvals;
  final String errorMessage;

  bool get isLoading => status == RequestsLoadStatus.initial || status == RequestsLoadStatus.loading;

  RequestViewConfig viewOf(RequestScope scope) => scope == RequestScope.mine ? mine : approvals;

  // ── Lookups ──────────────────────────────────────────────────────────────

  TimeTrackerRequest? byId(String id) {
    for (final TimeTrackerRequest r in requests) {
      if (r.id == id) return r;
    }
    return null;
  }

  RequestType? typeOf(TimeTrackerRequest request) {
    for (final RequestType t in types) {
      if (t.id == request.requestTypeId) return t;
    }
    return null;
  }

  TimeTrackerEmployee? employeeOf(String email) {
    final String key = email.trim().toLowerCase();
    for (final TimeTrackerEmployee e in employees) {
      if (e.email == key) return e;
    }
    return null;
  }

  /// Both languages of the type, the description and the requester — the
  /// search haystack (language-independent).
  String searchTextOf(TimeTrackerRequest r) {
    final RequestType? t = typeOf(r);
    final TimeTrackerEmployee? who = employeeOf(r.requesterEmail);
    // 13/10/2026 (owner): the department too — Approvals searches employee,
    // type and department.
    return '${t?.nameEn ?? ''} ${t?.nameAr ?? ''} ${r.description} '
        '${who?.nameEn ?? ''} ${who?.nameAr ?? ''} ${r.requesterEmail} '
        '${who?.departmentNameEn ?? ''} ${who?.departmentNameAr ?? ''} ${departments[r.requesterDepartmentId] ?? ''}';
  }

  // ── Requests tab ─────────────────────────────────────────────────────────

  List<TimeTrackerRequest> get myRequests => RequestList.mine(requests, myEmail);

  Map<RequestBucket, int> get myCounts => RequestList.counts(myRequests);

  List<TimeTrackerRequest> get visibleMine => RequestList.filter(
        myRequests,
        bucket: mine.bucket,
        query: mine.query,
        filter: mine.filter,
        textOf: searchTextOf,
      );

  // ── Approvals tab ────────────────────────────────────────────────────────

  List<TimeTrackerRequest> get approvalRequests => ApprovalInbox.of(requests, viewer);

  /// No Under Review counter here → it counts as Pending.
  Map<RequestBucket, int> get approvalCounts =>
      RequestList.counts(approvalRequests, underReviewAsPending: true);

  List<TimeTrackerRequest> get visibleApprovals => RequestList.filter(
        approvalRequests,
        bucket: approvals.bucket,
        query: approvals.query,
        filter: approvals.filter,
        requesterEmail: approvals.employeeEmail,
        underReviewAsPending: true,
        textOf: searchTextOf,
      );

  /// The people who appear in the Approvals tab (Employees selector).
  List<TimeTrackerEmployee> get approvalRequesters {
    final Set<String> emails = <String>{
      for (final TimeTrackerRequest r in approvalRequests) r.requesterEmail.trim().toLowerCase(),
    };
    return <TimeTrackerEmployee>[
      for (final String e in emails) employeeOf(e) ?? TimeTrackerEmployee(email: e),
    ];
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestsState]
  RequestsState copyWith({
    RequestsLoadStatus? status,
    List<TimeTrackerRequest>? requests,
    List<RequestType>? types,
    List<TimeTrackerEmployee>? employees,
    Map<String, String>? departments,
    String? myEmail,
    ApproverView? viewer,
    RequestViewConfig? mine,
    RequestViewConfig? approvals,
    String? errorMessage,
  }) =>
      RequestsState(
        status: status ?? this.status,
        requests: requests ?? this.requests,
        types: types ?? this.types,
        employees: employees ?? this.employees,
        departments: departments ?? this.departments,
        myEmail: myEmail ?? this.myEmail,
        viewer: viewer ?? this.viewer,
        mine: mine ?? this.mine,
        approvals: approvals ?? this.approvals,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
