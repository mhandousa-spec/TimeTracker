/// Module: roles / r2_user_management / presentation / ui / pages / bulk_access_upload
///
///*************************** FILE INFO ****************************///
/// File Name: access_bulk_upload_parser.dart
/// Purpose: Reads a User Management import workbook (.xlsx / .xls) into raw
///          rows. No validation happens here — that is
///          `AccessBulkUploadRows`' job, against the live employee and role
///          lists.
/// Author: Knowticed Plus team
/// Created At: 21/9/2026 — bug report p.1, "where is the import button?".
///          Modelled on the GRC assignee importer (`assignee_excel_parser.dart`),
///          which is the cleaned-up form of the services bulk upload
///          (`s4_bulk_upload_services`).
///
/// Columns (Figma 4717:36048): Employee ID, Email, Current Role Type,
/// Desired Role Type, Access Granted, Access Revoked, Status.
///
/// Headers are matched by NAME (case- and space-insensitive), not position, so
/// a sheet with the columns in another order, or with extra columns, still
/// reads. Current Role Type and Status are accepted but ignored — both are
/// derived on the review screen from live data, never trusted from a file.
library;

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;

/// Every column the template carries, in template order.
const List<String> accessBulkUploadHeaders = <String>[
  'Employee ID',
  'Email',
  'Current Role Type',
  'Desired Role Type',
  'Access Granted',
  'Access Revoked',
  'Status',
];

/// Columns a file must have. The employee may be identified by EITHER
/// Employee ID or Email, so neither is required on its own — see
/// [_missingRequiredHeaders].
const List<String> _requiredHeaders = <String>[
  'Desired Role Type',
  'Access Granted',
  'Access Revoked',
];

/// One data row, exactly as the file had it (trimmed text).
class AccessBulkRawRow {
  final String employeeId;
  final String email;
  final String desiredRole;
  final String accessGranted;
  final String accessRevoked;

  const AccessBulkRawRow({
    required this.employeeId,
    required this.email,
    required this.desiredRole,
    required this.accessGranted,
    required this.accessRevoked,
  });

  bool get isBlank => <String>[
        employeeId,
        email,
        desiredRole,
        accessGranted,
        accessRevoked,
      ].every((String v) => v.isEmpty);
}

sealed class AccessBulkParseResult {}

class AccessBulkParseSuccess extends AccessBulkParseResult {
  final List<AccessBulkRawRow> rows;
  AccessBulkParseSuccess(this.rows);
}

/// The file could not be read, or lacks required columns. [missingHeaders]
/// is empty when the workbook itself was unreadable.
class AccessBulkParseInvalid extends AccessBulkParseResult {
  final List<String> missingHeaders;
  AccessBulkParseInvalid(this.missingHeaders);
}

class AccessBulkParseEmpty extends AccessBulkParseResult {}

/// Parses an import file by its extension: `.csv`, otherwise a workbook.
/// ADDED 21/9/2026 — CSV is accepted too, so a sheet the `excel` package
/// cannot open can still be imported by saving it as CSV.
AccessBulkParseResult parseAccessBulkFile(List<int> bytes, String fileName) {
  return fileName.toLowerCase().endsWith('.csv')
      ? parseAccessBulkCsv(bytes)
      : parseAccessBulkWorkbook(bytes);
}

/// Parses the first worksheet that has a header row.
AccessBulkParseResult parseAccessBulkWorkbook(List<int> bytes) {
  // The excel package throws on some workbooks it cannot resolve; the GRC
  // importer documents a spinner left running forever when this escaped.
  final Excel excel;
  try {
    excel = Excel.decodeBytes(_withRelativeTargets(bytes));
  } catch (e) {
    // ignore: avoid_print
    assert(() {
      print('[access-import] workbook could not be decoded: $e');
      return true;
    }());
    return AccessBulkParseInvalid(const <String>[]);
  }
  if (excel.tables.isEmpty) return AccessBulkParseEmpty();

  for (final String tableName in excel.tables.keys) {
    final Sheet? sheet = excel.tables[tableName];
    if (sheet == null || sheet.rows.isEmpty) continue;

    final List<List<String>> rows = <List<String>>[
      for (final List<Data?> row in sheet.rows)
        <String>[for (final Data? cell in row) _cellText(cell?.value)],
    ];
    final AccessBulkParseResult? result = _fromRows(rows);
    if (result != null) return result;
  }

  return AccessBulkParseEmpty();
}

/// Parses a CSV export (UTF-8, optional BOM, comma-separated).
AccessBulkParseResult parseAccessBulkCsv(List<int> bytes) {
  final String text;
  try {
    text = utf8
        .decode(bytes, allowMalformed: true)
        .replaceFirst('\uFEFF', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
  } catch (_) {
    return AccessBulkParseInvalid(const <String>[]);
  }

  final List<List<dynamic>> table = Csv(autoDetect: false, skipEmptyLines: false).decode(text);

  final List<List<String>> rows = <List<String>>[
    for (final List<dynamic> row in table)
      <String>[for (final dynamic cell in row) '${cell ?? ''}'.trim()],
  ];
  return _fromRows(rows) ?? AccessBulkParseEmpty();
}

/// Shared by both formats. Returns null when [rows] has no header row at all
/// (an empty sheet), so the workbook path can try the next sheet.
AccessBulkParseResult? _fromRows(List<List<String>> rows) {
  if (rows.isEmpty) return null;

  final List<String> headers = rows.first.map(_normalise).toList();
  if (headers.every((String h) => h.isEmpty)) return null;

  final List<String> missing = _missingRequiredHeaders(headers);
  if (missing.isNotEmpty) return AccessBulkParseInvalid(missing);

  // Column index per template header; -1 when the file lacks it.
  int indexOf(String header) => headers.indexOf(_normalise(header));
  final int idCol = indexOf('Employee ID');
  final int emailCol = indexOf('Email');
  final int roleCol = indexOf('Desired Role Type');
  final int grantedCol = indexOf('Access Granted');
  final int revokedCol = indexOf('Access Revoked');

  final List<AccessBulkRawRow> parsed = <AccessBulkRawRow>[];
  for (int i = 1; i < rows.length; i++) {
    final List<String> row = rows[i];
    String at(int col) => col < 0 || col >= row.length ? '' : row[col].trim();

    final AccessBulkRawRow raw = AccessBulkRawRow(
      employeeId: at(idCol),
      email: at(emailCol),
      desiredRole: at(roleCol),
      accessGranted: at(grantedCol),
      accessRevoked: at(revokedCol),
    );
    if (!raw.isBlank) parsed.add(raw);
  }

  return parsed.isEmpty ? AccessBulkParseEmpty() : AccessBulkParseSuccess(parsed);
}

/// Rewrites absolute part targets (`Target="/xl/worksheets/sheet1.xml"`) in a
/// workbook's `.rels` files to the relative form Excel itself writes
/// (`worksheets/sheet1.xml`).
///
/// ADDED 21/9/2026. Both forms are valid OOXML, but the `excel` package only
/// resolves the relative one and throws on the other — so a workbook written
/// by openpyxl, pandas and several online converters could not be imported
/// ("This file could not be read"). Returns [bytes] untouched when nothing
/// needs rewriting or the file is not a zip at all (the decoder then reports
/// it as before).
List<int> _withRelativeTargets(List<int> bytes) {
  try {
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    final RegExp absolute = RegExp(r'Target="/([^"]*)"');
    bool changed = false;
    final Archive out = Archive();

    for (final ArchiveFile file in archive.files) {
      if (!file.isFile || !file.name.endsWith('.rels')) {
        out.addFile(file);
        continue;
      }

      // `xl/_rels/workbook.xml.rels` describes parts relative to `xl/`;
      // `_rels/.rels` describes them relative to the package root.
      final int relsAt = file.name.lastIndexOf('_rels/');
      final String base = relsAt <= 0 ? '' : file.name.substring(0, relsAt);

      final String xml = utf8.decode(file.content as List<int>);
      final String fixed = xml.replaceAllMapped(absolute, (Match m) {
        final String target = m.group(1)!;
        return target.startsWith(base)
            ? 'Target="${target.substring(base.length)}"'
            : m.group(0)!;
      });

      if (fixed == xml) {
        out.addFile(file);
      } else {
        changed = true;
        final List<int> data = utf8.encode(fixed);
        out.addFile(ArchiveFile(file.name, data.length, data));
      }
    }

    if (!changed) return bytes;
    return ZipEncoder().encode(out) ?? bytes;
  } catch (_) {
    return bytes;
  }
}

List<String> _missingRequiredHeaders(List<String> normalisedHeaders) {
  final List<String> missing = _requiredHeaders
      .where((String h) => !normalisedHeaders.contains(_normalise(h)))
      .toList();
  final bool hasIdentity =
      normalisedHeaders.contains(_normalise('Employee ID')) ||
          normalisedHeaders.contains(_normalise('Email'));
  if (!hasIdentity) missing.insert(0, 'Employee ID / Email');
  return missing;
}

/// "Employee  ID" / "employee id" / " Employee ID " all compare equal.
String _normalise(String header) =>
    header.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _cellText(CellValue? value) {
  return switch (value) {
    null => '',
    TextCellValue() => value.value.toString().trim(),
    IntCellValue() => value.value.toString(),
    DoubleCellValue() => _trimTrailingZero(value.value),
    BoolCellValue() => value.value.toString(),
    FormulaCellValue() => value.formula.trim(),
    // ISO text, so `parseAccessDate` reads it back without guessing.
    DateCellValue() => value.asDateTimeLocal().toIso8601String(),
    DateTimeCellValue() =>
      DateTime(value.year, value.month, value.day).toIso8601String(),
    TimeCellValue() => value.toString(),
  };
}

String _trimTrailingZero(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
