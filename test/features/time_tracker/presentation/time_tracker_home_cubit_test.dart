/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_cubit_test.dart
/// Purpose: Unit tests for the phase-1 `TimeTrackerHomeCubit` — the visible
///          tabs follow the role switches and the HR licence; a licence
///          failure is a failure state, not a crash. Also checks the
///          System Log action list.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_state.dart';

import '../_support/time_tracker_test_fakes.dart';

void main() {
  TimeTrackerHomeCubit cubit({
    required Set<String> on,
    bool hasHr = false,
    Object? failWith,
  }) =>
      TimeTrackerHomeCubit(
        access: accessWith(on),
        resolver: WorkSetupSourceResolver(
          companyModules: CompanyModulesService(
            dataSource: FakeCompanyModulesRemote(<String, Map<String, dynamic>>{
              'c': <String, dynamic>{
                'Modules': <String, dynamic>{'hr': hasHr},
              },
            })
              ..failWith = failWith,
            companyId: () => 'c',
          ),
          timeTrackerSource:
              TimeTrackerWorkSetupSource(remoteDataSource: FakeTimeTrackerRemote()),
          hrSource: HrWorkSetupSource(remoteDataSource: FakeHrRemote()),
        ),
      );

  test('starts loading-shaped, then lists every tab (no HR)', () async {
    final TimeTrackerHomeCubit c = cubit(on: allKeys());
    expect(c.state.isLoading, isTrue);
    await c.init();
    expect(c.state.status, TimeTrackerHomeStatus.success);
    expect(c.state.tabs, TimeTrackerTab.values);
    expect(c.state.canCheckIn, isTrue);
    expect(c.state.hasHrDashboard, isTrue);
    expect(c.state.companyHasHr, isFalse);
    await c.close();
  });

  test('HR company → Locations tab hidden', () async {
    final TimeTrackerHomeCubit c = cubit(on: allKeys(), hasHr: true);
    await c.init();
    expect(c.state.companyHasHr, isTrue);
    expect(c.state.tabs, isNot(contains(TimeTrackerTab.locations)));
    await c.close();
  });

  test('employee switches only → Dashboard / Attendance / Requests', () async {
    final TimeTrackerHomeCubit c = cubit(on: <String>{
      'Check_In_Permissions',
      'Check_In_And_Out',
      'Time_Tracker_Dashboard_Permissions',
      'Personal_Dashboard',
      'Attendance_Permissions',
      'View_Attendance',
      'Time_Tracker_Request_Permissions',
      'View_Time_Tracker_Requests',
    });
    await c.init();
    expect(c.state.tabs, <TimeTrackerTab>[
      TimeTrackerTab.dashboard,
      TimeTrackerTab.attendance,
      TimeTrackerTab.requests,
    ]);
    expect(c.state.hasHrDashboard, isFalse);
    await c.close();
  });

  test('a licence failure → failure state with a message', () async {
    final TimeTrackerHomeCubit c =
        cubit(on: allKeys(), failWith: StateError('No company is signed in'));
    await c.init();
    expect(c.state.status, TimeTrackerHomeStatus.failure);
    expect(c.state.errorMessage, contains('No company'));
    await c.close();
  });

  test('init after close does not throw (emit-after-close guard)', () async {
    final TimeTrackerHomeCubit c = cubit(on: allKeys());
    await c.close();
    await c.init();
  });

  // Updated 9/10/2026 - phase 4: + 4 request-cycle actions.
  test('System Log actions: the 30 agreed actions, all distinct', () {
    expect(TimeTrackerLogService.allActions, hasLength(30));
    expect(TimeTrackerLogService.allActions.toSet(), hasLength(30));
  });
}
