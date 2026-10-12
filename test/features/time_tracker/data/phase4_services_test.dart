/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: phase4_services_test.dart
/// Purpose: Unit tests for the phase-4 data layer over the in-memory
///          remote: `RequestService` (form set-up, submit, cancel, ask to
///          cancel, reminder, comments), `ApprovalService` (manager → HR,
///          reject, under review, cancel after approving) with the vacation
///          deduct / refund and the transaction correction apply / revert,
///          the notifications they send, the permission + scope gates, and
///          `RoleApproverDirectory`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office');
const RequestType _annual = RequestType(id: 'annual', nameEn: 'Annual Vacation', nameAr: 'إجازة سنوية', isDeductedFromVacationBalance: true);
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave');
const RequestType _free = RequestType(id: 'free', nameEn: 'Excused', isHrApprovalRequired: false, isManagerApprovalRequired: false, isDeductedFromVacationBalance: true);
const RequestType _branch = RequestType(id: 'branch', nameEn: 'Branch Only', locationIds: <String>['branch']);
const RequestType _off = RequestType(id: 'off', nameEn: 'Off', status: RequestTypeStatus.inactive);

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1', role: 'Employee'),
  TimeTrackerEmployee(email: 'boss@co.com', nameEn: 'Boss B', departmentId: 'dep-9', role: 'Manager'),
  TimeTrackerEmployee(email: 'hr@co.com', nameEn: 'Hana R', departmentId: 'dep-5', role: 'HR'),
  TimeTrackerEmployee(email: 'lead@co.com', nameEn: 'Lead L', departmentId: 'dep-1', role: 'lead-role'),
];

final DateTime _now = DateTime(2026, 10, 5, 10);

Set<String> _without(List<String> keys) => allKeys()..removeAll(keys);

class _World {
  _World({String manager = 'boss@co.com', Set<String>? myKeys, bool balance = true, bool managerApproves = true}) {
    seedAssignment(remote, location: _hq);
    seedRequestTypes(remote, <RequestType>[_annual, _sick, _free, _branch, _off]);
    if (balance) {
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10));
    }
    me = Phase4Kit(
      remote: remote,
      // A plain employee by default (9/10/2026): with every switch ON the
      // requester would count as HR, and HR's own requests go to their
      // manager only (owner rule) — covered in request_rules_test.dart.
      access: accessWith(myKeys ?? _without(<String>['Approvals_All_Departments']), email: 'me@co.com', departmentId: 'dep-1'),
      manager: manager,
      people: _people,
      roles: <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
        FakeRoleSource.approverRole('r-hr', name: 'HR'),
        FakeRoleSource.approverRole('lead-role', all: false),
        // 9/10/2026 (code review finding 7): a manager must hold
        // Approve_And_Reject to get the manager step.
        FakeRoleSource.approverRole('r-mgr', name: 'Manager', all: false, approve: managerApproves),
      ],
      clock: () => _now,
    );
  }

  final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
  late final Phase4Kit me;

  Phase4Kit get boss => me.as(
      accessWith(_without(<String>['Approvals_All_Departments']), email: 'boss@co.com', departmentId: 'dep-9'),
      clock: () => _now);
  Phase4Kit get hr => me.as(accessWith(allKeys(), email: 'hr@co.com', departmentId: 'dep-5'), clock: () => _now);

  Future<TimeTrackerRequest> submit(RequestType type, {int days = 3}) async {
    final RequestFormSetup setup = await me.requestService.loadFormSetup();
    return me.requestService.submit(
      RequestDraft(type: type, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 12 + days - 1)),
      setup: setup,
      isArabic: false,
    );
  }

  Future<VacationBalance?> balance() =>
      me.balances.fetchBalance(employeeEmail: 'me@co.com', year: _now.year);
}

void main() {
  group('RequestService', () {
    test('form set-up: active types for my location + department, my balance', () async {
      final _World w = _World();
      final RequestFormSetup setup = await w.me.requestService.loadFormSetup();
      expect(setup.types.map((RequestType t) => t.id), <String>['annual', 'free', 'sick']);
      expect(setup.balance!.remainingDays, 10);
      expect(setup.schedule, isNotNull);
    });

    test('submit: pending at the manager, logged, the manager notified with the count', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      expect(r.status, RequestStatus.pending);
      expect(r.currentStep, ApprovalStepKind.manager);
      expect(r.approvalSteps.first.approverEmail, 'boss@co.com');
      expect(w.me.log.actions, contains(TimeTrackerLogService.actionCreateRequest));
      final SentNotification n = w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).single;
      expect(n.receiver, 'boss@co.com');
      expect(n.page, TimeTrackerNotificationPage.approvalDetails);
      expect(n.requestId, r.id);
      expect(n.variables[TemplateVariable.count], '1');
      expect(n.sender, 'me@co.com');
    });

    test('no manager → straight to HR: every HR approver covering me is notified', () async {
      final _World w = _World(manager: '');
      final TimeTrackerRequest r = await w.submit(_sick);
      expect(r.currentStep, ApprovalStepKind.hr);
      expect(
        w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).map((SentNotification n) => n.receiver).toSet(),
        <String>{'hr@co.com'},
        reason: 'owner rule 9/10/2026: the HR step = Approve_And_Reject + All Departments only (not the dep-1 lead)',
      );
    });

    test('code review 7: a manager who cannot approve is skipped at submit → HR', () async {
      final _World w = _World(managerApproves: false);
      final TimeTrackerRequest r = await w.submit(_sick);
      expect(r.currentStep, ApprovalStepKind.hr);
      expect(r.approvalSteps.where((RequestApprovalStep s) => s.step == ApprovalStepKind.manager), isEmpty);
      expect(
        w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).map((SentNotification n) => n.receiver).toSet(),
        <String>{'hr@co.com'},
      );
    });

    test('submit needs Create_Time_Tracker_Request', () async {
      final _World w = _World(myKeys: _without(<String>['Create_Time_Tracker_Request']));
      expect(() => w.submit(_sick), throwsA(isA<TimeTrackerPermissionDenied>()));
    });

    test('more days than the balance → refused, nothing stored', () async {
      final _World w = _World();
      // Owner round 9 b: the refusal names the year and its days left.
      await expectLater(
        w.submit(_annual, days: 11),
        throwsA(isA<TimeTrackerYearBalanceShort>()
            .having((TimeTrackerYearBalanceShort e) => e.year, 'year', 2026)
            .having((TimeTrackerYearBalanceShort e) => e.daysLeft, 'daysLeft', 10)),
      );
      expect(await w.me.requests.watchRequests().first, isEmpty);
    });

    test('a type that needs no approval is approved at once and deducts', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_free);
      expect(r.status, RequestStatus.approved);
      expect((await w.balance())!.usedDays, 3);
      expect(w.me.notifications.sent, isEmpty);
    });

    test('cancel a pending request: requester only, with the switch', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      expect(() => w.boss.requestService.cancelPending(r), throwsA(isA<TimeTrackerPermissionDenied>()));
      final TimeTrackerRequest c = await w.me.requestService.cancelPending(r);
      expect(c.status, RequestStatus.canceled);
      expect(w.me.log.actions, contains(TimeTrackerLogService.actionCancelRequest));
    });

    test('reminder: notifies the current approver; again within two days → too soon', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      w.me.notifications.sent.clear();
      final TimeTrackerRequest sent = await w.me.requestService.sendReminder(r, isArabic: false);
      expect(sent.lastReminderAt, _now);
      expect(w.me.notifications.sent.single.receiver, 'boss@co.com');
      expect(w.me.log.actions, contains(TimeTrackerLogService.actionSendReminder));
      await expectLater(w.me.requestService.sendReminder(r, isArabic: false), throwsA(isA<ReminderTooSoon>()));
      final Phase4Kit later = w.me.as(w.me.access, clock: () => _now.add(const Duration(days: 2)));
      expect((await later.requestService.sendReminder(r, isArabic: false)).lastReminderAt,
          _now.add(const Duration(days: 2)));
      expect(() => w.boss.requestService.sendReminder(r, isArabic: false), throwsA(isA<TimeTrackerPermissionDenied>()));
    });

    test('comments: requester and an involved approver; edit own; outsiders refused', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      // 9/10/2026 (data model): each comment is a document of
      // Requests/{id}/Comments; the request itself is not rewritten.
      final RequestComment a = await w.me.requestService.addComment(r, text: 'Doctor note follows', asApprover: false);
      final RequestComment b = await w.boss.requestService.addComment(r, text: 'OK', asApprover: true);
      final List<RequestComment> thread = await w.me.requestService.watchComments(r.id).first;
      expect(RequestCommentRules.thread(thread).map((RequestComment c) => c.authorEmail),
          <String>['me@co.com', 'boss@co.com']);
      final RequestComment edited =
          await w.me.requestService.editComment(r, commentId: a.id, text: 'Note sent', asApprover: false);
      expect(edited.text, 'Note sent');
      await expectLater(w.me.requestService.deleteComment(r, commentId: b.id, asApprover: false), throwsException);
      // HR is not involved yet (the request has not reached HR).
      await expectLater(w.hr.requestService.addComment(r, text: 'x', asApprover: true),
          throwsA(isA<TimeTrackerPermissionDenied>()));
    });
  });

  group('ApprovalService', () {
    test('manager → HR → approved: HR notified, balance deducted, requester notified', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_annual);
      final Phase4Kit boss = w.boss;
      final TimeTrackerRequest atHr =
          await boss.approvalService.approve(r, typeName: const TimeTrackerTypeName(en: 'Annual Vacation'), isArabic: false);
      expect(atHr.status, RequestStatus.pending);
      expect(atHr.currentStep, ApprovalStepKind.hr);
      expect(
        boss.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).map((SentNotification n) => n.receiver).toSet(),
        <String>{'hr@co.com'},
      );
      expect((await w.balance())!.usedDays, 0, reason: 'nothing deducted before the final approval');
      final Phase4Kit hr = w.hr;
      final TimeTrackerRequest done = await hr.approvalService
          .approve(atHr, typeName: const TimeTrackerTypeName(en: 'Annual Vacation', ar: 'إجازة سنوية'), isArabic: false);
      expect(done.status, RequestStatus.approved);
      expect((await w.balance())!.usedDays, 3);
      final SentNotification n = hr.notifications.of(TimeTrackerNotificationEvent.requestApprovedAttendanceLeave).single;
      expect(n.receiver, 'me@co.com');
      expect(n.page, TimeTrackerNotificationPage.requestDetails);
      expect(n.variables[TemplateVariable.requestType], 'Annual Vacation');
      expect(hr.log.actions, contains(TimeTrackerLogService.actionApprove));
    });

    test('the last days used → "Vacation Limit Reached"', () async {
      final _World w = _World(manager: '');
      seedBalance(w.remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 3));
      final TimeTrackerRequest r = await w.submit(_annual);
      final Phase4Kit hr = w.hr;
      await hr.approvalService.approve(r, typeName: const TimeTrackerTypeName(en: 'Annual Vacation'), isArabic: false);
      expect(hr.notifications.of(TimeTrackerNotificationEvent.vacationEntitlementExhausted).single.receiver, 'me@co.com');
    });

    test('who may decide: the stored manager at step 1; HR in scope at step 2; never yourself', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Sick Leave');
      expect(w.hr.approvalService.mayDecide(r), isFalse, reason: 'step 1 is the manager');
      expect(() => w.hr.approvalService.approve(r, typeName: name, isArabic: false),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      final TimeTrackerRequest atHr = await w.boss.approvalService.approve(r, typeName: name, isArabic: false);
      expect(w.boss.approvalService.mayDecide(atHr), isFalse, reason: 'boss: dep-9, no All Departments');
      final Phase4Kit lead = w.me.as(
          accessWith(_without(<String>['Approvals_All_Departments']), email: 'lead@co.com', departmentId: 'dep-1'),
          clock: () => _now);
      expect(lead.approvalService.mayDecide(atHr), isFalse,
          reason: 'owner rule 9/10/2026: the HR step needs All Departments (own department is not enough)');
      expect(w.hr.approvalService.mayDecide(atHr), isTrue);
      expect(w.me.approvalService.mayDecide(atHr), isFalse, reason: 'nobody decides their own request');
      final Phase4Kit noSwitch = w.me.as(
          accessWith(_without(<String>['Approve_And_Reject']), email: 'hr@co.com', departmentId: 'dep-5'),
          clock: () => _now);
      expect(noSwitch.approvalService.mayDecide(atHr), isFalse);
    });

    test('reject: reason required; requester notified', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Sick Leave');
      expect(() => w.boss.approvalService.reject(r, reason: ' ', typeName: name, isArabic: false), throwsStateError);
      final Phase4Kit boss = w.boss;
      final TimeTrackerRequest rejected =
          await boss.approvalService.reject(r, reason: 'Team is short', typeName: name, isArabic: false);
      expect(rejected.status, RequestStatus.rejected);
      expect(rejected.approvalSteps.first.reason, 'Team is short');
      expect(boss.notifications.of(TimeTrackerNotificationEvent.requestRejected).single.receiver, 'me@co.com');
      expect(boss.log.actions, contains(TimeTrackerLogService.actionReject));
    });

    test('employee asks to cancel an approved request → both approve → canceled + refund', () async {
      final _World w = _World();
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Annual Vacation');
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.boss.approvalService.approve(r, typeName: name, isArabic: false);
      r = await w.hr.approvalService.approve(r, typeName: name, isArabic: false);
      expect((await w.balance())!.usedDays, 3);
      w.me.notifications.sent.clear();
      r = await w.me.requestService.requestCancellation(r, reason: 'Trip canceled', isArabic: false);
      expect(r.status, RequestStatus.underReview);
      expect(w.me.notifications.sent.single.receiver, 'boss@co.com');
      expect(w.me.log.actions, contains(TimeTrackerLogService.actionRequestCancellation));
      r = await w.boss.approvalService.approve(r, typeName: name, isArabic: false);
      expect(r.status, RequestStatus.underReview);
      final Phase4Kit hr = w.hr;
      r = await hr.approvalService.approve(r, typeName: name, isArabic: false);
      expect(r.status, RequestStatus.canceled);
      expect((await w.balance())!.usedDays, 0);
      expect(hr.notifications.of(TimeTrackerNotificationEvent.requestCanceled).single.receiver, 'me@co.com');
      expect(hr.log.actions, contains(TimeTrackerLogService.actionApproveCancellation));
    });

    test('a refused cancellation keeps the request approved (no refund)', () async {
      final _World w = _World(manager: '');
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Annual Vacation');
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.hr.approvalService.approve(r, typeName: name, isArabic: false);
      r = await w.me.requestService.requestCancellation(r, reason: 'x', isArabic: false);
      final Phase4Kit hr = w.hr;
      r = await hr.approvalService.reject(r, reason: 'Already booked', typeName: name, isArabic: false);
      expect(r.status, RequestStatus.approved);
      expect((await w.balance())!.usedDays, 3);
      expect(hr.log.actions, contains(TimeTrackerLogService.actionRejectCancellation));
      expect(hr.notifications.sent, isEmpty);
    });

    test('HR cancels after approving: Canceled By HR + refund; gated and never your own', () async {
      final _World w = _World(manager: '');
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Annual Vacation');
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.hr.approvalService.approve(r, typeName: name, isArabic: false);
      final Phase4Kit noSwitch = w.me.as(
          accessWith(_without(<String>['Cancel_Request_After_Approving']), email: 'hr@co.com', departmentId: 'dep-5'),
          clock: () => _now);
      expect(noSwitch.approvalService.mayCancelAfterApproving(r), isFalse);
      expect(w.me.approvalService.mayCancelAfterApproving(r), isFalse);
      final Phase4Kit hr = w.hr;
      r = await hr.approvalService.cancelAfterApproving(r, reason: 'Audit', typeName: name, isArabic: false);
      expect(r.status, RequestStatus.canceledByHr);
      expect(r.cancellationReason, 'Audit');
      expect((await w.balance())!.usedDays, 0);
      expect(hr.notifications.of(TimeTrackerNotificationEvent.requestCanceled).single.receiver, 'me@co.com');
      expect(hr.log.actions, contains(TimeTrackerLogService.actionCancelAfterApproving));
    });
  });

  group('Transactions', () {
    test('submit notifies the manager; approved → the day is corrected; canceled by HR → reverted', () async {
      final _World w = _World();
      final TransactionService txService = TransactionService(
        requests: w.me.requests,
        managers: w.me.managers,
        access: w.me.access,
        log: w.me.log,
        approvers: w.me.approvers,
        notifier: w.me.notifications,
        clock: () => _now,
      );
      // The sweep had marked 1 Oct absent.
      await w.me.attendance.saveDay(
        day: AttendanceDay(id: '', employeeEmail: 'me@co.com', date: DateTime(2026, 10, 1), status: AttendanceStatus.absent),
      );
      TimeTrackerRequest tx = await txService.submit(
        checkIn: DateTime(2026, 10, 1, 9),
        checkOut: DateTime(2026, 10, 1, 17),
        description: 'Forgot to check in',
      );
      expect(w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).single.receiver, 'boss@co.com');
      const TimeTrackerTypeName name = TimeTrackerTypeName(en: 'Transaction');
      tx = await w.boss.approvalService.approve(tx, typeName: name, isArabic: false);
      final Phase4Kit hr = w.hr;
      tx = await hr.approvalService.approve(tx, typeName: name, isArabic: false);
      expect(tx.status, RequestStatus.approved);
      expect(hr.notifications.of(TimeTrackerNotificationEvent.attendanceCorrectionApproved).single.receiver, 'me@co.com');
      AttendanceDay? day = await w.me.attendance.fetchDay(employeeEmail: 'me@co.com', date: DateTime(2026, 10, 1));
      expect(day!.status, AttendanceStatus.present);
      expect(day.isCorrectedByTransaction, isTrue);
      expect(day.sourceRequestId, tx.id);
      expect(day.totalWorkMinutes, 480);
      tx = await hr.approvalService.cancelAfterApproving(tx, reason: 'Wrong day', typeName: name, isArabic: false);
      day = await w.me.attendance.fetchDay(employeeEmail: 'me@co.com', date: DateTime(2026, 10, 1));
      expect(day!.status, AttendanceStatus.absent);
      expect(day.sessions, isEmpty);
      expect(day.isCorrectedByTransaction, isFalse);
    });

    test('a pending transaction is canceled with Cancel_Transaction', () async {
      final _World w = _World(myKeys: _without(<String>['Cancel_Transaction']));
      final TransactionService txService = TransactionService(
        requests: w.me.requests,
        managers: w.me.managers,
        access: w.me.access,
        log: w.me.log,
        clock: () => _now,
      );
      final TimeTrackerRequest tx = await txService.submit(
        checkIn: DateTime(2026, 10, 1, 9),
        checkOut: DateTime(2026, 10, 1, 17),
        description: '',
      );
      expect(() => w.me.requestService.cancelPending(tx), throwsA(isA<TimeTrackerPermissionDenied>()));
      final _World ok = _World();
      final TimeTrackerRequest tx2 = await TransactionService(
        requests: ok.me.requests,
        managers: ok.me.managers,
        access: ok.me.access,
        log: ok.me.log,
        clock: () => _now,
      ).submit(checkIn: DateTime(2026, 10, 1, 9), checkOut: DateTime(2026, 10, 1, 17), description: '');
      expect((await ok.me.requestService.cancelPending(tx2)).status, RequestStatus.canceled);
      expect(ok.me.log.actions, contains(TimeTrackerLogService.actionCancelTransaction));
    });
  });

  group('RoleApproverDirectory', () {
    test('roles by name or id with the module + switches; scope; cached', () async {
      final _World w = _World();
      // Owner rule 9/10/2026: HR approvers = All Departments holders only.
      final List<TimeTrackerApprover> hr = await w.me.approvers.fetchHrApprovers();
      expect(hr.map((TimeTrackerApprover a) => a.email).toSet(), <String>{'hr@co.com'});
      final List<TimeTrackerApprover> approvers = await w.me.approvers.fetchApprovers();
      expect(approvers.map((TimeTrackerApprover a) => a.email).toSet(), <String>{'hr@co.com', 'lead@co.com', 'boss@co.com'});
      final TimeTrackerApprover lead = approvers.firstWhere((TimeTrackerApprover a) => a.email == 'lead@co.com');
      expect(lead.allDepartments, isFalse);
      expect(lead.covers('dep-1'), isTrue);
      expect(lead.covers('dep-2'), isFalse);
      expect(await w.me.approvers.mayApprove('boss@co.com'), isTrue);
      expect(await w.me.approvers.mayApprove('me@co.com'), isFalse);
      await w.me.approvers.fetchHrApprovers();
      expect(w.me.roleSource.reads, 1);
    });

    test('a role without the Time Tracker module grants nothing', () async {
      final _World w = _World();
      final Phase4Kit k = Phase4Kit(
        remote: w.remote,
        access: w.me.access,
        people: _people,
        roles: <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
          FakeRoleSource.approverRole('r-hr', name: 'HR', modules: const <String>['crm']),
        ],
      );
      expect(await k.approvers.fetchHrApprovers(), isEmpty);
    });

    test('a request with nothing waiting notifies nobody', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_free);
      expect(await w.me.approvers.waitingApprovers(r), isEmpty);
    });
  });
}
