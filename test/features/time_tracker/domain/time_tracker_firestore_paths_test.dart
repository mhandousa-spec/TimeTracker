/// Module: test / time_tracker / domain
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_firestore_paths_test.dart
/// Purpose: Unit tests for `TimeTrackerFirestorePaths` — the FINAL SPEC §2
///          layout (one collection per feature under Modules/time_tracker),
///          the `{email}_{yyyy-MM-dd}` attendance id, HR read paths and the
///          refusal of an empty / path-breaking email.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026

import 'package:flutter_test/flutter_test.dart';

import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';

void main() {
  group('collections', () {
    test('live under Modules/time_tracker with the spec names', () {
      expect(TimeTrackerFirestorePaths.root, 'Modules/time_tracker');
      expect(TimeTrackerFirestorePaths.attendance, 'Modules/time_tracker/Attendance');
      expect(TimeTrackerFirestorePaths.requests, 'Modules/time_tracker/Requests');
      expect(TimeTrackerFirestorePaths.requestTypes,
          'Modules/time_tracker/Request_Types');
      expect(TimeTrackerFirestorePaths.locations, 'Modules/time_tracker/Locations');
      expect(TimeTrackerFirestorePaths.locationAssignments,
          'Modules/time_tracker/Location_Assignments');
      expect(TimeTrackerFirestorePaths.groups, 'Modules/time_tracker/Groups');
      expect(TimeTrackerFirestorePaths.vacationBalances,
          'Modules/time_tracker/Vacation_Balances');
      expect(TimeTrackerFirestorePaths.notificationLog,
          'Modules/time_tracker/Notification_Log');
    });

    test('HR data is read from Modules/hr', () {
      expect(TimeTrackerFirestorePaths.hrShifts, 'Modules/hr/Shifts');
      expect(TimeTrackerFirestorePaths.hrShiftAssignments,
          'Modules/hr/Shift_Assignments');
      expect(TimeTrackerFirestorePaths.hrLocations, 'Modules/hr/Locations');
    });

    test('role grants + licence key follow the house naming', () {
      expect(TimeTrackerFirestorePaths.rolePermissions,
          'time_tracker_module_permissions');
      expect(TimeTrackerFirestorePaths.moduleKey, 'time_tracker');
    });
  });

  group('document ids', () {
    test('attendance id = lower-cased email + yyyy-MM-dd', () {
      expect(
        TimeTrackerFirestorePaths.attendanceDocId(
          '  Moataz@Bayanatz.COM ',
          DateTime(2026, 3, 7, 18, 30),
        ),
        'moataz@bayanatz.com_2026-03-07',
      );
      expect(TimeTrackerFirestorePaths.attendancePrefix('A@B.com'), 'a@b.com_');
    });

    test('notification log id joins ref, event and millis', () {
      expect(
        TimeTrackerFirestorePaths.notificationLogDocId('r1', 'late', 42),
        'r1__late__42',
      );
    });

    test('rejects an empty, blank or path-splitting email', () {
      expect(() => TimeTrackerFirestorePaths.emailKey(''), throwsStateError);
      expect(() => TimeTrackerFirestorePaths.emailKey('   '), throwsStateError);
      expect(
        () => TimeTrackerFirestorePaths.attendanceDocId('a/b@c.com', DateTime(2026)),
        throwsStateError,
      );
    });
  });
}
