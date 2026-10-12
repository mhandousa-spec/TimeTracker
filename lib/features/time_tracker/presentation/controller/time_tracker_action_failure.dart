/// Module: time_tracker / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_action_failure.dart
/// Purpose: Declares `TimeTrackerActionFailure` — why the last save of a
///          set-up cubit failed (none / no permission / other) — and
///          `timeTrackerFailureOf`, which classifies a caught error.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase 3: the set-up cubits (Locations, Employees, Groups, Request Types)
/// return `bool` to `CustomDialogManager.showDialogFlow` and keep the reason
/// here, so the page can show "no permission" or "could not be saved"
/// (`showTimeTrackerFailure`) after the flow closes.

/// Updated: 9/10/2026 - code review: [TimeTrackerActionFailure.changed]
/// (someone else saved the request first — finding 2) and
/// [TimeTrackerActionFailure.noBalance] (a deducting request without a
/// vacation balance — finding 10), each with its own message.
/// Updated: 9/10/2026 - owner round 9 option b: [TimeTrackerActionFailure.
/// balanceShort] (a year of the request has too few vacation days left) and
/// [timeTrackerBalanceYearOf] (the year + days left the message names, also
/// for a year with no balance — 0 days).

import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';

enum TimeTrackerActionFailure { none, denied, failed, changed, noBalance, balanceShort }

/// Function Name: [timeTrackerFailureOf]
///
/// Purpose: [TimeTrackerActionFailure.denied] for a permission refusal,
/// [TimeTrackerActionFailure.changed] / [TimeTrackerActionFailure.noBalance]
/// for those refusals (9/10/2026), [TimeTrackerActionFailure.failed] for
/// anything else.
///
/// Return type: [TimeTrackerActionFailure]
TimeTrackerActionFailure timeTrackerFailureOf(Object error) {
  if (error is TimeTrackerPermissionDenied) return TimeTrackerActionFailure.denied;
  if (error is TimeTrackerRecordChanged) return TimeTrackerActionFailure.changed;
  if (error is TimeTrackerNoVacationBalance) return TimeTrackerActionFailure.noBalance;
  if (error is TimeTrackerYearBalanceShort) return TimeTrackerActionFailure.balanceShort;
  return TimeTrackerActionFailure.failed;
}

/// Function Name: [timeTrackerBalanceYearOf]
///
/// Purpose: ADDED 9/10/2026 (owner round 9 option b) — the year and the days
/// left a balance refusal names ("2027 has only 2 days left"; a year with
/// no balance = 0 days), or null for any other error / an unknown year.
///
/// Return type: [(int, double)?]
(int, double)? timeTrackerBalanceYearOf(Object error) {
  if (error is TimeTrackerYearBalanceShort) return (error.year, error.daysLeft);
  if (error is TimeTrackerNoVacationBalance) {
    final int? year = error.year;
    return year == null ? null : (year, 0);
  }
  return null;
}
