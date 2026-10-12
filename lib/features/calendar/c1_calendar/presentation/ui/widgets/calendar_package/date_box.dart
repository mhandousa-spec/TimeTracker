/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: date_box.dart
/// Purpose: One day cell.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

/// Unit of calendar.
class DateBox extends StatelessWidget {
  const DateBox({
    Key? key,
    required this.child,
    this.color,
    this.width = 24.0,
    this.height = 24.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.onPressed,
    this.showDot = false,
    this.isSelected = false,
    this.isToday = false,
    this.hasEvent = false,
    this.selectedDayColor,
    this.selectedDayTextColor,
  }) : super(key: key);

  final Widget child;
  final Color? color;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final VoidCallback? onPressed;
  final bool showDot;
  final bool isToday;
  final bool isSelected;
  final bool hasEvent;
  final Color? selectedDayColor;
  final Color? selectedDayTextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnconstrainedBox(
      alignment: Alignment.center,
      child: InkResponse(
        onTap: onPressed,
        radius: 16.0,
        borderRadius: borderRadius,
        highlightShape: BoxShape.rectangle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          // No `alignment` any more: the Stack below is told to fill the box
          // (StackFit.expand), and a container alignment would shrink-wrap it
          // to the number instead, which is what `bottom` would then measure
          // against.
          decoration: BoxDecoration(
            color: isSelected
                ? (selectedDayColor ?? theme.primaryColor)
                : isToday
                ? AppColors.primary  // ✅ CHANGED: Use AppColors.primary instead of theme.highlightColor
                : null,
            borderRadius: borderRadius,
          ),
          // FIXED 13/9/2026 — Stack, not Column.
          //
          // Two bugs, one cause. The dot used to be a second child of a
          // CENTRED Column, added only `if (showDot && hasEvent)`: a day with
          // an event had two children and a day without had one, so centring
          // two items lifted the number by half the dot's height and a week
          // row came out ragged.
          //
          // Making the dot unconditional fixed the ragged row but broke the
          // box: number + 4px dot + 4px margin does not fit 24px, so every
          // cell overflowed by 7px.
          //
          // A Stack settles both. The number is centred in the box and stays
          // there whether or not there is a dot, and the dot is laid over the
          // bottom edge rather than stacked beneath — it takes no vertical
          // space, so nothing can overflow.
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: child),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Transparent rather than absent: an invisible dot keeps
                      // every cell identical, and costs nothing to paint.
                      color: (showDot && hasEvent)
                          ? (isSelected
                              ? (selectedDayTextColor ??
                                  theme.colorScheme.onPrimary)
                              : isToday
                                  ? AppColors.textButton
                                  : theme.colorScheme.secondary)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}