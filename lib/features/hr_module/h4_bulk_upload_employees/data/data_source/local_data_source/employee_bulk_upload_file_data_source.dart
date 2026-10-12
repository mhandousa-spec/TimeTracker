// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_file_data_source.dart
// Purpose: Picks and parses employee Excel workbooks without UI state.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../../../generated/l10n.dart';
import '../../../utils/constants/employee_bulk_upload_headers.dart';
import '../../../utils/employee_bulk_upload_failure.dart';
import '../../models/employee_bulk_upload_file.dart';
import '../../models/employee_bulk_upload_row.dart';
import 'employee_bulk_upload_legacy_xls_reader.dart';

/// Local boundary for selecting and decoding employee spreadsheets.
class EmployeeBulkUploadFileDataSource {
  const EmployeeBulkUploadFileDataSource();

  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls'],
      allowMultiple: false,
      withData: true,
    );
    return result?.files.single;
  }

  Either<EmployeeBulkUploadFailure, EmployeeBulkUploadFile> parse({
    required String fileName,
    required Uint8List bytes,
    required S localization,
  }) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension != 'xlsx' && extension != 'xls') {
      return Left(EmployeeBulkUnsupportedFileFailure(
        localization.employeeBulkUnsupportedFile,
      ));
    }

    try {
      if (extension == 'xls') {
        final sheet = readEmployeeBulkUploadLegacyXls(bytes);
        if (sheet == null) {
          return Left(EmployeeBulkEmptyWorkbookFailure(
            localization.employeeBulkEmptyWorkbook,
          ));
        }
        return _parseRows(
          fileName: fileName,
          sheetName: sheet.name,
          rows: sheet.rows,
          firstPhysicalRowIndex: sheet.firstRowIndex,
          localization: localization,
        );
      }

      final workbook = Excel.decodeBytes(bytes);
      final sheetEntry =
          workbook.tables.entries.cast<MapEntry<String, Sheet>?>().firstWhere(
                (entry) => entry != null && entry.value.rows.isNotEmpty,
                orElse: () => null,
              );
      if (sheetEntry == null) {
        return Left(EmployeeBulkEmptyWorkbookFailure(
          localization.employeeBulkEmptyWorkbook,
        ));
      }

      return _parseRows(
        fileName: fileName,
        sheetName: sheetEntry.key,
        rows: sheetEntry.value.rows
            .map<List<Object?>>(
              (row) => row.map<Object?>((cell) => cell?.value).toList(),
            )
            .toList(growable: false),
        firstPhysicalRowIndex: 0,
        localization: localization,
      );
    } catch (_) {
      return Left(EmployeeBulkCorruptWorkbookFailure(
        localization.employeeBulkInvalidWorkbook,
      ));
    }
  }

  Either<EmployeeBulkUploadFailure, EmployeeBulkUploadFile> _parseRows({
    required String fileName,
    required String sheetName,
    required List<List<Object?>> rows,
    required int firstPhysicalRowIndex,
    required S localization,
  }) {
    final firstNonEmptyIndex = rows.indexWhere((row) => !_isBlankRow(row));
    if (firstNonEmptyIndex < 0) {
      return Left(EmployeeBulkEmptyWorkbookFailure(
        localization.employeeBulkEmptyWorkbook,
      ));
    }
    final headers = rows[firstNonEmptyIndex].map(_cellText).toList();
    final headerLayout = _resolveHeaderLayout(headers);
    if (!headerLayout.isValid) {
      return Left(EmployeeBulkHeaderFailure(
        localization.employeeBulkHeaderMismatch,
        missingHeaders: headerLayout.missingHeaders,
        unexpectedHeaders: headerLayout.unexpectedHeaders,
        hasOrderMismatch: headerLayout.hasOrderMismatch,
      ));
    }

    final parsedRows = <EmployeeBulkUploadRow>[];
    for (var index = firstNonEmptyIndex + 1; index < rows.length; index++) {
      final cells = rows[index];
      if (_isBlankRow(cells)) continue;
      final values = <String, String>{};
      for (final header in EmployeeBulkUploadHeaders.values) {
        final column = headerLayout.columns[header];
        values[header] = column == null || column >= cells.length
            ? ''
            : _cellText(cells[column], header: header);
      }
      for (final phoneHeader in _phoneHeaders) {
        final countryCodeColumn = headerLayout.countryCodeColumns[phoneHeader];
        if (countryCodeColumn == null || countryCodeColumn >= cells.length) {
          continue;
        }
        values[phoneHeader] = _combinePhone(
          countryCode: _cellText(cells[countryCodeColumn]),
          phoneNumber: values[phoneHeader]!,
        );
      }
      values[EmployeeBulkUploadHeaders.number] =
          (parsedRows.length + 1).toString();
      parsedRows.add(EmployeeBulkUploadRow(
        excelRowNumber: firstPhysicalRowIndex + index + 1,
        values: values,
      ));
    }

    if (parsedRows.isEmpty) {
      return Left(EmployeeBulkEmptyWorkbookFailure(
        localization.employeeBulkNoRows,
      ));
    }
    if (parsedRows.length > EmployeeBulkUploadHeaders.maxRows) {
      return Left(EmployeeBulkRowLimitFailure(
        localization.employeeBulkRowLimit,
      ));
    }

    return Right(EmployeeBulkUploadFile(
      fileName: fileName,
      sheetName: sheetName,
      rows: parsedRows,
    ));
  }

  /// Method Name: [_resolveHeaderLayout]
  ///
  /// Purpose: Validates the strict employee-template header contract and
  /// captures enough context for a service-style correction dialog.
  ///
  /// Parameters:
  /// - [headers]: Raw headers read from the first non-empty workbook row.
  ///
  /// Returns: A typed description of whether the header row is valid.
  _EmployeeBulkHeaderLayout _resolveHeaderLayout(List<String> headers) {
    final scan = _scanHeaders(headers);
    final expectedHeaders = _expectedHeaders(scan.columns);
    final missingHeaders = _missingHeaders(scan.columns);
    final hasExactOrder = _hasExactHeaderOrder(
      scan.resolvedHeaders,
      expectedHeaders,
    );

    return _EmployeeBulkHeaderLayout(
      isValid: hasExactOrder &&
          missingHeaders.isEmpty &&
          scan.unexpectedHeaders.isEmpty,
      columns: scan.columns,
      countryCodeColumns: scan.countryCodeColumns,
      missingHeaders: missingHeaders,
      unexpectedHeaders: scan.unexpectedHeaders,
      hasOrderMismatch: !hasExactOrder &&
          missingHeaders.isEmpty &&
          scan.unexpectedHeaders.isEmpty,
    );
  }

  /// Method Name: [_scanHeaders]
  ///
  /// Purpose: Resolves aliases, indexes, duplicates, and phone country-code
  /// columns without deciding whether the complete layout is valid.
  ///
  /// Parameters:
  /// - [headers]: Raw header values read from the worksheet.
  ///
  /// Returns: The normalized header scan used by the layout validator.
  _EmployeeBulkHeaderScan _scanHeaders(List<String> headers) {
    final columns = <String, int>{};
    final countryCodeColumns = <String, int>{};
    final unexpectedHeaders = <String>[];
    final resolvedHeaders = <String>[];

    for (var index = 0; index < headers.length; index++) {
      final header = headers[index].trim();
      if (header == EmployeeBulkUploadHeaders.countryCode) {
        _scanCountryCodeHeader(
          headers: headers,
          index: index,
          countryCodeColumns: countryCodeColumns,
          unexpectedHeaders: unexpectedHeaders,
        );
        continue;
      }

      final canonicalHeader = _canonicalHeader(header);
      if (canonicalHeader == null || columns.containsKey(canonicalHeader)) {
        unexpectedHeaders.add(header);
        continue;
      }
      columns[canonicalHeader] = index;
      resolvedHeaders.add(canonicalHeader);
    }

    return _EmployeeBulkHeaderScan(
      columns: columns,
      countryCodeColumns: countryCodeColumns,
      unexpectedHeaders: unexpectedHeaders,
      resolvedHeaders: resolvedHeaders,
    );
  }

  /// Method Name: [_scanCountryCodeHeader]
  ///
  /// Purpose: Validates a country-code column and associates it with the
  /// following phone column.
  ///
  /// Parameters:
  /// - [headers]: Raw worksheet headers.
  /// - [index]: Position of the country-code header.
  /// - [countryCodeColumns]: Valid phone-to-country-code index mappings.
  /// - [unexpectedHeaders]: Headers that cannot be used by the template.
  ///
  /// Returns: Nothing; updates the supplied scan collections.
  void _scanCountryCodeHeader({
    required List<String> headers,
    required int index,
    required Map<String, int> countryCodeColumns,
    required List<String> unexpectedHeaders,
  }) {
    final phoneHeader = index + 1 < headers.length
        ? _canonicalHeader(headers[index + 1])
        : null;
    final isValidPhonePair = phoneHeader != null &&
        _phoneHeaders.contains(phoneHeader) &&
        !countryCodeColumns.containsKey(phoneHeader);
    if (isValidPhonePair) {
      countryCodeColumns[phoneHeader] = index;
    } else {
      unexpectedHeaders.add(headers[index].trim());
    }
  }

  /// Method Name: [_expectedHeaders]
  ///
  /// Purpose: Selects the expected header sequence, allowing the generated
  /// `NO` column to be omitted from imported files.
  ///
  /// Parameters:
  /// - [columns]: Canonical headers discovered in the worksheet.
  ///
  /// Returns: The ordered headers required for this workbook variant.
  List<String> _expectedHeaders(Map<String, int> columns) {
    if (columns.containsKey(EmployeeBulkUploadHeaders.number)) {
      return EmployeeBulkUploadHeaders.values;
    }
    return EmployeeBulkUploadHeaders.values
        .where((header) => header != EmployeeBulkUploadHeaders.number)
        .toList(growable: false);
  }

  /// Method Name: [_missingHeaders]
  ///
  /// Purpose: Finds required template columns absent from the worksheet.
  ///
  /// Parameters:
  /// - [columns]: Canonical headers discovered in the worksheet.
  ///
  /// Returns: Missing headers in template order.
  List<String> _missingHeaders(Map<String, int> columns) {
    return EmployeeBulkUploadHeaders.values
        .where(
          (header) =>
              header != EmployeeBulkUploadHeaders.number &&
              !columns.containsKey(header),
        )
        .toList(growable: false);
  }

  /// Method Name: [_hasExactHeaderOrder]
  ///
  /// Purpose: Confirms that resolved headers occur in the exact template
  /// sequence.
  ///
  /// Parameters:
  /// - [resolvedHeaders]: Canonical headers found in workbook order.
  /// - [expectedHeaders]: Required canonical header sequence.
  ///
  /// Returns: Whether both sequences have equal length and values.
  bool _hasExactHeaderOrder(
    List<String> resolvedHeaders,
    List<String> expectedHeaders,
  ) {
    if (resolvedHeaders.length != expectedHeaders.length) return false;
    return resolvedHeaders.asMap().entries.every(
          (entry) => entry.value == expectedHeaders[entry.key],
        );
  }

  String? _canonicalHeader(String header) {
    final trimmedHeader = header.trim();
    if (EmployeeBulkUploadHeaders.values.contains(trimmedHeader)) {
      return trimmedHeader;
    }
    return EmployeeBulkUploadHeaders.activeDirectoryAliases[trimmedHeader];
  }

  String _combinePhone({
    required String countryCode,
    required String phoneNumber,
  }) {
    if (countryCode.isEmpty || phoneNumber.isEmpty) return phoneNumber;
    final normalizedCode =
        countryCode.startsWith('+') ? countryCode : '+$countryCode';
    return '$normalizedCode $phoneNumber';
  }

  bool _isBlankRow(List<Object?> row) =>
      row.every((cell) => _cellText(cell).isEmpty);

  String _cellText(Object? value, {String? header}) {
    if (value == null) return '';
    if (value is DateCellValue) return _formatDate(value.asDateTimeLocal());
    if (value is DateTimeCellValue) {
      return _formatDate(value.asDateTimeLocal());
    }
    if (value is DateTime) return _formatDate(value);
    if (value is num) {
      if (_isDateHeader(header)) {
        return _formatDate(
          DateTime(1899, 12, 30).add(Duration(days: value.toInt())),
        );
      }
      if (value.isFinite && value == value.truncate()) {
        return value.toInt().toString();
      }
    }
    return value.toString().trim();
  }

  bool _isDateHeader(String? header) => const {
        EmployeeBulkUploadHeaders.nationalIdExpiration,
        EmployeeBulkUploadHeaders.passportExpiration,
        EmployeeBulkUploadHeaders.birthDate,
      }.contains(header);

  String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

/// Header-contract result used to keep file parsing independent from UI.
class _EmployeeBulkHeaderLayout {
  const _EmployeeBulkHeaderLayout({
    required this.isValid,
    required this.columns,
    required this.countryCodeColumns,
    required this.missingHeaders,
    required this.unexpectedHeaders,
    required this.hasOrderMismatch,
  });

  final bool isValid;
  final Map<String, int> columns;
  final Map<String, int> countryCodeColumns;
  final List<String> missingHeaders;
  final List<String> unexpectedHeaders;
  final bool hasOrderMismatch;
}

/// Intermediate normalized header data used by [_resolveHeaderLayout].
class _EmployeeBulkHeaderScan {
  const _EmployeeBulkHeaderScan({
    required this.columns,
    required this.countryCodeColumns,
    required this.unexpectedHeaders,
    required this.resolvedHeaders,
  });

  final Map<String, int> columns;
  final Map<String, int> countryCodeColumns;
  final List<String> unexpectedHeaders;
  final List<String> resolvedHeaders;
}

const _phoneHeaders = <String>{
  EmployeeBulkUploadHeaders.mobilePhone,
  EmployeeBulkUploadHeaders.homeNumber,
  EmployeeBulkUploadHeaders.officeNumber,
};
