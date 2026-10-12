// ***************************** FILE INFO ***************************** //
// File Name: employee_excel_exporter.dart
// Purpose: Creates and saves HR employee Excel workbooks.
// Author: Mohamed Elrashidy
// Created At: 2026-08-29
// ********************************************************************* //

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

/// Creates `.xlsx` files from localized employee table rows.
class EmployeeExcelExporter {
  /// Method Name: [export]
  ///
  /// Purpose: Builds an Excel workbook from the supplied table values and
  /// saves it in the platform Downloads directory when available.
  ///
  /// Parameters:
  /// - [headers]: Ordered localized table headings.
  /// - [rows]: Ordered table values matching [headers].
  /// - [fileName]: File name without the `.xlsx` extension.
  ///
  /// Returns: The saved Excel file.
  Future<File> export({
    required List<String> headers,
    required List<List<String>> rows,
    required String fileName,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook[workbook.getDefaultSheet() ?? 'Sheet1'];
    sheet.appendRow(headers.map(TextCellValue.new).toList());
    for (final row in rows) {
      sheet.appendRow(row.map(TextCellValue.new).toList());
    }

    final bytes = workbook.save();
    if (bytes == null) throw StateError('Unable to create Excel workbook');
    final directory = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.xlsx');
    return file.writeAsBytes(bytes, flush: true);
  }
}
