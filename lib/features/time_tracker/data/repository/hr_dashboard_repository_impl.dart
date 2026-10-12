/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: hr_dashboard_repository_impl.dart
/// Purpose: Declares `HrDashboardRepositoryImpl` — the HR dashboard's
///          company-wide reads: attendance days of many employees for a date
///          range, and every employee's placement (location + schedule).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Attendance: one document-id range per employee
/// (`{email}_{first}` … `{email}_{last}`), at most [batchSize] reads in
/// flight — bounded by the range, never the whole collection.
/// Placements: whoever owns the set-up (owner decision 7):
///   * no HR → `Location_Assignments` + `Locations` (the location's Work
///     Start / End, Working Days and Late After are the schedule; inactive or
///     deleted locations place nobody);
///   * HR → `Shift_Assignments/{employeeId}` + `Shifts` (working week
///     UNKNOWN — `isWorkingWeekKnown: false`, 9/10/2026 code review finding
///     1 — and no start date, the `HrWorkSetupSource` defaults).
/// Firestore failures become clean `Exception`s (try/catch lives in
/// repositories and cubits only).

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_dashboard_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/hr_work_setup_mapper.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/hr_dashboard_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_placement.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/dashboard_range.dart';

class HrDashboardRepositoryImpl implements HrDashboardBaseRepository {
  HrDashboardRepositoryImpl({
    required TimeTrackerDashboardRemoteDataSource remoteDataSource,
    required WorkSetupSourceResolver resolver,
  })  : _remote = remoteDataSource,
        _resolver = resolver;

  final TimeTrackerDashboardRemoteDataSource _remote;
  final WorkSetupSourceResolver _resolver;

  /// Range reads in flight at once.
  static const int batchSize = 10;

  @override
  Future<List<AttendanceDay>> fetchAttendance({
    required Iterable<String> employeeEmails,
    required DateSpan span,
  }) async {
    try {
      final List<String> emails = <String>{
        for (final String e in employeeEmails)
          if (e.trim().isNotEmpty && !e.contains('/')) e.trim().toLowerCase(),
      }.toList()
        ..sort();
      final List<AttendanceDay> out = <AttendanceDay>[];
      for (int i = 0; i < emails.length; i += batchSize) {
        final Iterable<String> batch = emails.skip(i).take(batchSize);
        final List<List<TimeTrackerDocument>> pages = await Future.wait(<Future<List<TimeTrackerDocument>>>[
          for (final String email in batch)
            _remote.fetchIdRange(
              TimeTrackerFirestorePaths.attendance,
              firstId: TimeTrackerFirestorePaths.attendanceDocId(email, span.first),
              lastId: TimeTrackerFirestorePaths.attendanceDocId(email, span.last),
            ),
        ]);
        for (final List<TimeTrackerDocument> page in pages) {
          out.addAll(page.map((TimeTrackerDocument d) => AttendanceDayModel.fromMap(d.id, d.data)));
        }
      }
      return List<AttendanceDay>.unmodifiable(out);
    } catch (error) {
      throw _clean(error, 'load the attendance');
    }
  }

  @override
  Future<Map<String, EmployeePlacement>> fetchPlacements({
    required List<TimeTrackerEmployee> employees,
  }) async {
    try {
      final bool hasHr = await _resolver.hasHrModule();
      return hasHr ? await _hrPlacements(employees) : await _ownPlacements(employees);
    } catch (error) {
      throw _clean(error, 'load the work locations');
    }
  }

  Future<Map<String, EmployeePlacement>> _ownPlacements(List<TimeTrackerEmployee> employees) async {
    final List<TimeTrackerDocument> assignmentDocs =
        await _remote.fetchCollection(TimeTrackerFirestorePaths.locationAssignments);
    final List<TimeTrackerDocument> locationDocs = await _remote.fetchCollection(TimeTrackerFirestorePaths.locations);
    final Map<String, WorkLocation> locations = <String, WorkLocation>{
      for (final TimeTrackerDocument d in locationDocs) d.id: WorkLocationModel.fromMap(d.id, d.data),
    };
    final Set<String> wanted = <String>{for (final TimeTrackerEmployee e in employees) e.email.trim().toLowerCase()};
    final Map<String, EmployeePlacement> out = <String, EmployeePlacement>{};
    for (final TimeTrackerDocument d in assignmentDocs) {
      final LocationAssignment a = LocationAssignmentModel.fromMap(d.id, d.data);
      final String email = (a.employeeEmail.isNotEmpty ? a.employeeEmail : d.id).trim().toLowerCase();
      final WorkLocation? location = locations[a.locationId];
      if (!wanted.contains(email) || !a.isAssigned || location == null || !location.isActive) continue;
      out[email] = EmployeePlacement(
        email: email,
        locationId: location.id,
        schedule: location.schedule,
        startDate: a.startDate,
      );
    }
    return Map<String, EmployeePlacement>.unmodifiable(out);
  }

  Future<Map<String, EmployeePlacement>> _hrPlacements(List<TimeTrackerEmployee> employees) async {
    final List<TimeTrackerDocument> assignmentDocs =
        await _remote.fetchCollection(TimeTrackerFirestorePaths.hrShiftAssignments);
    final List<TimeTrackerDocument> shiftDocs = await _remote.fetchCollection(TimeTrackerFirestorePaths.hrShifts);
    final Map<String, HrShift> shifts = <String, HrShift>{
      for (final TimeTrackerDocument d in shiftDocs) d.id: HrWorkSetupMapper.shiftFrom(d),
    };
    final Map<String, String> emailById = <String, String>{
      for (final TimeTrackerEmployee e in employees)
        if (e.employeeId.trim().isNotEmpty) e.employeeId.trim(): e.email.trim().toLowerCase(),
    };
    final Map<String, EmployeePlacement> out = <String, EmployeePlacement>{};
    for (final TimeTrackerDocument d in assignmentDocs) {
      final String? email = emailById[d.id];
      final HrShift? shift = shifts[HrWorkSetupMapper.shiftIdOf(d)];
      if (email == null || shift == null) continue;
      out[email] = EmployeePlacement(
        email: email,
        locationId: shift.locationId,
        // 9/10/2026 (code review finding 1): no working days in HR → unknown week.
        schedule: WorkSchedule(
          startMinutes: shift.startMinutes,
          endMinutes: shift.endMinutes,
          isWorkingWeekKnown: false,
        ),
      );
    }
    return Map<String, EmployeePlacement>.unmodifiable(out);
  }

  Exception _clean(Object error, String action) {
    if (error is FirebaseException) return Exception('Could not $action (${error.code}).');
    if (error is StateError) return Exception(error.message);
    if (error is Exception) return error;
    return Exception('Could not $action: $error');
  }
}
