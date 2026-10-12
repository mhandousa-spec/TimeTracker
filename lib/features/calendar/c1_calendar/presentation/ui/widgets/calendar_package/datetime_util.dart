/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: datetime_util.dart
/// Purpose: Date helpers.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

extension DateTimeUtil on DateTime {
  /// Generate a new DateTime instance with a zero time.
  DateTime toZeroTime() => DateTime.utc(year, month, day, 12);

  int findWeekIndex(List<DateTime> dates) {
    return dates.indexWhere(isAtSameMomentAs) ~/ 7;
  }

  /// Calculates first week date (Sunday) from this date.
  DateTime firstDayOfWeek({int? startWeekDay}) {
    final utcDate = DateTime.utc(year, month, day, 12);
    if (startWeekDay != null && startWeekDay < 7) {
      return utcDate.subtract(Duration(days: utcDate.weekday - startWeekDay));
    }
    return utcDate.subtract(Duration(days: utcDate.weekday % 7));
  }

  /// Generates 7 dates according to this date.
  /// (Supposed that this date is result of [firstDayOfWeek])
  List<DateTime> weekDates() {
    return List.generate(
      7,
      (index) => add(Duration(days: index)),
      growable: false,
    );
  }

  /// Generates list of list with [DateTime]
  /// according to [date] and [weeksAmount].
  /// gives the beginning of the day of the week [startWeekDay]
  List<List<DateTime>> generateWeeks(int weeksAmount, {int? startWeekDay}) {
    final firstViewDate = firstDayOfWeek(startWeekDay: startWeekDay).subtract(
      Duration(
        days: (weeksAmount ~/ 2) * 7,
      ),
    );

    return List.generate(
      weeksAmount,
      (weekIndex) {
        final firstDateOfNextWeek = firstViewDate.add(
          Duration(
            days: weekIndex * 7,
          ),
        );

        return firstDateOfNextWeek.weekDates();
      },
      growable: false,
    );
  }

  /// Generates [pagesAmount] pages of [daysPerPage] CONSECUTIVE days, with
  /// this date sitting in the middle page.
  ///
  /// ADDED 13/9/2026 for the day-mode strip, which shows five days per page
  /// rather than a whole week — see `AdvancedCalendar.daysPerStripPage`.
  /// [generateWeeks] cannot express that: a page there is always exactly the
  /// seven dates of one calendar week.
  ///
  /// Pages are contiguous, so paging forward from the last day of one page
  /// lands on the next day, never on a gap or a repeat. This date is placed at
  /// index `daysPerPage ~/ 2` of the middle page — centred for an odd page
  /// size, one past centre for an even one.
  ///
  /// All arithmetic is on [toZeroTime]'s UTC noon, so a DST boundary cannot
  /// shift a date by an hour and break the `isAtSameMomentAs` comparisons the
  /// strip uses to mark today and the selection.
  List<List<DateTime>> generateDayStrips(int pagesAmount, int daysPerPage) {
    final DateTime firstDateOfMiddlePage =
        toZeroTime().subtract(Duration(days: daysPerPage ~/ 2));
    final int middlePage = pagesAmount ~/ 2;

    return List<List<DateTime>>.generate(
      pagesAmount,
      (int pageIndex) {
        final DateTime firstDate = firstDateOfMiddlePage.add(
          Duration(days: (pageIndex - middlePage) * daysPerPage),
        );
        return List<DateTime>.generate(
          daysPerPage,
          (int index) => firstDate.add(Duration(days: index)),
          growable: false,
        );
      },
      growable: false,
    );
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
