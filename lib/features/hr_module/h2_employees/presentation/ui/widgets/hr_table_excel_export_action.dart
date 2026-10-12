// ***************************** FILE INFO ***************************** //
// File Name: hr_table_excel_export_action.dart
// Purpose: Exports HR table rows with standard loading and result feedback.
// Author: Mohamed Elrashidy
// Created At: 2026-08-29
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../generated/l10n.dart';
import '../../../utils/employee_excel_exporter.dart';

/// Coordinates one HR table export and prevents duplicate submissions.
class HrTableExcelExportAction {
  final EmployeeExcelExporter _excelExporter = EmployeeExcelExporter();
  bool _isExporting = false;

  /// Method Name: [export]
  ///
  /// Purpose: Saves table values to Excel and presents standardized feedback.
  ///
  /// Parameters:
  /// - [context]: Provides localization and dialog presentation.
  /// - [headers]: Ordered spreadsheet column labels.
  /// - [rows]: Table rows aligned with [headers].
  /// - [fileName]: Download file name without its extension.
  ///
  /// Returns: Completes after the export result feedback is displayed.
  Future<void> export({
    required BuildContext context,
    required List<String> headers,
    required List<List<String>> rows,
    required String fileName,
  }) async {
    if (_isExporting) return;

    _isExporting = true;
    final localization = S.of(context);
    var succeeded = false;
    unawaited(showLoadingIndicator());
    try {
      await _excelExporter.export(
        headers: headers,
        rows: rows,
        fileName: fileName,
      );
      succeeded = true;
    } catch (_) {
      succeeded = false;
    } finally {
      hideLoadingIndicator();
      _isExporting = false;
    }

    if (!context.mounted) return;
    if (succeeded) {
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/successful.json',
        title: localization.downloadSuccessTitle,
        subtitle: localization.successDownloadFile,
      );
      return;
    }
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      title: localization.downloadFailed,
      subtitle: localization.failedToDownloadFile,
    );
  }
}
