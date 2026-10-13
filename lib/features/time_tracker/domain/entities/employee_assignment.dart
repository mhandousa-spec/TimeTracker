/// Module: time_tracker / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: employee_assignment.dart
/// Purpose: Declares `AttendanceRules` (break / pause / different-location
///          rules), `LocationAssignment` (one employee → one location) and
///          `EmployeeGroup` (a named set of employees sharing the same rules).
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// FINAL SPEC §2 `Location_Assignments/{email}` and `Groups/{id}` (no-HR
/// companies; with HR the assignment comes from HR Shift Management). Both
/// carry the same rule fields as the Figma "Review / Grant Access" dialog
/// (`661:95280`). An assignment with an empty [LocationAssignment.locationId]
/// is "unassigned" (Remove Employee Assignment keeps the history).
///
/// Plain immutable Dart: no Firestore, no Flutter.
/// Updated: 9/10/2026 - owner decisions 32–33 (round 6): the LOCATION is the
/// source of the break / pause rules — [AttendanceRules.isCustom] false =
/// "Use the location's rules" (nothing copied; resolved from the location
/// at read time by `EffectiveRulesResolver`), true = custom rules for this
/// group / employee only. Group name + description are bilingual
/// ([EmployeeGroup.nameAr] / [EmployeeGroup.descriptionAr]).

import 'package:knowticed_plus/features/time_tracker/domain/entities/audit_info.dart';

/// The attendance rules granted with an assignment or a group.
class AttendanceRules {
  const AttendanceRules({
    this.isBreakAllowed = false,
    this.breakMinutes = 0,
    this.isPauseAllowed = false,
    this.pauseMinutes = 0,
    this.isDifferentLocationAllowed = false,
    this.allowedLocationIds = const <String>[],
    this.isCustom = true,
  });

  /// Follows the location (owner decision 33): no break / pause of its own.
  static const AttendanceRules fromLocation = AttendanceRules(isCustom: false);

  final bool isBreakAllowed;
  final int breakMinutes;
  final bool isPauseAllowed;

  /// ADDED 9/10/2026 (approved schema `Custom_Rules.Allowed_Pause_Minutes`):
  /// the longest pause (0 = no limit).
  final int pauseMinutes;
  final bool isDifferentLocationAllowed;

  /// Other locations the employee may check in at ("Select Location").
  final List<String> allowedLocationIds;

  /// ADDED 9/10/2026 (decision 33, `Custom_Rules.Is_Custom`): true = the break /
  /// pause values above override the location's; false = the location's
  /// apply. Rows written before the flag existed read as true (their values
  /// were chosen explicitly), so nothing changes for them.
  final bool isCustom;

  /// ADDED 13/10/2026: the same working rules (break / pause / custom flag)
  /// — a change sends "Shift Updated" to the employee.
  bool sameShiftAs(AttendanceRules o) =>
      isCustom == o.isCustom &&
      isBreakAllowed == o.isBreakAllowed &&
      breakMinutes == o.breakMinutes &&
      isPauseAllowed == o.isPauseAllowed &&
      pauseMinutes == o.pauseMinutes;

  /// ADDED 13/10/2026: the same extra check-in places.
  bool samePlacesAs(AttendanceRules o) =>
      isDifferentLocationAllowed == o.isDifferentLocationAllowed &&
      allowedLocationIds.toSet().containsAll(o.allowedLocationIds) &&
      o.allowedLocationIds.toSet().containsAll(allowedLocationIds);

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [AttendanceRules]
  AttendanceRules copyWith({
    bool? isBreakAllowed,
    int? breakMinutes,
    bool? isPauseAllowed,
    int? pauseMinutes,
    bool? isDifferentLocationAllowed,
    List<String>? allowedLocationIds,
    bool? isCustom,
  }) =>
      AttendanceRules(
        isBreakAllowed: isBreakAllowed ?? this.isBreakAllowed,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        isPauseAllowed: isPauseAllowed ?? this.isPauseAllowed,
        pauseMinutes: pauseMinutes ?? this.pauseMinutes,
        isDifferentLocationAllowed: isDifferentLocationAllowed ?? this.isDifferentLocationAllowed,
        allowedLocationIds: allowedLocationIds ?? this.allowedLocationIds,
        isCustom: isCustom ?? this.isCustom,
      );
}

class LocationAssignment {
  const LocationAssignment({
    required this.employeeEmail,
    this.locationId = '',
    this.startDate,
    this.rules = const AttendanceRules(),
    this.groupId = '',
    this.audit = AuditInfo.none,
  });

  /// Lower-cased; also the document id.
  final String employeeEmail;

  /// '' = unassigned.
  final String locationId;
  final DateTime? startDate;
  final AttendanceRules rules;

  /// The group the assignment came from ('' for a personal assignment).
  final String groupId;
  final AuditInfo audit;

  bool get isAssigned => locationId.isNotEmpty;

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [LocationAssignment]
  LocationAssignment copyWith({
    String? locationId,
    DateTime? startDate,
    AttendanceRules? rules,
    String? groupId,
  }) =>
      LocationAssignment(
        employeeEmail: employeeEmail,
        locationId: locationId ?? this.locationId,
        startDate: startDate ?? this.startDate,
        rules: rules ?? this.rules,
        groupId: groupId ?? this.groupId,
        audit: audit,
      );
}

/// ADDED 13/10/2026 (owner T8): one step of an employee's location history
/// — a row of `Location_Assignments/{email}` where the work locations
/// changed (assigned, transferred or removed).
class AssignmentHistoryEntry {
  const AssignmentHistoryEntry({
    required this.locationId,
    this.extraLocationIds = const <String>[],
    this.startDate,
    this.changedAt,
    this.changedBy = '',
    this.groupId = '',
  });

  /// Main location ('' = the assignment was removed).
  final String locationId;
  final List<String> extraLocationIds;
  final DateTime? startDate;

  /// When the row was written, and by whom (e-mail).
  final DateTime? changedAt;
  final String changedBy;
  final String groupId;

  bool get isRemoval => locationId.isEmpty;
}

class EmployeeGroup {
  const EmployeeGroup({
    required this.id,
    required this.name,
    this.nameAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.imageUrl = '',
    this.memberEmails = const <String>[],
    this.locationId = '',
    this.startDate,
    this.rules = const AttendanceRules(),
    this.isDeleted = false,
    this.audit = AuditInfo.none,
  });

  final String id;

  /// English name (`Group_Name`).
  final String name;

  /// ADDED 9/10/2026 (decision 32): Arabic name (`Group_Name_Ar`).
  final String nameAr;
  final String description;

  /// ADDED 9/10/2026 (decision 32): Arabic description (`Description_Ar`).
  final String descriptionAr;
  final String imageUrl;
  final List<String> memberEmails;
  final String locationId;
  final DateTime? startDate;
  final AttendanceRules rules;

  /// Soft delete (Delete Group keeps the history) — STATUS.md assumption A4.
  final bool isDeleted;
  final AuditInfo audit;

  /// Function Name: [label] / [about]
  ///
  /// Purpose: The name / description in the app language, falling back to
  /// the other one (9/10/2026, decision 32).
  ///
  /// Return type: [String]
  String label({required bool isArabic}) => _pick(isArabic ? nameAr : name, isArabic ? name : nameAr);
  String about({required bool isArabic}) =>
      _pick(isArabic ? descriptionAr : description, isArabic ? description : descriptionAr);

  static String _pick(String first, String fallback) =>
      first.trim().isNotEmpty ? first.trim() : fallback.trim();

  /// Function Name: [copyWith]
  ///
  /// Purpose: Immutable update.
  ///
  /// Return type: [EmployeeGroup]
  EmployeeGroup copyWith({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    List<String>? memberEmails,
    String? locationId,
    DateTime? startDate,
    AttendanceRules? rules,
    bool? isDeleted,
  }) =>
      EmployeeGroup(
        id: id,
        name: name ?? this.name,
        nameAr: nameAr ?? this.nameAr,
        description: description ?? this.description,
        descriptionAr: descriptionAr ?? this.descriptionAr,
        imageUrl: imageUrl ?? this.imageUrl,
        memberEmails: memberEmails ?? this.memberEmails,
        locationId: locationId ?? this.locationId,
        startDate: startDate ?? this.startDate,
        rules: rules ?? this.rules,
        isDeleted: isDeleted ?? this.isDeleted,
        audit: audit,
      );
}
