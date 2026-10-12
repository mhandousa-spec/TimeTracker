/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_requests.dart
/// Purpose: Declares `TtDemoRequests` — the DEBUG-ONLY demo leave requests
///          and attendance transactions in EVERY status: pending at the
///          manager, pending at HR, approved, rejected (with reason),
///          canceled, canceled by HR, under review (cancellation asked),
///          transaction pending / approved — with comments and PDF
///          documents.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data)
///
/// Pure Dart. Every request is built and moved through its cycle with the
/// module's OWN rules (`ApprovalRouter.initialSteps`, `RequestCycleRules`),
/// so the approval steps, current step, status and deducted days are exactly
/// what the app would have stored. The signed-in user gets the full set on
/// their own Requests tab; every colleague gets a rotating pattern so the
/// Approvals tab, the HR dashboard and Needs Attention fill up.

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_setup.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_texts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';

/// What happens to a demo request after it is submitted.
enum _Fate { pending, pendingHr, approved, rejected, canceled, canceledByHr, underReview }

class TtDemoRequests {
  TtDemoRequests(this.input, this.setup, {required this.isArabic});

  final TtDemoInput input;
  final TtDemoSetup setup;

  /// Language of the free texts (descriptions, reasons, comments).
  final bool isArabic;

  final List<TtDemoRequest> _out = <TtDemoRequest>[];
  int _n = 0;

  late final Map<String, RequestType> _types = <String, RequestType>{
    for (final RequestType t in setup.requestTypes) t.id: t,
  };

  DateTime get _today => TtDemoCalendar.dayOf(input.now);

  /// Function Name: [build]
  ///
  /// Purpose: Every demo request (the signed-in user's full set first).
  ///
  /// Return type: [List<TtDemoRequest>]
  List<TtDemoRequest> build() {
    _mine();
    for (int i = 0; i < input.others.length; i++) {
      _colleague(i, input.others[i]);
    }
    return List<TtDemoRequest>.unmodifiable(_out);
  }

  // ── The signed-in user: every status on their own Requests tab ─────────────

  void _mine() {
    final TimeTrackerEmployee me = input.me;
    final TtDemoCalendar c = TtDemoCalendar(setup.locationOf(me).schedule);
    _leave(me, TtDemoIds.annual, c.ahead(_today, 6), 2, TtDemoTexts.familyTrip, _Fate.pending,
        submitted: _at(_today, -1, 10, 12), comments: _handover(me, _today));
    _leave(me, TtDemoIds.sick, c.back(_today, 12), 2, TtDemoTexts.flu, _Fate.approved,
        submitted: _at(c.back(_today, 12), 0, 7, 40), document: TtDemoDocumentKind.medicalReport,
        comments: _report(me, c.back(_today, 11)));
    final DateTime mission = c.back(_today, 7);
    _partial(me, TtDemoIds.mission, mission, 10 * 60, 14 * 60, TtDemoTexts.ministryMeeting, _Fate.approved,
        submitted: _at(mission, -1, 15, 30), document: TtDemoDocumentKind.travelOrder);
    _leave(me, TtDemoIds.workshop, c.back(_today, 4), 1, TtDemoTexts.digitalWorkshop, _Fate.rejected,
        submitted: _at(c.back(_today, 4), -6, 9, 5), reason: TtDemoTexts.rejectNoInvitation);
    _leave(me, TtDemoIds.annual, c.back(_today, 18), 3, TtDemoTexts.personalMatters, _Fate.canceled,
        submitted: _at(c.back(_today, 18), -10, 11, 0), reason: TtDemoTexts.cancelPlansChanged);
    _leave(me, TtDemoIds.annual, c.ahead(_today, 15), 3, TtDemoTexts.yearEnd, _Fate.canceledByHr,
        submitted: _at(_today, -8, 13, 20), reason: TtDemoTexts.cancelByHrAudit);
    _leave(me, TtDemoIds.annual, c.ahead(_today, 25), 4, TtDemoTexts.familyTrip, _Fate.underReview,
        submitted: _at(_today, -12, 9, 45), reason: TtDemoTexts.cancelRequestReturn);
    _leave(me, TtDemoIds.annual, c.back(_today, 22), 3, TtDemoTexts.personalMatters, _Fate.approved,
        submitted: _at(c.back(_today, 22), -9, 10, 30));
    _older(me, c, monthsBack: 4, days: 5);
    _transaction(me, c.back(_today, 2), TtDemoTexts.forgotCheckOut, _Fate.pending);
    _transaction(me, c.back(_today, 9), TtDemoTexts.deviceFailure, _Fate.approved);
  }

  // ── Colleagues: a rotating pattern of five ────────────────────────────────

  void _colleague(int i, TimeTrackerEmployee e) {
    final TtDemoCalendar c = TtDemoCalendar(setup.locationOf(e).schedule);
    switch (i % 5) {
      case 0:
        _leave(e, TtDemoIds.annual, c.back(_today, 15 + i % 3), 3, TtDemoTexts.personalMatters, _Fate.approved,
            submitted: _at(c.back(_today, 15 + i % 3), -7, 10, 0));
        _leave(e, TtDemoIds.annual, c.ahead(_today, 10 + i), 2, TtDemoTexts.familyTrip, _Fate.pending,
            submitted: _at(_today, -3, 9, 15), comments: _handover(e, TtDemoCalendar.addDays(_today, -2)));
        _transaction(e, c.back(_today, 5), TtDemoTexts.forgotCheckOut, _Fate.approved);
        _older(e, c, monthsBack: 3, days: 4);
      case 1:
        _leave(e, TtDemoIds.sick, c.back(_today, 10), 2, TtDemoTexts.flu, _Fate.approved,
            submitted: _at(c.back(_today, 10), 0, 7, 55), document: TtDemoDocumentKind.medicalReport,
            comments: _report(e, c.back(_today, 9)));
        _leave(e, TtDemoIds.annual, c.ahead(_today, 8), 3, TtDemoTexts.yearEnd, _Fate.pendingHr,
            submitted: _at(_today, -4, 12, 10));
        _partial(e, TtDemoIds.mission, c.back(_today, 3), 11 * 60, 15 * 60, TtDemoTexts.siteVisit, _Fate.rejected,
            submitted: _at(c.back(_today, 3), -2, 14, 0), reason: TtDemoTexts.rejectWorkload);
        _leave(e, TtDemoIds.annual, c.ahead(_today, 20), 2, TtDemoTexts.personalMatters, _Fate.canceled,
            submitted: _at(_today, -6, 10, 40), reason: TtDemoTexts.cancelPlansChanged);
      case 2:
        final DateTime mission = c.back(_today, 6);
        _partial(e, TtDemoIds.mission, mission, 10 * 60, 13 * 60 + 30, TtDemoTexts.ministryMeeting, _Fate.approved,
            submitted: _at(mission, -1, 16, 5), document: TtDemoDocumentKind.travelOrder,
            comments: <RequestComment>[_comment(1, _managerOf(e), TtDemoTexts.commentMissionLetter, _at(mission, 0, 15, 0))]);
        _transaction(e, c.back(_today, 1), TtDemoTexts.forgotCheckOut, _Fate.pending);
        _leave(e, TtDemoIds.annual, _today, 3, TtDemoTexts.familyTrip, _Fate.approved,
            submitted: _at(_today, -9, 11, 25));
        _older(e, c, monthsBack: 5, days: 3);
      case 3:
        _leave(e, TtDemoIds.workshop, c.back(_today, 8), 1, TtDemoTexts.archivingWorkshop, _Fate.rejected,
            submitted: _at(c.back(_today, 8), -5, 9, 30), reason: TtDemoTexts.rejectNoInvitation);
        _leave(e, TtDemoIds.annual, c.back(_today, 20), 2, TtDemoTexts.personalMatters, _Fate.approved,
            submitted: _at(c.back(_today, 20), -8, 10, 15));
        _leave(e, TtDemoIds.sick, c.back(_today, 3), 1, TtDemoTexts.checkup, _Fate.pending,
            submitted: _at(c.back(_today, 3), 1, 8, 20), document: TtDemoDocumentKind.medicalReport);
        _leave(e, TtDemoIds.annual, c.ahead(_today, 12), 2, TtDemoTexts.yearEnd, _Fate.canceledByHr,
            submitted: _at(_today, -10, 13, 0), reason: TtDemoTexts.cancelByHrAudit);
      default:
        _leave(e, TtDemoIds.annual, c.ahead(_today, 18), 3, TtDemoTexts.familyTrip, _Fate.underReview,
            submitted: _at(_today, -11, 10, 0), reason: TtDemoTexts.cancelRequestReturn);
        _leave(e, TtDemoIds.workshop, c.back(_today, 9), 1, TtDemoTexts.digitalWorkshop, _Fate.approved,
            submitted: _at(c.back(_today, 9), -7, 9, 0), document: TtDemoDocumentKind.workshopInvitation);
        _transaction(e, c.back(_today, 4), TtDemoTexts.deviceFailure, _Fate.pendingHr);
        _older(e, c, monthsBack: 2, days: 2);
    }
  }

  // ── Builders ───────────────────────────────────────────────────────────────

  /// An approved annual vacation [monthsBack] months ago (year charts).
  void _older(TimeTrackerEmployee e, TtDemoCalendar c, {required int monthsBack, required int days}) {
    final DateTime month = DateTime(_today.year, _today.month - monthsBack, 9);
    if (month.year != _today.year) return; // stays in this year's balance
    final DateTime start = c.ahead(month, 1);
    _leave(e, TtDemoIds.annual, start, days, TtDemoTexts.personalMatters, _Fate.approved,
        submitted: _at(start, -12, 10, 0));
  }

  void _leave(
    TimeTrackerEmployee e,
    String typeId,
    DateTime start,
    int workingDays,
    TtDemoText description,
    _Fate fate, {
    required DateTime submitted,
    TtDemoText? reason,
    TtDemoDocumentKind? document,
    List<RequestComment> comments = const <RequestComment>[],
  }) {
    final WorkSchedule schedule = setup.locationOf(e).schedule;
    final DateTime first = TtDemoCalendar.dayOf(start);
    final DateTime last = TtDemoCalendar(schedule).spanEnd(first, workingDays);
    final DateTime from = DateTime(first.year, first.month, first.day);
    final DateTime to = DateTime(last.year, last.month, last.day, 23, 59);
    _add(
      e,
      typeId: typeId,
      from: from,
      to: to,
      allDay: true,
      totalMinutes: (DateTime.utc(last.year, last.month, last.day)
                  .difference(DateTime.utc(first.year, first.month, first.day))
                  .inDays +
              1) *
          24 *
          60,
      description: description,
      fate: fate,
      submitted: submitted,
      reason: reason,
      document: document,
      comments: comments,
    );
  }

  void _partial(
    TimeTrackerEmployee e,
    String typeId,
    DateTime day,
    int startMinutes,
    int endMinutes,
    TtDemoText description,
    _Fate fate, {
    required DateTime submitted,
    TtDemoText? reason,
    TtDemoDocumentKind? document,
    List<RequestComment> comments = const <RequestComment>[],
  }) {
    final DateTime from = DateTime(day.year, day.month, day.day, 0, startMinutes);
    final DateTime to = DateTime(day.year, day.month, day.day, 0, endMinutes);
    _add(e,
        typeId: typeId,
        from: from,
        to: to,
        allDay: false,
        totalMinutes: endMinutes - startMinutes,
        description: description,
        fate: fate,
        submitted: submitted,
        reason: reason,
        document: document,
        comments: comments);
  }

  /// A check-in / check-out correction for [day] (the employee forgot to
  /// check out, or the check-in failed).
  void _transaction(TimeTrackerEmployee e, DateTime day, TtDemoText description, _Fate fate) {
    final WorkSchedule s = setup.locationOf(e).schedule;
    final int roll = TtDemoDice.roll('${e.email}_tx_${day.day}', 12);
    final DateTime checkIn = DateTime(day.year, day.month, day.day, 0, s.startMinutes - 6 + roll);
    final DateTime checkOut = DateTime(day.year, day.month, day.day, 0, s.endMinutes + 25 + roll * 3);
    final String manager = _managerOf(e);
    final List<RequestApprovalStep> steps = ApprovalRouter.transactionSteps(
      managerEmail: manager,
      requesterEmail: e.email,
      requesterIsHrApprover: _isHr(e.email),
    );
    final TimeTrackerRequest base = TimeTrackerRequest(
      id: TtDemoIds.request(++_n),
      requesterEmail: e.email,
      requesterDepartmentId: e.departmentId,
      isTransaction: true,
      description: description.of(isArabic: isArabic),
      startAt: checkIn,
      endAt: checkOut,
      totalMinutes: checkOut.difference(checkIn).inMinutes,
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
    final DateTime submitted = DateTime(day.year, day.month, day.day + 1, 9, 10 + roll);
    _out.add(TtDemoRequest(
      request: _move(base, fate, submitted, reason: null, deducts: false),
      submittedAt: submitted,
      documents: fate == _Fate.approved && roll.isEven
          ? <TtDemoDocument>[_document(TtDemoDocumentKind.meetingMinutes, e, checkIn, checkOut, submitted)]
          : const <TtDemoDocument>[],
    ));
  }

  void _add(
    TimeTrackerEmployee e, {
    required String typeId,
    required DateTime from,
    required DateTime to,
    required bool allDay,
    required int totalMinutes,
    required TtDemoText description,
    required _Fate fate,
    required DateTime submitted,
    TtDemoText? reason,
    TtDemoDocumentKind? document,
    List<RequestComment> comments = const <RequestComment>[],
  }) {
    final RequestType type = _types[typeId]!;
    final List<RequestApprovalStep> steps = ApprovalRouter.initialSteps(
      isManagerApprovalRequired: type.isManagerApprovalRequired,
      isHrApprovalRequired: type.isHrApprovalRequired,
      managerEmail: _managerOf(e),
      requesterEmail: e.email,
      requesterIsHrApprover: _isHr(e.email),
    );
    final TimeTrackerRequest base = TimeTrackerRequest(
      id: TtDemoIds.request(++_n),
      requesterEmail: e.email,
      requesterDepartmentId: e.departmentId,
      requestTypeId: type.id,
      description: description.of(isArabic: isArabic),
      startAt: from,
      endAt: to,
      isAllDay: allDay,
      totalMinutes: totalMinutes,
      status: ApprovalRouter.initialStatus(steps),
      approvalSteps: steps,
      currentStep: ApprovalRouter.currentStepOf(steps)?.step,
    );
    _out.add(TtDemoRequest(
      request: _move(base, fate, submitted, reason: reason, deducts: type.isDeductedFromVacationBalance),
      submittedAt: submitted,
      // 9/10/2026 (data model): comments are their own documents.
      comments: comments,
      documents: document == null
          ? const <TtDemoDocument>[]
          : <TtDemoDocument>[_document(document, e, from, to, submitted)],
    ));
  }

  /// Moves [r] through its cycle to [fate] with the module's own rules.
  TimeTrackerRequest _move(
    TimeTrackerRequest r,
    _Fate fate,
    DateTime submitted, {
    required TtDemoText? reason,
    required bool deducts,
  }) {
    final String why = (reason ?? TtDemoTexts.rejectWorkload).of(isArabic: isArabic);
    DateTime at = submitted.add(const Duration(hours: 3));
    TimeTrackerRequest approveAll(TimeTrackerRequest x) {
      TimeTrackerRequest y = x;
      while (RequestCycleRules.actionableStep(y) != null) {
        y = RequestCycleRules.approve(y, approverEmail: _deciderFor(y), at: at).after;
        at = at.add(const Duration(hours: 20));
      }
      return y;
    }

    TimeTrackerRequest approved() {
      final TimeTrackerRequest y = approveAll(r);
      final double days = deducts
          ? VacationBalanceRules.requestedDays(y, schedule: setup.locationOf(_person(y.requesterEmail)).schedule)
          : 0;
      // Data model 9/10/2026: deducted days are recorded per balance year.
      return y.copyWith(deductedDaysByYear: <int, double>{y.startAt.year: days});
    }

    switch (fate) {
      case _Fate.pending:
        return r;
      case _Fate.pendingHr:
        final RequestApprovalStep? step = RequestCycleRules.actionableStep(r);
        final bool hrFollows = r.approvalSteps.length > 1 && step?.step == ApprovalStepKind.manager;
        return hrFollows ? RequestCycleRules.approve(r, approverEmail: _deciderFor(r), at: at).after : r;
      case _Fate.approved:
        return approved();
      case _Fate.rejected:
        return RequestCycleRules.reject(r, approverEmail: _deciderFor(r), reason: why, at: at).after;
      case _Fate.canceled:
        return RequestCycleRules.cancelPending(r, reason: why);
      case _Fate.canceledByHr:
        return RequestCycleRules.cancelByHr(approved(), reason: why);
      case _Fate.underReview:
        return RequestCycleRules.requestCancellation(approved(), reason: why);
    }
  }

  /// Who decides the waiting step of [r]: the manager stored on a manager
  /// step; on an HR step an HR approver who is neither the requester nor
  /// the person who decided the earlier step.
  String _deciderFor(TimeTrackerRequest r) {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(r);
    if (step != null && step.step == ApprovalStepKind.manager && step.approverEmail.isNotEmpty) {
      return step.approverEmail;
    }
    final Set<String> taken = <String>{
      r.requesterEmail,
      for (final RequestApprovalStep s in r.approvalSteps)
        if (!s.isPending && !s.isSkipped) s.approverEmail,
    };
    for (final String hr in input.hrApprovers) {
      if (!taken.contains(hr)) return hr;
    }
    for (final TimeTrackerEmployee p in input.everyone) {
      if (!taken.contains(p.email)) return p.email;
    }
    return input.me.email;
  }

  String _managerOf(TimeTrackerEmployee e) => (input.managerOf[e.email] ?? '').trim().toLowerCase();

  bool _isHr(String email) => input.hrApprovers.contains(email);

  TimeTrackerEmployee _person(String email) =>
      input.everyone.firstWhere((TimeTrackerEmployee p) => p.email == email, orElse: () => input.me);

  /// [day] + [dayOffset] days at [hour]:[minute].
  static DateTime _at(DateTime day, int dayOffset, int hour, int minute) =>
      DateTime(day.year, day.month, day.day + dayOffset, hour, minute);

  List<RequestComment> _handover(TimeTrackerEmployee e, DateTime day) {
    final String reviewer = _managerOf(e).isNotEmpty ? _managerOf(e) : _firstHrOtherThan(e.email);
    return <RequestComment>[
      _comment(1, reviewer, TtDemoTexts.commentHandover, _at(day, 0, 11, 20)),
      _comment(2, e.email, TtDemoTexts.commentHandoverReply, _at(day, 0, 12, 5)),
    ];
  }

  List<RequestComment> _report(TimeTrackerEmployee e, DateTime day) =>
      <RequestComment>[_comment(1, _firstHrOtherThan(e.email), TtDemoTexts.commentReport, _at(day, 0, 10, 15))];

  String _firstHrOtherThan(String email) {
    for (final String hr in input.hrApprovers) {
      if (hr != email) return hr;
    }
    return email == input.me.email && input.others.isNotEmpty ? input.others.first.email : input.me.email;
  }

  RequestComment _comment(int n, String author, TtDemoText text, DateTime at) => RequestComment(
        id: 'demo_comment_$n',
        authorEmail: author.isEmpty ? input.me.email : author,
        text: text.of(isArabic: isArabic),
        createdAt: at,
      );

  TtDemoDocument _document(TtDemoDocumentKind kind, TimeTrackerEmployee e, DateTime from, DateTime to, DateTime issued) {
    final String name = e.name(isArabic: false);
    final String file = switch (kind) {
      TtDemoDocumentKind.medicalReport => 'Medical Report — $name.pdf',
      TtDemoDocumentKind.workshopInvitation => 'Workshop Invitation — Digital Government Forum.pdf',
      TtDemoDocumentKind.travelOrder => 'Travel Order — Business Mission — $name.pdf',
      TtDemoDocumentKind.meetingMinutes => 'Committee Meeting Attendance Sheet.pdf',
    };
    return TtDemoDocument(kind: kind, fileName: file, employee: e, from: from, to: to, issuedAt: issued);
  }
}
