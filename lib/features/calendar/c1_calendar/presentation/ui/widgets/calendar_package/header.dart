/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: header.dart
/// Purpose: Month/year header.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.monthDate,
    this.margin = const EdgeInsets.only(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: 0.0,
    ),
    this.onPressed,
    this.dateStyle,
    this.todayStyle,
    this.child,
    this.onPrevMonth,
    this.onNextMonth,
    this.showArrows = false,
    this.arrowColor, // ✅ NEW: Arrow color parameter
  }) : super(key: key);

  final DateTime monthDate;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onPressed;
  final TextStyle? dateStyle;
  final TextStyle? todayStyle;
  final Widget? child;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final bool showArrows;
  final Color? arrowColor; // ✅ NEW

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ LEFT: Month/Year Text
          // Text(
          //   style: dateStyle ?? theme.textTheme.titleMedium?.copyWith(
          //     fontWeight: FontWeight.w600,
          //     fontSize: 16,
          //   ),
          // ),

          const Spacer(),

          // ✅ RIGHT: Navigation Arrows
          if (showArrows)
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: arrowColor ?? theme.iconTheme.color,
                  ),
                  onPressed: onPrevMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: arrowColor ?? theme.iconTheme.color,
                  ),
                  onPressed: onNextMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),

        ],
      ),
    );
  }
}