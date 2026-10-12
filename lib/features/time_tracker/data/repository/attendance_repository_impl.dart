/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_repository_impl.dart
/// Purpose: Declares `AttendanceRepositoryImpl` — attendance days in
///          `Modules/time_tracker/Attendance/{email}_{yyyy-MM-dd}`.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// One document per employee per day (FINAL SPEC §2); its history is the
/// day's event log (each check-in / pause / resume / check-out = one row).
/// "My attendance" is a document-id range on `{email}_` — no field query on
/// a history list. Owner decision 8: HR never edits a day directly; a
/// correction arrives as an approved transaction (`Is_Corrected_By_
/// Transaction` + `Source_Request_Id`).
/// Updated: 9/10/2026 - phase 4: [fetchCorrectionHistory] (transaction revert).
/// Updated: 9/10/2026 - code review: [updateDay] — the check-in moves are
/// applied to the day AS STORED inside one transaction (they used to write
/// the screen's cached copy over a second device's / a correction's row).
/// Updated: 9/10/2026 - QA KP-TT-015: [watchDay] (the shared check-in state
/// follows today's / yesterday's stored day live).

import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/time_tracker_history_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attendance_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';

class AttendanceRepositoryImpl extends TimeTrackerHistoryRepository<AttendanceDay>
    implements AttendanceBaseRepository {
  AttendanceRepositoryImpl({
    required super.remoteDataSource,
    required super.access,
  });

  @override
  String get collectionPath => TimeTrackerFirestorePaths.attendance;

  @override
  String get entityLabel => 'attendance day';

  @override
  AttendanceDay decode(TimeTrackerDocument document) =>
      AttendanceDayModel.fromMap(document.id, document.data);

  @override
  Map<String, Object?> encode(
    AttendanceDay entity, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      AttendanceDayModel.row(entity, id: id, audit: audit);

  @override
  void validate(AttendanceDay entity) {
    for (final AttendanceSession s in entity.sessions) {
      final DateTime? out = s.checkOutAt;
      if (out != null && out.isBefore(s.checkInAt)) {
        throw Exception('A check-out cannot be before its check-in.');
      }
    }
  }

  @override
  Stream<List<AttendanceDay>> watchEmployeeAttendance({
    required String employeeEmail,
  }) =>
      watchDocuments(
        () => remote.watchIdPrefix(
          collectionPath,
          TimeTrackerFirestorePaths.attendancePrefix(employeeEmail),
        ),
      );

  /// QA KP-TT-015 (9/10/2026): one day, live — an id range that holds only
  /// that document (`{email}_{yyyy-MM-dd}`), so no new data-source call.
  @override
  Stream<AttendanceDay?> watchDay({
    required String employeeEmail,
    required DateTime date,
  }) {
    final String id;
    try {
      id = _docId(employeeEmail, date);
    } catch (error) {
      return Stream<AttendanceDay?>.error(error);
    }
    return watchDocuments(() => remote.watchIdPrefix(collectionPath, id)).map(
      (List<AttendanceDay> days) {
        for (final AttendanceDay d in days) {
          if (d.id == id) return d;
        }
        return null;
      },
    );
  }

  @override
  Future<AttendanceDay?> fetchDay({
    required String employeeEmail,
    required DateTime date,
  }) async =>
      fetchOne(_docId(employeeEmail, date));

  @override
  Future<AttendanceDay> saveDay({required AttendanceDay day}) async =>
      write(day, id: _docId(day.employeeEmail, day.date), mustExist: false);

  @override
  Future<AttendanceDay> updateDay({
    required String employeeEmail,
    required DateTime date,
    required AttendanceDay Function(AttendanceDay? stored) change,
  }) async {
    final String id = _docId(employeeEmail, date);
    final String by = actor();
    try {
      final TimeTrackerDocument doc = await remote.appendRow(
        relativePath: collectionPath,
        id: id,
        mustExist: false,
        row: (String docId, Map<String, dynamic>? stored) {
          final AttendanceDay next =
              change(stored == null ? null : decode(TimeTrackerDocument(id: docId, data: stored)));
          validate(next);
          return encode(
            next,
            id: docId,
            audit: TimeTrackerAudit.next(stored, actor: by, now: DateTime.now()),
          );
        },
      );
      return decode(doc);
    } catch (error) {
      throw clean(error, 'save the $entityLabel');
    }
  }

  @override
  Future<bool> createDayIfAbsent({required AttendanceDay day}) async =>
      createOnly(day, id: _docId(day.employeeEmail, day.date));

  @override
  Future<AttendanceCorrectionHistory?> fetchCorrectionHistory({
    required String employeeEmail,
    required DateTime date,
    required String requestId,
  }) async {
    final String id = _docId(employeeEmail, date);
    try {
      final TimeTrackerDocument? doc = await remote.fetchDocument(collectionPath, id);
      if (doc == null || requestId.trim().isEmpty) return null;
      return AttendanceDayModel.correctionHistory(doc.id, doc.data, requestId);
    } catch (error) {
      throw clean(error, 'load the $entityLabel');
    }
  }

  String _docId(String email, DateTime date) =>
      keyOf(() => TimeTrackerFirestorePaths.attendanceDocId(email, date));
}
