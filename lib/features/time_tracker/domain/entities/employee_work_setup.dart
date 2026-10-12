/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: employee_work_setup.dart
/// Purpose: Declares `EmployeeWorkSetup` — everything check-in and the
///          attendance calculation need to know about ONE employee: where they
///          work, when, and which break / pause / location rules apply.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// The same shape whether the data came from Time Tracker (no-HR company:
/// assignment + location) or from HR (Shift_Assignments + Shifts) — see
/// `WorkSetupSource`. [owner] says which.
/// Updated: 9/10/2026 - decision 33: [rules] are the EFFECTIVE rules
/// (employee custom → group custom → location) and [rulesSource] says which.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

class EmployeeWorkSetup {
  const EmployeeWorkSetup({
    required this.owner,
    required this.location,
    required this.schedule,
    this.rules = const AttendanceRules(),
    this.startDate,
    this.rulesSource = RulesSource.employee,
  });

  final WorkSetupOwner owner;

  /// The employee's assigned location.
  final WorkLocation location;

  /// The hours the employee is expected to work.
  final WorkSchedule schedule;
  final AttendanceRules rules;

  /// First day the assignment applies (null = immediately).
  final DateTime? startDate;

  /// ADDED 9/10/2026 (decision 33): where [rules] come from — the location,
  /// the group's custom rules or the employee's own (`EffectiveRulesResolver`).
  final RulesSource rulesSource;
}
