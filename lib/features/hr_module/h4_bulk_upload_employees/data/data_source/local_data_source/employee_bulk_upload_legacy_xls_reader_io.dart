// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_legacy_xls_reader_io.dart
// Purpose: Decodes legacy Excel 97-2003 BIFF worksheets from in-memory bytes.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'dart:typed_data';

import 'package:excel2003/excel2003.dart';

/// Platform-neutral values extracted from one legacy worksheet.
class EmployeeBulkUploadLegacySheet {
  const EmployeeBulkUploadLegacySheet({
    required this.name,
    required this.rows,
    required this.firstRowIndex,
  });

  final String name;
  final List<List<Object?>> rows;
  final int firstRowIndex;
}

/// Method Name: [readEmployeeBulkUploadLegacyXls]
///
/// Purpose: Reads the first non-empty BIFF8 worksheet without filesystem IO.
///
/// Parameters:
/// - [bytes]: Complete legacy workbook bytes.
///
/// Returns: The first non-empty worksheet, or null when no data exists.
EmployeeBulkUploadLegacySheet? readEmployeeBulkUploadLegacyXls(
  Uint8List bytes,
) {
  final workbook = XlsReader.fromBytes(bytes);
  for (var index = 0; index < workbook.sheetCount; index++) {
    final sheet = workbook.sheet(index);
    final rows = sheet.rows
        .map<List<Object?>>((row) => List<Object?>.from(row))
        .toList(growable: false);
    if (rows.any(_hasValue)) {
      return EmployeeBulkUploadLegacySheet(
        name: sheet.name,
        rows: rows,
        firstRowIndex: sheet.firstRow,
      );
    }
  }
  return null;
}

bool _hasValue(List<Object?> row) =>
    row.any((value) => value?.toString().trim().isNotEmpty ?? false);
