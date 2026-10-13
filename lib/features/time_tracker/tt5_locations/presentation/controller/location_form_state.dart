/// Module: time_tracker / tt5_locations / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: location_form_state.dart
/// Purpose: Declares `LocationFormState` (+ `LocationFormStatus`) — the
///          Create / Edit Location draft, whether its errors are shown, and
///          the "Use my current location" progress.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// One immutable state + `copyWith` + status enum + derived getters
/// (playbook §3). Owner rules: Create is grey until the draft is valid;
/// Save (edit) is grey until something changed; a tap on the grey button
/// reveals the errors ([showErrors]).

import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/location_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum LocationFormStatus { editing, saving, saved, failure }

class LocationFormState {
  const LocationFormState({
    required this.draft,
    this.original,
    this.status = LocationFormStatus.editing,
    this.showErrors = false,
    this.isLocating = false,
    this.locateIssue,
    this.failure = TimeTrackerActionFailure.none,
    this.startChosen = true,
    this.endChosen = true,
    this.needsState = false,
    this.needsCity = false,
  });

  final WorkLocation draft;

  /// The stored location being edited (null = creating).
  final WorkLocation? original;
  final LocationFormStatus status;
  final bool showErrors;
  final bool isLocating;

  /// Why "Use my current location" found nothing (null = fine).
  final DeviceLocationIssue? locateIssue;
  final TimeTrackerActionFailure failure;

  /// 13/10/2026 (owner: "why default values?"): a NEW location starts with
  /// no work times — the user picks them (false until picked).
  final bool startChosen;
  final bool endChosen;

  /// The chosen country / state has a State / City list, so one must be
  /// picked (set by the page once the address lists are loaded).
  final bool needsState;
  final bool needsCity;

  bool get isEdit => original != null;

  Set<LocationFormError> get errors => <LocationFormError>{
        ...LocationFormRules.validate(
          draft,
          requireCountry: true,
          requireState: needsState,
          requireCity: needsCity,
        ),
        if (!startChosen) LocationFormError.workStartRequired,
        if (!endChosen) LocationFormError.workEndRequired,
      }..removeAll(<LocationFormError>[
          // "Start = End" only once both were picked.
          if (!startChosen || !endChosen) LocationFormError.workTimesSame,
          if (!startChosen || !endChosen) LocationFormError.lateAfterTooLong,
        ]);

  /// Something differs from the stored location (always true when creating).
  bool get isDirty {
    final WorkLocation? before = original;
    if (before == null) return true;
    // Not an import column (approved schema `Allowed_Pause_Minutes`, 9/10/2026).
    if (before.pauseMinutes != draft.pauseMinutes) return true;
    final List<String> a = LocationImportRules.rowOf(before);
    final List<String> b = LocationImportRules.rowOf(draft);
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }

  bool get canSubmit => errors.isEmpty && isDirty && status != LocationFormStatus.saving;

  /// [error] is shown under its field.
  bool shows(LocationFormError error) => showErrors && errors.contains(error);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update. [clearLocateIssue] empties [locateIssue].
  ///
  /// Return type: [LocationFormState]
  LocationFormState copyWith({
    WorkLocation? draft,
    LocationFormStatus? status,
    bool? showErrors,
    bool? isLocating,
    DeviceLocationIssue? locateIssue,
    bool clearLocateIssue = false,
    TimeTrackerActionFailure? failure,
    bool? startChosen,
    bool? endChosen,
    bool? needsState,
    bool? needsCity,
  }) =>
      LocationFormState(
        draft: draft ?? this.draft,
        original: original,
        status: status ?? this.status,
        showErrors: showErrors ?? this.showErrors,
        isLocating: isLocating ?? this.isLocating,
        locateIssue: clearLocateIssue ? null : (locateIssue ?? this.locateIssue),
        failure: failure ?? this.failure,
        startChosen: startChosen ?? this.startChosen,
        endChosen: endChosen ?? this.endChosen,
        needsState: needsState ?? this.needsState,
        needsCity: needsCity ?? this.needsCity,
      );
}
