// ***************************** FILE INFO ***************************** //
// File Name: emergency_contact_bulk_upload_cubit.dart
// Purpose: Coordinates emergency-contact workbook upload interaction.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_file_data_source.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../data/data_source/local_data_source/emergency_contact_bulk_upload_file_data_source.dart';
import '../../data/models/emergency_contact_bulk_upload_models.dart';
import '../../data/repository/emergency_contact_bulk_upload_repository.dart';
import '../../domain/use_case/validate_emergency_contact_bulk_upload.dart';
import '../../utils/emergency_contact_bulk_upload_headers.dart';

sealed class EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadStatus();
}

final class EmergencyContactBulkUploadInitial
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadInitial();
}

final class EmergencyContactBulkUploadWorking
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadWorking();
}

final class EmergencyContactBulkUploadEditing
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadEditing();
}

final class EmergencyContactBulkUploadReady
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadReady();
}

final class EmergencyContactBulkUploadSubmitting
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadSubmitting();
}

final class EmergencyContactBulkUploadSuccess
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadSuccess();
}

final class EmergencyContactBulkUploadPartial
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadPartial();
}

final class EmergencyContactBulkUploadFailure
    extends EmergencyContactBulkUploadStatus {
  const EmergencyContactBulkUploadFailure();
}

class EmergencyContactBulkUploadState {
  const EmergencyContactBulkUploadState(
      {this.status = const EmergencyContactBulkUploadInitial(),
      this.file,
      this.selectedRows = const {},
      this.focusedError,
      this.message,
      this.result});
  final EmergencyContactBulkUploadStatus status;
  final BulkUploadFile? file;
  final Set<int> selectedRows;
  final BulkUploadCellError? focusedError;
  final String? message;
  final EmergencyContactBulkUploadCommitResult? result;
  bool get canSubmit =>
      file != null &&
      file!.errors.isEmpty &&
      file!.rows.isNotEmpty &&
      status is! EmergencyContactBulkUploadSubmitting;
  EmergencyContactBulkUploadState copyWith(
          {EmergencyContactBulkUploadStatus? status,
          BulkUploadFile? file,
          bool clearFile = false,
          Set<int>? selectedRows,
          BulkUploadCellError? focusedError,
          bool clearFocused = false,
          String? message,
          bool clearMessage = false,
          EmergencyContactBulkUploadCommitResult? result}) =>
      EmergencyContactBulkUploadState(
          status: status ?? this.status,
          file: clearFile ? null : file ?? this.file,
          selectedRows: selectedRows ?? this.selectedRows,
          focusedError: clearFocused ? null : focusedError ?? this.focusedError,
          message: clearMessage ? null : message ?? this.message,
          result: result ?? this.result);
}

/// Owns parsing, validation, preview editing, and row submission.
class EmergencyContactBulkUploadCubit
    extends Cubit<EmergencyContactBulkUploadState> {
  EmergencyContactBulkUploadCubit(
      {EmergencyContactBulkUploadRepository? repository,
      EmergencyContactBulkUploadFileDataSource? fileDataSource,
      ValidateEmergencyContactBulkUpload? validator,
      Future<void> Function()? refreshProvider})
      : _repository = repository ?? EmergencyContactBulkUploadRepository(),
        _fileDataSource =
            fileDataSource ?? const EmergencyContactBulkUploadFileDataSource(),
        _validator = validator ?? const ValidateEmergencyContactBulkUpload(),
        _refreshProvider = refreshProvider,
        super(const EmergencyContactBulkUploadState());
  final EmergencyContactBulkUploadRepository _repository;
  final EmergencyContactBulkUploadFileDataSource _fileDataSource;
  final ValidateEmergencyContactBulkUpload _validator;
  final Future<void> Function()? _refreshProvider;
  EmergencyContactBulkUploadPreflight? _preflight;

  Future<void> pickAndParse(S l10n) async {
    final file = await _fileDataSource.pickFile();
    if (file?.bytes == null) return;
    await parseBytes(file!.name, file.bytes!, l10n);
  }

  Future<void> parseBytes(String name, Uint8List bytes, S l10n) async {
    emit(state.copyWith(
        status: const EmergencyContactBulkUploadWorking(), clearMessage: true));
    final parsed = _fileDataSource.parse(fileName: name, bytes: bytes);
    switch (parsed) {
      case BulkUploadParsedFile(:final file):
        _preflight ??= await _repository.loadPreflight();
        final result = _validator(
            rows: file.rows, preflight: _preflight!, localization: l10n);
        emit(state.copyWith(
            status: result.errors.isEmpty
                ? const EmergencyContactBulkUploadReady()
                : const EmergencyContactBulkUploadEditing(),
            file: file.copyWith(errors: result.errors),
            clearFocused: true));
      case BulkUploadParseFailure():
        emit(state.copyWith(
            status: const EmergencyContactBulkUploadFailure(),
            message: l10n.employeeBulkInvalidWorkbook,
            clearFile: true));
    }
  }

  Future<void> updateCell(
      int index, String header, String value, S l10n) async {
    final file = state.file;
    if (file == null || index < 0 || index >= file.rows.length) return;
    final rows = [...file.rows];
    rows[index] = rows[index].updateValue(header, value);
    final result =
        _validator(rows: rows, preflight: _preflight!, localization: l10n);
    emit(state.copyWith(
        status: result.errors.isEmpty
            ? const EmergencyContactBulkUploadReady()
            : const EmergencyContactBulkUploadEditing(),
        file: file.copyWith(rows: result.rows, errors: result.errors),
        clearFocused: true));
  }

  /// Method Name: [addRow]
  ///
  /// Purpose: Adds an empty emergency-contact row within the workbook limit.
  Future<void> addRow(S l10n) async {
    final file = state.file;
    if (file == null ||
        file.rows.length >=
            EmergencyContactBulkUploadHeaders.template.maxRows) {
      return;
    }
    final result = _validator(
      rows: [
        ...file.rows,
        BulkUploadRow.empty(
            EmergencyContactBulkUploadHeaders.template, file.rows.length)
      ],
      preflight: _preflight!,
      localization: l10n,
    );
    emit(state.copyWith(
        status: result.errors.isEmpty
            ? const EmergencyContactBulkUploadReady()
            : const EmergencyContactBulkUploadEditing(),
        file: file.copyWith(rows: result.rows, errors: result.errors),
        clearFocused: true));
  }

  /// Method Name: [duplicateSelected]
  ///
  /// Purpose: Duplicates the selected emergency-contact row.
  Future<void> duplicateSelected(S l10n) async {
    final file = state.file;
    if (file == null || state.selectedRows.length != 1) return;
    final selectedIndex = state.selectedRows.first;
    emit(state.copyWith(selectedRows: const {}));
    final result = _validator(
      rows: [...file.rows, file.rows[selectedIndex].renumber(file.rows.length)],
      preflight: _preflight!,
      localization: l10n,
    );
    emit(state.copyWith(
        status: result.errors.isEmpty
            ? const EmergencyContactBulkUploadReady()
            : const EmergencyContactBulkUploadEditing(),
        file: file.copyWith(rows: result.rows, errors: result.errors),
        clearFocused: true));
  }

  /// Method Name: [removeSelected]
  ///
  /// Purpose: Removes selected emergency-contact rows.
  Future<void> removeSelected(S l10n) async {
    final file = state.file;
    if (file == null) return;
    final retained = [
      for (var index = 0; index < file.rows.length; index++)
        if (!state.selectedRows.contains(index)) file.rows[index],
    ];
    if (retained.isEmpty) return discard();
    emit(state.copyWith(selectedRows: const {}));
    final result = _validator(
      rows: [
        for (var index = 0; index < retained.length; index++)
          retained[index].renumber(index)
      ],
      preflight: _preflight!,
      localization: l10n,
    );
    emit(state.copyWith(
        status: result.errors.isEmpty
            ? const EmergencyContactBulkUploadReady()
            : const EmergencyContactBulkUploadEditing(),
        file: file.copyWith(rows: result.rows, errors: result.errors),
        clearFocused: true));
  }

  void toggleRow(int index) {
    final selected = {...state.selectedRows};
    selected.contains(index) ? selected.remove(index) : selected.add(index);
    emit(state.copyWith(selectedRows: selected));
  }

  /// Method Name: [nextError]
  ///
  /// Purpose: Focuses the next emergency-contact validation error.
  void nextError() => _focusError(1);

  /// Method Name: [previousError]
  ///
  /// Purpose: Focuses the previous emergency-contact validation error.
  void previousError() => _focusError(-1);

  void _focusError(int direction) {
    final errors = state.file?.errors ?? const <BulkUploadCellError>[];
    if (errors.isEmpty) return;
    final current =
        state.focusedError == null ? 0 : errors.indexOf(state.focusedError!);
    emit(state.copyWith(
        focusedError:
            errors[(current + direction + errors.length) % errors.length]));
  }

  void discard() {
    _preflight = null;
    emit(const EmergencyContactBulkUploadState());
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: const EmergencyContactBulkUploadSubmitting()));
    final result = await _repository.commitRows(state.file!.rows);
    if (result.updatedCount > 0) await _refreshProvider?.call();
    emit(state.copyWith(
        status: result.hasFailures
            ? const EmergencyContactBulkUploadPartial()
            : const EmergencyContactBulkUploadSuccess(),
        result: result));
  }
}
