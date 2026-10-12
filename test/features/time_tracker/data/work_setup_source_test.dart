/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: work_setup_source_test.dart
/// Purpose: Unit tests for the HR switch — `CompanyModulesParser` /
///          `CompanyModulesService` (licence → hasHrModule, cached per
///          company), `WorkSetupSourceResolver` (HR vs Time Tracker), and the
///          two `WorkSetupSource` implementations.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/models/company_modules_parser.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/hr_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

import '../_support/time_tracker_test_fakes.dart';

void main() {
  group('CompanyModulesParser', () {
    test('reads Demo_Details.Modules with bool / list / {Values} entries', () {
      final Map<String, dynamic> doc = <String, dynamic>{
        'Demo_Details': <String, dynamic>{
          'Modules': <String, dynamic>{
            'HR': <String, dynamic>{'Values': <Object?>[false, true]},
            'todo': true,
            'crm': <Object?>[true, false],
          },
        },
      };
      expect(CompanyModulesParser.licensedModules(doc), <String, bool>{
        'hr': true,
        'todo': true,
        'crm': false,
      });
      expect(CompanyModulesParser.hasHr(doc), isTrue);
    });

    test('root-level Modules works; missing licence = nothing licensed', () {
      expect(
        CompanyModulesParser.hasHr(<String, dynamic>{
          'Modules': <String, dynamic>{'hr': false},
        }),
        isFalse,
      );
      expect(CompanyModulesParser.licensedModules(null), isEmpty);
      expect(CompanyModulesParser.hasHr(<String, dynamic>{}), isFalse);
    });
  });

  group('CompanyModulesService', () {
    test('caches per company and re-reads on a company switch', () async {
      String company = 'c1';
      final FakeCompanyModulesRemote remote = FakeCompanyModulesRemote(
        <String, Map<String, dynamic>>{
          'c1': <String, dynamic>{
            'Modules': <String, dynamic>{'hr': true},
          },
          'c2': <String, dynamic>{
            'Modules': <String, dynamic>{'hr': false},
          },
        },
      );
      final CompanyModulesService service =
          CompanyModulesService(dataSource: remote, companyId: () => company);
      expect(await service.hasHrModule(), isTrue);
      expect(await service.hasHrModule(), isTrue);
      expect(remote.reads, 1);
      company = 'c2';
      expect(await service.hasHrModule(), isFalse);
      expect(remote.reads, 2);
    });

    test('a failed read is not cached', () async {
      final FakeCompanyModulesRemote remote = FakeCompanyModulesRemote(
        <String, Map<String, dynamic>>{},
      )..failWith = StateError('offline');
      final CompanyModulesService service =
          CompanyModulesService(dataSource: remote, companyId: () => 'c1');
      await expectLater(service.hasHrModule(), throwsStateError);
      remote.failWith = null;
      expect(await service.hasHrModule(), isFalse);
    });
  });

  group('WorkSetupSourceResolver', () {
    WorkSetupSourceResolver resolver(bool hasHr, {Object? failWith}) =>
        WorkSetupSourceResolver(
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
        );

    test('HR licensed → HR source; otherwise Time Tracker source', () async {
      expect((await resolver(true).resolve()).owner, WorkSetupOwner.hr);
      expect((await resolver(false).resolve()).owner, WorkSetupOwner.timeTracker);
    });

    test('a licence failure surfaces as a clean Exception', () async {
      await expectLater(
        resolver(false, failWith: StateError('No company')).hasHrModule(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('TimeTrackerWorkSetupSource (no HR)', () {
    Map<String, dynamic> doc(Map<String, Object?> values) =>
        TimeTrackerHistoryCodec.append(old: null, values: values, now: DateTime(2026));

    test('assignment + location → schedule from the location, rules from the '
        'assignment', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      remote.store[TimeTrackerFirestorePaths.locations] = <String, Map<String, dynamic>>{
        'hq': doc(<String, Object?>{
          'Name_En': 'HQ',
          'Work_Start_Time': 540,
          'Work_End_Time': 1020,
          'Working_Days': <String, Object?>{'Values': <Object?>[7, 1, 2, 3, 4]},
          'Location_Status': 'active',
        }),
        'old': doc(<String, Object?>{'Name_En': 'Old', 'Location_Status': 'deleted'}),
      };
      remote.store[TimeTrackerFirestorePaths.locationAssignments] =
          <String, Map<String, dynamic>>{
        'me@co.com': doc(<String, Object?>{
          'Employee_Email': 'me@co.com',
          'Location_Id': 'hq',
          'Is_Pause_Allowed': true,
        }),
      };
      final WorkSetupSource source = TimeTrackerWorkSetupSource(remoteDataSource: remote);

      final List<WorkLocation> locations = await source.loadLocations();
      expect(locations.map((WorkLocation l) => l.id), <String>['hq']);

      final EmployeeWorkSetup? setup =
          await source.loadWorkSetup(employeeEmail: 'Me@co.com', employeeId: 'e1');
      expect(setup!.owner, WorkSetupOwner.timeTracker);
      expect(setup.schedule.startMinutes, 540);
      expect(setup.schedule.workingDays, <int>[7, 1, 2, 3, 4]);
      expect(setup.rules.isPauseAllowed, isTrue);
    });

    test('no assignment, or an unassigned one → null', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final WorkSetupSource source = TimeTrackerWorkSetupSource(remoteDataSource: remote);
      expect(
        await source.loadWorkSetup(employeeEmail: 'me@co.com', employeeId: 'e1'),
        isNull,
      );
      remote.store[TimeTrackerFirestorePaths.locationAssignments] =
          <String, Map<String, dynamic>>{
        'me@co.com': doc(<String, Object?>{'Location_Id': ''}),
      };
      expect(
        await source.loadWorkSetup(employeeEmail: 'me@co.com', employeeId: 'e1'),
        isNull,
      );
    });
  });

  group('HrWorkSetupSource (with HR)', () {
    FakeHrRemote hrData() {
      final FakeHrRemote hr = FakeHrRemote();
      // Exact HR shape: lists of history + capital-T `Timestamps`.
      hr.shifts['s1'] = <String, dynamic>{
        'Id': 's1',
        'Location_Ids': <Object?>['egypt', 'nasr-city'],
        'Branch_Ids': <Object?>['b', 'b'],
        'Start_Minutes': <Object?>[480, 540],
        'End_Minutes': <Object?>[960, 1020],
        'Timestamps': <Object?>[Timestamp.now(), Timestamp.now()],
        'Editor': <Object?>['x', 'y'],
      };
      hr.assignments['e1'] = <String, dynamic>{
        'Id': 'e1',
        'Employee_Id': 'e1',
        'Shift_Id': <Object?>['s0', 's1'],
      };
      return hr;
    }

    test('employee id → current shift → hours and location', () async {
      final WorkSetupSource source = HrWorkSetupSource(remoteDataSource: hrData());
      final EmployeeWorkSetup? setup =
          await source.loadWorkSetup(employeeEmail: 'me@co.com', employeeId: 'e1');
      expect(setup!.owner, WorkSetupOwner.hr);
      expect(setup.schedule.startMinutes, 540);
      expect(setup.schedule.endMinutes, 1020);
      expect(setup.schedule.workingDays, WorkSchedule.allDays);
      expect(setup.location.id, 'nasr-city');
      expect(setup.location.isGeofenceEnabled, isFalse);
      expect(setup.rules.isPauseAllowed, isTrue);
    });

    test('HR location documents win over shift-only ids', () async {
      final FakeHrRemote hr = hrData();
      hr.locations['nasr-city'] = <String, dynamic>{
        'Name_En': 'Nasr City',
        'Latitude': 30.05,
        'Longitude': 31.33,
      };
      final WorkSetupSource source = HrWorkSetupSource(remoteDataSource: hr);
      final List<WorkLocation> all = await source.loadLocations();
      expect(all.single.nameEn, 'Nasr City');
      expect(all.single.hasCoordinates, isTrue);
    });

    test('no HR assignment → null (cannot check in)', () async {
      final WorkSetupSource source = HrWorkSetupSource(remoteDataSource: hrData());
      expect(
        await source.loadWorkSetup(employeeEmail: 'x@co.com', employeeId: 'nobody'),
        isNull,
      );
    });
  });
}
