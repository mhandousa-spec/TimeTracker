/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: csv_helper.dart
/// Purpose: Declares `CSVHelper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 10/9/2026 - Added [exportForUser] / [exportRowsForUser], the
///                      PHONE-SAFE save path. [exportToCSV] below writes
///                      straight to a folder, which does not reach the user on
///                      a phone at all — see the doc on [exportForUser].
/// Updated: 30/8/2026 - The save location moved to [ExportDirectory.resolve].
///                      This file used to send macOS and iOS to
///                      `getApplicationDocumentsDirectory()`, which under the
///                      app sandbox is the container's Documents folder — not
///                      `~/Documents` — so on macOS every CSV was written
///                      somewhere the user never sees. See export_directory.dart
///                      for the full account.

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/core/helper/main_helper/export_directory.dart';

class CSVHelper {
  String createCsv(List<List<dynamic>> rows) {
    String csv = Csv(autoDetect: false).encode(rows);
    return csv;
  }

  Future<File> saveCsvToFile(String csvData, String fileName) async {
    final Directory directory = await ExportDirectory.resolve();
    final path = '${directory.path}${Platform.pathSeparator}$fileName.csv';
    final file = File(path);
    List<int> csvBytes = utf8.encode(csvData);
    List<int> bom = [0xEF, 0xBB, 0xBF];
    return await file.writeAsBytes(bom + csvBytes);
  }

  /// Writes the CSV to a folder and returns the `File`.
  ///
  /// DESKTOP ONLY, in practice. On a phone the folder this resolves to is not
  /// somewhere the user can reach — see [exportForUser], which is what any
  /// export the USER is waiting for should call.
  exportToCSV(List<List<dynamic>> rows, String fileName) async {
    final csv = createCsv(rows);
    final file = await saveCsvToFile(csv, fileName);
    return file;
  }

  /// The [Right] value [exportForUser] returns when the user dismissed the
  /// system save sheet without choosing a destination.
  static const String exportCancelled = '';

  /// Writes a CSV somewhere the user can actually open it, on every platform.
  ///
  /// ADDED 10/9/2026, lifted verbatim from `RoleCubit.exportRolesToCsv` — which
  /// now calls this — so the app has ONE answer to "save this file for the
  /// user" instead of one per feature. The roles export had already been
  /// reported broken twice and fixed twice; the phone export flows were still
  /// running the pre-fix code through [exportToCSV] and were broken in exactly
  /// the ways its history describes:
  ///
  /// - Android: [ExportDirectory.resolve] writes straight into
  ///   `/storage/emulated/0/Download`. Scoped storage (API 29+) forbids that,
  ///   so `File.writeAsBytes` throws `Permission denied` and nothing is saved.
  /// - iOS: the write SUCCEEDS, into the app's private Documents folder. There
  ///   is no user-visible Downloads on iOS and this app does not publish its
  ///   Documents folder to the Files app, so the file exists and cannot be
  ///   reached from anywhere. This is the "export does not work" that has no
  ///   error to show for itself.
  ///
  /// Both phone platforms therefore stage the CSV in the temp folder and hand
  /// it to the system save sheet through `flutter_file_dialog` — SAF on
  /// Android, "Save to Files" on iOS — the one path that needs no storage
  /// permission on any Android version. The user picks the destination, so
  /// there is no "where did it go" left to answer. Desktop keeps the real
  /// Downloads folder.
  ///
  /// The UTF-8 BOM is not optional: this app's exports carry Arabic, and Excel
  /// reads a BOM-less UTF-8 CSV as the local codepage — the Arabic columns
  /// open as mojibake.
  ///
  /// Returns Left = an error message; Right = the saved path, or
  /// [exportCancelled] when the user dismissed the save sheet — nothing was
  /// written and nothing went wrong, so the caller shows neither outcome.
  ///
  /// CHANGED 28/9/2026 (Knowledge Hub bug report p.24 — "when press export
  /// only export the file and show confirmation message"): the desktop path no
  /// longer opens the Downloads folder in the file manager after writing. The
  /// caller shows its confirmation dialog instead. Pass [revealFolder] `true`
  /// to get the old behaviour back for one call site.
  Future<Either<String, String>> exportForUser({
    required String fileName,
    required String csvContent,
    bool revealFolder = false,
  }) async {
    try {
      final String finalFileName =
          fileName.toLowerCase().endsWith('.csv') ? fileName : '$fileName.csv';

      const List<int> utf8Bom = <int>[0xEF, 0xBB, 0xBF];
      final List<int> bytes = <int>[...utf8Bom, ...utf8.encode(csvContent)];

      // ── Phones: stage in temp, then let the OS place the file ──
      if (Platform.isAndroid || Platform.isIOS) {
        final Directory tempDirectory = await getTemporaryDirectory();
        final String stagedPath =
            '${tempDirectory.path}${Platform.pathSeparator}$finalFileName';
        final File staged = File(stagedPath);
        await staged.writeAsBytes(bytes);

        final String? savedPath = await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: stagedPath,
            fileName: finalFileName,
          ),
        );

        // The staged copy has been handed over (or refused); either way it is
        // a temp file and does not belong on the device.
        if (await staged.exists()) {
          await staged.delete();
        }

        // `null` is a dismissal, not a failure.
        return Right(savedPath ?? exportCancelled);
      }

      // ── Desktop: the real Downloads folder ──
      final Directory directory = await ExportDirectory.resolve();
      final String filePath =
          '${directory.path}${Platform.pathSeparator}$finalFileName';

      final File written = File(filePath);
      await written.writeAsBytes(bytes);

      // A write that reported no error and produced no file is the exact
      // failure mode this whole path exists to end, so it is checked rather
      // than assumed.
      if (!await written.exists()) {
        return Left('The file could not be written to $filePath');
      }

      // Open the folder so the file is IN FRONT of the user rather than named
      // in a dialog they have to go and act on. Best-effort — see the doc on
      // `ExportDirectory.reveal`; the export has already succeeded.
      if (revealFolder) await ExportDirectory.reveal(filePath);

      return Right(filePath);
    } catch (e, stackTrace) {
      debugPrint('exportForUser failed: $e\n$stackTrace');
      return Left(e.toString());
    }
  }

  /// [exportForUser] for callers that hold rows rather than rendered CSV.
  Future<Either<String, String>> exportRowsForUser({
    required String fileName,
    required List<List<dynamic>> rows,
    bool revealFolder = false,
  }) =>
      exportForUser(
        fileName: fileName,
        csvContent: createCsv(rows),
        revealFolder: revealFolder,
      );
}
