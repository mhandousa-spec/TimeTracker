/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: effective_rules.dart
/// Purpose: Declares `RulesSource`, `EffectiveRules` and
///          `EffectiveRulesResolver` — which break / pause /
///          different-location rules apply to ONE employee, and where they
///          come from.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (owner decision 33, round 6)
///
/// Owner decision 33 (9/10/2026): the LOCATION is the source of the
/// attendance rules (hours, working days, Late After, breaks + length,
/// pause). A group or a single employee either follows the location
/// ("Use the location's rules", `AttendanceRules.isCustom` false — nothing
/// is copied, so a later location edit applies at once) or has CUSTOM break
/// / pause rules for itself only. Precedence:
///   employee custom → group custom → location.
/// "Allow Different Work Location" (+ the allowed locations) is NOT a
/// location rule: it is the employee's own when their rules are custom,
/// else the group's when they belong to a (live) group, else their own.
///
/// Stored as the approved schema's `Custom_Rules` map (`Is_Custom`,
/// `Is_Break_Allowed`, `Allowed_Break_Minutes`, `Is_Pause_Allowed`,
/// `Allowed_Pause_Minutes`) on `Groups` / `Location_Assignments`; the
/// location's defaults are its own `Is_Break_Allowed`,
/// `Allowed_Break_Minutes`, `Is_Pause_Allowed`, `Allowed_Pause_Minutes`.
///
/// Pure Dart — unit-tested.

import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

/// Where an employee's effective break / pause rules come from.
enum RulesSource { location, group, employee }

/// The rules that apply, and their source ("From location" / "Custom").
class EffectiveRules {
  const EffectiveRules({required this.rules, required this.source});

  final AttendanceRules rules;
  final RulesSource source;

  bool get isFromLocation => source == RulesSource.location;
}

class EffectiveRulesResolver {
  const EffectiveRulesResolver._();

  /// Function Name: [locationRules]
  ///
  /// Purpose: The break / pause rules [location] sets.
  ///
  /// Return type: [AttendanceRules]
  static AttendanceRules locationRules(WorkLocation location) => AttendanceRules(
        isBreakAllowed: location.isBreakAllowed,
        breakMinutes: location.isBreakAllowed ? location.breakMinutes : 0,
        isPauseAllowed: location.isPauseAllowed,
        pauseMinutes: location.isPauseAllowed ? location.pauseMinutes : 0,
        isCustom: false,
      );

  /// Function Name: [resolve]
  ///
  /// Purpose: The effective rules of an employee assigned by [assignment]
  /// to [location], possibly through [group] (ignored unless it is the
  /// assignment's live group).
  ///
  /// Return type: [EffectiveRules]
  static EffectiveRules resolve({
    required WorkLocation location,
    LocationAssignment? assignment,
    EmployeeGroup? group,
  }) {
    final LocationAssignment? a = assignment;
    final EmployeeGroup? g = group != null &&
            !group.isDeleted &&
            a != null &&
            a.groupId.isNotEmpty &&
            a.groupId == group.id
        ? group
        : null;
    final AttendanceRules own = a?.rules ?? AttendanceRules.fromLocation;
    // Different location: the employee's own when custom, else the group's.
    final AttendanceRules elsewhere = own.isCustom || g == null ? own : g.rules;
    AttendanceRules withElsewhere(AttendanceRules r) => r.copyWith(
          isDifferentLocationAllowed: elsewhere.isDifferentLocationAllowed,
          allowedLocationIds: elsewhere.allowedLocationIds,
        );
    if (own.isCustom && a != null) {
      return EffectiveRules(rules: withElsewhere(own), source: RulesSource.employee);
    }
    if (g != null && g.rules.isCustom) {
      return EffectiveRules(rules: withElsewhere(g.rules), source: RulesSource.group);
    }
    return EffectiveRules(rules: withElsewhere(locationRules(location)), source: RulesSource.location);
  }
}
