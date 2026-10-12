/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_builder.dart
/// Purpose: Declares `TimeTrackerDemoBuilder` — puts the DEBUG-ONLY demo
///          plan together: set-up, requests, attendance and the 21-day
///          vacation balances (used days = what the plan's approved annual
///          vacations deducted this year).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — demo data)
///
/// Pure Dart; `TimeTrackerDemoService` writes the result.

import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_attendance.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_requests.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/request_status.dart';

abstract final class TimeTrackerDemoBuilder {
  /// The yearly vacation days every demo balance holds (owner brief).
  static const double yearlyDays = 21;

  /// Function Name: [build]
  ///
  /// Purpose: The whole demo plan for [input]; free texts in the app
  /// language ([isArabic]).
  ///
  /// Return type: [TtDemoPlan]
  static TtDemoPlan build(TtDemoInput input, {required bool isArabic}) {
    final TtDemoSetup setup = TtDemoSetup(input);
    final List<TtDemoRequest> requests = TtDemoRequests(input, setup, isArabic: isArabic).build();
    final EmployeeGroup? group = setup.group;
    return TtDemoPlan(
      locations: setup.createsLocations ? TtDemoSetup.demoLocations : const [],
      groups: group == null ? const <EmployeeGroup>[] : <EmployeeGroup>[group],
      assignments: setup.assignments,
      requestTypes: setup.requestTypes,
      balances: <VacationBalance>[
        for (final TimeTrackerEmployee e in input.everyone) _balance(e, requests, input.now.year),
      ],
      days: TtDemoAttendance(input, setup, requests).build(),
      requests: requests,
      typesCreatedAt: setup.setupDate,
    );
  }

  static VacationBalance _balance(TimeTrackerEmployee e, List<TtDemoRequest> requests, int year) {
    double used = 0;
    for (final TtDemoRequest r in requests) {
      final bool held = r.request.status == RequestStatus.approved || r.request.status == RequestStatus.underReview;
      if (r.request.requesterEmail != e.email || !held || r.request.startAt.year != year) continue;
      used += r.request.deductedVacationDays ?? 0;
    }
    return VacationBalance(employeeEmail: e.email, year: year, totalDays: yearlyDays, usedDays: used);
  }
}
