/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_model.dart
/// Purpose: Declares `VacationBalanceModel` — Firestore <-> `VacationBalance`
///          mapping for one `Vacation_Balances/{email}_{year}` history
///          document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim, plus the audit trio.
/// Updated: 9/10/2026 - owner standing rule: a document never stores its own
/// id — `Vacation_Balance_Id` is no longer written (the id comes from the
/// snapshot; an old document that still has the field is read as before and
/// the history codec simply carries it).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): one document per employee
/// per YEAR — id `{lower-case email}_{year}` ([docIdOf]); `Remaining_Days`
/// is NO LONGER written (always computed `Total_Days − Used_Days` —
/// `VacationBalance.remainingDays`; an old stored value is ignored on read).
/// [isYearDocument] tells a per-year document from an old `{email}` one, so
/// the old layout is never mistaken for a balance (migration: see
/// `Documents/Time Tracker Module/migrations/`).

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';

typedef _F = TimeTrackerFieldCodec;

class VacationBalanceModel {
  const VacationBalanceModel._();

  /// LEGACY, read-tolerated only — never written since 9/10/2026 (owner
  /// rule: no self-id inside a document).
  static const String fLegacyBalanceId = 'Vacation_Balance_Id';
  static const String fEmployeeEmail = 'Employee_Email';
  static const String fBalanceYear = 'Balance_Year';
  static const String fTotalDays = 'Total_Days';
  static const String fUsedDays = 'Used_Days';

  /// Function Name: [docIdOf]
  ///
  /// Purpose: The document id of [balance] — `{email}_{year}`.
  ///
  /// Return type: [String] — throws `StateError` on a bad email / year.
  static String docIdOf(VacationBalance balance) =>
      TimeTrackerFirestorePaths.vacationBalanceDocId(balance.employeeEmail, balance.year);

  /// Function Name: [yearOfId]
  ///
  /// Purpose: The year at the end of a `{email}_{year}` id, or null.
  ///
  /// Return type: [int?]
  static int? yearOfId(String id) {
    final int at = id.lastIndexOf('_');
    if (at <= 0 || at == id.length - 1) return null;
    final String tail = id.substring(at + 1);
    if (tail.length != 4) return null;
    return int.tryParse(tail);
  }

  /// Function Name: [isYearDocument]
  ///
  /// Purpose: [id] is the per-year id of the stored `Employee_Email` and
  /// `Balance_Year` (`{email}_{year}`) — false for the old `{email}` layout
  /// or a hand-made document.
  ///
  /// Return type: [bool]
  static bool isYearDocument(String id, Map<String, dynamic> map) {
    final String email = _F.string(TimeTrackerHistoryCodec.lastOf(map, fEmployeeEmail)).trim().toLowerCase();
    final Object? year = TimeTrackerHistoryCodec.lastOf(map, fBalanceYear);
    if (email.isEmpty || year is! num || year < 1000 || year > 9999) return false;
    return id == '${email}_${year.toInt()}';
  }

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  /// The year falls back to the id's year (`{email}_{year}`).
  ///
  /// Return type: [VacationBalance]
  static VacationBalance fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final String email = _F.string(now(fEmployeeEmail));
    final int? idYear = yearOfId(id);
    return VacationBalance(
      employeeEmail: email.isNotEmpty ? email : (idYear == null ? id : id.substring(0, id.lastIndexOf('_'))),
      year: _F.integer(now(fBalanceYear), fallback: idYear ?? 0),
      totalDays: _F.decimal(now(fTotalDays)),
      usedDays: _F.decimal(now(fUsedDays)),
      audit: _F.auditOf(map),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row
  /// (no `Remaining_Days` — computed, never stored; no self-id — the
  /// document id is `{email}_{year}`, 9/10/2026). [id] is kept in the
  /// signature for the shared repository contract.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    VacationBalance balance, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fEmployeeEmail: balance.employeeEmail.trim().toLowerCase(),
        fBalanceYear: balance.year,
        fTotalDays: balance.totalDays,
        fUsedDays: balance.usedDays,
        ...audit.fields,
      };
}
