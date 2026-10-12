/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: phase2_cubits_test.dart
/// Purpose: Unit tests for the phase-2 cubits: Check In / Pause / Resume /
///          Check Out (geofence, permission denied, wrong location, not
///          assigned), the home cubit's tabs + sweep, the transaction form,
///          and the dashboard / attendance cubits.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/absent_day_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_table_filter.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/transaction_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/controller/time_tracker_home_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt2_personal_dashboard/presentation/controller/personal_dashboard_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt3_attendance/presentation/controller/attendance_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt4_transaction_form/presentation/controller/transaction_form_cubit.dart';

import '../_support/time_tracker_test_fakes.dart';

/// HQ with a 100 m geofence at (30, 31).
const WorkLocation _hq = WorkLocation(
  id: 'hq',
  nameEn: 'HQ',
  latitude: 30,
  longitude: 31,
  isGeofenceEnabled: true,
  geofenceRadiusMeters: 100,
);

class _FakeAttachments implements AttachmentBaseRepository {
  int uploads = 0;

  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    uploads++;
    return RequestAttachment(
      name: fileName,
      url: 'https://x/$fileName',
      sizeBytes: bytes.length,
      uploadedAt: DateTime(2026, 10, 8),
    );
  }

  // Added 9/10/2026 (phase 3): group pictures.
  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      'https://x/$fileName';
}

void main() {
  group('CheckInCubit', () {
    DateTime now = DateTime(2026, 10, 8, 9, 5);

    Future<({CheckInCubit cubit, FakeTimeTrackerRemote remote, FakeLog log, FakeLocationReader gps})>
        build({
      Set<String>? on,
      AttendanceRules rules = const AttendanceRules(isPauseAllowed: true),
      DeviceLocationResult? position,
      bool assigned = true,
    }) async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      if (assigned) seedAssignment(remote, location: _hq, rules: rules);
      final TimeTrackerAccess access = accessWith(on ?? allKeys());
      final FakeLog log = FakeLog();
      final FakeLocationReader gps = FakeLocationReader(
        position ?? const DeviceLocationResult.found(GeoPoint(30, 31)),
      );
      final CheckInCubit cubit = CheckInCubit(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        resolver: noHrResolver(remote),
        location: gps,
        access: access,
        log: log,
        clock: () => now,
      );
      await cubit.init();
      return (cubit: cubit, remote: remote, log: log, gps: gps);
    }

    setUp(() => now = DateTime(2026, 10, 8, 9, 5));

    test('init: ready, not checked in, own location offered', () async {
      final r = await build();
      expect(r.cubit.state.status, CheckInLoadStatus.ready);
      expect(r.cubit.state.isCheckedIn, isFalse);
      expect(r.cubit.state.options.map((CheckInOption o) => o.key), <String>['hq']);
      await r.cubit.close();
    });

    test('check in inside the geofence → verified, late, logged', () async {
      final r = await build();
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(result.isSuccess, isTrue);
      expect(result.locationVerified, isTrue);
      expect(r.gps.reads, 1);
      expect(r.cubit.state.isCheckedIn, isTrue);
      expect(r.cubit.state.day!.status, AttendanceStatus.late);
      expect(r.cubit.state.day!.lateMinutes, 5);
      expect(r.log.actions, <String>[TimeTrackerLogService.actionCheckIn]);
      expect(r.remote.store[TimeTrackerFirestorePaths.attendance]!.keys,
          <String>['me@co.com_2026-10-08']);
      await r.cubit.close();
    });

    // 9/10/2026 (code review, "geolocator ignores isMocked / accuracy").
    test('code review: a mock-location position is refused, nothing written', () async {
      final r = await build(position: const DeviceLocationResult.failed(DeviceLocationIssue.mocked));
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(result.outcome, CheckInOutcome.mockedLocation);
      expect(r.cubit.state.isCheckedIn, isFalse);
      expect(r.remote.store[TimeTrackerFirestorePaths.attendance] ?? const <String, dynamic>{}, isEmpty);
      await r.cubit.close();
    });

    // 9/10/2026 (code review: no busy guard → double tap = two sessions).
    test('code review: a second tap while the first check-in saves is ignored', () async {
      final r = await build();
      final Future<CheckInResult> first = r.cubit.checkIn(r.cubit.state.options.first);
      final CheckInResult second = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(second.outcome, CheckInOutcome.busy);
      expect((await first).isSuccess, isTrue);
      expect(r.cubit.state.day!.sessions, hasLength(1));
      expect(r.log.actions, <String>[TimeTrackerLogService.actionCheckIn]);
      await r.cubit.close();
    });

    test('outside the geofence → Wrong Location, nothing written', () async {
      final r = await build(
        position: const DeviceLocationResult.found(GeoPoint(30.1, 31.1)),
      );
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(result.outcome, CheckInOutcome.wrongLocation);
      expect(r.cubit.state.isCheckedIn, isFalse);
      expect(r.remote.store[TimeTrackerFirestorePaths.attendance] ?? const <String, Object>{},
          isEmpty);
      await r.cubit.close();
    });

    test('location permission denied → clear outcome, blocked', () async {
      final r = await build(
        position: const DeviceLocationResult.failed(DeviceLocationIssue.deniedForever),
      );
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(result.outcome, CheckInOutcome.locationDenied);
      expect(r.cubit.state.isCheckedIn, isFalse);
      await r.cubit.close();
    });

    test('pause → resume → check out; several sessions a day', () async {
      final r = await build();
      await r.cubit.checkIn(r.cubit.state.options.first);
      now = DateTime(2026, 10, 8, 12);
      expect((await r.cubit.pause()).isSuccess, isTrue);
      expect(r.cubit.state.isPaused, isTrue);
      now = DateTime(2026, 10, 8, 12, 30);
      expect((await r.cubit.resume()).isSuccess, isTrue);
      now = DateTime(2026, 10, 8, 17);
      expect((await r.cubit.checkOut()).isSuccess, isTrue);
      expect(r.cubit.state.isCheckedIn, isFalse);
      expect(r.cubit.state.hasCheckedOut, isTrue);
      final AttendanceDay day = r.cubit.state.day!;
      expect(day.breakMinutes, 30);
      expect(day.totalWorkMinutes, 7 * 60 + 25);
      // Check in again the same day.
      now = DateTime(2026, 10, 8, 18);
      expect((await r.cubit.checkIn(r.cubit.state.options.first)).isSuccess, isTrue);
      expect(r.cubit.state.day!.sessions, hasLength(2));
      expect(r.log.actions, <String>[
        TimeTrackerLogService.actionCheckIn,
        TimeTrackerLogService.actionPause,
        TimeTrackerLogService.actionResume,
        TimeTrackerLogService.actionCheckOut,
        TimeTrackerLogService.actionCheckIn,
      ]);
      await r.cubit.close();
    });

    test('pause not allowed by the rules → refused', () async {
      final r = await build(rules: const AttendanceRules());
      await r.cubit.checkIn(r.cubit.state.options.first);
      expect(r.cubit.state.canPause, isFalse);
      expect((await r.cubit.pause()).outcome, CheckInOutcome.failed);
      await r.cubit.close();
    });

    test('Check_In_And_Out OFF → no permission', () async {
      final r = await build(on: <String>{'Attendance_Permissions', 'View_Attendance'});
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options.first);
      expect(result.outcome, CheckInOutcome.noPermission);
      await r.cubit.close();
    });

    test('not assigned anywhere → notAssigned', () async {
      final r = await build(assigned: false);
      expect(r.cubit.state.setup, isNull);
      expect(r.cubit.state.options, isEmpty);
      expect(
        (await r.cubit.checkIn(const CheckInOption.office(_hq))).outcome,
        CheckInOutcome.notAssigned,
      );
      await r.cubit.close();
    });

    test('Remote offered only with work-elsewhere (switch + assignment)', () async {
      final r = await build(
        rules: const AttendanceRules(isDifferentLocationAllowed: true),
      );
      expect(r.cubit.state.options.map((CheckInOption o) => o.key),
          <String>['hq', 'remote', 'client_site']);
      final CheckInResult result = await r.cubit.checkIn(r.cubit.state.options[1]);
      expect(result.isSuccess, isTrue);
      expect(result.locationVerified, isFalse);
      expect(r.gps.reads, 0);
      await r.cubit.close();
      final r2 = await build(
        on: allKeys()..remove('Work_From_Different_Location'),
        rules: const AttendanceRules(isDifferentLocationAllowed: true),
      );
      expect(r2.cubit.state.options.map((CheckInOption o) => o.key), <String>['hq']);
      await r2.cubit.close();
    });
  });

  group('TimeTrackerHomeCubit (phase 2)', () {
    test('first tab selected; selectTab / toggleHeader; sweep runs', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      seedAssignment(remote,
          location: const WorkLocation(id: 'hq', nameEn: 'HQ'),
          startDate: DateTime(2026, 10, 1));
      final TimeTrackerAccess access = accessWith(allKeys());
      final AbsentDaySweeper sweeper = AbsentDaySweeper(
        attendance: AttendanceRepositoryImpl(remoteDataSource: remote, access: access),
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        resolver: noHrResolver(remote),
        access: access,
        clock: () => DateTime(2026, 10, 3, 10),
      );
      final TimeTrackerHomeCubit cubit = TimeTrackerHomeCubit(
        access: access,
        resolver: noHrResolver(remote),
        sweeper: sweeper,
      );
      await cubit.init();
      expect(cubit.state.selectedTab, TimeTrackerTab.dashboard);
      cubit.selectTab(TimeTrackerTab.attendance);
      expect(cubit.state.selectedTab, TimeTrackerTab.attendance);
      cubit.toggleHeader();
      expect(cubit.state.headerExpanded, isFalse);
      await pumpEventQueue(); // the fire-and-forget sweep from init
      expect(remote.store[TimeTrackerFirestorePaths.attendance]!.keys,
          <String>['me@co.com_2026-10-01', 'me@co.com_2026-10-02']);
      expect(cubit.lastSweepError, isEmpty);
      await cubit.close();
    });

    test('a hidden tab cannot be selected', () async {
      final TimeTrackerHomeCubit cubit = TimeTrackerHomeCubit(
        access: accessWith(<String>{'Attendance_Permissions', 'View_Attendance'}),
        resolver: noHrResolver(FakeTimeTrackerRemote()),
      );
      await cubit.init();
      expect(cubit.state.tabs, <TimeTrackerTab>[TimeTrackerTab.attendance]);
      cubit.selectTab(TimeTrackerTab.approvals);
      expect(cubit.state.selectedTab, TimeTrackerTab.attendance);
      await cubit.close();
    });
  });

  group('TransactionFormCubit', () {
    TransactionFormCubit build(FakeTimeTrackerRemote remote, {_FakeAttachments? files}) {
      final TimeTrackerAccess access = accessWith(allKeys());
      return TransactionFormCubit(
        service: TransactionService(
          requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
          managers: FakeManagerResolver('boss@co.com'),
          access: access,
          log: FakeLog(),
          clock: () => DateTime(2026, 10, 8, 12),
        ),
        attachments: files ?? _FakeAttachments(),
        access: access,
        clock: () => DateTime(2026, 10, 8, 12),
        pickFile: () async => null,
      );
    }

    test('starts invalid; errors only after revealErrors', () async {
      final TransactionFormCubit cubit = build(FakeTimeTrackerRemote());
      expect(cubit.state.canSubmit, isFalse);
      expect(cubit.state.shows(TransactionError.checkInRequired), isFalse);
      expect(cubit.revealErrors(), isFalse);
      expect(cubit.state.shows(TransactionError.checkInRequired), isTrue);
      await cubit.close();
    });

    test('valid draft + uploaded file → submitted with the attachment', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final _FakeAttachments files = _FakeAttachments();
      final TransactionFormCubit cubit = build(remote, files: files);
      cubit
        ..checkInChanged(DateTime(2026, 10, 7, 9))
        ..checkOutChanged(DateTime(2026, 10, 7, 17))
        ..descriptionChanged('Forgot');
      await cubit.uploadAttachment('scan.pdf', <int>[1, 2, 3]);
      expect(cubit.state.attachment!.name, 'scan.pdf');
      expect(cubit.state.canSubmit, isTrue);
      expect(await cubit.submit(), isTrue);
      expect(cubit.state.status, TransactionFormStatus.success);
      expect(files.uploads, 1);
      expect(remote.store[TimeTrackerFirestorePaths.requests], hasLength(1));
      await cubit.close();
    });

    test('a file over 10 MB is refused before upload', () async {
      final _FakeAttachments files = _FakeAttachments();
      final TransactionFormCubit cubit = build(FakeTimeTrackerRemote(), files: files);
      await cubit.uploadAttachment('big.bin', List<int>.filled(AttachmentBaseRepository.maxSizeBytes + 1, 0));
      expect(cubit.state.fileTooLarge, isTrue);
      expect(files.uploads, 0);
      await cubit.close();
    });
  });

  group('dashboard + attendance cubits', () {
    test('dashboard: loads, ranges, custom span, late mode', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final TimeTrackerAccess access = accessWith(allKeys());
      final AttendanceRepositoryImpl attendance =
          AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
      await attendance.saveDay(
        day: AttendanceDay(
          id: '',
          employeeEmail: 'me@co.com',
          date: DateTime(2026, 10, 6),
          status: AttendanceStatus.late,
          lateMinutes: 12,
        ),
      );
      final PersonalDashboardCubit cubit = PersonalDashboardCubit(
        attendance: attendance,
        requests: RequestRepositoryImpl(remoteDataSource: remote, access: access),
        balances: VacationBalanceRepositoryImpl(remoteDataSource: remote, access: access),
        resolver: noHrResolver(remote),
        access: access,
        clock: () => DateTime(2026, 10, 8, 12),
      );
      await cubit.init();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, PersonalDashboardStatus.loaded);
      expect(cubit.state.range, DashboardRange.year);
      expect(cubit.state.stats.late, 1);
      cubit.selectRange(DashboardRange.day);
      expect(cubit.state.stats.late, 0);
      cubit.applyCustom(DateTime(2026, 10, 7), DateTime(2026, 10, 1));
      expect(cubit.state.range, DashboardRange.custom);
      expect(cubit.state.span.first, DateTime(2026, 10, 1));
      expect(cubit.state.stats.lateByMonth.single.minutes, 12);
      cubit.setLateMode(LateHistoryMode.counts);
      expect(cubit.state.lateMode, LateHistoryMode.counts);
      await cubit.close();
    });

    test('attendance: streams days, filter and reset', () async {
      final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
      final TimeTrackerAccess access = accessWith(allKeys());
      final AttendanceRepositoryImpl attendance =
          AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
      for (final AttendanceStatus s in <AttendanceStatus>[AttendanceStatus.present, AttendanceStatus.absent]) {
        await attendance.saveDay(
          day: AttendanceDay(
            id: '',
            employeeEmail: 'me@co.com',
            date: DateTime(2026, 10, s == AttendanceStatus.present ? 5 : 6),
            status: s,
          ),
        );
      }
      final AttendanceCubit cubit = AttendanceCubit(attendance: attendance, access: access);
      await cubit.init();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.status, AttendanceLoadStatus.loaded);
      expect(cubit.state.days, hasLength(2));
      cubit.applyFilter(const AttendanceFilter(status: AttendanceStatus.absent));
      expect(cubit.state.rows((_) => '').single.status, AttendanceStatus.absent);
      cubit.resetFilter();
      expect(cubit.state.rows((_) => ''), hasLength(2));
      await cubit.close();
    });
  });
}
