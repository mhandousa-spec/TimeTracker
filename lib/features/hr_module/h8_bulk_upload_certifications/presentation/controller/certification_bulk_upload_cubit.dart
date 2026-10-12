// ***************************** FILE INFO ***************************** //
// File Name: certification_bulk_upload_cubit.dart
// Purpose: Coordinates certification workbook editing and submission.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_file_data_source.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../data/models/certification_bulk_upload_models.dart';
import '../../data/repository/certification_bulk_upload_repository.dart';
import '../../domain/use_case/validate_certification_bulk_upload.dart';
import '../../utils/certification_bulk_upload_headers.dart';

sealed class CertificationBulkStatus {
  const CertificationBulkStatus();
}

final class CertificationBulkInitial extends CertificationBulkStatus {
  const CertificationBulkInitial();
}

final class CertificationBulkWorking extends CertificationBulkStatus {
  const CertificationBulkWorking();
}

final class CertificationBulkEditing extends CertificationBulkStatus {
  const CertificationBulkEditing();
}

final class CertificationBulkReady extends CertificationBulkStatus {
  const CertificationBulkReady();
}

final class CertificationBulkSubmitting extends CertificationBulkStatus {
  const CertificationBulkSubmitting();
}

final class CertificationBulkCompleted extends CertificationBulkStatus {
  const CertificationBulkCompleted();
}

final class CertificationBulkPartial extends CertificationBulkStatus {
  const CertificationBulkPartial();
}

final class CertificationBulkFailed extends CertificationBulkStatus {
  const CertificationBulkFailed();
}

/// Immutable state exposed by the certification workbook page.
class CertificationBulkState {
  const CertificationBulkState({
    this.status = const CertificationBulkInitial(),
    this.file,
    this.selectedRows = const {},
    this.focusedError,
    this.message,
    this.result,
  });

  final CertificationBulkStatus status;
  final BulkUploadFile? file;
  final Set<int> selectedRows;
  final BulkUploadCellError? focusedError;
  final String? message;
  final CertificationBulkUploadCommitResult? result;
  bool get canSubmit =>
      file != null &&
      file!.errors.isEmpty &&
      file!.rows.isNotEmpty &&
      status is! CertificationBulkSubmitting;

  CertificationBulkState copyWith({
    CertificationBulkStatus? status,
    BulkUploadFile? file,
    bool clearFile = false,
    Set<int>? selectedRows,
    BulkUploadCellError? focusedError,
    bool clearFocused = false,
    String? message,
    CertificationBulkUploadCommitResult? result,
  }) =>
      CertificationBulkState(
        status: status ?? this.status,
        file: clearFile ? null : file ?? this.file,
        selectedRows: selectedRows ?? this.selectedRows,
        focusedError: clearFocused ? null : focusedError ?? this.focusedError,
        message: message,
        result: result ?? this.result,
      );
}

/// Owns certification workbook parsing, validation, and row submission.
class CertificationBulkUploadCubit extends Cubit<CertificationBulkState> {
  CertificationBulkUploadCubit({
    CertificationBulkUploadRepository? repository,
    BulkUploadFileDataSource? files,
    ValidateCertificationBulkUpload? validator,
    Future<void> Function()? refreshProvider,
  })  : _repository = repository ?? CertificationBulkUploadRepository(),
        _files = files ?? const BulkUploadFileDataSource(),
        _validator = validator ?? const ValidateCertificationBulkUpload(),
        _refreshProvider = refreshProvider,
        super(const CertificationBulkState());

  final CertificationBulkUploadRepository _repository;
  final BulkUploadFileDataSource _files;
  final ValidateCertificationBulkUpload _validator;
  final Future<void> Function()? _refreshProvider;
  CertificationBulkUploadPreflight? _preflight;

  /// Method Name: [pick]
  ///
  /// Purpose: Picks a workbook and starts certification parsing.
  Future<void> pick(S localization) async {
    final picked = await _files.pickFile();
    if (picked?.bytes != null) {
      await parse(picked!.name, picked.bytes!, localization);
    }
  }

  /// Method Name: [parse]
  ///
  /// Purpose: Parses and validates a certification workbook.
  Future<void> parse(String name, Uint8List bytes, S localization) async {
    emit(state.copyWith(
        status: const CertificationBulkWorking(), message: null));
    final parsed = _files.parse(
      fileName: name,
      bytes: bytes,
      template: CertificationBulkUploadHeaders.template,
    );
    if (parsed case BulkUploadParsedFile(:final file)) {
      await _validate(file, localization);
    } else {
      emit(state.copyWith(
        status: const CertificationBulkFailed(),
        clearFile: true,
        message: localization.employeeBulkHeaderMismatch,
      ));
    }
  }

  /// Method Name: [update]
  ///
  /// Purpose: Updates one workbook cell and revalidates the workbook.
  Future<void> update(
      int index, String header, String value, S localization) async {
    final file = state.file;
    if (file == null || index < 0 || index >= file.rows.length) return;
    final rows = [...file.rows];
    rows[index] = rows[index].updateValue(header, value);
    await _validate(file.copyWith(rows: rows), localization);
  }

  /// Method Name: [addRow]
  ///
  /// Purpose: Adds an empty certification row.
  Future<void> addRow(S localization) async {
    final file = state.file;
    if (file == null ||
        file.rows.length >= CertificationBulkUploadHeaders.template.maxRows) {
      return;
    }
    await _validate(
        file.copyWith(rows: [
          ...file.rows,
          BulkUploadRow.empty(
              CertificationBulkUploadHeaders.template, file.rows.length),
        ]),
        localization);
  }

  /// Method Name: [duplicateSelected]
  ///
  /// Purpose: Duplicates the selected certification row.
  Future<void> duplicateSelected(S localization) async {
    final file = state.file;
    if (file == null || state.selectedRows.length != 1) return;
    final index = state.selectedRows.first;
    emit(state.copyWith(selectedRows: const {}));
    await _validate(
        file.copyWith(rows: [
          ...file.rows,
          file.rows[index].renumber(file.rows.length),
        ]),
        localization);
  }

  /// Method Name: [removeSelected]
  ///
  /// Purpose: Removes selected certification rows.
  Future<void> removeSelected(S localization) async {
    final file = state.file;
    if (file == null) return;
    final retained = [
      for (var index = 0; index < file.rows.length; index++)
        if (!state.selectedRows.contains(index)) file.rows[index],
    ];
    if (retained.isEmpty) return discard();
    emit(state.copyWith(selectedRows: const {}));
    await _validate(
        file.copyWith(rows: [
          for (var index = 0; index < retained.length; index++)
            retained[index].renumber(index),
        ]),
        localization);
  }

  /// Method Name: [toggleRow]
  ///
  /// Purpose: Toggles a row selection.
  void toggleRow(int index) {
    final selected = {...state.selectedRows};
    selected.contains(index) ? selected.remove(index) : selected.add(index);
    emit(state.copyWith(selectedRows: selected));
  }

  /// Method Name: [nextError]
  ///
  /// Purpose: Focuses the next certification validation error.
  void nextError() => _focusError(1);

  /// Method Name: [previousError]
  ///
  /// Purpose: Focuses the previous certification validation error.
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

  /// Method Name: [discard]
  ///
  /// Purpose: Resets the workbook and preflight cache.
  void discard() {
    _preflight = null;
    emit(const CertificationBulkState());
  }

  /// Method Name: [submit]
  ///
  /// Purpose: Commits validated rows and refreshes certification data.
  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: const CertificationBulkSubmitting()));
    final result = await _repository.commitRows(state.file!.rows);
    if (result.updatedCount > 0) await _refreshProvider?.call();
    emit(state.copyWith(
      status: result.hasFailures
          ? const CertificationBulkPartial()
          : const CertificationBulkCompleted(),
      result: result,
    ));
  }

  Future<void> _validate(BulkUploadFile file, S localization) async {
    try {
      _preflight ??= await _repository.loadPreflight();
      final result = _validator(
        rows: file.rows,
        preflight: _preflight!,
        localization: localization,
      );
      emit(state.copyWith(
        status: result.errors.isEmpty
            ? const CertificationBulkReady()
            : const CertificationBulkEditing(),
        file: file.copyWith(errors: result.errors),
        clearFocused: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: const CertificationBulkFailed(),
        message: localization.employeeBulkPreflightFailure,
      ));
    }
  }
}
