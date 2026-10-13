/// Module: time_tracker / tt8_request_types / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_types_cubit.dart
/// Purpose: Declares `RequestTypesCubit` — streams the request types (and
///          the locations their availability refers to), holds the tab's
///          search / status filter / card-table toggle, and runs Active /
///          Inactive and Remove.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// FINAL SPEC §1 section 6. Gates: `Change_Request_Type_Status`,
/// `Remove_Request_Type` (status `removed`, never a hard delete). Request
/// types are company set-up, so the tab exists with or without HR. Nothing
/// is seeded (brief) — an empty company shows the empty state. Async work in
/// [init]; streams cancelled in [close]; emit-after-close guarded.
/// Updated: 9/10/2026 - code review: no stream opened after [close] ran
/// during [init]; a failed names read is kept in `errorMessage`.

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_state.dart';

class RequestTypesCubit extends Cubit<RequestTypesState> {
  RequestTypesCubit({
    required RequestTypeBaseRepository types,
    required WorkSetupSourceResolver resolver,
    required EmployeeDirectoryBaseRepository directory,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
  })  : _types = types,
        _resolver = resolver,
        _directory = directory,
        _access = access,
        _log = log,
        super(const RequestTypesState());

  final RequestTypeBaseRepository _types;
  final WorkSetupSourceResolver _resolver;
  final EmployeeDirectoryBaseRepository _directory;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  StreamSubscription<List<RequestType>>? _sub;

  @override
  void emit(RequestTypesState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Load locations + departments (availability names), then
  /// stream the request types.
  ///
  /// Return type: [Future<void>]
  Future<void> init({bool isArabic = false}) async {
    emit(state.copyWith(status: RequestTypesLoadStatus.loading, errorMessage: ''));
    try {
      // HR's locations when the company has HR, Time Tracker's otherwise.
      final List<WorkLocation> locations =
          await (await _resolver.resolve()).loadLocations();
      final Map<String, String> departments = await _directory.fetchDepartments(isArabic: isArabic);
      final List<TimeTrackerEmployee> people = await _directory.fetchEmployees(isArabic: isArabic);
      emit(state.copyWith(locations: locations, departments: departments, employees: people));
    } catch (error) {
      // Names only — the list still works without them; the reason is kept.
      emit(state.copyWith(errorMessage: error.toString()));
    }
    await _sub?.cancel();
    // 9/10/2026 (code review): closed during the awaits → open nothing.
    if (isClosed) return;
    _sub = _types.watchRequestTypes().listen(
      (List<RequestType> list) =>
          emit(state.copyWith(status: RequestTypesLoadStatus.loaded, types: list)),
      onError: (Object error) => emit(state.copyWith(
        status: RequestTypesLoadStatus.failure,
        errorMessage: error.toString(),
      )),
    );
  }

  void searchChanged(String query) => emit(state.copyWith(query: query));
  void filterStatus(RequestTypeStatus? status) =>
      emit(state.copyWith(statusFilter: status, clearStatusFilter: status == null));
  void setGrid(bool isGrid) => emit(state.copyWith(isGrid: isGrid));

  /// Function Name: [toggleStatus]
  ///
  /// Purpose: Active ↔ Inactive (`Change_Request_Type_Status`). A removed
  /// type comes back as active.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> toggleStatus(RequestType type) => _run(() async {
        if (!_access.canChangeRequestTypeStatus) throw const TimeTrackerPermissionDenied();
        await _types.updateRequestType(
          type: type.copyWith(
            status: type.status == RequestTypeStatus.active
                ? RequestTypeStatus.inactive
                : RequestTypeStatus.active,
          ),
        );
        _log.log(TimeTrackerLogService.actionChangeRequestTypeStatus);
      });

  /// Function Name: [remove]
  ///
  /// Purpose: Remove (`Remove_Request_Type`): status `removed`.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> remove(RequestType type) => _run(() async {
        if (!_access.canRemoveRequestType) throw const TimeTrackerPermissionDenied();
        await _types.updateRequestType(type: type.copyWith(status: RequestTypeStatus.removed));
        _log.log(TimeTrackerLogService.actionRemoveRequestType);
      });

  /// Function Name: [restore]
  ///
  /// Purpose: ADDED 12/10/2026 (owner R-4) — a removed type back to active
  /// (`Change_Request_Type_Status`).
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> restore(RequestType type) => _run(() async {
        if (!_access.canChangeRequestTypeStatus) throw const TimeTrackerPermissionDenied();
        await _types.updateRequestType(type: type.copyWith(status: RequestTypeStatus.active));
        _log.log(TimeTrackerLogService.actionChangeRequestTypeStatus);
      });

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
    await _sub?.cancel();
    return super.close();
  }
}
