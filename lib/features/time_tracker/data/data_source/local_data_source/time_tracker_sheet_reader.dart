/// Module: time_tracker / data / data_source / local_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_sheet_reader.dart
/// Purpose: Declares `TimeTrackerSheetReader` — lets the user pick a CSV /
///          Excel file and reads its first sheet into a grid of strings
///          (Import Locations).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Module-local copy of the Database Builder's `TableImportFileParser`
/// reading (UTF-8 with malformed bytes allowed, CRLF normalised, the FIRST
/// Excel sheet). Throws on an unreadable file — the cubit catches. Returns
/// null when the user cancels the picker.
/// Updated: 9/10/2026 - QA KP-TT-012: the picker goes through
/// `TimeTrackerFilePickGuard` (one native picker at a time).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_file_pick_guard.dart';

/// A picked file, read.
class TimeTrackerSheet {
  const TimeTrackerSheet({required this.fileName, required this.grid});

  final String fileName;
  final List<List<String>> grid;
}

class TimeTrackerSheetReader {
  const TimeTrackerSheetReader();

  static const List<String> allowedExtensions = <String>['csv', 'xlsx', 'xls'];

  /// Function Name: [pickAndRead]
  ///
  /// Purpose: Open the file picker, then read the chosen file.
  ///
  /// Return type: [Future<TimeTrackerSheet?>] — null when cancelled.
  Future<TimeTrackerSheet?> pickAndRead() async {
    // QA KP-TT-012 (9/10/2026): one native picker at a time (a second tap
    // on "Upload File" is ignored instead of failing with multiple_request).
    final FilePickerResult? result = await TimeTrackerFilePickGuard.run(
      () => FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      ),
    );
    if (result == null || result.files.isEmpty) return null;
    final PlatformFile file = result.files.single;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) throw const FormatException('The file could not be read.');
    return TimeTrackerSheet(fileName: file.name, grid: read(bytes, file.name));
  }

  /// Function Name: [read]
  ///
  /// Purpose: [bytes] of [fileName] → rows of cells.
  ///
  /// Return type: [List<List<String>>]
  static List<List<String>> read(Uint8List bytes, String fileName) =>
      fileName.toLowerCase().endsWith('.csv') ? _csv(bytes) : _excel(bytes);

  static List<List<String>> _csv(Uint8List bytes) {
    String text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('﻿')) text = text.substring(1);
    final List<List<dynamic>> parsed = Csv(autoDetect: false, skipEmptyLines: false)
        .decode(text.replaceAll('\r\n', '\n'));
    return <List<String>>[
      for (final List<dynamic> row in parsed)
        <String>[for (final Object? cell in row) '${cell ?? ''}'],
    ];
  }

  static List<List<String>> _excel(Uint8List bytes) {
    final Excel workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.keys.isEmpty) return const <List<String>>[];
    final Sheet sheet = workbook.tables[workbook.tables.keys.first]!;
    return <List<String>>[
      for (final List<Data?> row in sheet.rows)
        <String>[for (final Data? cell in row) '${cell?.value ?? ''}'],
    ];
  }
}
