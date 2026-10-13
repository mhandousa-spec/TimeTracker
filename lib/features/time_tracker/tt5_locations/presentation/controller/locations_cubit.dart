/// Module: time_tracker / tt5_locations / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: locations_cubit.dart
/// Purpose: Declares `LocationsCubit` — streams the company's locations and
///          assignments, holds the Locations tab's search + filter, and runs
///          Active / Inactive, Delete and Import.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3, no-HR companies only (owner decision 12): with HR every write is
/// refused (the tab is hidden anyway). Gates: `Change_Location_Status`,
/// `Delete_Location` (soft — `deleted` status, A4), `Import_Locations`
/// (never deletes; blank cell = keep — `LocationImportRules`). Every write
/// is logged. Async work starts in [init]; streams cancelled in [close];
/// emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - code review: Delete / make Inactive is refused while
/// employees are assigned to the location ([assignedCount], re-read from
/// the store at save time — owner: "Reassign them first"); no subscription
/// is opened after [close] ran during [init]; a failed assignments stream is
/// kept in `errorMessage` instead of being swallowed.

import 'dart:async';

import 'package:knowticed_plus/core/helper/main_helper/location_data_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_assignment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/location_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  LocationsCubit({
    required LocationBaseRepository locations,
    required LocationAssignmentBaseRepository assignments,
    required WorkSetupSourceResolver resolver,
    required TimeTrackerAccess access,
    required TimeTrackerLogService log,
  })  : _locations = locations,
        _assignments = assignments,
        _resolver = resolver,
        _access = access,
        _log = log,
        super(const LocationsState());

  final LocationBaseRepository _locations;
  final LocationAssignmentBaseRepository _assignments;
  final WorkSetupSourceResolver _resolver;
  final TimeTrackerAccess _access;
  final TimeTrackerLogService _log;
  StreamSubscription<List<WorkLocation>>? _locSub;
  StreamSubscription<List<LocationAssignment>>? _asgSub;

  @override
  void emit(LocationsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [init]
  ///
  /// Purpose: Read the HR licence, then stream locations + assignments.
  ///
  /// Return type: [Future<void>]
  Future<void> init() async {
    emit(state.copyWith(status: LocationsLoadStatus.loading, errorMessage: ''));
    // States / cities data for the address labels (9/10/2026). Never throws:
    // a missing asset just leaves the stored codes on screen.
    await LocationDataService.instance.load();
    try {
      final bool hasHr = await _resolver.hasHrModule();
      emit(state.copyWith(companyHasHr: hasHr));
    } catch (error) {
      emit(state.copyWith(status: LocationsLoadStatus.failure, errorMessage: error.toString()));
      return;
    }
    await _locSub?.cancel();
    await _asgSub?.cancel();
    if (isClosed) return;
    _locSub = _locations.watchLocations().listen(
      (List<WorkLocation> list) =>
          emit(state.copyWith(status: LocationsLoadStatus.loaded, locations: list)),
      onError: (Object error) => emit(state.copyWith(
        status: LocationsLoadStatus.failure,
        errorMessage: error.toString(),
      )),
    );
    _asgSub = _assignments.watchAssignments().listen(
      (List<LocationAssignment> list) => emit(state.copyWith(assignments: list)),
      // Counts only (the list still works) — keep why.
      onError: (Object error) => emit(state.copyWith(errorMessage: error.toString())),
    );
  }

  /// Function Name: [searchChanged] / [applyFilter]
  ///
  /// Purpose: The search box text / the filter popup's Apply or Reset.
  ///
  /// Return type: [void]
  void searchChanged(String query) => emit(state.copyWith(query: query));
  void applyFilter(LocationsFilter filter) => emit(state.copyWith(filter: filter));

  /// 13/10/2026 (owner): the status counters (All / Active / Inactive) —
  /// null = All; the geofence choice of the Filter stays.
  void filterStatus(LocationStatus? status) =>
      emit(state.copyWith(filter: LocationsFilter(status: status, geofence: state.filter.geofence)));

  /// 13/10/2026 (owner): List / Grid on a tablet.
  void setGrid(bool isGrid) => emit(state.copyWith(isGrid: isGrid));

  /// Function Name: [toggleStatus]
  ///
  /// Purpose: Active ↔ Inactive (`Change_Location_Status`).
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> toggleStatus(WorkLocation location) => _run(() async {
        if (!_access.canChangeLocationStatus(companyHasHr: state.companyHasHr)) {
          throw const TimeTrackerPermissionDenied();
        }
        if (location.status == LocationStatus.active) await _refuseWhileAssigned(location);
        await _locations.updateLocation(
          location: location.copyWith(
            status: location.status == LocationStatus.active
                ? LocationStatus.inactive
                : LocationStatus.active,
          ),
        );
        _log.log(TimeTrackerLogService.actionChangeLocationStatus);
      });

  /// Function Name: [delete]
  ///
  /// Purpose: Soft-delete (`Delete_Location`): status `deleted`, history and
  /// old attendance kept.
  ///
  /// Return type: [Future<bool>] — saved.
  Future<bool> delete(WorkLocation location) => _run(() async {
        if (!_access.canDeleteLocation(companyHasHr: state.companyHasHr)) {
          throw const TimeTrackerPermissionDenied();
        }
        await _refuseWhileAssigned(location);
        await _locations.updateLocation(
          location: location.copyWith(status: LocationStatus.deleted),
        );
        _log.log(TimeTrackerLogService.actionDeleteLocation);
      });

  /// Function Name: [assignedCount]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — employees assigned to
  /// [location] now (the page asks before Delete / Inactive).
  ///
  /// Return type: [int]
  int assignedCount(WorkLocation location) =>
      LocationFormRules.assignedEmployees(location.id, state.assignments);

  /// Re-reads the assignments: a location still holding employees is never
  /// deleted / deactivated (owner rule, 9/10/2026).
  Future<void> _refuseWhileAssigned(WorkLocation location) async {
    final int assigned =
        LocationFormRules.assignedEmployees(location.id, await _assignments.watchAssignments().first);
    if (assigned > 0) {
      throw StateError('$assigned employees are assigned to this location. Reassign them first.');
    }
  }

  /// Function Name: [planImport]
  ///
  /// Purpose: The preview of importing [grid] (first row = headings).
  ///
  /// Return type: [LocationImportPlan]
  LocationImportPlan planImport(List<List<String>> grid) =>
      LocationImportRules.plan(grid: grid, existing: state.locations);

  /// Function Name: [readImport]
  ///
  /// Purpose: Run [pick] (file picker + reader, from the data layer) and
  /// plan its grid. Never throws: an unreadable file is a result.
  ///
  /// Return type: [Future<LocationImportRead>]
  Future<LocationImportRead> readImport(Future<List<List<String>>?> Function() pick) async {
    try {
      final List<List<String>>? grid = await pick();
      if (grid == null) return const LocationImportRead.cancelled();
      return LocationImportRead.read(planImport(grid), grid: grid);
    } catch (_) {
      return const LocationImportRead.unreadable();
    }
  }

  /// Function Name: [applyImport]
  ///
  /// Purpose: Write every create / update row of [plan] (`Import_Locations`).
  /// Stops at the first failure; rows already written stay.
  ///
  /// Return type: [Future<bool>] — every row saved.
  Future<bool> applyImport(LocationImportPlan plan) => _run(() async {
        if (!_access.canImportLocations(companyHasHr: state.companyHasHr)) {
          throw const TimeTrackerPermissionDenied();
        }
        for (final LocationImportRow row in plan.writable) {
          final WorkLocation location = row.location!;
          if (row.action == LocationImportAction.create) {
            await _locations.createLocation(location: location);
            _log.log(TimeTrackerLogService.actionCreateLocation);
          } else {
            await _locations.updateLocation(location: location);
            _log.log(TimeTrackerLogService.actionEditLocation);
          }
        }
      });

  /// Function Name: [acknowledgeFailure]
  ///
  /// Purpose: The page showed the failure message.
  ///
  /// Return type: [void]
  void acknowledgeFailure() =>
      emit(state.copyWith(failure: TimeTrackerActionFailure.none));

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
    await _locSub?.cancel();
    await _asgSub?.cancel();
    return super.close();
  }
}
