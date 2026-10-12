/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_event_tap.dart
/// Purpose: Makes a calendar event card tappable — a To-Do card opens THAT
///          to-do's details; a Time Tracker card opens that request (or
///          attendance day) inside the module.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 9/10/2026 - Time Tracker phase 6: `TimeTrackerCalendarEvent`
///          cards open `TimeTrackerModuleEntry` — the request's details (the
///          approver's details for "Awaiting Your Approval"), or, for a late
///          / absent card, the Attendance tab filtered to that day.
///
/// WHY ONE SHARED WRAPPER
/// ----------------------
/// The calendar draws event cards in two widgets:
///   * `EventCard`       — the day's list under the MONTH grid (full calendar
///                         screen, phone and tablet). The screen OPENS in month
///                         view, so this is the card the user sees first;
///   * `DayTimelineView` — the DAY view of the full screen (phone + tablet) and
///                         the home calendar card's timeline.
/// The first To-Do tap fix only wrapped the day-timeline card, so tapping a
/// To-Do card in the month view (the default) did nothing at all, and the
/// day-view tap opened the module root instead of the to-do. Both cards now
/// go through this wrapper, so every view routes the same way.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';

class CalendarEventTap extends StatelessWidget {
  const CalendarEventTap({
    super.key,
    required this.event,
    required this.child,
  });

  /// The event the card shows.
  final CalendarEventModel event;

  /// The card itself.
  final Widget child;

  /// Whether a tap on [event] leads anywhere. To-Do and (9/10/2026) Time
  /// Tracker cards navigate; every other module's card is returned
  /// untouched, as before.
  bool get _isTappable =>
      event.type is TodoCalendarEvent || event.type is TimeTrackerCalendarEvent;

  /// Function Name: [destinationOf]
  ///
  /// Purpose: The page a tap on [event] opens (null = not tappable).
  /// To-Do: that to-do's details (`TodoModuleEntry.initialTodoId`; a card
  /// without an id — a seeded demo card — opens the list). Time Tracker: the
  /// request (approver's details for an approval card), or the Attendance
  /// tab on that day for a late / absent card; no id → the module.
  ///
  /// Parameters:
  ///   [CalendarEventModel] event
  ///
  /// Return type: [Widget?]
  static Widget? destinationOf(CalendarEventModel event) {
    final String id = (event.requestId ?? '').trim();
    final Object? type = event.type;
    if (type is TodoCalendarEvent) {
      return TodoModuleEntry(initialTodoId: id.isEmpty ? null : id);
    }
    if (type is TimeTrackerCalendarEvent) {
      if (type.opensAttendanceDay) {
        return TimeTrackerModuleEntry(initialAttendanceDate: event.date);
      }
      return TimeTrackerModuleEntry(
        initialRequestId: id.isEmpty ? null : id,
        initialAsApproval: type == TimeTrackerCalendarEvent.approvalPending,
      );
    }
    return null;
  }

  /// Function Name: [_open]
  ///
  /// Purpose: Low haptic, then open [destinationOf].
  ///
  /// Parameters:
  ///   [BuildContext] context
  ///
  /// Return type: [void]
  void _open(BuildContext context) {
    final Widget? page = destinationOf(event);
    if (page == null) return;
    HapticController.low();
    navigateTo(context, page);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTappable) return child;
    return GestureDetector(
      // Opaque: the card's padding and gaps are hit too, not only its text.
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(context),
      child: child,
    );
  }
}
