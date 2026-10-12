/// Module: time_tracker / tt8_request_types / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_form_cubit.dart
/// Purpose: Declares `RequestTypeFormCubit` — the Creating / Editing Request
///          Type draft: field updates, availability limits, validation and
///          the save (create / edit + System Log).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:43870` / `661:44042` + "Deducts From Vacation Balance"
/// (`Is_Deducted_From_Vacation_Balance`, FINAL SPEC §2). Gates:
/// `Create_Request_Type` / `Edit_Request_Type`; the edit form's Active
/// switch also needs `Change_Request_Type_Status` (a status change is
/// logged as such). A limit switched OFF empties its list (= available
/// everywhere). Emit-after-close guarded (playbook §3).

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/request_type_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_type_form_state.dart';

class RequestTypeFormCubit extends Cubit<RequestTypeFormState> {
  RequestTypeFormCubit({
    required RequestTypeBaseRepository types,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    RequestType? original,
  })  : _types = types,
        _access = access,
        _log = log,
        super(RequestTypeFormState(
          draft: original ?? const RequestType(id: '', nameEn: ''),
          original: original,
          limitLocations: original?.locationIds.isNotEmpty ?? false,
          limitDepartments: original?.departmentIds.isNotEmpty ?? false,
        ));

  final RequestTypeBaseRepository _types;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;

  @override
  void emit(RequestTypeFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void update(RequestType next) => emit(state.copyWith(draft: next));

  void setLimitLocations(bool on) => emit(state.copyWith(
        limitLocations: on,
        draft: on ? null : state.draft.copyWith(locationIds: const <String>[]),
      ));

  void setLimitDepartments(bool on) => emit(state.copyWith(
        limitDepartments: on,
        draft: on ? null : state.draft.copyWith(departmentIds: const <String>[]),
      ));

  /// Function Name: [revealErrors]
  ///
  /// Purpose: Show every field error (tap on the grey button).
  ///
  /// Return type: [bool] — the draft can be saved.
  bool revealErrors() {
    emit(state.copyWith(showErrors: true));
    return state.canSubmit;
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Create or edit (the confirm dialog's Yes).
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> submit() async {
    if (!state.canSubmit) return false;
    emit(state.copyWith(status: RequestTypeFormStatus.saving, failure: TimeTrackerActionFailure.none));
    try {
      final RequestType? before = state.original;
      if (before == null) {
        if (!_access.canCreateRequestType) throw const TimeTrackerPermissionDenied();
        await _types.createRequestType(type: state.draft);
        _log.log(TimeTrackerLogService.actionCreateRequestType);
      } else {
        final bool statusChanged = before.status != state.draft.status;
        if (!_access.canEditRequestType ||
            (statusChanged && !_access.canChangeRequestTypeStatus)) {
          throw const TimeTrackerPermissionDenied();
        }
        await _types.updateRequestType(type: state.draft);
        _log.log(TimeTrackerLogService.actionEditRequestType);
        if (statusChanged) _log.log(TimeTrackerLogService.actionChangeRequestTypeStatus);
      }
      emit(state.copyWith(status: RequestTypeFormStatus.saved));
      return true;
    } catch (error) {
      emit(state.copyWith(status: RequestTypeFormStatus.failure, failure: timeTrackerFailureOf(error)));
      return false;
    }
  }

  void acknowledgeFailure() => emit(state.copyWith(
        status: RequestTypeFormStatus.editing,
        failure: TimeTrackerActionFailure.none,
      ));
}
