/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_csv_export.dart
/// Purpose: Declares `exportTimeTrackerCsv` — Export button flow for any
///          Time Tracker table: file-name dialog → CSV → the platform's save
///          sheet → success / failure message.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Module-local copy of the GRC export flow (`grc_export.dart`) built on the
/// core `CSVHelper.exportForUser` (UTF-8 BOM so Arabic opens in Excel; the
/// system save sheet on iOS / Android) and `CustomDialogManager.showExport`.
/// The app has no generic .xlsx exporter that reaches the user on iOS, so
/// CSV is used (opens in Excel / Numbers). A dismissed save sheet shows
/// nothing.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [exportTimeTrackerCsv]
///
/// Purpose: Run the export flow for [header] + [rows].
///
/// Parameters:
///   [BuildContext] context
///   [String] defaultFileName: pre-filled file name (no extension).
///   [List<String>] header
///   [List<List<String>>] rows
///
/// Return type: [Future<void>]
Future<void> exportTimeTrackerCsv({
  required BuildContext context,
  required String defaultFileName,
  required List<String> header,
  required List<List<String>> rows,
}) {
  return CustomDialogManager.showExport(
    context: context,
    initialFileName: defaultFileName,
    onDownload: (String fileName) async {
      final String name =
          fileName.trim().isEmpty ? defaultFileName : fileName.trim();
      final CSVHelper helper = CSVHelper();
      final String csv = helper.createCsv(<List<dynamic>>[header, ...rows]);
      final result = await helper.exportForUser(fileName: name, csvContent: csv);
      if (!context.mounted) return;
      final S s = S.of(context);
      result.fold(
        (String error) => CustomDialogManager.showMessage(
          context: context,
          lottiePath: AppAssets.lottieWarning,
          title: s.exportFailed,
          subtitle: error,
        ),
        (String path) {
          if (path == CSVHelper.exportCancelled) return;
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: AppAssets.successful,
            title: s.exportSuccessful,
            subtitle: s.exportSuccess,
            // Owner rule R3: success messages close themselves, no OK button.
            closeAfter: const Duration(seconds: 3),
          );
        },
      );
    },
  );
}
