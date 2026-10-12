/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: controller.dart
/// Purpose: Selected-date controller.
/// Author: Vendored — advanced_calendar, forked into this repo
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N14: added the standard header.
///
/// NOTE (CR-SKEL-CAL-N05): this package is a vendored, generic calendar
/// widget set. Per §5 it belongs in `lib/core/custom/`, not inside a
/// feature. Moving it is a separate change.

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/features/calendar/c1_calendar/presentation/ui/widgets/calendar_package/datetime_util.dart';

/// Advanced Calendar controller that manage selection date state.
class AdvancedCalendarController extends ValueNotifier<DateTime> {
  /// Generates controller with custom date selected.
  AdvancedCalendarController(DateTime value) : super(value);

  /// Generates controller with today date selected.
  AdvancedCalendarController.today() : this(DateTime.now().toZeroTime());

  @override
  set value(DateTime newValue) => super.value = newValue.toZeroTime();
}
