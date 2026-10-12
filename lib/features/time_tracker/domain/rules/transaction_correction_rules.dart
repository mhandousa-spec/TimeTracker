/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: transaction_correction_rules.dart
/// Purpose: Declares `TransactionCorrectionRules` — how an APPROVED
///          attendance transaction rewrites the employee's day, and how a
///          "Cancel Request After Approving" puts the day back.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Owner decision 8 (HR never edits attendance directly; a correction is an
/// approved transaction) + phase-4 brief §B:
///   * Apply: the day of the transaction's check-in gets ONE corrected
///     session [check-in → check-out]; every stored session that overlaps
///     it (an open one included) is replaced, the others are kept. The day
///     is flagged `Is_Corrected_By_Transaction` with `Source_Request_Id`,
///     then status / late / break / total are recalculated by
///     `AttendanceCalculator`.
///   * Revert: the day goes back to how it was just before the correction
///     (the history row before the first one stamped with the request), or
///     to an empty day when there was no record; it is recalculated again
///     (an empty past working day reads as absent). A leave status the old
///     row had (vacation / sick leave / excused) is kept.
/// Every change is a NEW history row (the repository appends) — nothing is
/// overwritten. Pure Dart, unit-tested.
/// Updated: 9/10/2026 - code review finding 6: [apply] refuses a correction
/// longer than 24 hours (a transaction submitted before the new form rule
/// can no longer write a multi-day session onto one day).

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_calculator.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';

class TransactionCorrectionRules {
  const TransactionCorrectionRules._();

  /// Function Name: [dayOf]
  ///
  /// Purpose: The attendance day a transaction corrects (its check-in day).
  ///
  /// Return type: [DateTime]
  static DateTime dayOf(TimeTrackerRequest transaction) =>
      DateTime(transaction.startAt.year, transaction.startAt.month, transaction.startAt.day);

  /// Function Name: [overlaps]
  ///
  /// Return type: [bool] — [session] shares time with [from] → [to] (an open
  /// session runs forever).
  static bool overlaps(AttendanceSession session, DateTime from, DateTime to) {
    final DateTime? out = session.checkOutAt;
    return session.checkInAt.isBefore(to) && (out == null || out.isAfter(from));
  }

  /// Function Name: [apply]
  ///
  /// Purpose: The corrected day (see the file header).
  ///
  /// Parameters:
  ///   [AttendanceDay?] existing: the stored day (null = none).
  ///   [TimeTrackerRequest] transaction: approved, `isTransaction`.
  ///   [WorkSchedule?] schedule: the employee's schedule (late / absent).
  ///   [DateTime] now
  ///
  /// Return type: [AttendanceDay] — throws `StateError` for a non-transaction
  /// or one longer than 24 hours.
  static AttendanceDay apply({
    required AttendanceDay? existing,
    required TimeTrackerRequest transaction,
    required WorkSchedule? schedule,
    required DateTime now,
  }) {
    if (!transaction.isTransaction) {
      throw StateError('Only an attendance transaction corrects a day.');
    }
    final DateTime from = transaction.startAt;
    final DateTime to = transaction.endAt;
    if (to.difference(from) > TransactionRules.maxSpan) {
      throw StateError('A correction cannot be longer than 24 hours. Please reject it and ask for one per day.');
    }
    final AttendanceDay base = existing ??
        AttendanceDay(id: '', employeeEmail: transaction.requesterEmail, date: dayOf(transaction));
    AttendanceSession? replaced;
    final List<AttendanceSession> kept = <AttendanceSession>[];
    for (final AttendanceSession s in base.sessions) {
      if (overlaps(s, from, to)) {
        replaced ??= s;
      } else {
        kept.add(s);
      }
    }
    final AttendanceSession corrected = AttendanceSession(
      checkInAt: from,
      checkOutAt: to,
      workLocationId: replaced?.workLocationId ?? '',
      workLocationType: replaced?.workLocationType ?? WorkLocationType.office,
    );
    final List<AttendanceSession> sessions = <AttendanceSession>[...kept, corrected]
      ..sort((AttendanceSession a, AttendanceSession b) => a.checkInAt.compareTo(b.checkInAt));
    return AttendanceCalculator.apply(
      base.copyWith(
        sessions: List<AttendanceSession>.unmodifiable(sessions),
        isCorrectedByTransaction: true,
        sourceRequestId: transaction.id,
      ),
      schedule: schedule,
      now: now,
    );
  }

  /// Function Name: [revert]
  ///
  /// Purpose: [current] put back to [before] (see the file header).
  ///
  /// Parameters:
  ///   [AttendanceDay] current: the stored (corrected) day.
  ///   [AttendanceDay?] before: the row just before the correction (null =
  ///     the day had no record).
  ///   [WorkSchedule?] schedule
  ///   [DateTime] now
  ///
  /// Return type: [AttendanceDay]
  static AttendanceDay revert({
    required AttendanceDay current,
    required AttendanceDay? before,
    required WorkSchedule? schedule,
    required DateTime now,
  }) {
    final AttendanceStatus? oldStatus = before?.status;
    return AttendanceCalculator.apply(
      current.copyWith(
        sessions: before?.sessions ?? const <AttendanceSession>[],
        isCorrectedByTransaction: before?.isCorrectedByTransaction ?? false,
        sourceRequestId: before?.sourceRequestId ?? '',
      ),
      schedule: schedule,
      now: now,
      leaveStatus: oldStatus != null && oldStatus.isLeave ? oldStatus : null,
    );
  }
}
