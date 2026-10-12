/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: week_view.dart
/// Purpose: Week strip.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

class WeekView extends StatelessWidget {
  WeekView({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.lineHeight,
    this.highlightMonth,
    this.onChanged,
    this.events,
    required this.innerDot,
    required this.keepLineSize,
    this.textStyle,
    this.selectedDayColor,
    this.selectedDayTextColor,
  }) : super(key: key);

  final DateTime todayDate = DateTime.now().toZeroTime();
  final List<DateTime> dates;
  final double lineHeight;
  final int? highlightMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onChanged;
  final dynamic events;
  final bool innerDot;
  final bool keepLineSize;
  final TextStyle? textStyle;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  // ✅ Helper method to convert numbers to Arabic-Indic numerals
  String _toArabicNumber(int number, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!isArabic) return number.toString();

    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return int.tryParse(digit) != null ? arabicNumbers[int.parse(digit)] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: lineHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        // CHANGED 13/9/2026 — was a hardcoded 7. The DAY strip now hands this
        // widget five consecutive days per page; the MONTH grid still hands it
        // a seven-date week, so it reads the length rather than assuming one.
        children: List<Widget>.generate(
          dates.length,
              (dayIndex) {
            final date = dates[dayIndex];
            final isToday = date.isAtSameMomentAs(todayDate);
            final isSelected = date.isAtSameMomentAs(selectedDate);
            final isHighlight = highlightMonth == date.month;

            // CHANGED 23/8/2026: days belonging to the previous or next month
            // are no longer drawn at all. They used to render dimmed —
            // `AppColors.colorBlack.withOpacity(0.25)` in the keepLineSize
            // branch, `0.6` in the other — which put a row of greyed 26..31 on
            // top of the grid and 1..5 under it, and those cells were still
            // tappable, so tapping one silently jumped the selection into
            // another month.
            //
            // The cell is still emitted, just empty: the row lays its seven
            // children out with `MainAxisAlignment.spaceAround`, so returning
            // a narrower widget (or nothing) would shift every remaining day
            // out of its column. Same width in, blank content.
            //
            // Guarded on `highlightMonth != null` because `WeekView` is also
            // used for the week strip, which passes no month and must keep
            // showing every day it holds.
            if (highlightMonth != null && !isHighlight) {
              return keepLineSize
                  ? const Expanded(child: SizedBox.shrink())
                  : SizedBox(width: innerDot ? 32 : 24);
            }

            // Get events for this date with support for custom event objects
            List<dynamic> dateEvents = [];
            if (events != null) {
              if (events is List<DateTime>) {
                dateEvents = (events as List<DateTime>)
                    .where((element) => element.isSameDate(date))
                    .toList();
              } else if (events is List) {
                dateEvents = (events as List)
                    .where((element) {
                  if (element is Map && element['date'] != null) {
                    final eventDate = element['date'] as DateTime;
                    return eventDate.isSameDate(date);
                  } else if (element is DateTime) {
                    return element.isSameDate(date);
                  }
                  return false;
                })
                    .toList();
              }
            }
            final hasEvent = dateEvents.isNotEmpty;

            if (keepLineSize) {
              return Expanded(
                child: InkResponse(
                  onTap: onChanged != null ? () => onChanged!(date) : null,
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (selectedDayColor ?? theme.primaryColor)
                          : isToday
                          ? AppColors.primary
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _toArabicNumber(date.day, context), // ✅ CHANGED: Use Arabic numbers
                          style: textStyle?.copyWith(
                            fontSize: 16,
                            color: isSelected
                                ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                                : isToday
                                ? AppColors.textButton
                                : isHighlight || highlightMonth == null
                                ? AppColors.colorBlack
                                : AppColors.colorBlack.withOpacity(0.25),
                            fontWeight:
                            isSelected && textStyle?.fontWeight != null
                                ? FontWeight
                                .values[textStyle!.fontWeight!.index + 2]
                                : FontWeight.w500,
                          ),
                        ),
                        // Same always-emit rule as the branch below: one dot
                        // row's height (2px pad + a 2px dot) is reserved
                        // whether or not the day has events, so the number
                        // does not shift.
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 4),
                          child: hasEvent
                          ? Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: SizedBox(
                              width: 28,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 2,
                                runSpacing: 1,
                                children: List.generate(
                                  dateEvents.length,
                                      (index) {
                                    Color dotColor = isSelected
                                        ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                                        : theme.colorScheme.secondary;

                                    if (dateEvents[index] is Map &&
                                        dateEvents[index]['color'] != null) {
                                      dotColor = dateEvents[index]['color'] as Color;
                                    }

                                    return Container(
                                      height: 2,
                                      width: 2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(1),
                                        color: dotColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                          : const SizedBox(width: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DateBox(
                  width: innerDot ? 32 : 24,
                  height: innerDot ? 32 : 24,
                  showDot: innerDot,
                  onPressed: onChanged != null ? () => onChanged!(date) : null,
                  isSelected: isSelected,
                  isToday: isToday,
                  hasEvent: hasEvent,
                  selectedDayColor: selectedDayColor,
                  selectedDayTextColor: selectedDayTextColor,
                  child: Text(
                    _toArabicNumber(date.day, context), // ✅ CHANGED: Use Arabic numbers
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (selectedDayTextColor ?? theme.colorScheme.onPrimary)
                          : isToday
                          ? AppColors.textButton
                          : isHighlight || highlightMonth == null
                          ? AppColors.text
                          : AppColors.colorBlack.withOpacity(0.6),
                    ),
                  ),
                ),
                // FIXED 13/9/2026 — the dot row is ALWAYS emitted, with a
                // floor of exactly one dot row's height.
                //
                // THIS is what made days with events sit higher than days
                // without, not DateBox: `showDot` here is `innerDot`, which is
                // false for the month grid, so DateBox never draws a dot at
                // all — this Column does. It is `spaceEvenly`, so a day with
                // an event had TWO children and a day without had ONE, and the
                // Column shrink-wraps: 24px tall against 32px. Centred in the
                // row, that lifts the number by 4px.
                //
                // minHeight 8 = the 2px top pad + a 6px dot, so a day with no
                // events reserves exactly what a day with one row of dots
                // occupies and every number in the row lands on one baseline.
                // A day with enough events to wrap onto a second row still
                // grows, as it always did.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 8),
                  child: (!innerDot && hasEvent)
                  ? Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 28,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 1,
                        children: List.generate(
                          dateEvents.length,
                              (index) {
                            Color dotColor = theme.primaryColor;

                            if (dateEvents[index] is Map &&
                                dateEvents[index]['color'] != null) {
                              dotColor = dateEvents[index]['color'] as Color;
                            }

                            return Container(
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(1),
                                color: dotColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                  // Same footprint, no dots.
                  : const SizedBox(width: 28),
                ),
              ],
            );
          },
          growable: false,
        ),
      ),
    );
  }
}