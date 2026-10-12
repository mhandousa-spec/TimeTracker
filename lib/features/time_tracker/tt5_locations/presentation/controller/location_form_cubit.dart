/// Module: time_tracker / tt5_locations / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: location_form_cubit.dart
/// Purpose: Declares `LocationFormCubit` — the Create / Edit Location
///          draft: field updates, "Use my current location", validation
///          and the save (create / edit + System Log).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:39468` / `661:40152` / `661:40322` + Work Start / End,
/// Working Days and Late After (owner decisions 13, 22). Gates:
/// `Create_Location` / `Edit_Location`, refused when the company has HR
/// (decision 12). The page owns the text controllers and pushes parsed
/// values here (playbook §3). Emit-after-close guarded.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/location_form_state.dart';

class LocationFormCubit extends Cubit<LocationFormState> {
  LocationFormCubit({
    required LocationBaseRepository locations,
    required DeviceLocationReader device,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
    WorkLocation? original,
  })  : _locations = locations,
        _device = device,
        _resolver = resolver,
        _access = access,
        _log = log,
        super(LocationFormState(
          draft: original ??
              const WorkLocation(
                id: '',
                nameEn: '',
                workingDays: LocationImportRules.defaultWorkingDays,
              ),
          original: original,
        ));

  final LocationBaseRepository _locations;
  final DeviceLocationReader _device;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;

  @override
  void emit(LocationFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [update]
  ///
  /// Purpose: Replace the draft with [next] (built by the page from
  /// `state.draft.copyWith(…)`).
  ///
  /// Return type: [void]
  void update(WorkLocation next) => emit(state.copyWith(draft: next));

  /// Function Name: [toggleDay]
  ///
  /// Purpose: Add / remove working day [weekday] (1 = Mon … 7 = Sun).
  ///
  /// Return type: [void]
  void toggleDay(int weekday) {
    final Set<int> days = state.draft.workingDays.toSet();
    days.contains(weekday) ? days.remove(weekday) : days.add(weekday);
    emit(state.copyWith(
      draft: state.draft.copyWith(
        workingDays: <int>[for (int d = 1; d <= 7; d++) if (days.contains(d)) d],
      ),
    ));
  }

  /// Function Name: [useCurrentLocation]
  ///
  /// Purpose: Fill latitude / longitude from the device (geolocator).
  ///
  /// Return type: [Future<GeoPoint?>] — the position, for the page's fields.
  Future<GeoPoint?> useCurrentLocation() async {
    emit(state.copyWith(isLocating: true, clearLocateIssue: true));
    final DeviceLocationResult result = await _device.currentPosition();
    final GeoPoint? p = result.position;
    if (p == null) {
      emit(state.copyWith(isLocating: false, locateIssue: result.issue));
      return null;
    }
    emit(state.copyWith(
      isLocating: false,
      draft: state.draft.copyWith(latitude: p.latitude, longitude: p.longitude),
    ));
    return p;
  }

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
    emit(state.copyWith(status: LocationFormStatus.saving, failure: TimeTrackerActionFailure.none));
    try {
      final bool hasHr = await _resolver.hasHrModule();
      if (state.isEdit) {
        // 9/10/2026 (UI pass, owner #8): the status is edited here now.
        final bool statusChanged = state.original?.status != state.draft.status;
        if (!_access.canEditLocation(companyHasHr: hasHr) ||
            (statusChanged && !_access.canChangeLocationStatus(companyHasHr: hasHr))) {
          throw const TimeTrackerPermissionDenied();
        }
        await _locations.updateLocation(location: state.draft);
        _log.log(TimeTrackerLogService.actionEditLocation);
        if (statusChanged) _log.log(TimeTrackerLogService.actionChangeLocationStatus);
      } else {
        if (!_access.canCreateLocation(companyHasHr: hasHr)) {
          throw const TimeTrackerPermissionDenied();
        }
        await _locations.createLocation(location: state.draft);
        _log.log(TimeTrackerLogService.actionCreateLocation);
      }
      emit(state.copyWith(status: LocationFormStatus.saved));
      return true;
    } catch (error) {
      emit(state.copyWith(status: LocationFormStatus.failure, failure: timeTrackerFailureOf(error)));
      return false;
    }
  }

  /// Function Name: [acknowledgeFailure]
  ///
  /// Purpose: The page showed the failure; back to editing.
  ///
  /// Return type: [void]
  void acknowledgeFailure() => emit(state.copyWith(
        status: LocationFormStatus.editing,
        failure: TimeTrackerActionFailure.none,
      ));
}
