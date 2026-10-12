/// Module: GRC Assignee Bulk Upload (shared by Control Owner + Control Champion)
/// Description: Parses an uploaded Excel (.xlsx/.xls) workbook of
///              assignee/policy/control rows into raw [AssigneeBulkRow]
///              values. Validates the header row against the fixed expected
///              column list before reading any data, mirroring
///              policy_excel_parser.dart's approach.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-26
/// Dependencies: excel package

import 'package:excel/excel.dart' hide Border, BorderStyle;

/// The sheet's header row must match this list exactly, in order. Shared by
/// both the Control Owner and Control Champion bulk upload flows — only the
/// page title/label differs between them, not the template shape.
const List<String> assigneeBulkUploadExpectedHeaders = [
  'Email',
  'Policy Name',
  'Control Name',
];

/// class name: [AssigneeBulkRow]
///
/// purpose: one raw, unvalidated data row parsed from the uploaded sheet.
///          [controlNames] is the raw cell text — a single control name, or
///          several separated by commas — split and resolved later in
///          [AssigneeBulkRowForm.validate].
class AssigneeBulkRow {
  final String email;
  final String policyName;
  final String controlNames;

  const AssigneeBulkRow({
    required this.email,
    required this.policyName,
    required this.controlNames,
  });
}

sealed class AssigneeExcelParseResult {}

class AssigneeExcelParseSuccess extends AssigneeExcelParseResult {
  final List<AssigneeBulkRow> rows;
  AssigneeExcelParseSuccess(this.rows);
}

class AssigneeExcelParseHeaderMismatch extends AssigneeExcelParseResult {
  final String message;
  AssigneeExcelParseHeaderMismatch(this.message);
}

class AssigneeExcelParseEmpty extends AssigneeExcelParseResult {}

/// function name: [parseAssigneeExcel]
///
/// purpose: decode an uploaded workbook's bytes, validate its header row
///          against [assigneeBulkUploadExpectedHeaders], and parse every
///          non-blank data row into an [AssigneeBulkRow].
AssigneeExcelParseResult parseAssigneeExcel(List<int> bytes) {
  // The excel package throws (a bare null-check) on workbooks it cannot
  // resolve -- e.g. a sheet relationship written with an absolute
  // "/xl/worksheets/..." target, as some generators do. Without this guard
  // the error escaped the page and left its spinner running forever.
  final Excel excel;
  try {
    excel = Excel.decodeBytes(bytes);
  } catch (_) {
    return AssigneeExcelParseHeaderMismatch(
      'This file could not be read. Open it in Excel, save it again as '
      '.xlsx and retry. Expected columns: '
      '${assigneeBulkUploadExpectedHeaders.join(', ')}',
    );
  }
  if (excel.tables.isEmpty) return AssigneeExcelParseEmpty();

  for (final tableName in excel.tables.keys) {
    final sheet = excel.tables[tableName];
    if (sheet == null || sheet.rows.isEmpty) continue;

    final rows = sheet.rows;
    final actualHeaders =
        rows.first.map((cell) => _cellText(cell?.value)).toList();
    while (actualHeaders.isNotEmpty && actualHeaders.last.isEmpty) {
      actualHeaders.removeLast();
    }

    if (!_headersMatch(actualHeaders)) {
      return AssigneeExcelParseHeaderMismatch(
        'Expected columns: ${assigneeBulkUploadExpectedHeaders.join(', ')}',
      );
    }

    final parsedRows = <AssigneeBulkRow>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String valueAt(String header) {
        final colIndex = assigneeBulkUploadExpectedHeaders.indexOf(header);
        if (colIndex >= row.length) return '';
        return _cellText(row[colIndex]?.value);
      }

      final parsed = AssigneeBulkRow(
        email: valueAt('Email'),
        policyName: valueAt('Policy Name'),
        controlNames: valueAt('Control Name'),
      );

      final isBlankRow = [parsed.email, parsed.policyName, parsed.controlNames]
          .every((value) => value.isEmpty);
      if (isBlankRow) continue;

      parsedRows.add(parsed);
    }

    return parsedRows.isEmpty
        ? AssigneeExcelParseEmpty()
        : AssigneeExcelParseSuccess(parsedRows);
  }

  return AssigneeExcelParseEmpty();
}

bool _headersMatch(List<String> actualHeaders) {
  if (actualHeaders.length != assigneeBulkUploadExpectedHeaders.length) {
    return false;
  }
  for (var i = 0; i < actualHeaders.length; i++) {
    if (actualHeaders[i].trim() != assigneeBulkUploadExpectedHeaders[i]) {
      return false;
    }
  }
  return true;
}

/// Extracts plain display text from any [CellValue]. See
/// policy_excel_parser.dart's identical helper for why TextCellValue's
/// toString() is safe to use directly here.
String _cellText(CellValue? value) {
  return switch (value) {
    null => '',
    TextCellValue() => value.value.toString().trim(),
    IntCellValue() => value.value.toString(),
    DoubleCellValue() => _trimTrailingZero(value.value),
    BoolCellValue() => value.value.toString(),
    FormulaCellValue() => value.formula.trim(),
    DateCellValue() => value.asDateTimeLocal().toString(),
    DateTimeCellValue() => DateTime(value.year, value.month, value.day).toString(),
    TimeCellValue() => value.toString(),
  };
}

String _trimTrailingZero(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
