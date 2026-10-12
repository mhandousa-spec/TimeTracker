/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: week_days.dart
/// Purpose: Weekday header row.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

/// Week day names line.
class WeekDays extends StatelessWidget {
  const WeekDays({
    Key? key,
    this.weekNames = const <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.dates,
    this.style,
    required this.keepLineSize,
  })  : assert(dates != null || weekNames.length == 7,
            '`weekNames` must have length 7'),
        super(key: key);

  /// Week day names. Used when [dates] is null — i.e. MONTH mode, where the
  /// seven columns are the same weekdays every row.
  final List<String> weekNames;

  /// ADDED 13/9/2026. The exact dates the row below is showing, in DAY mode.
  ///
  /// The day strip pages five CONSECUTIVE days rather than a calendar week,
  /// so which weekdays are on screen changes as you swipe and a fixed
  /// Sun..Sat list would label the wrong columns. When this is set the header
  /// derives its names — and its COLUMN COUNT — from these dates instead.
  final List<DateTime>? dates;

  /// Text style.
  final TextStyle? style;

  final bool keepLineSize;

  /// Get abbreviated day name based on available width
  String _getAbbreviatedName(String fullName, bool isArabic, bool useShort) {
    if (!useShort) return fullName;

    if (isArabic) {
      // Arabic single letter abbreviations
      final arabicShortNames = {
        'الأحد': 'ح',
        'الاثنين': 'ن',
        'الثلاثاء': 'ث',
        'الأربعاء': 'ع',
        'الخميس': 'خ',
        'الجمعة': 'ج',
        'السبت': 'س',
      };
      return arabicShortNames[fullName] ?? fullName.substring(0, 1);
    } else {
      // English 3-letter abbreviations
      return fullName.length > 3 ? fullName.substring(0, 3) : fullName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should use short names based on available width
        final bool useShortNames = constraints.maxWidth < 350;

        // Check if current locale is Arabic
        final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

        final List<String> names = dates != null
            ? dates!
                .map((DateTime date) => DateFormat(
                      'EEE',
                      Localizations.localeOf(context).toString(),
                    ).format(date))
                .toList(growable: false)
            : weekNames;

        return DefaultTextStyle(
          style: style!,
          child: Padding(
            // SPACING 24/8/2026: was `EdgeInsets.only(top: 12.sp)`. That gap
            // existed only at the top, which is exactly what made the card
            // look unbalanced — 12sp above the weekday names, nothing at the
            // sides or under the last week. The space now comes from
            // `AdvancedCalendar.contentPadding`, which applies equally to all
            // four sides.
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(names.length, (index) {
                return Expanded(
                  child: Center(
                    child: Text(
                      _getAbbreviatedName(names[index], isArabic, useShortNames),
                      style: style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
