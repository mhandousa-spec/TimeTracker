/// Module: time_tracker / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: work_setup_source.dart
/// Purpose: Declares `WorkSetupSource` — the ONE interface screens use to get
///          locations, shift hours and an employee's assignment, whoever owns
///          them.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// KEY ARCHITECTURE RULE (owner decision 7, 8/10/2026): a company may buy
/// Time Tracker without HR. Then Time Tracker owns locations (with working
/// hours), assignments and groups. With HR, HR owns them (Shift Management)
/// and Time Tracker only reads. Two implementations exist —
/// `TimeTrackerWorkSetupSource` and `HrWorkSetupSource` — and
/// `WorkSetupSourceResolver` picks one from the company's licence. Screens
/// only ever see this interface.
///
/// Error policy: methods complete or throw a clean `Exception`.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

abstract class WorkSetupSource {
  /// Which module the data comes from.
  WorkSetupOwner get owner;

  /// Function Name: [loadLocations]
  ///
  /// Purpose: Every location an employee can be assigned to / check in at
  /// (active ones only).
  ///
  /// Return type: [Future<List<WorkLocation>>]
  Future<List<WorkLocation>> loadLocations();

  /// Function Name: [loadWorkSetup]
  ///
  /// Purpose: One employee's location, schedule and rules.
  ///
  /// Parameters:
  ///   [String] employeeEmail: key of Time Tracker data.
  ///   [String] employeeId: key of HR data (`Shift_Assignments/{employeeId}`).
  ///
  /// Return type: [Future<EmployeeWorkSetup?>] — null when the employee is
  /// not assigned anywhere (they cannot check in).
  Future<EmployeeWorkSetup?> loadWorkSetup({
    required String employeeEmail,
    required String employeeId,
  });
}
