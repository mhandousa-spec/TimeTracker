/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: employee_placement.dart
/// Purpose: Declares `EmployeePlacement` — where ONE employee is assigned and
///          the hours they are expected to work, as the HR dashboard needs it
///          for every employee at once (Location filter, "absent today",
///          absences of the month).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Same meaning as `EmployeeWorkSetup`, without the check-in rules: no-HR
/// companies fill it from `Location_Assignments` + the location's schedule,
/// HR companies from `Shift_Assignments` + `Shifts` (every day a working day,
/// no start date — `HrWorkSetupSource` defaults). Plain immutable Dart.

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

class EmployeePlacement {
  const EmployeePlacement({
    required this.email,
    required this.locationId,
    required this.schedule,
    this.startDate,
  });

  /// Lower-cased.
  final String email;

  /// The assigned location ('' = none known).
  final String locationId;

  /// The hours the employee is expected to work.
  final WorkSchedule schedule;

  /// First day the assignment applies (null = unknown, e.g. HR shifts).
  final DateTime? startDate;
}
