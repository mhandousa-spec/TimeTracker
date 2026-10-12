/// Module: time_tracker / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_range.dart
/// Purpose: Declares `DashboardRange` (the Personal Dashboard's "Time" menu:
///          Day · Week · Month · Year · Custom) and `DateSpan` (the closed
///          range of days it covers).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:35168` (menu) + `661:35259` (custom date selector with Apply).
/// Meanings (phase-2 assumption, STATUS.md): Day = today; Week = the last 7
/// days including today; Month = the current calendar month; Year = the
/// current calendar year (the default — the Late History chart is by month);
/// Custom = the picked range.

enum DashboardRange { day, week, month, year, custom }

/// A closed range of calendar days (local midnights, both ends included).
class DateSpan {
  DateSpan(DateTime first, DateTime last)
      : first = DateTime(first.year, first.month, first.day),
        last = DateTime(last.year, last.month, last.day);

  final DateTime first;
  final DateTime last;

  /// Whether [moment] falls on a day inside the span.
  bool contains(DateTime moment) {
    final DateTime d = DateTime(moment.year, moment.month, moment.day);
    return !d.isBefore(first) && !d.isAfter(last);
  }

  /// Function Name: [of]
  ///
  /// Purpose: The span [range] covers at [now] ([custom] for Custom).
  ///
  /// Return type: [DateSpan]
  static DateSpan of(DashboardRange range, DateTime now, {DateSpan? custom}) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case DashboardRange.day:
        return DateSpan(today, today);
      case DashboardRange.week:
        return DateSpan(DateTime(now.year, now.month, now.day - 6), today);
      case DashboardRange.month:
        return DateSpan(
          DateTime(now.year, now.month),
          DateTime(now.year, now.month + 1, 0),
        );
      case DashboardRange.year:
        return DateSpan(DateTime(now.year), DateTime(now.year, 12, 31));
      case DashboardRange.custom:
        return custom ?? DateSpan(today, today);
    }
  }
}
