/// Module: time_tracker / tt4_transaction_form / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_form_cubit.dart
/// Purpose: Declares `TransactionFormCubit` — the "Creating Transaction"
///          draft: picks, validation, the document upload and the submit.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Submit goes through `TransactionService` (Request_Transaction gate,
/// direct-manager → HR routing, System Log). The page owns the text
/// controller and the picked TIMES; the cubit owns the draft (playbook §3).
/// Emit-after-close guarded.
/// Updated: 9/10/2026 - code review finding 6: [init] loads whether the
/// employee's shift crosses midnight; the draft is validated with the
/// same-day / next-day (overnight) / 24-hour rule.
/// Updated: 9/10/2026 - QA KP-TT-012: [pickAndUpload] is single-flight
/// (`TimeTrackerFilePickGuard`) and shows the upload spinner while picking.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/attachment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_file_pick_guard.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_state.dart';

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required TransactionService service,
    required AttachmentBaseRepository attachments,
    required TimeTrackerAccess access,
    DateTime Function() clock = DateTime.now,
    Future<PickedFileData?> Function()? pickFile,
  })  : _service = service,
        _attachments = attachments,
        _access = access,
        _clock = clock,
        _pickFile = pickFile ?? MediaPickerService().pickAnyFile,
        super(TransactionFormState(errors: _validate(null, null, '', clock())));

  final TransactionService _service;
  final AttachmentBaseRepository _attachments;
  final TimeTrackerAccess _access;
  final DateTime Function() _clock;

  /// Opens the platform file picker (core `MediaPickerService`).
  final Future<PickedFileData?> Function() _pickFile;

  @override
  void emit(TransactionFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  static Set<TransactionError> _validate(
    DateTime? checkIn,
    DateTime? checkOut,
    String description,
    DateTime now, {
    bool overnightShift = false,
  }) =>
      TransactionRules.validate(
        checkIn: checkIn,
        checkOut: checkOut,
        description: description,
        now: now,
        overnightShift: overnightShift,
      );

  TransactionFormState _revalidated(TransactionFormState next) => next.copyWith(
        errors: _validate(
          next.checkIn,
          next.checkOut,
          next.description,
          _clock(),
          overnightShift: next.overnightShift,
        ),
      );

  /// Function Name: [init]
  ///
  /// Purpose: ADDED 9/10/2026 (finding 6) — learn whether the shift crosses
  /// midnight (a next-day check-out is allowed only then).
  ///
  /// Return type: [Future<void>]
  Future<void> init() async {
    try {
      final bool overnight = (await _service.scheduleOfMe())?.isOvernight ?? false;
      emit(_revalidated(state.copyWith(overnightShift: overnight)));
    } catch (error) {
      // Unknown schedule → the strict same-day rule stays; the service
      // re-checks on submit.
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  /// Function Name: [checkInChanged] / [checkOutChanged]
  ///
  /// Purpose: A complete date + time for that end.
  ///
  /// Return type: [void]
  void checkInChanged(DateTime value) =>
      emit(_revalidated(state.copyWith(checkIn: value)));
  void checkOutChanged(DateTime value) =>
      emit(_revalidated(state.copyWith(checkOut: value)));

  /// Function Name: [descriptionChanged]
  ///
  /// Return type: [void]
  void descriptionChanged(String value) =>
      emit(_revalidated(state.copyWith(description: value)));

  /// Function Name: [revealErrors]
  ///
  /// Purpose: Tap on the disabled Submit — show every problem.
  ///
  /// Return type: [bool] — true when the draft is valid.
  bool revealErrors() {
    final TransactionFormState next = _revalidated(state);
    emit(next.copyWith(showErrors: true));
    return next.errors.isEmpty;
  }

  /// Function Name: [pickAndUpload]
  ///
  /// Purpose: "Upload Attachment" — pick a file, then upload it.
  ///
  /// Return type: [Future<void>]
  Future<void> pickAndUpload() async {
    // QA KP-TT-012 (9/10/2026): ONE pick at a time (see the request form);
    // the Upload button shows the spinner while the picker is open.
    if (state.isUploading || TimeTrackerFilePickGuard.isBusy) return;
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
  /// Purpose: Upload the picked "Transaction Document" (replaces the
  /// previous one).
  ///
  /// Parameters:
  ///   [String] fileName
  ///   [List<int>] bytes
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
      emit(state.copyWith(isUploading: false, attachment: file));
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
  /// Purpose: The red ⊖ on the file card.
  ///
  /// Return type: [void]
  void removeAttachment() => emit(state.copyWith(clearAttachment: true));

  /// Function Name: [submit]
  ///
  /// Purpose: Create the transaction (after the confirm dialog).
  ///
  /// Return type: [Future<bool>] — true when it was stored.
  Future<bool> submit() async {
    final TransactionFormState valid = _revalidated(state);
    final DateTime? checkIn = valid.checkIn;
    final DateTime? checkOut = valid.checkOut;
    if (valid.errors.isNotEmpty || checkIn == null || checkOut == null) {
      emit(valid.copyWith(showErrors: true));
      return false;
    }
    emit(valid.copyWith(status: TransactionFormStatus.submitting, errorMessage: ''));
    try {
      final RequestAttachment? file = state.attachment;
      await _service.submit(
        checkIn: checkIn,
        checkOut: checkOut,
        description: state.description,
        attachments: file == null
            ? const <RequestAttachment>[]
            : <RequestAttachment>[file],
      );
      emit(state.copyWith(status: TransactionFormStatus.success));
      return true;
    } catch (error) {
      emit(state.copyWith(
        status: TransactionFormStatus.failure,
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
  void acknowledgeFailure() => emit(state.copyWith(
        status: TransactionFormStatus.editing,
        permissionDenied: false,
      ));
}
