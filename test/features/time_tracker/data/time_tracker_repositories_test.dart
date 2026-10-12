/// Module: test / time_tracker / data
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_repositories_test.dart
/// Purpose: Unit tests for the repositories over an in-memory data source —
///          writes land in the right collection / document id, every write
///          appends a history row with the audit trio, invalid or anonymous
///          writes never reach the data source, and errors come back clean.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/data/repository/attendance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_assignment_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/location_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/request_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/vacation_balance_repository_impl.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

import '../_support/time_tracker_test_fakes.dart';

void main() {
  late FakeTimeTrackerRemote remote;

  setUp(() => remote = FakeTimeTrackerRemote());

  TimeTrackerRequest draft() => TimeTrackerRequest(
        id: '',
        requesterEmail: 'me@co.com',
        requestTypeId: 'annual',
        startAt: DateTime(2026, 10, 11),
        endAt: DateTime(2026, 10, 12),
      );

  group('RequestRepositoryImpl', () {
    test('create → Requests/{autoId}; update appends a second row', () async {
      final RequestRepositoryImpl repo =
          RequestRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
      final TimeTrackerRequest saved = await repo.createRequest(request: draft());
      expect(saved.id, isNotEmpty);
      expect(remote.writes.single, TimeTrackerFirestorePaths.requests);
      expect(remote.ensureCalls, 1);

      await repo.updateRequest(
        request: saved.copyWith(status: RequestStatus.approved),
      );
      final Map<String, dynamic> doc =
          remote.store[TimeTrackerFirestorePaths.requests]![saved.id]!;
      expect(doc['Request_Status'], <Object?>['pending', 'approved']);
      expect(doc['timestamps'], hasLength(2));
      expect(doc['Modified_By'], <Object?>['me@co.com', 'me@co.com']);
    });

    test('invalid requests never reach the data source', () async {
      final RequestRepositoryImpl repo =
          RequestRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
      await expectLater(
        repo.createRequest(request: draft().copyWith(requestTypeId: '')),
        throwsException,
      );
      await expectLater(
        repo.createRequest(
          request: draft().copyWith(endAt: DateTime(2026, 10, 1)),
        ),
        throwsException,
      );
      await expectLater(repo.updateRequest(request: draft()), throwsException);
      expect(remote.writes, isEmpty);
    });

    test('an anonymous write is refused', () async {
      final RequestRepositoryImpl repo = RequestRepositoryImpl(
        remoteDataSource: remote,
        access: accessWith(<String>{}, email: ''),
      );
      await expectLater(repo.createRequest(request: draft()), throwsException);
      expect(remote.writes, isEmpty);
    });

    test('updating a vanished request fails cleanly (no StateError)', () async {
      final RequestRepositoryImpl repo =
          RequestRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
      await expectLater(
        repo.updateRequest(
          request: TimeTrackerRequest(
            id: 'gone',
            requesterEmail: 'me@co.com',
            requestTypeId: 'annual',
            startAt: DateTime(2026),
            endAt: DateTime(2026),
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('watch errors arrive as clean Exceptions', () async {
      remote.failWith = StateError('No company is signed in');
      final RequestRepositoryImpl repo =
          RequestRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
      await expectLater(repo.watchRequests(), emitsError(isException));
    });
  });

  group('AttendanceRepositoryImpl', () {
    test('one document per employee per day: {email}_{yyyy-MM-dd}', () async {
      final AttendanceRepositoryImpl repo = AttendanceRepositoryImpl(
        remoteDataSource: remote,
        access: accessWith(<String>{}),
      );
      final AttendanceDay day = AttendanceDay(
        id: '',
        employeeEmail: 'Me@Co.com',
        date: DateTime(2026, 10, 8),
        sessions: <AttendanceSession>[
          AttendanceSession(checkInAt: DateTime(2026, 10, 8, 9)),
        ],
      );
      await repo.saveDay(day: day);
      await repo.saveDay(day: day);
      final Map<String, Map<String, dynamic>> col =
          remote.store[TimeTrackerFirestorePaths.attendance]!;
      expect(col.keys, <String>['me@co.com_2026-10-08']);
      expect(col.values.single['timestamps'], hasLength(2));

      final AttendanceDay? read = await repo.fetchDay(
        employeeEmail: 'me@co.com',
        date: DateTime(2026, 10, 8, 23),
      );
      expect(read!.isCheckedIn, isTrue);
      final List<AttendanceDay> mine =
          await repo.watchEmployeeAttendance(employeeEmail: 'ME@co.com').first;
      expect(mine, hasLength(1));
    });

    test('a check-out before its check-in is refused', () async {
      final AttendanceRepositoryImpl repo = AttendanceRepositoryImpl(
        remoteDataSource: remote,
        access: accessWith(<String>{}),
      );
      await expectLater(
        repo.saveDay(
          day: AttendanceDay(
            id: '',
            employeeEmail: 'me@co.com',
            date: DateTime(2026, 10, 8),
            sessions: <AttendanceSession>[
              AttendanceSession(
                checkInAt: DateTime(2026, 10, 8, 9),
                checkOutAt: DateTime(2026, 10, 8, 8),
              ),
            ],
          ),
        ),
        throwsException,
      );
    });

    test('a path-breaking email is a clean Exception', () async {
      final AttendanceRepositoryImpl repo = AttendanceRepositoryImpl(
        remoteDataSource: remote,
        access: accessWith(<String>{}),
      );
      await expectLater(
        repo.fetchDay(employeeEmail: 'a/b@c.com', date: DateTime(2026)),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('assignments and balances are keyed by the lower-cased email', () async {
    final LocationAssignmentRepositoryImpl assignments =
        LocationAssignmentRepositoryImpl(
      remoteDataSource: remote,
      access: accessWith(<String>{}),
    );
    await assignments.saveAssignment(
      assignment: const LocationAssignment(employeeEmail: 'New@Co.com', locationId: 'hq'),
    );
    expect(remote.store[TimeTrackerFirestorePaths.locationAssignments]!.keys,
        <String>['new@co.com']);

    final VacationBalanceRepositoryImpl balances = VacationBalanceRepositoryImpl(
      remoteDataSource: remote,
      access: accessWith(<String>{}),
    );
    await balances.saveBalance(
      balance: const VacationBalance(
        employeeEmail: 'New@Co.com',
        year: 2026,
        totalDays: 21,
      ),
    );
    final VacationBalance? read = await balances.fetchBalance(employeeEmail: 'new@co.com', year: 2026);
    // 9/10/2026 (data model): one document per employee per year.
    expect(remote.store[TimeTrackerFirestorePaths.vacationBalances]!.keys, <String>['new@co.com_2026']);
    expect(read!.remainingDays, 21);
    await expectLater(
      balances.saveBalance(
        balance: const VacationBalance(employeeEmail: 'x@co.com', year: 2026, totalDays: -1),
      ),
      throwsException,
    );
  });

  test('a location with a geofence needs coordinates and a radius', () async {
    final LocationRepositoryImpl repo =
        LocationRepositoryImpl(remoteDataSource: remote, access: accessWith(<String>{}));
    await expectLater(
      repo.createLocation(
        location: const WorkLocation(id: '', nameEn: 'HQ', isGeofenceEnabled: true),
      ),
      throwsException,
    );
    await expectLater(
      repo.createLocation(
        location: const WorkLocation(id: '', nameEn: 'HQ', workingDays: <int>[]),
      ),
      throwsException,
    );
    final WorkLocation saved = await repo.createLocation(
      location: const WorkLocation(id: '', nameEn: 'HQ'),
    );
    expect(saved.id, isNotEmpty);
    expect(remote.writes, <String>[TimeTrackerFirestorePaths.locations]);
  });
}
