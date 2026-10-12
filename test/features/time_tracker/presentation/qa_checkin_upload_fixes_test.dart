/// Module: test / time_tracker / presentation
///
///*************************** FILE INFO ****************************///
/// File Name: qa_checkin_upload_fixes_test.dart
/// Purpose: Tests for the QA full-pass bugs fixed on 9/10/2026:
///          KP-TT-015 (one shared check-in state for the module header and
///          every Home quick card; stale actions re-read and recover),
///          KP-TT-012 (one file picker in flight — no "multiple_request"),
///          and the DEBUG-ONLY simulator allowance for mocked positions
///          (release logic still refuses them).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/geolocator_location_repository.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_file_pick_guard.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_log_service.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/today_attendance_hub.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/transaction_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/device_location_reader.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/attendance_session_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/geofence.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
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

const String _dayId = 'me@co.com_2026-10-08';

class _Attachments implements AttachmentBaseRepository {
  int uploads = 0;

  @override
  Future<RequestAttachment> uploadRequestAttachment({
    required String employeeEmail,
    required String fileName,
    required List<int> bytes,
  }) async {
    uploads++;
    return RequestAttachment(name: fileName, url: 'https://x/$fileName', sizeBytes: bytes.length);
  }

  @override
  Future<String> uploadGroupImage({
    required String uploaderEmail,
    required String fileName,
    required List<int> bytes,
  }) async =>
      'https://x/$fileName';
}

/// The module header + two Home quick cards of ONE signed-in employee:
/// three `CheckInCubit`s over one Firestore (fake) and one shared hub.
class _Screens {
  _Screens({bool shared = true}) {
    seedAssignment(remote, location: _hq, rules: const AttendanceRules(isPauseAllowed: true));
    hub = shared ? TodayAttendanceHub(attendance: repo, clock: () => now) : null;
  }

  DateTime now = DateTime(2026, 10, 8, 9, 5);
  final FakeTimeTrackerRemote remote = FakeTimeTrackerRemote();
  final TimeTrackerAccess access = accessWith(allKeys());
  final FakeLog log = FakeLog();
  late final AttendanceRepositoryImpl repo = AttendanceRepositoryImpl(remoteDataSource: remote, access: access);
  TodayAttendanceHub? hub;

  Future<CheckInCubit> open() async {
    final CheckInCubit cubit = CheckInCubit(
      attendance: repo,
      resolver: noHrResolver(remote),
      location: FakeLocationReader(const DeviceLocationResult.found(GeoPoint(30, 31))),
      access: access,
      log: log,
      clock: () => now,
      hub: hub,
    );
    await cubit.init();
    await pumpEventQueue();
    return cubit;
  }

  int get rows => (remote.store[TimeTrackerFirestorePaths.attendance]?[_dayId]?['timestamps'] as List<dynamic>?)?.length ?? 0;
}

void main() {
  group('QA KP-TT-015 — one shared check-in state', () {
    test('a Check Out on one Home card updates the other card AND the module header at once', () async {
      final _Screens s = _Screens();
      final CheckInCubit header = await s.open();
      final CheckInCubit cardA = await s.open();
      final CheckInCubit cardB = await s.open();

      expect((await cardA.checkIn(cardA.state.options.first)).isSuccess, isTrue);
      await pumpEventQueue();
      for (final CheckInCubit c in <CheckInCubit>[header, cardA, cardB]) {
        expect(c.state.isCheckedIn, isTrue, reason: 'every control shows the check-in');
      }

      s.now = DateTime(2026, 10, 8, 11, 37);
      expect((await cardA.checkOut()).isSuccess, isTrue);
      await pumpEventQueue();
      for (final CheckInCubit c in <CheckInCubit>[header, cardA, cardB]) {
        expect(c.state.isCheckedIn, isFalse, reason: 'no stale timer / Pause / Check Out anywhere');
        expect(c.state.hasCheckedOut, isTrue);
      }

      // Pause / Resume from the header show on the cards too.
      s.now = DateTime(2026, 10, 8, 12);
      expect((await header.checkIn(header.state.options.first)).isSuccess, isTrue);
      expect((await header.pause()).isSuccess, isTrue);
      await pumpEventQueue();
      expect(cardB.state.isPaused, isTrue);
      expect((await cardB.resume()).isSuccess, isTrue);
      await pumpEventQueue();
      expect(header.state.isPaused, isFalse);
      expect(s.log.actions, <String>[
        TimeTrackerLogService.actionCheckIn,
        TimeTrackerLogService.actionCheckOut,
        TimeTrackerLogService.actionCheckIn,
        TimeTrackerLogService.actionPause,
        TimeTrackerLogService.actionResume,
      ]);

      await header.close();
      await cardA.close();
      await cardB.close();
      expect(s.hub!.listenersOf('me@co.com'), 0, reason: 'Firestore listeners released');
    });

    test('a change written on ANOTHER device reaches every control (live stored day)', () async {
      final _Screens s = _Screens();
      final CheckInCubit header = await s.open();
      final CheckInCubit card = await s.open();
      // Another device checks in, then out, writing the stored day directly.
      await s.repo.updateDay(
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 8),
        change: (AttendanceDay? d) => AttendanceSessionRules.checkIn(
          d ?? AttendanceDay(id: '', employeeEmail: 'me@co.com', date: DateTime(2026, 10, 8)),
          at: DateTime(2026, 10, 8, 9),
          locationId: 'hq',
          type: WorkLocationType.office,
        ),
      );
      await pumpEventQueue();
      expect(header.state.isCheckedIn, isTrue);
      expect(card.state.isCheckedIn, isTrue);
      await s.repo.updateDay(
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 8),
        change: (AttendanceDay? d) => AttendanceSessionRules.checkOut(d!, at: DateTime(2026, 10, 8, 10)),
      );
      await pumpEventQueue();
      expect(header.state.isCheckedIn, isFalse);
      expect(card.state.isCheckedIn, isFalse);
      await header.close();
      await card.close();
    });

    test('a stale Check Out (screen not refreshed) writes nothing, re-reads and says "already checked out"', () async {
      // No hub: the control CAN be stale (e.g. offline listener) — it must
      // recover instead of "Something went wrong".
      final _Screens s = _Screens(shared: false);
      final CheckInCubit header = await s.open();
      final CheckInCubit card = await s.open();
      expect((await card.checkIn(card.state.options.first)).isSuccess, isTrue);
      await header.init(); // header saw the check-in
      expect(header.state.isCheckedIn, isTrue);
      s.now = DateTime(2026, 10, 8, 11, 7);
      expect((await card.checkOut()).isSuccess, isTrue);
      final int rowsBefore = s.rows;
      expect(header.state.isCheckedIn, isTrue, reason: 'stale on purpose');

      final CheckInResult stale = await header.checkOut();
      expect(stale.outcome, CheckInOutcome.alreadyCheckedOut);
      expect(s.rows, rowsBefore, reason: 'nothing written');
      expect(header.state.isCheckedIn, isFalse, reason: 'the stored day is shown again');
      expect(header.state.isBusy, isFalse);
      expect(s.log.actions.where((String a) => a == TimeTrackerLogService.actionCheckOut), hasLength(1));

      // Stale Pause (the screen still offered it) → same recovery.
      expect((await header.pause()).outcome, CheckInOutcome.alreadyCheckedOut, reason: 'nothing to pause — refreshed');
      await header.close();
      await card.close();
    });

    test('a stale Check In (already checked in elsewhere) → stateChanged, no second session', () async {
      final _Screens s = _Screens(shared: false);
      final CheckInCubit header = await s.open();
      final CheckInCubit card = await s.open();
      expect((await card.checkIn(card.state.options.first)).isSuccess, isTrue);
      expect(header.state.isCheckedIn, isFalse, reason: 'stale on purpose');
      final CheckInResult stale = await header.checkIn(header.state.options.first);
      expect(stale.outcome, CheckInOutcome.stateChanged);
      expect(header.state.isCheckedIn, isTrue);
      expect(header.state.day!.sessions, hasLength(1));
      await header.close();
      await card.close();
    });

    test('hub: a first read never overwrites a newer published day; the shown day follows overnight sessions', () async {
      final _Screens s = _Screens();
      final TodayAttendanceHub hub = s.hub!;
      final AttendanceDay open = AttendanceDay(
        id: _dayId,
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 8),
        sessions: <AttendanceSession>[AttendanceSession(checkInAt: DateTime(2026, 10, 8, 9))],
      );
      final AttendanceDay closed = AttendanceDay(
        id: _dayId,
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 8),
        sessions: <AttendanceSession>[
          AttendanceSession(checkInAt: DateTime(2026, 10, 8, 9), checkOutAt: DateTime(2026, 10, 8, 10)),
        ],
      );
      hub.publish(closed);
      hub.publish(open, authoritative: false);
      expect(hub.shownDay('me@co.com', s.now)!.isCheckedIn, isFalse);
      hub.publish(open);
      expect(hub.shownDay('Me@Co.com', s.now)!.isCheckedIn, isTrue);
      // Next day before check-in: yesterday's still-open session is shown.
      expect(hub.shownDay('me@co.com', DateTime(2026, 10, 9, 1))!.date, DateTime(2026, 10, 8));
      hub.publish(closed);
      final AttendanceDay today = hub.shownDay('me@co.com', DateTime(2026, 10, 9, 1))!;
      expect(today.date, DateTime(2026, 10, 9));
      expect(today.sessions, isEmpty);
      expect(hub.shownDay('other@co.com', s.now), isNull);
    });
  });

  group('QA KP-TT-012 — one file picker in flight', () {
    setUp(() {
      TimeTrackerFilePickGuard.reset();
      TimeTrackerFilePickGuard.retryDelay = Duration.zero;
    });

    TransactionFormCubit form(_Attachments files, Future<PickedFileData?> Function() pick) => TransactionFormCubit(
          service: TransactionService(
            requests: RequestRepositoryImpl(remoteDataSource: FakeTimeTrackerRemote(), access: accessWith(allKeys())),
            managers: FakeManagerResolver(),
            access: accessWith(allKeys()),
            log: FakeLog(),
          ),
          attachments: files,
          access: accessWith(allKeys()),
          clock: () => DateTime(2026, 10, 8, 12),
          pickFile: pick,
        );

    test('a double tap opens ONE picker; the button shows the spinner while picking', () async {
      int opened = 0;
      final Completer<PickedFileData?> picker = Completer<PickedFileData?>();
      final _Attachments files = _Attachments();
      final TransactionFormCubit cubit = form(files, () {
        opened++;
        return picker.future;
      });
      final Future<void> first = cubit.pickAndUpload();
      expect(cubit.state.isUploading, isTrue, reason: 'Upload replaced by the spinner while the picker is open');
      await cubit.pickAndUpload(); // second tap — ignored
      expect(opened, 1, reason: 'never a second native pickFiles (multiple_request)');
      picker.complete(const PickedFileData(name: 'report.pdf', bytes: <int>[1, 2, 3]));
      await first;
      expect(files.uploads, 1);
      expect(cubit.state.attachment!.name, 'report.pdf');
      expect(cubit.state.isUploading, isFalse);
      expect(cubit.state.uploadFailed, isFalse);
      await cubit.close();
    });

    test('a cancelled pick restores the Upload button', () async {
      final TransactionFormCubit cubit = form(_Attachments(), () async => null);
      await cubit.pickAndUpload();
      expect(cubit.state.isUploading, isFalse);
      expect(cubit.state.uploadFailed, isFalse);
      await cubit.close();
    });

    test('"multiple_request" from a native picker still closing → retried once → uploaded', () async {
      int calls = 0;
      final _Attachments files = _Attachments();
      final TransactionFormCubit cubit = form(files, () async {
        calls++;
        if (calls == 1) {
          throw PlatformException(code: 'multiple_request', message: 'Cancelled by a second request');
        }
        return const PickedFileData(name: 'photo.jpg', bytes: <int>[9]);
      });
      await cubit.pickAndUpload();
      expect(calls, 2);
      expect(files.uploads, 1);
      expect(cubit.state.uploadFailed, isFalse);
      expect(TimeTrackerFilePickGuard.isBusy, isFalse);
      await cubit.close();
    });

    test('a refusal that persists is reported (Upload back, error shown), the guard is released', () async {
      final TransactionFormCubit cubit = form(_Attachments(), () async {
        throw PlatformException(code: 'multiple_request', message: 'Cancelled by a second request');
      });
      await cubit.pickAndUpload();
      expect(cubit.state.uploadFailed, isTrue);
      expect(cubit.state.isUploading, isFalse);
      expect(TimeTrackerFilePickGuard.isBusy, isFalse);
      await cubit.close();
    });

    test('guard: module-wide — a second form cannot open a picker while one is open', () async {
      final Completer<String?> first = Completer<String?>();
      final Future<String?> a = TimeTrackerFilePickGuard.run<String>(() => first.future);
      int second = 0;
      expect(await TimeTrackerFilePickGuard.run<String>(() async {
        second++;
        return 'x';
      }), isNull);
      expect(second, 0);
      first.complete('a.pdf');
      expect(await a, 'a.pdf');
      expect(await TimeTrackerFilePickGuard.run<String>(() async => 'b.pdf'), 'b.pdf');
    });
  });

  group('Geofence on the simulator — DEBUG-ONLY mocked positions', () {
    test('release / profile logic (flag false): a mocked position is refused', () {
      expect(
        GeolocatorLocationRepository.judge(isMocked: true, accuracy: 5, allowMocked: false),
        DeviceLocationIssue.mocked,
      );
      expect(const GeolocatorLocationRepository(allowMockedPositions: false).allowMockedPositions, isFalse);
    });

    test('debug allowance (flag true): a mocked simulator position is used like a real one', () {
      expect(GeolocatorLocationRepository.judge(isMocked: true, accuracy: 5, allowMocked: true), isNull);
      // Still too vague → unavailable, mocked or not.
      expect(
        GeolocatorLocationRepository.judge(isMocked: true, accuracy: 500, allowMocked: true),
        DeviceLocationIssue.unavailable,
      );
      expect(GeolocatorLocationRepository.judge(isMocked: false, accuracy: 5, allowMocked: false), isNull);
    });

    test('the default follows kDebugMode (true in this debug test run, false in any release build)', () {
      expect(const GeolocatorLocationRepository().allowMockedPositions, isTrue);
    });
  });
}
