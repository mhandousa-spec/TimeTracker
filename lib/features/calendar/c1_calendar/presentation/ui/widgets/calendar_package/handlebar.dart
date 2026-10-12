/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: handlebar.dart
/// Purpose: Drag handle between month and week modes.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

part of './widget.dart';

class HandleBar extends StatelessWidget {
  const HandleBar({
    Key? key,
    this.decoration,
    this.margin = const EdgeInsets.only(
      top: 8.0,
    ),
    this.onPressed,
  }) : super(key: key);

  final BoxDecoration? decoration;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: margin,
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.1,
          child: Container(
            height: 4.0,
            decoration: decoration ??
                BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2.0),
                ),
          ),
        ),
      ),
    );
  }
}
