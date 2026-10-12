/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: data_model_oct9_test.dart
/// Purpose: Tests of the owner-approved data model of 9 Oct 2026:
///          `Vacation_Balances/{email}_{year}` (per-year id, computed
///          remaining, no roll-over, deduction / refund atomic, and — owner
///          round 9 option b — a request spanning two years SPLIT per year,
///          a short year refused by name, old numeric values read) and the request
///          comments sub-collection `Requests/{id}/Comments/{commentId}`
///          (add / edit = revision / soft delete, permissions unchanged, the
///          request itself never rewritten, old embedded comments still read).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (data model)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_role_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_comment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/request_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_notification_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_failures.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_comment_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/request_form_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_actions_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/request_comments_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt9_requests/presentation/ui/pages/request_details_page.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';
import '../_support/time_tracker_widget_harness.dart';

const WorkLocation _hq = WorkLocation(id: 'hq', nameEn: 'Main Office', nameAr: 'المكتب الرئيسي');
const RequestType _annual =
    RequestType(id: 'annual', nameEn: 'Annual Vacation', nameAr: 'إجازة سنوية', isDeductedFromVacationBalance: true);
const RequestType _sick = RequestType(id: 'sick', nameEn: 'Sick Leave', nameAr: 'إجازة مرضية');
const TimeTrackerTypeName _annualName = TimeTrackerTypeName(en: 'Annual Vacation', ar: 'إجازة سنوية');

const List<TimeTrackerEmployee> _people = <TimeTrackerEmployee>[
  TimeTrackerEmployee(email: 'me@co.com', nameEn: 'Moataz H', departmentId: 'dep-1', role: 'Employee'),
  TimeTrackerEmployee(email: 'boss@co.com', nameEn: 'Boss B', departmentId: 'dep-9', role: 'Manager'),
  TimeTrackerEmployee(email: 'hr@co.com', nameEn: 'Hana R', departmentId: 'dep-5', role: 'HR'),
  TimeTrackerEmployee(email: 'lead@co.com', nameEn: 'Lead L', departmentId: 'dep-1', role: 'lead-role'),
];

final DateTime _now = DateTime(2026, 10, 5, 10);

Set<String> _without(List<String> keys) => allKeys()..removeAll(keys);

const String _balances = TimeTrackerFirestorePaths.vacationBalances;

class _World {
  _World({Set<String>? myKeys, List<VacationBalance> balances = const <VacationBalance>[]}) {
    seedAssignment(remote, location: _hq);
    seedRequestTypes(remote, <RequestType>[_annual, _sick]);
    for (final VacationBalance b in balances) {
      seedBalance(remote, b);
    }
    me = Phase4Kit(
      remote: remote,
      access: accessWith(myKeys ?? _without(<String>['Approvals_All_Departments']),
          email: 'me@co.com', departmentId: 'dep-1'),
      manager: 'boss@co.com',
      people: _people,
      roles: <(TimeTrackerRoleRecord, Map<String, dynamic>)>[
        FakeRoleSource.approverRole('r-hr', name: 'HR'),
        FakeRoleSource.approverRole('lead-role', all: false),
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
  Phase4Kit get lead => me.as(
      accessWith(_without(<String>['Approvals_All_Departments']), email: 'lead@co.com', departmentId: 'dep-1'),
      clock: () => _now);

  Future<TimeTrackerRequest> submit(RequestType type, DateTime first, DateTime last) async {
    final RequestFormSetup setup = await me.requestService.loadFormSetup();
    return me.requestService.submit(
      RequestDraft(type: type, startDate: first, endDate: last),
      setup: setup,
      isArabic: false,
    );
  }

  /// Manager, then HR (the final approval deducts).
  Future<TimeTrackerRequest> approveAll(TimeTrackerRequest r) async {
    final TimeTrackerRequest atHr = await boss.approvalService.approve(r, typeName: _annualName, isArabic: false);
    return hr.approvalService.approve(atHr, typeName: _annualName, isArabic: false);
  }

  Map<String, dynamic>? balanceDoc(String id) => remote.store[_balances]?[id];

  double? used(String id) {
    final Map<String, dynamic>? doc = balanceDoc(id);
    return doc == null ? null : TimeTrackerFieldCodec.decimal(TimeTrackerHistoryCodec.lastOf(doc, 'Used_Days'));
  }
}

/// A request document in the OLD shape (embedded `Comments` list).
Map<String, dynamic> _legacyRequestDoc(TimeTrackerRequest r) {
  final Map<String, Object?> row = TimeTrackerRequestModel.row(
    r,
    id: r.id,
    audit: TimeTrackerAudit.next(null, actor: 'me@co.com', now: DateTime(2026, 10)),
  );
  row['Comments'] = TimeTrackerFieldCodec.wrap(<Object?>[
    <String, Object?>{
      'Comment_Id': '1696000000000000_0',
      'Comment_Author_Email': 'me@co.com',
      'Comment_Text': 'Old embedded comment',
      'Comment_Date_Time': TimeTrackerFieldCodec.timestamp(DateTime(2026, 10, 1, 9)),
      'Is_Comment_Deleted': false,
    },
  ]);
  return TimeTrackerHistoryCodec.append(old: null, values: row, now: DateTime(2026, 10));
}

void main() {
  group('Vacation_Balances/{email}_{year}', () {
    test('per-year id: lower-case email + year; bad years refused; old {email} ids are not balances', () {
      expect(TimeTrackerFirestorePaths.vacationBalanceDocId(' Me@Co.com ', 2026), 'me@co.com_2026');
      expect(() => TimeTrackerFirestorePaths.vacationBalanceDocId('me@co.com', 26), throwsStateError);
      expect(() => TimeTrackerFirestorePaths.vacationBalanceDocId('', 2026), throwsStateError);
      expect(VacationBalanceModel.yearOfId('first_last@co.com_2027'), 2027);
      expect(VacationBalanceModel.yearOfId('me@co.com'), isNull);
      final Map<String, dynamic> doc = TimeTrackerHistoryCodec.append(
        old: null,
        values: VacationBalanceModel.row(
          const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21),
          id: 'me@co.com_2026',
          audit: TimeTrackerAudit.next(null, actor: 'hr@co.com', now: DateTime(2026)),
        ),
        now: DateTime(2026),
      );
      expect(VacationBalanceModel.isYearDocument('me@co.com_2026', doc), isTrue);
      expect(VacationBalanceModel.isYearDocument('me@co.com', doc), isFalse, reason: 'old layout');
      expect(doc.keys, isNot(contains('Remaining_Days')));
      expect(doc.keys, containsAll(<String>['Employee_Email', 'Balance_Year', 'Total_Days', 'Used_Days', 'timestamps']));
      expect(doc.keys, isNot(contains('Vacation_Balance_Id')), reason: 'owner rule: no self-id inside a document');
    });

    test('old documents that still carry a self-id read fine; the id comes from the snapshot', () {
      final Map<String, dynamic> balance = TimeTrackerHistoryCodec.append(
        old: null,
        values: <String, Object?>{
          'Vacation_Balance_Id': 'something-else',
          'Employee_Email': 'me@co.com',
          'Balance_Year': 2026,
          'Total_Days': 21,
          'Used_Days': 1,
        },
        now: DateTime(2026),
      );
      expect(VacationBalanceModel.isYearDocument('me@co.com_2026', balance), isTrue);
      expect(VacationBalanceModel.fromMap('me@co.com_2026', balance).remainingDays, 20);
      final Map<String, dynamic> comment = TimeTrackerHistoryCodec.append(
        old: null,
        values: <String, Object?>{'Comment_Id': 'old-id', 'Comment_Text': 'Hi', 'Author_Email': 'me@co.com'},
        now: DateTime(2026),
      );
      expect(RequestCommentModel.fromMap('doc-id', comment).id, 'doc-id');
      expect(RequestCommentModel.fromMap('', comment).id, 'old-id', reason: 'tolerated fallback');
      final Map<String, Object?> row = RequestCommentModel.row(
        RequestComment(id: 'c1', authorEmail: 'me@co.com', text: 'Hi', createdAt: DateTime(2026)),
        id: 'c1',
        audit: TimeTrackerAudit.next(null, actor: 'me@co.com', now: DateTime(2026)),
      );
      expect(row.containsKey('Comment_Id'), isFalse);
    });

    test('remaining is computed (Total − Used), never below zero', () {
      expect(const VacationBalance(employeeEmail: 'a', year: 2026, totalDays: 21, usedDays: 3.5).remainingDays, 17.5);
      expect(const VacationBalance(employeeEmail: 'a', year: 2026, totalDays: 5, usedDays: 7).remainingDays, 0);
    });

    test('lists per year skip other years and old {email} documents; reads never write', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final VacationBalanceRepositoryImpl repo =
          VacationBalanceRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys()));
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21));
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2025, totalDays: 18));
      seedBalance(remote, const VacationBalance(employeeEmail: 'amr@co.com', year: 2026, totalDays: 15));
      // An OLD-layout document (id = e-mail) — must not count as a balance.
      remote.store[_balances]!['old@co.com'] = TimeTrackerHistoryCodec.append(
        old: null,
        values: <String, Object?>{
          'Vacation_Balance_Id': 'old@co.com',
          'Employee_Email': 'old@co.com',
          'Balance_Year': 2026,
          'Total_Days': 30,
          'Used_Days': 0,
          'Remaining_Days': 30,
        },
        now: DateTime(2026),
      );
      final int writes = remote.writes.length;
      final List<VacationBalance> y2026 = await repo.watchBalancesOfYear(year: 2026).first;
      expect(y2026.map((VacationBalance b) => b.employeeEmail).toSet(), <String>{'me@co.com', 'amr@co.com'});
      expect((await repo.watchBalancesOfYear(year: 2025).first).single.totalDays, 18);
      expect((await repo.fetchBalancesOf(employeeEmail: 'ME@co.com')).map((VacationBalance b) => b.year).toSet(),
          <int>{2025, 2026});
      expect(await repo.fetchBalancesOf(employeeEmail: 'old@co.com'), isEmpty);
      expect(await repo.fetchBalance(employeeEmail: 'old@co.com', year: 2026), isNull);
      expect(await repo.fetchBalance(employeeEmail: 'me@co.com', year: 2027), isNull, reason: 'no roll-over');
      expect((await repo.watchBalance(employeeEmail: 'me@co.com', year: 2025).first)!.totalDays, 18);
      expect(remote.writes.length, writes, reason: 'reads never write');
    });

    test('setTotalDays keeps the used days stored at write time (a deduction landing meanwhile)', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final VacationBalanceRepositoryImpl repo =
          VacationBalanceRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys(), email: 'hr@co.com'));
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 1));
      // Between HR opening the dialog and saving, an approval deducts 3 days.
      remote.beforeTransaction = () {
        remote.beforeTransaction = null;
        seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 4));
      };
      final VacationBalance saved = await repo.setTotalDays(employeeEmail: 'Me@co.com', year: 2026, totalDays: 25);
      expect(<double>[saved.totalDays, saved.usedDays, saved.remainingDays], <double>[25, 4, 21]);
      final VacationBalance created = await repo.setTotalDays(employeeEmail: 'new@co.com', year: 2027, totalDays: 12);
      expect(<Object>[created.year, created.usedDays], <Object>[2027, 0.0]);
      expect(remote.store[_balances]!.keys, containsAll(<String>['me@co.com_2026', 'new@co.com_2027']));
      await expectLater(repo.setTotalDays(employeeEmail: 'me@co.com', year: 2026, totalDays: -1), throwsException);
    });
  });

  group('requests deduct / refund the balance of their START year (atomic)', () {
    test('a 2027 leave with only a 2026 balance is refused (no balance that year)', () async {
      final _World w = _World(balances: const <VacationBalance>[
        VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10),
      ]);
      await expectLater(
        w.submit(_annual, DateTime(2027, 1, 4), DateTime(2027, 1, 6)),
        throwsA(isA<TimeTrackerNoVacationBalance>()),
      );
      final RequestFormSetup setup = await w.me.requestService.loadFormSetup();
      expect(setup.balance!.year, 2026);
      expect(setup.balanceForDraft(RequestDraft(type: _annual, startDate: DateTime(2027, 1, 4))), isNull);
    });

    test('approval deducts from the 2027 document only; a cancel refunds it there', () async {
      final _World w = _World(balances: const <VacationBalance>[
        VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10, usedDays: 2),
        VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21),
      ]);
      final TimeTrackerRequest r = await w.submit(_annual, DateTime(2027, 1, 4), DateTime(2027, 1, 6));
      final TimeTrackerRequest done = await w.approveAll(r);
      expect(done.status, RequestStatus.approved);
      expect(done.deductedVacationDays, 3);
      expect(w.used('me@co.com_2027'), 3);
      expect(w.used('me@co.com_2026'), 2, reason: 'another year is untouched');
      expect(w.balanceDoc('me@co.com_2027')!.keys, isNot(contains('Remaining_Days')));
      final TimeTrackerRequest canceled =
          await w.hr.approvalService.cancelAfterApproving(done, reason: 'Audit', typeName: _annualName, isArabic: false);
      expect(canceled.status, RequestStatus.canceledByHr);
      expect(w.used('me@co.com_2027'), 0);
      expect(w.used('me@co.com_2026'), 2);
    });
  });

  // Owner round 9, option b: a deducting request MAY span two years; each
  // year's share is deducted from / refunded to that year's document.
  group('cross-year leave: SPLIT per year (owner round 9 option b)', () {
    TimeTrackerRequest leave(DateTime start, DateTime end, {bool allDay = true}) => TimeTrackerRequest(
          id: 'x',
          requesterEmail: 'me@co.com',
          startAt: start,
          endAt: end,
          isAllDay: allDay,
          totalMinutes: end.difference(start).inMinutes,
        );

    test('daysByYear: working days per year; partial time split at midnight of 1 January', () {
      expect(VacationBalanceRules.daysByYear(leave(DateTime(2026, 12, 29), DateTime(2027, 1, 3, 23, 59))),
          <int, double>{2026: 3, 2027: 3});
      final WorkSchedule sunThu = const WorkSchedule(startMinutes: 9 * 60, endMinutes: 17 * 60)
          .withWorkingDays(WorkSchedule.sundayToThursday, known: true);
      // Tue 29 Dec – Sun 3 Jan: 29, 30, 31 (Tue–Thu) + 3 Jan (Sun).
      expect(VacationBalanceRules.daysByYear(leave(DateTime(2026, 12, 29), DateTime(2027, 1, 3, 23, 59)), schedule: sunThu),
          <int, double>{2026: 3, 2027: 1});
      final Map<int, double> partial = VacationBalanceRules.daysByYear(
          leave(DateTime(2026, 12, 31, 22), DateTime(2027, 1, 1, 2), allDay: false),
          schedule: sunThu);
      expect(partial[2026], closeTo(0.25, 1e-9), reason: '2 h of an 8 h day');
      expect(partial[2027], closeTo(0.25, 1e-9));
      expect(VacationBalanceRules.daysByYear(leave(DateTime(2026, 12, 31, 22), DateTime(2027, 1, 1), allDay: false)).keys,
          <int>[2026], reason: 'an end at midnight belongs to the day before');
    });

    test('the form names the first year that cannot cover its share (missing year = 0 days)', () {
      final RequestDraft draft = RequestDraft(type: _annual, startDate: DateTime(2026, 12, 29), endDate: DateTime(2027, 1, 3));
      const VacationBalance y2026 = VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10);
      const VacationBalance y2027 = VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21, usedDays: 19);
      expect(RequestFormRules.daysByYear(draft), <int, double>{2026: 3, 2027: 3});
      final Set<RequestFormError> short =
          RequestFormRules.validate(draft, balance: y2026, balances: const <VacationBalance>[y2026, y2027]);
      expect(short, contains(RequestFormError.exceedsBalance));
      final VacationShortfall s2027 =
          RequestFormRules.shortfall(draft, balance: y2026, balances: const <VacationBalance>[y2026, y2027])!;
      expect(<Object>[s2027.year, s2027.daysLeft, s2027.isMissing], <Object>[2027, 2.0, false]);
      final VacationShortfall missing =
          RequestFormRules.shortfall(draft, balance: y2026, balances: const <VacationBalance>[y2026])!;
      expect(<Object>[missing.year, missing.daysLeft, missing.isMissing], <Object>[2027, 0.0, true]);
      expect(RequestFormRules.validate(draft, balance: y2026, balances: const <VacationBalance>[y2026]),
          contains(RequestFormError.noBalance));
      const VacationBalance enough = VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21);
      expect(RequestFormRules.validate(draft, balance: y2026, balances: const <VacationBalance>[y2026, enough]),
          isNot(anyOf(contains(RequestFormError.exceedsBalance), contains(RequestFormError.noBalance))));
      expect(
        RequestFormRules.validate(
            RequestDraft(type: _sick, startDate: DateTime(2026, 12, 29), endDate: DateTime(2027, 1, 3))),
        isEmpty,
        reason: 'a type that does not deduct is never checked',
      );
    });

    test('approval splits 3 + 3 into both years in ONE write; a cancel refunds each share', () async {
      final _World w = _World(balances: const <VacationBalance>[
        VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10),
        VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21),
      ]);
      final TimeTrackerRequest r = await w.submit(_annual, DateTime(2026, 12, 29), DateTime(2027, 1, 3));
      final TimeTrackerRequest done = await w.approveAll(r);
      expect(done.status, RequestStatus.approved);
      expect(done.deductedDaysByYear, <int, double>{2026: 3, 2027: 3});
      expect(done.deductedVacationDays, 6);
      final Map<String, dynamic> stored = w.remote.store[TimeTrackerFirestorePaths.requests]![r.id]!;
      expect(TimeTrackerHistoryCodec.lastOf(stored, 'Deducted_Vacation_Days'), <String, Object?>{'2026': 3.0, '2027': 3.0});
      expect(<double?>[w.used('me@co.com_2026'), w.used('me@co.com_2027')], <double>[3, 3]);
      await w.hr.approvalService.cancelAfterApproving(done, reason: 'Audit', typeName: _annualName, isArabic: false);
      expect(<double?>[w.used('me@co.com_2026'), w.used('me@co.com_2027')], <double>[0, 0]);
    });

    test('submit names the short year early; the final approval is refused when a year runs short', () async {
      final _World w = _World(balances: const <VacationBalance>[
        VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10),
        VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21, usedDays: 19),
      ]);
      final int writes = w.remote.writes.length;
      final Object? early = await w
          .submit(_annual, DateTime(2026, 12, 29), DateTime(2027, 1, 3))
          .then<Object?>((_) => null, onError: (Object e) => e);
      expect(early, isA<TimeTrackerYearBalanceShort>());
      final TimeTrackerYearBalanceShort shortEarly = early! as TimeTrackerYearBalanceShort;
      expect(<Object>[shortEarly.year, shortEarly.daysLeft], <Object>[2027, 2.0]);
      expect(w.remote.writes.length, writes, reason: 'nothing written');

      // Enough at submit, then 2027 shrinks before the final approval.
      seedBalance(w.remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21));
      final TimeTrackerRequest r = await w.submit(_annual, DateTime(2026, 12, 29), DateTime(2027, 1, 3));
      final TimeTrackerRequest atHr = await w.boss.approvalService.approve(r, typeName: _annualName, isArabic: false);
      seedBalance(w.remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2027, totalDays: 21, usedDays: 19));
      final Object? late = await w.hr.approvalService
          .approve(atHr, typeName: _annualName, isArabic: false)
          .then<Object?>((_) => null, onError: (Object e) => e);
      expect(late, isA<TimeTrackerYearBalanceShort>());
      expect((late! as TimeTrackerYearBalanceShort).year, 2027);
      expect((await w.me.requests.fetchRequest(id: r.id))!.status, RequestStatus.pending, reason: 'nothing written');
      expect(<double?>[w.used('me@co.com_2026'), w.used('me@co.com_2027')], <double>[0, 19]);
      final RequestActionsState state = RequestActionsState.failedWith(late);
      expect(<Object?>[state.failure, state.balanceYear, state.balanceDaysLeft],
          <Object?>[TimeTrackerActionFailure.balanceShort, 2027, 2.0]);
      final RequestActionsState missing = RequestActionsState.failedWith(const TimeTrackerNoVacationBalance(year: 2027));
      expect(<Object?>[missing.failure, missing.balanceYear, missing.balanceDaysLeft],
          <Object?>[TimeTrackerActionFailure.noBalance, 2027, 0.0]);
    });

    test('an OLD numeric Deducted_Vacation_Days reads as {start year: n} and is refunded there', () async {
      expect(TimeTrackerRequestModel.deductedFrom(3, startYear: 2026), <int, double>{2026: 3});
      expect(TimeTrackerRequestModel.deductedFrom(<String, Object?>{'2027': 1, '2026': 2.5}, startYear: 2026),
          <int, double>{2026: 2.5, 2027: 1});
      expect(TimeTrackerRequestModel.deductedFrom(null, startYear: 2026), isNull);
      expect(TimeTrackerRequestModel.deductedTo(const <int, double>{2027: 1, 2026: 2}),
          <String, Object?>{'2026': 2.0, '2027': 1.0});
      final _World w = _World(balances: const <VacationBalance>[
        VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 10),
      ]);
      final TimeTrackerRequest r = await w.submit(_annual, DateTime(2026, 11, 2), DateTime(2026, 11, 4));
      await w.approveAll(r);
      expect(w.used('me@co.com_2026'), 3);
      // Rewrite the stored value the way an older build wrote it: a number.
      final Map<String, dynamic> doc = w.remote.store[TimeTrackerFirestorePaths.requests]![r.id]!;
      final List<Object?> history = TimeTrackerHistoryCodec.historyOf(doc, 'Deducted_Vacation_Days');
      doc['Deducted_Vacation_Days'] = <Object?>[...history.sublist(0, history.length - 1), 3];
      final TimeTrackerRequest old = (await w.me.requests.fetchRequest(id: r.id))!;
      expect(old.deductedDaysByYear, <int, double>{2026: 3});
      await w.hr.approvalService.cancelAfterApproving(old, reason: 'Audit', typeName: _annualName, isArabic: false);
      expect(w.used('me@co.com_2026'), 0);
    });
  });

  group('Requests/{id}/Comments sub-collection', () {
    Future<(_World, TimeTrackerRequest)> world({Set<String>? myKeys}) async {
      final _World w = _World(myKeys: myKeys);
      final TimeTrackerRequest r = await w.submit(_sick, DateTime(2026, 10, 12), DateTime(2026, 10, 12));
      return (w, r);
    }

    test('add / edit (a revision) / soft delete: one document per comment, the request is not rewritten', () async {
      final (_World w, TimeTrackerRequest r) = await world();
      final String path = TimeTrackerFirestorePaths.requestComments(r.id);
      expect(path, '${TimeTrackerFirestorePaths.requests}/${r.id}/Comments');
      final int requestRows = TimeTrackerHistoryCodec.rowCount(w.remote.store[TimeTrackerFirestorePaths.requests]![r.id]!);
      final RequestComment a = await w.me.requestService.addComment(r, text: ' Doctor note follows ', asApprover: false);
      final RequestComment b = await w.boss.requestService.addComment(r, text: 'OK', asApprover: true);
      expect(w.remote.store[path]!.keys, <String>{a.id, b.id});
      final Map<String, dynamic> doc = w.remote.store[path]![a.id]!;
      expect(doc.containsKey('Comment_Id'), isFalse, reason: 'the document id IS the comment id');
      expect(doc['Comment_Text'], <Object?>['Doctor note follows']);
      expect(doc['Author_Email'], <Object?>['me@co.com']);
      expect(doc['Is_Deleted'], <Object?>[false]);
      expect(doc['Attachments'], <Object?>[<String, Object?>{'Values': <Object?>[]}]);
      expect(doc['Created_At'], hasLength(1));
      expect(doc['timestamps'], hasLength(1));

      final RequestComment edited = await w.me.requestService.editComment(r, commentId: a.id, text: 'Note sent', asApprover: false);
      expect(edited.text, 'Note sent');
      expect(w.remote.store[path]![a.id]!['Comment_Text'], <Object?>['Doctor note follows', 'Note sent']);
      expect(RequestCommentModel.editedAtOf(w.remote.store[path]![a.id]!), isNotNull);

      final RequestComment gone = await w.me.requestService.deleteComment(r, commentId: a.id, asApprover: false);
      expect(gone.isDeleted, isTrue);
      expect(w.remote.store[path]![a.id]!['Is_Deleted'], <Object?>[false, false, true]);
      final List<RequestComment> stored = await w.me.requestService.watchComments(r.id).first;
      expect(stored, hasLength(2), reason: 'soft delete keeps the document');
      expect(RequestCommentRules.thread(stored).single.text, 'OK');

      expect(TimeTrackerHistoryCodec.rowCount(w.remote.store[TimeTrackerFirestorePaths.requests]![r.id]!), requestRows,
          reason: 'a comment never rewrites the request');
      expect(w.remote.store[TimeTrackerFirestorePaths.requests]![r.id]!.containsKey('Comments'), isFalse);
    });

    test('permissions unchanged: own comments only; involved approver; switches gate', () async {
      final (_World w, TimeTrackerRequest r) = await world();
      final String path = TimeTrackerFirestorePaths.requestComments(r.id);
      final RequestComment boss = await w.boss.requestService.addComment(r, text: 'Why?', asApprover: true);
      final int writes = w.remote.writes.length;
      // Someone else's comment: refused inside the write, nothing stored.
      await expectLater(w.me.requestService.editComment(r, commentId: boss.id, text: 'x', asApprover: false),
          throwsException);
      await expectLater(w.me.requestService.deleteComment(r, commentId: boss.id, asApprover: false), throwsException);
      expect(w.remote.writes.length, writes);
      expect(w.remote.store[path]![boss.id]!['Comment_Text'], <Object?>['Why?']);
      // The boss is not the requester; HR / a lead are not involved yet.
      await expectLater(w.boss.requestService.addComment(r, text: 'x', asApprover: false),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      await expectLater(w.hr.requestService.addComment(r, text: 'x', asApprover: true),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      await expectLater(w.lead.requestService.addComment(r, text: 'x', asApprover: true),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      // Without Comment_On_Requests the requester cannot write either.
      final (_World w2, TimeTrackerRequest r2) = await world(
          myKeys: _without(<String>['Approvals_All_Departments', 'Comment_On_Requests']));
      await expectLater(w2.me.requestService.addComment(r2, text: 'x', asApprover: false),
          throwsA(isA<TimeTrackerPermissionDenied>()));
      await expectLater(w.me.requestService.addComment(r, text: '   ', asApprover: false), throwsStateError);
    });

    test('an OLD request with an embedded Comments list still reads (read-only legacy thread)', () async {
      final _World w = _World();
      final TimeTrackerRequest base = TimeTrackerRequest(
        id: 'old-1',
        requesterEmail: 'me@co.com',
        requesterDepartmentId: 'dep-1',
        requestTypeId: 'sick',
        startAt: DateTime(2026, 10, 20),
        endAt: DateTime(2026, 10, 20, 23, 59),
        isAllDay: true,
        approvalSteps: const <RequestApprovalStep>[
          RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com'),
        ],
        currentStep: ApprovalStepKind.manager,
      );
      w.remote.store.putIfAbsent(TimeTrackerFirestorePaths.requests, () => <String, Map<String, dynamic>>{})['old-1'] =
          _legacyRequestDoc(base);
      final TimeTrackerRequest read = (await w.me.requests.fetchRequest(id: 'old-1'))!;
      expect(read.legacyComments.single.text, 'Old embedded comment');
      expect(read.legacyComments.single.isLegacy, isTrue);
      final List<RequestComment> thread = RequestCommentRules.thread(
        await w.me.requestService.watchComments('old-1').first,
        legacy: read.legacyComments,
      );
      expect(thread.single.text, 'Old embedded comment');
      expect(RequestCommentRules.canModify(thread.single, 'me@co.com'), isFalse);
      // A new comment goes to the sub-collection; the old field is kept
      // untouched (carried) until the migration removes it.
      await w.me.requestService.addComment(read, text: 'New one', asApprover: false);
      await w.me.requestService.sendReminder(read, isArabic: false);
      final Map<String, dynamic> stored = w.remote.store[TimeTrackerFirestorePaths.requests]!['old-1']!;
      expect(TimeTrackerHistoryCodec.lastOf(stored, 'Comments'), isNotNull);
      expect(TimeTrackerHistoryCodec.historyOf(stored, 'Comments'), hasLength(2));
    });

    test('RequestCommentsCubit streams the thread live', () async {
      final (_World w, TimeTrackerRequest r) = await world();
      final RequestCommentsCubit cubit = RequestCommentsCubit(source: w.me.requestService.watchComments);
      await cubit.watch(r.id);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, RequestCommentsStatus.loaded);
      expect(cubit.state.comments, isEmpty);
      await w.me.requestService.addComment(r, text: 'Hello', asApprover: false);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.comments.single.text, 'Hello');
      await cubit.close();
    });
  });

  group('comments section (widget)', () {
    setUpAll(initTimeTrackerTestStorage);

    testWidgets('writing a comment shows it from the sub-collection; legacy comments show read-only',
        (WidgetTester tester) async {
      final TimeTrackerHarness h = TimeTrackerHarness();
      seedAssignment(h.remote, location: _hq);
      seedRequestTypes(h.remote, <RequestType>[_sick]);
      final TimeTrackerRequest base = TimeTrackerRequest(
        id: 'p1',
        requesterEmail: 'me@co.com',
        requesterDepartmentId: 'dep-1',
        requestTypeId: 'sick',
        startAt: DateTime(2026, 10, 20),
        endAt: DateTime(2026, 10, 20, 23, 59),
        isAllDay: true,
        approvalSteps: const <RequestApprovalStep>[
          RequestApprovalStep(step: ApprovalStepKind.manager, approverEmail: 'boss@co.com'),
        ],
        currentStep: ApprovalStepKind.manager,
      );
      h.remote.store.putIfAbsent(TimeTrackerFirestorePaths.requests, () => <String, Map<String, dynamic>>{})['p1'] =
          _legacyRequestDoc(base);
      await h.pump(tester, const RequestDetailsPage(requestId: 'p1'));
      // The legacy comment is there (the section opens on its own).
      expect(find.text('Old embedded comment'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('requestCommentEdit_1696000000000000_0')), findsNothing);
      await tester.enterText(find.byKey(const ValueKey<String>('requestCommentInput')).first, 'Fresh comment');
      await tester.tap(find.byKey(const ValueKey<String>('requestCommentSend')));
      await h.settle(tester);
      expect(find.text('Fresh comment'), findsOneWidget);
      final Map<String, Map<String, dynamic>> docs =
          h.remote.store[TimeTrackerFirestorePaths.requestComments('p1')]!;
      expect(docs, hasLength(1));
      final String id = docs.keys.single;
      expect(find.byKey(ValueKey<String>('requestCommentEdit_$id')), findsOneWidget);
      await h.dispose(tester);
    });
  });
}
