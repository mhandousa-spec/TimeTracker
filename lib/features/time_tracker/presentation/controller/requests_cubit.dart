/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: requests_cubit.dart
/// Purpose: Declares `RequestsCubit` — streams the company's requests and
///          request types, loads the employee names, and holds the view
///          settings of the Requests and Approvals tabs.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 4. Read-only feed: every change goes through
/// `RequestActionsCubit` (services), and the streams bring the result back.
/// Requests are filtered in the app (history fields cannot be queried on
/// their current value — FINAL SPEC §2 "Known risk"). Async work in [init];
/// streams cancelled in [close]; emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - code review: an employee without Approvals / HR
/// dashboard rights streams ONLY their own requests (finding 9); an HR
/// approver loads who may approve, so a BLOCKED manager step shows up in
/// their Approvals (finding 7); no subscription is opened after [close]
/// ran during [init]'s awaits; non-fatal read failures are kept in
/// `errorMessage` instead of being swallowed.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_list_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';

export 'package:knowticed_plus/features/time_tracker/presentation/controller/requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  RequestsCubit({
    required RequestBaseRepository requests,
    required RequestTypeBaseRepository types,
    required EmployeeDirectoryBaseRepository directory,
    required TimeTrackerAccess access,
    ApproverDirectory? approvers,
  })  : _requests = requests,
        _types = types,
        _directory = directory,
        _access = access,
        _approvers = approvers,
        super(const RequestsState());

  final RequestBaseRepository _requests;
  final RequestTypeBaseRepository _types;
  final EmployeeDirectoryBaseRepository _directory;
  final TimeTrackerAccess _access;
  final ApproverDirectory? _approvers;
  StreamSubscription<List<TimeTrackerRequest>>? _requestSub;
  StreamSubscription<List<RequestType>>? _typeSub;

  @override
  void emit(RequestsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Load names (employees, departments), then stream the types
  /// and the requests.
  ///
  /// Return type: [Future<void>]
  Future<void> init({bool isArabic = false}) async {
    emit(state.copyWith(
      status: RequestsLoadStatus.loading,
      errorMessage: '',
      myEmail: _access.currentUserEmail,
      viewer: _access.approverView,
    ));
    try {
      final List<TimeTrackerEmployee> people = await _directory.fetchEmployees(isArabic: isArabic);
      final Map<String, String> departments = await _directory.fetchDepartments(isArabic: isArabic);
      emit(state.copyWith(employees: people, departments: departments));
    } catch (error) {
      // Names only — the lists still work with e-mails; the reason is kept.
      emit(state.copyWith(errorMessage: error.toString()));
    }
    await _typeSub?.cancel();
    if (isClosed) return;
    _typeSub = _types.watchRequestTypes().listen(
      (List<RequestType> list) => emit(state.copyWith(types: list)),
      // Type names only (the lists show ids) — keep why.
      onError: (Object error) => emit(state.copyWith(errorMessage: error.toString())),
    );
    await _requestSub?.cancel();
    if (isClosed) return;
    // Finding 9: company-wide only for approvers / HR dashboard holders.
    final Stream<List<TimeTrackerRequest>> feed = _access.readsCompanyRequests
        ? _requests.watchRequests()
        : _requests.watchRequestsOf(email: _access.currentUserEmail);
    _requestSub = feed.listen(
      (List<TimeTrackerRequest> list) =>
          emit(state.copyWith(status: RequestsLoadStatus.loaded, requests: list)),
      onError: (Object error) => emit(state.copyWith(
        status: RequestsLoadStatus.failure,
        errorMessage: error.toString(),
      )),
    );
    await _loadApprovers();
  }

  /// Finding 7: an HR approver sees (and may act on) a manager step whose
  /// manager cannot act any more.
  Future<void> _loadApprovers() async {
    final ApproverDirectory? approvers = _approvers;
    if (approvers == null || !state.viewer.isHrApprover) return;
    try {
      final Set<String> emails = <String>{
        for (final TimeTrackerApprover a in await approvers.fetchApprovers()) a.email,
      };
      emit(state.copyWith(viewer: state.viewer.withActiveApprovers(emails)));
    } catch (error) {
      // Without the list no step counts as blocked (the old behaviour).
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  /// Function Name: [setBucket] / [search] / [setFilter] / [setGrid] /
  /// [setEmployee]
  ///
  /// Purpose: One tab's counter, search text, Filter popup, card / table
  /// toggle, and the Approvals "Employees" selector ('' = all).
  ///
  /// Return type: [void]
  void setBucket(RequestScope scope, RequestBucket bucket) =>
      _view(scope, (RequestViewConfig v) => v.copyWith(bucket: bucket));

  void search(RequestScope scope, String query) =>
      _view(scope, (RequestViewConfig v) => v.copyWith(query: query));

  void setFilter(RequestScope scope, RequestFilter filter) =>
      _view(scope, (RequestViewConfig v) => v.copyWith(filter: filter));

  void setGrid(RequestScope scope, bool isGrid) =>
      _view(scope, (RequestViewConfig v) => v.copyWith(isGrid: isGrid));

  void setEmployee(String email) =>
      _view(RequestScope.approvals, (RequestViewConfig v) => v.copyWith(employeeEmail: email));

  void _view(RequestScope scope, RequestViewConfig Function(RequestViewConfig) update) {
    emit(scope == RequestScope.mine
        ? state.copyWith(mine: update(state.mine))
        : state.copyWith(approvals: update(state.approvals)));
  }

  @override
  Future<void> close() async {
    await _requestSub?.cancel();
    await _typeSub?.cancel();
    return super.close();
  }
}
