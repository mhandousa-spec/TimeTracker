/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: request_list_rules.dart
/// Purpose: Declares the list logic of the Requests and Approvals tabs —
///          `RequestBucket` (the status counters), `RequestKind` +
///          `RequestFilter` (the Filter popup), `RequestList` (mine,
///          counts, search / filter, newest first) and `ApprovalInbox`
///          (which requests involve an approver, and how many wait for one).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Requests tab (inventory §C `661:14909`): All · Approved · Pending ·
/// Rejected · Under Review · Canceled (Canceled By HR counted as Canceled).
/// Approvals tab (§H2 `661:83996`): All · Approved · Pending · Rejected ·
/// Canceled — no Under Review counter, so a cancellation under review counts
/// as Pending there. Filter popup (owner 9/10/2026, replacing Figma
/// `661:93425`): Request Type (incl. Transaction) · Status · From – To; the
/// Approvals tab adds Department and Employee.
///
/// Approvals involvement (brief §B, FINAL SPEC scope rule): a request is in
/// a viewer's Approvals tab when it is not their own and they are its direct
/// manager (manager step), or an HR approver in scope (`Approve_And_Reject`
/// + All Departments or the same department) once the request reached its
/// HR step, or — with `Cancel_Request_After_Approving` in scope — it is
/// approved / canceled by HR. Pure Dart, unit-tested.
/// Updated: 9/10/2026 - code review (FINAL SPEC wins): the HR step involves
/// ONLY "All Departments" approvers and never the person who decided the
/// manager step of the same round; nothing involves a viewer without
/// `View_Approvals`; rounds are read one at a time (finding 5) and a
/// `skipped` step counts as passed; an HR approver also sees a request whose
/// manager step is BLOCKED (the manager cannot act — finding 7).

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/approval_router.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_cycle_rules.dart';

/// One status counter.
enum RequestBucket {
  all,
  approved,
  pending,
  rejected,
  underReview,
  canceled;

  /// Function Name: [matches]
  ///
  /// Purpose: Whether [status] falls in this bucket. [underReviewAsPending]
  /// = the Approvals tab (no Under Review counter).
  ///
  /// Return type: [bool]
  bool matches(RequestStatus status, {bool underReviewAsPending = false}) {
    switch (this) {
      case RequestBucket.all:
        return true;
      case RequestBucket.approved:
        return status == RequestStatus.approved;
      case RequestBucket.pending:
        return status == RequestStatus.pending ||
            (underReviewAsPending && status == RequestStatus.underReview);
      case RequestBucket.rejected:
        return status == RequestStatus.rejected;
      case RequestBucket.underReview:
        return !underReviewAsPending && status == RequestStatus.underReview;
      case RequestBucket.canceled:
        return status == RequestStatus.canceled || status == RequestStatus.canceledByHr;
    }
  }
}

/// The kind a filter can ask for (the Request Type dropdown offers
/// "Transaction" next to the request types).
enum RequestKind { request, transaction }

/// The Filter popup's values (null = any).
///
/// UI quality pass (owner 13:45 #3): the meaningful fields only — Request
/// Type (or "Transaction"), Status and a date RANGE (from – to); the
/// Approvals tab adds Department (scope rules) and Employee. "Total Time"
/// and "Day" are gone.
class RequestFilter {
  const RequestFilter({
    this.kind,
    this.requestTypeId,
    this.status,
    this.from,
    this.to,
    this.departmentId,
    this.employeeEmail,
  });

  final RequestKind? kind;
  final String? requestTypeId;
  final RequestStatus? status;

  /// The request must touch [from] … [to] (calendar days, both optional).
  final DateTime? from;
  final DateTime? to;

  /// Approvals only: the requester's department.
  final String? departmentId;

  /// Approvals only: the requester (lower-cased).
  final String? employeeEmail;

  static const RequestFilter none = RequestFilter();

  bool get isActive =>
      kind != null ||
      requestTypeId != null ||
      status != null ||
      from != null ||
      to != null ||
      departmentId != null ||
      (employeeEmail ?? '').isNotEmpty;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [matches]
  ///
  /// Return type: [bool] — [request] passes every set criterion.
  bool matches(TimeTrackerRequest request) {
    final RequestKind? k = kind;
    if (k != null && (k == RequestKind.transaction) != request.isTransaction) return false;
    final String? type = requestTypeId;
    if (type != null && request.requestTypeId != type) return false;
    final RequestStatus? st = status;
    if (st != null && request.status != st) return false;
    final DateTime first = _day(request.startAt);
    final DateTime last = _day(request.endAt);
    final DateTime? a = from;
    if (a != null && last.isBefore(_day(a))) return false;
    final DateTime? b = to;
    if (b != null && first.isAfter(_day(b))) return false;
    final String? dep = departmentId;
    if (dep != null && request.requesterDepartmentId.trim() != dep.trim()) return false;
    final String who = (employeeEmail ?? '').trim().toLowerCase();
    if (who.isNotEmpty && request.requesterEmail.trim().toLowerCase() != who) return false;
    return true;
  }
}

class RequestList {
  const RequestList._();

  /// Function Name: [mine]
  ///
  /// Purpose: The requests and transactions [email] submitted.
  ///
  /// Return type: [List<TimeTrackerRequest>]
  static List<TimeTrackerRequest> mine(List<TimeTrackerRequest> all, String email) =>
      List<TimeTrackerRequest>.unmodifiable(
        all.where((TimeTrackerRequest r) => RequestCycleRules.isRequester(r, email)),
      );

  /// Function Name: [counts]
  ///
  /// Purpose: How many of [list] fall in each bucket.
  ///
  /// Return type: [Map<RequestBucket, int>]
  static Map<RequestBucket, int> counts(
    List<TimeTrackerRequest> list, {
    bool underReviewAsPending = false,
  }) =>
      <RequestBucket, int>{
        for (final RequestBucket b in RequestBucket.values)
          b: list
              .where((TimeTrackerRequest r) =>
                  b.matches(r.status, underReviewAsPending: underReviewAsPending))
              .length,
      };

  /// Function Name: [filter]
  ///
  /// Purpose: [list] in [bucket], matching [query] (against [textOf]) and
  /// [filter], newest first.
  ///
  /// Return type: [List<TimeTrackerRequest>]
  static List<TimeTrackerRequest> filter(
    List<TimeTrackerRequest> list, {
    RequestBucket bucket = RequestBucket.all,
    String query = '',
    RequestFilter filter = RequestFilter.none,
    String requesterEmail = '',
    bool underReviewAsPending = false,
    required String Function(TimeTrackerRequest) textOf,
  }) {
    final String q = query.trim().toLowerCase();
    final String who = requesterEmail.trim().toLowerCase();
    final List<TimeTrackerRequest> out = <TimeTrackerRequest>[
      for (final TimeTrackerRequest r in list)
        if (bucket.matches(r.status, underReviewAsPending: underReviewAsPending) &&
            filter.matches(r) &&
            (who.isEmpty || r.requesterEmail.trim().toLowerCase() == who) &&
            (q.isEmpty || textOf(r).toLowerCase().contains(q)))
          r,
    ]..sort(newestFirst);
    return List<TimeTrackerRequest>.unmodifiable(out);
  }

  /// Function Name: [newestFirst]
  ///
  /// Purpose: Sort order — request date (creation), then start, then id.
  ///
  /// Return type: [int]
  static int newestFirst(TimeTrackerRequest a, TimeTrackerRequest b) {
    final DateTime x = a.audit.createdAt ?? a.startAt;
    final DateTime y = b.audit.createdAt ?? b.startAt;
    final int byDate = y.compareTo(x);
    return byDate != 0 ? byDate : b.id.compareTo(a.id);
  }
}

/// Who is looking at the Approvals tab.
class ApproverView {
  const ApproverView({
    required this.email,
    required this.departmentId,
    required this.canApproveAndReject,
    required this.allDepartments,
    required this.canCancelAfterApproving,
    this.canViewApprovals = true,
    this.activeApprovers,
  });

  final String email;
  final String departmentId;
  final bool canApproveAndReject;
  final bool allDepartments;
  final bool canCancelAfterApproving;

  /// ADDED 9/10/2026 (code review): the `View_Approvals` switch — without
  /// it nothing is in the viewer's Approvals.
  final bool canViewApprovals;

  /// ADDED 9/10/2026 (code review finding 7): the e-mails that may act as
  /// approvers (null = not known yet → no manager step counts as blocked).
  final Set<String>? activeApprovers;

  /// HR approver: `Approve_And_Reject` + "All Departments" (FINAL SPEC).
  bool get isHrApprover => canApproveAndReject && allDepartments;

  /// Function Name: [withActiveApprovers]
  ///
  /// Return type: [ApproverView] — this view knowing [emails].
  ApproverView withActiveApprovers(Set<String> emails) => ApproverView(
        email: email,
        departmentId: departmentId,
        canApproveAndReject: canApproveAndReject,
        allDepartments: allDepartments,
        canCancelAfterApproving: canCancelAfterApproving,
        canViewApprovals: canViewApprovals,
        activeApprovers: <String>{for (final String e in emails) e.trim().toLowerCase()},
      );

  /// [departmentId] is inside the viewer's approvals scope.
  bool covers(String requesterDepartmentId) =>
      allDepartments ||
      (departmentId.trim().isNotEmpty && departmentId.trim() == requesterDepartmentId.trim());
}

class ApprovalInbox {
  const ApprovalInbox._();

  static String _norm(String email) => email.trim().toLowerCase();

  /// Function Name: [isDirectManager]
  ///
  /// Return type: [bool] — [email] is the request's manager-step approver.
  static bool isDirectManager(TimeTrackerRequest request, String email) =>
      _norm(email).isNotEmpty &&
      request.approvalSteps.any((RequestApprovalStep s) =>
          s.step == ApprovalStepKind.manager && _norm(s.approverEmail) == _norm(email));

  /// Function Name: [reachedHr]
  ///
  /// Purpose: The request got to an HR step: every earlier step of THAT
  /// round approved or passed (`skipped`) — rounds are separate (finding 5).
  ///
  /// Return type: [bool]
  static bool reachedHr(TimeTrackerRequest request) {
    final List<RequestApprovalStep> steps = request.approvalSteps;
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].step != ApprovalStepKind.hr || steps[i].isSkipped) continue;
      bool before = true;
      for (int j = ApprovalRouter.roundStartOf(steps, i); j < i; j++) {
        if (!steps[j].isCleared) before = false;
      }
      if (before) return true;
    }
    return false;
  }

  /// Function Name: [isManagerStepBlocked]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 7) — [request] waits on a
  /// manager step whose manager is not among [activeApprovers] (no approve
  /// switch any more / not an active employee). Null = unknown → false.
  ///
  /// Return type: [bool]
  static bool isManagerStepBlocked(TimeTrackerRequest request, Set<String>? activeApprovers) {
    final Set<String>? known = activeApprovers;
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    if (known == null || step == null || step.step != ApprovalStepKind.manager) return false;
    return !known.contains(_norm(step.approverEmail));
  }

  /// Function Name: [involves]
  ///
  /// Purpose: Whether [request] belongs in [viewer]'s Approvals tab (see the
  /// file header).
  ///
  /// Return type: [bool]
  static bool involves(TimeTrackerRequest request, ApproverView viewer) {
    if (!viewer.canViewApprovals ||
        _norm(viewer.email).isEmpty ||
        RequestCycleRules.isRequester(request, viewer.email)) {
      return false;
    }
    if (isDirectManager(request, viewer.email)) return true;
    if (viewer.isHrApprover &&
        (reachedHr(request) || isManagerStepBlocked(request, viewer.activeApprovers))) {
      return true;
    }
    return viewer.covers(request.requesterDepartmentId) &&
        viewer.canCancelAfterApproving &&
        (request.status == RequestStatus.approved || request.status == RequestStatus.canceledByHr);
  }

  /// Function Name: [of]
  ///
  /// Purpose: Every request of [all] in [viewer]'s Approvals tab.
  ///
  /// Return type: [List<TimeTrackerRequest>]
  static List<TimeTrackerRequest> of(List<TimeTrackerRequest> all, ApproverView viewer) =>
      List<TimeTrackerRequest>.unmodifiable(
        all.where((TimeTrackerRequest r) => involves(r, viewer)),
      );

  /// Function Name: [waitsFor]
  ///
  /// Purpose: Whether [request]'s current step waits for [email]: the
  /// manager step stored for them, or an HR step when they are an HR
  /// approver (`Approve_And_Reject` + "All Departments" — FINAL SPEC) who
  /// did not decide the manager step of the same round. [hrDepartmentId] is
  /// kept for callers; it no longer widens anything (9/10/2026).
  ///
  /// Return type: [bool]
  static bool waitsFor(
    TimeTrackerRequest request, {
    required String email,
    bool isHrApprover = false,
    bool hrAllDepartments = false,
    String hrDepartmentId = '',
  }) {
    final RequestApprovalStep? step = RequestCycleRules.actionableStep(request);
    if (step == null || RequestCycleRules.isRequester(request, email)) return false;
    if (step.step == ApprovalStepKind.manager) return _norm(step.approverEmail) == _norm(email);
    return isHrApprover &&
        hrAllDepartments &&
        !ApprovalRouter.decidedInRound(request.approvalSteps, step, email);
  }

  /// Function Name: [waitingCount]
  ///
  /// Purpose: How many of [all] currently wait for [email] (the "{count}"
  /// of the Pending Approvals notification).
  ///
  /// Return type: [int]
  static int waitingCount(
    List<TimeTrackerRequest> all, {
    required String email,
    bool isHrApprover = false,
    bool hrAllDepartments = false,
    String hrDepartmentId = '',
  }) =>
      all
          .where((TimeTrackerRequest r) => waitsFor(
                r,
                email: email,
                isHrApprover: isHrApprover,
                hrAllDepartments: hrAllDepartments,
                hrDepartmentId: hrDepartmentId,
              ))
          .length;
}
