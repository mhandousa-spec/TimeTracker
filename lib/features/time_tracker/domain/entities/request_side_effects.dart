/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: request_side_effects.dart
/// Purpose: Declares `RequestSideEffects` — what a request's save does
///          OUTSIDE the request (vacation balance, attendance day) — and
///          `RequestCommit`, what one atomic save wrote.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (code review fixes)
///
/// Code review findings 2–4 (9/10/2026): the status change of a request and
/// its effects used to be separate writes (approved without the deduction
/// after a network drop, double deductions on a double tap, refunds
/// recomputed from inputs that had changed since). Now the services PLAN the
/// effects before saving (`RequestEffects`) and the repository writes the
/// request (compare-and-set on its revision), the balance and the
/// attendance day in ONE Firestore transaction — all or nothing.
///
/// Updated: 9/10/2026 - owner round 9 option b: the balance effect is PER
/// YEAR ([RequestSideEffects.usedDaysByYear]) — a request spanning two years
/// moves both years' documents in the same transaction;
/// [RequestCommit.balances] holds each year's balance as stored.
///
/// Plain immutable Dart: no Firestore, no Flutter.

import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

/// What happens to the attendance day of a TRANSACTION.
enum AttendanceCorrectionKind {
  /// Nothing.
  none,

  /// Final approval: the corrected session is written on its day.
  apply,

  /// An approved transaction canceled: the day goes back to how it was.
  revert,
}

class RequestSideEffects {
  const RequestSideEffects({
    this.usedDaysByYear = const <int, double>{},
    this.attendance = AttendanceCorrectionKind.none,
    this.schedule,
  });

  /// Nothing outside the request.
  static const RequestSideEffects none = RequestSideEffects();

  /// Days added to each year's `Used_Days` (+ deduction — refused when that
  /// year has no balance or too few days left; − refund — skipped when that
  /// year has none stored). Year → days.
  final Map<int, double> usedDaysByYear;

  /// The attendance effect of a transaction.
  final AttendanceCorrectionKind attendance;

  /// The requester's schedule (late / absent recalculation of the day).
  final WorkSchedule? schedule;

  bool get isEmpty =>
      usedDaysByYear.values.every((double d) => d == 0) && attendance == AttendanceCorrectionKind.none;
}

/// What one atomic request save wrote.
class RequestCommit {
  const RequestCommit({required this.request, this.balances = const <int, VacationBalance>{}});

  /// The request as stored.
  final TimeTrackerRequest request;

  /// Each touched year's balance as stored after a deduction / refund
  /// (year → balance; empty = untouched).
  final Map<int, VacationBalance> balances;

  /// A deduction left nothing in one of its years ("Vacation Limit Reached").
  bool get usedUpBalance {
    final Map<int, double> taken = request.deductedDaysByYear ?? const <int, double>{};
    for (final MapEntry<int, VacationBalance> e in balances.entries) {
      if ((taken[e.key] ?? 0) > 0 && e.value.remainingDays <= 0) return true;
    }
    return false;
  }
}
