// ***************************** FILE INFO ***************************** //
// File Name: salary_bulk_upload_cubit.dart
// Purpose: Coordinates salary workbook validation and submission.
// Author: Mohamed Elrashidy
// Created At: 2026-08-19
// ********************************************************************* //

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../generated/l10n.dart';
import '../../../shared/bulk_upload/bulk_upload_file_data_source.dart';
import '../../../shared/bulk_upload/bulk_upload_template.dart';
import '../../data/models/salary_bulk_upload_models.dart';
import '../../data/repository/salary_bulk_upload_repository.dart';
import '../../domain/use_case/validate_salary_bulk_upload.dart';
import '../../utils/salary_bulk_upload_headers.dart';

sealed class SalaryBulkStatus {
  const SalaryBulkStatus();
}

final class SalaryBulkInitial extends SalaryBulkStatus {
  const SalaryBulkInitial();
}

final class SalaryBulkWorking extends SalaryBulkStatus {
  const SalaryBulkWorking();
}

final class SalaryBulkEditing extends SalaryBulkStatus {
  const SalaryBulkEditing();
}

final class SalaryBulkReady extends SalaryBulkStatus {
  const SalaryBulkReady();
}

final class SalaryBulkSubmitting extends SalaryBulkStatus {
  const SalaryBulkSubmitting();
}

final class SalaryBulkCompleted extends SalaryBulkStatus {
  const SalaryBulkCompleted();
}

final class SalaryBulkPartial extends SalaryBulkStatus {
  const SalaryBulkPartial();
}

final class SalaryBulkFailed extends SalaryBulkStatus {
  const SalaryBulkFailed();
}

/// Immutable state exposed by the salary upload page.
class SalaryBulkState {
  const SalaryBulkState({
    this.status = const SalaryBulkInitial(),
    this.file,
    this.message,
    this.updated = 0,
    this.failed = 0,
    this.result,
    this.selectedRows = const {},
    this.focusedError,
  });

  final SalaryBulkStatus status;
  final BulkUploadFile? file;
  final String? message;
  final int updated;
  final int failed;
  final SalaryBulkUploadCommitResult? result;
  final Set<int> selectedRows;
  final BulkUploadCellError? focusedError;
  bool get canSubmit =>
      file != null &&
      file!.errors.isEmpty &&
      file!.rows.isNotEmpty &&
      status is! SalaryBulkSubmitting;

  SalaryBulkState copyWith({
    SalaryBulkStatus? status,
    BulkUploadFile? file,
    bool clearFile = false,
    String? message,
    int? updated,
    int? failed,
    SalaryBulkUploadCommitResult? result,
    Set<int>? selectedRows,
    BulkUploadCellError? focusedError,
    bool clearFocused = false,
  }) =>
      SalaryBulkState(
        status: status ?? this.status,
        file: clearFile ? null : file ?? this.file,
        message: message,
        updated: updated ?? this.updated,
        failed: failed ?? this.failed,
        result: result ?? this.result,
        selectedRows: selectedRows ?? this.selectedRows,
        focusedError: clearFocused ? null : focusedError ?? this.focusedError,
      );
}

/// Owns salary workbook editing, validation, and independent commits.
class SalaryBulkUploadCubit extends Cubit<SalaryBulkState> {
  SalaryBulkUploadCubit({
    SalaryBulkUploadRepository? repository,
    BulkUploadFileDataSource? files,
    ValidateSalaryBulkUpload? validator,
    Future<void> Function()? refreshProvider,
  })  : _repository = repository ?? SalaryBulkUploadRepository(),
        _files = files ?? const BulkUploadFileDataSource(),
        _validator = validator ?? const ValidateSalaryBulkUpload(),
        _refreshProvider = refreshProvider,
        super(const SalaryBulkState());

  final SalaryBulkUploadRepository _repository;
  final BulkUploadFileDataSource _files;
  final ValidateSalaryBulkUpload _validator;
  final Future<void> Function()? _refreshProvider;
  SalaryBulkUploadPreflight? _preflight;

  Future<void> pick(S localization) async {
    final picked = await _files.pickFile();
    if (picked?.bytes != null) {
      await parse(picked!.name, picked.bytes!, localization);
    }
  }

  Future<void> parse(String name, Uint8List bytes, S localization) async {
    emit(state.copyWith(status: const SalaryBulkWorking(), message: null));
    final parsed = _files.parse(
        fileName: name,
        bytes: bytes,
        template: SalaryBulkUploadHeaders.template);
    if (parsed case BulkUploadParsedFile(:final file)) {
      await _validate(file, localization);
    } else {
      emit(state.copyWith(
          status: const SalaryBulkFailed(),
          clearFile: true,
          message: localization.employeeBulkHeaderMismatch));
    }
  }

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
  /// Purpose: Adds an empty salary row within the workbook limit.
  Future<void> addRow(S localization) async {
    final file = state.file;
    if (file == null ||
        file.rows.length >= SalaryBulkUploadHeaders.template.maxRows) {
      return;
    }
    await _validate(
        file.copyWith(rows: [
          ...file.rows,
          BulkUploadRow.empty(
              SalaryBulkUploadHeaders.template, file.rows.length),
        ]),
        localization);
  }

  /// Method Name: [duplicateSelected]
  ///
  /// Purpose: Duplicates the selected salary row.
  Future<void> duplicateSelected(S localization) async {
    final file = state.file;
    if (file == null || state.selectedRows.length != 1) return;
    final selectedIndex = state.selectedRows.first;
    emit(state.copyWith(selectedRows: const {}));
    await _validate(
        file.copyWith(rows: [
          ...file.rows,
          file.rows[selectedIndex].renumber(file.rows.length),
        ]),
        localization);
  }

  /// Method Name: [removeSelected]
  ///
  /// Purpose: Removes selected salary rows and renumbers the remainder.
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
  /// Purpose: Toggles a row selection for workbook actions.
  void toggleRow(int index) {
    final selected = {...state.selectedRows};
    selected.contains(index) ? selected.remove(index) : selected.add(index);
    emit(state.copyWith(selectedRows: selected));
  }

  /// Method Name: [nextError]
  ///
  /// Purpose: Focuses the next validation error.
  void nextError() => _focusError(1);

  /// Method Name: [previousError]
  ///
  /// Purpose: Focuses the previous validation error.
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

  Future<void> submit(S localization) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: const SalaryBulkSubmitting(), message: null));
    final result = await _repository.commitRows(state.file!.rows);
    if (result.updatedCount > 0) {
      try {
        await _refreshProvider?.call();
      } catch (_) {
        // Persistence has already completed and must remain successful.
      }
    }
    emit(state.copyWith(
      status: result.hasFailures
          ? const SalaryBulkPartial()
          : const SalaryBulkCompleted(),
      updated: result.updatedCount,
      failed: result.failedRows.length,
      result: result,
    ));
  }

  void discard() {
    _preflight = null;
    emit(const SalaryBulkState());
  }

  Future<void> _validate(BulkUploadFile file, S localization) async {
    try {
      _preflight ??= await _repository.loadPreflight();
      final result = _validator(
          rows: file.rows, preflight: _preflight!, localization: localization);
      emit(state.copyWith(
        status: result.errors.isEmpty
            ? const SalaryBulkReady()
            : const SalaryBulkEditing(),
        file: file.copyWith(errors: result.errors),
        message: null,
        clearFocused: true,
      ));
    } catch (_) {
      emit(state.copyWith(
          status: const SalaryBulkFailed(),
          message: localization.employeeBulkPreflightFailure));
    }
  }
}
