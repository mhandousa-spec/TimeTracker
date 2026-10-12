/// Module: time_tracker / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: request_effects.dart
/// Purpose: Declares `RequestEffects` — PLANS what a request's status change
///          does OUTSIDE the request (vacation balance deduct / refund, a
///          transaction's attendance day correct / revert) plus the
///          employee's schedule those need — and `PlannedRequestChange`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Phase-4 brief §B:
///   * final approval (pending → approved): a leave type that deducts →
///     its cost in vacation days; a transaction → the corrected day.
///   * an approved request canceled (by HR, or the employee's cancellation
///     accepted): refund, or revert the correction.
/// The schedule (working days, shift hours) comes from the company's work
/// set-up source (HR or Time Tracker). Errors propagate as clean
/// `Exception`s from the repositories (no try here — playbook §3).
///
/// Updated: 9/10/2026 - code review findings 1–4 + 10:
///   * NOTHING is written here any more: [plan] returns the request to save
///     (with the deducted days recorded on the final approval) and the
///     `RequestSideEffects`; `RequestBaseRepository.commitRequest` writes all
///     of it in ONE transaction (approved-without-deduction, double
///     deductions and duplicates after a failed second write are gone);
///   * a refund gives back exactly the stored deduction (a type flag or
///     working days changed since no longer change the refund);
///   * vacation days are counted on [deductionScheduleOf] — a schedule with
///     no known week (HR shifts) uses the company's Time Tracker week, else
///     Sunday–Thursday (never every calendar day);
///   * a deducting request with NO balance stored is refused by the
///     repository (owner: missing balance = 0 days remaining).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are one
/// document per employee per YEAR.
/// Updated: 9/10/2026 - owner round 9 option b (replaces the cross-year
/// block): the final approval counts the days PER YEAR
/// (`VacationBalanceRules.daysByYear`, same working-day rules), records them
/// on the request (`deductedDaysByYear` → `Deducted_Vacation_Days` map) and
/// plans one deduction per year; a cancel refunds exactly each year's
/// share. The repository writes the request and every year's balance in
/// ONE transaction and refuses it when a year cannot cover its share.

import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_side_effects.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// The request to save and what its save does outside it.
class PlannedRequestChange {
  const PlannedRequestChange({required this.request, this.effects = RequestSideEffects.none});

  final TimeTrackerRequest request;
  final RequestSideEffects effects;
}

class RequestEffects {
  RequestEffects({
    required WorkSetupSourceResolver resolver,
    required EmployeeDirectoryBaseRepository directory,
  })  : _resolver = resolver,
        _directory = directory;

  final WorkSetupSourceResolver _resolver;
  final EmployeeDirectoryBaseRepository _directory;

  /// Function Name: [scheduleOf]
  ///
  /// Purpose: [email]'s schedule ([employeeId] '' = looked up in the
  /// employee directory, needed by an HR company).
  ///
  /// Return type: [Future<WorkSchedule?>] — null when not assigned.
  Future<WorkSchedule?> scheduleOf(String email, {String employeeId = ''}) async {
    String id = employeeId;
    if (id.isEmpty) {
      for (final TimeTrackerEmployee e in await _directory.fetchEmployees(isArabic: false)) {
        if (e.email == email.trim().toLowerCase()) id = e.employeeId;
      }
    }
    final EmployeeWorkSetup? setup = await (await _resolver.resolve()).loadWorkSetup(
      employeeEmail: email,
      employeeId: id,
    );
    return setup?.schedule;
  }

  /// Function Name: [deductionScheduleOf]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 1) — the schedule
  /// vacation days are counted on (`VacationBalanceRules.deductionSchedule`:
  /// the real one when its week is known, else the company's Time Tracker
  /// week, else Sunday–Thursday).
  ///
  /// Return type: [Future<WorkSchedule>]
  Future<WorkSchedule> deductionScheduleOf(String email, {String employeeId = ''}) async {
    final WorkSchedule? schedule = await scheduleOf(email, employeeId: employeeId);
    if (schedule != null && schedule.isWorkingWeekKnown) return schedule;
    return VacationBalanceRules.deductionSchedule(
      schedule,
      companyWeek: await _resolver.companyWorkingWeek(),
    );
  }

  /// Function Name: [needsType]
  ///
  /// Purpose: Whether planning [from] → [after] needs the request type
  /// (an approval of a leave request, or a refund with no stored deduction).
  ///
  /// Return type: [bool]
  static bool needsType(RequestStatus from, TimeTrackerRequest after) {
    if (after.isTransaction) return false;
    if (_approves(from, after)) return true;
    return _ends(from, after) && after.deductedDaysByYear == null;
  }

  static bool _approves(RequestStatus from, TimeTrackerRequest after) =>
      from == RequestStatus.pending && after.status == RequestStatus.approved;

  static bool _ends(RequestStatus from, TimeTrackerRequest after) =>
      (from == RequestStatus.approved || from == RequestStatus.underReview) &&
      (after.status == RequestStatus.canceled || after.status == RequestStatus.canceledByHr);

  /// Function Name: [plan]
  ///
  /// Purpose: What [after] having moved from [from] must do outside the
  /// request (nothing is written here).
  ///
  /// Parameters:
  ///   [RequestStatus] from
  ///   [TimeTrackerRequest] after: the request about to be saved.
  ///   [RequestType?] type: its request type (null for a transaction, or
  ///     when [needsType] is false).
  ///
  /// Return type: [Future<PlannedRequestChange>]
  Future<PlannedRequestChange> plan({
    required RequestStatus from,
    required TimeTrackerRequest after,
    required RequestType? type,
  }) async {
    final bool approves = _approves(from, after);
    final bool ends = _ends(from, after);
    if (!approves && !ends) return PlannedRequestChange(request: after);
    if (after.isTransaction) {
      return PlannedRequestChange(
        request: after,
        effects: RequestSideEffects(
          attendance: approves ? AttendanceCorrectionKind.apply : AttendanceCorrectionKind.revert,
          schedule: await scheduleOf(after.requesterEmail),
        ),
      );
    }
    if (approves) {
      if (!VacationBalanceRules.deducts(after, type)) {
        // Nothing taken — recorded, so a later flag change refunds nothing.
        return PlannedRequestChange(request: after.copyWith(deductedDaysByYear: const <int, double>{}));
      }
      // Owner round 9 option b: each year's share from that year's balance.
      final Map<int, double> byYear = VacationBalanceRules.daysByYear(
        after,
        schedule: await deductionScheduleOf(after.requesterEmail),
      );
      return PlannedRequestChange(
        request: after.copyWith(deductedDaysByYear: byYear),
        effects: RequestSideEffects(usedDaysByYear: byYear),
      );
    }
    // Ends: give back exactly each year's share (legacy rows: recompute).
    final Map<int, double> refund = after.deductedDaysByYear != null
        ? VacationBalanceRules.refundByYear(after, recomputed: const <int, double>{})
        : (VacationBalanceRules.deducts(after, type)
            ? VacationBalanceRules.daysByYear(
                after,
                schedule: await deductionScheduleOf(after.requesterEmail),
              )
            : const <int, double>{});
    return PlannedRequestChange(
      request: after,
      effects: RequestSideEffects(usedDaysByYear: <int, double>{
        for (final MapEntry<int, double> e in refund.entries) e.key: -e.value,
      }),
    );
  }
}
