/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_options.dart
/// Purpose: Declares `CheckInOption` (one entry of the check-in sheet's
///          "Work Location" dropdown) and `CheckInOptions` — which entries an
///          employee may pick.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma check-in sheet `661:17263` / menu `661:17281` (Warehouse · Office -1
/// · Main Office · Remote · Client Site). Rules (owner decision 5 + brief
/// phase 2, 8/10/2026):
///   * the employee's assigned location is always offered (first);
///   * other company locations from the assignment's "Allowed Location"
///     list, Remote and Client Site are offered ONLY when the employee may
///     work elsewhere (`Work_From_Different_Location` switch AND the
///     assignment's `Is_Different_Location_Allowed`);
///   * inactive / deleted locations are never offered.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_work_setup.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/attendance_status.dart';

class CheckInOption {
  const CheckInOption.office(WorkLocation this.location)
      : type = WorkLocationType.office;

  const CheckInOption.away(this.type) : location = null;

  final WorkLocationType type;

  /// The company location (office only).
  final WorkLocation? location;

  /// Stable key for the dropdown: the location id, or the away type.
  String get key => location?.id ?? type.storageKey;
}

class CheckInOptions {
  const CheckInOptions._();

  /// Function Name: [build]
  ///
  /// Purpose: The options of the check-in sheet, in display order.
  ///
  /// Parameters:
  ///   [EmployeeWorkSetup] setup: where the employee is assigned.
  ///   [List<WorkLocation>] companyLocations: every location (for the
  ///     allowed-other list).
  ///   [bool] mayWorkElsewhere: switch AND assignment allow other places.
  ///
  /// Return type: [List<CheckInOption>]
  static List<CheckInOption> build({
    required EmployeeWorkSetup setup,
    required List<WorkLocation> companyLocations,
    required bool mayWorkElsewhere,
  }) {
    final List<CheckInOption> out = <CheckInOption>[];
    if (setup.location.isActive) out.add(CheckInOption.office(setup.location));
    if (!mayWorkElsewhere) return List<CheckInOption>.unmodifiable(out);
    for (final String id in setup.rules.allowedLocationIds) {
      if (id == setup.location.id) continue;
      for (final WorkLocation l in companyLocations) {
        if (l.id == id && l.isActive) out.add(CheckInOption.office(l));
      }
    }
    out
      ..add(const CheckInOption.away(WorkLocationType.remote))
      ..add(const CheckInOption.away(WorkLocationType.clientSite));
    return List<CheckInOption>.unmodifiable(out);
  }
}
