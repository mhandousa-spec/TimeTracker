/// Module: time_tracker / tt7_groups / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: group_form_cubit.dart
/// Purpose: Declares `GroupFormCubit` — the Create / Edit Group draft:
///          field updates, members, the group picture upload and the
///          reveal-errors tap. The save itself runs through
///          `EmployeesCubit.saveGroup` (which applies the group to its
///          members' assignments).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:95712` / `661:96092`. The picture goes to Firebase Storage
/// `Modules/time_tracker/Group_Images/{uploader}/` (≤ 10 MB) through
/// `AttachmentBaseRepository.uploadGroupImage`. The picker is injectable
/// for tests. Emit-after-close guarded (playbook §3).
/// Updated: 9/10/2026 - owner review: [uploadImageFile] (the core
/// `CustomImagePicker` hands over a picked file) and [markUploadFailed].
/// Updated: 9/10/2026 - QA KP-TT-012: [pickAndUploadImage] is single-flight
/// (`TimeTrackerFilePickGuard`).

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_file_pick_guard.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_state.dart';

export 'package:knowticed_plus/features/time_tracker/tt7_groups/presentation/controller/group_form_state.dart';

class GroupFormCubit extends Cubit<GroupFormState> {
  GroupFormCubit({
    required AttachmentBaseRepository attachments,
    required TimeTrackerAccess access,
    EmployeeGroup? original,
    Future<PickedFileData?> Function()? pickImage,
  })  : _attachments = attachments,
        _access = access,
        _pickImage = pickImage ?? (() => MediaPickerService().pickImage(fromCamera: false)),
        super(GroupFormState(
          // Decision 33 (9/10/2026): a new group follows its location.
          draft: original ?? const EmployeeGroup(id: '', name: '', rules: AttendanceRules.fromLocation),
          original: original,
        ));

  final AttachmentBaseRepository _attachments;
  final TimeTrackerAccess _access;
  final Future<PickedFileData?> Function() _pickImage;

  @override
  void emit(GroupFormState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [update]
  ///
  /// Purpose: Replace the draft (built by the page with `copyWith`).
  ///
  /// Return type: [void]
  void update(EmployeeGroup next) => emit(state.copyWith(draft: next));

  /// Function Name: [setMembers]
  ///
  /// Purpose: The members (lower-cased, de-duplicated).
  ///
  /// Return type: [void]
  void setMembers(List<String> emails) => emit(state.copyWith(
        draft: state.draft.copyWith(memberEmails: <String>{
          for (final String e in emails) e.trim().toLowerCase(),
        }.toList()),
      ));

  /// Function Name: [pickAndUploadImage]
  ///
  /// Purpose: Pick a picture and upload it; the URL becomes the group image.
  ///
  /// Return type: [Future<void>]
  Future<void> pickAndUploadImage() async {
    // QA KP-TT-012 (9/10/2026): one pick at a time, never during an upload.
    if (state.isUploading || TimeTrackerFilePickGuard.isBusy) return;
    final PickedFileData? picked;
    try {
      picked = await TimeTrackerFilePickGuard.run(_pickImage);
    } catch (_) {
      emit(state.copyWith(uploadFailed: true));
      return;
    }
    if (picked == null) return;
    emit(state.copyWith(isUploading: true, uploadFailed: false));
    try {
      final String url = await _attachments.uploadGroupImage(
        uploaderEmail: _access.currentUserEmail,
        fileName: picked.name,
        bytes: picked.bytes,
      );
      emit(state.copyWith(isUploading: false, draft: state.draft.copyWith(imageUrl: url)));
    } catch (_) {
      emit(state.copyWith(isUploading: false, uploadFailed: true));
    }
  }

  /// Function Name: [uploadImageFile]
  ///
  /// Purpose: ADDED 9/10/2026 — upload the picture the core image picker
  /// returned; its URL becomes the group image.
  ///
  /// Return type: [Future<void>]
  Future<void> uploadImageFile(File file) async {
    emit(state.copyWith(isUploading: true, uploadFailed: false));
    try {
      final List<int> bytes = await file.readAsBytes();
      final String url = await _attachments.uploadGroupImage(
        uploaderEmail: _access.currentUserEmail,
        fileName: file.uri.pathSegments.isEmpty ? 'group.jpg' : file.uri.pathSegments.last,
        bytes: bytes,
      );
      emit(state.copyWith(isUploading: false, draft: state.draft.copyWith(imageUrl: url)));
    } catch (_) {
      emit(state.copyWith(isUploading: false, uploadFailed: true));
    }
  }

  /// Function Name: [markUploadFailed]
  ///
  /// Purpose: The picker refused the file (format / unreadable).
  ///
  /// Return type: [void]
  void markUploadFailed() => emit(state.copyWith(isUploading: false, uploadFailed: true));

  /// Function Name: [revealErrors]
  ///
  /// Purpose: Show every field error (tap on the grey button).
  ///
  /// Return type: [bool] — the draft can be saved.
  bool revealErrors() {
    emit(state.copyWith(showErrors: true));
    return state.canSubmit;
  }
}
