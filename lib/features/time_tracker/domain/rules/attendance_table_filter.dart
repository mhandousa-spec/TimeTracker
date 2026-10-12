/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: attendance_table_filter.dart
/// Purpose: Declares `AttendanceFilter` (the Attendance tab's filter popup:
///          Status · Date range · Work Location Type) and `AttendanceTable`
///          (filtering, search, sorting and the status tile counts).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma Attendance `661:14182` + filter popup `661:17294`. Phase-2 reading
/// of the popup (STATUS.md): Status = the day's attendance status; Type =
/// where the employee worked (Office / Remote / Client Site — any session);
/// Day = weekday; Total Time = at least N hours worked. Rows are newest
/// first. Tile counts (Present / Absent / Late / Vacation / Sick Leave /
/// Excuse Leave) are over ALL the employee's days; Present includes late
/// days (an attended day), Late counts them again on their own tile.
///
/// Pure Dart — unit-tested.
/// Updated: 9/10/2026 - UI quality pass (owner finding 13:45 #3): the filter
/// is Status · From – To · Work Location Type ("Day" and "Total Time" are
/// gone; a single day is `AttendanceFilter.day`).

import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

class AttendanceFilter {
  const AttendanceFilter({
    this.status,
    this.type,
    this.from,
    this.to,
  });

  /// One day only (the calendar's late / absent card deep link).
  factory AttendanceFilter.day(DateTime day) => AttendanceFilter(from: day, to: day);

  final AttendanceStatus? status;
  final WorkLocationType? type;

  /// Days from [from] to [to] (calendar days, both optional).
  final DateTime? from;
  final DateTime? to;

  static const AttendanceFilter none = AttendanceFilter();

  bool get isActive => status != null || type != null || from != null || to != null;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Function Name: [matches]
  ///
  /// Return type: [bool] — [day] passes every set criterion.
  bool matches(AttendanceDay day) {
    final DateTime d = _day(day.date);
    final DateTime? a = from;
    if (a != null && d.isBefore(_day(a))) return false;
    final DateTime? b = to;
    if (b != null && d.isAfter(_day(b))) return false;
    if (status != null && day.status != status) return false;
    final WorkLocationType? t = type;
    if (t != null &&
        !day.sessions.any((AttendanceSession s) => s.workLocationType == t)) {
      return false;
    }
    return true;
  }
}

class AttendanceTileCounts {
  const AttendanceTileCounts({
    this.present = 0,
    this.absent = 0,
    this.late = 0,
    this.vacation = 0,
    this.sickLeave = 0,
    this.excused = 0,
  });

  final int present;
  final int absent;
  final int late;
  final int vacation;
  final int sickLeave;
  final int excused;
}

class AttendanceTable {
  const AttendanceTable._();

  /// Function Name: [rows]
  ///
  /// Purpose: The days to show: [filter] applied, then [query] matched
  /// against [describe] (the row's visible text, built by the page in the
  /// user's language), newest first.
  ///
  /// Parameters:
  ///   [List<AttendanceDay>] days
  ///   [AttendanceFilter] filter
  ///   [String] query
  ///   [String Function(AttendanceDay)] describe
  ///
  /// Return type: [List<AttendanceDay>]
  static List<AttendanceDay> rows({
    required List<AttendanceDay> days,
    required AttendanceFilter filter,
    required String query,
    required String Function(AttendanceDay day) describe,
  }) {
    final String q = query.trim().toLowerCase();
    final List<AttendanceDay> out = days
        .where(filter.matches)
        .where((AttendanceDay d) =>
            q.isEmpty || describe(d).toLowerCase().contains(q))
        .toList()
      ..sort((AttendanceDay a, AttendanceDay b) => b.date.compareTo(a.date));
    return List<AttendanceDay>.unmodifiable(out);
  }

  /// Function Name: [tiles]
  ///
  /// Purpose: Count every status over [days].
  ///
  /// Return type: [AttendanceTileCounts]
  static AttendanceTileCounts tiles(List<AttendanceDay> days) {
    int present = 0, absent = 0, late = 0, vacation = 0, sick = 0, excused = 0;
    for (final AttendanceDay d in days) {
      switch (d.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          present++;
          late++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.vacation:
          vacation++;
        case AttendanceStatus.sickLeave:
          sick++;
        case AttendanceStatus.excused:
          excused++;
        case null:
          break;
      }
    }
    return AttendanceTileCounts(
      present: present,
      absent: absent,
      late: late,
      vacation: vacation,
      sickLeave: sick,
      excused: excused,
    );
  }
}
