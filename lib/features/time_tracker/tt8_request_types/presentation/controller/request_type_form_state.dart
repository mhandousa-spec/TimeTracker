/// Module: time_tracker / tt8_request_types / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_form_state.dart
/// Purpose: Declares `RequestTypeFormState` (+ `RequestTypeFormStatus`) —
///          the Creating / Editing Request Type draft, its two availability
///          switches and whether its errors are shown.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:43870` / `661:44042`. Create grey until valid; Save grey until
/// something changed; a tap on the grey button reveals the errors (owner
/// rules). One immutable state + `copyWith` + derived getters.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_type_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';

enum RequestTypeFormStatus { editing, saving, saved, failure }

class RequestTypeFormState {
  const RequestTypeFormState({
    required this.draft,
    this.original,
    this.limitLocations = false,
    this.limitDepartments = false,
    this.status = RequestTypeFormStatus.editing,
    this.showErrors = false,
    this.failure = TimeTrackerActionFailure.none,
  });

  final RequestType draft;
  final RequestType? original;
  final bool limitLocations;
  final bool limitDepartments;
  final RequestTypeFormStatus status;
  final bool showErrors;
  final TimeTrackerActionFailure failure;

  bool get isEdit => original != null;

  Set<RequestTypeFormError> get errors => RequestTypeFormRules.validate(
        draft,
        limitLocations: limitLocations,
        limitDepartments: limitDepartments,
      );

  bool get isDirty {
    final RequestType? b = original;
    if (b == null) return true;
    String key(RequestType t) => <Object>[
          t.nameEn.trim(), t.nameAr.trim(), t.descriptionEn.trim(), t.descriptionAr.trim(),
          t.isHrApprovalRequired, t.isManagerApprovalRequired, t.isDescriptionRequired,
          t.isAttachmentRequired, t.isDeductedFromVacationBalance,
          (List<String>.of(t.locationIds)..sort()).join(','),
          (List<String>.of(t.departmentIds)..sort()).join(','), t.status.storageKey,
        ].join('|');
    return key(draft) != key(b);
  }

  bool get canSubmit => errors.isEmpty && isDirty && status != RequestTypeFormStatus.saving;

  bool shows(RequestTypeFormError e) => showErrors && errors.contains(e);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestTypeFormState]
  RequestTypeFormState copyWith({
    RequestType? draft,
    bool? limitLocations,
    bool? limitDepartments,
    RequestTypeFormStatus? status,
    bool? showErrors,
    TimeTrackerActionFailure? failure,
  }) =>
      RequestTypeFormState(
        draft: draft ?? this.draft,
        original: original,
        limitLocations: limitLocations ?? this.limitLocations,
        limitDepartments: limitDepartments ?? this.limitDepartments,
        status: status ?? this.status,
        showErrors: showErrors ?? this.showErrors,
        failure: failure ?? this.failure,
      );
}
