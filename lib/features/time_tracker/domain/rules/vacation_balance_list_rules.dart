/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_list_rules.dart
/// Purpose: Declares `VacationBalanceRow` (one line of the Vacation Balances
///          tab), `VacationBalanceList` (rows, search, department filter) and
///          `VacationBalanceEditRules` (the Edit dialog's Total Days check
///          and the balance it saves).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Brief §B (`Vacation_Balance_Permissions`): one row per company employee —
/// Employee · Department · Year · Total Days · Used · Remaining. An employee
/// with no stored balance still has a row (0 days) so HR can set it. Days
/// may be fractional (one decimal). Pure Dart — unit-tested.
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are one
/// document per employee per YEAR — the tab lists the SELECTED year
/// ([VacationBalanceYears]); a balance of another year is never shown in its
/// place (no roll-over). Remaining is always computed (Total − Used).

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';

/// ADDED 9/10/2026 (data model): the years the Vacation Balances tab offers.
class VacationBalanceYears {
  const VacationBalanceYears._();

  /// Years before the current one in the Year selector.
  static const int pastYears = 3;

  /// Years after the current one (HR may set next year's balances ahead).
  static const int futureYears = 1;

  /// Function Name: [selectable]
  ///
  /// Purpose: The Year selector's entries, newest first: [currentYear] + 1
  /// down to [currentYear] − 3.
  ///
  /// Return type: [List<int>]
  static List<int> selectable(int currentYear) => List<int>.unmodifiable(<int>[
        for (int y = currentYear + futureYears; y >= currentYear - pastYears; y--) y,
      ]);
}

/// One employee and their balance for the selected year.
class VacationBalanceRow {
  const VacationBalanceRow({required this.employee, required this.balance, this.isStored = false});

  final TimeTrackerEmployee employee;

  /// The stored balance of the year, or 0 days when none is stored.
  final VacationBalance balance;

  /// A balance document exists for the employee.
  final bool isStored;
}

class VacationBalanceList {
  const VacationBalanceList._();

  static String _norm(String v) => v.trim().toLowerCase();

  /// Function Name: [rows]
  ///
  /// Purpose: One row per employee with the balance of [year] (none stored
  /// for that year → 0 days), sorted by name.
  ///
  /// Parameters:
  ///   [List<TimeTrackerEmployee>] employees
  ///   [List<VacationBalance>] balances: stored balances (other years are
  ///     ignored).
  ///   [int] year: the selected year.
  ///   [bool] isArabic: sort by the name in the app language.
  ///
  /// Return type: [List<VacationBalanceRow>]
  static List<VacationBalanceRow> rows({
    required List<TimeTrackerEmployee> employees,
    required List<VacationBalance> balances,
    required int year,
    bool isArabic = false,
  }) {
    final Map<String, VacationBalance> byEmail = <String, VacationBalance>{
      for (final VacationBalance b in balances)
        if (b.year == year) _norm(b.employeeEmail): b,
    };
    final List<VacationBalanceRow> out = <VacationBalanceRow>[
      for (final TimeTrackerEmployee e in employees)
        if (_norm(e.email).isNotEmpty) _row(e, byEmail[_norm(e.email)], year),
    ]..sort((VacationBalanceRow a, VacationBalanceRow b) =>
        a.employee.name(isArabic: isArabic).toLowerCase().compareTo(b.employee.name(isArabic: isArabic).toLowerCase()));
    return List<VacationBalanceRow>.unmodifiable(out);
  }

  static VacationBalanceRow _row(TimeTrackerEmployee e, VacationBalance? stored, int year) {
    if (stored == null) {
      return VacationBalanceRow(
        employee: e,
        balance: VacationBalance(employeeEmail: _norm(e.email), year: year),
      );
    }
    return VacationBalanceRow(employee: e, balance: stored, isStored: true);
  }

  /// Function Name: [filter]
  ///
  /// Purpose: [rows] matching [query] (names, title, department, e-mail) and
  /// [departmentId] ('' = every department) and [departmentIds] (13/10/2026,
  /// owner: multi-select; empty = every department).
  ///
  /// Return type: [List<VacationBalanceRow>]
  static List<VacationBalanceRow> filter(
    List<VacationBalanceRow> rows, {
    String query = '',
    String departmentId = '',
    Set<String> departmentIds = const <String>{},
  }) {
    final String q = query.trim().toLowerCase();
    final String dep = departmentId.trim();
    return List<VacationBalanceRow>.unmodifiable(<VacationBalanceRow>[
      for (final VacationBalanceRow r in rows)
        if ((q.isEmpty || r.employee.searchText.contains(q)) &&
            (dep.isEmpty || r.employee.departmentId.trim() == dep) &&
            (departmentIds.isEmpty || departmentIds.contains(r.employee.departmentId.trim())))
          r,
    ]);
  }

  /// Function Name: [days]
  ///
  /// Purpose: A day count as text: whole numbers without decimals, else
  /// one decimal ("21", "2.5").
  ///
  /// Return type: [String]
  static String days(double value) => value == value.roundToDouble() ? '${value.round()}' : value.toStringAsFixed(1);
}

/// Why a Total Days value cannot be saved.
enum VacationTotalError { required, invalid, tooLarge }

class VacationBalanceEditRules {
  const VacationBalanceEditRules._();

  /// A year has at most 366 days.
  static const double maxTotalDays = 366;

  /// Function Name: [parseTotal]
  ///
  /// Purpose: Read a typed Total Days ("21", "12.5", Arabic digits too).
  ///
  /// Return type: [double?] — null when blank or unreadable.
  static double? parseTotal(String text) {
    const String eastern = '٠١٢٣٤٥٦٧٨٩';
    final StringBuffer b = StringBuffer();
    for (final int c in text.trim().runes) {
      final String ch = String.fromCharCode(c);
      final int i = eastern.indexOf(ch);
      b.write(i >= 0 ? '$i' : (ch == '٫' || ch == ',' ? '.' : ch));
    }
    final String s = b.toString();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  /// Function Name: [validate]
  ///
  /// Purpose: The problem with [text] as Total Days, or null when valid
  /// (0 … 366, at most one decimal).
  ///
  /// Return type: [VacationTotalError?]
  static VacationTotalError? validate(String text) {
    if (text.trim().isEmpty) return VacationTotalError.required;
    final double? v = parseTotal(text);
    // One decimal at most (2.3 × 10 is 22.999… in binary — compare loosely).
    if (v == null || v.isNaN || v < 0 || ((v * 10) - (v * 10).round()).abs() > 1e-6) {
      return VacationTotalError.invalid;
    }
    if (v > maxTotalDays) return VacationTotalError.tooLarge;
    return null;
  }

  /// Function Name: [apply]
  ///
  /// Purpose: The balance to save when HR sets [totalDays] for [year]:
  /// [stored] (the SAME year's balance — used days kept) with the new total,
  /// or a new balance with nothing used. A [stored] balance of another year
  /// is ignored (9/10/2026: one document per year, no roll-over).
  ///
  /// Parameters:
  ///   [String] email
  ///   [VacationBalance?] stored
  ///   [int] year
  ///   [double] totalDays
  ///
  /// Return type: [VacationBalance]
  static VacationBalance apply({
    required String email,
    required VacationBalance? stored,
    required int year,
    required double totalDays,
  }) {
    final VacationBalance? old = stored;
    if (old == null || old.year != year) {
      return VacationBalance(employeeEmail: email.trim().toLowerCase(), year: year, totalDays: totalDays);
    }
    return old.copyWith(totalDays: totalDays);
  }
}
