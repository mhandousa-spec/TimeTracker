/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: vacation_balance_rules.dart
/// Purpose: Declares `VacationBalanceRules` — how many vacation days a
///          request costs, and how a status change moves the balance.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Rules (owner decisions 6 + 11, 8/10/2026):
///   * Only a leave request (never a transaction) whose type has
///     `Is_Deducted_From_Vacation_Balance` touches the balance.
///   * Days are deducted when the request becomes APPROVED (pending →
///     approved) and given back when an approved request is canceled
///     (approved / under_review → canceled or canceled_by_hr). A rejected
///     cancellation (under_review → approved) changes nothing.
///   * All-day requests cost one day per WORKING day in the range; partial
///     requests cost totalMinutes ÷ the planned shift minutes (fractional).
///   * (Owner decision 21, the lazy 1 January roll-over inside one document,
///     was REMOVED 9/10/2026 — see below.)
/// Updated: 9/10/2026 - code review: [deductionSchedule] (finding 1 — a
/// schedule with no known week counts vacation days on the company's
/// Time Tracker week, else Sunday–Thursday, never on every calendar day)
/// and [refundFor] (finding 4 — a refund gives back exactly what the
/// approval stored as deducted).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): one balance document per
/// employee per YEAR. Nothing rolls over: a year with no document = no
/// balance (0 days for a deducting type — finding 10). `rollOver` is gone.
/// Updated: 9/10/2026 - owner round 9, option b (replaces the earlier
/// "one request per year" block): a deducting request MAY span two years —
/// its days are counted PER YEAR with the same working-day rules
/// ([daysByYear]) and each year's share is deducted from / refunded to that
/// year's document ([refundByYear]). Every year must cover its share
/// ([shortfall]: the first year whose balance is missing (= 0 days) or too
/// small — named in the message).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

class VacationBalanceRules {
  const VacationBalanceRules._();

  /// Planned minutes of a working day when no schedule is known (8 h).
  static const int defaultWorkdayMinutes = 8 * 60;

  /// Function Name: [deducts]
  ///
  /// Purpose: Whether [request] of [type] counts against the balance.
  ///
  /// Return type: [bool]
  static bool deducts(TimeTrackerRequest request, RequestType? type) =>
      !request.isTransaction &&
      type != null &&
      type.isDeductedFromVacationBalance;

  /// Function Name: [requestedDays]
  ///
  /// Purpose: Vacation days [request] costs.
  ///
  /// Parameters:
  ///   [TimeTrackerRequest] request
  ///   [WorkSchedule?] schedule: working days + planned minutes (null =
  ///     every day, 8 h).
  ///
  /// Return type: [double]
  static double requestedDays(
    TimeTrackerRequest request, {
    WorkSchedule? schedule,
  }) {
    if (request.isAllDay) {
      final DateTime first = _day(request.startAt);
      final DateTime last = _day(request.endAt);
      int days = 0;
      for (DateTime d = first; !d.isAfter(last); d = _nextDay(d)) {
        if (schedule == null || schedule.isWorkingDay(d)) days++;
      }
      return days.toDouble();
    }
    final int perDay = schedule?.shiftMinutes ?? defaultWorkdayMinutes;
    if (perDay <= 0 || request.totalMinutes <= 0) return 0;
    return request.totalMinutes / perDay;
  }

  /// Function Name: [deductionSchedule]
  ///
  /// Purpose: The schedule vacation days are counted on: [schedule] when its
  /// working week is known; otherwise the same hours (9:00–17:00 when none)
  /// over [companyWeek] (the company's Time Tracker locations), or Sunday →
  /// Thursday when there is none. Used ONLY for the day count (code review
  /// finding 1, 9/10/2026) — absences and reminders never use it.
  ///
  /// Return type: [WorkSchedule]
  static WorkSchedule deductionSchedule(WorkSchedule? schedule, {List<int>? companyWeek}) {
    final WorkSchedule? known = schedule;
    if (known != null && known.isWorkingWeekKnown) return known;
    final List<int> week = companyWeek != null && companyWeek.isNotEmpty
        ? companyWeek
        : WorkSchedule.sundayToThursday;
    final WorkSchedule base = known ?? const WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60);
    return base.withWorkingDays(week, known: false);
  }

  /// Function Name: [refundByYear]
  ///
  /// Purpose: Days to give back to each year when an approved request is
  /// canceled: exactly the stored per-year `Deducted_Vacation_Days` (code
  /// review finding 4; per year since round 9 option b); a request approved
  /// before that field existed (null) falls back to [recomputed].
  ///
  /// Return type: [Map<int, double>] — never negative, zero years dropped.
  static Map<int, double> refundByYear(
    TimeTrackerRequest request, {
    required Map<int, double> recomputed,
  }) {
    final Map<int, double> source = request.deductedDaysByYear ?? recomputed;
    return Map<int, double>.unmodifiable(<int, double>{
      for (final MapEntry<int, double> e in source.entries)
        if (e.value > 0) e.key: e.value,
    });
  }

  /// Function Name: [daysByYear]
  ///
  /// Purpose: ADDED 9/10/2026 (owner round 9 option b) — what [request]
  /// costs in each calendar year: all-day requests count the WORKING days
  /// of [schedule] falling in each year; partial requests split their time
  /// at midnight of 1 January (minutes ÷ the planned shift minutes). The
  /// years sum to [requestedDays].
  ///
  /// Return type: [Map<int, double>] — years with a cost only (ascending).
  static Map<int, double> daysByYear(TimeTrackerRequest request, {WorkSchedule? schedule}) {
    final Map<int, double> out = <int, double>{};
    if (request.isAllDay) {
      final DateTime last = _day(request.endAt);
      for (DateTime d = _day(request.startAt); !d.isAfter(last); d = _nextDay(d)) {
        if (schedule == null || schedule.isWorkingDay(d)) out[d.year] = (out[d.year] ?? 0) + 1;
      }
      return Map<int, double>.unmodifiable(out);
    }
    final double total = requestedDays(request, schedule: schedule);
    if (total <= 0) return const <int, double>{};
    final DateTime start = request.startAt;
    final DateTime end = request.endAt;
    if (start.year == end.year || !end.isAfter(DateTime(end.year))) {
      return Map<int, double>.unmodifiable(<int, double>{start.year: total});
    }
    final int span = end.difference(start).inMinutes;
    if (span <= 0) return Map<int, double>.unmodifiable(<int, double>{start.year: total});
    for (int y = start.year; y <= end.year; y++) {
      final DateTime from = start.isAfter(DateTime(y)) ? start : DateTime(y);
      final DateTime to = end.isBefore(DateTime(y + 1)) ? end : DateTime(y + 1);
      final int minutes = to.difference(from).inMinutes;
      if (minutes > 0) out[y] = total * minutes / span;
    }
    return Map<int, double>.unmodifiable(out);
  }

  /// Function Name: [shortfall]
  ///
  /// Purpose: ADDED 9/10/2026 (owner round 9 option b) — the first year (in
  /// order) whose balance cannot cover its share of [byYear]: no balance
  /// document (= 0 days left) or fewer days left than needed.
  ///
  /// Parameters:
  ///   [Map<int, double>] byYear: the cost per year ([daysByYear]).
  ///   [VacationBalance? Function(int year)] balanceOf: that year's balance.
  ///
  /// Return type: [VacationShortfall?] — null when every year is covered.
  static VacationShortfall? shortfall(
    Map<int, double> byYear,
    VacationBalance? Function(int year) balanceOf,
  ) {
    final List<int> years = byYear.keys.toList()..sort();
    for (final int y in years) {
      final double need = byYear[y] ?? 0;
      if (need <= 0) continue;
      final VacationBalance? b = balanceOf(y);
      if (b == null) return VacationShortfall(year: y, daysLeft: 0, needed: need, isMissing: true);
      if (wouldExceed(b, need)) return VacationShortfall(year: y, daysLeft: b.remainingDays, needed: need);
    }
    return null;
  }

  /// Function Name: [deltaFor]
  ///
  /// Purpose: How many days a status change adds to `Used_Days` (+ deduct,
  /// − refund, 0 nothing).
  ///
  /// Parameters:
  ///   [RequestStatus] from / [RequestStatus] to
  ///   [double] days: the request's cost ([requestedDays]).
  ///
  /// Return type: [double]
  static double deltaFor({
    required RequestStatus from,
    required RequestStatus to,
    required double days,
  }) {
    if (from == RequestStatus.pending && to == RequestStatus.approved) {
      return days;
    }
    final bool wasHeld =
        from == RequestStatus.approved || from == RequestStatus.underReview;
    final bool isCanceled =
        to == RequestStatus.canceled || to == RequestStatus.canceledByHr;
    return wasHeld && isCanceled ? -days : 0;
  }

  /// Function Name: [applyStatusChange]
  ///
  /// Purpose: [balance] after [request] moved [from] → [to].
  ///
  /// Parameters:
  ///   [VacationBalance] balance
  ///   [TimeTrackerRequest] request
  ///   [RequestType?] type
  ///   [RequestStatus] from / [RequestStatus] to
  ///   [WorkSchedule?] schedule
  ///
  /// Return type: [VacationBalance] — unchanged when nothing applies; used
  /// days never drop below zero.
  static VacationBalance applyStatusChange({
    required VacationBalance balance,
    required TimeTrackerRequest request,
    required RequestType? type,
    required RequestStatus from,
    required RequestStatus to,
    WorkSchedule? schedule,
  }) {
    if (!deducts(request, type)) return balance;
    final double delta = deltaFor(
      from: from,
      to: to,
      days: requestedDays(request, schedule: schedule),
    );
    if (delta == 0) return balance;
    final double used = balance.usedDays + delta;
    return balance.copyWith(usedDays: used < 0 ? 0 : used);
  }

  /// Function Name: [wouldExceed]
  ///
  /// Purpose: Approving [days] more would go past the remaining balance
  /// (drives the "Vacation Limit Reached" notification).
  ///
  /// Return type: [bool]
  static bool wouldExceed(VacationBalance balance, double days) =>
      days > balance.remainingDays + 1e-9;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // Calendar arithmetic (not +24h) so DST changes never skip or repeat a day.
  static DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
}

/// ADDED 9/10/2026 (owner round 9 option b): a year whose balance cannot
/// cover its share of a request ("2027 has only 2 days left").
class VacationShortfall {
  const VacationShortfall({
    required this.year,
    required this.daysLeft,
    required this.needed,
    this.isMissing = false,
  });

  final int year;

  /// Days left that year (0 when no balance document exists).
  final double daysLeft;

  /// That year's share of the request.
  final double needed;

  /// No balance document for that year.
  final bool isMissing;
}
