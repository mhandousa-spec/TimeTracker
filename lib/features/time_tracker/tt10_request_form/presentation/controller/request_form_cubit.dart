/// Module: time_tracker / tt10_request_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: request_form_cubit.dart
/// Purpose: Declares `RequestFormCubit` — the "Creating New Request" draft:
///          loads what the form offers, the field changes, validation, the
///          attachment uploads and the submit.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase-4 brief §A. Submit goes through `RequestService`
/// (`Create_Time_Tracker_Request` gate, direct-manager → HR routing,
/// balance check, notifications, System Log). Attachments reuse the
/// phase-2 upload (`AttachmentBaseRepository`, 10 MB, core
/// `MediaPickerService`). The page owns the text controller; the cubit owns
/// the draft (playbook §3). Async work in [init]; emit-after-close guarded.
/// Updated: 9/10/2026 - code review: validation includes the employee's own
/// requests (overlap) and the missing-balance rule (finding 10).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): one balance per year;
/// owner round 9 option b — a draft spanning two years is checked against
/// EACH year's balance (`RequestFormRules.shortfall`).
/// Updated: 9/10/2026 - QA KP-TT-012: [pickAndUpload] is single-flight
/// (`TimeTrackerFilePickGuard`) and shows the upload spinner while picking.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/attachment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_file_pick_guard.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt10_request_form/presentation/controller/request_form_state.dart';

class RequestFormCubit extends Cubit<RequestFormState> {
  RequestFormCubit({
    required RequestService service,
    required AttachmentBaseRepository attachments,
    required TimeTrackerAccess access,
    Future<PickedFileData?> Function()? pickFile,
  })  : _service = service,
        _attachments = attachments,
        _access = access,
        _pickFile = pickFile ?? MediaPickerService().pickAnyFile,
        super(const RequestFormState());

  final RequestService _service;
  final AttachmentBaseRepository _attachments;
  final TimeTrackerAccess _access;
  final Future<PickedFileData?> Function() _pickFile;

  @override
  void emit(RequestFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  RequestFormState _revalidated(RequestFormState next) => next.copyWith(
        errors: RequestFormRules.validate(
          next.draft,
          balance: next.setup.balanceForDraft(next.draft),
          balances: next.setup.balances,
          schedule: next.setup.schedule,
          ownRequests: next.setup.ownRequests,
        ),
      );

  void _update(RequestDraft draft) => emit(_revalidated(state.copyWith(draft: draft)));

  /// Function Name: [init]
  ///
  /// Purpose: Load the types the employee may pick, their balance and
  /// schedule.
  ///
  /// Return type: [Future<void>]
  Future<void> init() async {
    emit(_revalidated(state));
    try {
      final RequestFormSetup setup = await _service.loadFormSetup();
      emit(_revalidated(state.copyWith(setupReady: true, setup: setup)));
    } catch (error) {
      // No types offered → the form says so; Submit stays grey.
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  /// Function Name: [typeChanged] … [endTimeChanged]
  ///
  /// Purpose: One field changed (times are minutes since midnight).
  ///
  /// Return type: [void]
  void typeChanged(RequestType type) => _update(state.draft.copyWith(type: type));
  void descriptionChanged(String value) => _update(state.draft.copyWith(description: value));
  void startDateChanged(DateTime value) => _update(state.draft.copyWith(startDate: value));
  void endDateChanged(DateTime value) => _update(state.draft.copyWith(endDate: value));
  void allDayChanged(bool value) => _update(state.draft.copyWith(isAllDay: value));
  void startTimeChanged(int minutes) => _update(state.draft.copyWith(startMinutes: minutes));
  void endTimeChanged(int minutes) => _update(state.draft.copyWith(endMinutes: minutes));

  /// Function Name: [revealErrors]
  ///
  /// Purpose: Tap on the grey Submit — show every problem.
  ///
  /// Return type: [bool] — true when the draft is valid.
  bool revealErrors() {
    final RequestFormState next = _revalidated(state);
    emit(next.copyWith(showErrors: true));
    return next.errors.isEmpty;
  }

  /// Function Name: [pickAndUpload]
  ///
  /// Purpose: "Upload Attachment" — pick a file, then upload it.
  ///
  /// Return type: [Future<void>]
  Future<void> pickAndUpload() async {
    // QA KP-TT-012 (9/10/2026): ONE pick at a time — a second tap / call
    // while the picker or the upload runs is ignored (it used to open a
    // second native picker: "multiple_request, Cancelled by a second
    // request"); the Upload button shows the spinner meanwhile.
    if (!state.canAddAttachment || state.isUploading || TimeTrackerFilePickGuard.isBusy) return;
    emit(state.copyWith(isUploading: true, uploadFailed: false, fileTooLarge: false));
    final PickedFileData? picked;
    try {
      picked = await TimeTrackerFilePickGuard.run(_pickFile);
    } catch (error) {
      emit(state.copyWith(isUploading: false, uploadFailed: true, errorMessage: error.toString()));
      return;
    }
    if (picked == null) {
      emit(state.copyWith(isUploading: false));
      return;
    }
    await uploadAttachment(picked.name, picked.bytes);
  }

  /// Function Name: [uploadAttachment]
  ///
  /// Purpose: Upload one picked file and add it to the draft.
  ///
  /// Return type: [Future<void>]
  Future<void> uploadAttachment(String fileName, List<int> bytes) async {
    if (bytes.length > AttachmentBaseRepository.maxSizeBytes) {
      emit(state.copyWith(fileTooLarge: true, uploadFailed: false, isUploading: false));
      return;
    }
    emit(state.copyWith(isUploading: true, uploadFailed: false, fileTooLarge: false));
    try {
      final RequestAttachment file = await _attachments.uploadRequestAttachment(
        employeeEmail: _access.currentUserEmail,
        fileName: fileName,
        bytes: bytes,
      );
      emit(_revalidated(state.copyWith(
        isUploading: false,
        draft: state.draft.copyWith(
          attachments: List<RequestAttachment>.unmodifiable(
            <RequestAttachment>[...state.draft.attachments, file],
          ),
        ),
      )));
    } catch (error) {
      emit(state.copyWith(
        isUploading: false,
        uploadFailed: true,
        fileTooLarge: error.toString().contains(AttachmentRepositoryImpl.tooLarge),
      ));
    }
  }

  /// Function Name: [removeAttachment]
  ///
  /// Purpose: The red ⊖ on file [index].
  ///
  /// Return type: [void]
  void removeAttachment(int index) {
    final List<RequestAttachment> files = List<RequestAttachment>.of(state.draft.attachments);
    if (index < 0 || index >= files.length) return;
    files.removeAt(index);
    _update(state.draft.copyWith(attachments: List<RequestAttachment>.unmodifiable(files)));
  }

  /// Function Name: [submit]
  ///
  /// Purpose: Create the request (after the confirm dialog).
  ///
  /// Return type: [Future<bool>] — true when it was stored.
  Future<bool> submit({required bool isArabic}) async {
    final RequestFormState valid = _revalidated(state);
    if (valid.errors.isNotEmpty) {
      emit(valid.copyWith(showErrors: true));
      return false;
    }
    emit(valid.copyWith(status: RequestFormStatus.submitting, errorMessage: ''));
    try {
      await _service.submit(state.draft, setup: state.setup, isArabic: isArabic);
      emit(state.copyWith(status: RequestFormStatus.success));
      return true;
    } catch (error) {
      emit(state.copyWith(
        status: RequestFormStatus.failure,
        permissionDenied: error is TimeTrackerPermissionDenied,
        errorMessage: error.toString(),
      ));
      return false;
    }
  }

  /// Function Name: [acknowledgeFailure]
  ///
  /// Purpose: Back to editing after the failure message was shown.
  ///
  /// Return type: [void]
  void acknowledgeFailure() =>
      emit(state.copyWith(status: RequestFormStatus.editing, permissionDenied: false));
}
