/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_base_repository.dart
/// Purpose: Declares `VacationBalanceBaseRepository` — the contract for vacation balances.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Error policy (MASTER_CODE_REVIEW §0.2 C1 — try/catch, not Either): every
/// method either completes or throws an `Exception` whose message is safe to
/// show. Raw `FirebaseException`s never cross this boundary.
/// Updated: 9/10/2026 - phase 5: [watchBalance].
/// Updated: 9/10/2026 - data model (owner, 9 Oct): ONE document per employee
/// per year (`Vacation_Balances/{email}_{year}`). Every read names its YEAR;
/// a year with no document = no balance (null). The 1 January roll-over and
/// `fetchCurrentBalance` are gone; `watchBalances()` (whole collection) is
/// replaced by [watchBalancesOfYear]; [fetchBalancesOf] (every year of one
/// employee — the request form) and [setTotalDays] (HR edit / import, used
/// days kept inside the same transaction) are new. Documents whose id is not
/// `{email}_{year}` (the old `{email}` layout) are never read as balances —
/// run the migration (`Documents/Time Tracker Module/migrations/`).

import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';

abstract class VacationBalanceBaseRepository {
  /// Function Name: [watchBalancesOfYear]
  ///
  /// Purpose: Live list of every employee's balance for [year] (the
  /// Vacation Balances tab — a `Balance_Year` array-contains query).
  ///
  /// Return type: [Stream<List<VacationBalance>>]
  Stream<List<VacationBalance>> watchBalancesOfYear({required int year});

  /// Function Name: [watchBalance]
  ///
  /// Purpose: Live balance of ONE employee for [year], so the "Vacations
  /// Credit" tile follows an HR edit / import / deduction at once.
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///   [int] year
  ///
  /// Return type: [Stream<VacationBalance?>] — null while none is stored.
  Stream<VacationBalance?> watchBalance({required String employeeEmail, required int year});

  /// Function Name: [fetchBalance]
  ///
  /// Purpose: One employee's balance for [year], or null when none is stored
  /// (a pure read — nothing is ever written by a read).
  ///
  /// Parameters:
  ///   [String] employeeEmail
  ///   [int] year
  ///
  /// Return type: [Future<VacationBalance?>]
  Future<VacationBalance?> fetchBalance({required String employeeEmail, required int year});

  /// Function Name: [fetchBalancesOf]
  ///
  /// Purpose: Every stored year of one employee (the request form checks the
  /// balance of the year the request starts in).
  ///
  /// Return type: [Future<List<VacationBalance>>]
  Future<List<VacationBalance>> fetchBalancesOf({required String employeeEmail});

  /// Function Name: [saveBalance]
  ///
  /// Purpose: Append [balance] as the next row of its `{email}_{year}`
  /// document (created on the first save) — as given, no merge.
  ///
  /// Parameters:
  ///   [VacationBalance] balance
  ///
  /// Return type: [Future<VacationBalance>] — as stored.
  Future<VacationBalance> saveBalance({required VacationBalance balance});

  /// Function Name: [setTotalDays]
  ///
  /// Purpose: HR edit / import — set [employeeEmail]'s `Total_Days` for
  /// [year]. Read and written in ONE transaction: the used days stored at
  /// that moment are kept (a deduction made meanwhile is never lost); no
  /// document yet → created with 0 used.
  ///
  /// Return type: [Future<VacationBalance>] — as stored.
  Future<VacationBalance> setTotalDays({
    required String employeeEmail,
    required int year,
    required double totalDays,
  });
}
