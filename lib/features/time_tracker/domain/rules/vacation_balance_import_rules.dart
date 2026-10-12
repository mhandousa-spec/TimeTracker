/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_import_rules.dart
/// Purpose: Declares `VacationBalanceImportRules` (template columns and the
///          planner that turns an uploaded sheet into a preview) and its
///          result types `VacationImportPlan` / `VacationImportRow`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Import Vacation Balances (`Import_Vacation_Balances`, brief §B). Template
/// = Email · Year · Total Days (English headings, matched case-insensitively;
/// other columns ignored). Rules — same spirit as the locations import:
///   * a row whose e-mail is a company employee SETS their Total Days for
///     the year (creates the balance when none exists); used days are kept;
///   * the import writes ONE year — the year selected on the tab: a blank
///     Year means that year; any other year is skipped ("wrong year");
///   * nothing is ever deleted; a row with a problem (unknown e-mail, bad
///     number, duplicate e-mail) is skipped and the rest still import.
/// Pure Dart (the file reading lives in the data layer), unit-tested.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are one
/// document per employee per year (`{email}_{year}`); the import targets the
/// tab's selected year (it used to be the current year only) and nothing
/// rolls over.

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_list_rules.dart';

/// The template columns, in file order (English: machine-read in both
/// languages).
enum VacationImportColumn {
  email('Email'),
  year('Year'),
  totalDays('Total Days');

  const VacationImportColumn(this.heading);

  final String heading;
}

enum VacationImportAction { create, update, unchanged, skip }

/// Why a row is skipped.
enum VacationImportIssue { unknownEmployee, duplicateEmail, wrongYear, totalRequired, totalInvalid, totalTooLarge }

class VacationImportRow {
  const VacationImportRow({
    required this.line,
    required this.email,
    required this.action,
    this.balance,
    this.issues = const <VacationImportIssue>[],
  });

  /// 1-based line in the file (the heading row is line 1).
  final int line;
  final String email;
  final VacationImportAction action;

  /// What will be saved (create / update only).
  final VacationBalance? balance;
  final List<VacationImportIssue> issues;
}

class VacationImportPlan {
  const VacationImportPlan({this.rows = const <VacationImportRow>[], this.missingColumns = false, this.year = 0});

  final List<VacationImportRow> rows;

  /// The file has no "Email" or no "Total Days" heading.
  final bool missingColumns;

  /// The year the import writes.
  final int year;

  int count(VacationImportAction action) => rows.where((VacationImportRow r) => r.action == action).length;

  /// The rows that will be written.
  List<VacationImportRow> get writable => <VacationImportRow>[
        for (final VacationImportRow r in rows)
          if (r.action == VacationImportAction.create || r.action == VacationImportAction.update) r,
      ];
}

class VacationBalanceImportRules {
  const VacationBalanceImportRules._();

  static String _norm(String v) => v.trim().toLowerCase();

  /// The template heading row.
  static List<String> get headings => <String>[
        for (final VacationImportColumn c in VacationImportColumn.values) c.heading,
      ];

  /// Function Name: [templateRow]
  ///
  /// Purpose: One employee's line of the downloadable template.
  ///
  /// Return type: [List<String>]
  static List<String> templateRow(VacationBalanceRow row) => <String>[
        row.employee.email,
        '${row.balance.year}',
        VacationBalanceList.days(row.balance.totalDays),
      ];

  /// Function Name: [plan]
  ///
  /// Purpose: The preview of importing [grid] (first row = headings).
  ///
  /// Parameters:
  ///   [List<List<String>>] grid
  ///   [List<TimeTrackerEmployee>] employees: the company's employees.
  ///   [List<VacationBalance>] stored: the stored balances (other years
  ///     are ignored).
  ///   [int] year: the year the import writes (the tab's selected year).
  ///
  /// Return type: [VacationImportPlan]
  static VacationImportPlan plan({
    required List<List<String>> grid,
    required List<TimeTrackerEmployee> employees,
    required List<VacationBalance> stored,
    required int year,
  }) {
    if (grid.isEmpty) return VacationImportPlan(missingColumns: true, year: year);
    final Map<VacationImportColumn, int> at = <VacationImportColumn, int>{};
    for (int i = 0; i < grid.first.length; i++) {
      final String h = _norm(grid.first[i]);
      for (final VacationImportColumn c in VacationImportColumn.values) {
        if (_norm(c.heading) == h) at[c] = i;
      }
    }
    if (!at.containsKey(VacationImportColumn.email) || !at.containsKey(VacationImportColumn.totalDays)) {
      return VacationImportPlan(missingColumns: true, year: year);
    }
    final Set<String> known = <String>{for (final TimeTrackerEmployee e in employees) _norm(e.email)};
    final Map<String, VacationBalance> byEmail = <String, VacationBalance>{
      for (final VacationBalance b in stored)
        if (b.year == year) _norm(b.employeeEmail): b,
    };
    final Set<String> seen = <String>{};
    final List<VacationImportRow> rows = <VacationImportRow>[];
    for (int r = 1; r < grid.length; r++) {
      if (grid[r].every((String v) => v.trim().isEmpty)) continue;
      String cell(VacationImportColumn c) {
        final int? i = at[c];
        return i == null || i >= grid[r].length ? '' : grid[r][i].trim();
      }

      final String email = _norm(cell(VacationImportColumn.email));
      if (email.isNotEmpty && !seen.add(email)) {
        rows.add(VacationImportRow(
          line: r + 1,
          email: email,
          action: VacationImportAction.skip,
          issues: const <VacationImportIssue>[VacationImportIssue.duplicateEmail],
        ));
        continue;
      }
      rows.add(_row(
        line: r + 1,
        email: email,
        yearText: cell(VacationImportColumn.year),
        totalText: cell(VacationImportColumn.totalDays),
        known: known.contains(email),
        stored: byEmail[email],
        year: year,
      ));
    }
    return VacationImportPlan(rows: List<VacationImportRow>.unmodifiable(rows), year: year);
  }

  static VacationImportRow _row({
    required int line,
    required String email,
    required String yearText,
    required String totalText,
    required bool known,
    required VacationBalance? stored,
    required int year,
  }) {
    final List<VacationImportIssue> issues = <VacationImportIssue>[
      if (!known) VacationImportIssue.unknownEmployee,
    ];
    final double? yearValue = yearText.isEmpty ? year.toDouble() : VacationBalanceEditRules.parseTotal(yearText);
    if (yearValue == null || yearValue != year.toDouble()) issues.add(VacationImportIssue.wrongYear);
    switch (VacationBalanceEditRules.validate(totalText)) {
      case VacationTotalError.required:
        issues.add(VacationImportIssue.totalRequired);
      case VacationTotalError.invalid:
        issues.add(VacationImportIssue.totalInvalid);
      case VacationTotalError.tooLarge:
        issues.add(VacationImportIssue.totalTooLarge);
      case null:
        break;
    }
    if (issues.isNotEmpty) {
      return VacationImportRow(
        line: line,
        email: email,
        action: VacationImportAction.skip,
        issues: List<VacationImportIssue>.unmodifiable(issues),
      );
    }
    final double total = VacationBalanceEditRules.parseTotal(totalText)!;
    final VacationBalance next =
        VacationBalanceEditRules.apply(email: email, stored: stored, year: year, totalDays: total);
    final VacationBalance? old = stored;
    final VacationImportAction action = old == null
        ? VacationImportAction.create
        : (old.year == next.year && old.totalDays == next.totalDays && old.usedDays == next.usedDays
            ? VacationImportAction.unchanged
            : VacationImportAction.update);
    return VacationImportRow(line: line, email: email, action: action, balance: next);
  }
}
