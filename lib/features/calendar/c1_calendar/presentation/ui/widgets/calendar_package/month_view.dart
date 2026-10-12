/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: month_view.dart
/// Purpose: Month grid.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

class MonthView extends StatelessWidget {
  const MonthView({
    Key? key,
    required this.monthView,
    required this.todayDate,
    required this.selectedDate,
    required this.weekLineHeight,
    required this.weeksAmount,
    required this.innerDot,
    this.onChanged,
    this.events,
    required this.keepLineSize,
    this.textStyle,
    this.selectedDayColor,
    this.selectedDayTextColor,
  }) : super(key: key);

  final ViewRange monthView;
  final DateTime? todayDate;
  final DateTime selectedDate;
  final double weekLineHeight;
  final int weeksAmount;
  final ValueChanged<DateTime>? onChanged;
  final dynamic events;
  final bool innerDot;
  final bool keepLineSize;
  final TextStyle? textStyle;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  @override
  Widget build(BuildContext context) {
    // Only the rows this month occupies — see ViewRange.weeksUsed. `6` was
    // hardcoded here while the height below used `weeksAmount`, so the two
    // disagreed and short months ended in an empty row.
    final int rows = monthView.weeksUsed;

    final index = selectedDate.findWeekIndex(monthView.dates);
    // Guard the divisor: a one-row month is impossible in a Gregorian
    // calendar, but 0 here would be an infinity, not an exception.
    final offset = rows > 1 ? index / (rows - 1) * 2 - 1.0 : 0.0;

    return OverflowBox(
      alignment: Alignment(0, offset),
      minHeight: weekLineHeight,
      maxHeight: weekLineHeight * rows,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(
          rows,
              (weekIndex) {
            final weekStart = weekIndex * 7;

            return WeekView(
              innerDot: innerDot,
              dates: monthView.dates.sublist(weekStart, weekStart + 7),
              selectedDate: selectedDate,
              highlightMonth: monthView.firstDay.month,
              lineHeight: weekLineHeight,
              onChanged: onChanged,
              events: events,
              keepLineSize: keepLineSize,
              textStyle: textStyle,
              selectedDayColor: selectedDayColor,
              selectedDayTextColor: selectedDayTextColor,
            );
          },
          growable: false,
        ),
      ),
    );
  }
}