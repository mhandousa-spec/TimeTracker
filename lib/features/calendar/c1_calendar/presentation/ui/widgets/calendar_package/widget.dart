/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: widget.dart
/// Purpose: The calendar widget itself.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_package/controller.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_package/datetime_util.dart';

part './date_box.dart';
part './handlebar.dart';
part './header.dart';
part './month_view.dart';
part './month_view_bean.dart';
part './week_days.dart';
part './week_view.dart';

enum CalendarViewMode {
  day,
  month,
}

class AdvancedCalendar extends StatefulWidget {
  const AdvancedCalendar({
    Key? key,
    this.controller,
    this.startWeekDay,
    this.events,
    this.weekLineHeight = 32.0,
    this.preloadMonthViewAmount = 13,
    this.preloadWeekViewAmount = 21,
    this.daysPerStripPage = 5,
    this.dayStripLineHeight,
    this.weeksInMonthViewAmount = 6,
    this.todayStyle,
    this.headerStyle,
    this.onHorizontalDrag,
    this.backgroundColorCalender,
    this.innerDot = false,
    this.keepLineSize = false,
    this.calendarTextStyle,
    this.navigationArrowColor,
    this.showNavigationArrows = false,
    this.viewMode = CalendarViewMode.month,
    this.selectedDayColor,
    this.selectedDayTextColor,
    this.contentPadding = EdgeInsets.zero,
  })  : assert(
  keepLineSize && innerDot ||
      innerDot && !keepLineSize ||
      !innerDot && !keepLineSize,
  'keepLineSize should be used only when innerDot is true',
  ),
        super(key: key);

  final AdvancedCalendarController? controller;
  final Function(DateTime)? onHorizontalDrag;
  final double weekLineHeight;
  final int preloadMonthViewAmount;
  final int preloadWeekViewAmount;

  /// How many day columns the DAY-mode strip shows at once.
  ///
  /// ADDED 13/9/2026. The strip used to be one calendar week per page: seven
  /// columns squeezed into the card, which on a phone-width window left each
  /// day about 55px and the numbers crowded against their neighbours. Five
  /// columns give each day a readable slot; the remaining days of the week are
  /// one swipe away, and pages are contiguous so swiping never skips or
  /// repeats a date.
  ///
  /// MONTH mode is untouched — a month grid is seven columns by definition.
  final int daysPerStripPage;

  /// Row height for the DAY strip only. Defaults to [weekLineHeight].
  ///
  /// ADDED 13/9/2026. A month row has to be tall enough to separate six
  /// stacked weeks, and [weekLineHeight] is sized for that. The day strip is a
  /// single row, and at the same height its contents — a 24px date box plus
  /// one 8px dot row — left a third of the strip as empty card below the
  /// numbers. This lets the day strip be as tall as it actually needs without
  /// tightening the month grid.
  final double? dayStripLineHeight;

  /// [dayStripLineHeight] if given, else [weekLineHeight].
  double get effectiveDayStripLineHeight =>
      dayStripLineHeight ?? weekLineHeight;
  final int weeksInMonthViewAmount;
  final dynamic events;
  final int? startWeekDay;
  final TextStyle? headerStyle;
  final TextStyle? todayStyle;
  final bool innerDot;
  final Color? backgroundColorCalender;
  final bool keepLineSize;
  final TextStyle? calendarTextStyle;
  final bool showNavigationArrows;
  final Color? navigationArrowColor;
  final CalendarViewMode viewMode;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  /// SPACING 24/8/2026 — the calendar used to sit flush against its own
  /// background: the weekday row and the day numbers touched the left and
  /// right edges and the last week touched the bottom, while the only
  /// breathing space was the 12sp `WeekDays` gave the top. That reads as an
  /// unbalanced card.
  ///
  /// The padding is a parameter rather than a hardcoded value because the two
  /// callers differ: the home card wraps the calendar in its own padded
  /// `Container` (so it stays at zero), while the calendar screen lets the
  /// widget paint its own card and passes `EdgeInsets.all(...)` here.
  ///
  /// Pass ONE value for all four sides (`EdgeInsets.all`), and size it with
  /// `.sp` — `15.w` and `15.h` are different pixel counts under ScreenUtil,
  /// so `symmetric(horizontal: 15.w, vertical: 15.h)` is NOT square.
  ///
  /// TWO THINGS THAT WERE TRIED AND REVERTED, so they are not tried again:
  ///
  /// 1. Matching the top and bottom to the side gap by MEASURING it. The seven
  ///    day columns are equal `Expanded`s that centre their contents, so the
  ///    side gap is roughly `(columnWidth - cellWidth) / 2` — around 50px on a
  ///    desktop window. Copying that onto the vertical axis made the card far
  ///    too tall, the day view worst of all.
  ///
  /// 2. Pinning the FIRST column's content to the start and the LAST one's to
  ///    the end, to close that side gap. It works, but the weekday labels are
  ///    not all the same width, so aligning the outer two to the edges makes
  ///    the spacing BETWEEN columns visibly uneven — one gap small, the next
  ///    large. Equal separation matters more than a tight edge.
  ///
  /// So: all seven columns stay equal width with their contents centred. The
  /// side gap is wider than [contentPadding] because of that centring, and that
  /// is accepted.
  final EdgeInsetsGeometry contentPadding;

  @override
  _AdvancedCalendarState createState() => _AdvancedCalendarState();
}

class _AdvancedCalendarState extends State<AdvancedCalendar>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<int> _monthViewCurrentPage;
  late AnimationController _animationController;
  late AdvancedCalendarController _controller;
  late List<ViewRange> _monthRangeList;
  late List<List<DateTime>> _dayStripList;
  late ValueNotifier<int> _weekViewCurrentPage;

  PageController? _monthPageController;
  PageController? _weekPageController;
  DateTime? _todayDate;
  List<String>? _weekNames;

  @override
  void initState() {
    super.initState();

    final monthPageIndex = widget.preloadMonthViewAmount ~/ 2;
    _monthViewCurrentPage = ValueNotifier(monthPageIndex);
    _monthPageController = PageController(initialPage: monthPageIndex);

    final weekPageIndex = widget.preloadWeekViewAmount ~/ 2;
    _weekPageController = PageController(initialPage: weekPageIndex);
    _weekViewCurrentPage = ValueNotifier(weekPageIndex);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0,
    );


    _controller = widget.controller ?? AdvancedCalendarController.today();
    _todayDate = _controller.value;

    _monthRangeList = List.generate(
      widget.preloadMonthViewAmount,
          (index) => ViewRange.generateDates(
        _todayDate!,
        _todayDate!.month + (index - _monthPageController!.initialPage),
        widget.weeksInMonthViewAmount,
        startWeekDay: widget.startWeekDay,
      ),
    );

    // CHANGED 13/9/2026 — `generateWeeks` produced one seven-day calendar
    // week per page. The strip now pages `daysPerStripPage` consecutive days
    // at a time, re-centred on the selection, which is what lets five columns
    // fill the card instead of seven.
    _dayStripList = _controller.value.generateDayStrips(
      widget.preloadWeekViewAmount,
      widget.daysPerStripPage,
    );

    _controller.addListener(() {
      _dayStripList = _controller.value.generateDayStrips(
        widget.preloadWeekViewAmount,
        widget.daysPerStripPage,
      );
      _weekViewCurrentPage.value = widget.preloadWeekViewAmount ~/ 2;
      if (_weekPageController != null && _weekPageController!.hasClients) {
        _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
      }
    });

    if (widget.startWeekDay != null && widget.startWeekDay! < 7) {
      final time = _controller.value.subtract(
        Duration(days: _controller.value.weekday - widget.startWeekDay!),
      );
      final list = List<DateTime>.generate(
        8,
            (index) => time.add(Duration(days: index * 1)),
      ).toList();
      _weekNames = List<String>.generate(7, (index) {
        return DateFormat("EEE").format(list[index]); // ✅ NEW: First 3 characters (Sun, Mon, Tue, etc.)
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animationController.value = widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: widget.backgroundColorCalender,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium,
          child: Padding(
            padding: widget.contentPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: _monthViewCurrentPage,
                  builder: (_, value, __) {
                    return Header(
                      monthDate: _monthRangeList[_monthViewCurrentPage.value].firstDay,
                      onPressed: _handleTodayPressed,
                      dateStyle: widget.headerStyle,
                      todayStyle: widget.todayStyle,
                      showArrows: widget.showNavigationArrows,
                      onPrevMonth: _handlePrevPressed,
                      onNextMonth: _handleNextPressed,
                      arrowColor: widget.navigationArrowColor,
                    );
                  },
                ),
                // CHANGED 13/9/2026 — in DAY mode the header follows the
                // strip page. The strip no longer shows a calendar week, so a
                // fixed Sun..Sat list would label the wrong columns: page on
                // and "Mon Tue Wed Thu Fri" has to become "Sat Sun Mon Tue
                // Wed". Month mode keeps the static list.
                //
                // Rebuilding the header here — rather than moving the names
                // into each day cell — keeps it in its own row above the
                // numbers, so switching between month and day does not change
                // the card's height.
                //
                // It listens to BOTH the page index and the controller:
                // selecting a day rebuilds `_dayStripList` around the new date
                // and jumps back to the middle page, so the index alone can
                // come out unchanged and a lone ValueNotifier on it would
                // never fire — leaving the header labelling the old dates.
                ValueListenableBuilder<DateTime>(
                  valueListenable: _controller,
                  builder: (_, __, ___) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _weekViewCurrentPage,
                      builder: (_, int stripPage, __) {
                        final List<DateTime>? stripDates =
                            widget.viewMode == CalendarViewMode.day &&
                                    stripPage >= 0 &&
                                    stripPage < _dayStripList.length
                                ? _dayStripList[stripPage]
                                : null;
                        return WeekDays(
                            dates: stripDates,
                            // CHANGED 23/8/2026: was `theme.hintColor`, which rendered the
                            // Sun/Mon/Tue row noticeably greyer than the day numbers under
                            // it. `WeekView` paints an in-month day number with
                            // `AppColors.colorBlack`, so the header now uses the same
                            // colour and the two rows read as one block.
                            //
                            // The colour is chosen here rather than inside `WeekDays`
                            // deliberately: `WeekDays` renders whatever `style` it is
                            // handed, and overriding the caller's colour inside it would
                            // make that parameter a lie.
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500
                            ),
                            keepLineSize: widget.keepLineSize,
                            weekNames: _weekNames != null
                                ? _weekNames!
                                : const <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'],
                        );
                      },
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, __) {
                    // CHANGED 13/9/2026 — the month grid is as tall as the
                    // CURRENT month needs, not a fixed six rows.
                    //
                    // `weeksInMonthViewAmount` is 6 and the SizedBox used it
                    // unconditionally, so a five-row month (September 2026)
                    // reserved a sixth row of empty space below the last week.
                    // Rebuilt on page change so the height follows as you
                    // swipe between months, and it stays in step with the row
                    // count MonthView renders because both read the same
                    // ViewRange.weeksUsed.
                    return ValueListenableBuilder<int>(
                      valueListenable: _monthViewCurrentPage,
                      builder: (_, monthPageIndex, __) {
                        final int weeksUsed = monthPageIndex >= 0 &&
                                monthPageIndex < _monthRangeList.length
                            ? _monthRangeList[monthPageIndex].weeksUsed
                            : widget.weeksInMonthViewAmount;

                        final height = widget.viewMode == CalendarViewMode.day
                            ? widget.effectiveDayStripLineHeight
                            : widget.weekLineHeight * weeksUsed;

                        return SizedBox(
                      height: height,
                      child: ValueListenableBuilder<DateTime>(
                        valueListenable: _controller,
                        builder: (_, selectedDate, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              IgnorePointer(
                                ignoring: widget.viewMode == CalendarViewMode.day,
                                child: Opacity(
                                  opacity: widget.viewMode == CalendarViewMode.month ? 1.0 : 0.0,
                                  child: PageView.builder(
                                    onPageChanged: (pageIndex) {
                                      if (widget.onHorizontalDrag != null) {
                                        widget.onHorizontalDrag!(_monthRangeList[pageIndex].firstDay);
                                      }
                                      _monthViewCurrentPage.value = pageIndex;
                                    },
                                    controller: _monthPageController,
                                    physics: widget.viewMode == CalendarViewMode.month
                                        ? const AlwaysScrollableScrollPhysics()
                                        : const NeverScrollableScrollPhysics(),
                                    itemCount: _monthRangeList.length,
                                    itemBuilder: (_, pageIndex) {
                                      return MonthView(
                                        innerDot: widget.innerDot,
                                        monthView: _monthRangeList[pageIndex],
                                        todayDate: _todayDate,
                                        selectedDate: selectedDate,
                                        weekLineHeight: widget.weekLineHeight,
                                        weeksAmount: widget.weeksInMonthViewAmount,
                                        onChanged: _handleDateChanged,
                                        events: widget.events,
                                        keepLineSize: widget.keepLineSize,
                                        textStyle: widget.calendarTextStyle,
                                        selectedDayColor: widget.selectedDayColor,
                                        selectedDayTextColor: widget.selectedDayTextColor,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: _monthViewCurrentPage,
                                builder: (_, pageIndex, __) {
                                  final offset = widget.viewMode == CalendarViewMode.day
                                      ? 0.0
                                      : () {
                                    final index = selectedDate.findWeekIndex(
                                      _monthRangeList[_monthViewCurrentPage.value].dates,
                                    );
                                    // Same divisor as MonthView's own offset
                                    // (ViewRange.weeksUsed), so the day-mode
                                    // row lines up with the month row it
                                    // slides out of.
                                    final int rows = _monthRangeList[
                                            _monthViewCurrentPage.value]
                                        .weeksUsed;
                                    return rows > 1
                                        ? index / (rows - 1) * 2 - 1.0
                                        : 0.0;
                                  }();

                                  return Align(
                                    alignment: Alignment(0.0, offset),
                                    child: IgnorePointer(
                                      ignoring: widget.viewMode == CalendarViewMode.month,
                                      child: Opacity(
                                        opacity: widget.viewMode == CalendarViewMode.day ? 1.0 : 0.0,
                                        child: SizedBox(
                                          height: widget
                                              .effectiveDayStripLineHeight,

                                          child: PageView.builder(
                                            onPageChanged: (indexPage) {
                                              _weekViewCurrentPage.value =
                                                  indexPage;

                                              final pageIndex = _monthRangeList.indexWhere(
                                                    (index) => index.firstDay.month == _dayStripList[indexPage].first.month,
                                              );

                                              // GUARD 13/9/2026 — a five-day
                                              // page can walk past the far end
                                              // of the preloaded months, and
                                              // indexWhere answers -1 there.
                                              // Indexing on that threw.
                                              if (pageIndex < 0) return;

                                              if (widget.onHorizontalDrag != null) {
                                                widget.onHorizontalDrag!(_monthRangeList[pageIndex].firstDay);
                                              }
                                              _monthViewCurrentPage.value = pageIndex;
                                            },
                                            controller: _weekPageController,
                                            itemCount: _dayStripList.length,
                                            physics: widget.viewMode == CalendarViewMode.day
                                                ? const AlwaysScrollableScrollPhysics()
                                                : const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return WeekView(
                                                innerDot: widget.innerDot,
                                                dates: _dayStripList[index],
                                                selectedDate: selectedDate,
                                                lineHeight: widget
                                                    .effectiveDayStripLineHeight,
                                                onChanged: _handleWeekDateChanged,
                                                events: widget.events,
                                                keepLineSize: widget.keepLineSize,
                                                textStyle: widget.calendarTextStyle,
                                                selectedDayColor: widget.selectedDayColor,
                                                selectedDayTextColor: widget.selectedDayTextColor,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _monthPageController!.dispose();
    _monthViewCurrentPage.dispose();
    _weekViewCurrentPage.dispose();

    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _handleWeekDateChanged(DateTime date) {
    _handleDateChanged(date);
    _monthViewCurrentPage.value = _monthRangeList
        .lastIndexWhere((monthRange) => monthRange.dates.contains(date));
  }

  void _handleDateChanged(DateTime date) {
    _controller.value = date;
  }

  void _handleTodayPressed() {
    _controller.value = DateTime.now().toZeroTime();
    _monthPageController!.jumpToPage(widget.preloadMonthViewAmount ~/ 2);
    _weekPageController!.jumpToPage(widget.preloadWeekViewAmount ~/ 2);
    _weekViewCurrentPage.value = widget.preloadWeekViewAmount ~/ 2;
  }

  void _handlePrevPressed() {
    final isMonthView = widget.viewMode == CalendarViewMode.month;

    if (isMonthView) {
      _monthPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextPressed() {
    final isMonthView = widget.viewMode == CalendarViewMode.month;

    if (isMonthView) {
      _monthPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _weekPageController!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}