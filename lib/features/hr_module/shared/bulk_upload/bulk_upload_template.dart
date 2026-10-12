// ***************************** FILE INFO ***************************** //
// File Name: bulk_upload_template.dart
// Purpose: Defines reusable HR spreadsheet template contracts.
// Author: Mohamed Elrashidy
// Created At: 2026-08-16
// ********************************************************************* //

/// Immutable spreadsheet contract consumed by HR bulk-upload features.
class BulkUploadTemplate {
  const BulkUploadTemplate({
    required this.headers,
    required this.maxRows,
    this.optionalHeaders = const {},
    this.aliases = const {},
    this.readOnlyHeaders = const {'NO'},
  });

  final List<String> headers;
  final int maxRows;
  final Set<String> optionalHeaders;
  final Map<String, String> aliases;
  final Set<String> readOnlyHeaders;

  bool isRequired(String header) => !optionalHeaders.contains(header);
}

/// One editable, immutable row shared by HR spreadsheet workflows.
class BulkUploadRow {
  BulkUploadRow(
      {required this.excelRowNumber, required Map<String, String> values})
      : values = Map.unmodifiable(Map<String, String>.from(values));

  final int excelRowNumber;
  final Map<String, String> values;

  String value(String header) => values[header]?.trim() ?? '';

  BulkUploadRow updateValue(String header, String value) => BulkUploadRow(
        excelRowNumber: excelRowNumber,
        values: Map<String, String>.from(values)..[header] = value,
      );

  BulkUploadRow renumber(int index) => BulkUploadRow(
        excelRowNumber: index + 2,
        values: Map<String, String>.from(values)..['NO'] = '${index + 1}',
      );

  factory BulkUploadRow.empty(BulkUploadTemplate template, int index) =>
      BulkUploadRow(
        excelRowNumber: index + 2,
        values: {
          for (final header in template.headers) header: '',
          'NO': '${index + 1}',
        },
      );
}

/// Associates a user-visible validation message with one workbook cell.
class BulkUploadCellError {
  const BulkUploadCellError({
    required this.rowIndex,
    required this.header,
    required this.message,
  });

  final int rowIndex;
  final String header;
  final String message;
}

/// Parsed workbook with feature validation errors.
class BulkUploadFile {
  BulkUploadFile({
    required this.fileName,
    required this.sheetName,
    required List<BulkUploadRow> rows,
    List<BulkUploadCellError> errors = const [],
  })  : rows = List.unmodifiable(rows),
        errors = List.unmodifiable(errors);

  final String fileName;
  final String sheetName;
  final List<BulkUploadRow> rows;
  final List<BulkUploadCellError> errors;

  BulkUploadFile copyWith({
    List<BulkUploadRow>? rows,
    List<BulkUploadCellError>? errors,
  }) =>
      BulkUploadFile(
        fileName: fileName,
        sheetName: sheetName,
        rows: rows ?? this.rows,
        errors: errors ?? this.errors,
      );
}
