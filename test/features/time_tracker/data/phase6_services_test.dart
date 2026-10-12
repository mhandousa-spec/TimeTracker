/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: phase6_services_test.dart
/// Purpose: Phase-6 data-layer tests over the in-memory remote:
///          * `TimeTrackerReminderSweeper` + `TimeTrackerNotificationLogRepository`
///            — missed check-in, forgot to check out, pending approvals
///            (receiver, page, sender, Request_Id), sent ONCE (Notification_Log
///            markers, a second device stays silent), throttle, gates, a log
///            that cannot be reached;
///          * every phase-4 notification (fake sender): event, receiver,
///            page, `Request_Id`, sender and the rendered EN / AR text;
///          * the Notification Control catalogue (all Time Tracker events
///            under the Time Tracker tab);
///          * System Log: the action list, every action logged somewhere,
///            under `Modules.timeTracker`, and the System Logs module filter.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/time_tracker_module/time_tracker_notification_pages.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_notification_log_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_reminder_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

// ── Shared set-up ──────────────────────────────────────────────────────────

/// 9:00 → 17:00 every day, 10 minutes grace.
const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', lateAfterMinutes: 10);

Set<String> _without(List<String> keys) => allKeys()..removeAll(keys);

/// Records every send (incl. the Arabic variables) instead of sending.
class _Recorder extends TimeTrackerNotificationService {
  final List<_Sent> sent = <_Sent>[];

  List<_Sent> of(TimeTrackerNotificationEvent e) => sent.where((_Sent s) => s.event == e).toList();

  @override
  Future<bool> send({
    required TimeTrackerNotificationEvent event,
    required TimeTrackerNotificationPage page,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const <TemplateVariable, String>{},
    Map<TemplateVariable, String> variablesAr = const <TemplateVariable, String>{},
    String requestId = '',
  }) async {
    sent.add(_Sent(event, page, senderEmail, receiverEmail.toLowerCase(), requestId, variables, variablesAr));
    return true;
  }
}

class _Sent {
  const _Sent(this.event, this.page, this.sender, this.receiver, this.requestId, this.variables, this.variablesAr);

  final TimeTrackerNotificationEvent event;
  final TimeTrackerNotificationPage page;
  final String sender;
  final String receiver;
  final String requestId;
  final Map<TemplateVariable, String> variables;
  final Map<TemplateVariable, String> variablesAr;

  /// The catalogue default rendered like `AppNotificationSender` does
  /// (Arabic falls back to the EN value of a variable it does not override).
  String body({bool arabic = false}) {
    String text = arabic ? event.bodyAr : event.bodyEn;
    final Map<TemplateVariable, String> values =
        arabic ? <TemplateVariable, String>{...variables, ...variablesAr} : variables;
    values.forEach((TemplateVariable v, String value) => text = text.replaceAll(v.token, value));
    return text;
  }
}

/// A remote whose Notification_Log cannot be written.
class _LogDownRemote extends FakeTimeTrackerRemote {
  @override
  Future<bool> createIfAbsent({
    required String relativePath,
    required String id,
    required HistoryRowBuilder row,
  }) {
    if (relativePath == TimeTrackerFirestorePaths.notificationLog) {
      return Future<bool>.error(StateError('offline'));
    }
    return super.createIfAbsent(relativePath: relativePath, id: id, row: row);
  }
}

class _SweepWorld {
  _SweepWorld({
    required this.now,
    Set<String>? keys,
    FakeTimeTrackerRemote? remote,
    String email = 'me@co.com',
  }) : remote = remote ?? FakeTimeTrackerRemote() {
    access = accessWith(keys ?? allKeys(), email: email, departmentId: 'dep-1');
    seedAssignment(this.remote, location: _hq, email: email);
  }

  DateTime now;
  final FakeTimeTrackerRemote remote;
  late final TimeTrackerAccess access;
  final _Recorder notifications = _Recorder();

  late final AttendanceRepositoryImpl attendance = AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
  late final RequestRepositoryImpl requests = RequestRepositoryImpl(remoteDataSource: remote, access: access);

  TimeTrackerReminderSweeper sweeper() => TimeTrackerReminderSweeper(
        attendance: attendance,
        requests: requests,
        resolver: noHrResolver(remote),
        access: access,
        log: TimeTrackerNotificationLogRepository(remoteDataSource: remote, access: access),
        notifier: notifications,
        clock: () => now,
      );

  Map<String, Map<String, dynamic>> get markers =>
      remote.store[TimeTrackerFirestorePaths.notificationLog] ?? <String, Map<String, dynamic>>{};
}

// ── Phase-4 world (same as phase4_services_test) ──────────────────────────

const RequestType _annual =
    RequestType(id: 'annual', nameEn: 'Annual Vacation', nameAr: 'إجازة سنوية', isDeductedFromVacationBalance: true);
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1', role: 'Employee'),
  TimeTrackerEmployee(email: 'boss@co.com', nameEn: 'Boss B', departmentId: 'dep-9', role: 'Manager'),
  TimeTrackerEmployee(email: 'hr@co.com', nameEn: 'Hana R', departmentId: 'dep-5', role: 'HR'),
];

final DateTime _now = DateTime(2026, 10, 5, 10);

class _World {
  _World({String manager = 'boss@co.com'}) {
    seedAssignment(remote, location: _hq);
    seedRequestTypes(remote, <RequestType>[_annual, _sick]);
    seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 3));
    me = Phase4Kit(
      remote: remote,
      access: accessWith(_without(<String>['Approvals_All_Departments']), email: 'me@co.com', departmentId: 'dep-1'),
      manager: manager,
      people: _people,
      // 9/10/2026 (code review finding 7): the direct manager must hold
      // Approve_And_Reject, else the request skips to HR.
      roles: <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
        FakeRoleSource.approverRole('r-hr', name: 'HR'),
        FakeRoleSource.approverRole('r-mgr', name: 'Manager', all: false),
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
}

/// No leftover `{{placeholder}}` in [n]'s EN and AR text.
void _expectRendered(SentNotification n, {String? en, String? ar}) {
  String render(String body, Map<TemplateVariable, String> values) {
    String text = body;
    values.forEach((TemplateVariable v, String value) => text = text.replaceAll(v.token, value));
    return text;
  }

  final String textEn = render(n.event.bodyEn, n.variables);
  final String textAr = render(n.event.bodyAr, n.variables);
  expect(textEn, isNot(contains('{{')), reason: n.event.key);
  expect(textAr, isNot(contains('{{')), reason: n.event.key);
  if (en != null) expect(textEn, contains(en));
  if (ar != null) expect(textAr, contains(ar));
  expect(n.variables.keys.toSet().containsAll(n.event.variables), isTrue, reason: n.event.key);
}

void main() {
  group('TimeTrackerReminderSweeper — missed check-in', () {
    test('after start + grace with no check-in: the employee, once, from the system, opening the module', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 9, 15));
      final TimeTrackerSweepReport first = await w.sweeper().sweep(isArabic: false);
      expect(first.sent, 1);
      final _Sent n = w.notifications.of(TimeTrackerNotificationEvent.missedCheckIn).single;
      expect(n.receiver, 'me@co.com');
      expect(n.sender, TimeTrackerReminderSweeper.systemSender);
      expect(n.page, TimeTrackerNotificationPage.mainPage);
      expect(n.requestId, isEmpty, reason: 'no Request_Id → View opens the module main page');
      final String marker = TimeTrackerFirestorePaths.notificationLogDocId(
          'me@co.com_2026-10-12', 'missed_check_in', DateTime(2026, 10, 12, 9, 10).millisecondsSinceEpoch);
      expect(w.markers.keys, <String>[marker]);
      expect(TimeTrackerHistoryCodec.lastOf(w.markers[marker]!, 'Receiver_Email'), 'me@co.com');
      expect(TimeTrackerHistoryCodec.lastOf(w.markers[marker]!, 'Event_Key'), 'missed_check_in');

      // Again, and on a second device: already in Notification_Log.
      final TimeTrackerSweepReport again = await w.sweeper().sweep(isArabic: false);
      expect(again.sent, 0);
      expect(again.alreadySent, 1);
      expect(w.notifications.sent, hasLength(1));
    });

    test('before the grace, once checked in, or without Check_In_And_Out: nothing', () async {
      final _SweepWorld early = _SweepWorld(now: DateTime(2026, 10, 12, 9, 5));
      expect((await early.sweeper().sweep(isArabic: false)).due, 0);

      final _SweepWorld inside = _SweepWorld(now: DateTime(2026, 10, 12, 11));
      await inside.attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: DateTime(2026, 10, 12),
          sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 12, 9, 30))],
        ),
      );
      expect((await inside.sweeper().sweep(isArabic: false)).due, 0);

      final _SweepWorld noSwitch = _SweepWorld(now: DateTime(2026, 10, 12, 11), keys: _without(<String>['Check_In_And_Out']));
      expect((await noSwitch.sweeper().sweep(isArabic: false)).due, 0);
    });

    test('an approved leave covering today: nothing', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 11));
      seedRequests(w.remote, <TimeTrackerRequest>[
        TimeTrackerRequest(
          id: 'leave',
          requesterEmail: 'me@co.com',
          requestTypeId: 'sick',
          startAt: DateTime(2026, 10, 11),
          endAt: DateTime(2026, 10, 13),
          isAllDay: true,
          status: RequestStatus.approved,
        ),
      ]);
      expect((await w.sweeper().sweep(isArabic: false)).due, 0);
    });
  });

  group('TimeTrackerReminderSweeper — forgot to check out', () {
    test('still checked in 30 min after the end: "Check-Out Not Recorded" once', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 17, 45));
      await w.attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: DateTime(2026, 10, 12),
          sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 12, 9))],
        ),
      );
      final TimeTrackerSweepReport r = await w.sweeper().sweep(isArabic: true);
      expect(r.sent, 1);
      final _Sent n = w.notifications.sent.single;
      expect(n.event, TimeTrackerNotificationEvent.missedCheckOut);
      expect(n.page, TimeTrackerNotificationPage.mainPage);
      expect(n.receiver, 'me@co.com');
      expect((await w.sweeper().sweep(isArabic: true)).alreadySent, 1);
      expect(w.notifications.sent, hasLength(1));
    });

    test('an overnight session started yesterday is followed', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 13, 8));
      await w.attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: DateTime(2026, 10, 12),
          sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 12, 9))],
        ),
      );
      await w.sweeper().sweep(isArabic: false);
      expect(w.notifications.of(TimeTrackerNotificationEvent.missedCheckOut), hasLength(1));
      expect(w.notifications.of(TimeTrackerNotificationEvent.missedCheckIn), isEmpty,
          reason: 'still in yesterday\'s session — not a missed check-in');
    });
  });

  group('TimeTrackerReminderSweeper — pending approvals', () {
    test('requests waiting > 2 days for me: one notification a day with the count and the oldest', () async {
      final _SweepWorld w = _SweepWorld(
        now: DateTime(2026, 10, 10, 9),
        email: 'boss@co.com',
        keys: _without(<String>['Check_In_And_Out', 'Approvals_All_Departments']),
      );
      seedRequests(
        w.remote,
        <TimeTrackerRequest>[
          for (final String id in <String>['r1', 'r2'])
            TimeTrackerRequest(
              id: id,
              requesterEmail: 'me@co.com',
              requesterDepartmentId: 'dep-1',
              requestTypeId: 'sick',
              startAt: DateTime(2026, 10, 20),
              endAt: DateTime(2026, 10, 20),
              approvalSteps: const <RequestApprovalStep>[
                RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com'),
              ],
              currentStep: ApprovalStepKind.manager,
            ),
        ],
        at: DateTime(2026, 10, 1),
      );
      final TimeTrackerSweepReport r = await w.sweeper().sweep(isArabic: false);
      expect(r.sent, 1);
      final _Sent n = w.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).single;
      expect(n.receiver, 'boss@co.com');
      expect(n.page, TimeTrackerNotificationPage.approvalDetails);
      expect(n.variables[TemplateVariable.count], '2');
      expect(<String>['r1', 'r2'], contains(n.requestId));
      expect(n.body(), contains('2 requests'));

      // Same day: silent. Next day: again.
      expect((await w.sweeper().sweep(isArabic: false)).sent, 0);
      w.now = DateTime(2026, 10, 11, 9);
      expect((await w.sweeper().sweep(isArabic: false)).sent, 1);
    });

    test('without Approve And Reject: nothing', () async {
      final _SweepWorld w = _SweepWorld(
        now: DateTime(2026, 10, 10, 9),
        email: 'boss@co.com',
        keys: _without(<String>['Check_In_And_Out', 'Approve_And_Reject']),
      );
      expect((await w.sweeper().sweep(isArabic: false)).due, 0);
    });
  });

  group('TimeTrackerReminderSweeper — robustness', () {
    test('sweepIfDue: at most once every 15 minutes per user', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 9, 15));
      final TimeTrackerReminderSweeper s = w.sweeper();
      expect((await s.sweepIfDue(isArabic: false)).skipped, isFalse);
      w.now = DateTime(2026, 10, 12, 9, 25);
      expect((await s.sweepIfDue(isArabic: false)).skipped, isTrue);
      w.now = DateTime(2026, 10, 12, 9, 31);
      expect((await s.sweepIfDue(isArabic: false)).skipped, isFalse);
    });

    test('Notification_Log unreachable: nothing sent (fail-closed), never throws', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 9, 15), remote: _LogDownRemote());
      final TimeTrackerSweepReport r = await w.sweeper().sweep(isArabic: false);
      expect(r.failed, 1);
      expect(w.notifications.sent, isEmpty);
    });

    test('every read failing: a failed report, no throw', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 9, 15));
      w.remote.failWith = StateError('offline');
      final TimeTrackerSweepReport r = await w.sweeper().sweep(isArabic: false);
      expect(r.failed, 1);
      expect(r.sent, 0);
    });

    test('signed out: not run', () async {
      final _SweepWorld w = _SweepWorld(now: DateTime(2026, 10, 12, 9, 15), email: '');
      expect((await w.sweeper().sweep(isArabic: false)).skipped, isTrue);
    });
  });

  group('Phase-4 notifications: receiver, page, Request_Id, sender, text', () {
    test('submit → manager (approval details, count, request id); manager → HR approvers', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      final SentNotification toBoss = w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).single;
      expect(toBoss.receiver, 'boss@co.com');
      expect(toBoss.page, TimeTrackerNotificationPage.approvalDetails);
      expect(toBoss.requestId, r.id);
      expect(toBoss.sender, 'me@co.com');
      // QA KP-TT-011 (9/10/2026): singular for one request — "1 request"
      // (the Arabic "طلب واحد" is the variablesAr override, tested in
      // domain/qa_absence_wording_test.dart).
      _expectRendered(toBoss, en: 'You currently have 1 request pending', ar: 'لديك حالياً');
      expect(toBoss.variables[TemplateVariable.countedRequests], '1 request');

      final Phase4Kit boss = w.boss;
      final TimeTrackerRequest atHr =
          await boss.approvalService.approve(r, typeName: const TimeTrackerTypeName(en: 'Sick Leave'), isArabic: false);
      final SentNotification toHr = boss.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).single;
      expect(toHr.receiver, 'hr@co.com');
      expect(toHr.page, TimeTrackerNotificationPage.approvalDetails);
      expect(toHr.requestId, atHr.id);
      expect(toHr.sender, 'boss@co.com');
    });

    test('final approval / rejection / vacation used up → requester details, with the type in EN and AR', () async {
      final _World w = _World();
      const TimeTrackerTypeName names = TimeTrackerTypeName(en: 'Annual Vacation', ar: 'إجازة سنوية');
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.boss.approvalService.approve(r, typeName: names, isArabic: false);
      final Phase4Kit hr = w.hr;
      r = await hr.approvalService.approve(r, typeName: names, isArabic: false);
      final SentNotification ok = hr.notifications.of(TimeTrackerNotificationEvent.requestApprovedAttendanceLeave).single;
      expect(ok.receiver, 'me@co.com');
      expect(ok.page, TimeTrackerNotificationPage.requestDetails);
      expect(ok.requestId, r.id);
      expect(ok.sender, 'hr@co.com');
      _expectRendered(ok, en: 'Your Annual Vacation request has been reviewed and formally approved');
      final SentNotification used = hr.notifications.of(TimeTrackerNotificationEvent.vacationEntitlementExhausted).single;
      expect(used.receiver, 'me@co.com');
      expect(used.requestId, r.id);
      _expectRendered(used);

      final _World w2 = _World();
      final TimeTrackerRequest s = await w2.submit(_sick);
      final Phase4Kit boss = w2.boss;
      await boss.approvalService
          .reject(s, reason: 'Team is short', typeName: const TimeTrackerTypeName(en: 'Sick Leave', ar: 'إجازة مرضية'), isArabic: true);
      final SentNotification no = boss.notifications.of(TimeTrackerNotificationEvent.requestRejected).single;
      expect(no.receiver, 'me@co.com');
      expect(no.page, TimeTrackerNotificationPage.requestDetails);
      expect(no.requestId, s.id);
      _expectRendered(no, en: 'Your Sick Leave request has been reviewed and declined');
    });

    test('cancellation asked → approver; Canceled By HR → requester (request_canceled)', () async {
      final _World w = _World(manager: '');
      const TimeTrackerTypeName names = TimeTrackerTypeName(en: 'Annual Vacation');
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.hr.approvalService.approve(r, typeName: names, isArabic: false);
      w.me.notifications.sent.clear();
      r = await w.me.requestService.requestCancellation(r, reason: 'Trip canceled', isArabic: false);
      final SentNotification ask = w.me.notifications.sent.single;
      expect(ask.event, TimeTrackerNotificationEvent.pendingApprovalsManager);
      expect(ask.receiver, 'hr@co.com');
      expect(ask.page, TimeTrackerNotificationPage.approvalDetails);
      expect(ask.requestId, r.id);

      final _World w2 = _World(manager: '');
      TimeTrackerRequest q = await w2.submit(_annual);
      q = await w2.hr.approvalService.approve(q, typeName: names, isArabic: false);
      final Phase4Kit hr = w2.hr;
      q = await hr.approvalService.cancelAfterApproving(q, reason: 'Audit', typeName: names, isArabic: false);
      final SentNotification canceled = hr.notifications.of(TimeTrackerNotificationEvent.requestCanceled).single;
      expect(canceled.receiver, 'me@co.com');
      expect(canceled.page, TimeTrackerNotificationPage.requestDetails);
      expect(canceled.requestId, q.id);
      _expectRendered(canceled, en: 'Your Annual Vacation request has been canceled');
    });

    test('reminder → current approver; transaction approved / rejected → correction events', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      w.me.notifications.sent.clear();
      await w.me.requestService.sendReminder(r, isArabic: false);
      final SentNotification reminder = w.me.notifications.sent.single;
      expect(reminder.receiver, 'boss@co.com');
      expect(reminder.requestId, r.id);
      expect(reminder.page, TimeTrackerNotificationPage.approvalDetails);

      TransactionService txService(Phase4Kit k) => TransactionService(
            requests: k.requests,
            managers: k.managers,
            access: k.access,
            log: k.log,
            approvers: k.approvers,
            notifier: k.notifications,
            clock: () => _now,
          );
      const TimeTrackerTypeName tx = TimeTrackerTypeName(en: 'Transaction');
      TimeTrackerRequest t = await txService(w.me)
          .submit(checkIn: DateTime(2026, 10, 1, 9), checkOut: DateTime(2026, 10, 1, 17), description: 'Forgot to check in');
      expect(w.me.notifications.of(TimeTrackerNotificationEvent.pendingApprovalsManager).last.requestId, t.id);
      t = await w.boss.approvalService.approve(t, typeName: tx, isArabic: false);
      final Phase4Kit hr = w.hr;
      t = await hr.approvalService.approve(t, typeName: tx, isArabic: false);
      final SentNotification fixed = hr.notifications.of(TimeTrackerNotificationEvent.attendanceCorrectionApproved).single;
      expect(fixed.receiver, 'me@co.com');
      expect(fixed.requestId, t.id);
      expect(fixed.page, TimeTrackerNotificationPage.requestDetails);
      _expectRendered(fixed);

      TimeTrackerRequest t2 = await txService(w.me)
          .submit(checkIn: DateTime(2026, 10, 2, 9), checkOut: DateTime(2026, 10, 2, 17), description: 'Badge reader down');
      final Phase4Kit boss = w.boss;
      t2 = await boss.approvalService.reject(t2, reason: 'No proof', typeName: tx, isArabic: false);
      final SentNotification refused = boss.notifications.of(TimeTrackerNotificationEvent.attendanceCorrectionRejected).single;
      expect(refused.receiver, 'me@co.com');
      expect(refused.requestId, t2.id);
      _expectRendered(refused);
    });
  });

  group('Notification Control', () {
    test('every Time Tracker event sits under the Time Tracker tab (17 incl. missed_check_out)', () {
      expect(NotificationTab.forModule(AppModule.timeTracker), NotificationTab.tracking);
      expect(NotificationCatalog.eventsOf(AppModule.timeTracker), TimeTrackerNotificationEvent.values);
      expect(TimeTrackerNotificationEvent.values, hasLength(17));
      for (final TimeTrackerNotificationEvent e in TimeTrackerNotificationEvent.values) {
        expect(e.module, AppModule.timeTracker, reason: e.key);
        expect(NotificationCatalog.find(module: AppModule.timeTracker, key: e.key), e, reason: e.key);
        expect(e.templateId, 'time_tracker_${e.key}');
        // Owner rule: no tanween / diacritics in new Arabic copy.
        if (e == TimeTrackerNotificationEvent.missedCheckOut) {
          expect(RegExp('[ً-ْ]').hasMatch('${e.titleAr}${e.bodyAr}'), isFalse);
        }
      }
    });

    test('every send goes through the one dispatch point (AppNotificationSender.sendEvent honours the switch)', () {
      final String source =
          File('lib/features/time_tracker/data/services/time_tracker_notification_service.dart').readAsStringSync();
      expect(source, contains('AppNotificationSender.sendEvent('));
      final String sweeper =
          File('lib/features/time_tracker/data/services/time_tracker_reminder_sweeper.dart').readAsStringSync();
      expect(sweeper, contains('_notifier.send('));
      expect(sweeper, isNot(contains('services/app_notification_sender.dart')), reason: 'no direct sender');
    });
  });

  group('System Log', () {
    test('30 distinct lower-case actions', () {
      final List<String> all = TimeTrackerLogService.allActions;
      expect(all, hasLength(30));
      expect(all.toSet(), hasLength(30));
      for (final String a in all) {
        expect(a, a.toLowerCase());
        expect(a.trim(), isNotEmpty);
      }
    });

    test('every action is written somewhere in the module (Edit Vacation Balance: the phase-5 tab)', () {
      final String logFile = File('lib/features/time_tracker/data/services/time_tracker_log_service.dart').readAsStringSync();
      expect(logFile, contains('module: Modules.timeTracker'));
      final List<String> names = RegExp(r'static const String (action\w+)')
          .allMatches(logFile)
          .map((RegExpMatch m) => m.group(1)!)
          .toList();
      expect(names, hasLength(30));
      final String module = Directory('lib/features/time_tracker')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File f) => f.path.endsWith('.dart') && !f.path.endsWith('time_tracker_log_service.dart'))
          .map((File f) => f.readAsStringSync())
          .join('\n');
      const Set<String> pendingPhase5 = <String>{'actionEditVacationBalance'};
      for (final String n in names) {
        if (pendingPhase5.contains(n)) continue;
        expect(module, contains('TimeTrackerLogService.$n'), reason: '$n is never logged');
      }
    });

    test('System Logs: a log stored with module "timeTracker" resolves and passes the Time Tracker filter', () {
      final SystemLogsModel log = SystemLogsModel.fromMap(<String, dynamic>{
        SystemLogsModel.ACTION: TimeTrackerLogService.actionCheckIn,
        SystemLogsModel.MODULE: Modules.timeTracker.name,
        SystemLogsModel.USER_EMAIL: 'me@co.com',
        SystemLogsModel.FIRST_NAME: 'Moataz',
        SystemLogsModel.MIDDLE_NAME: '',
        SystemLogsModel.LAST_NAME: 'H',
        SystemLogsModel.COUNTRY: 'Egypt',
        SystemLogsModel.CITY: 'Cairo',
        SystemLogsModel.ROLE: 'Employee',
      });
      expect(log.module, Modules.timeTracker);
      expect(SystemLogsController.matchesModule(log, Modules.timeTracker.name), isTrue);
      expect(SystemLogsController.matchesModule(log, Modules.todo.name), isFalse);
      expect(SystemLogsController.matchesModule(log, null), isTrue);
      expect(SystemLogsController.matchesModule(const SystemLogsModel(), Modules.timeTracker.name), isFalse);
    });
  });
}
