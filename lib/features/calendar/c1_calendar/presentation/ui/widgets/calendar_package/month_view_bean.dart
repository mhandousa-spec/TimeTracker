/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: month_view_bean.dart
/// Purpose: Month view data holder.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

class ViewRange {
  const ViewRange._(this.firstDay, this.dates);

  /// Creates custom filled [ViewRange] instance.
  const ViewRange.custom(
    DateTime firstDay,
    List<DateTime> dates,
  ) : this._(firstDay, dates);

  /// Generates [ViewRange] instance based on [date],
  /// number of [month] and [weeksAmount].
  /// gives the beginning of the day of the week [startWeekDay]
  factory ViewRange.generateDates(
    DateTime date,
    int month,
    int weeksAmount, {
    int? startWeekDay,
  }) {
    final firstMonthDate = DateTime.utc(date.year, month, 1);
    final firstViewDate =
        firstMonthDate.firstDayOfWeek(startWeekDay: startWeekDay);

    return ViewRange._(
      firstMonthDate,
      List.generate(
        weeksAmount * 7,
        (index) => firstViewDate.add(Duration(days: index)),
        growable: false,
      ),
    );
  }

  /// Month view index.
  final DateTime firstDay;

  /// Month view dates.
  final List<DateTime> dates;

  /// How many week rows this month actually occupies (4-6).
  ///
  /// ADDED 13/9/2026. [dates] is always `weeksAmount * 7` = 42 entries, and
  /// the grid rendered all six rows for every month. A month like September
  /// 2026 needs five, so the sixth came out as a blank strip of dead space
  /// under the last week.
  ///
  /// The view starts at the first day of the week containing the 1st, so every
  /// in-month date is contiguous from row 0 — the answer is simply which row
  /// the last in-month date falls in.
  int get weeksUsed {
    int lastRow = 0;
    for (int i = 0; i < dates.length; i++) {
      if (dates[i].month == firstDay.month && dates[i].year == firstDay.year) {
        lastRow = i ~/ 7;
      }
    }
    return lastRow + 1;
  }
}
