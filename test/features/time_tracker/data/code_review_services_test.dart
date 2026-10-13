/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: code_review_services_test.dart
/// Purpose: The data-layer half of the 9/10/2026 code review fixes over the
///          in-memory remote: finding 2 (compare-and-set — a race never
///          double-deducts), 3 (status + balance in ONE transaction), 4
///          (refund the stored days even if the type changed), 9 (an
///          employee reads only their own requests), 10 (no balance = 0
///          days), and the minor ones (fresh type at submit, stale
///          transaction cancel, unknown status skipped, history rows carry
///          unknown fields, attendance date from the doc id, location guard,
///          new-role Time Tracker defaults OFF).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/controller/locations_cubit.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office');
const RequestType _annual =
    RequestType(id: 'annual', nameEn: 'Annual Vacation', isDeductedFromVacationBalance: true);
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave');
const TimeTrackerTypeName _name = TimeTrackerTypeName(en: 'Annual Vacation');

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1', role: 'Employee'),
  TimeTrackerEmployee(email: 'boss@co.com', nameEn: 'Boss B', departmentId: 'dep-9', role: 'Manager'),
  TimeTrackerEmployee(email: 'hr@co.com', nameEn: 'Hana R', departmentId: 'dep-5', role: 'HR'),
  TimeTrackerEmployee(email: 'hr2@co.com', nameEn: 'Hadi R', departmentId: 'dep-5', role: 'HR'),
];

final DateTime _now = DateTime(2026, 10, 5, 10);

Set<String> _without(List<String> keys) => allKeys()..removeAll(keys);

class _World {
  _World({String manager = '', bool balance = true}) {
    seedAssignment(remote, location: _hq);
    seedRequestTypes(remote, <RequestType>[_annual, _sick]);
    if (balance) {
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10));
    }
    me = Phase4Kit(
      remote: remote,
      access: accessWith(_without(<String>['Approvals_All_Departments', 'View_Approvals', 'HR_Dashboard']),
          email: 'me@co.com', departmentId: 'dep-1'),
      manager: manager,
      people: _people,
      roles: <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
        FakeRoleSource.approverRole('r-hr', name: 'HR'),
        FakeRoleSource.approverRole('r-mgr', name: 'Manager', all: false),
      ],
      clock: () => _now,
    );
  }

  final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
  late final Phase4Kit me;

  Phase4Kit hrAs(String email) => me.as(accessWith(allKeys(), email: email, departmentId: 'dep-5'), clock: () => _now);

  Future<TimeTrackerRequest> submit(RequestType type, {int days = 3}) async {
    final RequestFormSetup setup = await me.requestService.loadFormSetup();
    return me.requestService.submit(
      RequestDraft(type: type, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 12 + days - 1)),
      setup: setup,
      isArabic: false,
    );
  }

  Future<VacationBalance?> balance() => me.balances.fetchBalance(employeeEmail: 'me@co.com', year: _now.year);

  /// Somebody else writes the request (a comment, another approver…).
  void touch(String id) {
    final Map<String, Map<String, dynamic>> docs = remote.store[TimeTrackerFirestorePaths.requests]!;
    docs[id] = TimeTrackerHistoryCodec.append(old: docs[id], values: const <String, Object?>{}, now: _now);
  }
}

void main() {
  group('finding 2 — compare-and-set', () {
    test('a write that lost the race is refused; the balance is deducted exactly once', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_annual);
      final Phase4Kit hr = w.hrAs('hr@co.com');
      bool once = true;
      w.remote.beforeTransaction = () {
        if (once) {
          once = false;
          w.touch(r.id); // another approver wrote between our read and commit
        }
      };
      await expectLater(hr.approvalService.approve(r, typeName: _name, isArabic: false),
          throwsA(isA<TimeTrackerRecordChanged>()));
      expect((await w.balance())!.usedDays, 0, reason: 'nothing deducted by the refused write');
      w.remote.beforeTransaction = null;
      final TimeTrackerRequest done = await hr.approvalService.approve(r, typeName: _name, isArabic: false);
      expect(done.status, RequestStatus.approved);
      expect((await w.balance())!.usedDays, 3);
      // A second approval (double tap / second HR) finds nothing waiting.
      await expectLater(w.hrAs('hr2@co.com').approvalService.approve(r, typeName: _name, isArabic: false),
          throwsA(anything));
      expect((await w.balance())!.usedDays, 3, reason: 'never deducted twice');
    });
  });

  group('finding 3 + 10 — status and balance in one transaction; no balance = 0', () {
    test('submitting a deducting type without a balance is refused', () async {
      final _World w = _World(balance: false);
      await expectLater(w.submit(_annual), throwsA(isA<TimeTrackerNoVacationBalance>()));
      expect(await w.me.requests.watchRequests().first, isEmpty);
      // A non-deducting type is not affected.
      expect((await w.submit(_sick)).status, RequestStatus.pending);
    });

    test('an approval that cannot deduct leaves the request pending (nothing half-written)', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_annual);
      // The balance disappears before HR approves.
      w.remote.store[TimeTrackerFirestorePaths.vacationBalances]!.clear();
      final Phase4Kit hr = w.hrAs('hr@co.com');
      await expectLater(hr.approvalService.approve(r, typeName: _name, isArabic: false),
          throwsA(isA<TimeTrackerNoVacationBalance>()));
      final TimeTrackerRequest? stored = await w.me.requests.fetchRequest(id: r.id);
      expect(stored!.status, RequestStatus.pending, reason: 'before: approved, then the deduction failed');
    });
  });

  group('finding 4 — the refund is the stored deduction', () {
    test('a type flag changed after approval still refunds the days taken', () async {
      final _World w = _World();
      TimeTrackerRequest r = await w.submit(_annual);
      r = await w.hrAs('hr@co.com').approvalService.approve(r, typeName: _name, isArabic: false);
      expect(r.deductedVacationDays, 3);
      expect((await w.balance())!.usedDays, 3);
      // HR edits the type: no longer deducted.
      seedRequestTypes(w.remote, <RequestType>[
        const RequestType(id: 'annual', nameEn: 'Annual Vacation'),
        _sick,
      ]);
      r = await w.hrAs('hr@co.com').approvalService.cancelAfterApproving(r, reason: 'Audit', typeName: _name, isArabic: false);
      expect(r.status, RequestStatus.canceledByHr);
      expect((await w.balance())!.usedDays, 0, reason: 'before: no refund once the flag was off');
    });
  });

  group('finding 9 — an employee reads only their own requests', () {
    test('the form set-up / submit use the Requester_Email feed, never the company feed', () async {
      final _World w = _World();
      await w.submit(_sick);
      // 9/10/2026 (data model): the form also reads the employee's OWN
      // balances (one per year) by Employee_Email.
      final Iterable<String> requestQueries =
          w.remote.arrayQueries.where((String q) => q.startsWith('${TimeTrackerFirestorePaths.requests}.'));
      expect(requestQueries, everyElement(contains('${TimeTrackerRequestModel.fRequesterEmail}=me@co.com')));
      expect(requestQueries, isNotEmpty);
      expect(w.remote.arrayQueries.where((String q) => q.startsWith('${TimeTrackerFirestorePaths.vacationBalances}.')),
          everyElement('${TimeTrackerFirestorePaths.vacationBalances}.Employee_Email=me@co.com'));
      expect(w.remote.collectionReads.where((String p) => p == TimeTrackerFirestorePaths.requests), isEmpty);
    });
  });

  group('minor findings', () {
    test('submit re-reads the type: one deactivated meanwhile is refused', () async {
      final _World w = _World();
      final RequestFormSetup setup = await w.me.requestService.loadFormSetup();
      seedRequestTypes(w.remote, <RequestType>[
        const RequestType(id: 'sick', nameEn: 'Sick Leave', status: RequestTypeStatus.inactive),
      ]);
      await expectLater(
        w.me.requestService.submit(
          RequestDraft(type: _sick, startDate: DateTime(2026, 10, 12), endDate: DateTime(2026, 10, 12)),
          setup: setup,
          isArabic: false,
        ),
        throwsStateError,
      );
    });

    test('canceling a transaction decides on the STORED copy (stale snapshot refused)', () async {
      final _World w = _World(manager: 'boss@co.com');
      final TransactionService tx = TransactionService(
        requests: w.me.requests,
        managers: w.me.managers,
        access: w.me.access,
        log: w.me.log,
        approvers: w.me.approvers,
        clock: () => _now,
      );
      final TimeTrackerRequest pending = await tx.submit(attachments: const <RequestAttachment>[RequestAttachment(name: 'proof.pdf', url: 'https://x/proof.pdf')], 
        checkIn: DateTime(2026, 10, 1, 9),
        checkOut: DateTime(2026, 10, 1, 17),
        description: 'Forgot',
      );
      // The manager rejects it meanwhile; the employee's screen still shows "pending".
      await w.me.as(accessWith(allKeys(), email: 'boss@co.com', departmentId: 'dep-9'), clock: () => _now)
          .approvalService
          .reject(pending, reason: 'No', typeName: const TimeTrackerTypeName(en: 'Transaction'), isArabic: false);
      await expectLater(tx.cancel(pending), throwsA(anything));
      expect((await w.me.requests.fetchRequest(id: pending.id))!.status, RequestStatus.rejected);
    });

    test('a request with an unknown status is skipped, not read as pending', () async {
      final _World w = _World();
      final TimeTrackerRequest r = await w.submit(_sick);
      final Map<String, Map<String, dynamic>> docs = w.remote.store[TimeTrackerFirestorePaths.requests]!;
      docs[r.id] = TimeTrackerHistoryCodec.append(
        old: docs[r.id],
        values: const <String, Object?>{TimeTrackerRequestModel.fStatus: 'Escalated'},
        now: _now,
      );
      expect(TimeTrackerRequestModel.hasKnownStatus(docs[r.id]!), isFalse);
      expect(await w.me.requests.watchRequests().first, isEmpty);
      expect(await w.me.requests.fetchRequest(id: r.id), isNull);
    });

    test('a new history row keeps fields this app version does not know', () {
      final Map<String, dynamic> stored = TimeTrackerHistoryCodec.append(
        old: null,
        values: const <String, Object?>{'Status': 'a', 'Future_Field': 42},
        now: DateTime(2026, 10, 1),
      );
      final Map<String, dynamic> next = TimeTrackerHistoryCodec.append(
        old: stored,
        values: const <String, Object?>{'Status': 'b'},
        now: DateTime(2026, 10, 2),
      );
      expect(TimeTrackerHistoryCodec.historyOf(next, 'Future_Field'), <Object?>[42, 42]);
      expect(TimeTrackerHistoryCodec.rowCount(next), 2);
    });

    test('the attendance date comes from the doc id, not a Timestamp in the reader\'s zone', () {
      expect(AttendanceDayModel.dayFromId('me@co.com_2026-10-09'), DateTime(2026, 10, 9));
      expect(AttendanceDayModel.dayFromId('me_2026-01-31'), DateTime(2026, 1, 31));
      expect(AttendanceDayModel.dayFromId('bad-id'), isNull);
    });

    test('a location with assigned employees is never deleted or deactivated', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote, location: _hq);
      final LocationsCubit c = LocationsCubit(
        locations: LocationRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys())),
        assignments: LocationAssignmentRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys())),
        resolver: noHrResolver(remote),
        access: accessWith(allKeys()),
        log: FakeLog(),
      );
      await c.init();
      await Future<void>.delayed(Duration.zero);
      expect(c.assignedCount(_hq), 1);
      expect(await c.delete(_hq), isFalse);
      expect(await c.toggleStatus(_hq), isFalse);
      final WorkLocation stored = (await LocationRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys()))
              .watchLocations()
              .first)
          .single;
      expect(stored.status, LocationStatus.active);
      await c.close();
    });

    test('QA KP-TT-001: a new role starts with every Time Tracker switch OFF', () {
      final Map<String, bool> ceiling = <String, bool>{'Check_In_And_Out': true, 'Delete_Location': true};
      expect(RoleCubit.newRoleDefaults('time_tracker', ceiling).values, everyElement(isFalse));
      expect(RoleCubit.newRoleDefaults('time_tracker', ceiling).keys, ceiling.keys);
      // Other modules keep their behaviour.
      expect(RoleCubit.newRoleDefaults('crm', ceiling), ceiling);
    });
  });
}
