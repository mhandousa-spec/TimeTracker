/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance.dart
/// Purpose: Declares `VacationBalance` — one employee's vacation days for ONE
///          year ("Vacations Credit" tile, Vacation Balances tab).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 11 (8/10/2026): the balance ALWAYS lives in Time Tracker,
/// with or without HR. Days may be fractional (a few hours off count as part
/// of a day).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): ONE document per employee
/// per year (`Vacation_Balances/{email}_{year}`); a new year is a new
/// document — nothing rolls over. Remaining is NEVER stored: it is always
/// [totalDays] − [usedDays] ([remainingDays]).
///
/// Plain immutable Dart: no Firestore, no Flutter.

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';

class VacationBalance {
  const VacationBalance({
    required this.employeeEmail,
    required this.year,
    this.totalDays = 0,
    this.usedDays = 0,
    this.audit = AuditInfo.none,
  });

  /// Lower-cased; with [year] it makes the document id `{email}_{year}`.
  final String employeeEmail;

  /// The calendar year this balance belongs to (never changes).
  final int year;
  final double totalDays;
  final double usedDays;
  final AuditInfo audit;

  /// Days still available: `Total_Days − Used_Days`, computed (never
  /// stored), never below zero.
  double get remainingDays {
    final double left = totalDays - usedDays;
    return left < 0 ? 0 : left;
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update (the year never changes — another year is
  /// another balance).
  ///
  /// Return type: [VacationBalance]
  VacationBalance copyWith({double? totalDays, double? usedDays}) => VacationBalance(
        employeeEmail: employeeEmail,
        year: year,
        totalDays: totalDays ?? this.totalDays,
        usedDays: usedDays ?? this.usedDays,
        audit: audit,
      );
}
