/// Module: test / time_tracker / _support
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_phase5_fakes.dart
/// Purpose: Phase-5 test doubles: an in-memory `HrDashboardBaseRepository`
///          over the same `FakeTimeTrackerRemote` store (attendance days by
///          document-id range, placements given by the test), a fake of the
///          dashboard data source, and seeding helpers for attendance days.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_dashboard_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/hr_dashboard_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';

import 'time_tracker_test_fakes.dart';

/// Store [days] in [remote] (each its own history document).
void seedDays(FakeTimeTrackerRemote remote, List<AttendanceDay> days) {
  for (final AttendanceDay d in days) {
    final String id = TimeTrackerFirestorePaths.attendanceDocId(d.employeeEmail, d.date);
    remote.store.putIfAbsent(TimeTrackerFirestorePaths.attendance, () => <String, Map<String, dynamic>>{})[id] =
        TimeTrackerHistoryCodec.append(
      old: null,
      values: AttendanceDayModel.row(
        d,
        id: id,
        audit: TimeTrackerAudit.next(null, actor: d.employeeEmail, now: d.date),
      ),
      now: d.date,
    );
  }
}

/// The HR dashboard reads over [remote]'s store.
class FakeHrDashboardRepository implements HrDashboardBaseRepository {
  FakeHrDashboardRepository(this.remote, {Map<String, EmployeePlacement>? placements})
      : placements = placements ?? <String, EmployeePlacement>{};

  final FakeTimeTrackerRemote remote;
  Map<String, EmployeePlacement> placements;

  /// Every attendance range asked for (first / last day keys).
  final List<String> attendanceCalls = <String>[];

  /// When set, every read throws it.
  Object? failWith;

  @override
  Future<List<AttendanceDay>> fetchAttendance({
    required Iterable<String> employeeEmails,
    required DateSpan span,
  }) async {
    final Object? error = failWith;
    if (error != null) throw error;
    attendanceCalls.add(
      '${TimeTrackerFirestorePaths.dateKey(span.first)}_${TimeTrackerFirestorePaths.dateKey(span.last)}',
    );
    final Map<String, Map<String, dynamic>> col =
        remote.store[TimeTrackerFirestorePaths.attendance] ?? <String, Map<String, dynamic>>{};
    final List<AttendanceDay> out = <AttendanceDay>[];
    for (final String email in employeeEmails) {
      final String first = TimeTrackerFirestorePaths.attendanceDocId(email, span.first);
      final String last = TimeTrackerFirestorePaths.attendanceDocId(email, span.last);
      for (final MapEntry<String, Map<String, dynamic>> e in col.entries) {
        if (e.key.compareTo(first) >= 0 && e.key.compareTo(last) <= 0) {
          out.add(AttendanceDayModel.fromMap(e.key, e.value));
        }
      }
    }
    return out;
  }

  @override
  Future<Map<String, EmployeePlacement>> fetchPlacements({required List<TimeTrackerEmployee> employees}) async {
    final Object? error = failWith;
    if (error != null) throw error;
    final Set<String> wanted = <String>{for (final TimeTrackerEmployee e in employees) e.email};
    return <String, EmployeePlacement>{
      for (final MapEntry<String, EmployeePlacement> p in placements.entries)
        if (wanted.contains(p.key)) p.key: p.value,
    };
  }
}

/// The dashboard data source over [remote]'s store (repository tests).
class FakeDashboardRemote implements TimeTrackerDashboardRemoteDataSource {
  FakeDashboardRemote(this.remote);

  final FakeTimeTrackerRemote remote;

  /// Every id range read.
  final List<String> ranges = <String>[];

  @override
  Future<List<TimeTrackerDocument>> fetchIdRange(
    String relativePath, {
    required String firstId,
    required String lastId,
  }) async {
    ranges.add('$firstId..$lastId');
    final Map<String, Map<String, dynamic>> col = remote.store[relativePath] ?? <String, Map<String, dynamic>>{};
    final List<String> ids = col.keys.where((String id) => id.compareTo(firstId) >= 0 && id.compareTo(lastId) <= 0).toList()
      ..sort();
    return <TimeTrackerDocument>[for (final String id in ids) TimeTrackerDocument(id: id, data: col[id]!)];
  }

  @override
  Future<List<TimeTrackerDocument>> fetchCollection(String relativePath) async {
    final Map<String, Map<String, dynamic>> col = remote.store[relativePath] ?? <String, Map<String, dynamic>>{};
    return <TimeTrackerDocument>[
      for (final MapEntry<String, Map<String, dynamic>> e in col.entries) TimeTrackerDocument(id: e.key, data: e.value),
    ];
  }
}
