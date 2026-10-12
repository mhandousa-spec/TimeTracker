/// Module: time_tracker / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: location_assignment_model.dart
/// Purpose: Declares `AttendanceRulesFields` (the break / pause /
///          different-location columns shared by assignments and groups) and
///          `LocationAssignmentModel` — Firestore <-> `LocationAssignment`
///          for one `Location_Assignments/{email}` history document.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Field names are FINAL SPEC §2 verbatim, plus `Location_Assignment_Id`
/// (= the email; house rule "every doc has an …_Id") and the audit trio.
/// Remove Employee Assignment writes an empty `Location_Id` (history kept).
/// Updated: 9/10/2026 - decision 33 + approved schema: the override is the
/// `Custom_Rules` map (old flat fields read as a fallback: explicit values =
/// custom, except a legacy group-linked assignment — it follows its group).

import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';

typedef _F = TimeTrackerFieldCodec;

/// The rule columns shared by `Location_Assignments` and `Groups`.
///
/// Approved schema (9/10/2026, `Module Schemas/Time Tracker/target.json`):
/// the break / pause override is ONE map field `Custom_Rules`
/// `{Is_Custom, Is_Break_Allowed, Allowed_Break_Minutes, Is_Pause_Allowed,
/// Allowed_Pause_Minutes}` (absent or `Is_Custom` false = follow the next
/// level: employee → group → location). "Allow Different Work Location"
/// stays two separate fields. Documents written before keep being READ:
/// the old flat `Is_Break_Allowed` / `Break_Minutes` / `Is_Pause_Allowed`
/// (+ this app's short-lived `Is_Custom_Rules`) — never written again.
class AttendanceRulesFields {
  const AttendanceRulesFields._();

  static const String fCustomRules = 'Custom_Rules';
  static const String kIsCustom = 'Is_Custom';
  static const String kIsBreakAllowed = 'Is_Break_Allowed';
  static const String kBreakMinutes = 'Allowed_Break_Minutes';
  static const String kIsPauseAllowed = 'Is_Pause_Allowed';
  static const String kPauseMinutes = 'Allowed_Pause_Minutes';

  static const String fIsDifferentLocation = 'Is_Different_Location_Allowed';
  static const String fAllowedLocationIds = 'Allowed_Location_Ids';

  /// LEGACY (read only): the flat rule fields written before `Custom_Rules`.
  static const String fIsBreakAllowed = 'Is_Break_Allowed';
  static const String fBreakMinutes = 'Break_Minutes';
  static const String fIsPauseAllowed = 'Is_Pause_Allowed';

  /// LEGACY (read only): the flag written by this app on 9/10/2026 before
  /// the approved `Custom_Rules.Is_Custom`.
  static const String fIsCustomRules = 'Is_Custom_Rules';

  /// Function Name: [hasOverrideField]
  ///
  /// Purpose: [map] states its override explicitly (`Custom_Rules`, or the
  /// legacy `Is_Custom_Rules`) — false for documents written before both.
  ///
  /// Return type: [bool]
  static bool hasOverrideField(Map<String, dynamic> map) =>
      TimeTrackerHistoryCodec.lastOf(map, fCustomRules) is Map ||
      TimeTrackerHistoryCodec.lastOf(map, fIsCustomRules) != null;

  /// Function Name: [from]
  ///
  /// Purpose: Read the current rules (last history entries) of [map]:
  /// `Custom_Rules` when present; else the legacy flat fields (explicit
  /// values → custom, unless the legacy `Is_Custom_Rules` says otherwise).
  ///
  /// Return type: [AttendanceRules]
  static AttendanceRules from(Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final bool different = _F.boolean(now(fIsDifferentLocation));
    final List<String> allowed = _F.strings(now(fAllowedLocationIds));
    final Object? custom = now(fCustomRules);
    if (custom is Map) {
      final Map<String, dynamic> c = Map<String, dynamic>.from(custom);
      final bool on = _F.boolean(c[kIsCustom]);
      final bool breaks = on && _F.boolean(c[kIsBreakAllowed]);
      final bool pause = on && _F.boolean(c[kIsPauseAllowed]);
      return AttendanceRules(
        isCustom: on,
        isBreakAllowed: breaks,
        breakMinutes: breaks ? _F.integer(c[kBreakMinutes]) : 0,
        isPauseAllowed: pause,
        pauseMinutes: pause ? _F.integer(c[kPauseMinutes]) : 0,
        isDifferentLocationAllowed: different,
        allowedLocationIds: allowed,
      );
    }
    return AttendanceRules(
      isBreakAllowed: _F.boolean(now(fIsBreakAllowed)),
      breakMinutes: _F.integer(now(fBreakMinutes)),
      isPauseAllowed: _F.boolean(now(fIsPauseAllowed)),
      isDifferentLocationAllowed: different,
      allowedLocationIds: allowed,
      isCustom: now(fIsCustomRules) != false,
    );
  }

  /// Function Name: [to]
  ///
  /// Purpose: The rule columns of one history row: `Custom_Rules` (always
  /// written, `Is_Custom` false = "Use the location's rules", so an old flat
  /// value can never be mistaken for an override) + the different-location
  /// fields.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> to(AttendanceRules rules) {
    final bool on = rules.isCustom;
    final bool breaks = on && rules.isBreakAllowed;
    final bool pause = on && rules.isPauseAllowed;
    return <String, Object?>{
      fCustomRules: <String, Object?>{
        kIsCustom: on,
        kIsBreakAllowed: breaks,
        kBreakMinutes: breaks ? rules.breakMinutes : 0,
        kIsPauseAllowed: pause,
        kPauseMinutes: pause && rules.pauseMinutes > 0 ? rules.pauseMinutes : 0,
      },
      fIsDifferentLocation: rules.isDifferentLocationAllowed,
      fAllowedLocationIds: _F.wrap(
        rules.isDifferentLocationAllowed
            ? List<Object?>.of(rules.allowedLocationIds)
            : const <Object?>[],
      ),
    };
  }
}

class LocationAssignmentModel {
  const LocationAssignmentModel._();

  static const String fAssignmentId = 'Location_Assignment_Id';
  static const String fEmployeeEmail = 'Employee_Email';
  static const String fLocationId = 'Location_Id';
  static const String fStartDate = 'Start_Date';
  static const String fGroupId = 'Group_Id';

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build the entity from the LAST entry of every history list.
  ///
  /// Return type: [LocationAssignment]
  static LocationAssignment fromMap(String id, Map<String, dynamic> map) {
    Object? now(String key) => TimeTrackerHistoryCodec.lastOf(map, key);
    final String email = _F.string(now(fEmployeeEmail));
    final String groupId = _F.string(now(fGroupId));
    final AttendanceRules rules = AttendanceRulesFields.from(map);
    return LocationAssignment(
      employeeEmail: email.isNotEmpty ? email : id,
      locationId: _F.string(now(fLocationId)),
      startDate: _F.date(now(fStartDate)),
      // Decision 33 (9/10/2026): a row written BEFORE `Is_Custom_Rules`
      // that came from a group holds a COPY of the group's rules (A7), so it
      // follows the group (same values today, and later group edits apply
      // again); a personal legacy row keeps its explicit values (custom).
      rules: groupId.isNotEmpty && !AttendanceRulesFields.hasOverrideField(map)
          ? rules.copyWith(isCustom: false)
          : rules,
      groupId: groupId,
      audit: _F.auditOf(map),
    );
  }

  /// Function Name: [row]
  ///
  /// Purpose: Field name -> new value for every field of one history row.
  ///
  /// Return type: [Map<String, Object?>]
  static Map<String, Object?> row(
    LocationAssignment assignment, {
    required String id,
    required TimeTrackerAudit audit,
  }) =>
      <String, Object?>{
        fAssignmentId: id,
        fEmployeeEmail: assignment.employeeEmail.trim().toLowerCase(),
        fLocationId: assignment.locationId,
        fStartDate: _F.timestamp(assignment.startDate),
        ...AttendanceRulesFields.to(assignment.rules),
        fGroupId: assignment.groupId,
        ...audit.fields,
      };
}
