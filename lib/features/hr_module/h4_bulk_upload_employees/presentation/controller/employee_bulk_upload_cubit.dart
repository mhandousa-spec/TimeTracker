// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_cubit.dart
// Purpose: Coordinates employee workbook editing, validation, and submission.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../../roles/r4_active_directory/data/models/department_model.dart';
import '../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../data/data_source/local_data_source/employee_bulk_upload_file_data_source.dart';
import '../../data/models/employee_bulk_upload_preflight.dart';
import '../../data/models/employee_bulk_upload_commit_result.dart';
import '../../data/models/employee_bulk_upload_file.dart';
import '../../data/models/employee_bulk_upload_row.dart';
import '../../data/repository/employee_bulk_upload_repository.dart';
import '../../domain/use_case/validate_employee_bulk_upload.dart';
import '../../utils/constants/employee_bulk_upload_headers.dart';
import '../../utils/employee_bulk_upload_failure.dart';
import 'employee_bulk_upload_state.dart';

/// Owns the full employee bulk-upload flow and its editable row state.
class EmployeeBulkUploadCubit extends Cubit<EmployeeBulkUploadState> {
  EmployeeBulkUploadCubit({
    MainCoreDepartmentCubit? departmentCubit,
    HrModuleDataCubit? hrModuleDataCubit,
    required String editorEmail,
    List<DepartmentModelPro> Function()? departmentProvider,
    Future<void> Function(bool includeDepartments)? refreshProvider,
    EmployeeBulkUploadRepository? repository,
    EmployeeBulkUploadFileDataSource? fileDataSource,
    ValidateEmployeeBulkUpload? validator,
  })  : assert(departmentCubit != null || departmentProvider != null),
        assert(hrModuleDataCubit != null || refreshProvider != null),
        _departmentProvider =
            departmentProvider ?? (() => departmentCubit!.departmentModels),
        _refreshProvider = refreshProvider ??
            ((includeDepartments) => includeDepartments
                ? hrModuleDataCubit!.refreshData()
                : hrModuleDataCubit!.refreshEmployees()),
        _editorEmail = editorEmail,
        _repository = repository ?? EmployeeBulkUploadRepository(),
        _fileDataSource =
            fileDataSource ?? const EmployeeBulkUploadFileDataSource(),
        _validator = validator ?? const ValidateEmployeeBulkUpload(),
        super(EmployeeBulkUploadState());

  final List<DepartmentModelPro> Function() _departmentProvider;
  final Future<void> Function(bool includeDepartments) _refreshProvider;
  final EmployeeBulkUploadRepository _repository;
  final EmployeeBulkUploadFileDataSource _fileDataSource;
  final ValidateEmployeeBulkUpload _validator;
  final String _editorEmail;
  EmployeeBulkUploadPreflight? _preflight;
  int _validationRequestId = 0;

  /// Method Name: [pickAndParse]
  ///
  /// Purpose: Opens the workbook picker and converts selection failures into
  /// typed, localized feedback for the bulk-upload page.
  ///
  /// Parameters:
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: Completes after selection, parsing, and initial validation.
  Future<void> pickAndParse(S localization) async {
    if (state.status is EmployeeBulkUploadSubmitting) return;
    emit(state.copyWith(
      status: const EmployeeBulkUploadPicking(),
      clearFailure: true,
    ));
    try {
      final picked = await _fileDataSource.pickFile();
      if (picked == null) {
        emit(state.copyWith(status: const EmployeeBulkUploadInitial()));
        return;
      }
      final bytes = picked.bytes;
      if (bytes == null) {
        _emitFailure(
          EmployeeBulkFileReadFailure(
            localization.employeeBulkFileReadFailure,
          ),
          localization,
          clearFile: true,
        );
        return;
      }
      emit(state.copyWith(status: const EmployeeBulkUploadParsing()));
      await parseBytes(picked.name, bytes, localization);
    } catch (_) {
      _emitFailure(
        EmployeeBulkFileReadFailure(localization.employeeBulkFileReadFailure),
        localization,
        clearFile: true,
      );
    }
  }

  /// Method Name: [parseBytes]
  ///
  /// Purpose: Parses dropped or picked workbook bytes, then begins employee
  /// validation against a fresh preflight snapshot.
  ///
  /// Parameters:
  /// - [fileName]: Original workbook file name.
  /// - [bytes]: Workbook contents.
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: Completes after the parsed file is ready or a typed failure emits.
  Future<void> parseBytes(
      String fileName, Uint8List bytes, S localization) async {
    _preflight = null;
    _validationRequestId++;
    emit(state.copyWith(
      status: const EmployeeBulkUploadParsing(),
      clearFailure: true,
    ));
    await Future<void>.delayed(Duration.zero);
    final parsed = _fileDataSource.parse(
      fileName: fileName,
      bytes: bytes,
      localization: localization,
    );
    await parsed.fold(
      (failure) async => _emitFailure(
        failure,
        localization,
        clearFile: true,
      ),
      (file) async => _validateFile(file, localization),
    );
  }

  /// Method Name: [reportDroppedFileFailure]
  ///
  /// Purpose: Presents drag-and-drop input failures through the same typed,
  /// localized flow used by picker and parser failures.
  ///
  /// Parameters:
  /// - [failure]: Safe failure describing the rejected drop action.
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: Emits a failure state without retaining a workbook.
  void reportDroppedFileFailure(
    EmployeeBulkUploadFailure failure,
    S localization,
  ) {
    _emitFailure(failure, localization, clearFile: true);
  }

  Future<void> updateCell(
      int rowIndex, String header, String value, S localization) async {
    final file = state.file;
    if (file == null || rowIndex < 0 || rowIndex >= file.rows.length) return;
    final rows = List<EmployeeBulkUploadRow>.from(file.rows);
    rows[rowIndex] = rows[rowIndex].updateValue(header, value);
    await _validateFile(file.copyWith(rows: rows), localization);
  }

  Future<void> addRow(S localization) async {
    final file = state.file;
    if (file == null || file.rows.length >= EmployeeBulkUploadHeaders.maxRows) {
      return;
    }
    final rows = List<EmployeeBulkUploadRow>.from(file.rows)
      ..add(EmployeeBulkUploadRow.empty(file.rows.length));
    await _validateFile(file.copyWith(rows: _renumber(rows)), localization);
  }

  Future<void> duplicateSelected(S localization) async {
    final file = state.file;
    if (file == null || state.selectedRows.isEmpty) return;
    final rows = List<EmployeeBulkUploadRow>.from(file.rows);
    for (final index in state.selectedRows.toList()..sort()) {
      if (rows.length >= EmployeeBulkUploadHeaders.maxRows) break;
      if (index >= 0 && index < file.rows.length) {
        rows.add(file.rows[index]);
      }
    }
    emit(state.copyWith(selectedRows: const {}));
    await _validateFile(file.copyWith(rows: _renumber(rows)), localization);
  }

  Future<void> removeSelected(S localization) async {
    final file = state.file;
    if (file == null || state.selectedRows.isEmpty) return;
    final rows = <EmployeeBulkUploadRow>[];
    for (var index = 0; index < file.rows.length; index++) {
      if (!state.selectedRows.contains(index)) rows.add(file.rows[index]);
    }
    emit(state.copyWith(selectedRows: const {}));
    if (rows.isEmpty) {
      discard();
      return;
    }
    await _validateFile(file.copyWith(rows: _renumber(rows)), localization);
  }

  void toggleRow(int rowIndex) {
    final selected = Set<int>.from(state.selectedRows);
    selected.contains(rowIndex)
        ? selected.remove(rowIndex)
        : selected.add(rowIndex);
    emit(state.copyWith(selectedRows: selected));
  }

  void focusNextError() {
    final errors = state.file?.errors ?? const [];
    if (errors.isEmpty) return;
    final current = state.focusedError;
    final index = current == null ? -1 : errors.indexOf(current);
    emit(state.copyWith(focusedError: errors[(index + 1) % errors.length]));
  }

  /// Method Name: [focusPreviousError]
  ///
  /// Purpose: Focuses the preceding invalid spreadsheet cell with wraparound.
  ///
  /// Returns: Updates the focused validation error when errors exist.
  void focusPreviousError() {
    final errors = state.file?.errors ?? const [];
    if (errors.isEmpty) return;
    final current = state.focusedError;
    final index = current == null ? 0 : errors.indexOf(current);
    final previousIndex = index <= 0 ? errors.length - 1 : index - 1;
    emit(state.copyWith(focusedError: errors[previousIndex]));
  }

  /// Method Name: [discard]
  ///
  /// Purpose: Clears the active workbook and invalidates the cached preflight
  /// data so the next import starts with a fresh lookup snapshot.
  ///
  /// Returns: Resets the upload flow to its initial state.
  void discard() {
    _preflight = null;
    _validationRequestId++;
    emit(EmployeeBulkUploadState());
  }

  /// Method Name: [submit]
  ///
  /// Purpose: Rechecks a validated workbook, commits every employee
  /// transaction independently, and reports only rows that failed to persist.
  ///
  /// Parameters:
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: Completes after the commit attempt and state update.
  Future<void> submit(S localization) async {
    if (!state.canSubmit || state.status is EmployeeBulkUploadSubmitting) {
      return;
    }
    emit(state.copyWith(
      status: const EmployeeBulkUploadSubmitting(),
      clearFailure: true,
    ));
    final result = await _repository.createEmployeesIndividually(
      rows: state.file!.rows,
      newDepartments: state.newDepartments,
      editorEmail: _editorEmail,
    );
    await result.fold(
      (failure) async => _emitFailure(failure, localization),
      (commitResult) async {
        await _refreshAfterCommit(commitResult);
        emit(state.copyWith(
          status: commitResult.hasFailures
              ? const EmployeeBulkUploadCompletedWithFailures()
              : const EmployeeBulkUploadSuccess(),
          createdEmployeeCount: commitResult.createdEmployeeCount,
          failedEmployees: commitResult.failedEmployees,
        ));
      },
    );
  }

  /// Method Name: [_refreshAfterCommit]
  ///
  /// Purpose: Refreshes locally cached employee data after at least one
  /// employee transaction succeeds without changing the import outcome.
  ///
  /// Parameters:
  /// - [commitResult]: Aggregated independent employee transaction result.
  ///
  /// Returns: Completes after an optional best-effort cache refresh.
  Future<void> _refreshAfterCommit(
    EmployeeBulkUploadCommitResult commitResult,
  ) async {
    if (commitResult.createdEmployeeCount == 0) return;
    try {
      await _refreshProvider(state.newDepartments.isNotEmpty);
    } catch (_) {
      // Firestore commits are already complete; a local refresh cannot undo
      // the result or change which employee rows failed.
    }
  }

  /// Method Name: [_validateFile]
  ///
  /// Purpose: Validates a workbook, loading remote lookup data only when no
  /// current preflight cache is available.
  ///
  /// Parameters:
  /// - [file]: Immutable workbook to validate.
  /// - [localization]: Localized validation-message resolver.
  ///
  /// Returns: Completes when validation or a preflight failure state emits.
  Future<void> _validateFile(
      EmployeeBulkUploadFile file, S localization) async {
    final validationRequestId = ++_validationRequestId;
    emit(state.copyWith(
      status: const EmployeeBulkUploadValidating(),
      file: file,
      clearFailure: true,
    ));
    final cachedPreflight = _preflight;
    if (cachedPreflight != null) {
      _applyValidation(file, cachedPreflight, localization);
      return;
    }

    final preflightResult = await _repository.loadPreflightData();
    if (isClosed || validationRequestId != _validationRequestId) return;
    preflightResult.fold(
      (failure) => _emitFailure(failure, localization, file: file),
      (preflight) {
        _preflight = preflight;
        _applyValidation(file, preflight, localization);
      },
    );
  }

  List<EmployeeBulkUploadRow> _renumber(List<EmployeeBulkUploadRow> rows) =>
      List.generate(rows.length, (index) => rows[index].renumber(index));

  /// Method Name: [_applyValidation]
  ///
  /// Purpose: Applies local employee validation from an already loaded
  /// preflight snapshot, avoiding a remote lookup on every keystroke.
  ///
  /// Parameters:
  /// - [file]: Immutable workbook to validate.
  /// - [preflight]: Cached employee and role lookup data.
  /// - [localization]: Localized validation-message resolver.
  ///
  /// Returns: Emits ready or editing state with normalized rows and errors.
  void _applyValidation(
    EmployeeBulkUploadFile file,
    EmployeeBulkUploadPreflight preflight,
    S localization,
  ) {
    final result = _validator(
      rows: file.rows,
      preflight: preflight,
      departments: _departmentProvider(),
      editorEmail: _editorEmail,
      localization: localization,
    );
    emit(state.copyWith(
      status: result.isValid
          ? const EmployeeBulkUploadReady()
          : const EmployeeBulkUploadEditing(),
      file: file.copyWith(rows: result.rows, errors: result.errors),
      newDepartments: result.newDepartments,
      clearFocusedError: true,
      clearFailure: true,
    ));
  }

  /// Method Name: [_emitFailure]
  ///
  /// Purpose: Translates a boundary failure into safe typed state for the
  /// feature's service-style error UI.
  ///
  /// Parameters:
  /// - [failure]: Typed file, lookup, or persistence failure.
  /// - [localization]: Localized failure-message resolver.
  /// - [file]: Optional workbook retained after a later-stage failure.
  /// - [clearFile]: Whether the failure invalidates the current workbook.
  ///
  /// Returns: Emits [EmployeeBulkUploadFailureStatus].
  void _emitFailure(
    EmployeeBulkUploadFailure failure,
    S localization, {
    EmployeeBulkUploadFile? file,
    bool clearFile = false,
  }) {
    emit(state.copyWith(
      status: const EmployeeBulkUploadFailureStatus(),
      file: file,
      clearFile: clearFile,
      failure: failure,
      failureMessage: _failureMessage(failure, localization),
    ));
  }

  /// Method Name: [_failureMessage]
  ///
  /// Purpose: Maps typed failures to safe, localized HR messages instead of
  /// exposing low-level file-picker or Firestore exception text.
  ///
  /// Parameters:
  /// - [failure]: Typed operation failure.
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: A user-displayable failure message.
  String _failureMessage(EmployeeBulkUploadFailure failure, S localization) {
    return switch (failure) {
      EmployeeBulkUnsupportedFileFailure() =>
        localization.employeeBulkUnsupportedFile,
      EmployeeBulkNoDroppedFileFailure() =>
        localization.employeeBulkNoDroppedFiles,
      EmployeeBulkFileReadFailure() => localization.employeeBulkFileReadFailure,
      EmployeeBulkCorruptWorkbookFailure() =>
        localization.employeeBulkInvalidWorkbook,
      EmployeeBulkEmptyWorkbookFailure() => failure.message,
      EmployeeBulkHeaderFailure() => localization.employeeBulkHeaderMismatch,
      EmployeeBulkRowLimitFailure() => localization.employeeBulkRowLimit,
      EmployeeBulkDuplicateEmployeeFailure() =>
        localization.employeeBulkExistingEmployeeId,
      EmployeeBulkDuplicateEmailFailure() =>
        localization.employeeBulkExistingEmail,
      EmployeeBulkRoleLookupFailure() => localization.employeeBulkRoleNotFound,
      EmployeeBulkDepartmentConflictFailure() =>
        localization.employeeBulkDepartmentConflict,
      EmployeeBulkPreflightFailure() =>
        localization.employeeBulkPreflightFailure,
      EmployeeBulkInvalidDataFailure() => localization.employeeBulkRowLimit,
      _ => localization.employeeBulkUploadFailure,
    };
  }

  /// Method Name: [failureMessageFor]
  ///
  /// Purpose: Resolves a safe localized message for a row-level commit failure
  /// shown by the presentation layer.
  ///
  /// Parameters:
  /// - [failure]: Typed persistence failure for one employee row.
  /// - [localization]: Localized message resolver.
  ///
  /// Returns: A user-displayable failure message.
  String failureMessageFor(
    EmployeeBulkUploadFailure failure,
    S localization,
  ) =>
      _failureMessage(failure, localization);
}
