/// Module: GRC Control Bulk Upload
/// Description: Parses an uploaded Excel (.xlsx/.xls) workbook of Controls
///              into raw [ControlBulkRow] values, scoped to a single
///              Policy. Validates the header row against the fixed
///              expected column list before reading any data — mirrors
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: excel package, policy_bulk_date_format.dart
library;

import 'package:knowticed_plus/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;

/// The sheet's header row must match this list exactly, in order.
const List<String> controlBulkUploadExpectedHeaders = [
  'Control Name',
  'اسم ضابط',
  'Control Number',
  'رقم ضابط',
  'Control Description',
  'وصف ضابط',
  'Start Date',
  'End Date',
  'Control Weight',
  'Frequency',
  'Control Champion',
  'Control Owner',
  'Applied Departments',
  'Department Weight',
];

/// class name: [ControlBulkRow]
///
/// purpose: one raw, unvalidated data row parsed from the uploaded sheet.
class ControlBulkRow {
  final String controlNameEn;
  final String controlNameAr;
  final String controlNumberEn;
  final String controlNumberAr;
  final String controlDescriptionEn;
  final String controlDescriptionAr;
  final String startDate;
  final String endDate;
  final String controlWeight;
  final String frequency;
  final String controlChampion;
  final String controlOwner;
  final String appliedDepartments;
  final String departmentWeight;

  const ControlBulkRow({
    required this.controlNameEn,
    required this.controlNameAr,
    required this.controlNumberEn,
    required this.controlNumberAr,
    required this.controlDescriptionEn,
    required this.controlDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.controlWeight,
    required this.frequency,
    required this.controlChampion,
    required this.controlOwner,
    required this.appliedDepartments,
    required this.departmentWeight,
  });
}

sealed class ControlExcelParseResult {}

class ControlExcelParseSuccess extends ControlExcelParseResult {
  final List<ControlBulkRow> rows;
  ControlExcelParseSuccess(this.rows);
}

class ControlExcelParseHeaderMismatch extends ControlExcelParseResult {
  final String message;
  ControlExcelParseHeaderMismatch(this.message);
}

class ControlExcelParseEmpty extends ControlExcelParseResult {}

/// function name: [parseControlExcel]
///
/// purpose: decode an uploaded workbook's bytes, validate its header row
///          against [controlBulkUploadExpectedHeaders], and parse every
///          non-blank data row into a [ControlBulkRow].
ControlExcelParseResult parseControlExcel(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return ControlExcelParseEmpty();

  for (final tableName in excel.tables.keys) {
    final sheet = excel.tables[tableName];
    if (sheet == null || sheet.rows.isEmpty) continue;

    final rows = sheet.rows;
    final actualHeaders = rows.first.map((cell) => _cellText(cell?.value)).toList();
    while (actualHeaders.isNotEmpty && actualHeaders.last.isEmpty) {
      actualHeaders.removeLast();
    }

    if (!_headersMatch(actualHeaders)) {
      return ControlExcelParseHeaderMismatch(
        'Expected columns: ${controlBulkUploadExpectedHeaders.join(', ')}',
      );
    }

    final parsedRows = <ControlBulkRow>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String valueAt(String header) {
        final colIndex = controlBulkUploadExpectedHeaders.indexOf(header);
        if (colIndex >= row.length) return '';
        return _cellText(row[colIndex]?.value);
      }

      final parsed = ControlBulkRow(
        controlNameEn: valueAt('Control Name'),
        controlNameAr: valueAt('اسم ضابط'),
        controlNumberEn: valueAt('Control Number'),
        controlNumberAr: valueAt('رقم ضابط'),
        controlDescriptionEn: valueAt('Control Description'),
        controlDescriptionAr: valueAt('وصف ضابط'),
        startDate: valueAt('Start Date'),
        endDate: valueAt('End Date'),
        controlWeight: valueAt('Control Weight'),
        frequency: valueAt('Frequency'),
        controlChampion: valueAt('Control Champion'),
        controlOwner: valueAt('Control Owner'),
        appliedDepartments: valueAt('Applied Departments'),
        departmentWeight: valueAt('Department Weight'),
      );

      final isBlankRow = [
        parsed.controlNameEn,
        parsed.controlNameAr,
        parsed.controlNumberEn,
        parsed.controlNumberAr,
        parsed.controlDescriptionEn,
        parsed.controlDescriptionAr,
        parsed.startDate,
        parsed.endDate,
        parsed.controlWeight,
        parsed.frequency,
        parsed.controlChampion,
        parsed.controlOwner,
        parsed.appliedDepartments,
        parsed.departmentWeight,
      ].every((value) => value.isEmpty);
      if (isBlankRow) continue;

      parsedRows.add(parsed);
    }

    return parsedRows.isEmpty ? ControlExcelParseEmpty() : ControlExcelParseSuccess(parsedRows);
  }

  return ControlExcelParseEmpty();
}

bool _headersMatch(List<String> actualHeaders) {
  if (actualHeaders.length != controlBulkUploadExpectedHeaders.length) return false;
  for (var i = 0; i < actualHeaders.length; i++) {
    if (actualHeaders[i].trim() != controlBulkUploadExpectedHeaders[i]) return false;
  }
  return true;
}

/// Extracts plain display text from any [CellValue].
String _cellText(CellValue? value) {
  return switch (value) {
    null => '',
    TextCellValue() => value.value.toString().trim(),
    IntCellValue() => value.value.toString(),
    DoubleCellValue() => _trimTrailingZero(value.value),
    BoolCellValue() => value.value.toString(),
    FormulaCellValue() => value.formula.trim(),
    DateCellValue() => formatPolicyBulkDate(value.asDateTimeLocal()),
    DateTimeCellValue() =>
      formatPolicyBulkDate(DateTime(value.year, value.month, value.day)),
    TimeCellValue() => value.toString(),
  };
}

String _trimTrailingZero(double value) {
  return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
