/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase5_cubits_test.dart
/// Purpose: Cubit tests of phase 5: `HrDashboardCubit` (switch gate, scope,
///          bounded / cached attendance reads, filters without reads, stale
///          refresh, failure) and `VacationBalancesCubit` (gate, rows, Edit,
///          Import, permission refusals, System Log).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_type_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/vacation_balance_import_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_action_failure.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/controller/hr_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt13_vacation_balances/presentation/controller/vacation_balances_cubit.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_phase5_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const String _hrDash = 'HR_Dashboard';
const String _allDeps = 'HR_Dashboard_All_Departments';
const String _byEmployee = 'HR_Dashboard_Filter_By_Employee';

Set<String> _keys(Set<String> drop) => allKeys()..removeAll(drop);

const WorkSchedule _nineToFive = WorkSchedule(startMinutes: 540, endMinutes: 1020);

void main() {
  group('HrDashboardCubit', () {
    late FakeTimeTrackerRemote remote;
    late FakeHrDashboardRepository repo;
    DateTime now = DateTime(2026, 10, 9, 10, 30);

    HrDashboardCubit cubit(TimeTrackerAccess access) => HrDashboardCubit(
          dashboard: repo,
          requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
          types: RequestTypeRepositoryImpl(remoteDataSource: remote, access: access),
          directory: FakeDirectory(),
          resolver: noHrResolver(remote),
          access: access,
          clock: () => now,
        );

    setUp(() {
      now = DateTime(2026, 10, 9, 10, 30);
      remote = FakeTimeTrackerRemote();
      repo = FakeHrDashboardRepository(remote, placements: <String, EmployeePlacement>{
        for (final String e in <String>['me@co.com', 'amr@co.com', 'sara@co.com'])
          e: EmployeePlacement(email: e, locationId: e == 'sara@co.com' ? 'branch' : 'hq', schedule: _nineToFive,
              startDate: DateTime(2026, 10, 1)),
      });
      seedDays(remote, <AttendanceDay>[
        AttendanceDay(id: '', employeeEmail: 'sara@co.com', date: DateTime(2026, 10, 9), status: AttendanceStatus.late),
      ]);
      seedRequests(remote, <TimeTrackerRequest>[
        TimeTrackerRequest(
          id: 'r1',
          requesterEmail: 'sara@co.com',
          startAt: DateTime(2026, 10, 5),
          endAt: DateTime(2026, 10, 5),
          status: RequestStatus.approved,
        ),
      ]);
    });

    test('without HR_Dashboard nothing is read', () async {
      final HrDashboardCubit c = cubit(accessWith(_keys(<String>{_hrDash})));
      await c.init();
      expect(c.state.status, HrDashboardStatus.initial);
      expect(repo.attendanceCalls, isEmpty);
      await c.close();
    });

    test('without All Departments: own department only; reads only those employees', () async {
      final HrDashboardCubit c = cubit(accessWith(_keys(<String>{_allDeps})));
      await c.init();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.status, HrDashboardStatus.loaded);
      expect(c.state.allDepartments, isFalse);
      expect(c.state.stats.employeeCount, 2);
      expect(c.state.placements.keys.toSet(), <String>{'me@co.com', 'amr@co.com'});
      expect(c.state.stats.kpi.lateToday, 0, reason: 'Sara (dep-2) is out of scope');
      c.setDepartment('dep-2');
      expect(c.state.stats.employeeCount, 2, reason: 'the hidden Department filter is ignored');
      await c.close();
    });

    test('All Departments: everyone; filters narrow without reading again', () async {
      final HrDashboardCubit c = cubit(accessWith(allKeys()));
      await c.init();
      await Future<void>.delayed(Duration.zero);
      final int reads = repo.attendanceCalls.length;
      expect(reads, 2, reason: 'the range up to today + this month / yesterday');
      expect(c.state.stats.employeeCount, 3);
      expect(c.state.stats.kpi.lateToday, 1);
      expect(c.state.stats.approved, 1);
      c.setDepartment('dep-2');
      expect(c.state.stats.employeeCount, 1);
      c.setDepartment('');
      c.setLocation('hq');
      expect(c.state.stats.employeeCount, 2);
      c.setLocation('');
      c.setEmployees(<String>{'AMR@co.com'});
      expect(c.state.filters.employeeEmails, <String>{'amr@co.com'});
      expect(c.state.pickedEmployees.single.email, 'amr@co.com');
      expect(c.state.stats.employeeCount, 1);
      expect(repo.attendanceCalls.length, reads);
      await c.close();
    });

    test('picked employees only count with Filter by Employee', () async {
      final HrDashboardCubit c = cubit(accessWith(_keys(<String>{_byEmployee})));
      await c.init();
      c.setEmployees(<String>{'amr@co.com'});
      expect(c.state.stats.employeeCount, 3);
      await c.close();
    });

    test('ranges are read once and cached; a stale cache is read again', () async {
      final HrDashboardCubit c = cubit(accessWith(allKeys()));
      await c.init();
      expect(repo.attendanceCalls, <String>['2026-01-01_2026-10-09', '2026-10-01_2026-10-09']);
      await c.selectRange(DashboardRange.month);
      expect(repo.attendanceCalls, hasLength(2), reason: 'month up to today = the cached recent range');
      await c.selectRange(DashboardRange.week);
      expect(repo.attendanceCalls.last, '2026-10-03_2026-10-09');
      await c.selectRange(DashboardRange.year);
      expect(repo.attendanceCalls, hasLength(3));
      await c.applyCustom(DateTime(2026, 9, 10), DateTime(2026, 9, 1));
      expect(c.state.span.first, DateTime(2026, 9, 1));
      expect(repo.attendanceCalls.last, '2026-09-01_2026-09-10');
      now = now.add(const Duration(minutes: 3));
      final int before = repo.attendanceCalls.length;
      await c.refreshIfStale();
      expect(repo.attendanceCalls.length, before + 2);
      await c.close();
    });

    test('a failed read shows the failure; the toggle never reads', () async {
      repo.failWith = Exception('boom');
      final HrDashboardCubit c = cubit(accessWith(allKeys()));
      await c.init();
      expect(c.state.status, HrDashboardStatus.failure);
      c.setShowHr(true);
      expect(c.state.showHr, isTrue);
      await c.close();
    });
  });

  group('VacationBalancesCubit', () {
    late FakeTimeTrackerRemote remote;
    late FakeLog log;

    VacationBalancesCubit cubit(Set<String> on) => VacationBalancesCubit(
          balances: VacationBalanceRepositoryImpl(remoteDataSource: remote, access: accessWith(on)),
          directory: FakeDirectory(),
          access: accessWith(on),
          log: log,
          clock: () => DateTime(2026, 10, 9),
        );

    // 9/10/2026 (data model): one document per employee per year.
    Map<String, dynamic> stored(String email, [int year = 2026]) =>
        remote.store[TimeTrackerFirestorePaths.vacationBalances]!['${email}_$year']!;

    setUp(() {
      remote = FakeTimeTrackerRemote();
      log = FakeLog();
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 3));
      seedBalance(remote, const VacationBalance(employeeEmail: 'amr@co.com', year: 2025, totalDays: 15, usedDays: 9));
    });

    test('without View_Vacation_Balances nothing loads', () async {
      final VacationBalancesCubit c = cubit(allKeys()..remove('View_Vacation_Balances'));
      await c.init();
      expect(c.state.status, VacationBalancesStatus.initial);
      await c.close();
    });

    test('one row per employee; search and department narrow it', () async {
      final VacationBalancesCubit c = cubit(allKeys());
      await c.init();
      await Future<void>.delayed(Duration.zero);
      expect(c.state.status, VacationBalancesStatus.loaded);
      expect(c.state.rows, hasLength(3));
      expect(c.state.rows.firstWhere((r) => r.employee.email == 'amr@co.com').isStored, isFalse,
          reason: 'the 2025 document is not shown in 2026 (no roll-over)');
      expect(c.state.year, 2026);
      await c.setYear(2025);
      await Future<void>.delayed(Duration.zero);
      expect(c.state.rows.firstWhere((r) => r.employee.email == 'amr@co.com').balance.usedDays, 9);
      expect(c.state.rows.firstWhere((r) => r.employee.email == 'me@co.com').isStored, isFalse);
      await c.setYear(2026);
      await Future<void>.delayed(Duration.zero);
      c.setDepartment('dep-2');
      expect(c.state.visible.single.employee.email, 'sara@co.com');
      c.setDepartment('');
      c.search('moataz');
      expect(c.state.visible.single.employee.email, 'me@co.com');
      await c.close();
    });

    test('Edit keeps the used days of the year, writes the SELECTED year\'s document, and logs', () async {
      final VacationBalancesCubit c = cubit(allKeys());
      await c.init();
      expect(await c.editTotal('me@co.com', 25), isTrue);
      expect((stored('me@co.com')['Total_Days'] as List<dynamic>).last, 25);
      expect((stored('me@co.com')['Used_Days'] as List<dynamic>).last, 3);
      expect(stored('me@co.com').containsKey('Remaining_Days'), isFalse);
      expect(await c.editTotal('amr@co.com', 18), isTrue);
      expect((stored('amr@co.com')['Balance_Year'] as List<dynamic>).last, 2026);
      expect((stored('amr@co.com')['Used_Days'] as List<dynamic>).last, 0);
      expect((stored('amr@co.com', 2025)['Total_Days'] as List<dynamic>).last, 15, reason: '2025 untouched');
      expect(await c.editTotal('sara@co.com', 10), isTrue, reason: 'created');
      expect(log.actions, List<String>.filled(3, TimeTrackerLogService.actionEditVacationBalance));
      await c.close();
    });

    test('Edit without Edit_Vacation_Balance is refused (nothing written)', () async {
      final VacationBalancesCubit c = cubit(allKeys()..remove('Edit_Vacation_Balance'));
      await c.init();
      final int writes = remote.writes.length;
      expect(await c.editTotal('me@co.com', 25), isFalse);
      expect(c.state.failure, TimeTrackerActionFailure.denied);
      expect(remote.writes.length, writes);
      await c.close();
    });

    test('Import: preview, then writes only new / changed rows; refused without the switch', () async {
      final VacationBalancesCubit c = cubit(allKeys());
      await c.init();
      await Future<void>.delayed(Duration.zero);
      final VacationImportRead read = await c.readImport(() async => const <List<String>>[
            <String>['Email', 'Year', 'Total Days'],
            <String>['me@co.com', '2026', '21'],
            <String>['sara@co.com', '', '14'],
            <String>['nobody@co.com', '2026', '5'],
          ]);
      final VacationImportPlan plan = read.plan!;
      expect(plan.count(VacationImportAction.unchanged), 1);
      expect(plan.writable.single.email, 'sara@co.com');
      expect(await c.applyImport(plan), isTrue);
      expect((stored('sara@co.com')['Total_Days'] as List<dynamic>).last, 14);
      expect(log.actions, <String>[TimeTrackerLogService.actionEditVacationBalance]);
      expect((await c.readImport(() async => null)).plan, isNull);
      expect((await c.readImport(() async => throw const FormatException('bad'))).unreadable, isTrue);
      final VacationBalancesCubit noImport = cubit(allKeys()..remove('Import_Vacation_Balances'));
      await noImport.init();
      expect(await noImport.applyImport(plan), isFalse);
      expect(noImport.state.failure, TimeTrackerActionFailure.denied);
      await c.close();
      await noImport.close();
    });
  });
}
