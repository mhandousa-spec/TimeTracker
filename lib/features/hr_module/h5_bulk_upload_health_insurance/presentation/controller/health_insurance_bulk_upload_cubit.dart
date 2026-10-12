// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_bulk_upload_cubit.dart
// Purpose: Owns health-insurance spreadsheet upload interaction state.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_file_data_source.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../data/models/health_insurance_bulk_upload_models.dart';
import '../../data/repository/health_insurance_bulk_upload_repository.dart';
import '../../domain/use_case/validate_health_insurance_bulk_upload.dart';
import '../../utils/health_insurance_bulk_upload_headers.dart';

sealed class HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadStatus();
}

final class HealthInsuranceBulkUploadInitial
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadInitial();
}

final class HealthInsuranceBulkUploadWorking
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadWorking();
}

final class HealthInsuranceBulkUploadEditing
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadEditing();
}

final class HealthInsuranceBulkUploadReady
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadReady();
}

final class HealthInsuranceBulkUploadSubmitting
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadSubmitting();
}

final class HealthInsuranceBulkUploadSuccess
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadSuccess();
}

final class HealthInsuranceBulkUploadPartial
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadPartial();
}

final class HealthInsuranceBulkUploadFailure
    extends HealthInsuranceBulkUploadStatus {
  const HealthInsuranceBulkUploadFailure();
}

/// Immutable state exposed by the health-insurance bulk-upload page.
class HealthInsuranceBulkUploadState {
  const HealthInsuranceBulkUploadState({
    this.status = const HealthInsuranceBulkUploadInitial(),
    this.file,
    this.selectedRows = const {},
    this.focusedError,
    this.message,
    this.result,
  });
  final HealthInsuranceBulkUploadStatus status;
  final BulkUploadFile? file;
  final Set<int> selectedRows;
  final BulkUploadCellError? focusedError;
  final String? message;
  final HealthInsuranceBulkUploadCommitResult? result;
  bool get canSubmit =>
      file != null &&
      file!.errors.isEmpty &&
      file!.rows.isNotEmpty &&
      status is! HealthInsuranceBulkUploadSubmitting;
  HealthInsuranceBulkUploadState copyWith(
          {HealthInsuranceBulkUploadStatus? status,
          BulkUploadFile? file,
          bool clearFile = false,
          Set<int>? selectedRows,
          BulkUploadCellError? focusedError,
          bool clearFocused = false,
          String? message,
          bool clearMessage = false,
          HealthInsuranceBulkUploadCommitResult? result}) =>
      HealthInsuranceBulkUploadState(
        status: status ?? this.status,
        file: clearFile ? null : file ?? this.file,
        selectedRows: selectedRows ?? this.selectedRows,
        focusedError: clearFocused ? null : focusedError ?? this.focusedError,
        message: clearMessage ? null : message ?? this.message,
        result: result ?? this.result,
      );
}

/// Feature controller built around the shared HR workbook parser and models.
class HealthInsuranceBulkUploadCubit
    extends Cubit<HealthInsuranceBulkUploadState> {
  HealthInsuranceBulkUploadCubit(
      {HealthInsuranceBulkUploadRepository? repository,
      BulkUploadFileDataSource? fileDataSource,
      ValidateHealthInsuranceBulkUpload? validator})
      : _repository = repository ?? HealthInsuranceBulkUploadRepository(),
        _fileDataSource = fileDataSource ?? const BulkUploadFileDataSource(),
        _validator = validator ?? const ValidateHealthInsuranceBulkUpload(),
        super(const HealthInsuranceBulkUploadState());
  final HealthInsuranceBulkUploadRepository _repository;
  final BulkUploadFileDataSource _fileDataSource;
  final ValidateHealthInsuranceBulkUpload _validator;
  HealthInsuranceBulkUploadPreflight? _preflight;

  Future<void> pickAndParse(S l10n) async {
    emit(state.copyWith(
        status: const HealthInsuranceBulkUploadWorking(), clearMessage: true));
    final picked = await _fileDataSource.pickFile();
    if (picked?.bytes == null) {
      emit(const HealthInsuranceBulkUploadState());
      return;
    }
    await parseBytes(picked!.name, picked.bytes!, l10n);
  }

  Future<void> parseBytes(String name, Uint8List bytes, S l10n) async {
    emit(state.copyWith(
        status: const HealthInsuranceBulkUploadWorking(), clearMessage: true));
    final parsed = _fileDataSource.parse(
        fileName: name,
        bytes: bytes,
        template: HealthInsuranceBulkUploadHeaders.template);
    switch (parsed) {
      case BulkUploadParsedFile(:final file):
        await _validate(file, l10n);
      case BulkUploadParseFailure(:final code):
        emit(state.copyWith(
            status: const HealthInsuranceBulkUploadFailure(),
            message: _parseMessage(code, l10n),
            clearFile: true));
    }
  }

  Future<void> updateCell(
      int index, String header, String value, S l10n) async {
    final file = state.file;
    if (file == null) return;
    final rows = [...file.rows];
    rows[index] = rows[index].updateValue(header, value);
    await _validate(file.copyWith(rows: rows), l10n);
  }

  Future<void> addRow(S l10n) async {
    final file = state.file;
    if (file == null ||
        file.rows.length >= HealthInsuranceBulkUploadHeaders.template.maxRows) {
      return;
    }
    await _validate(
        file.copyWith(rows: [
          ...file.rows,
          BulkUploadRow.empty(
              HealthInsuranceBulkUploadHeaders.template, file.rows.length)
        ]),
        l10n);
  }

  Future<void> removeSelected(S l10n) async {
    final file = state.file;
    if (file == null) return;
    final retained = [
      for (var i = 0; i < file.rows.length; i++)
        if (!state.selectedRows.contains(i)) file.rows[i]
    ];
    final rows = [
      for (var i = 0; i < retained.length; i++) retained[i].renumber(i),
    ];
    if (rows.isEmpty) {
      discard();
      return;
    }
    emit(state.copyWith(selectedRows: const {}));
    await _validate(file.copyWith(rows: rows), l10n);
  }

  Future<void> duplicateSelected(S l10n) async {
    final file = state.file;
    if (file == null || state.selectedRows.length != 1) return;
    final rows = [...file.rows];
    rows.add(file.rows[state.selectedRows.first].renumber(rows.length));
    emit(state.copyWith(selectedRows: const {}));
    await _validate(file.copyWith(rows: rows), l10n);
  }

  void toggleRow(int index) {
    final values = {...state.selectedRows};
    values.contains(index) ? values.remove(index) : values.add(index);
    emit(state.copyWith(selectedRows: values));
  }

  void discard() {
    _preflight = null;
    emit(const HealthInsuranceBulkUploadState());
  }

  void nextError() {
    final errors = state.file?.errors ?? const <BulkUploadCellError>[];
    if (errors.isEmpty) return;
    final index = state.focusedError == null
        ? 0
        : (errors.indexOf(state.focusedError!) + 1) % errors.length;
    emit(state.copyWith(focusedError: errors[index]));
  }

  void previousError() {
    final errors = state.file?.errors ?? const <BulkUploadCellError>[];
    if (errors.isEmpty) return;
    final current =
        state.focusedError == null ? 0 : errors.indexOf(state.focusedError!);
    emit(state.copyWith(
        focusedError: errors[(current - 1 + errors.length) % errors.length]));
  }

  Future<void> submit(S l10n) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: const HealthInsuranceBulkUploadSubmitting()));
    final result = await _repository.commitRows(state.file!.rows);
    emit(state.copyWith(
        status: result.hasFailures
            ? const HealthInsuranceBulkUploadPartial()
            : const HealthInsuranceBulkUploadSuccess(),
        result: result));
  }

  Future<void> _validate(BulkUploadFile file, S l10n) async {
    emit(state.copyWith(
        status: const HealthInsuranceBulkUploadWorking(), file: file));
    try {
      _preflight ??= await _repository.loadPreflight();
      final result = _validator(
          rows: file.rows, preflight: _preflight!, localization: l10n);
      emit(state.copyWith(
          status: result.errors.isEmpty
              ? const HealthInsuranceBulkUploadReady()
              : const HealthInsuranceBulkUploadEditing(),
          file: file.copyWith(rows: result.rows, errors: result.errors),
          clearFocused: true));
    } catch (_) {
      emit(state.copyWith(
          status: const HealthInsuranceBulkUploadFailure(),
          message: l10n.healthInsuranceBulkPreflightFailure));
    }
  }

  String _parseMessage(BulkUploadParseFailureCode code, S l10n) =>
      switch (code) {
        BulkUploadParseFailureCode.unsupported =>
          l10n.employeeBulkUnsupportedFile,
        BulkUploadParseFailureCode.corrupt => l10n.employeeBulkInvalidWorkbook,
        BulkUploadParseFailureCode.headers =>
          l10n.healthInsuranceBulkHeaderMismatch,
        BulkUploadParseFailureCode.rows => l10n.employeeBulkRowLimit,
        _ => l10n.employeeBulkEmptyWorkbook
      };
}
