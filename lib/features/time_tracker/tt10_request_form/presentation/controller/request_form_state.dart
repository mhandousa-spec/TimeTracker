/// Module: time_tracker / tt10_request_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_form_state.dart
/// Purpose: Declares `RequestFormState` (+ `RequestFormStatus`) — the
///          "Creating New Request" draft, what the form offers (types,
///          balance, schedule), the uploads and the validation errors.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:16900` (All Day on) / `661:17016` (All Day off + a file).
/// Owner rules (playbook §4b): Submit stays grey until every required field
/// is valid; a tap on the grey Submit reveals the errors ([showErrors]).

import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';

enum RequestFormStatus { editing, submitting, success, failure }

class RequestFormState {
  const RequestFormState({
    this.status = RequestFormStatus.editing,
    this.setupReady = false,
    this.setup = const RequestFormSetup(),
    this.draft = const RequestDraft(),
    this.errors = const <RequestFormError>{},
    this.showErrors = false,
    this.isUploading = false,
    this.uploadFailed = false,
    this.fileTooLarge = false,
    this.permissionDenied = false,
    this.errorMessage = '',
  });

  /// Most files one request carries.
  static const int maxAttachments = 5;

  final RequestFormStatus status;

  /// The types / balance / schedule have been loaded (the form shows at
  /// once; the Request Type list fills when they arrive).
  final bool setupReady;
  final RequestFormSetup setup;
  final RequestDraft draft;
  final Set<RequestFormError> errors;
  final bool showErrors;
  final bool isUploading;
  final bool uploadFailed;
  final bool fileTooLarge;
  final bool permissionDenied;
  final String errorMessage;

  /// Every required field is valid, the set-up is loaded and nothing is
  /// uploading.
  bool get canSubmit =>
      setupReady && errors.isEmpty && !isUploading && status != RequestFormStatus.submitting;

  bool get canAddAttachment => draft.attachments.length < maxAttachments;

  /// Whether [error] is drawn under its field.
  bool shows(RequestFormError error) => showErrors && errors.contains(error);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestFormState]
  RequestFormState copyWith({
    RequestFormStatus? status,
    bool? setupReady,
    RequestFormSetup? setup,
    RequestDraft? draft,
    Set<RequestFormError>? errors,
    bool? showErrors,
    bool? isUploading,
    bool? uploadFailed,
    bool? fileTooLarge,
    bool? permissionDenied,
    String? errorMessage,
  }) =>
      RequestFormState(
        status: status ?? this.status,
        setupReady: setupReady ?? this.setupReady,
        setup: setup ?? this.setup,
        draft: draft ?? this.draft,
        errors: errors ?? this.errors,
        showErrors: showErrors ?? this.showErrors,
        isUploading: isUploading ?? this.isUploading,
        uploadFailed: uploadFailed ?? this.uploadFailed,
        fileTooLarge: fileTooLarge ?? this.fileTooLarge,
        permissionDenied: permissionDenied ?? this.permissionDenied,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
