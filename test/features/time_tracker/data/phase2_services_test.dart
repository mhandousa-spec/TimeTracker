/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: phase2_services_test.dart
/// Purpose: Unit tests for the phase-2 data layer: `OrgChartManagerResolver`
///          (decision 18), the create-only attendance write + the
///          `AbsentDaySweeper` (20), the lazy vacation roll-over in the
///          repository (21) and `TransactionService` (19).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/employee_directory_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/org_chart_manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/absent_day_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/approval_step.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

import '../_support/time_tracker_test_fakes.dart';

/// Answers the Firestore fallback from a map (id → supervisor).
class _FakeDirectory implements EmployeeDirectoryRemoteDataSource {
  _FakeDirectory(this.byId);

  final Map<String, String> byId;
  int reads = 0;

  @override
  Future<String> fetchSupervisorEmail(String employeeId) async {
    reads++;
    return byId[employeeId] ?? '';
  }
}

void main() {
  group('OrgChartManagerResolver (decision 18)', () {
    test('in-memory directory first, lower-cased', () async {
      final _FakeDirectory remote = _FakeDirectory(<String, String>{});
      final OrgChartManagerResolver r = OrgChartManagerResolver(
        remoteDataSource: remote,
        lookup: (String email) => email == 'me@co.com' ? ' Boss@Co.com ' : null,
      );
      expect(await r.managerEmailOf(employeeEmail: 'Me@co.com', employeeId: 'e1'),
          'boss@co.com');
      expect(remote.reads, 0);
    });

    test('Firestore fallback by employee id', () async {
      final _FakeDirectory remote =
          _FakeDirectory(<String, String>{'e1': 'lead@co.com'});
      final OrgChartManagerResolver r = OrgChartManagerResolver(
        remoteDataSource: remote,
        lookup: (_) => null,
      );
      expect(await r.managerEmailOf(employeeEmail: 'me@co.com', employeeId: 'e1'),
          'lead@co.com');
      expect(remote.reads, 1);
    });

    test('no manager, or a self-reference → "" (step 1 skipped)', () async {
      final OrgChartManagerResolver r = OrgChartManagerResolver(
        remoteDataSource: _FakeDirectory(<String, String>{'e1': 'ME@co.com'}),
        lookup: (_) => '',
      );
      expect(await r.managerEmailOf(employeeEmail: 'me@co.com', employeeId: 'e1'), '');
      expect(await r.managerEmailOf(employeeEmail: 'x@co.com'), '');
    });
  });

  group('absent-day sweep (decision 20)', () {
    // Monday 12 Oct 2026, 10:00.
    DateTime clock() => DateTime(2026, 10, 12, 10);

    const WorkLocation hq = WorkLocation(
      id: 'hq',
      nameEn: 'HQ',
      workingDays: <int>[1, 2, 3, 4, 5],
    );

    test('creates the missing absent days once (idempotent)', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote, location: hq, startDate: DateTime(2026, 10, 7));
      final TimeTrackerAccess access = accessWith(allKeys());
      final AttendanceRepositoryImpl attendance =
          AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
      // Thursday 8 has a real record.
      await attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: DateTime(2026, 10, 8),
          status: AttendanceStatus.present,
        ),
      );
      final AbsentDaySweeper sweeper = AbsentDaySweeper(
        attendance: attendance,
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        resolver: noHrResolver(remote),
        access: access,
        clock: clock,
      );
      expect(await sweeper.sweep(), 2); // Wed 7 + Fri 9
      final Map<String, Map<String, dynamic>> docs =
          remote.store[TimeTrackerFirestorePaths.attendance]!;
      expect(docs.keys.toSet(), <String>{
        'me@co.com_2026-10-07',
        'me@co.com_2026-10-08',
        'me@co.com_2026-10-09',
      });
      expect(
        TimeTrackerHistoryCodec.lastOf(docs['me@co.com_2026-10-09']!, 'Attendance_Status'),
        'absent',
      );
      // The real record was not touched.
      expect(
        TimeTrackerHistoryCodec.lastOf(docs['me@co.com_2026-10-08']!, 'Attendance_Status'),
        'present',
      );
      expect(await sweeper.sweep(), 0);
    });

    test('approved leave is skipped; unassigned → nothing', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote, location: hq, startDate: DateTime(2026, 10, 7));
      final TimeTrackerAccess access = accessWith(allKeys());
      final RequestRepositoryImpl requests =
          RequestRepositoryImpl(remoteDataSource: remote, access: access);
      await requests.createRequest(
        request: TimeTrackerRequest(
          id: '',
          requesterEmail: 'me@co.com',
          requestTypeId: 'annual',
          startAt: DateTime(2026, 10, 7),
          endAt: DateTime(2026, 10, 9),
          isAllDay: true,
          status: RequestStatus.approved,
        ),
      );
      final AbsentDaySweeper sweeper = AbsentDaySweeper(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        requests: requests,
        resolver: noHrResolver(remote),
        access: access,
        clock: clock,
      );
      expect(await sweeper.sweep(), 0);

      final AbsentDaySweeper nobody = AbsentDaySweeper(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        requests: requests,
        resolver: noHrResolver(remote),
        access: accessWith(allKeys(), email: 'new@co.com'),
        clock: clock,
      );
      expect(await nobody.sweep(), 0);
    });
  });

  group('vacation balance per year (9/10/2026 data model — replaces decision 21)', () {
    // Owner 9 Oct: one document per employee per year; a new year is a new
    // document, nothing rolls over and a read never writes.
    test('a new year has no balance until HR sets one; reads write nothing', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final VacationBalanceRepositoryImpl repo = VacationBalanceRepositoryImpl(
        remoteDataSource: remote,
        access: accessWith(allKeys()),
      );
      await repo.saveBalance(
        balance: const VacationBalance(
          employeeEmail: 'me@co.com',
          year: 2025,
          totalDays: 21,
          usedDays: 10,
        ),
      );
      expect(await repo.fetchBalance(employeeEmail: 'me@co.com', year: 2026), isNull);
      final VacationBalance? old = await repo.fetchBalance(employeeEmail: 'me@co.com', year: 2025);
      expect(old!.remainingDays, 11);
      expect(remote.store[TimeTrackerFirestorePaths.vacationBalances]!.keys, <String>['me@co.com_2025']);
      expect(remote.writes, hasLength(1), reason: 'reads never write');
    });
  });

  group('TransactionService (decision 19)', () {
    TransactionService service(
      FakeTimeTrackerRemote remote, {
      Set<String>? on,
      String manager = 'boss@co.com',
      FakeLog? log,
    }) {
      final TimeTrackerAccess access = accessWith(on ?? allKeys());
      return TransactionService(
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        managers: FakeManagerResolver(manager),
        access: access,
        log: log ?? FakeLog(),
        clock: () => DateTime(2026, 10, 8, 12),
      );
    }

    test('submit routes direct manager → HR and logs', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final FakeLog log = FakeLog();
      final TimeTrackerRequest saved = await service(remote, log: log).submit(
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17),
        attachments: const <RequestAttachment>[RequestAttachment(name: 'proof.pdf', url: 'https://x/proof.pdf')],
        description: 'Forgot to check in',
      );
      expect(saved.id, isNotEmpty);
      expect(saved.isTransaction, isTrue);
      expect(saved.status, RequestStatus.pending);
      expect(saved.approvalSteps.first.approverEmail, 'boss@co.com');
      expect(saved.currentStep, ApprovalStepKind.manager);
      expect(log.actions, <String>[TimeTrackerLogService.actionCreateTransaction]);
      final Map<String, dynamic> doc =
          remote.store[TimeTrackerFirestorePaths.requests]!.values.single;
      expect(TimeTrackerHistoryCodec.lastOf(doc, 'Is_Transaction'), isTrue);
    });

    test('no manager → HR only', () async {
      final TimeTrackerRequest saved = await service(FakeTimeTrackerRemote(), manager: '')
          .submit(
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17),
        attachments: const <RequestAttachment>[RequestAttachment(name: 'proof.pdf', url: 'https://x/proof.pdf')],
        description: 'Forgot',
      );
      expect(saved.currentStep, ApprovalStepKind.hr);
    });

    test('Request_Transaction OFF → refused, nothing written', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      await expectLater(
        service(remote, on: <String>{'Attendance_Permissions', 'View_Attendance'}).submit(
          checkIn: DateTime(2026, 10, 7, 9),
          checkOut: DateTime(2026, 10, 7, 17),
          attachments: const <RequestAttachment>[RequestAttachment(name: 'proof.pdf', url: 'https://x/proof.pdf')],
          description: 'Forgot',
        ),
        throwsA(isA<TimeTrackerPermissionDenied>()),
      );
      expect(remote.writes, isEmpty);
    });

    test('cancel a pending transaction (Cancel_Transaction)', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final FakeLog log = FakeLog();
      final TransactionService s = service(remote, log: log);
      final TimeTrackerRequest saved = await s.submit(
        checkIn: DateTime(2026, 10, 7, 9),
        checkOut: DateTime(2026, 10, 7, 17),
        attachments: const <RequestAttachment>[RequestAttachment(name: 'proof.pdf', url: 'https://x/proof.pdf')],
        description: 'Forgot',
      );
      final TimeTrackerRequest canceled = await s.cancel(saved, reason: 'duplicate');
      expect(canceled.status, RequestStatus.canceled);
      expect(log.actions.last, TimeTrackerLogService.actionCancelTransaction);
      await expectLater(
        service(remote, on: <String>{'Attendance_Permissions', 'Request_Transaction'})
            .cancel(saved),
        throwsA(isA<TimeTrackerPermissionDenied>()),
      );
    });
  });
}
