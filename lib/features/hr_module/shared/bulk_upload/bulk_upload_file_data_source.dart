// ***************************** FILE INFO ***************************** //
// File Name: bulk_upload_file_data_source.dart
// Purpose: Decodes reusable HR XLS/XLSX spreadsheet templates.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../../h4_bulk_upload_employees/data/data_source/local_data_source/employee_bulk_upload_legacy_xls_reader.dart';
import 'bulk_upload_template.dart';

/// File parsing result that never exposes decoder implementation details.
sealed class BulkUploadParseResult {
  const BulkUploadParseResult();
}

final class BulkUploadParsedFile extends BulkUploadParseResult {
  const BulkUploadParsedFile(this.file);
  final BulkUploadFile file;
}

final class BulkUploadParseFailure extends BulkUploadParseResult {
  const BulkUploadParseFailure(this.code);
  final BulkUploadParseFailureCode code;
}

enum BulkUploadParseFailureCode { unsupported, corrupt, empty, headers, rows }

/// Shared picker and strict-template parser for HR bulk-upload features.
class BulkUploadFileDataSource {
  const BulkUploadFileDataSource();

  Future<PlatformFile?> pickFile() => FilePicker
      .platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx', 'xls'],
        allowMultiple: false,
        withData: true,
      )
      .then((result) => result?.files.single);

  BulkUploadParseResult parse({
    required String fileName,
    required Uint8List bytes,
    required BulkUploadTemplate template,
  }) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension != 'xlsx' && extension != 'xls') {
      return const BulkUploadParseFailure(
          BulkUploadParseFailureCode.unsupported);
    }
    try {
      if (extension == 'xls') {
        final sheet = readEmployeeBulkUploadLegacyXls(bytes);
        if (sheet == null) {
          return const BulkUploadParseFailure(BulkUploadParseFailureCode.empty);
        }
        return _parseRows(
            fileName, sheet.name, sheet.rows, sheet.firstRowIndex, template);
      }
      final workbook = Excel.decodeBytes(bytes);
      final entry =
          workbook.tables.entries.cast<MapEntry<String, Sheet>?>().firstWhere(
                (value) => value != null && value.value.rows.isNotEmpty,
                orElse: () => null,
              );
      if (entry == null) {
        return const BulkUploadParseFailure(BulkUploadParseFailureCode.empty);
      }
      return _parseRows(
        fileName,
        entry.key,
        entry.value.rows
            .map((row) => row.map((cell) => cell?.value).toList())
            .toList(),
        0,
        template,
      );
    } catch (_) {
      return const BulkUploadParseFailure(BulkUploadParseFailureCode.corrupt);
    }
  }

  BulkUploadParseResult _parseRows(
      String fileName,
      String sheetName,
      List<List<Object?>> rows,
      int firstPhysicalRowIndex,
      BulkUploadTemplate template) {
    final headerRow =
        rows.indexWhere((row) => row.any((cell) => _text(cell).isNotEmpty));
    if (headerRow < 0) {
      return const BulkUploadParseFailure(BulkUploadParseFailureCode.empty);
    }
    final rawHeaders = rows[headerRow].map(_text).toList();
    final resolved = <String>[];
    final columns = <String, int>{};
    for (var index = 0; index < rawHeaders.length; index++) {
      final raw = rawHeaders[index].trim();
      final header =
          template.headers.contains(raw) ? raw : template.aliases[raw];
      if (header == null || columns.containsKey(header)) {
        return const BulkUploadParseFailure(BulkUploadParseFailureCode.headers);
      }
      columns[header] = index;
      resolved.add(header);
    }
    final expected = columns.containsKey('NO')
        ? template.headers
        : template.headers.where((header) => header != 'NO').toList();
    if (resolved.length != expected.length ||
        resolved
            .asMap()
            .entries
            .any((entry) => entry.value != expected[entry.key])) {
      return const BulkUploadParseFailure(BulkUploadParseFailureCode.headers);
    }
    final parsed = <BulkUploadRow>[];
    for (var index = headerRow + 1; index < rows.length; index++) {
      if (rows[index].every((cell) => _text(cell).isEmpty)) continue;
      parsed.add(BulkUploadRow(
        excelRowNumber: firstPhysicalRowIndex + index + 1,
        values: {
          for (final header in template.headers)
            header: header == 'NO'
                ? '${parsed.length + 1}'
                : _text(columns[header] != null &&
                        columns[header]! < rows[index].length
                    ? rows[index][columns[header]!]
                    : null),
        },
      ));
    }
    if (parsed.isEmpty) {
      return const BulkUploadParseFailure(BulkUploadParseFailureCode.empty);
    }
    if (parsed.length > template.maxRows) {
      return const BulkUploadParseFailure(BulkUploadParseFailureCode.rows);
    }
    return BulkUploadParsedFile(
        BulkUploadFile(fileName: fileName, sheetName: sheetName, rows: parsed));
  }

  String _text(Object? value) {
    if (value == null) return '';
    if (value is num && value.isFinite && value == value.truncate()) {
      return value.toInt().toString();
    }
    return value.toString().trim();
  }
}
