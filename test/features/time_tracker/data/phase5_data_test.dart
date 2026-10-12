/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: phase5_data_test.dart
/// Purpose: Data-layer tests of phase 5: the HR dashboard repository
///          (bounded attendance ranges per employee, placements from Time
///          Tracker or HR set-up, clean errors), the one-employee balance
///          stream, and the personal dashboard following it (incl. another
///          employee's dashboard, which never writes a roll-over).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_dashboard_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';

import '../_support/time_tracker_phase3_fakes.dart';
import '../_support/time_tracker_phase4_fakes.dart';
import '../_support/time_tracker_phase5_fakes.dart';
import '../_support/time_tracker_test_fakes.dart';

const WorkLocation _hq = WorkLocation(
  id: 'hq',
  nameEn: 'Main Office',
  workStartMinutes: 9 * 60,
  workEndMinutes: 17 * 60,
  workingDays: <int>[7, 1, 2, 3, 4],
  lateAfterMinutes: 10,
);

AttendanceDay _day(String email, DateTime d) =>
    AttendanceDay(id: '', employeeEmail: email, date: d, status: AttendanceStatus.present);

void main() {
  group('HrDashboardRepositoryImpl', () {
    test('attendance: one id range per employee, only the asked days', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedDays(remote, <AttendanceDay>[
        _day('me@co.com', DateTime(2026, 9, 30)),
        _day('me@co.com', DateTime(2026, 10, 1)),
        _day('me@co.com', DateTime(2026, 10, 9)),
        _day('amr@co.com', DateTime(2026, 10, 2)),
        _day('sara@co.com', DateTime(2026, 10, 2)),
      ]);
      final FakeDashboardRemote source = FakeDashboardRemote(remote);
      final HrDashboardRepositoryImpl repo = HrDashboardRepositoryImpl(remoteDataSource: source, resolver: noHrResolver(remote));
      final List<AttendanceDay> days = await repo.fetchAttendance(
        employeeEmails: <String>['ME@co.com', 'amr@co.com', ''],
        span: DateSpan(DateTime(2026, 10, 1), DateTime(2026, 10, 8)),
      );
      expect(days.map((AttendanceDay d) => '${d.employeeEmail} ${d.date.day}').toSet(),
          <String>{'me@co.com 1', 'amr@co.com 2'});
      expect(source.ranges, <String>[
        'amr@co.com_2026-10-01..amr@co.com_2026-10-08',
        'me@co.com_2026-10-01..me@co.com_2026-10-08',
      ]);
    });

    test('placements without HR: assignment + the location\'s schedule; inactive locations place nobody', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote, location: _hq, startDate: DateTime(2026, 10, 1));
      seedAssignment(remote,
          location: _hq.copyWith(id: 'old', status: LocationStatus.inactive), email: 'amr@co.com');
      final HrDashboardRepositoryImpl repo =
          HrDashboardRepositoryImpl(remoteDataSource: FakeDashboardRemote(remote), resolver: noHrResolver(remote));
      final Map<String, EmployeePlacement> p = await repo.fetchPlacements(employees: FakeDirectory.defaultPeople);
      expect(p.keys, <String>['me@co.com']);
      expect(p['me@co.com']!.locationId, 'hq');
      expect(p['me@co.com']!.schedule.lateAfterMinutes, 10);
      expect(p['me@co.com']!.schedule.workingDays, <int>[7, 1, 2, 3, 4]);
      expect(p['me@co.com']!.startDate, DateTime(2026, 10, 1));
    });

    test('placements with HR: Shift_Assignments/{employeeId} + Shifts, every day, no start', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      remote.store[TimeTrackerFirestorePaths.hrShiftAssignments] = <String, Map<String, dynamic>>{
        'emp-amr': <String, dynamic>{'Shift_Id': <String>['s1']},
        'emp-ghost': <String, dynamic>{'Shift_Id': <String>['s1']},
      };
      remote.store[TimeTrackerFirestorePaths.hrShifts] = <String, Map<String, dynamic>>{
        's1': <String, dynamic>{
          'Id': <String>['s1'],
          'Location_Ids': <String>['cairo'],
          'Start_Minutes': <int>[480],
          'End_Minutes': <int>[960],
        },
      };
      final HrDashboardRepositoryImpl repo =
          HrDashboardRepositoryImpl(remoteDataSource: FakeDashboardRemote(remote), resolver: hrResolver(remote));
      final Map<String, EmployeePlacement> p = await repo.fetchPlacements(employees: const <TimeTrackerEmployee>[
        TimeTrackerEmployee(email: 'amr@co.com', employeeId: 'emp-amr'),
        TimeTrackerEmployee(email: 'me@co.com', employeeId: 'emp-me'),
      ]);
      expect(p.keys, <String>['amr@co.com']);
      expect(p['amr@co.com']!.locationId, 'cairo');
      expect(p['amr@co.com']!.schedule.startMinutes, 480);
      expect(p['amr@co.com']!.schedule.workingDays, WorkSchedule.allDays);
      expect(p['amr@co.com']!.startDate, isNull);
    });

    test('a failing read becomes a clean Exception', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final HrDashboardRepositoryImpl repo =
          HrDashboardRepositoryImpl(remoteDataSource: _ThrowingSource(remote), resolver: noHrResolver(remote));
      expect(
        () => repo.fetchAttendance(employeeEmails: <String>['me@co.com'], span: DateSpan(DateTime(2026), DateTime(2026))),
        throwsA(isA<Exception>().having((Exception e) => '$e', 'message', contains('No company'))),
      );
    });
  });

  group('vacation balance stream', () {
    test('watchBalance: exactly that e-mail, null while none is stored, follows saves', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final VacationBalanceRepositoryImpl repo =
          VacationBalanceRepositoryImpl(remoteDataSource: remote, access: accessWith(allKeys()));
      seedBalance(remote, const VacationBalance(employeeEmail: 'a@co.com.eg', year: 2026, totalDays: 9));
      final List<VacationBalance?> seen = <VacationBalance?>[];
      final sub = repo.watchBalance(employeeEmail: 'A@co.com', year: 2026).listen(seen.add);
      await Future<void>.delayed(Duration.zero);
      expect(seen.last, isNull);
      await repo.saveBalance(balance: const VacationBalance(employeeEmail: 'a@co.com', year: 2026, totalDays: 12));
      await Future<void>.delayed(Duration.zero);
      expect(seen.last!.totalDays, 12);
      await sub.cancel();
    });

    test('the personal dashboard\'s Vacations Credit follows an HR edit live', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final access = accessWith(allKeys());
      seedBalance(remote, const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 21, usedDays: 1));
      final VacationBalanceRepositoryImpl balances = VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access);
      final PersonalDashboardCubit cubit = PersonalDashboardCubit(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        balances: balances,
        resolver: noHrResolver(remote),
        access: access,
        clock: () => DateTime(2026, 10, 9),
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.vacationDaysLeft, 20);
      await balances.saveBalance(
        balance: const VacationBalance(employeeEmail: 'me@co.com', year: 2026, totalDays: 30, usedDays: 1),
      );
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.vacationDaysLeft, 29);
      await cubit.close();
    });

    // 9/10/2026 (data model): balances are per year — last year's document
    // is not this year's balance (no roll-over).
    test('another employee\'s dashboard reads their days; last year\'s balance is not this year\'s', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final access = accessWith(allKeys());
      seedBalance(remote, const VacationBalance(employeeEmail: 'amr@co.com', year: 2025, totalDays: 15, usedDays: 7));
      seedDays(remote, <AttendanceDay>[_day('amr@co.com', DateTime(2026, 10, 1)), _day('me@co.com', DateTime(2026, 10, 1))]);
      final PersonalDashboardCubit cubit = PersonalDashboardCubit(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        balances: VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access),
        resolver: noHrResolver(remote),
        access: access,
        clock: () => DateTime(2026, 10, 9),
      );
      await cubit.init(employeeEmail: 'AMR@co.com');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.email, 'amr@co.com');
      expect(cubit.state.days.map((AttendanceDay d) => d.employeeEmail).toSet(), <String>{'amr@co.com'});
      expect(cubit.state.vacationDaysLeft, 0, reason: 'no 2026 document → no balance (no roll-over)');
      expect(remote.writes, isEmpty, reason: 'nothing is written for someone else');
      await cubit.close();
    });
  });
}

/// A data source that cannot resolve its path (no company signed in).
class _ThrowingSource extends FakeDashboardRemote {
  _ThrowingSource(super.remote);

  @override
  Future<List<TimeTrackerDocument>> fetchCollection(String relativePath) async =>
      throw StateError('No company is signed in.');

  @override
  Future<List<TimeTrackerDocument>> fetchIdRange(
    String relativePath, {
    required String firstId,
    required String lastId,
  }) async =>
      throw StateError('No company is signed in.');
}
