// Module: core
//
//*************************** FILE INFO ****************************///
// File Name: _focus_date.dart
// Purpose: Declares `_FocusedDate`.
// Author: Knowticed Plus team
// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Module: core/custom
//
//*************************** FILE INFO ****************************///
// File Name: _focus_date.dart
// Purpose: Declares `_FocusedDate`.
// Author: Knowticed Plus team
// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

part of '../calendar_date_picker2.dart';

/// InheritedWidget indicating what the current focused date is for its children.
///
/// This is used by the [_CalendarView] to let its children [_DayPicker]s know
/// what the currently focused date (if any) should be.
class _FocusedDate extends InheritedWidget {
  const _FocusedDate({
    required super.child,
    this.date,
  });

  final DateTime? date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static DateTime? maybeOf(BuildContext context) {
    final _FocusedDate? focusedDate =
        context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}
