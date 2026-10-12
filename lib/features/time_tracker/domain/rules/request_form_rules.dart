/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_form_rules.dart
/// Purpose: Declares `RequestDraft` (the "Creating New Request" form),
///          `RequestFormError` and `RequestFormRules` — which request types
///          the employee may pick, the total time, validation (vacation
///          balance included) and building the request with its approval
///          cycle.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:16900` / `661:17016` (title fixed to "Creating New Request" —
/// owner fix): Request Type = ACTIVE types available to the employee's
/// location AND department (`RequestType.isAvailableFor`) · Description
/// (required when the type says so, 0/500) · Start Date · End Date · All Day
/// (off → Start Time / End Time) · Attachments (required when the type says
/// so). Total time: all day = calendar days × 24 h (shown as days),
/// otherwise end − start in minutes. A type that deducts from the vacation
/// balance may not ask for more days than remain
/// (`VacationBalanceRules.requestedDays`); with NO balance stored it is
/// refused (0 days remaining — code review 9/10/2026, replacing the phase-4
/// "never blocks" assumption). The approval cycle comes from the type's switches
/// (`ApprovalRouter.initialSteps`). Pure Dart, unit-tested.
/// Updated: 9/10/2026 - code review:
///   * finding 10 (owner): a deducting type with NO balance stored = 0 days
///     remaining → `noBalance` ("contact HR") whenever it costs a day;
///   * a request may not overlap one of the employee's own pending /
///     approved / under-review leave requests (`overlapsExisting`);
///   * [build] passes `managerIsSoleOtherHr` (the manager who is the only
///     other HR approver decides alone — owner rule).
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are kept per
/// YEAR. Owner round 9 option b (replaces the cross-year block): a
/// deducting request may span two years — [validate] checks EACH year's
/// share against that year's balance ([daysByYear], [shortfall]); the
/// first year that cannot cover it is named in the message.

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// Why a request draft cannot be submitted.
enum RequestFormError {
  typeRequired,
  descriptionRequired,
  descriptionTooLong,
  startDateRequired,
  endDateRequired,
  startTimeRequired,
  endTimeRequired,
  endBeforeStart,
  attachmentsRequired,
  exceedsBalance,

  /// 9/10/2026 (finding 10): a deducting type, no balance stored.
  noBalance,

  /// 9/10/2026 (code review): overlaps one of the employee's own requests.
  overlapsExisting,

}

/// The form's values. Dates are calendar days; times are minutes since
/// midnight (used only when [isAllDay] is off).
class RequestDraft {
  const RequestDraft({
    this.type,
    this.description = '',
    this.startDate,
    this.endDate,
    this.isAllDay = true,
    this.startMinutes,
    this.endMinutes,
    this.attachments = const <RequestAttachment>[],
  });

  final RequestType? type;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAllDay;
  final int? startMinutes;
  final int? endMinutes;
  final List<RequestAttachment> attachments;

  /// Function Name: [startAt] / [endAt]
  ///
  /// Purpose: The requested time frame (all day = 00:00 → 23:59), or null
  /// while a needed value is missing.
  ///
  /// Return type: [DateTime?]
  DateTime? get startAt {
    final DateTime? d = startDate;
    if (d == null) return null;
    if (isAllDay) return DateTime(d.year, d.month, d.day);
    final int? m = startMinutes;
    return m == null ? null : DateTime(d.year, d.month, d.day, m ~/ 60, m % 60);
  }

  DateTime? get endAt {
    final DateTime? d = endDate;
    if (d == null) return null;
    if (isAllDay) return DateTime(d.year, d.month, d.day, 23, 59);
    final int? m = endMinutes;
    return m == null ? null : DateTime(d.year, d.month, d.day, m ~/ 60, m % 60);
  }

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [RequestDraft]
  RequestDraft copyWith({
    RequestType? type,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    int? startMinutes,
    int? endMinutes,
    List<RequestAttachment>? attachments,
  }) =>
      RequestDraft(
        type: type ?? this.type,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isAllDay: isAllDay ?? this.isAllDay,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
        attachments: attachments ?? this.attachments,
      );
}

class RequestFormRules {
  const RequestFormRules._();

  /// Figma "0/500".
  static const int maxDescriptionLength = 500;

  /// Minutes in a day (an all-day request stores days × this).
  static const int minutesPerDay = 24 * 60;

  /// Function Name: [availableTypes]
  ///
  /// Purpose: The types the employee may pick: ACTIVE and available for
  /// [locationId] AND [departmentId], sorted by English name.
  ///
  /// Return type: [List<RequestType>]
  static List<RequestType> availableTypes(
    List<RequestType> types, {
    required String locationId,
    required String departmentId,
  }) {
    final List<RequestType> out = <RequestType>[
      for (final RequestType t in types)
        if (t.isAvailableFor(locationId: locationId, departmentId: departmentId)) t,
    ]..sort((RequestType a, RequestType b) =>
        a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
    return List<RequestType>.unmodifiable(out);
  }

  /// Function Name: [totalMinutes]
  ///
  /// Purpose: The draft's total time: all day = calendar days (inclusive)
  /// × 24 h; otherwise end − start. 0 while incomplete or reversed.
  ///
  /// Return type: [int]
  static int totalMinutes(RequestDraft draft) {
    final DateTime? start = draft.startAt;
    final DateTime? end = draft.endAt;
    if (start == null || end == null || end.isBefore(start)) return 0;
    if (draft.isAllDay) {
      final DateTime a = DateTime.utc(start.year, start.month, start.day);
      final DateTime b = DateTime.utc(end.year, end.month, end.day);
      return (b.difference(a).inDays + 1) * minutesPerDay;
    }
    return end.difference(start).inMinutes;
  }

  /// Function Name: [requestedDays]
  ///
  /// Purpose: Vacation days the draft would cost (working days for all day,
  /// minutes ÷ shift minutes otherwise — `VacationBalanceRules`).
  ///
  /// Return type: [double]
  static double requestedDays(RequestDraft draft, {WorkSchedule? schedule}) {
    final DateTime? start = draft.startAt;
    final DateTime? end = draft.endAt;
    if (start == null || end == null || end.isBefore(start)) return 0;
    return VacationBalanceRules.requestedDays(
      TimeTrackerRequest(
        id: '',
        requesterEmail: '',
        startAt: start,
        endAt: end,
        isAllDay: draft.isAllDay,
        totalMinutes: totalMinutes(draft),
      ),
      schedule: schedule,
    );
  }

  /// Function Name: [daysByYear]
  ///
  /// Purpose: ADDED 9/10/2026 (owner round 9 option b) — what the draft
  /// costs in each calendar year (`VacationBalanceRules.daysByYear`).
  ///
  /// Return type: [Map<int, double>]
  static Map<int, double> daysByYear(RequestDraft draft, {WorkSchedule? schedule}) {
    final DateTime? start = draft.startAt;
    final DateTime? end = draft.endAt;
    if (start == null || end == null || end.isBefore(start)) return const <int, double>{};
    return VacationBalanceRules.daysByYear(
      TimeTrackerRequest(
        id: '',
        requesterEmail: '',
        startAt: start,
        endAt: end,
        isAllDay: draft.isAllDay,
        totalMinutes: totalMinutes(draft),
      ),
      schedule: schedule,
    );
  }

  /// Function Name: [shortfall]
  ///
  /// Purpose: ADDED 9/10/2026 (owner round 9 option b) — the first year of
  /// the draft whose balance cannot cover its share (null = all covered).
  /// [balance] stands for the START year when [balances] has no document
  /// for it (the form's own balance).
  ///
  /// Return type: [VacationShortfall?]
  static VacationShortfall? shortfall(
    RequestDraft draft, {
    WorkSchedule? schedule,
    VacationBalance? balance,
    List<VacationBalance> balances = const <VacationBalance>[],
  }) {
    final int? startYear = draft.startAt?.year;
    VacationBalance? of(int year) {
      for (final VacationBalance b in balances) {
        if (b.year == year) return b;
      }
      return year == startYear ? balance : null;
    }

    return VacationBalanceRules.shortfall(daysByYear(draft, schedule: schedule), of);
  }

  /// Function Name: [validate]
  ///
  /// Purpose: Every problem of [draft] (empty = valid).
  ///
  /// Parameters:
  ///   [RequestDraft] draft
  ///   [VacationBalance?] balance: the employee's balance for the year the
  ///     draft STARTS in (null = none stored → 0 days remaining for a
  ///     deducting type, 9/10/2026).
  ///   [List<VacationBalance>] balances: the employee's balances of every
  ///     year (a draft spanning two years needs each year — round 9 b).
  ///   [WorkSchedule?] schedule: working days for the day count.
  ///   [List<TimeTrackerRequest>] ownRequests: the employee's own requests
  ///     (an overlap with a live leave request is refused — 9/10/2026).
  ///
  /// Return type: [Set<RequestFormError>]
  static Set<RequestFormError> validate(
    RequestDraft draft, {
    VacationBalance? balance,
    List<VacationBalance> balances = const <VacationBalance>[],
    WorkSchedule? schedule,
    List<TimeTrackerRequest> ownRequests = const <TimeTrackerRequest>[],
  }) {
    final RequestType? type = draft.type;
    final Set<RequestFormError> errors = <RequestFormError>{};
    if (type == null) errors.add(RequestFormError.typeRequired);
    if (type != null && type.isDescriptionRequired && draft.description.trim().isEmpty) {
      errors.add(RequestFormError.descriptionRequired);
    }
    if (draft.description.trim().length > maxDescriptionLength) {
      errors.add(RequestFormError.descriptionTooLong);
    }
    if (draft.startDate == null) errors.add(RequestFormError.startDateRequired);
    if (draft.endDate == null) errors.add(RequestFormError.endDateRequired);
    if (!draft.isAllDay) {
      if (draft.startMinutes == null) errors.add(RequestFormError.startTimeRequired);
      if (draft.endMinutes == null) errors.add(RequestFormError.endTimeRequired);
    }
    final DateTime? start = draft.startAt;
    final DateTime? end = draft.endAt;
    if (start != null && end != null && !end.isAfter(start)) {
      errors.add(RequestFormError.endBeforeStart);
    }
    if (type != null && type.isAttachmentRequired && draft.attachments.isEmpty) {
      errors.add(RequestFormError.attachmentsRequired);
    }
    if (type != null &&
        type.isDeductedFromVacationBalance &&
        !errors.contains(RequestFormError.endBeforeStart)) {
      // Finding 10 (owner): no balance stored = 0 days remaining. Round 9 b:
      // every year of the draft must cover its own share.
      final VacationShortfall? short = shortfall(draft, schedule: schedule, balance: balance, balances: balances);
      if (short != null) {
        errors.add(short.isMissing ? RequestFormError.noBalance : RequestFormError.exceedsBalance);
      }
    }
    if (start != null && end != null && end.isAfter(start) && overlapsOwn(start, end, ownRequests)) {
      errors.add(RequestFormError.overlapsExisting);
    }
    return errors;
  }

  /// Function Name: [overlapsOwn]
  ///
  /// Purpose: ADDED 9/10/2026 (code review) — [start] → [end] shares time
  /// with one of [ownRequests]' live LEAVE requests (pending, approved or
  /// under a cancellation review; transactions never count).
  ///
  /// Return type: [bool]
  static bool overlapsOwn(DateTime start, DateTime end, List<TimeTrackerRequest> ownRequests) =>
      ownRequests.any((TimeTrackerRequest r) =>
          !r.isTransaction &&
          (r.status == RequestStatus.pending ||
              r.status == RequestStatus.approved ||
              r.status == RequestStatus.underReview) &&
          r.startAt.isBefore(end) &&
          start.isBefore(r.endAt));

  /// Function Name: [build]
  ///
  /// Purpose: The new request (id '' — the repository assigns one) with its
  /// approval cycle: the direct manager (when the type needs it and one is
  /// known), then HR (when the type needs it). No step → approved at once.
  ///
  /// Parameters:
  ///   [RequestDraft] draft: must be valid (see [validate]).
  ///   [String] requesterEmail / [String] requesterDepartmentId
  ///   [String] managerEmail: '' = no manager known (step 1 skipped).
  ///
  /// Return type: [TimeTrackerRequest] — throws `StateError` when the draft
  /// is incomplete.
  static TimeTrackerRequest build(
    RequestDraft draft, {
    required String requesterEmail,
    required String requesterDepartmentId,
    required String managerEmail,
    bool requesterIsHrApprover = false,
    bool managerIsSoleOtherHr = false,
  }) {
    final RequestType? type = draft.type;
    final DateTime? start = draft.startAt;
    final DateTime? end = draft.endAt;
    if (type == null || start == null || end == null || !end.isAfter(start)) {
      throw StateError('The request is not complete.');
    }
    final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
      isManagerApprovalRequired: type.isManagerApprovalRequired,
      isHrApprovalRequired: type.isHrApprovalRequired,
      managerEmail: managerEmail,
      requesterEmail: requesterEmail,
      requesterIsHrApprover: requesterIsHrApprover,
      managerIsSoleOtherHr: managerIsSoleOtherHr,
    );
    return TimeTrackerRequest(
      id: '',
      requesterEmail: requesterEmail.trim().toLowerCase(),
      requesterDepartmentId: requesterDepartmentId,
      requestTypeId: type.id,
      description: draft.description.trim(),
      startAt: start,
      endAt: end,
      isAllDay: draft.isAllDay,
      totalMinutes: totalMinutes(draft),
      attachments: List<RequestAttachment>.unmodifiable(draft.attachments),
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
  }
}
