/// Module: GRC shared helpers
/// Description: "Export" for the GRC list screens (champions, owners, a
///              person's task table) — the app's File Name / Download card
///              followed by a UTF-8 CSV written through CSVHelper.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: CustomDialogManager.showExport, CSVHelper.exportForUser
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// function name: [exportGrcCsv]
///
/// purpose: asks for a file name, then writes [header] + [rows] as a CSV.
///          Same flow the Active Directory export uses, so every Export
///          button in the app behaves the same way.
///
/// parameters:
///            [BuildContext] context
///            [String] defaultFileName: pre-filled in the File Name field
///            [List<String>] header: first CSV row
///            [List<List<Object?>>] rows: one list per data row
///
/// return type: [Future<void>]
Future<void> exportGrcCsv({
  required BuildContext context,
  required String defaultFileName,
  required List<String> header,
  required List<List<Object?>> rows,
}) {
  return CustomDialogManager.showExport(
    context: context,
    initialFileName: defaultFileName,
    onDownload: (String fileName) async {
      final String name =
          fileName.trim().isEmpty ? defaultFileName : fileName.trim();
      final CSVHelper helper = CSVHelper();
      final String csv = helper.createCsv(<List<dynamic>>[
        header,
        ...rows.map((r) => r.map((c) => c ?? '').toList()),
      ]);
      final result =
          await helper.exportForUser(fileName: name, csvContent: csv);
      if (!context.mounted) return;
      result.fold(
        (String error) => CustomDialogManager.showMessage(
          context: context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
          title: S.of(context).exportFailed,
          subtitle: error,
        ),
        (String path) {
          // A dismissed save sheet is not an outcome worth a dialog.
          if (path == CSVHelper.exportCancelled) return;
          showSuccessDialog(
            context: context,
            title: S.of(context).success,
            subtitle: S.of(context).grcFileExported,
          );
        },
      );
    },
  );
}
